#!/usr/bin/env bash
DE_NAME="fvwm"
DE_LABEL="FVWM"
DE_HAS_COMPOSITOR=false
DE_REQUIRED_BINS=("fvwm")
DE_OPTIONAL_BINS=()

de_env() { :; }
de_start() { process_spawn de dbus-run-session fvwm; }
