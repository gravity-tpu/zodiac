# Product Roadmap: Autonomous Edge SDN & Hardware-Accelerated Network Services

> **Physical Laboratory Testbed for Edge SDN & Hardware Acceleration**  
> **Substrate:** Northbound Networks Zodiac FX (KSZ8795 + SAM4E8E) + Google Coral USB Accelerator (Edge TPU)  
> **Upstream Engine:** [gravity-tpu/agentic-era-networking](https://github.com/gravity-tpu/agentic-era-networking)  
> **Invariants:** Fail-Closed Default Drop (INV-002), 64-Bit Integer BigInt Counters (INV-001), Nanosecond Precision Latencies (The Dean Invariant).

---

## 1. Overview & Capability Matrix

This roadmap outlines the phased development of **6 core edge networking and content delivery services** directly on physical desktop silicon. By coupling the Zodiac FX programmable switch with the Google Coral Edge TPU coprocessor over a host DisplayLink dock, we replicate and validate foundational software-defined edge primitives at the physical packet and wire level.

| Milestone | Problem Space / Networking Primitive | Local Hardware Implementation | Target Latency | Council Invariant |
| :--- | :--- | :--- | :--- | :--- |
| **Phase 1** | **Transparent DNS Reverse Proxy Interception** | Authoritative RFC 1035 UDP DNS Server + Local VIP Proxy | < 1 ms | *Ghemawat* (Zero-Config Simplicity) |
| **Phase 2** | **Dynamic Multi-Path & Congestion-Aware Routing** | Multi-Port Path Optimization (Zodiac Ports 1, 2, 3) | 5–15 ms dynamic shift | *Vinyals & Hassabis* (Loop-Free DAG Proof) |
| **Phase 3** | **Wire-Level Hardware Rate Limiting & Metering** | KSZ8795 8 Hardware Rate Meters (3 Bands Each) | Line-rate wire drop | *Dean* (Nanosecond Hardware Enforcement) |
| **Phase 4** | **Sub-3ms Edge Anomaly Detection & Threat Mitigation** | Google Coral TPU INT8 Anomaly Classifier (Port 3 Tap) | < 3 ms inference | *Hassabis & Ghemawat* (Fail-Closed Quarantine) |
| **Phase 5** | **Edge Asset Caching & Tag-Based Invalidation** | Flat RAM/SSD Ring Cache with Instant Tag Purge | < 0.5 ms cache hit | *Dean & Ghemawat* (Cache Locality & BigInt Metrics) |
| **Phase 6** | **Edge Programmable Workers & On-Device ML Inference** | Local Compute Pipeline with INT8 Tensor Acceleration | 2.5 ms inference | *Quoc Le* (Adaptive On-Device Intelligence) |

---

## 2. Detailed Milestone Specifications

### Phase 1: Transparent DNS Reverse Proxy Interception Engine
* **Goal**: Transparently intercept client web traffic across physical data ports without requiring client-side proxy configuration or URL rewriting.
* **Mechanism**:
  1. Zodiac FX forwards client DNS queries (UDP port 53) on Port 1 directly to the local DNS server (`src/dns/server.ts`).
  2. The DNS resolver answers query records with a local Virtual IP (VIP) managed on the host controller.
  3. Client HTTP/TLS requests are naturally steered into the local edge proxy cache before transit to external upstreams on Port 2.
* **Deliverables**:
  - `src/edge/dns-proxy-interceptor.ts`: Transparent DNS query interception and VIP mapping.
  - Integration with `agentic-era-networking` wire RFC 1035 engine.

### Phase 2: Dynamic Multi-Path & Congestion-Aware Routing
* **Goal**: Dynamically steer packets across multiple physical egress links based on real-time link health, jitter, and nanosecond round-trip times (RTT).
* **Mechanism**:
  1. Zodiac FX Port 2 configured as Primary Uplink; Port 3 configured as Secondary / Sandbox Uplink.
  2. Continuous probe packets measure jitter, frame errors (`rx_frame_err`), and RTT deltas.
  3. Upon detecting link degradation or latency spikes, the controller synthesizes a path transition.
  4. The candidate route passes through `SymbolicRouteVerifier.verifyLoopFree()` before an OpenFlow 1.3 `FLOW_MOD` shifts traffic to Port 3.
* **Deliverables**:
  - `src/edge/smart-router.ts`: Multi-path latency probe and OpenFlow port steering.
  - Formal cycle verification preventing route flap oscillations.

### Phase 3: Wire-Level Hardware Rate Limiting & Metering
* **Goal**: Protect upstream origins and local workloads from bandwidth exhaustion by enforcing rate limits directly at the physical switch PHY.
* **Mechanism**:
  1. Program the Zodiac FX's **8 hardware rate meters** via OpenFlow 1.3 meter modification commands (`OFPMC_ADD`).
  2. Configure up to 3 meter bands per meter (e.g., Band 1: Remark DSCP; Band 2: Drop; Band 3: Quarantine).
  3. Counters for dropped frames (`rx_dropped`, `tx_dropped`) tracked strictly using 64-bit integer units (`BigInt`).
* **Deliverables**:
  - `src/edge/hardware-meters.ts`: Typed configuration generator for KSZ8795 switch rate limiters.
  - Prometheus meter telemetry metrics exporter.

### Phase 4: Sub-3ms Edge Anomaly Detection & Threat Mitigation
* **Goal**: Neutralize anomalous traffic bursts, port scanning, and rogue agent traffic before packets reach the host operating system.
* **Mechanism**:
  1. Zodiac FX Port 3 acts as a hardware mirror/tap port, replicating ingress packet streams into the host controller.
  2. The Google Coral USB Edge TPU evaluates quantized INT8 1D-CNN or Autoencoder models on sliding windows of packet headers and inter-arrival times ($\Delta t$).
  3. If reconstruction error exceeds threshold, an immediate OpenFlow `FLOW_MOD` (priority `65535`, action `DROP`) is pushed into the 128-entry table to block the offending MAC/IP.
  4. Adheres to fail-closed isolation: if the TPU model crashes or confidence drops, traffic is dropped by default.
* **Deliverables**:
  - `src/edge/tpu-anomaly-detector.ts`: Coral Edge TPU inference driver and feature extraction pipeline.
  - Automated high-priority quarantine flow injector.

### Phase 5: Edge Asset Caching & Tag-Based Invalidation Engine
* **Goal**: Serve static assets and idempotent API GET responses from local edge memory, eliminating redundant origin fetches.
* **Mechanism**:
  1. Local reverse proxy stores HTTP responses in a cache-friendly flat in-memory ring buffer.
  2. Cache hits are fulfilled directly in < 500 µs without traversing external switch ports.
  3. API-driven cache purge endpoint supports URL, prefix, and cache-tag invalidation.
  4. Physical switch port telemetry (`rxBytes` vs. `txBytes`) verifies origin bandwidth offload.
* **Deliverables**:
  - `src/edge/cache-engine.ts`: In-memory LRU cache with instant purge APIs.
  - Cache hit/miss ratio telemetry mapped to BigInt hardware counters.

### Phase 6: Edge Programmable Workers & On-Device ML Inference
* **Goal**: Execute compute logic, request payload transformations, and AI classification directly on the edge node without cloud round-trip delay.
* **Mechanism**:
  1. Lightweight edge worker pipeline intercepts inbound requests on the local reverse proxy.
  2. Offloads complex classification tasks (e.g., token verification, intent detection, prompt injection scanning) to the Google Coral Edge TPU in ~2.5 ms.
  3. Rewrites HTTP headers, annotates telemetry metadata, and dynamically adjusts routing decisions before upstream dispatch.
* **Deliverables**:
  - `src/edge/worker-runtime.ts`: Modular middleware pipeline supporting on-device Edge TPU tensor execution.
  - End-to-end benchmark demonstrating < 5 ms total edge processing overhead.

---

## 3. Implementation Order & Verification Gates

Development proceeds sequentially from Phase 1 to Phase 6. Each milestone must pass the Senior Staff Council verification suite:
* Strict TypeScript compilation with zero `@ts-ignore` or loose type casts.
* Deterministic unit tests with 100% invariant adherence.
* Real hardware validation against the physical Zodiac FX switch and Coral USB Accelerator.
