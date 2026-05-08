---
# REQUIRED — what Claude needs to find and trigger this skill
name: {{NAME}}
description: {{DESCRIPTION}}

# OPTIONAL — uncomment and edit the fields you need.
# Full reference: https://code.claude.com/docs/en/skills

# Restrict invocation
# disable-model-invocation: true   # only the user can run /{{NAME}}
# user-invocable: false            # Hide from / menu (Claude can still invoke)

# Pre-approve tools while this skill is active (narrowest allowlist that works)
# allowed-tools: Read Grep
# allowed-tools: Bash(git status *) Bash(git log *)

# Hint shown in the / autocomplete
# argument-hint: [target]

# Named positional arguments (used as $name in the body)
# arguments: target environment

# Force a model / effort while the skill runs (resets next prompt)
# model: sonnet
# effort: high

# Run in a forked subagent context (isolated)
# context: fork
# agent: Explore

# Only auto-load when working with files matching these globs
# paths:
#   - "src/api/**/*.ts"
#   - "tests/**/*.test.ts"
---

# {{NAME}}

## Context

<!-- Optional: dynamic shell injection runs BEFORE Claude sees the skill.
     The output replaces the placeholder. Use sparingly. -->
<!-- Current branch: !`git branch --show-current` -->

## Instructions

<!-- What Claude should do, step by step. State commands and acceptance
     criteria explicitly. Skill body stays in context for the rest of the
     session, so every line is a recurring token cost — be concise. -->

1. ...
2. ...
3. ...

## Validation

<!-- How does the user (or Claude) know the skill succeeded? List the
     verifiable artefacts: files written, commands that should pass,
     expected exit codes. -->

- ...

## Anti-patterns

<!-- Optional: list pitfalls Claude should avoid for this specific skill. -->
