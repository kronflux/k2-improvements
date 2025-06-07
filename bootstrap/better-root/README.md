# Better Root Directory

## Purpose

The K2 Plus has a small internal filesystem (~220MB) where the default `root` home directory resides. This creates storage limitations for installing additional software and components.

This component relocates the root home directory to the larger `/mnt/UDISK` partition and creates the standard Klipper directory structure that most 3D printer software expects.

## Problem

**Default K2 layout:**
- Root home: `/root` (on small internal storage)
- Limited space for additional software
- Non-standard directory structure for Klipper ecosystem

**Standard Klipper printer layout:**
```sh
$ ls -1
crowsnest
fluidd
fluidd-config
kiauh
kiauh-backups
klipper
klippy-env
moonraker
moonraker-env
printer_data
```

## Solution

**After better-root installation:**
```sh
$ ls -1 /mnt/UDISK/root
klipper -> /usr/share/klipper
klippy-env -> /usr/share/klippy-env/
moonraker -> /usr/share/moonraker
moonraker-env -> /usr/share/moonraker-env
printer_data -> /mnt/UDISK/printer_data/
k2-improvements/
```

## What it does

1. **Moves root home directory** from `/root` to `/mnt/UDISK/root`
2. **Updates system configuration** (`/etc/passwd`) to reflect new location
3. **Creates symlinks** to standard Klipper components in expected locations
4. **Preserves existing files** by moving (not copying) all content
5. **Forces re-login** to activate the new environment

## Technical Details

- Uses `rsync --remove-source-files` to safely move all existing content
- Updates `/etc/passwd` to change root's home directory
- Cleans up overlay filesystem remnants from original location
- Creates symlinks to system-installed Klipper components
- Only runs once (skips if already configured)

## Why This Matters

This setup is **required** for most K2 improvements because:
- Software expects to find components in the user's home directory
- Provides sufficient storage space for additional packages
- Maintains compatibility with standard Klipper installation scripts
- Enables proper separation between system and user components

## Installation Effect

After running `install.sh`, you will be automatically logged out. This is necessary because:
- The shell session needs to reload with the new `$HOME` environment
- Path variables and working directory need to be updated
- Ensures all subsequent commands use the correct home directory
