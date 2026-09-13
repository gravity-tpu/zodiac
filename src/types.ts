/**
 * types.ts
 * Type definitions for Zodiac FX Switch states, flows, ports, and telemetry
 *
 * Council Invariant: All packet and byte accounting counters must use BigInt.
 */

export type ZodiacCliContext = 'base' | 'config' | 'openflow' | 'debug';
export type ZodiacPortState = 'UP' | 'DOWN';
export type ZodiacVlanType = 'openflow' | 'native';
export type ZodiacFailstate = 'secure' | 'safe';

export interface ZodiacPortStats {
  readonly port: number;
  readonly state: ZodiacPortState;
  readonly vlanId: number;
  readonly vlanType: ZodiacVlanType;
  readonly rxPackets: bigint;
  readonly txPackets: bigint;
  readonly rxBytes: bigint;
  readonly txBytes: bigint;
  readonly rxDropped: bigint;
  readonly txDropped: bigint;
  readonly rxErrors: bigint;
  readonly txErrors: bigint;
}

export interface ZodiacDeviceStatus {
  readonly name: string;
  readonly firmwareVersion: string;
  readonly macAddress: string;
  readonly ipAddress: string;
  readonly netmask: string;
  readonly gateway: string;
  readonly ofControllerIp: string;
  readonly ofControllerPort: number;
  readonly ofVersion: number;
  readonly failstate: ZodiacFailstate;
  readonly activeFlowCount: number;
  readonly maxFlowCapacity: number;
}

export interface ZodiacFlowEntry {
  readonly index: number;
  readonly tableId: number;
  readonly priority: number;
  readonly match: string;
  readonly actions: string;
  readonly packetCount: bigint;
  readonly byteCount: bigint;
  readonly idleTimeoutSec?: number | undefined;
  readonly hardTimeoutSec?: number | undefined;
  readonly durationSec?: number | undefined;
}

export interface ZodiacVlanConfig {
  readonly id: number;
  readonly name: string;
  readonly type: ZodiacVlanType;
  readonly ports: readonly number[];
}
