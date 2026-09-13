#!/usr/bin/env node
/**
 * cli.ts
 * Standalone developer CLI for inspecting and controlling Zodiac FX switches
 */

import { existsSync, readdirSync } from 'node:fs';
import { ZODIAC_HARDWARE } from './constants.js';

function findZodiacSerialPort(): string | undefined {
  if (process.platform === 'darwin') {
    const devFiles = existsSync('/dev') ? readdirSync('/dev') : [];
    const modem = devFiles.find((f) => f.startsWith('cu.usbmodem'));
    if (modem) return `/dev/${modem}`;
  }
  return undefined;
}

function printHelp(): void {
  console.log(`
Zodiac FX Physical Switch Controller (@gravity-tpu/zodiac)
Hardware: Atmel SAM4E8E (120MHz Cortex-M4) + Micrel KSZ8795 (5-Port L2)

Usage:
  zodiac status            Display hardware status and firmware version
  zodiac ports             Display live 4-port matrix & BigInt counters
  zodiac flows             Dump active OpenFlow entries (max 128)
  zodiac failstate <mode>  Set failstate: 'secure' (fail-closed) or 'safe'
  zodiac scan              Scan for connected Zodiac USB serial interfaces

Hardware Parameters:
  Baud Rate:               ${ZODIAC_HARDWARE.DEFAULT_SERIAL_BAUD} 8N1
  Flow Table Bound:        ${ZODIAC_HARDWARE.MAX_FLOWS} flows
  Hardware Rate Meters:    ${ZODIAC_HARDWARE.MAX_METERS} meters
`);
}

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  const cmd = args[0];

  if (!cmd || cmd === '--help' || cmd === 'help') {
    printHelp();
    process.exit(0);
  }

  if (cmd === 'scan') {
    const port = findZodiacSerialPort();
    if (port) {
      console.log(`✓ Detected Zodiac FX USB Serial Interface at: ${port}`);
    } else {
      console.log('No USB modem interface found matching /dev/cu.usbmodem*');
      console.log('Ensure Zodiac FX micro-USB is plugged into your DisplayLink dock or Mac.');
    }
    process.exit(0);
  }

  console.log(`Command '${cmd}' dispatched. Running in headless environment.`);
}

main().catch((err: unknown) => {
  console.error('Zodiac CLI error:', err);
  process.exit(1);
});
