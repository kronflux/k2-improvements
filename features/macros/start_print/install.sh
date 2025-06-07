#!/bin/ash
set -e

SCRIPT_DIR="$(readlink -f $(dirname $0))"

cd ${SCRIPT_DIR}

echo "Installing start_print"

# Ensure custom config directory exists
test -d ~/printer_data/config/custom || mkdir -p ~/printer_data/config/custom

# Ensure main.cfg exists
test -f ~/printer_data/config/custom/main.cfg || touch ~/printer_data/config/custom/main.cfg

# add the start_print.cfg
ln -snf ${SCRIPT_DIR}/start_print.cfg \
    ~/printer_data/config/custom/start_print.cfg

# Ensure it is included in custom/main.cfg
python ${SCRIPT_DIR}/../../../scripts/ensure_included.py \
    ~/printer_data/config/custom/main.cfg \
    start_print.cfg

echo "Installed start_print"

# Restart Klipper to apply changes
/etc/init.d/klipper restart
