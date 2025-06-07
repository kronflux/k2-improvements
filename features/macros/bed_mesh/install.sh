#!/bin/ash
set -e

SCRIPT_DIR="$(readlink -f $(dirname $0))"

cd ${SCRIPT_DIR}

echo "Installing bed_mesh"

# Ensure custom config directory exists
test -d ~/printer_data/config/custom || mkdir -p ~/printer_data/config/custom

# Ensure main.cfg exists
test -f ~/printer_data/config/custom/main.cfg || touch ~/printer_data/config/custom/main.cfg

# add the main.cfg to printer.cfg
python ${SCRIPT_DIR}/../../../scripts/ensure_included.py \
    ~/printer_data/config/printer.cfg custom/main.cfg

# add the bed_mesh.cfg
ln -snf ${SCRIPT_DIR}/bed_mesh.cfg \
    ~/printer_data/config/custom/bed_mesh.cfg

# Ensure it is included in custom/main.cfg
python ${SCRIPT_DIR}/../../../scripts/ensure_included.py \
    ~/printer_data/config/custom/main.cfg \
    bed_mesh.cfg

echo "Installed bed_mesh"

# Restart Klipper to apply changes
/etc/init.d/klipper restart
