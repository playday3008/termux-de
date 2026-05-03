#!/usr/bin/env bash
DE_NAME="xfce"
DE_LABEL="XFCE"
DE_HAS_COMPOSITOR=true
DE_REQUIRED_BINS=("xfce4-session")
DE_OPTIONAL_BINS=("xfce4-terminal" "thunar")

de_env() { :; }
de_start() { process_spawn de dbus-run-session xfce4-session; }
