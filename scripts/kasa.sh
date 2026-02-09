#!/usr/bin/env bash
# Kasa device control script
set -e

CONFIG_DIR="${HOME}/.openclaw/integrations/kasa"
DEVICES_FILE="${CONFIG_DIR}/devices.json"

# Ensure config dir exists
mkdir -p "$CONFIG_DIR"

# Create empty devices file if not exists
if [ ! -f "$DEVICES_FILE" ]; then
    echo '{}' > "$DEVICES_FILE"
fi

# Activate venv if it exists (python-kasa may also be installed globally)
if [ -f "${HOME}/.openclaw/venvs/kasa/bin/activate" ]; then
    source "${HOME}/.openclaw/venvs/kasa/bin/activate"
fi

python3 << EOF
import asyncio
import json
import sys
from pathlib import Path

args = "$@".split()

if not args:
    print("Usage: kasa.sh discover | <device_name_or_ip> [on|off|toggle|status]")
    sys.exit(1)

DEVICES_FILE = Path("$DEVICES_FILE")

def load_devices():
    if DEVICES_FILE.exists():
        return json.loads(DEVICES_FILE.read_text())
    return {}

def save_devices(devices):
    DEVICES_FILE.write_text(json.dumps(devices, indent=2))

def resolve_device(name_or_ip):
    """Resolve device name to IP"""
    devices = load_devices()
    # Check if it's a known name
    if name_or_ip in devices:
        return devices[name_or_ip]
    # Check if it looks like an IP
    if name_or_ip.replace('.', '').isdigit():
        return name_or_ip
    # Try case-insensitive match
    for name, ip in devices.items():
        if name.lower() == name_or_ip.lower():
            return ip
    return None

async def discover():
    from kasa import Discover
    print("Discovering Kasa devices...")
    devices = await Discover.discover(timeout=10)
    
    if not devices:
        print("No devices found. Try with credentials:")
        print("  kasa.sh discover --username EMAIL --password PASS")
        return
    
    known = load_devices()
    for ip, dev in devices.items():
        await dev.update()
        print(f"  {dev.alias}: {dev.model} @ {ip} ({'ON' if dev.is_on else 'OFF'})")
        known[dev.alias] = ip
    
    save_devices(known)
    print(f"\nSaved {len(known)} devices to {DEVICES_FILE}")

async def control(ip, action):
    from kasa import Discover
    dev = await Discover.discover_single(ip, timeout=10)
    
    if action == "on":
        await dev.turn_on()
        print(f"{dev.alias} turned ON")
    elif action == "off":
        await dev.turn_off()
        print(f"{dev.alias} turned OFF")
    elif action == "toggle":
        if dev.is_on:
            await dev.turn_off()
            print(f"{dev.alias} turned OFF")
        else:
            await dev.turn_on()
            print(f"{dev.alias} turned ON")
    elif action == "status":
        print(f"{dev.alias}: {'ON' if dev.is_on else 'OFF'}")
    else:
        print(f"Unknown action: {action}")

async def main():
    cmd = args[0]
    
    if cmd == "discover":
        await discover()
    else:
        ip = resolve_device(cmd)
        if not ip:
            print(f"Device '{cmd}' not found. Run 'kasa.sh discover' first.")
            sys.exit(1)
        
        action = args[1] if len(args) > 1 else "status"
        await control(ip, action)

asyncio.run(main())
EOF
