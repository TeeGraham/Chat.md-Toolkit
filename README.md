# NewTools – Bash Helper Template for ocaml-gpt

> **Base platform**: NewTools is the companion utility toolkit for the
> [ocaml-gpt](https://github.com/dakotamurphyucf/ocaml-gpt.git) project.  While
> the helpers can be reused in any Bash environment, they are shipped and kept
> up-to-date in the ocaml-gpt repository.  If you cloned this directory on its
> own and wish to explore the full platform, fetch it with:
>
> ```bash
> git clone https://github.com/dakotamurphyucf/ocaml-gpt.git
> ```

> **Development**: The NewTools Toolkit is actively developed and maintained
> by **Ty Graham**.  Issues, suggestions, and pull-requests are welcome!


This directory provides a **minimal, copy-paste-ready template** for creating
re-usable Bash helpers.  The structure is small on purpose – just enough to
encourage good habits (library vs. executable, `set -euo pipefail`, etc.).

```
NewTools/
├── scripts/
│   ├── toolbox.sh          # Generic helpers (die, say_hello, …)
│   ├── poppler_helpers.sh  # PDF-oriented helpers (pdftotext, pdfinfo, …)
│   └── pandoc_helpers.sh   # Word → formats (docx→pdf/md via Pandoc)
├── bin/
│   ├── run-tool            # Example wrapper for `say_hello`
│   ├── pdf-to-text         # Wrapper → pdf_to_text()
│   ├── pdf-pagecount       # Wrapper → pdf_pagecount()
│   ├── pdf-extract-images  # Wrapper → pdf_extract_images()
│   ├── pdf-split           # Wrapper → pdf_split_pages()
│   ├── pdf-merge           # Wrapper → pdf_merge()
│   ├── pdf-to-csv          # Wrapper → pdf_to_csv()
│   ├── docx-to-pdf         # Wrapper → docx_to_pdf()
│   └── docx-to-md          # Wrapper → docx_to_markdown()
└── README.md         # What you are reading now
```

## 1  Giving Exec Permissions (`chmod`)

Unix treats “is this file executable?” as a permission flag.  After copying or
creating new scripts, make them runnable:

```bash
# From project root …

# *Scripts*: give execution permission to every new helper you add.
chmod +x NewTools/scripts/toolbox.sh
chmod +x NewTools/scripts/poppler_helpers.sh
# Pandoc helpers
chmod +x NewTools/scripts/pandoc_helpers.sh

# *Wrappers*: all files in `NewTools/bin/` should be executable.
chmod +x NewTools/bin/*
```

Tip: If you check these files into Git after making them executable, the `+x`
bit is stored in the repository – teammates will not have to run `chmod`.

## 2  Using the Function Library (toolbox.sh)

Inside *another* Bash script:

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/../NewTools/scripts/toolbox.sh"

# Now you can call any helper defined in toolbox.sh
say_hello "Alice"
backup_file ./config.yml
```

### Quick smoke-test from a terminal

```bash
# Type directly in your shell:
source NewTools/scripts/toolbox.sh
say_hello            # → Hello, World!
say_hello "Bob"       # → Hello, Bob!
```

## 3  Running the CLI Wrappers

`bin/` now contains several ready-made commands.  All of them delegate to
functions in `scripts/` so you get a clean CLI without code duplication.

```bash
# Greeting demo (unchanged)
./NewTools/bin/run-tool Bob

# --- Poppler helpers ---------------------------------------------------
# Convert PDF → TXT (layout-preserving)
./NewTools/bin/pdf-to-text  slides.pdf   # → slides.txt

# How many pages in a PDF?
./NewTools/bin/pdf-pagecount slides.pdf  # → 42

# Extract every embedded image into ./slides_images/
./NewTools/bin/pdf-extract-images slides.pdf

# Split into page-1.pdf, page-2.pdf …
./NewTools/bin/pdf-split slides.pdf

# Merge multiple PDFs into a book.pdf
./NewTools/bin/pdf-merge book.pdf chapter1.pdf chapter2.pdf chapter3.pdf

# Export each page to a CSV row (page,text)
./NewTools/bin/pdf-to-csv slides.pdf       # → slides.csv

# Put NewTools/bin on your PATH once and call them from anywhere
export PATH="$PATH:$(pwd)/NewTools/bin"
pdf-to-text resume.pdf

# --- Pandoc helpers ------------------------------------------------------
# Convert DOCX → PDF
./NewTools/bin/docx-to-pdf report.docx      # → report.pdf

# Convert DOCX → Markdown (CommonMark)
./NewTools/bin/docx-to-md  report.docx      # → report.md

# As with the PDF helpers you can put NewTools/bin on your PATH and call the
# commands from anywhere:
export PATH="$PATH:$(pwd)/NewTools/bin"
docx-to-pdf spec.docx
```

Feel free to clone any of the wrapper scripts when adding new helpers—each is
just 4–5 lines that source the relevant library and forward arguments.

## 4  Extending the Helpers

• Generic helpers: edit `NewTools/scripts/toolbox.sh`.

• PDF/Poppler helpers: edit `NewTools/scripts/poppler_helpers.sh`—it already
  contains `require_poppler` so you can safely add more wrappers around tools
  like `pdftoppm`, `pdftocairo`, `pdfsig`, etc.

• Word/Pandoc helpers: edit `NewTools/scripts/pandoc_helpers.sh`—it contains
  `require_pandoc` which checks that a `pandoc` executable is present. Extend
  the file with additional conversions such as `md_to_docx`, `html_to_docx`,
  etc.

Keep `set -euo pipefail` at the top of each script and use the shared `die()`
helper for fatal errors.  Every new wrapper in `bin/` should be granted
execute permission (`chmod +x`).

Happy scripting! 🎉

-------------------------------------------------------------------------------
# 5  Dependencies
-------------------------------------------------------------------------------

The helpers rely on a few external programs.  For a complete list plus install
commands see `NewTools/DEPENDENCIES.md`.  Briefly:

• Bash ≥ 3.2 (default on Linux/macOS)  
• Standard coreutils (cp, date, awk, …)  
• Poppler CLI tools (`pdftotext`, `pdfinfo`, …) — install with
  `apt-get install poppler-utils` or `brew install poppler`.

• Pandoc (for Word ↔ other formats) — install with `apt-get install pandoc` or
  `brew install pandoc`.

The `require_poppler` and `require_pandoc` helpers abort scripts early if the
corresponding tools are absent.

