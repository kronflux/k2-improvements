# Bootstrap Components

This directory contains the bootstrap installation components for K2 Improvements. The bootstrap is a prerequisite that must be installed first before any other K2 improvements can be applied.

## What Bootstrap Does

1. **Installs Entware** - Package manager for additional software on embedded systems
2. **Sets up better root directory** - Moves root home to larger storage partition  
3. **Clones K2 improvements repository** - Downloads the full feature set to the printer

## Structure

```
bootstrap/
├── bootstrap.sh              # Main installation orchestrator
├── entware/                  # Entware package manager setup
│   ├── install.sh           # Entware installation script
│   ├── wget-ssl.py          # Python-based wget with SSL support
│   └── unslung.init         # Service manager with debug logging
└── better-root/             # Root directory relocation
    ├── README.md            # Detailed explanation of root directory changes
    └── install.sh           # Root directory setup script
```

## Installation Process

For complete setup instructions including password change and SSH key setup, see [QUICKSTART.md](../QUICKSTART.md).

Basic installation steps:
1. **Upload via Fluidd**: Extract and upload the bootstrap folder to `/mnt/UDISK/printer_data/config/`
2. **SSH to printer**: Connect as root user
3. **Run bootstrap**: Execute `sh /mnt/UDISK/printer_data/config/bootstrap/bootstrap.sh`
4. **Automatic logout**: System logs you out to refresh environment

## Release Process

Bootstrap releases are automatically created via GitHub Actions when:
1. A tag matching `v*-bootstrap*` is pushed (e.g., `v1.0.0-bootstrap`, `v1.0.0-bootstrap-alpha`)
2. The workflow is manually triggered for testing

### Release Artifacts
- **Tag releases**: `bootstrap-v1.0.0-bootstrap.zip`
- **Manual builds**: `bootstrap-<commit-sha>.zip`
