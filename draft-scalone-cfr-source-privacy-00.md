---
title: "Customer-Facing Relay (CFR): Enhancing Source Privacy in Encrypted Transport and CDN Scenarios"
abbrev: "CFR Source Privacy"
docname: draft-scalone-cfr-source-privacy-00
category: info
submissiontype: IETF
ipr: trust200902
area: SEC
workgroup: DISPATCH

keyword:
  - privacy
  - ECH
  - relay
  - CDN
  - TLS

date: 2025-10-20

author:
  - fullname: Gianpaolo Angelo Scalone
    initials: G.
    surname: Scalone
    organization: Vodafone
    email: gianpaolo-angelo.scalone@vodafone.com

...

--- abstract

Encrypted Client Hello (ECH) improves destination privacy by encrypting
the Server Name Indication in TLS, but the customer's source identity —
typically the IP address and network metadata — remains observable to
intermediaries such as CDNs, hosting providers, and recursive resolvers.
This document introduces the *Customer-Facing Relay (CFR)*, a
lightweight, transport-agnostic relay operated by access providers
to decouple customer identity from encrypted destinations.
By forwarding opaque encrypted payloads (TCP or UDP)
without terminating TLS or QUIC, a CFR complements ECH
encryption to strengthen source privacy and reduce metadata correlation.

--- middle

# Introduction

While encryption technologies such as TLS 1.3 and Encrypted Client Hello
(ECH) significantly enhance destination privacy, the source of connections
remains exposed. Content delivery infrastructures can still observe
customer IP addresses and associated metadata, enabling correlation
of user behavior even when the content and destination name are protected.

This document proposes the *Customer-Facing Relay (CFR)* architecture,
which introduces a minimal intermediary between the customer and the
encrypted destination to partition visibility of metadata. The intent
is to complement existing privacy mechanisms by focusing on the source
side of communication.

# Terminology

{::boilerplate bcp14}

**CFR**: *Customer-Facing Relay*, a privacy-enhancing network function
located close to the end customer, for example within an ISP or
enterprise access network.

**CFS**: *Client-Facing Server* as defined in ECH. The CFS terminates
encrypted handshakes on behalf of multiple origins. In contrast, the
*CFR does not terminate TLS or QUIC sessions.* It forwards encrypted
packets while rewriting addressing information, similar to a NAT or
tunnel endpoint, with the explicit goal of protecting customer source
privacy.

# Motivation

Destination privacy has improved through encryption, but this progress
has increased traffic centralization. A small number of CDNs now
terminate most encrypted sessions, consolidating visibility over
user traffic. This creates an architectural imbalance:
encryption hides *what* is accessed but not *who* is accessing it.

Observed effects:

* CDNs acting as Client-Facing Servers can correlate customer IPs across
  thousands of hosted domains.
* Aggregation of ECH traffic concentrates metadata in few entities.

CFRs aim to rebalance this asymmetry by separating customer identity
from destination visibility.

# Customer-Facing Relay (CFR) Concept

A Customer-Facing Relay (CFR) is a lightweight, privacy-oriented
intermediary positioned at the customer's network edge. It
relays encrypted transport flows toward upstream services without
decrypting or terminating them, rewriting source addressing to prevent
direct correlation between the customer's IP identity and the encrypted
destination.

Customer ---> CFR ---> CFS ---> Origin Server


Characteristics:

* **Transport-agnostic** — Works for both TCP and UDP, forwarding opaque
  encrypted packets.
* **No TLS/QUIC termination** — The end-to-end encryption context is
  preserved.
* **Deployable** — Can be operated by access providers and enterprises.
* **Transparent** — Performs no content filtering, categorization, or
  inspection.
* **Discoverable** — May be discovered via DNS-based mechanisms such as
  DDR or DNR.

| Entity   | Knows Source | Knows Destination | Content Visibility |
|----------|--------------|-------------------|--------------------|
| Customer | X            | X                 | X                  |
| CFR      | X            |                   |                    |
| CDN/CFS  |              | X                 |                    |

By splitting knowledge between the CFR and the CDN/CFS, no
single entity can fully correlate source and destination metadata.

Trust assumptions:

* The customer trusts the CFR not to expose source IP mappings.
* The CFR cannot read or modify encrypted traffic.
* The upstream service cannot identify the original customer.

# Relationship to Existing Work

* **ECH (RFC9460)** — Protects destination identity; CFR complements it
  by protecting source identity.
* **MASQUE (CONNECT-UDP / CONNECT-IP)** — Tunnel mechanisms; CFR can
  reuse encapsulation but for privacy rather than proxying.
* **DPRIVE (DoH/DoT/DoQ)** — Encrypts DNS traffic; CFR addresses the
  transport-layer metadata.
* **PEARG / HRPC** — Explore broader issues of privacy and
  decentralization.

# Open Questions

* How should CFR discovery and trust bootstrapping be achieved?
* What performance impacts arise from additional relay hops?
* Should CFRs support chaining or federation?
* How can abuse prevention coexist with privacy guarantees?
* Which IETF area or WG should progress standardization?

# Security Considerations

CFRs enhance privacy by partitioning knowledge between multiple parties,
but they also introduce new trust points and potential attack surfaces.

* **Collusion or compromise** — A malicious or compromised CFR could
  share mapping data, restoring correlation.
* **Inspection risk** — CFRs must not evolve into content inspection
  devices.
* **Denial-of-Service** — CFRs could be abused as relays; must enforce
  rate limits or token-based access.
* **Accountability vs. anonymity** — Requires balance between privacy
  and operational safety.

# IANA Considerations

This document makes no IANA requests.

# References

## Informative References

* [RFC9460]
* [RFC9325]
* [I-D.ietf-masque-connect-udp]
* [I-D.ietf-add-ddr]
* [I-D.ietf-add-dnr]

{backmatter}

[RFC9460]: https://www.rfc-editor.org/rfc/rfc9460.html
[RFC9325]: https://www.rfc-editor.org/rfc/rfc9325.html
[I-D.ietf-masque-connect-udp]: https://datatracker.ietf.org/doc/html/draft-ietf-masque-connect-udp
[I-D.ietf-add-ddr]: https://datatracker.ietf.org/doc/html/draft-ietf-add-ddr
[I-D.ietf-add-dnr]: https://datatracker.ietf.org/doc/html/draft-ietf-add-dnr
