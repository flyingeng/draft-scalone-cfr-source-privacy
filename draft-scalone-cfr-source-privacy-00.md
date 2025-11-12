
%%
title = "Customer-Facing Relay (CFR) for Source Privacy"
abbrev = "CFR Source Privacy"
category = "info"
docName = "draft-scalone-cfr-source-privacy-00"
ipr = "trust200902"
area = "ART"
workgroup = "TBD"
keyword = ["privacy", "dns", "ech", "cdn", "relay"]
date = 2025-11-12
%%

.# Abstract

This document describes a Customer-Facing Relay (CFR) architecture that reduces
source-IP linkability when accessing content via large content delivery networks (CDNs),
without introducing additional user-visible hops or proxies on the data path.

# Introduction

Explain the privacy gap with ECH (origin name confidentiality) vs. source address exposure.
Motivations, threat model, non-goals.

# Terminology

{::boilerplate bcp14}

# Architecture

High-level flow: Client → CFR (ISP) → CFS (CDN ingress) → Origin Service.

# Privacy Considerations

# Operational Considerations

# IANA Considerations

This document has no IANA actions.

# Security Considerations

# References

## Normative References

## Informative References
