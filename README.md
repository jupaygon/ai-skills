# ai-skills

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-2-blue.svg)](#available-skills)
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

| Skill                                                                      | Version  | Description                                                                                                      |
|----------------------------------------------------------------------------|----------|------------------------------------------------------------------------------------------------------------------|
| [easyadmin5](skills/easyadmin5/SKILL.md)                                   | 5.0.2+   | EasyAdmin 5 for Symfony — dashboard, CRUD, fields, filters, actions, events, security, design, migration from v4 |
| [symfony-security-audit](skills/symfony-security-audit/SKILL.md)           | 1.0.0    | Symfony 6/7 security audit — 10 recurring antipatterns (IDOR, injection, XSS, SSRF, auth) + 4 deep dives + grep-based scan plan + report format |

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

Contributions are welcome! Fork the repo and open a PR. You can:

- **Create a new skill** for a technology that is not covered yet
- **Improve an existing skill** — fix errors, add missing methods, update for new versions, improve examples

### Adding a new skill

1. Fork this repository
2. Create `skills/<name>/SKILL.md`
3. Follow this structure:
   - **Header**: Name, version, source URLs
   - **Breaking changes** (if migrating from a previous version)
   - **API reference**: Method signatures, parameters, return types
   - **Code examples**: Minimal, correct, copy-pasteable
   - **Common patterns**: Real-world usage, not toy examples
4. **Verify everything** against official documentation and source code — never guess
5. Open a PR from your fork

### How we verify skills

Skills go through an iterative review process before merging:

1. **Extraction** — API reference drafted from official docs and source code
2. **Multi-agent review** — Different AI agents cross-check every signature, parameter, and example against the real source code. Each reviewer catches errors the previous one missed
3. **Human review** — Final validation, judgment calls on what to include, and corrections
4. **Iteration** — Repeat until the error rate converges to zero

This process is why we trust the result: no single author (human or AI) reviews their own work.

### Quality rules

- Every method signature must be verified against official docs or source code
- No hallucinated APIs — if you are not sure, check
- Keep it concise — agents need facts, not prose
- Include version numbers — skills are version-specific
- Update when the library releases breaking changes

## Author

[Juanjo Payá](https://github.com/jupaygon) · [Blog](https://juanjopaya.com)

## License

MIT

---

If you find this useful, a star helps other developers discover it.
