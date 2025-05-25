#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  NewTools/scripts/pandoc_helpers.sh
# ---------------------------------------------------------------------------
# Convenience wrapper functions around   Pandoc – the universal document
# converter (https://pandoc.org).  The helpers included here focus on *Word
# → X* conversions that are common in documentation pipelines:
#
#   • docx_to_pdf      – Word (DOCX) → PDF
#   • docx_to_markdown – Word (DOCX) → Markdown (CommonMark)
#
# The functions follow the same style as the Poppler helpers that live in
# poppler_helpers.sh so that callers get a consistent experience:
#
#   1.   source "$(dirname "$0")/pandoc_helpers.sh"
#   2.   docx_to_pdf report.docx          # → report.pdf
#        docx_to_markdown report.docx     # → report.md
#
# Dependencies:  A reasonably recent *pandoc* executable must be available in
#                $PATH.  The require_pandoc helper aborts with a clear error
#                message otherwise.
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
# Internal helpers                                                            #
##############################################################################

# Abort if Pandoc is not installed.
require_pandoc() {
  command -v pandoc >/dev/null 2>&1 || die "Pandoc CLI not found. Install 'pandoc' (https://pandoc.org/install.html)."
}

##############################################################################
# Public API                                                                  #
##############################################################################

# docx_to_pdf <input.docx> [output.pdf]
# Convert a Microsoft Word DOCX file to PDF using Pandoc’s built-in PDF
# writer.  When the optional second argument is omitted the output file gets
# the same base name as the input with a .pdf extension.
docx_to_pdf() {
  require_pandoc

  local docx=$1
  local pdf_out=${2:-"${docx%.docx}.pdf"}

  [[ -f $docx ]] || die "docx_to_pdf: $docx does not exist"

  pandoc "$docx" -o "$pdf_out"
  echo "PDF written to $pdf_out"
}

# docx_to_markdown <input.docx> [output.md]
# Convert a Microsoft Word DOCX file to *CommonMark* Markdown.  The extension
# is .md by default when the second argument is omitted.
docx_to_markdown() {
  require_pandoc

  local docx=$1
  local md_out=${2:-"${docx%.docx}.md"}

  [[ -f $docx ]] || die "docx_to_markdown: $docx does not exist"

  pandoc "$docx" -t commonmark -o "$md_out"
  echo "Markdown written to $md_out"
}

# You can append additional Pandoc-based helpers below (e.g. md_to_docx,
# html_to_docx, etc.) while re-using require_pandoc for dependency checks.
# ---------------------------------------------------------------------------

