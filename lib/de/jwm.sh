#!/usr/bin/env bash
DE_NAME="jwm"
DE_LABEL="JWM"
DE_HAS_COMPOSITOR=false
DE_REQUIRED_BINS=("jwm")
DE_OPTIONAL_BINS=()

de_env() { :; }
de_start() { process_spawn de dbus-run-session jwm; }
