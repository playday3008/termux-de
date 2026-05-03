#!/usr/bin/env bash
DE_NAME="lxqt"
DE_LABEL="LXQt"
DE_HAS_COMPOSITOR=false
DE_REQUIRED_BINS=("startlxqt")
DE_OPTIONAL_BINS=("qterminal" "pcmanfm-qt")

de_env() { :; }
de_start() { process_spawn de dbus-run-session startlxqt; }
