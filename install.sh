#!/bin/bash

set -euo pipefail

REPO="christianhelle/skills"
DEST_ROOT="${HOME}/.agents/skills"
SKILLS=()
TAG="main"
FORCE=false
WHATIF=false

# ---- arg parsing ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--skill)  SKILLS+=("$2");   shift 2 ;;
    -t|--tag)    TAG="$2";         shift 2 ;;
    -f|--force)  FORCE=true;       shift   ;;
    -w|--whatif) WHATIF=true;      shift   ;;
    -h|--help)
      echo "Usage: $(basename "$0") [options]"
      echo "  -s, --skill <name>  Install only named skill (repeatable)"
      echo "  -t, --tag <ref>     Git tag or branch (default: main)"
      echo "  -f, --force         Overwrite without prompting"
      echo "  -w, --whatif        Dry run — show what would be installed"
      echo "  -h, --help          Show this help"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ---- resolve archive URL (tag first, fall back to branch) ----
TAG_URL="https://github.com/${REPO}/archive/refs/tags/${TAG}.zip"
BRANCH_URL="https://github.com/${REPO}/archive/refs/heads/${TAG}.zip"

echo "Resolving '${TAG}' ..." >&2
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L "${TAG_URL}")
if [ "$HTTP_CODE" = "200" ]; then
  ARCHIVE_URL="${TAG_URL}"
  echo "Found tag: ${TAG}" >&2
else
  ARCHIVE_URL="${BRANCH_URL}"
  echo "Using branch: ${TAG}" >&2
fi

# ---- check deps ----
for cmd in curl unzip; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: '$cmd' is required but not found." >&2
    exit 1
  fi
done

# ---- temp workspace ----
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

ZIP_PATH="${TEMP_DIR}/archive.zip"

echo "Downloading archive ..." >&2
curl -sL -o "$ZIP_PATH" "$ARCHIVE_URL"

echo "Extracting ..." >&2
unzip -q "$ZIP_PATH" -d "$TEMP_DIR"

# The extracted root is named skills-<tag> or skills-<commit>
EXTRACTED=$(find "$TEMP_DIR" -maxdepth 1 -type d -name 'skills-*' | head -1)
if [ -z "$EXTRACTED" ]; then
  echo "Error: extracted archive does not contain a 'skills-*' root folder." >&2
  exit 1
fi

# ---- discover skills (dirs with SKILL.md) ----
declare -a ALL_SKILLS=()
while IFS= read -r dir; do
  name=$(basename "$dir")
  ALL_SKILLS+=("$name")
done < <(find "$EXTRACTED" -maxdepth 1 -type d | tail -n +2 | while read -r d; do
  if [ -f "$d/SKILL.md" ]; then
    basename "$d"
  fi
done)

if [ "${#ALL_SKILLS[@]}" -eq 0 ]; then
  echo "No skills found in archive." >&2
  exit 0
fi

# ---- filter ----
if [ "${#SKILLS[@]}" -gt 0 ]; then
  UNKNOWN=()
  FILTERED=()
  for s in "${SKILLS[@]}"; do
    found=false
    for valid in "${ALL_SKILLS[@]}"; do
      if [ "$s" = "$valid" ]; then found=true; break; fi
    done
    if $found; then
      FILTERED+=("$s")
    else
      UNKNOWN+=("$s")
    fi
  done
  if [ "${#UNKNOWN[@]}" -gt 0 ]; then
    echo "Unknown skill name(s): ${UNKNOWN[*]}" >&2
  fi
  ALL_SKILLS=("${FILTERED[@]}")
  if [ "${#ALL_SKILLS[@]}" -eq 0 ]; then
    echo "No matching skills to install." >&2
    exit 0
  fi
fi

# ---- install ----
mkdir -p "$DEST_ROOT"

INSTALLED=0
SKIPPED=0
ERRORS=0

for name in "${ALL_SKILLS[@]}"; do
  src="${EXTRACTED}/${name}"
  dst="${DEST_ROOT}/${name}"

  if $WHATIF; then
    if [ -d "$dst" ]; then
      echo "  would overwrite: ${name}" >&2
    else
      echo "  would install:   ${name}" >&2
    fi
    INSTALLED=$((INSTALLED + 1))
    continue
  fi

  if [ -d "$dst" ] && ! $FORCE; then
    read -r -p "  '${name}' already exists. Overwrite? [y/N] " answer
    if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
      echo "  Skipped ${name}" >&2
      SKIPPED=$((SKIPPED + 1))
      continue
    fi
  fi

  if cp -r "$src" "$dst" 2>/dev/null; then
    echo "  Installed: ${name}" >&2
    INSTALLED=$((INSTALLED + 1))
  else
    echo "  Error writing ${name}" >&2
    ERRORS=$((ERRORS + 1))
  fi
done

# ---- summary ----
echo "" >&2
echo "Summary:" >&2
echo "  Installed: ${INSTALLED}" >&2
echo "  Skipped:   ${SKIPPED}" >&2
echo "  Errors:    ${ERRORS}" >&2
