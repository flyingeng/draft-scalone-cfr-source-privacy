#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.."; pwd)"
OUT="$ROOT/out"
mkdir -p "$OUT"

BASE="draft-scalone-cfr-source-privacy-00"

# Check tools
command -v kramdown-rfc >/dev/null || { echo "Install: gem install kramdown-rfc2629"; exit 1; }
command -v xml2rfc >/dev/null || { echo "Install: pip install xml2rfc"; exit 1; }

# Convert Markdown -> XML -> HTML/TXT
kramdown-rfc "$ROOT/$BASE.md" > "$OUT/$BASE.xml"
xml2rfc "$OUT/$BASE.xml" --html -o "$OUT/$BASE.html"
xml2rfc "$OUT/$BASE.xml" --text -o "$OUT/$BASE.txt"

echo "✅ Build complete. Output in $OUT"
