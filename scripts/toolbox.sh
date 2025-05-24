#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  NewTools/scripts/toolbox.sh
# ---------------------------------------------------------------------------
# A small library of reusable Bash helper functions.
# Source this file from any other script to gain access to the helpers.
#
#   source "$(dirname "$0")/toolbox.sh"
#
# All functions are written to be POSIX-ish but we rely on a few Bash niceties
# (arrays, local variables).  This file is meant to be copied or extended when
# you need more helpers.
# ---------------------------------------------------------------------------

# Exit immediately on error, on use of an undeclared variable, or on the first
# failure in a pipeline.
set -euo pipefail

# -------------- #
# internal utils #
# -------------- #
# Print an error message and abort.
die() {
  echo "error: $*" >&2
  exit 1
}

# -------------- #
# public helpers #
# -------------- #

# say_hello [name]
# Prints a friendly greeting. Defaults to "World".
say_hello() {
  local who=${1:-World}
  printf 'Hello, %s!\n' "$who"
}

# backup_file <path>
# Creates a timestamped backup of the given file in the same directory.
# Example:  backup_file ./config.yml  # -> config.yml.20240524084530.bak
backup_file() {
  local target=$1

  [[ -f $target ]] || die "$target does not exist"

  local ts
  ts=$(date +%Y%m%d%H%M%S)
  cp -v "$target" "${target}.${ts}.bak"
}

# Additional helpers can be added below this line.
# ---------------------------------------------------------------------------

