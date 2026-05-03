#!/usr/bin/env bash
DE_NAME="fluxbox"
DE_LABEL="Fluxbox"
DE_HAS_COMPOSITOR=false
DE_REQUIRED_BINS=("startfluxbox")
DE_OPTIONAL_BINS=()

de_env() { :; }
de_start() { process_spawn de dbus-run-session startfluxbox; }
