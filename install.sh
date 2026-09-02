#!/bin/bash

set -euo pipefail

REPO="christianhelle/skills"
DEST_ROOT="${HOME}/.agents/skills"
DEST_ROOT_CLAUDE="${HOME}/.claude/skills"
DEST_ROOTS=("$DEST_ROOT" "$DEST_ROOT_CLAUDE")
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
# Uses parallel indexed arrays (no Bash 4+ associative arrays needed)
declare -a ALL_SKILLS=()
declare -a SKILL_DESCS=()
while IFS= read -r dir; do
  name=$(basename "$dir")
  ALL_SKILLS+=("$name")
  # Extract description from SKILL.md frontmatter
  skill_md="${dir}/SKILL.md"
  if [ -f "$skill_md" ]; then
    desc=$(awk '
      { sub(/\r$/, "") }
      # Flush folded scalar on closing fence
      fence == 1 && /^---$/ && capturing {
        gsub(/\n/, " ", folded)
        sub(/\..*/, ".", folded)
        print folded
        exit
      }
      /^---$/ { fence++; next }
      fence == 1 && /^description:/ {
        sub(/^description:[[:space:]]*/, "")
        # Handle folded scalar (starts with >)
        if ($0 ~ /^>/) {
          sub(/^>[[:space:]]*/, "")
          folded = $0
          capturing = 1
          next
        }
        # Single-line description: grab first sentence
        sub(/\..*/, ".")
        print
        exit
      }
      fence == 1 && capturing && /^[[:space:]]/ {
        sub(/^[[:space:]]+/, "")
        if (folded == "") folded = $0; else folded = folded " " $0
        next
      }
      fence == 1 && capturing {
        # End of folded scalar — non-indented line
        gsub(/\n/, " ", folded)
        sub(/\..*/, ".", folded)
        print folded
        exit
      }
    ' "$skill_md")
    SKILL_DESCS+=("$desc")
  else
    SKILL_DESCS+=("")
  fi
done < <(find "$EXTRACTED" -maxdepth 1 -type d | tail -n +2 | while read -r d; do
  if [ -f "$d/SKILL.md" ]; then
    echo "$d"
  fi
done)

if [ "${#ALL_SKILLS[@]}" -eq 0 ]; then
  echo "No skills found in archive." >&2
  exit 0
fi

# ---- interactive selection ----
# Show interactive prompt when:
#   - No --skill flags were given
#   - Not in --whatif mode
#   - Running in an interactive terminal
if [ "${#SKILLS[@]}" -eq 0 ] && [ "$WHATIF" = false ] && [ -t 0 ]; then
  echo "" >&2
  echo "  Available skills:" >&2
  echo "" >&2

  # Print numbered list
  for i in "${!ALL_SKILLS[@]}"; do
    local_idx=$((i + 1))
    local_name="${ALL_SKILLS[$i]}"
    local_desc="${SKILL_DESCS[$i]:-}"
    if [ -n "$local_desc" ]; then
      printf "    %2d) %-24s %s\n" "$local_idx" "$local_name" "$local_desc" >&2
    else
      printf "    %2d) %s\n" "$local_idx" "$local_name" >&2
    fi
  done

  echo "" >&2
  echo "  Press Enter to install all, type skill numbers (e.g. 1,2)," >&2
  echo "  'all' to install everything, or 'none' to skip:" >&2
  printf "  > " >&2

  read -r USER_INPUT </dev/tty

  if [ -n "$USER_INPUT" ]; then
    # Normalize input
    INPUT_LOWER=$(echo "$USER_INPUT" | tr '[:upper:]' '[:lower:]' | xargs)

    if [ "$INPUT_LOWER" = "none" ] || [ "$INPUT_LOWER" = "n" ]; then
      echo "  No skills selected. Skipping installation." >&2
      exit 0
    fi

    if [ "$INPUT_LOWER" = "all" ] || [ "$INPUT_LOWER" = "a" ] || [ "$INPUT_LOWER" = "" ]; then
      : # Keep all skills — no filter
    else
      # Parse comma-separated numbers
      SELECTED=()
      SELECTED_DESCS=()
      IFS=',' read -ra PARTS <<< "$USER_INPUT"
      for part in "${PARTS[@]}"; do
        part=$(echo "$part" | xargs) # trim whitespace
        if [[ "$part" =~ ^[0-9]+$ ]]; then
          idx=$((part - 1))
          if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#ALL_SKILLS[@]}" ]; then
            SELECTED+=("${ALL_SKILLS[$idx]}")
            SELECTED_DESCS+=("${SKILL_DESCS[$idx]:-}")
          else
            echo "  Warning: '$part' is not a valid skill number, skipping." >&2
          fi
        else
          echo "  Warning: '$part' is not a valid number, skipping." >&2
        fi
      done

      if [ "${#SELECTED[@]}" -eq 0 ]; then
        echo "  No valid skills selected. Skipping installation." >&2
        exit 0
      fi

      ALL_SKILLS=("${SELECTED[@]}")
      SKILL_DESCS=("${SELECTED_DESCS[@]}")
      echo "" >&2
      echo "  Installing ${#ALL_SKILLS[@]} selected skill(s)..." >&2
    fi
  fi
  echo "" >&2
fi

# ---- filter ----
if [ "${#SKILLS[@]}" -gt 0 ]; then
  UNKNOWN=()
  FILTERED=()
  FILTERED_DESCS=()
  for i in "${!ALL_SKILLS[@]}"; do
    s="${ALL_SKILLS[$i]}"
    found=false
    for valid in "${SKILLS[@]}"; do
      if [ "$s" = "$valid" ]; then found=true; break; fi
    done
    if $found; then
      FILTERED+=("$s")
      FILTERED_DESCS+=("${SKILL_DESCS[$i]:-}")
    else
      UNKNOWN+=("$s")
    fi
  done
  if [ "${#UNKNOWN[@]}" -gt 0 ]; then
    echo "Unknown skill name(s): ${UNKNOWN[*]}" >&2
  fi
  ALL_SKILLS=("${FILTERED[@]}")
  SKILL_DESCS=("${FILTERED_DESCS[@]}")
  if [ "${#ALL_SKILLS[@]}" -eq 0 ]; then
    echo "No matching skills to install." >&2
    exit 0
  fi
fi

# ---- install ----
for dest in "${DEST_ROOTS[@]}"; do
  mkdir -p "$dest"
done

INSTALLED=0
SKIPPED=0
ERRORS=0
OVERWRITE=false
if $FORCE; then
  OVERWRITE=true
fi

# ---- single overwrite prompt for existing skills ----
if ! $WHATIF && ! $FORCE; then
  EXISTING=()
  for name in "${ALL_SKILLS[@]}"; do
    for dest in "${DEST_ROOTS[@]}"; do
      if [ -d "${dest}/${name}" ]; then
        # Avoid duplicates
        already=false
        for e in "${EXISTING[@]}"; do
          if [ "$e" = "$name" ]; then already=true; break; fi
        done
        if ! $already; then
          EXISTING+=("$name")
        fi
        break
      fi
    done
  done

  if [ "${#EXISTING[@]}" -gt 0 ]; then
    OVERWRITE_ANSWER=""
    if [ -r /dev/tty ]; then
      if [ "${#EXISTING[@]}" -eq 1 ]; then
        printf "  '%s' already exists. Overwrite? [y/N] " "${EXISTING[0]}" >&2
      else
        printf "  %d skill(s) already exist: %s\n" "${#EXISTING[@]}" "${EXISTING[*]}" >&2
        printf "  Overwrite all? [y/N] " >&2
      fi
      read -r OVERWRITE_ANSWER </dev/tty
    fi
    if [ "$OVERWRITE_ANSWER" = "y" ] || [ "$OVERWRITE_ANSWER" = "Y" ]; then
      OVERWRITE=true
    else
      echo "  Skipping existing skills where they already exist." >&2
      OVERWRITE=false
    fi
  fi
fi

for name in "${ALL_SKILLS[@]}"; do
  src="${EXTRACTED}/${name}"

  if $WHATIF; then
    for dest in "${DEST_ROOTS[@]}"; do
      dst="${dest}/${name}"
      if [ -d "$dst" ]; then
        echo "  would overwrite: ${name} -> ${dest}/" >&2
      else
        echo "  would install:   ${name} -> ${dest}/" >&2
      fi
    done
    INSTALLED=$((INSTALLED + 1))
    continue
  fi

  skill_installed=false
  skill_skipped=false
  skill_error=false
  for dest in "${DEST_ROOTS[@]}"; do
    dst="${dest}/${name}"

    if [ -d "$dst" ] && ! $OVERWRITE; then
      skill_skipped=true
      continue
    fi

    if [ -d "$dst" ]; then rm -rf "$dst"; fi
    if cp -r "$src" "$dst" 2>/dev/null; then
      echo "  Installed: ${name} -> ${dest}/" >&2
      skill_installed=true
    else
      echo "  Error writing ${name} -> ${dest}/" >&2
      skill_error=true
      ERRORS=$((ERRORS + 1))
    fi
  done

  if $skill_error; then
    :
  elif $skill_installed; then
    INSTALLED=$((INSTALLED + 1))
  elif $skill_skipped; then
    SKIPPED=$((SKIPPED + 1))
  fi
done

# ---- summary ----
echo "" >&2
echo "Summary:" >&2
echo "  Installed: ${INSTALLED}" >&2
echo "  Skipped:   ${SKIPPED}" >&2
echo "  Errors:    ${ERRORS}" >&2
