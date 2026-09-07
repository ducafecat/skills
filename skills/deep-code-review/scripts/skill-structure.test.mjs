import assert from 'node:assert/strict'
import {
  existsSync,
  readFileSync,
  readdirSync,
  statSync,
} from 'node:fs'
import { dirname, join } from 'node:path'
import test from 'node:test'
import { fileURLToPath } from 'node:url'

const scriptsDirectory = dirname(fileURLToPath(import.meta.url))
const skillDirectory = dirname(scriptsDirectory)
const skillPath = join(skillDirectory, 'SKILL.md')
const rulesDirectory = join(
  skillDirectory,
  'references',
  'ai_review_rules',
)
const expectedRules = [
  'architect.md',
  'devops.md',
  'product_contract.md',
  'reviewer.md',
  'runtime_performance.md',
  'security.md',
]

test('skill metadata and referenced resources are complete', () => {
  const skill = readFileSync(skillPath, 'utf8')
  const frontmatter = skill.match(/^---\n([\s\S]*?)\n---/)

  assert.ok(frontmatter, 'SKILL.md must start with YAML frontmatter')
  assert.match(frontmatter[1], /^name: code-review$/m)
  assert.match(frontmatter[1], /^description: .+$/m)
  assert.ok(
    existsSync(join(scriptsDirectory, 'build-review-manifest.mjs')),
    'manifest helper must exist',
  )

  const references = [
    ...skill.matchAll(/`(references\/[a-z0-9_./-]+\.md)`/g),
  ].map((match) => match[1])
  assert.ok(references.length > 0, 'SKILL.md must route supporting references')
  for (const reference of references) {
    assert.ok(existsSync(join(skillDirectory, reference)), `${reference} must exist`)
  }
})

test('AI rules contain only compact runtime requirements', () => {
  const actualRules = readdirSync(rulesDirectory)
    .filter((name) => name.endsWith('.md'))
    .sort()
  assert.deepEqual(actualRules, expectedRules)

  let totalBytes = 0
  for (const rule of actualRules) {
    const path = join(rulesDirectory, rule)
    const content = readFileSync(path, 'utf8')
    totalBytes += statSync(path).size
    assert.doesNotMatch(content, /audit_bot/)
    assert.doesNotMatch(content, /\{(?:project_context|diff_content|role_outputs)\}/)
    assert.doesNotMatch(content, /(?:代码质量|安全|架构|DevOps|性能|产品契约)评分/)
    assert.doesNotMatch(content, /输出格式/)
  }
  assert.ok(totalBytes <= 10_000, `AI rules total ${totalBytes} bytes`)
})

test('runtime instructions do not require Python', () => {
  const runtimeFiles = [
    skillPath,
    join(skillDirectory, 'references', 'standards.md'),
    ...expectedRules.map((rule) => join(rulesDirectory, rule)),
  ]
  const runtimeText = runtimeFiles
    .map((path) => readFileSync(path, 'utf8'))
    .join('\n')

  assert.doesNotMatch(runtimeText, /\bpython(?:3)?\b/i)
  assert.doesNotMatch(runtimeText, /\.py\b/i)
})
