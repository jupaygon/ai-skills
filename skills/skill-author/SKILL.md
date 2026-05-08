---
name: skill-author
description: Scaffold a new Claude Code skill with valid frontmatter, layout, and Agent Skills standard compliance. Invoke with /skill-author <skill-name> to create a new skill from a curated template. Asks 3 minimal questions (purpose, trigger phrases, manual-only vs auto-invocable), writes the SKILL.md, and reports the resulting path.
disable-model-invocation: true
allowed-tools: Bash(mkdir *) Bash(cp *) Bash(ls *) Bash(realpath *) Read Write Edit
argument-hint: [skill-name]
---

# /skill-author — create a new Claude Code skill from a template

You are scaffolding a new skill. The user invoked `/skill-author $ARGUMENTS`. The argument is the **skill name** (kebab-case, lowercase, ≤ 64 chars, `[a-z0-9-]+`).

## Step 1 — Validate the name

If `$ARGUMENTS` is empty, blank, or fails the regex `^[a-z][a-z0-9-]{0,63}$`, stop and ask the user for a valid name. Do not invent one.

## Step 2 — Decide where the skill lives

Ask the user only if it is unclear from context:

```
Where should this skill live?
  1) Project    →  .claude/skills/$ARGUMENTS/        (this repo only, committed)
  2) Personal   →  ~/.claude/skills/$ARGUMENTS/     (all your projects, machine-local)
  3) Plugin     →  inside a Claude Code plugin
  4) Vendored   →  inside an ai-skills-style submodule (advanced)
```

If the conversation already establishes the target (e.g. the user just opened `agent-ops/.claude/skills/`), skip the question and use that path.

## Step 3 — Three short questions

Ask the user, in their language, exactly these three questions. Do not paraphrase or re-explain:

1. **¿Qué hace este skill?** Una frase de qué problema resuelve.
2. **¿Cuándo debería invocarse?** Frases-disparador o casos de uso. Si es manual-only, basta con "manual".
3. **¿Manual-only (solo `/<name>`) o auto-invocable (Claude lo dispara cuando detecta los disparadores)?**

Combine question 1 + question 2 into the `description` field. The `description` is the single most important field — it is what Claude reads to decide whether to invoke the skill automatically. Put the key use case first.

## Step 4 — Pick a template

Two templates ship with this skill:

- **`templates/minimal.md`** — frontmatter (`name`, `description`) + an empty body. Use when the user only wants the smallest valid skill.
- **`templates/full.md`** — every supported frontmatter field commented in-place, plus the standard body sections (Context, Instructions, Validation). Use by default.

Templates contain only two placeholders: `{{NAME}}` and `{{DESCRIPTION}}`. The scaffold script (next step) handles the substitution and, if the user asked for manual-only, inserts `disable-model-invocation: true` right after the `description:` line. You do not have to edit the template by hand.

## Step 5 — Run the scaffold script

The bundled script handles directory creation and template copy. Use it instead of doing each step by hand:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/scaffold.sh \
  --name "<skill-name>" \
  --target-dir "<absolute path of the skills/ root>" \
  --template "minimal|full" \
  --description "<one-sentence description from step 3>" \
  --manual-only "yes|no"
```

The script:

- Refuses to overwrite an existing directory.
- Creates `<target-dir>/<skill-name>/SKILL.md` with the substituted template.
- Prints the absolute path of the created `SKILL.md`.

If the script exits non-zero, stop and report the error verbatim. Do not improvise a fallback that bypasses the safety checks.

## Step 6 — Report

Once the script returns successfully, report to the user:

- Absolute path of the created `SKILL.md`.
- The final `description` line (so they can review it for trigger keywords).
- One-line reminder: skills are picked up live (no restart needed) for personal and project skills already discovered at startup. If you created the top-level `.claude/skills/` directory just now, restart Claude Code so it can start watching it.

Do not generate body content beyond the template placeholders. The author will fill in the actual instructions.

## Hard rules

- **Never overwrite** an existing skill. If the directory already exists, abort and surface that fact to the user.
- **Never invent** the description. It must come from the user's answer to question 1+2.
- **Never enable `allowed-tools`, `context: fork`, `paths`, `model`, `effort`** unless the user explicitly asks for them. The default skill is the safest one.
- **Frontmatter is required.** Even if the user wants "the simplest possible skill", emit at least `name` and `description` — never let the auto-detected fallback (directory name + first paragraph) be the load-bearing surface.

## Anti-patterns to avoid

- Skill body that opens with a Markdown heading (`# Title`) and no frontmatter → unstable description fallback.
- `description` shorter than ~80 chars or vague ("does X") → auto-invocation never fires.
- `description` longer than ~1500 chars → truncated in the skill listing, trigger keywords lost.
- Multiple skills sharing identical `description` keywords → Claude cannot disambiguate.
- Bundling `allowed-tools: Bash(*)` "to be safe" → grants the skill silent shell access. Use the narrowest allowlist that works.

## Reference

Authoritative documentation: <https://code.claude.com/docs/en/skills>

This skill follows the [Agent Skills](https://agentskills.io) open standard.
