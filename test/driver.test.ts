import { describe, it, expect } from 'vitest';
import { ZodiacDriver, type SerialTransport } from '../src/driver.js';

class MockSerialTransport implements SerialTransport {
  public sent: string[] = [];
  public responses: Map<string, string> = new Map();

  constructor() {
    this.responses.set('exit', 'Zodiac_FX#');
    this.responses.set('config', 'Zodiac_FX (config)#');
    this.responses.set('openflow', 'Zodiac_FX (openflow)#');
    this.responses.set('show status', 'Device Name: Zodiac_FX\r\nFailstate: secure\r\nActive Flows: 1\r\nZodiac_FX#');
    this.responses.set('show ports', 'Port 1:\r\n  Status: UP\r\n  RX Packets: 100\r\nZodiac_FX#');
    this.responses.set('show flows', 'Flow 0:\r\n  Packet Count: 50\r\n  Byte Count: 3000\r\nZodiac_FX (openflow)#');
    this.responses.set('set failstate secure', 'Zodiac_FX (config)#');
    this.responses.set('save', 'Configuration saved.\r\nZodiac_FX (config)#');
    this.responses.set('clear flows', 'Flows cleared.\r\nZodiac_FX (openflow)#');
  }

  public async write(data: string): Promise<void> {
    this.sent.push(data.trim());
  }

  public async readUntil(_pattern: RegExp, _timeoutMs?: number): Promise<string> {
    const lastCmd = this.sent[this.sent.length - 1] ?? '';
    return this.responses.get(lastCmd) ?? 'Zodiac_FX#';
  }

  public async close(): Promise<void> {}
}

describe('ZodiacDriver (Context State Machine & Commands)', () => {
  it('manages context switching deterministically', async () => {
    const transport = new MockSerialTransport();
    const driver = new ZodiacDriver(transport);

    expect(driver.context).toBe('base');

    await driver.switchContext('config');
    expect(driver.context).toBe('config');
    expect(transport.sent).toContain('config');

    await driver.switchContext('openflow');
    expect(driver.context).toBe('openflow');
    expect(transport.sent).toContain('exit');
    expect(transport.sent).toContain('openflow');
  });

  it('queries status and preserves fail-closed invariant', async () => {
    const transport = new MockSerialTransport();
    const driver = new ZodiacDriver(transport);

    const status = await driver.getStatus();
    expect(status.name).toBe('Zodiac_FX');
    expect(status.failstate).toBe('secure');
  });

  it('sets failstate and saves to EEPROM non-volatile memory', async () => {
    const transport = new MockSerialTransport();
    const driver = new ZodiacDriver(transport);

    await driver.setFailstate('secure');

    expect(transport.sent).toContain('config');
    expect(transport.sent).toContain('set failstate secure');
    expect(transport.sent).toContain('save');
    expect(driver.context).toBe('base');
  });
});
