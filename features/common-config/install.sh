#!/bin/ash
set -e

SCRIPT_DIR="$(readlink -f $(dirname $0))"

# Default: cartographer present
CARTO="yes"

# Parse arguments for -nocartographer
for arg in "$@"; do
    if [ "$arg" = "-nocartographer" ]; then
        CARTO="no"
    fi
done

# Ensure custom config directory exists
test -d ~/printer_data/config/custom || mkdir -p ~/printer_data/config/custom

# Ensure main.cfg exists
test -f ~/printer_data/config/custom/main.cfg || touch ~/printer_data/config/custom/main.cfg

echo "Installing common-config"


################
##  general   ##
################

# add the main.cfg to printer.cfg
python ${SCRIPT_DIR}/../../scripts/ensure_included.py \
    ~/printer_data/config/printer.cfg \
    custom/main.cfg \
    False \
    end


################
##    box     ##
################

# Copy box.cfg to custom config dir
cp "${SCRIPT_DIR}/box.cfg" ~/printer_data/config/custom/

# Remove the stock box.cfg file
rm ~/printer_data/config/box.cfg

# Symlink the custom box.cfg to the stock location
ln -snf ~/printer_data/config/box.cfg \
    ~/printer_data/config/custom/box.cfg

# Remove box.cfg config section from printer.cfg
python "${SCRIPT_DIR}/../../scripts/alter_config.py" -section "include box.cfg"

# Add box.cfg custom config location to printer.cfg
python "${SCRIPT_DIR}/../../scripts/ensure_included.py" \
    ~/printer_data/config/printer.cfg \
    custom/box.cfg \
    False \
    after \
    "[include printer_params.cfg]"


################
## prtouch_v3 ##
################

# Copy prtouch_v3.cfg to custom config dir
cp "${SCRIPT_DIR}/prtouch_v3.cfg" ~/printer_data/config/custom/

# Remove prtouch_v3 sections from printer.cfg
python "${SCRIPT_DIR}/../../scripts/alter_config.py" -section "prtouch_v3"

# Ensure prtouch_v3 is included in custom/main.cfg and determine whether it should be commented out or not
if [ "$CARTO" = "no" ]; then
    # Add regular include (no True flag)
    python "${SCRIPT_DIR}/../../scripts/ensure_included.py" \
        ~/printer_data/config/custom/main.cfg \
        prtouch_v3.cfg
else
    # Add commented include (with True flag)
    python "${SCRIPT_DIR}/../../scripts/ensure_included.py" \
        ~/printer_data/config/custom/main.cfg \
        prtouch_v3.cfg \
        True
fi

echo "Installed common-config"

# Restart Klipper to apply changes
/etc/init.d/klipper restart
