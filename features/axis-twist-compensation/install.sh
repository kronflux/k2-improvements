#!/bin/ash
set -e

SCRIPT_DIR="$(readlink -f $(dirname $0))"

cd ${SCRIPT_DIR}

echo "Installing axis_twist_compensation"
rm -f /usr/share/klipper/klippy/extras/probe.py*

# symlink these so the user automatically gets updates
ln -snf ${SCRIPT_DIR}/probe.py /usr/share/klipper/klippy/extras/probe.py
ln -snf ${SCRIPT_DIR}/axis_twist_compensation.py /usr/share/klipper/klippy/extras/axis_twist_compensation.py

# Ensure custom config directory exists
test -d ~/printer_data/config/custom || mkdir -p ~/printer_data/config/custom

# Ensure main.cfg exists
test -f ~/printer_data/config/custom/main.cfg || touch ~/printer_data/config/custom/main.cfg

# add the axis_twist_compensation
ln -snf ${SCRIPT_DIR}/axis_twist_compensation.cfg \
    ~/printer_data/config/custom/axis_twist_compensation.cfg

# Ensure it is included in custom/main.cfg
python ${SCRIPT_DIR}/../../scripts/ensure_included.py \
    ~/printer_data/config/custom/main.cfg \
    axis_twist_compensation.cfg

echo "Installed axis_twist_compensation"

# Restart Klipper to apply changes
/etc/init.d/klipper restart
