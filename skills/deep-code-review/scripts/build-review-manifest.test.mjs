import assert from 'node:assert/strict'
import { spawnSync } from 'node:child_process'
import {
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from 'node:fs'
import { tmpdir } from 'node:os'
import { dirname, join } from 'node:path'
import test from 'node:test'
import { fileURLToPath } from 'node:url'

const scriptPath = fileURLToPath(
  new URL('./build-review-manifest.mjs', import.meta.url),
)

function git(repository, args) {
  const result = spawnSync('git', args, {
    cwd: repository,
    encoding: 'utf8',
  })
  assert.equal(result.status, 0, result.stderr)
  return result.stdout.trim()
}

function write(repository, path, content) {
  const absolutePath = join(repository, path)
  mkdirSync(dirname(absolutePath), { recursive: true })
  writeFileSync(absolutePath, content)
}

function createRepository(t) {
  const repository = mkdtempSync(join(tmpdir(), 'code-review-fixture-'))
  t.after(() => rmSync(repository, { force: true, recursive: true }))
  git(repository, ['init', '--quiet'])
  git(repository, ['config', 'user.email', 'review@example.com'])
  git(repository, ['config', 'user.name', 'Review Test'])
  write(repository, 'base.txt', 'base\n')
  git(repository, ['add', 'base.txt'])
  git(repository, ['commit', '--quiet', '-m', 'base'])
  return repository
}

function runHelper(t, repository, args = []) {
  const result = spawnSync(process.execPath, [scriptPath, ...args], {
    cwd: repository,
    encoding: 'utf8',
  })
  assert.equal(result.status, 0, result.stderr)
  assert.equal(result.stderr, '')
  const manifestPath = result.stdout.trim()
  assert.match(manifestPath, /manifest\.json$/)
  assert.equal(result.stdout, `${manifestPath}\n`)
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'))
  t.after(() => rmSync(manifest.tempDirectory, { force: true, recursive: true }))
  return manifest
}

function layer(manifest, kind) {
  return manifest.layers.find((entry) => entry.kind === kind)
}

test('clean worktree creates an empty manifest', (t) => {
  const repository = createRepository(t)
  const manifest = runHelper(t, repository)

  assert.equal(manifest.mode, 'working-tree')
  assert.equal(manifest.textFileCount, 0)
  assert.equal(manifest.changedLines, 0)
  assert.equal(manifest.sizeEligibleForLightReview, true)
  assert.deepEqual(manifest.standardSources, [])
})

test('collects staged, unstaged and untracked layers', (t) => {
  const repository = createRepository(t)
  write(repository, 'staged.txt', 'staged\n')
  git(repository, ['add', 'staged.txt'])
  write(repository, 'base.txt', 'base\nunstaged\n')
  write(repository, 'untracked.txt', 'untracked\n')

  const manifest = runHelper(t, repository)

  assert.deepEqual(manifest.textFiles, ['base.txt', 'staged.txt', 'untracked.txt'])
  assert.deepEqual(layer(manifest, 'staged').paths, ['staged.txt'])
  assert.deepEqual(layer(manifest, 'unstaged').paths, ['base.txt'])
  assert.deepEqual(layer(manifest, 'untracked').paths, ['untracked.txt'])
  assert.equal(manifest.changedLines, 3)
})

test('fixed-point mode includes committed and working-tree changes', (t) => {
  const repository = createRepository(t)
  const base = git(repository, ['rev-parse', 'HEAD'])
  write(repository, 'committed.txt', 'committed\n')
  git(repository, ['add', 'committed.txt'])
  git(repository, ['commit', '--quiet', '-m', 'committed'])
  write(repository, 'base.txt', 'base\nworking tree\n')

  const manifest = runHelper(t, repository, ['--base', base])

  assert.equal(manifest.mode, 'fixed-point')
  assert.equal(manifest.baseCommit, base)
  assert.equal(manifest.commits.length, 1)
  assert.deepEqual(layer(manifest, 'committed').paths, ['committed.txt'])
  assert.deepEqual(layer(manifest, 'unstaged').paths, ['base.txt'])
})

test('filters ignored and tracked-but-ignored paths', (t) => {
  const repository = createRepository(t)
  write(repository, 'ignored.txt', 'tracked\n')
  git(repository, ['add', 'ignored.txt'])
  git(repository, ['commit', '--quiet', '-m', 'tracked ignored candidate'])
  write(repository, '.gitignore', 'ignored.txt\nignored-new.txt\n')
  git(repository, ['add', '.gitignore'])
  write(repository, 'ignored.txt', 'changed but ignored\n')
  write(repository, 'ignored-new.txt', 'untracked and ignored\n')

  const manifest = runHelper(t, repository)

  assert.deepEqual(manifest.textFiles, ['.gitignore'])
  assert.deepEqual(layer(manifest, 'unstaged').paths, [])
  assert.deepEqual(layer(manifest, 'untracked').paths, [])
})

test('excludes documentation from review', (t) => {
  const repository = createRepository(t)
  write(repository, 'docs/guide.md', '# guide\n')
  write(repository, 'readme.md', 'readme\n')
  write(repository, '.docs/note.md', 'note\n')
  write(repository, 'docs/data.json', '{"ok":true}\n')
  write(repository, 'src/App.java', 'class App {}\n')

  const manifest = runHelper(t, repository)

  assert.deepEqual(manifest.textFiles, ['src/App.java'])
  assert.equal(manifest.textFileCount, 1)
})

test('documentation-only changes produce an empty text manifest', (t) => {
  const repository = createRepository(t)
  write(repository, 'docs/技术说明.md', '# doc\n')

  const manifest = runHelper(t, repository)

  assert.equal(manifest.textFileCount, 0)
  assert.deepEqual(manifest.textFiles, [])
})

test('records binary files and preserves special text paths', (t) => {
  const repository = createRepository(t)
  const specialPath = 'space name\nfile.txt'
  write(repository, specialPath, 'text\n')
  writeFileSync(join(repository, 'binary.bin'), Buffer.from([1, 0, 2]))

  const manifest = runHelper(t, repository)

  assert.deepEqual(manifest.textFiles, [specialPath])
  assert.deepEqual(manifest.binaryFiles, ['binary.bin'])
  assert.equal(manifest.textFileCount, 1)
})

test('reviews an untracked symlink without reading its target', (t) => {
  const repository = createRepository(t)
  const externalDirectory = mkdtempSync(join(tmpdir(), 'code-review-secret-'))
  t.after(() => rmSync(externalDirectory, { force: true, recursive: true }))
  const target = join(externalDirectory, 'secret.txt')
  writeFileSync(target, 'must-not-enter-patch\n')
  symlinkSync(target, join(repository, 'external-link'))

  const manifest = runHelper(t, repository)
  const patch = readFileSync(layer(manifest, 'untracked').patchPath, 'utf8')

  assert.deepEqual(manifest.textFiles, ['external-link'])
  assert.doesNotMatch(patch, /must-not-enter-patch/)
  assert.match(patch, /code-review-secret-/)
})

test('keeps a rename as one logical text file', (t) => {
  const repository = createRepository(t)
  git(repository, ['mv', 'base.txt', 'renamed.txt'])

  const manifest = runHelper(t, repository)

  assert.deepEqual(manifest.textFiles, ['renamed.txt'])
  assert.equal(manifest.textFileCount, 1)
  assert.deepEqual(layer(manifest, 'staged').paths, ['base.txt', 'renamed.txt'])
})

test('does not leak the ignored side of a rename', (t) => {
  const repository = createRepository(t)
  write(repository, 'other.txt', 'other\n')
  git(repository, ['add', 'other.txt'])
  write(repository, '.gitignore', 'ignored-name.txt\n')
  git(repository, ['add', '.gitignore'])
  git(repository, ['commit', '--quiet', '-m', 'ignore rename destination'])
  git(repository, ['mv', '-f', 'base.txt', 'ignored-name.txt'])
  git(repository, ['mv', 'other.txt', 'other-renamed.txt'])

  const manifest = runHelper(t, repository)

  assert.deepEqual(manifest.textFiles, ['base.txt', 'other-renamed.txt'])
  assert.equal(manifest.textFileCount, 2)
  assert.deepEqual(
    layer(manifest, 'staged').paths,
    ['other.txt', 'other-renamed.txt', 'base.txt'],
  )
  const patch = readFileSync(layer(manifest, 'staged').patchPath, 'utf8')
  assert.doesNotMatch(patch, /^\+\+\+ b\/ignored-name\.txt$/m)
  assert.match(patch, /^rename from other\.txt$/m)
  assert.match(patch, /^rename to other-renamed\.txt$/m)
})

test('discovers only applicable tracked standards', (t) => {
  const repository = createRepository(t)
  const externalDirectory = mkdtempSync(join(tmpdir(), 'code-review-rules-'))
  t.after(() => rmSync(externalDirectory, { force: true, recursive: true }))
  const externalRules = join(externalDirectory, 'AGENTS.md')
  writeFileSync(externalRules, 'external rules must not load\n')
  write(repository, 'AGENTS.md', 'root rules\n')
  write(repository, 'src/AGENTS.md', 'src rules\n')
  write(repository, 'ignored/AGENTS.md', 'ignored tracked rules\n')
  write(repository, 'other/CONTRIBUTING.md', 'other rules\n')
  mkdirSync(join(repository, 'linked'), { recursive: true })
  symlinkSync(externalRules, join(repository, 'linked/AGENTS.md'))
  git(repository, [
    'add',
    'AGENTS.md',
    'src/AGENTS.md',
    'ignored/AGENTS.md',
    'linked/AGENTS.md',
    'other/CONTRIBUTING.md',
  ])
  git(repository, ['commit', '--quiet', '-m', 'standards'])
  write(repository, '.gitignore', 'ignored/AGENTS.md\n')
  git(repository, ['add', '.gitignore'])
  write(repository, 'src/changed.txt', 'changed\n')
  write(repository, 'ignored/changed.txt', 'ignored subtree change\n')
  write(repository, 'linked/changed.txt', 'linked subtree change\n')

  const manifest = runHelper(t, repository)

  assert.deepEqual(manifest.standardSources, ['AGENTS.md', 'src/AGENTS.md'])
})

test('computes the exact light-review size boundaries', (t) => {
  const repository = createRepository(t)
  const lines = (count) =>
    Array.from({ length: count }, (_, index) => `line ${index + 1}`).join('\n') + '\n'
  write(repository, 'first.txt', lines(25))
  write(repository, 'second.txt', lines(25))

  const eligible = runHelper(t, repository)
  assert.equal(eligible.textFileCount, 2)
  assert.equal(eligible.changedLines, 50)
  assert.equal(eligible.sizeEligibleForLightReview, true)

  write(repository, 'third.txt', 'line 51\n')
  const ineligible = runHelper(t, repository)
  assert.equal(ineligible.textFileCount, 3)
  assert.equal(ineligible.changedLines, 51)
  assert.equal(ineligible.sizeEligibleForLightReview, false)
})

test('rejects invalid refs without writing a manifest path', (t) => {
  const repository = createRepository(t)
  const result = spawnSync(
    process.execPath,
    [scriptPath, '--base', 'missing-review-ref'],
    { cwd: repository, encoding: 'utf8' },
  )

  assert.notEqual(result.status, 0)
  assert.equal(result.stdout, '')
  assert.match(result.stderr, /missing-review-ref|Needed a single revision/)
})
