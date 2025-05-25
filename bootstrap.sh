#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  NewTools/bootstrap.sh
# ---------------------------------------------------------------------------
# One-shot bootstrap script that prepares this copy of *NewTools* on the
# current machine.
#
# What the script does:
#   1. Makes every helper in scripts/ and every wrapper in bin/ executable
#      (chmod +x).
#   2. Optionally appends `export PATH="…/NewTools/bin"` to the user’s shell
#      profile (~/.bashrc, ~/.zshrc, or ~/.profile) so the commands are
#      available from anywhere.
#   3. Checks whether Poppler utilities are available and prints a hint if
#      they are missing (re-using the logic that lives in scripts/
#      poppler_helpers.sh).
#
# The idea is that a *single* invocation — `./NewTools/bootstrap.sh` — is all
# that a contributor needs to run after cloning the repository.  From that
# point on every helper (pdf-to-text, pdf-merge, …) is ready for use.
# ---------------------------------------------------------------------------

set -euo pipefail

# Resolve the absolute path of the directory that contains *this* script.  We
# cannot rely on $PWD because the user may call the script from anywhere.
this_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

scripts_dir="$this_dir/scripts"
bin_dir="$this_dir/bin"

echo "[NewTools] Making helper libraries executable …"
chmod +x "$scripts_dir"/*.sh

echo "[NewTools] Making CLI wrappers executable …"
chmod +x "$bin_dir"/*

# ---------------------------------------------------------------------------
#  PATH handling
# ---------------------------------------------------------------------------

# Add bin/ to PATH for the *current* shell so subsequent commands in the same
# session work immediately.
if [[ ":$PATH:" != *":$bin_dir:"* ]]; then
  export PATH="$PATH:$bin_dir"
  echo "[NewTools] Temporarily added $bin_dir to PATH for this session."
fi

# Ask the user (only if the script is run interactively) whether to make the
# change permanent by appending to their shell profile.
if [[ -t 0 && -t 1 ]]; then
  if [[ ":$PATH:" != *":$bin_dir:"* ]]; then
    read -r -p "Add NewTools/bin to your PATH permanently (recommended)? [y/N] " reply
  else
    read -r -p "NewTools/bin is already on PATH for this session. Make it permanent? [y/N] " reply
  fi

  if [[ $reply =~ ^[Yy]$ ]]; then
    # Choose a suitable profile file depending on the user’s shell.
    target_profile=""
    shell_name=$(basename "${SHELL:-/bin/bash}")
    case $shell_name in
      bash) target_profile="$HOME/.bashrc" ;;
      zsh)  target_profile="$HOME/.zshrc"  ;;
      *)    target_profile="$HOME/.profile" ;;
    esac

    printf '\n# Added by NewTools bootstrap on %(%Y-%m-%d %H:%M:%S)T\n' -1 >> "$target_profile"
    printf 'export PATH="\$PATH:%s"\n' "$bin_dir" >> "$target_profile"
    echo "[NewTools] Appended export line to $target_profile — restart your shell to pick it up."
  fi
fi

# ---------------------------------------------------------------------------
#  Dependency check – Poppler utilities
# ---------------------------------------------------------------------------

# Source the helper and let it abort if Poppler is missing.
# shellcheck source=scripts/poppler_helpers.sh
source "$scripts_dir/poppler_helpers.sh"

# The call below will only succeed if the poppler CLI tools are present.
if command -v pdftotext >/dev/null 2>&1; then
  echo "[NewTools] Poppler utilities detected ✓"
else
  echo "[NewTools] Poppler utilities *not* found — PDF helpers will not work." >&2
  echo "            ➜ See NewTools/DEPENDENCIES.md for installation instructions." >&2
fi

# ---------------------------------------------------------------------------
#  Dependency check – Pandoc
# ---------------------------------------------------------------------------

if command -v pandoc >/dev/null 2>&1; then
  echo "[NewTools] Pandoc detected ✓"
else
  echo "[NewTools] Pandoc *not* found — DOCX conversion helpers will not work." >&2
  echo "            ➜ See NewTools/DEPENDENCIES.md for installation instructions." >&2
fi

echo "[NewTools] Bootstrap completed successfully. Enjoy!"

# ---------------------------------------------------------------------------
# End of file
# ---------------------------------------------------------------------------

