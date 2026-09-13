/**
 * constants.ts
 * Physical hardware bounds and defaults for Northbound Networks Zodiac FX
 */

export const ZODIAC_HARDWARE = {
  // Processor: Atmel / Microchip SAM4E8E (ARM Cortex-M4 @ 120 MHz)
  MCU: 'SAM4E8E',
  MCU_FREQ_MHZ: 120,

  // Switch IC: Micrel / Microchip KSZ8795CLX
  SWITCH_IC: 'KSZ8795CLX',

  // Bounded Hardware Capacities
  MAX_PORTS: 4,
  MAX_FLOWS: 128,
  MAX_VLANS: 4,
  MAX_METERS: 8,
  MAX_METER_BANDS_PER_METER: 3,
  MAX_GROUPS: 8,
  MAX_GROUP_BUCKETS: 32,

  // Default Network Configurations
  DEFAULT_IP: '10.0.1.99',
  DEFAULT_NETMASK: '255.255.255.0',
  DEFAULT_GATEWAY: '10.0.1.1',
  DEFAULT_CONTROLLER_IP: '10.0.1.8',
  DEFAULT_OF_PORT: 6633,

  // Serial Management Configuration
  DEFAULT_SERIAL_BAUD: 115200,
  SERIAL_DATA_BITS: 8,
  SERIAL_STOP_BITS: 1,
  SERIAL_PARITY: 'none' as const,

  // Default Port Roles
  PORT_ROLES: {
    PORT_1: { id: 1, defaultVlan: 100, type: 'openflow' as const, desc: 'Data Plane 1' },
    PORT_2: { id: 2, defaultVlan: 100, type: 'openflow' as const, desc: 'Data Plane 2' },
    PORT_3: { id: 3, defaultVlan: 100, type: 'openflow' as const, desc: 'Data Plane 3 / Tap' },
    PORT_4: { id: 4, defaultVlan: 200, type: 'native' as const, desc: 'Native Controller Management' },
  },

  // OpenFlow Wire Protocols Supported
  OFP_VERSIONS: {
    AUTO: 0,
    OFP_10: 1, // OpenFlow 1.0 (0x01)
    OFP_13: 4, // OpenFlow 1.3 (0x04)
  },
} as const;
