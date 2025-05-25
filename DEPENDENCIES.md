# NewTools – Dependency Reference

This document lists the external software required to run the shell helpers
provided in **NewTools/**.  Everything else ships as plain Bash code.

-------------------------------------------------------------------------------
Runtime Dependencies
-------------------------------------------------------------------------------

1. **Bash 3.2 or newer**  
   All scripts use standard Bash features (`local`, `set -euo pipefail`,
   `$( … )` command substitution).  Bash is pre-installed on macOS and most
   Linux distributions.

2. **GNU coreutils** (cp, mv, printf, date, etc.)  
   Present by default on Linux; macOS ships BSD variants which are entirely
   compatible with the commands used here.

3. **Poppler command-line utilities**  
   Only required for the PDF-related helpers located in
   `scripts/poppler_helpers.sh` and wrappers under `bin/` whose names begin
   with `pdf-` (for example *pdf-to-text*, *pdf-to-csv*, *pdf-pagecount*,
   …).  The helpers call the following Poppler programs:

   • `pdftotext`  – convert PDF → text  
   • `pdfinfo`    – page count and metadata  
   • `pdfimages`  – extract embedded images  
   • `pdfseparate` – split multi-page PDFs  
   • `pdfunite`   – merge PDFs

   (The *pdf_to_csv* helper also relies on `pdftotext` to extract the text
   of each page before serialising it into CSV.)

   Installation:

   Debian / Ubuntu      : `sudo apt-get install poppler-utils`

   Fedora               : `sudo dnf install poppler-utils`

   Arch / Manjaro       : `sudo pacman -S poppler`

   macOS (Homebrew)     : `brew install poppler`

   After installation the `require_poppler` function included in
   `poppler_helpers.sh` will detect and validate the presence of these tools.

4. **Pandoc**  
   Required for the Word-conversion helpers located in
   `scripts/pandoc_helpers.sh` and wrappers under `bin/` beginning with
   `docx-`.  The current helpers call the program as

   • `pandoc … -o <file>.pdf`       – convert DOCX → PDF  
   • `pandoc … -t commonmark -o …` – convert DOCX → Markdown (CommonMark)

   Installation:

   Debian / Ubuntu      : `sudo apt-get install pandoc`

   Fedora               : `sudo dnf install pandoc`

   Arch / Manjaro       : `sudo pacman -S pandoc`

   macOS (Homebrew)     : `brew install pandoc`

   After installation the `require_pandoc` function included in
   `pandoc_helpers.sh` will detect and validate the presence of the tool.

-------------------------------------------------------------------------------
Optional / Development Dependencies
-------------------------------------------------------------------------------

• **ShellCheck** – static analysis for shell scripts (`brew install
  shellcheck` or `apt-get install shellcheck`). This is *not* required at
  runtime; it simply helps contributors keep code quality high.

-------------------------------------------------------------------------------
Verifying Installation
-------------------------------------------------------------------------------

Run the built-in check from any shell:

```bash
# Should print a page count instead of an error
source NewTools/scripts/poppler_helpers.sh
pdf_pagecount sample.pdf
```

If Poppler is missing, you will receive the message

```
error: Poppler utilities not installed. Install 'poppler-utils' (Debian/Ubuntu) ...
```

Install the package indicated above and retry.

-------------------------------------------------------------------------------
That’s all – once Bash, Poppler *and* Pandoc are present, every helper in
NewTools is fully functional.

