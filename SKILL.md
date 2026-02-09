---
name: kasa
description: Control TP-Link Kasa smart plugs, switches, and bulbs locally. Use for turning devices on/off, checking status, and discovering Kasa devices on the network.
---

# Kasa (TP-Link)

Control TP-Link Kasa smart home devices locally via `python-kasa`.

## Requirements

- Python 3.8+
- Kasa devices on the same network

## Setup

```bash
pip3 install python-kasa
```

## Quick Start

### Discover devices

```bash
{baseDir}/scripts/kasa.sh discover
```

### Control a device

```bash
# By IP
{baseDir}/scripts/kasa.sh 192.168.1.100 on
{baseDir}/scripts/kasa.sh 192.168.1.100 off
{baseDir}/scripts/kasa.sh 192.168.1.100 status

# By name (after adding to config)
{baseDir}/scripts/kasa.sh "Bedroom fan" on
{baseDir}/scripts/kasa.sh "Bedroom fan" off
```

### Toggle

```bash
{baseDir}/scripts/kasa.sh 192.168.1.100 toggle
```

## Configuration

Known devices are saved in `{baseDir}/config/devices.json` (auto-updated by `discover`):

```json
{
  "Bedroom fan": "192.168.68.51",
  "Living room lamp": "192.168.68.52"
}
```

## Finding Device IPs

1. Check your router's DHCP client list
2. Use `kasa discover` command
3. Check the Kasa app: Device → Settings → Device Info (look for MAC, match in router)

## Supported Devices

- EP10, EP25 (Smart Plugs)
- HS100, HS103, HS105 (Smart Plugs)
- HS200, HS210, HS220 (Smart Switches)
- KL50, KL60, KL110, KL130 (Smart Bulbs)
- KS200, KS220, KS230 (Smart Switches)
- And more...

## Troubleshooting

**"Device not found"** — Newer devices may require credentials:
```bash
{baseDir}/scripts/kasa.sh discover --username you@email.com --password yourpass
```

**"Timeout"** — Check device IP, ensure it's on the same network
