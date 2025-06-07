#!/bin/sh
# Better root directory setup for K2 Plus
# Moves root home directory from small internal storage to larger UDISK partition
# Creates symlinks to make Klipper components accessible in standard locations

set -e  # Exit on any error

move_homedir() {
    # Only perform home directory move once (check if already completed)
    if ! grep -qE 'root.*UDISK' /etc/passwd; then
        echo "Moving root home directory to /mnt/UDISK/root..."
        
        # Create target directory if it doesn't exist
        if [ ! -d /mnt/UDISK/root ]; then
            mkdir /mnt/UDISK/root
        fi
        
        # Move all files from current root home to new location
        rsync --remove-source-files -a /root/ /mnt/UDISK/root/
        
        # Clean up overlay filesystem remnants in original root location
        rm -fr /overlay/upper/root/*
        
        # Update /etc/passwd to point root home to new location
        sed -i 's,/root,/mnt/UDISK/root,' /etc/passwd
        sync  # Ensure filesystem changes are written
    fi
}

link_up() {
    # Create symlinks in root home for standard Klipper components
    echo "Creating symlinks for Klipper components..."
    cd /mnt/UDISK/root
    # Link standard Klipper directories to their system locations
    ln -snf /usr/share/klipper klipper
    ln -snf /usr/share/klippy-env/ klippy-env
    ln -snf /mnt/UDISK/printer_data/ printer_data
    ln -snf /usr/share/moonraker moonraker
    ln -snf /usr/share/moonraker-env moonraker-env
}

aliases() {
    # update aliases
    cat > /etc/profile.d/aliases << EOF
alias grep='grep --color=always'
EOF
}

# Skip if already configured
if grep -qE 'root.*UDISK' /etc/passwd; then
    echo "Better root directory already configured, skipping..."
    exit 0
fi

# Perform the setup
move_homedir
link_up
#aliases

# Terminate current SSH session to force re-login with new environment
echo "I: You must re-login for changes to take effect."
echo "I: please reconnect to continue"
# terminate the SSH session
pgrep dropbear | grep -v "^$(pgrep -o dropbear)$" | xargs kill -9

