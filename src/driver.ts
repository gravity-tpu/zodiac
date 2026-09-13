/**
 * driver.ts
 * Deterministic serial transport and context state machine for Zodiac FX
 *
 * Implements context-aware command dispatching:
 * - base: show status, show ports, restart
 * - config: show config, set failstate <secure|safe>, show vlans
 * - openflow: show status, show flows, show meters, clear flows
 */

import { ZodiacCliParser } from './parser.js';
import type {
  ZodiacCliContext,
  ZodiacDeviceStatus,
  ZodiacFailstate,
  ZodiacFlowEntry,
  ZodiacPortStats,
} from './types.js';

export interface SerialTransport {
  write(data: string): Promise<void>;
  readUntil(pattern: RegExp, timeoutMs?: number): Promise<string>;
  close(): Promise<void>;
}

export class ZodiacDriver {
  private currentContext: ZodiacCliContext = 'base';

  constructor(private readonly transport: SerialTransport) {}

  public get context(): ZodiacCliContext {
    return this.currentContext;
  }

  /**
   * Transitions the CLI context (base, config, openflow, debug).
   */
  public async switchContext(target: ZodiacCliContext): Promise<void> {
    if (this.currentContext === target) return;

    if (this.currentContext !== 'base') {
      await this.sendCommand('exit');
      this.currentContext = 'base';
    }

    if (target !== 'base') {
      await this.sendCommand(target);
      this.currentContext = target;
    }
  }

  /**
   * Executes a command string and waits for the prompt to return.
   */
  public async sendCommand(cmd: string, timeoutMs = 3000): Promise<string> {
    await this.transport.write(cmd.trim() + '\r\n');
    // Prompt ends with '#' e.g. "Zodiac_FX#" or "Zodiac_FX (config)#"
    const response = await this.transport.readUntil(/#\s*$/, timeoutMs);
    return response;
  }

  /**
   * Queries hardware status (`show status`).
   */
  public async getStatus(): Promise<ZodiacDeviceStatus> {
    await this.switchContext('base');
    const raw = await this.sendCommand('show status');
    return ZodiacCliParser.parseStatus(raw);
  }

  /**
   * Queries 4-port hardware states and statistics (`show ports`).
   */
  public async getPorts(): Promise<ZodiacPortStats[]> {
    await this.switchContext('base');
    const raw = await this.sendCommand('show ports');
    return ZodiacCliParser.parsePorts(raw);
  }

  /**
   * Queries active OpenFlow flows in the 128-entry table (`show flows`).
   */
  public async getFlows(): Promise<ZodiacFlowEntry[]> {
    await this.switchContext('openflow');
    const raw = await this.sendCommand('show flows');
    return ZodiacCliParser.parseFlows(raw);
  }

  /**
   * Sets the failstate policy (secure = fail-closed, safe = retain active flows).
   */
  public async setFailstate(mode: ZodiacFailstate): Promise<void> {
    await this.switchContext('config');
    await this.sendCommand(`set failstate ${mode}`);
    await this.sendCommand('save');
    await this.switchContext('base');
  }

  /**
   * Clears the hardware flow table.
   */
  public async clearFlows(): Promise<void> {
    await this.switchContext('openflow');
    await this.sendCommand('clear flows');
    await this.switchContext('base');
  }

  /**
   * Restarts the Zodiac FX device.
   */
  public async restart(): Promise<void> {
    await this.switchContext('base');
    await this.transport.write('restart\r\n');
  }
}
