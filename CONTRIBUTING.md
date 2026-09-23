# Contributing

## Skill structure

Each skill lives under `skills/<skill-name>/` and must include `SKILL.md`.

Use these optional directories only when they directly support the skill:

- `scripts/` for reusable executable helpers
- `references/` for detailed documentation loaded on demand
- `assets/` for templates or files used in generated output

## SKILL.md rules

- Keep `name` identical to the skill directory.
- Use lowercase letters, numbers, and hyphens only.
- Keep `description` under 1024 characters and include both purpose and trigger context.
- Keep the body concise; move long templates and detailed explanations to `references/`.
- Include `license`, `metadata.compatibility`, and `metadata.version` for publishable releases.

## Validation

Run the Codex skill validator before publishing:

```bash
python3 /Users/ducafecat/.codex/skills/.system/skill-creator/scripts/quick_validate.py skills/flutter-riverpod-init
python3 /Users/ducafecat/.codex/skills/.system/skill-creator/scripts/quick_validate.py skills/flutter-assets-compress
```

Also check:

- `SKILL.md` front matter parses correctly.
- Reference links point to existing files.
- Long documentation lives in `references/`.
- `.DS_Store` and generated local artifacts are not committed.

## Release

Use SemVer. Update `metadata.version` in each changed skill and add a `CHANGELOG.md` entry before tagging a release.
