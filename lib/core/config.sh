#!/usr/bin/env bash
# Config loading: CLI > env > config file > defaults

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/termux-de"

load_config() {
    # Preserve CLI values (highest priority)
    local cli_de="${CHOSEN_DE:-}"
    local cli_driver="${GPU_DRIVER:-}"

    # Built-in defaults
    GPU_DRIVER="auto"
    DISPLAY_NUM=":0"
    TDE_PICOM_CONFIG=""
    TDE_PICOM_EXTRA_ARGS=""
    TDE_LOG_RETENTION_DAYS=7
    TDE_SHUTDOWN_GRACE_SECS=2
    TDE_GL_VERSION=""
    TDE_GLES_VERSION=""

    # Source config file (overrides defaults)
    local config_file="${CONFIG_DIR}/config"
    if [[ -f "$config_file" ]]; then
        # shellcheck source=/dev/null
        source "$config_file"
    fi

    # Apply TDE_ vars from config file
    GPU_DRIVER="${TDE_GPU_DRIVER:-$GPU_DRIVER}"
    DISPLAY_NUM="${TDE_DISPLAY:-$DISPLAY_NUM}"

    # Apply env var overrides (higher than config)
    GPU_DRIVER="${TERMUX_GPU_DRIVER:-$GPU_DRIVER}"

    # Restore CLI values (highest priority)
    [[ -n "$cli_driver" ]] && GPU_DRIVER="$cli_driver"

    # Resolve DE choice: CLI > env > config > last-de > default
    if [[ -n "$cli_de" ]]; then
        CHOSEN_DE="$cli_de"
    elif [[ -n "${TERMUX_DE:-}" ]]; then
        CHOSEN_DE="$TERMUX_DE"
    elif [[ -n "${TDE_DEFAULT_DE:-}" ]]; then
        CHOSEN_DE="$TDE_DEFAULT_DE"
    elif [[ -f "${CONFIG_DIR}/last-de" ]]; then
        CHOSEN_DE=$(<"${CONFIG_DIR}/last-de")
    else
        die "No DE selected. Pass --de=NAME or set a default."
    fi

    # Validate CHOSEN_DE regardless of source
    [[ "$CHOSEN_DE" =~ ^[a-z0-9_-]+$ ]] || die "Invalid DE name: $CHOSEN_DE"

    # Session environment
    export PULSE_SERVER=127.0.0.1
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-${TMPDIR}}"
    export DISPLAY="${DISPLAY_NUM}"

    mkdir -p "$CONFIG_DIR"
}

save_last_de() {
    printf '%s\n' "$CHOSEN_DE" > "${CONFIG_DIR}/last-de"
}
