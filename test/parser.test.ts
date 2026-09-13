import { describe, it, expect } from 'vitest';
import { ZodiacCliParser } from '../src/parser.js';
import { ZODIAC_HARDWARE } from '../src/constants.js';

describe('ZodiacCliParser (Deterministic Protocol & State Boundary)', () => {
  it('parses show status output with full hardware bounds', () => {
    const raw = `
Device Name: Zodiac_FX
Firmware Version: 0.85
MAC Address: 70:B3:D5:11:22:33
IP Address: 10.0.1.99
Netmask: 255.255.255.0
Gateway: 10.0.1.1
OpenFlow Controller: 10.0.1.8
OpenFlow Port: 6633
OpenFlow Version: 4
Failstate: secure
Active Flows: 14
`;

    const status = ZodiacCliParser.parseStatus(raw);

    expect(status.name).toBe('Zodiac_FX');
    expect(status.firmwareVersion).toBe('0.85');
    expect(status.macAddress).toBe('70:B3:D5:11:22:33');
    expect(status.ipAddress).toBe('10.0.1.99');
    expect(status.failstate).toBe('secure');
    expect(status.activeFlowCount).toBe(14);
    expect(status.maxFlowCapacity).toBe(ZODIAC_HARDWARE.MAX_FLOWS);
    expect(status.ofVersion).toBe(4);
  });

  it('parses show ports output with exact BigInt packet and byte counters', () => {
    const raw = `
Port 1:
  Status: UP
  VLAN: 100 (openflow)
  RX Packets: 15420
  TX Packets: 14380
  RX Bytes: 1048576
  TX Bytes: 984320
  RX Dropped: 5
  TX Dropped: 0
  RX Errors: 0
  TX Errors: 0

Port 4:
  Status: UP
  VLAN: 200 (native)
  RX Packets: 890
  TX Packets: 890
  RX Bytes: 56960
  TX Bytes: 56960
  RX Dropped: 0
  TX Dropped: 0
  RX Errors: 0
  TX Errors: 0
`;

    const ports = ZodiacCliParser.parsePorts(raw);

    expect(ports).toHaveLength(2);
    const p1 = ports[0]!;
    expect(p1.port).toBe(1);
    expect(p1.state).toBe('UP');
    expect(p1.vlanId).toBe(100);
    expect(p1.vlanType).toBe('openflow');
    expect(p1.rxPackets).toBe(15420n);
    expect(p1.rxBytes).toBe(1048576n);
    expect(p1.rxDropped).toBe(5n);

    const p4 = ports[1]!;
    expect(p4.port).toBe(4);
    expect(p4.vlanType).toBe('native');
    expect(p4.txPackets).toBe(890n);
  });

  it('parses show flows output enforcing BigInt flow counters', () => {
    const raw = `
Flow 0:
  Table: 0
  Priority: 100
  Match: in_port=1,eth_type=0x0800,nw_src=10.0.1.5
  Actions: output:2
  Packet Count: 420
  Byte Count: 35280
  Duration: 120
`;

    const flows = ZodiacCliParser.parseFlows(raw);

    expect(flows).toHaveLength(1);
    const f0 = flows[0]!;
    expect(f0.index).toBe(0);
    expect(f0.priority).toBe(100);
    expect(f0.match).toBe('in_port=1,eth_type=0x0800,nw_src=10.0.1.5');
    expect(f0.actions).toBe('output:2');
    expect(f0.packetCount).toBe(420n);
    expect(f0.byteCount).toBe(35280n);
    expect(f0.durationSec).toBe(120);
  });
});
