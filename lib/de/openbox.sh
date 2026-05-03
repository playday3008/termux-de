#!/usr/bin/env bash
DE_NAME="openbox"
DE_LABEL="Openbox"
DE_HAS_COMPOSITOR=false
DE_REQUIRED_BINS=("openbox")
DE_OPTIONAL_BINS=("obconf")

de_env() { :; }
de_start() { process_spawn de dbus-run-session openbox-session; }
