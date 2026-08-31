param(
    [string]$BASE = "draft-scalone-cfr-source-privacy-02"
)

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$REPO_ROOT = Split-Path -Parent $SCRIPT_DIR
$OUT = Join-Path $REPO_ROOT "out"

$SOURCE = Join-Path $REPO_ROOT "$BASE.md"
$XML = Join-Path $OUT "$BASE.xml"
$HTML = Join-Path $OUT "$BASE.html"
$TXT = Join-Path $OUT "$BASE.txt"

New-Item -ItemType Directory -Force -Path $OUT | Out-Null

Write-Host "Building $BASE..."
Write-Host "Source: $SOURCE"

if (-not (Test-Path $SOURCE)) {
    throw "Source file not found: $SOURCE"
}

# Markdown -> RFCXML
kramdown-rfc $SOURCE | Out-File -FilePath $XML -Encoding utf8

if ($LASTEXITCODE -ne 0) {
    throw "kramdown-rfc failed"
}

# RFCXML -> HTML
xml2rfc $XML --html -o $HTML

if ($LASTEXITCODE -ne 0) {
    throw "xml2rfc HTML generation failed"
}

# RFCXML -> TXT
xml2rfc $XML --text -o $TXT

if ($LASTEXITCODE -ne 0) {
    throw "xml2rfc text generation failed"
}

Write-Host ""
Write-Host "Build complete."
Write-Host "XML : $XML"
Write-Host "HTML: $HTML"
Write-Host "TXT : $TXT"