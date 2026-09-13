/**
 * parser.ts
 * Deterministic text parser for Northbound Networks Zodiac FX CLI responses
 *
 * Invariant: All packet and byte statistics must parse into 64-bit integer units (BigInt).
 */

import { ZODIAC_HARDWARE } from './constants.js';
import type {
  ZodiacDeviceStatus,
  ZodiacFailstate,
  ZodiacFlowEntry,
  ZodiacPortState,
  ZodiacPortStats,
  ZodiacVlanConfig,
  ZodiacVlanType,
} from './types.js';

export class ZodiacCliParser {
  /**
   * Parses the output of `show status` in the base CLI context.
   */
  public static parseStatus(raw: string): ZodiacDeviceStatus {
    const getVal = (regex: RegExp, fallback = ''): string => {
      const match = raw.match(regex);
      return match && match[1] ? match[1].trim() : fallback;
    };

    const failstateRaw = getVal(/failstate\s*:\s*([a-zA-Z]+)/i, 'secure').toLowerCase();
    const failstate: ZodiacFailstate = failstateRaw === 'safe' ? 'safe' : 'secure';

    const activeFlowsRaw = parseInt(getVal(/active\s*flows\s*:\s*(\d+)/i, '0'), 10);
    const ofPortRaw = parseInt(getVal(/openflow\s*port\s*:\s*(\d+)/i, '6633'), 10);
    const ofVersionRaw = parseInt(getVal(/openflow\s*version\s*:\s*(\d+)/i, '4'), 10);

    return {
      name: getVal(/device\s*name\s*:\s*([^\r\n]+)/i, 'Zodiac_FX'),
      firmwareVersion: getVal(/firmware\s*version\s*:\s*([^\r\n]+)/i, 'unknown'),
      macAddress: getVal(/mac\s*address\s*:\s*([0-9a-fA-F:]{17})/i, '00:00:00:00:00:00'),
      ipAddress: getVal(/ip\s*address\s*:\s*([0-9.]+)/i, ZODIAC_HARDWARE.DEFAULT_IP),
      netmask: getVal(/netmask\s*:\s*([0-9.]+)/i, ZODIAC_HARDWARE.DEFAULT_NETMASK),
      gateway: getVal(/gateway\s*:\s*([0-9.]+)/i, ZODIAC_HARDWARE.DEFAULT_GATEWAY),
      ofControllerIp: getVal(/controller(?:\s*ip)?\s*:\s*([0-9.]+)/i, ZODIAC_HARDWARE.DEFAULT_CONTROLLER_IP),
      ofControllerPort: isNaN(ofPortRaw) ? 6633 : ofPortRaw,
      ofVersion: isNaN(ofVersionRaw) ? 4 : ofVersionRaw,
      failstate,
      activeFlowCount: isNaN(activeFlowsRaw) ? 0 : activeFlowsRaw,
      maxFlowCapacity: ZODIAC_HARDWARE.MAX_FLOWS,
    };
  }

  /**
   * Parses the output of `show ports` in the base CLI context.
   */
  public static parsePorts(raw: string): ZodiacPortStats[] {
    const ports: ZodiacPortStats[] = [];
    const portBlocks = raw.split(/(?:^|\n)Port\s+(\d+):/i).slice(1);

    for (let i = 0; i < portBlocks.length; i += 2) {
      const portNum = parseInt(portBlocks[i] ?? '', 10);
      const block = portBlocks[i + 1] ?? '';

      if (isNaN(portNum)) continue;

      const getBigInt = (regex: RegExp): bigint => {
        const match = block.match(regex);
        if (!match || !match[1]) return 0n;
        try {
          return BigInt(match[1]);
        } catch {
          return 0n;
        }
      };

      const stateMatch = block.match(/status\s*:\s*([a-zA-Z]+)/i);
      const state: ZodiacPortState =
        stateMatch && stateMatch[1] && stateMatch[1].toUpperCase() === 'UP' ? 'UP' : 'DOWN';

      const vlanMatch = block.match(/vlan\s*:\s*(\d+)(?:\s*\(([a-zA-Z]+)\))?/i);
      const vlanId = vlanMatch && vlanMatch[1] ? parseInt(vlanMatch[1], 10) : (portNum === 4 ? 200 : 100);
      const vlanType: ZodiacVlanType =
        vlanMatch && vlanMatch[2] && vlanMatch[2].toLowerCase() === 'native' ? 'native' : 'openflow';

      ports.push({
        port: portNum,
        state,
        vlanId,
        vlanType,
        rxPackets: getBigInt(/rx\s*packets\s*:\s*(\d+)/i),
        txPackets: getBigInt(/tx\s*packets\s*:\s*(\d+)/i),
        rxBytes: getBigInt(/rx\s*bytes\s*:\s*(\d+)/i),
        txBytes: getBigInt(/tx\s*bytes\s*:\s*(\d+)/i),
        rxDropped: getBigInt(/rx\s*dropped\s*:\s*(\d+)/i),
        txDropped: getBigInt(/tx\s*dropped\s*:\s*(\d+)/i),
        rxErrors: getBigInt(/rx\s*errors\s*:\s*(\d+)/i),
        txErrors: getBigInt(/tx\s*errors\s*:\s*(\d+)/i),
      });
    }

    return ports;
  }

  /**
   * Parses the output of `show flows` in the openflow CLI context.
   */
  public static parseFlows(raw: string): ZodiacFlowEntry[] {
    const flows: ZodiacFlowEntry[] = [];
    const flowBlocks = raw.split(/(?:^|\n)Flow\s+(\d+):/i).slice(1);

    for (let i = 0; i < flowBlocks.length; i += 2) {
      const flowIndex = parseInt(flowBlocks[i] ?? '', 10);
      const block = flowBlocks[i + 1] ?? '';

      if (isNaN(flowIndex)) continue;

      const getBigInt = (regex: RegExp): bigint => {
        const match = block.match(regex);
        if (!match || !match[1]) return 0n;
        try {
          return BigInt(match[1]);
        } catch {
          return 0n;
        }
      };

      const tableMatch = block.match(/table\s*:\s*(\d+)/i);
      const prioMatch = block.match(/priority\s*:\s*(\d+)/i);
      const matchMatch = block.match(/match\s*:\s*([^\r\n]+)/i);
      const actionsMatch = block.match(/actions?\s*:\s*([^\r\n]+)/i);
      const durMatch = block.match(/duration\s*:\s*(\d+)/i);

      flows.push({
        index: flowIndex,
        tableId: tableMatch && tableMatch[1] ? parseInt(tableMatch[1], 10) : 0,
        priority: prioMatch && prioMatch[1] ? parseInt(prioMatch[1], 10) : 0,
        match: matchMatch && matchMatch[1] ? matchMatch[1].trim() : 'ANY',
        actions: actionsMatch && actionsMatch[1] ? actionsMatch[1].trim() : 'DROP',
        packetCount: getBigInt(/packet\s*count\s*:\s*(\d+)/i),
        byteCount: getBigInt(/byte\s*count\s*:\s*(\d+)/i),
        durationSec: durMatch && durMatch[1] ? parseInt(durMatch[1], 10) : undefined,
      });
    }

    return flows;
  }

  /**
   * Parses the output of `show vlans` in the config CLI context.
   */
  public static parseVlans(raw: string): ZodiacVlanConfig[] {
    const vlans: ZodiacVlanConfig[] = [];
    const lines = raw.split(/\r?\n/);

    for (const line of lines) {
      const match = line.match(/^\s*(\d+)\s+([^\s]+)\s+([a-zA-Z]+)\s+([0-9, ]+)/);
      if (match && match[1] && match[2] && match[3] && match[4]) {
        const id = parseInt(match[1], 10);
        const name = match[2].trim();
        const type: ZodiacVlanType = match[3].toLowerCase() === 'native' ? 'native' : 'openflow';
        const ports = match[4].split(',').map((p) => parseInt(p.trim(), 10)).filter((p) => !isNaN(p));

        vlans.push({ id, name, type, ports });
      }
    }

    return vlans;
  }
}
