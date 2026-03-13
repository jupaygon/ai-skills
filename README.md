# ai-skills

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-1-blue.svg)](#available-skills)
[![Claude Code](https://img.shields.io/badge/Claude_Code-compatible-blueviolet.svg)](https://claude.com/claude-code)
[![Cursor](https://img.shields.io/badge/Cursor-compatible-blue.svg)](https://cursor.com)

Production-ready AI skills for Claude Code, Cursor, and other AI coding agents. Verified references for frameworks, APIs, and dev workflows.

> **Stop your AI agent from hallucinating API calls.** Give it verified, up-to-date knowledge instead.

## What is a skill?

A **skill** is a structured reference document that gives an AI coding agent verified, up-to-date knowledge about a specific technology. Instead of guessing API signatures or hallucinating method names, the agent reads the skill and writes correct code on the first try.

Skills are **not tutorials** — they are concise, machine-optimized references extracted from official documentation and verified against real installations.

## Why?

AI coding agents have knowledge cutoffs. Libraries evolve. When EasyAdmin 5 drops `linkToCrud()` in favor of `linkTo()`, your agent doesn't know — unless you tell it.

Skills bridge that gap:
- **Verified** against official docs and real package versions
- **Structured** for fast LLM consumption (tables, signatures, examples)
- **Maintained** — updated when libraries release breaking changes

## Available skills

| Skill | Version | Description |
|-------|---------|-------------|
| [easyadmin5](skills/easyadmin5/SKILL.md) | 5.0.x | EasyAdmin 5 for Symfony — dashboard, CRUD, fields, actions, design, migration from v4 |

## How to use

### Claude Code

Add skills to your project's `.claude/skills/` directory, or reference them from a central location in your `CLAUDE.md`:

```markdown
# CLAUDE.md
When working with EasyAdmin, read the skill at /path/to/ai-skills/skills/easyadmin5/SKILL.md before writing any code.
```

Or copy the skill directly into your project:

```bash
cp -r skills/easyadmin5 /your-project/.claude/skills/
```

### Cursor / Other agents

Most AI coding agents support context files. Add the skill's `SKILL.md` as context when working with the relevant technology:

- **Cursor**: Add to `.cursor/rules/` or reference in project instructions
- **Windsurf**: Add to `.windsurfrules` or workspace context
- **Generic**: Include the file path in your system prompt or project docs

### Manual reference

Each `SKILL.md` is also a perfectly readable human reference. Bookmark it, `cat` it, or keep it open in a tab.

## Structure

```
skills/
└── <skill-name>/
    └── SKILL.md          # The skill reference (single file, self-contained)
```

Each skill is a single Markdown file — no dependencies, no build step, no config.

## Contributing

### Adding a new skill

1. Create `skills/<name>/SKILL.md`
2. Follow this structure:
   - **Header**: Name, version, source URLs
   - **Breaking changes** (if migrating from a previous version)
   - **API reference**: Method signatures, parameters, return types
   - **Code examples**: Minimal, correct, copy-pasteable
   - **Common patterns**: Real-world usage, not toy examples
3. **Verify everything** against official documentation — never guess
4. Submit a PR

### Quality rules

- Every method signature must be verified against official docs or source code
- No hallucinated APIs — if you're not sure, check
- Keep it concise — agents don't need prose, they need facts
- Include version numbers — skills are version-specific
- Update when the library releases breaking changes

## License

MIT
