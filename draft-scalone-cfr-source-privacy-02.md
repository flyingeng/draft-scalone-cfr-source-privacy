---
title: "Customer-Facing Relay (CFR): Enhancing Source Privacy in Encrypted Transport and CDN Scenarios"
abbrev: "CFR Source Privacy"
docname: draft-scalone-cfr-source-privacy-02
category: info
ipr: trust200902
submissiontype: IETF
v: 3
area: Security
workgroup: DISPATCH
date: 2026-08-31

author:
  - fullname: Gianpaolo Angelo Scalone
    organization: Vodafone
    email: gianpaolo-angelo.scalone@vodafone.com

informative:
  RFC4787:
  RFC5382:
  RFC6056:
  RFC6296:
  RFC6888:
  RFC7721:
  RFC7857:
  RFC8981:
  RFC9462:
  RFC9463:
  RFC9848:
  RFC9849:
  I-D.campling-ech-deployment-considerations:
---

--- abstract

Encrypted ClientHello (ECH) protects sensitive TLS ClientHello fields, including
the Server Name Indication (SNI), from on-path observers.  ECH does not,
however, attempt to hide the client's network-layer source identity from the
ECH client-facing server (CFS).  In split-mode deployments, the CFS decrypts
the ClientHelloInner in order to route the connection to the appropriate
backend while also receiving the connection from the client's visible source
address.

This creates a distinct source-privacy problem.  Where ECH service and content
front-door infrastructure are concentrated, a relatively small number of
providers can obtain a privileged vantage point from which a stable source
address can be correlated with many encrypted destinations and with other
service telemetry.  Measurements over a corpus of approximately one million
domains, together with an active-ECH validation subset, show substantial
front-door concentration and motivate treating source privacy as a complement
to destination privacy.

This document describes the Customer-Facing Relay (CFR), a network-layer,
access-side source-aliasing function.  A CFR forwards encrypted TCP or UDP
traffic without terminating TLS or QUIC and replaces the subscriber-visible
source address with a shared or short-lived source alias.  The document also
examines the different privacy properties of IPv4 NAT/CGN and IPv6 source
addressing and identifies requirements for privacy-preserving source mapping.

--- middle

# Introduction

TLS 1.3 and Encrypted ClientHello (ECH) {{RFC9849}} substantially reduce the
amount of destination information available to passive on-path observers.
ECH encrypts the ClientHelloInner, including the true server name and other
potentially sensitive handshake fields.  The ECH configuration can be
bootstrapped through SVCB or HTTPS DNS records as specified in {{RFC9848}}.

ECH deliberately has a different trust boundary from the problem considered
in this document.  In split mode, the client-facing server is the ECH service
provider.  It receives the connection from the client, decrypts the
ClientHelloInner, and forwards the resulting ClientHelloInner to the
appropriate backend server.  ECH therefore protects the inner destination
from parties outside that trust boundary; it does not attempt to make the
client anonymous to the client-facing server.

This distinction becomes increasingly relevant when a small number of
infrastructure providers front a large fraction of Internet services.  An
observer at such a front door can have a stronger correlation capability than
a generic on-path observer because it can combine:

* a stable or recurring network-layer source identifier;
* the destination information needed to process the ECH connection;
* connection timing and recurrence;
* transport and anti-abuse telemetry; and
* in some deployments, identity-adjacent signals such as login, bot
  management, analytics, or account-security events.

This document calls this capability *privileged linkability*.  It is not a
failure of ECH.  Rather, it is a separate privacy problem that becomes more
important as destination privacy improves and front-door infrastructure
becomes more concentrated.

The Customer-Facing Relay (CFR) is proposed as one possible network-native
mechanism to address this problem.  A CFR is positioned in or near the access
network and changes the source address and, where applicable, source port seen
by the upstream CFS.  It does not terminate TLS or QUIC and does not require
access to the ClientHelloInner.  The objective is to split visibility so that
the access side can identify the subscriber but not the ECH-protected inner
destination, while the CFS can identify the inner destination but sees only a
CFR-provided source alias rather than a durable subscriber source identifier.

The initial scope of CFR is client-initiated encrypted traffic.  Unsolicited
inbound connectivity and general-purpose server hosting are out of scope.

# Terminology

**CFR (Customer-Facing Relay):**
A network function positioned in or near an access network that forwards
encrypted traffic while replacing the client-visible source address with a
source alias.  A CFR does not terminate TLS or QUIC.

**CFS (Client-Facing Server):**
The ECH service provider defined by {{RFC9849}}.  In split mode it decrypts the
ClientHelloInner and forwards it to the appropriate backend server.

**Backend Server:**
The server that terminates the end-to-end TLS connection in an ECH split-mode
deployment.

**Front Door:**
An infrastructure service that receives a large set of client connections on
behalf of multiple origins.  A CFS operated by a CDN or hosting provider is a
typical example.

**Inner Destination:**
Destination-identifying information contained in the ECH-protected
ClientHelloInner, most notably the true server name.

**Source Alias:**
The network-layer source address, and where applicable transport source port,
presented by the CFR to the upstream front door in place of the subscriber's
original source information.

**Privacy Epoch:**
An implementation-defined interval or policy boundary across which a CFR may
change the source alias used for new flows.  A privacy epoch does not imply
that the mapping of an existing transport flow changes.

**General Linkability:**
The ability of a generic observer to correlate a user, host, or household
across connections using network and protocol metadata.

**Privileged Linkability:**
The ability of a front-door observer to correlate connections while also
having access to information or telemetry that is not available to a generic
on-path observer, including the destination information processed by the CFS.

# Source Privacy and the ECH Trust Boundary

## Destination privacy is not source privacy

ECH aims to make connections to server names within an anonymity set
indistinguishable to attackers outside the ECH service boundary {{RFC9849}}.
Its use therefore removes important destination information from the ordinary
network path.

However, the network source address remains outside TLS and is necessarily
visible to the server receiving the transport connection.  In a conventional
ECH deployment without a source-privacy mechanism, the CFS can therefore
observe both:

1. the source address from which the connection arrived; and
2. the ClientHelloInner that it successfully decrypts and processes.

This creates a direct source-to-destination correlation point at the CFS.

CFR changes the first item without changing the second.  The CFS continues to
perform its ECH role, but the source visible to it is an alias belonging to a
shared CFR pool rather than the subscriber's durable access-network source
identifier.

## General and privileged linkability

It is useful to distinguish two related but different privacy questions.

General linkability asks whether an observer can correlate traffic using
addresses, timing, DNS information, TLS metadata, recurrence, and other
signals available from an ordinary network vantage point.

Privileged linkability asks what can be inferred by an entity that is itself
part of the service path and therefore legitimately receives additional
information needed to operate the service.  A CFS is such an entity.

As ECH deployment increases, general destination visibility can decrease while
the relative value of the CFS vantage point increases.  This is a
redistribution of visibility, not an argument against ECH.

## Profiling and identity joins

A stable source address does not need to identify a natural person in order to
be privacy-relevant.  It can first act as a pseudonymous correlation key.

A front-door provider may observe repeated connections from the same source or
small source set and combine them with timing, destination clusters,
transport characteristics, anti-abuse signals, or service-specific
telemetry.  The resulting profile can be useful even before the subscriber's
civil identity is known.

The privacy risk increases if the same provider family also operates services
that can create an identity join.  Examples include account login, federated
identity, CAPTCHA or bot-management workflows, fraud checks, analytics, or
other authenticated interactions.  A later identity event can potentially
enrich a previously pseudonymous history.

This document does not assume that front-door providers perform such
profiling.  The point is architectural: the combination of source continuity,
destination visibility, concentration, and identity-adjacent telemetry creates
the capability.

# Measurement of Front-Door Concentration

This section reports measurements performed by the author during 2026.  The
measurements are motivating evidence rather than protocol requirements.  They
represent a snapshot and should be reproduced longitudinally and from
multiple network vantage points.

## General one-million-domain scan

A scan processed 1,000,131 domains.  The resulting mappings contained 646,843
unique IP addresses and 17,060 unique ASNs associated with the resolved
addresses.

Observed concentration included:

* the largest ASN covered 32.7% of domains;
* the ten largest ASNs covered 53.5% of domains;
* the largest individual IP address covered 4.2% of domains; and
* the ten largest individual IP addresses covered 36.4% of domains.

AS13335 alone accounted for 326,804 domains in this dataset.

These values are not themselves a proof of profiling.  They show that a
limited set of infrastructure vantage points can receive connections for a
large number of otherwise unrelated domains, which amplifies the privacy
effect of any stable source identifier visible at those vantage points.

## Exploratory linkability classification

An exploratory linkability classification used during the measurement
campaign placed 58.6% of the full-domain corpus in high or very-high
linkability buckets, with 33.5% in the very-high bucket.

For domains without observed ECH deployment, 65.8% were classified as high or
very-high and 41.2% as very-high.  Domains with ECH present showed lower
generic linkability in this metric (27.0% high or very-high), while exhibiting
substantially stronger provider concentration.

This difference is important.  A generic linkability metric is not sufficient
to describe the privacy properties of an ECH front door.  Provider
concentration and CFS privilege form a separate dimension.

The scoring methodology is not standardized by this document and the
classification results should therefore be treated as exploratory.

## Active-ECH validation subset

A separate active-ECH validation run tested 186,999 domains.  Of these,
185,957 completed a confirmed ECH handshake, corresponding to 99.44% of all
tested domains and 99.89% of the domains for which ECH was advertised in the
tested set.

In an enrichment of the active-ECH subset:

* 99.27% of domains mapped to a single ASN, AS13335; and
* the most common individual IP address covered 21.4% of active-ECH domains.

The ASN result is the more conservative concentration signal.  A domain can
advertise multiple IP addresses, so naive IP-based percentages can
double-count a domain and should not be interpreted as mutually exclusive
market-share values.

## Interpretation and limitations

The measurements support three limited conclusions.

First, ECH is operationally deployable at significant scale.

Second, active ECH deployment in the measured snapshot was highly
concentrated in front-door infrastructure.

Third, the privacy question cannot be reduced to whether ECH hides the server
name from the ordinary path.  It is also necessary to consider what a
concentrated CFS can correlate using the source identifier that remains
visible to it.

The results do not establish user-level tracking, do not measure provider
intent, and do not establish a universal deployment distribution.  Further
work should repeat the measurements over time, across geographies and
resolvers, and with explicit grouping of infrastructure belonging to the same
provider family.

# Customer-Facing Relay Concept

## Basic topology

The conceptual path is:

```
Client -> Access Network / CFR -> ECH CFS -> Backend
```

The CFR is not the ECH CFS and does not possess the ECH private key.  It
forwards the encrypted transport flow toward the CFS while replacing the
subscriber-visible source information with a source alias.

For TCP, the CFR may use NAT/NAPT-like state or an equivalent relay mechanism.

For UDP and QUIC, the CFR maintains sufficient state to preserve the mapping
for the lifetime of the flow while leaving QUIC packets opaque.

The mechanism may be integrated into an existing access gateway or deployed
as a dedicated network function.  The defining property is the privacy
boundary, not a particular implementation.

## Visibility split

A more precise privacy model distinguishes the front-door network destination
from the ECH-protected inner destination.

| Entity | Subscriber identity/source | Front-door destination | Inner destination | Application content |
| --- | --- | --- | --- | --- |
| Client | yes | yes | yes | yes |
| Access/CFR | yes | yes | no, assuming ECH and protected DNS | no |
| CFS/front door | no, if CFR is effective | yes | yes | no in ECH split mode |
| Backend | no direct subscriber source in the CFR split | via CFS | yes | yes after TLS termination |

The access/CFR must know where to forward packets and therefore cannot be said
to know no destination at all.  Its privacy advantage is that the
ECH-protected inner server name is not required for forwarding.

Conversely, the CFS knows the inner destination as part of its ECH role but,
with a properly operated CFR, does not receive the subscriber's durable source
identifier.

No single entity in this simplified model obtains both subscriber identity and
inner destination unless there is collusion, compromise, side-channel
correlation, or an additional information source.

## CFR characteristics

A CFR is intended to have the following characteristics:

* transport preserving: it supports encrypted TCP and UDP traffic;
* no TLS or QUIC termination;
* no ClientHelloInner inspection;
* no application-content inspection;
* source aliasing using a shared address and/or prefix pool;
* mapping stability for the lifetime of an existing flow;
* alias change across new flows or privacy epochs where operationally safe;
* IPv4 and IPv6 support;
* restricted use by authorized access-network customers; and
* incremental deployability.

A CFR is not intended to be a filtering, categorization, traffic-shaping, or
lawful-intercept function.

# IPv4 NAT, CGN, and Source Privacy

## Address sharing is useful but not sufficient

IPv4 NAT44 and carrier-grade NAT (CGN) already create a form of source
aggregation.  Multiple subscribers can share one external IPv4 address, which
can increase the size of the anonymity set visible to an upstream service.

However, existing NAT behavior is not designed to provide cross-service
unlinkability.  NAT behavioral requirements such as {{RFC4787}}, {{RFC5382}},
{{RFC6888}}, and {{RFC7857}} primarily address interoperability, robustness,
security, and predictable application behavior.

For example, endpoint-independent mapping and paired address pooling can
produce useful operational stability.  That same stability can also allow an
external address to function as a recurring pseudonymous identifier.

Similarly, port obfuscation recommendations in {{RFC6056}} and {{RFC7857}} are
primarily intended to make transport instance identifiers harder for an
off-path attacker to guess.  Port randomization does not by itself prevent a
front-door observer from grouping connections that repeatedly arrive from the
same external IP address.

## CGN and profiling

CGN can make one external address represent many subscribers, but the privacy
benefit depends on implementation details including:

* pool size and concurrent population;
* duration of subscriber-to-address affinity;
* whether address selection is stable across destinations;
* port-set allocation behavior;
* mapping lifetime;
* traffic timing and recurrence; and
* auxiliary signals visible at the upstream service.

Consequently, "behind CGN" should not be treated as equivalent to
"unlinkable".

A CFR-specific IPv4 profile should avoid using a stable external address as a
long-lived subscriber pseudonym.  It should also avoid changing the mapping
of an established transport flow merely to obtain more frequent rotation.

## Desired IPv4 mapping properties

A future CFR specification should define measurable privacy properties for
IPv4 source mapping.  Candidate properties include:

1. **Flow stability:** the external address/port mapping remains stable for
   the lifetime required by the transport flow.
2. **Cross-flow rotation:** new flows can be assigned different external
   aliases across time or privacy epochs.
3. **Shared pools:** aliases are drawn from pools used concurrently by
   multiple subscribers.
4. **No durable one-to-one assignment:** the external address should not
   become a long-lived deterministic identifier for one subscriber.
5. **Port obfuscation:** when source ports are translated, the translation
   should not introduce trivially predictable per-subscriber structure.
6. **Destination independence of privacy policy:** an implementation should
   not create a stable alias solely because many destinations happen to be
   served by the same front-door provider.

The exact trade-off among stability, entropy, port exhaustion, logging, and
application compatibility is left for future work.

# IPv6 Addressing, Prefixes, and Source Privacy

## Temporary addresses do not hide the network prefix

IPv6 commonly avoids address translation.  Host-side privacy mechanisms such
as temporary addresses {{RFC8981}} improve privacy by changing randomized
interface identifiers over time.

This is valuable but addresses a different layer of the problem.  An external
observer may still see a stable or slowly changing network prefix associated
with a household, access line, or subscriber delegation.  Multiple temporary
interface identifiers under the same visible prefix can therefore remain
groupable.

The broader privacy properties of IPv6 address-generation mechanisms are
discussed in {{RFC7721}}.

## NPTv6 is not an unlinkability mechanism

IPv6-to-IPv6 Network Prefix Translation (NPTv6) {{RFC6296}} provides a
stateless, transport-agnostic 1:1 translation between inside and outside
prefixes.  It is useful for address independence while preserving network
layer reachability.

A stable 1:1 prefix translation does not, by itself, provide the source
unlinkability sought by CFR.  If the same internal prefix is persistently
mapped to the same external prefix, an upstream observer can still use that
external prefix as a durable pseudonymous identifier.

CFR therefore does not equate IPv6 source privacy with simply deploying
NPTv6.

## CFR options for IPv6

An IPv6 CFR could be implemented using one or more mechanisms, including:

* stateful IPv6 source aliasing using a shared egress address pool;
* short-lived selection from multiple egress prefixes;
* tunneling to a CFR egress that assigns a source alias; or
* another mechanism that produces equivalent source-unlinkability
  properties without exposing the subscriber's delegated prefix.

This document does not select a single IPv6 translation architecture.

Whatever mechanism is used, the privacy objective is that the address or
prefix visible to the CFS is not a durable one-to-one representation of the
subscriber's access prefix.

## Desired IPv6 mapping properties

A future CFR specification should consider at least:

1. **Prefix unlinkability:** the CFS-visible prefix should not directly encode
   or persistently mirror the subscriber's delegated prefix.
2. **Address-pool sharing:** multiple subscribers should use the same CFR
   egress address or prefix space over time.
3. **Flow stability:** an established TCP or QUIC flow should not have its
   source changed merely because a privacy epoch expires.
4. **Rotation for new flows:** new connections may receive a different source
   alias when compatible with transport and application behavior.
5. **No IID-only assumption:** changing only the interface identifier is not
   sufficient when the stable prefix remains a correlation key.
6. **Equivalent IPv4/IPv6 privacy goals:** dual-stack clients should not
   obtain substantially weaker source privacy merely because one address
   family is selected.

# CFR Privacy Requirements

The following requirements describe the intended design space.  They are not
a normative protocol specification.

**R1 - Preserve destination confidentiality.**
CFR operation must not require ECH disablement or access to the
ClientHelloInner.

**R2 - Preserve end-to-end encryption.**
The CFR must not terminate the TLS or QUIC security association between client
and server.

**R3 - Reduce durable source linkability.**
The source alias visible to the CFS should not become a long-lived
subscriber identifier.

**R4 - Preserve transport flow continuity.**
Address and port changes should occur at safe flow boundaries unless the
transport explicitly supports and validates migration.

**R5 - Provide IPv4/IPv6 parity.**
The privacy objective should be expressible for both address families even
when the implementation mechanisms differ.

**R6 - Create a meaningful anonymity set.**
A source alias or egress pool should be shared among enough users and flows to
make trivial one-to-one mapping difficult.

**R7 - Minimize new visibility.**
A CFR should not introduce application-layer inspection or destination
classification as a prerequisite for source privacy.

**R8 - Avoid becoming an open relay.**
CFR use must be restricted to authorized users or access-network attachment.

**R9 - Support operational accountability without universal profiling.**
Operators may need mechanisms for abuse response, but such mechanisms should
not require the upstream CFS to receive a stable subscriber identifier.

# Discovery and Bootstrapping

A CFR integrated into an access network may not need explicit end-host
discovery if routing policy directs eligible traffic through it.

Other deployments may require clients to learn that a CFR service is
available or to select among CFR instances.

Discovery of Designated Resolvers (DDR) {{RFC9462}} and Discovery of
Network-designated Resolvers (DNR) {{RFC9463}} demonstrate mechanisms by which
network-provided encrypted services can be discovered.  They are DNS resolver
discovery mechanisms and cannot be directly reused as a generic CFR discovery
protocol without new specification work.

Future work could consider DHCP, Router Advertisement, DNS, configuration
profiles, or application-independent service-binding mechanisms.  Any
discovery mechanism must include a way to authenticate the CFR service and
avoid redirection to an attacker-controlled relay.

# Performance and Transport Considerations

A CFR adds forwarding and source-mapping state and can therefore affect
latency, state scale, and failure handling.

Important questions include:

* stateful versus stateless operation;
* load balancing across CFR instances;
* failover without exposing a stable fallback source;
* TCP state lifetime;
* UDP mapping lifetime;
* QUIC connection migration and path validation;
* multipath transports;
* fragmentation and Path MTU Discovery;
* ICMP and ICMPv6 handling;
* asymmetric routing;
* address and port pool exhaustion; and
* interaction with access-network anti-spoofing controls.

For QUIC in particular, a CFR should normally keep the source alias stable for
an existing path.  Rotating an alias in the middle of a connection can be
interpreted as path migration and may trigger validation or anti-abuse logic.

# Abuse Prevention and Accountability

A CFR must not become a general-purpose unauthenticated relay.

An access-provider deployment can restrict CFR use through the subscriber's
existing network attachment.  Other deployment models may require explicit
authorization.

CFR operation may complicate abuse response because the CFS no longer sees the
subscriber's access address.  This is an intentional privacy property and
creates a design tension with attribution.

Possible operational approaches include short-lived mapping records,
rate-limiting at the CFR, aggregate abuse signaling, or privacy-preserving
authorization mechanisms.  The appropriate retention and legal policies are
deployment-specific and outside the scope of this document.

Any accountability mechanism should be evaluated against the risk of
reconstructing a universal source-to-destination history.

# Relationship to Existing Work

## Encrypted ClientHello

ECH {{RFC9849}} protects the ClientHelloInner from on-path observers and
defines the client-facing server trust boundary.  CFR does not modify ECH and
does not attempt to hide information from the backend origin.  It addresses
the network source identifier visible at the ECH front door.

Bootstrapping of ECH through DNS SVCB and HTTPS records is specified in
{{RFC9848}}.

## Encrypted DNS

Encrypted DNS can prevent local-path observers from learning the queried
domain name.  This strengthens the intended CFR visibility split because the
access-side relay does not need to learn the inner destination in order to
forward packets.

CFR is not a DNS privacy mechanism and does not replace DoH, DoT, DoQ, DDR, or
DNR.

## IPv4 NAT and CGN

NAT and CGN already provide address translation and, sometimes, address
sharing.  CFR builds on similar data-plane techniques but has a different
objective: reducing durable source correlation at a concentrated upstream
front door.

## IPv6 privacy addressing

IPv6 temporary addresses {{RFC8981}} reduce host-level address correlation.
CFR additionally targets correlation through a stable network prefix or
stable upstream source mapping.

## ECH deployment considerations

Operational deployment considerations for ECH are discussed in
{{I-D.campling-ech-deployment-considerations}}.  CFR addresses a different but
complementary question: the source identifier visible to the ECH front door.

## Proxy and relay systems

Application or transport proxy systems can also hide a client's source
address from the final destination.  CFR explores a narrower access-network
function that does not require application-layer proxy semantics and does not
terminate the encrypted application session.

# Security and Privacy Considerations

CFR changes the distribution of metadata visibility and therefore introduces
its own security and privacy risks.

## Collusion

If the CFR operator and the CFS exchange sufficiently detailed per-flow
records, the intended visibility split can be reconstructed.

CFR therefore does not provide protection against collusion between all
parties in the path.

## Timing correlation

Even when source aliases change, a sufficiently capable observer may correlate
flows using timing, packet sizes, recurrence, or other traffic-analysis
signals.

CFR is intended to reduce a strong explicit identifier.  It is not a complete
traffic-analysis defense.

## Small anonymity sets

A source alias used by only one subscriber, or by very few subscribers, can
provide little privacy benefit.  Implementations should measure effective
pool occupancy and should not assume that translation alone creates
anonymity.

## Stable alias assignment

A deterministic long-lived subscriber-to-alias mapping defeats a central CFR
privacy objective even if the alias differs from the subscriber's real
address.

This risk applies to both IPv4 external-address affinity and IPv6 stable
prefix translation.

## State exhaustion and denial of service

Stateful CFRs can be attacked through connection or mapping exhaustion.
Existing NAT and relay operational experience is relevant, but privacy-driven
rotation can increase state-management complexity.

## Open-relay abuse

An improperly authenticated CFR could be used to conceal attack sources or
amplify traffic.  Deployments must restrict who can originate traffic through
the CFR and should apply ordinary anti-spoofing and abuse controls.

## Identity joins outside the network layer

CFR cannot prevent a user from directly identifying themselves to an
application, identity provider, analytics system, or other service.  It can
reduce the ability to use the network source address as a universal join key,
but application-level identifiers remain outside its scope.

## Operational drift

A CFR is intentionally narrow.  Adding TLS termination, content inspection,
classification, or persistent cross-destination subscriber identifiers would
change the privacy model and should be treated as a different architecture.

# IETF Standardization Questions

Further work is required before CFR can be specified as an interoperable
protocol or behavior.

Open questions include:

* how to define measurable source-unlinkability targets;
* how large a shared egress pool must be to provide useful privacy;
* how to define privacy epochs without breaking applications;
* whether IPv4 and IPv6 require separate mapping profiles;
* how to discover and authenticate optional CFR services;
* how to support QUIC migration and multipath transports;
* how to handle abuse response without restoring a globally visible
  subscriber identifier;
* how to measure the privacy impact of existing CGN behavior;
* how to model CFS provider-family concentration rather than ASN concentration
  alone; and
* how to test whether source aliases remain linkable through auxiliary
  signals.

DISPATCH, PEARG, MASQUE, INTAREA, and transport-related working groups may
contain expertise relevant to different parts of this problem.  This document
does not assume a particular final venue.

# IANA Considerations

This document makes no IANA requests.

--- back

# Changes from -01 to -02

* Updated ECH references to RFC 9849 and ECH DNS bootstrapping to RFC 9848.
* Reframed CFR around the ECH client-facing server trust boundary.
* Added the distinction between general linkability and privileged CFS
  linkability.
* Added 2026 one-million-domain and active-ECH concentration measurements.
* Added a profiling and identity-join threat model.
* Corrected the CFR privacy model to distinguish the front-door network
  destination from the ECH-protected inner destination.
* Expanded IPv4 NAT/CGN analysis and explained why address sharing alone does
  not guarantee unlinkability.
* Added IPv6 temporary-address, prefix-linkability, and NPTv6 analysis.
* Added candidate source-mapping privacy requirements for IPv4 and IPv6.
* Clarified that DDR and DNR are precedents for network service discovery, not
  directly reusable CFR discovery protocols.
* Expanded transport, abuse, accountability, and security considerations.

# Acknowledgments
{:numbered="false"}

The author acknowledges the helpful input and discussions from Andrew
Campling, Arnaud Taddei, Kevin Smith, Lee Wilman, Tom Newton, colleagues
within Vodafone Group, and participants in DINRG, PEARG, and DISPATCH.
