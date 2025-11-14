$BASE = "draft-scalone-cfr-source-privacy-00"
$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Definition
$OUT = Join-Path $ROOT "..\out"
New-Item -ItemType Directory -Force -Path $OUT | Out-Null

kramdown-rfc "..\$BASE.md" > "$OUT\$BASE.xml"
xml2rfc "$OUT\$BASE.xml" --html -o "$OUT\$BASE.html"
xml2rfc "$OUT\$BASE.xml" --text -o "$OUT\$BASE.txt"

Write-Host "Build complete: $OUT"
