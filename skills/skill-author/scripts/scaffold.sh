#!/usr/bin/env bash
# scaffold.sh — Create a new Claude Code skill directory from a template.
#
# Used by the /skill-author skill. See ../SKILL.md for the full flow.
#
# Usage:
#   scaffold.sh \
#     --name <skill-name>              (required, [a-z][a-z0-9-]{0,63})
#     --target-dir <abs-path>          (required, absolute path of the skills/ root)
#     --template <minimal|full>        (default: full)
#     --description <one-liner>        (required, drives the description: field)
#     --manual-only <yes|no>           (default: no)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMPLATES_DIR="${SKILL_DIR}/templates"

NAME=""
TARGET_DIR=""
TEMPLATE="full"
DESCRIPTION=""
MANUAL_ONLY="no"

die() { printf "scaffold.sh: %s\n" "$*" >&2; exit 1; }

while [ $# -gt 0 ]; do
    case "$1" in
        --name)         NAME="${2:-}"; shift 2 ;;
        --target-dir)   TARGET_DIR="${2:-}"; shift 2 ;;
        --template)     TEMPLATE="${2:-}"; shift 2 ;;
        --description)  DESCRIPTION="${2:-}"; shift 2 ;;
        --manual-only)  MANUAL_ONLY="${2:-}"; shift 2 ;;
        -h|--help)
            sed -n '2,15p' "$0" | sed 's|^# \{0,1\}||'
            exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

# --- Validation ---------------------------------------------------------------
[ -n "$NAME" ]         || die "--name is required"
[ -n "$TARGET_DIR" ]   || die "--target-dir is required"
[ -n "$DESCRIPTION" ]  || die "--description is required"

if ! [[ "$NAME" =~ ^[a-z][a-z0-9-]{0,63}$ ]]; then
    die "invalid skill name '$NAME' (must match ^[a-z][a-z0-9-]{0,63}$)"
fi

case "$TEMPLATE" in
    minimal|full) ;;
    *) die "unknown template '$TEMPLATE' (expected: minimal | full)" ;;
esac

case "$MANUAL_ONLY" in
    yes|no) ;;
    *) die "--manual-only must be 'yes' or 'no'" ;;
esac

[ -d "$TARGET_DIR" ] || die "target-dir does not exist: $TARGET_DIR"
case "$TARGET_DIR" in
    /*) ;;
    *) die "--target-dir must be an absolute path: $TARGET_DIR" ;;
esac

TEMPLATE_FILE="${TEMPLATES_DIR}/${TEMPLATE}.md"
[ -f "$TEMPLATE_FILE" ] || die "template not found: $TEMPLATE_FILE"

# --- Create skill directory (refuse to overwrite) -----------------------------
SKILL_PATH="${TARGET_DIR}/${NAME}"
SKILL_FILE="${SKILL_PATH}/SKILL.md"

if [ -e "$SKILL_PATH" ]; then
    die "refusing to overwrite existing path: $SKILL_PATH"
fi

mkdir -p "$SKILL_PATH"

# --- Render template ----------------------------------------------------------
# Substitute {{NAME}} and {{DESCRIPTION}}. We use awk (not sed) so the
# description can contain slashes, ampersands, etc. without escaping.
awk -v name="$NAME" -v desc="$DESCRIPTION" '
{
    gsub(/\{\{NAME\}\}/,        name)
    gsub(/\{\{DESCRIPTION\}\}/, desc)
    print
}
' "$TEMPLATE_FILE" > "$SKILL_FILE"

# If the user asked for manual-only, insert disable-model-invocation right
# after the description: line. Works for both templates without needing
# placeholders in the template files.
if [ "$MANUAL_ONLY" = "yes" ]; then
    awk '
        /^description: / && !inserted {
            print
            print "disable-model-invocation: true"
            inserted=1
            next
        }
        { print }
    ' "$SKILL_FILE" > "${SKILL_FILE}.tmp" && mv "${SKILL_FILE}.tmp" "$SKILL_FILE"
fi

printf "%s\n" "$SKILL_FILE"
