#!/usr/bin/env bash
DE_NAME="mate"
DE_LABEL="MATE"
DE_HAS_COMPOSITOR=true
DE_REQUIRED_BINS=("mate-session")
DE_OPTIONAL_BINS=("mate-terminal" "caja")

de_env() { :; }
de_start() { process_spawn de dbus-run-session mate-session; }
