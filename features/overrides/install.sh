#!/bin/ash
set -e

SCRIPT_DIR="$(readlink -f $(dirname $0))"

cd ${SCRIPT_DIR}

echo "Installing overrides"

# Ensure custom config directory exists
test -d ~/printer_data/config/custom || mkdir -p ~/printer_data/config/custom

# Ensure main.cfg exists
test -f ~/printer_data/config/custom/main.cfg || touch ~/printer_data/config/custom/main.cfg

# this file is intended to be user modified
cp -f ${SCRIPT_DIR}/overrides.cfg ~/printer_data/config/custom/overrides.cfg

python "${SCRIPT_DIR}/../../scripts/ensure_included.py" \
    ~/printer_data/config/custom/main.cfg \
    overrides.cfg \
    False \
    end

echo "Installed overrides"

# Restart Klipper to apply changes
/etc/init.d/klipper restart
