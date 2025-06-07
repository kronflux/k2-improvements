# Entware Package Manager

## Purpose

Entware is a package management system for embedded devices that provides additional software packages not available in the K2's limited built-in system. It's essential for installing updated versions of Klipper ecosystem components.

## What is Entware

Entware is the modern successor to Optware, designed specifically for embedded Linux systems like routers, NAS devices, and IoT devices. It provides:

- **Package Management**: Install, update, and remove software packages
- **Dependency Resolution**: Automatically handles software dependencies  
- **ARM Architecture Support**: Optimized for ARM processors like the K2's CPU
- **Service Management**: Handles startup/shutdown of installed services

## Why K2 Needs Entware

**K2 Limitations:**
- No built-in package manager (no `apt`, `yum`, or `pacman`)
- Outdated system components (old Klipper, Moonraker, Fluidd)
- Limited software availability
- No easy way to install additional tools

**Entware Provides:**
- Updated Klipper ecosystem components
- Essential development tools (`git`, `curl`, `wget-ssl`)
- Python packages and libraries
- System utilities and debugging tools

## Installation Components

### Core Files

- **`install.sh`** - Main installation script
- **`wget-ssl.py`** - Python-based wget with SSL support (bootstrap tool)
- **`unslung.init`** - Service management daemon with debug logging

### Installation Process

1. **Clean Installation**: Removes any existing `/opt` directories
2. **Directory Setup**: Creates `/mnt/UDISK/opt` and symlinks to `/opt`
3. **Bootstrap Download**: Uses Python wget to download initial packages
4. **Package Manager**: Installs `opkg` (OpenWrt package manager)
5. **Core Packages**: Installs essential tools (git, curl, wget-ssl, etc.)
6. **System Integration**: Configures PATH and service management
7. **Service Setup**: Installs Unslung service manager

### Unslung Service Manager

**What is Unslung:**
- Service management system for Entware packages
- Handles automatic startup/shutdown of installed services
- Waits for storage mounting before starting services
- Provides service lifecycle management

**Debug Features:**
- Logs all activity to `/tmp/unslung.log`
- Debug output shows executed commands
- Status messages for troubleshooting
- Better visibility into service startup issues

## Technical Details

### Storage Layout
```
/opt -> /mnt/UDISK/opt (symlink)
/mnt/UDISK/opt/
├── bin/          # Entware binaries
├── etc/          # Configuration files
├── lib/          # Libraries
├── sbin/         # System binaries
├── tmp/          # Temporary files
└── var/          # Variable data
```

### System Integration
- **PATH Updates**: Adds `/opt/bin:/opt/sbin` to system PATH
- **User Integration**: Links system user/group files
- **Service Management**: Installs startup scripts in `/etc/rc.d/`
- **SFTP Support**: Enables secure file transfer capabilities

### Architecture Details
- **Target**: ARMv7 soft-float (armv7sf-k3.2)
- **GLIBC**: Version 2.29 compatibility
- **Loader**: ld-linux.so.3

## Dependencies

**Required by K2 Improvements:**
- Updated Moonraker installation
- Fluidd web interface updates  
- Cartographer probe software
- Additional Python packages
- Development and debugging tools

**Automatic Installation:**
The bootstrap process handles all Entware installation automatically. Manual installation is not recommended as it requires specific configuration for the K2's embedded environment.

## Post-Installation

After Entware installation:
- New packages can be installed with `/opt/bin/opkg install <package>`
- Services are managed by the Unslung system
- Check `/tmp/unslung.log` for service startup diagnostics
- Entware binaries are available system-wide via PATH updates