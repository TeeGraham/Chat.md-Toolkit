#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  NewTools/scripts/poppler_helpers.sh
# ---------------------------------------------------------------------------
# Convenience wrapper functions around the Poppler command-line utilities
# (`pdftotext`, `pdfinfo`, `pdfimages`, `pdfseparate`, `pdfunite`, …).
#
# Currently exposed helpers
#   • pdf_to_text       – PDF → plain text (layout-preserving)
#   • pdf_pagecount     – page count via pdfinfo
#   • pdf_extract_images – extract embedded images
#   • pdf_split_pages   – split multi-page documents
#   • pdf_merge         – merge multiple PDFs
#   • pdf_to_csv        – export each page as a CSV row (page,text)
#
# These helpers allow you to manipulate PDFs from any Bash script without
# remembering the low-level syntax of each Poppler tool.
#
#   source "$(dirname "$0")/poppler_helpers.sh"
#
# Dependencies: poppler-utils (Debian/Ubuntu) or the Poppler Homebrew formula
# (macOS).  The `require_poppler` helper aborts with a clear message if the
# tools are absent.
# ---------------------------------------------------------------------------

set -euo pipefail

##############################################################################
# Ensure generic helpers are available                                        #
##############################################################################

# If `die()` is not already defined, source toolbox.sh that sits next to this
# file.  We resolve the *real* directory of this script so the helper works no
# matter where the caller is located (relative paths, symlinks, etc.).

if ! declare -f die >/dev/null 2>&1; then
  helper_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
  # shellcheck source=toolbox.sh
  source "$helper_dir/toolbox.sh"
fi

##############################################################################
# Internal helpers                                                             #
##############################################################################

# Abort if Poppler is not installed.
require_poppler() {
  command -v pdftotext >/dev/null 2>&1 || die "Poppler utilities not installed. Install 'poppler-utils' (Debian/Ubuntu) or 'brew install poppler' (macOS)."
}

##############################################################################
# Public API                                                                  #
##############################################################################

# pdf_to_text <pdf> [output_txt]
# Convert a PDF to text (layout-preserving) via `pdftotext`.
pdf_to_text() {
  require_poppler

  local pdf=$1
  local txt=${2:-"${pdf%.pdf}.txt"}

  pdftotext -layout "$pdf" "$txt"
  echo "Text extracted to $txt"
}

# pdf_pagecount <pdf>
# Echo the page count of the supplied PDF.
pdf_pagecount() {
  require_poppler

  local pdf=$1
  pdfinfo "$pdf" | awk '/^Pages:/ {print $2}'
}

# pdf_extract_images <pdf> [output_dir]
# Extract all images from a PDF into the given directory (default: <basename>_images/).
pdf_extract_images() {
  require_poppler

  local pdf=$1
  local outdir=${2:-"${pdf%.pdf}_images"}

  mkdir -p "$outdir"
  pdfimages -all "$pdf" "$outdir/img"
  echo "Images written to $outdir/"
}

# pdf_split_pages <pdf> [prefix]
# Split a multi-page PDF into one-page PDFs named <prefix>-1.pdf, <prefix>-2.pdf…
pdf_split_pages() {
  require_poppler

  local pdf=$1
  local prefix=${2:-"page"}

  pdfseparate "$pdf" "${prefix}-%d.pdf"
  echo "Pages written as ${prefix}-N.pdf"
}

# pdf_merge <output.pdf> <input1.pdf> [input2.pdf …]
# Merge multiple PDFs into a single output file.
pdf_merge() {
  require_poppler

  local outfile=$1
  shift

  (( $# >= 1 )) || die "pdf_merge: provide at least one input PDF"

  pdfunite "$@" "$outfile"
  echo "Created $outfile"
}

# pdf_to_csv <pdf> [output_csv]
# Export each page of a PDF to a CSV file with two columns: page,text.
# The text for each page is flattened to a single line. Double quotes inside the
# text are escaped following RFC 4180 (" → ""). Newlines are converted to
# spaces so that every row fits on one physical line in the CSV.
#
# Example usages
#   pdf_to_csv slides.pdf           # -> slides.csv
#   pdf_to_csv thesis.pdf pages.csv # -> pages.csv
#
# Note: This is a convenience helper implemented in Bash. For very large PDFs
# performance will be bounded by the speed of spawning `pdftotext` once per
# page.
pdf_to_csv() {
  require_poppler

  local pdf=$1
  local csv_out=${2:-"${pdf%.pdf}.csv"}

  [[ -f $pdf ]] || die "pdf_to_csv: $pdf does not exist"

  # Obtain the number of pages using the existing helper.
  local pages
  pages=$(pdf_pagecount "$pdf")

  # Prepare (overwrite) output CSV and write header.
  printf 'page,text\n' > "$csv_out"

  local p text
  for ((p = 1; p <= pages; p++)); do
    # Extract a single page to stdout; suppress stderr for cleaner output.
    text=$(pdftotext -layout -f "$p" -l "$p" "$pdf" - 2>/dev/null)

    # Flatten: replace newlines and consecutive spaces.
    text=${text//$'\n'/ }
    # shellcheck disable=SC2001
    text=$(echo "$text" | sed -E 's/  +/ /g')

    # Escape embedded double quotes (RFC 4180: " -> "").
    # Use backslash-escaped quotes so the shell parser isn't confused.
    text=${text//\"/\"\"}

    printf '%d,"%s"\n' "$p" "$text" >> "$csv_out"
  done

  echo "CSV written to csv_out"
}

# You can append additional wrappers around pdftoppm, pdftocairo, etc. below.
# ---------------------------------------------------------------------------

