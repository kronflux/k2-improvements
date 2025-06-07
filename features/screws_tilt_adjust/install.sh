#!/bin/ash
set -e

SCRIPT_DIR="$(readlink -f $(dirname $0))"

cd ${SCRIPT_DIR}

echo "Installing screws_tilt_adjust"

# Ensure custom config directory exists
test -d ~/printer_data/config/custom || mkdir -p ~/printer_data/config/custom

# Ensure main.cfg exists
test -f ~/printer_data/config/custom/main.cfg || touch ~/printer_data/config/custom/main.cfg

# add the screws_tilt_adjust.py to klippy extras
ln -snf ${SCRIPT_DIR}/screws_tilt_adjust.py \
    ~/klipper/klippy/extras/screws_tilt_adjust.py

# add the screws_tilt_adjust.cfg
ln -snf ${SCRIPT_DIR}/screws_tilt_adjust.cfg \
    ~/printer_data/config/custom/screws_tilt_adjust.cfg

# Ensure it is included in custom/main.cfg
python ${SCRIPT_DIR}/../../scripts/ensure_included.py \
    ~/printer_data/config/custom/main.cfg \
    screws_tilt_adjust.cfg

echo "Installed screws_tilt_adjust"

# Restart Klipper to apply changes
/etc/init.d/klipper restart
