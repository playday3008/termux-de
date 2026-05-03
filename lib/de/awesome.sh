#!/usr/bin/env bash
DE_NAME="awesome"
DE_LABEL="awesome"
DE_HAS_COMPOSITOR=false
DE_REQUIRED_BINS=("awesome")
DE_OPTIONAL_BINS=()

de_env() { :; }
de_start() { process_spawn de dbus-run-session awesome; }
