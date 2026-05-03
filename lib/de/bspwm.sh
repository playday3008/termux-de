#!/usr/bin/env bash
DE_NAME="bspwm"
DE_LABEL="bspwm"
DE_HAS_COMPOSITOR=false
DE_REQUIRED_BINS=("bspwm" "sxhkd")
DE_OPTIONAL_BINS=()

de_env() { :; }
de_start() { process_spawn de dbus-run-session bspwm; }
