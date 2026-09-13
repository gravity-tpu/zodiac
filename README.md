# Zodiac FX Physical Switch Driver & Interface (`@gravity-tpu/zodiac`)

> **Deterministic Hardware Driver, Serial CLI Interface & OpenFlow 1.3 Profile**  
> For the **Northbound Networks Zodiac FX** OpenFlow Hardware Switch.  
> Governed by the Senior Staff Council Invariants (Scale, Simplicity, Adaptation, Verification).  
> Upstream Core Architecture: [gravity-tpu/agentic-era-networking](https://github.com/gravity-tpu/agentic-era-networking)  
> **Product Roadmap**: [ROADMAP.md](./ROADMAP.md) (Autonomous Edge SDN & Hardware-Accelerated Network Services)

---

## 1. Hardware Overview & Specifications

The **Zodiac FX** is a 4-port 10/100 Fast Ethernet OpenFlow switch engineered for physical testbeds and verifiable software-defined networking:

* **Microcontroller (Control Plane)**: Atmel / Microchip SAM4E8E (ARM Cortex-M4 @ 120 MHz, 512KB Flash, 128KB SRAM).
* **Switch Engine (Data Plane)**: Micrel / Microchip KSZ8795CLX (5-port L2 switch with hardware tail-tagging).
* **Physical Ports**:
  * **Port 1**: OpenFlow Data Plane (Default VLAN 100).
  * **Port 2**: OpenFlow Data Plane (Default VLAN 100).
  * **Port 3**: OpenFlow Data Plane / Tap Mirror (Default VLAN 100).
  * **Port 4**: Native Controller / Management (Default VLAN 200).
* **Hardware Bounds**:
  * Maximum Flow Entries: **128 flows** (`MAX_FLOWS = 128`).
  * Maximum Rate Meters: **8 meters** (up to 3 bands each).
  * Maximum Action Groups: **8 groups** (up to 32 buckets).
* **Management Channels**:
  * **Micro-USB**: 5V Power + USB CDC ACM Serial CLI (`/dev/cu.usbmodem*` on macOS @ 115200 8N1).
  * **OpenFlow Southbound**: OpenFlow 1.0 (`0x01`) and OpenFlow 1.3 (`0x04`) over TCP port 6633.
  * **Embedded Web UI**: lwIP HTTP server on port 80 (default `http://10.0.1.99`).

---

## 2. Invariants & Implementation Rigor

1. **64-bit Integer Counters (BigInt)**:
   All packet counts, byte volumes, and dropped frame counters parse directly into native `BigInt`. No floating-point rounding errors.
2. **Fail-Closed Default (Default Drop)**:
   Failstate defaults to `secure`. If contact with the controller is severed, transit packets are dropped by construction.
3. **Deterministic Context Management**:
   The `ZodiacDriver` automatically manages CLI state transitions between `base`, `config`, `openflow`, and `debug` contexts.

---

## 3. Autonomous Edge SDN Product Roadmap

We are implementing 6 core edge networking and content delivery services on desktop silicon:

* **[Read Full Roadmap & Specifications](./ROADMAP.md)**
  1. **Phase 1: Transparent DNS Reverse Proxy Interception** (RFC 1035 UDP wire interception & VIP mapping)
  2. **Phase 2: Dynamic Multi-Path & Congestion-Aware Routing** (Multi-port path optimization & loop-free DAG proof)
  3. **Phase 3: Wire-Level Hardware Rate Limiting & Metering** (KSZ8795 8 rate meters in switch hardware)
  4. **Phase 4: Sub-3ms Edge Anomaly Detection & Threat Mitigation** (Google Coral Edge TPU INT8 coprocessor)
  5. **Phase 5: Edge Asset Caching & Tag-Based Invalidation Engine** (RAM/SSD ring cache with instant tag purging)
  6. **Phase 6: Edge Programmable Workers & On-Device ML Inference** (On-device neural tensor inference at wire speeds)

---

## 4. Quick Start

### Installation
```bash
npm install
npm run build
npm test
```

### CLI Commands
```bash
# Scan for connected Zodiac FX over USB
npx zodiac scan

# Display live status and port telemetry
npx zodiac status
npx zodiac ports

# Inspect active 128-entry flow table
npx zodiac flows
```

### Programmatic Usage
```typescript
import { ZodiacDriver, ZodiacCliParser } from '@gravity-tpu/zodiac';

// Attach to serial transport or mock stream
const driver = new ZodiacDriver(serialTransport);

// Query live 4-port hardware status
const ports = await driver.getPorts();
for (const p of ports) {
  console.log(`Port ${p.port}: ${p.state} | Rx: ${p.rxPackets} pkts (${p.rxBytes} bytes)`);
}

// Enforce fail-closed security
await driver.setFailstate('secure');
```

---

## 5. Hardware Headers & Pinouts

### JTAG Debug Header (Atmel-ICE SAM Connector)
* Pin 1: +3.3V
* Pin 2: TMS
* Pin 3: GND
* Pin 4: TCK
* Pin 5: GND
* Pin 6: TDO
* Pin 8: TDI

### SPI Expansion Header
* Pin 1: +5.0V (200mA Max)
* Pin 3: IRQ 1 (Slave interrupt)
* Pin 4: GND
* Pin 5: MISO
* Pin 6: NPCS0
* Pin 7: SCK
* Pin 8: MOSI

---

## 6. License
Apache-2.0
