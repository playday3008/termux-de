#!/usr/bin/env bash
DE_NAME="icewm"
DE_LABEL="IceWM"
DE_HAS_COMPOSITOR=false
DE_REQUIRED_BINS=("icewm-session")
DE_OPTIONAL_BINS=()

de_env() { :; }
de_start() { process_spawn de dbus-run-session icewm-session; }
