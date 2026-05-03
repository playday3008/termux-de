#!/usr/bin/env bash
DE_NAME="plasma"
DE_LABEL="KDE Plasma"
DE_HAS_COMPOSITOR=true
DE_REQUIRED_BINS=("startplasma-x11" "kwin_x11")
DE_OPTIONAL_BINS=("konsole" "dolphin")

de_env() {
    export XCURSOR_THEME=breeze_cursors
    export XCURSOR_SIZE=24
}

de_start() { process_spawn de dbus-run-session startplasma-x11; }
