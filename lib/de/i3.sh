#!/usr/bin/env bash
DE_NAME="i3"
DE_LABEL="i3"
DE_HAS_COMPOSITOR=false
DE_REQUIRED_BINS=("i3")
DE_OPTIONAL_BINS=("i3status" "dmenu")

de_env() { :; }
de_start() { process_spawn de dbus-run-session i3; }
