
# draft-scalone-cfr-source-privacy

Source-privacy proposal: **Customer-Facing Relay (CFR)**.

This repo tracks the Internet-Draft text in Markdown (kramdown-rfc) and uses CI to publish HTML/TXT.

## Build locally

Requirements:
- Ruby 3.x (`gem install kramdown-rfc2629`)
- Python 3.10+ (`pip install xml2rfc`)

```bash
./scripts/build.sh
# outputs in out/draft-scalone-cfr-source-privacy-00/
```

## CI
- On every push/PR: build artifacts
- On `main`: deploys HTML/TXT to GitHub Pages
