#!/bin/ash
set -e

SCRIPT_DIR=$(readlink -f $(dirname ${0}))

cd ${HOME}

export TMPDIR=/mnt/UDISK/tmp

if [ ! -d cartographer-klipper/.git ]; then
    if [ -d cartographer-klipper ]; then
        rm -rf cartographer-klipper
    fi
    git clone https://github.com/kronflux/cartographer-klipper.git
    git -C cartographer-klipper checkout k2
fi

if [ -L klippy-env ]; then
    echo "I: moving klippy-env to /mnt/UDISK/root"
    # move lippy-env to /mnt/UDISK
    rm -f klippy-env
    rsync -SHa /usr/share/klippy-env/ klippy-env/
fi

#TODO: how do we detect if we should upgrade?
upgrade_pip() {
    echo "I: upgrading klippy-env pip version"
    wget https://bootstrap.pypa.io/get-pip.py
    ~/klippy-env/bin/python3 ./get-pip.py
    rm -f ./get-pip.py
}
upgrade_pip

# ensure we are pulling wheels from piwheels
if ! grep -q 'extra-index-url=https://www.piwheels.org/simple' /etc/pip.conf; then
    echo 'extra-index-url=https://www.piwheels.org/simple' >> /etc/pip.conf
fi

# install requirements
echo "I: installing cartographer requirements"
~/klippy-env/bin/pip \
    install \
    --upgrade \
    --requirement cartographer-klipper/requirements.txt

# fix the klippy-env libraries
python3 ${SCRIPT_DIR}/../../scripts/fix_venv.py ~/klippy-env

# drop missing libraries in place
echo "I: installing cartographer libraries"
cp ${SCRIPT_DIR}/*.so* /usr/lib/

# install cartographer
echo "I: installing cartographer"
~/cartographer-klipper/install.sh

# install usb-serial bridge
mkdir -p /mnt/UDISK/bin
ln -snf  ${SCRIPT_DIR}/usb_bridge /mnt/UDISK/bin/usb_bridge
chmod +x /mnt/UDISK/bin/usb_bridge
ln -snf ${SCRIPT_DIR}/cartographer.sh /mnt/UDISK/bin/cartographer.sh
ln -snf ${SCRIPT_DIR}/cartographer.init /etc/init.d/cartographer
ln -snf ${SCRIPT_DIR}/cartographer.init /opt/etc/init.d/S50cartographer
/etc/init.d/cartographer start

# install cartographer convenience scripts
ln -snf ${SCRIPT_DIR}/cartographer.sh /mnt/UDISK/bin/cartographer.sh
chmod +x /mnt/UDISK/bin/cartographer.sh

# Ensure custom config directory exists
test -d ~/printer_data/config/custom || mkdir -p ~/printer_data/config/custom

# Ensure main.cfg exists
test -f ~/printer_data/config/custom/main.cfg || touch ~/printer_data/config/custom/main.cfg

# I believe I still want this as a true copy
# add the cartographer.cfg
cp ${SCRIPT_DIR}/cartographer.cfg ~/printer_data/config/custom

# Ensure it is included in custom/main.cfg
python ${SCRIPT_DIR}/../../scripts/ensure_included.py \
    ~/printer_data/config/custom/main.cfg \
    cartographer.cfg

# make this a patch
cd ~/klipper/klippy/extras
patch < ${SCRIPT_DIR}/homing.patch
rm -f klipper/klippy/extras/homing.pyc
cd -

# replace the bed mesh
rm -fr ~/klipper/klippy/extras/bed_mesh.py*
ln -snf ${SCRIPT_DIR}/bed_mesh.py ~/klipper/klippy/extras/bed_mesh.py

# restart klipper
/etc/init.d/klipper restart
