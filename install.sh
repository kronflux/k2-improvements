#!/bin/ash
set -e

SCRIPT_DIR="$(readlink -f $(dirname $0))"

cd "${SCRIPT_DIR}"

# Parse -nocartographer flag and filter arguments
NO_CARTO="no"
FEATURE_ARGS=""
for arg in "$@"; do
    if [ "$arg" = "-nocartographer" ]; then
        NO_CARTO="yes"
    else
        FEATURE_ARGS="$FEATURE_ARGS $arg"
    fi
done

echo "K2-Improvements - Installation Started"

install_feature() {
    FEATURE=$1
    shift
    "${SCRIPT_DIR}/features/${FEATURE}/install.sh" "$@"
}

ALL_FEATURES="better-init skip-setup moonraker fluidd common-config cartographer axis-twist-compensation screws_tilt_adjust macros/m191 macros/bed_mesh macros/start_print overrides"

mkdir -p /tmp/macros

install_list=""

if [ -z "$(echo $FEATURE_ARGS | xargs)" ]; then
    # No features specified: use ALL_FEATURES
    for FEATURE in $ALL_FEATURES; do
        if [ "$NO_CARTO" = "yes" ] && [ "$FEATURE" = "cartographer" ]; then
            continue
        fi
        install_list="$install_list $FEATURE"
    done
else
    # Use only specified features
    for FEATURE in $FEATURE_ARGS; do
        if [ "$NO_CARTO" = "yes" ] && [ "$FEATURE" = "cartographer" ]; then
            continue
        fi
        install_list="$install_list $FEATURE"
    done
fi

for FEATURE in $install_list; do
    if [ "$FEATURE" = "common-config" ] && [ "$NO_CARTO" = "yes" ]; then
        install_feature "$FEATURE" -nocartographer
    else
        install_feature "$FEATURE"
    fi
done

echo "K2-Improvements - Installation Complete"
