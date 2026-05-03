#!/usr/bin/env bash
# Picom compositor: start, autostart mask/restore

_PICOM_MASKED=false

compositor_start() {
    local has_picom=false
    command -v picom &>/dev/null && has_picom=true

    # Mask autostart regardless — prevents XDG conflict with built-in compositors
    [[ "$has_picom" == "true" ]] && compositor_mask_autostart

    [[ "${DE_HAS_COMPOSITOR:-true}" == "true" ]] && return 0

    if [[ "$has_picom" != "true" ]]; then
        log_warn "picom not found — running without compositor"
        return 0
    fi

    local -a args=()
    if [[ -n "${TDE_PICOM_CONFIG:-}" ]] && [[ -f "${TDE_PICOM_CONFIG}" ]]; then
        args+=(--config "${TDE_PICOM_CONFIG}")
    fi
    if [[ -v TDE_PICOM_ARGS ]]; then
        args+=("${TDE_PICOM_ARGS[@]}")
    elif [[ -n "${TDE_PICOM_EXTRA_ARGS:-}" ]]; then
        local -a extra
        read -ra extra <<< "${TDE_PICOM_EXTRA_ARGS}"
        args+=("${extra[@]}")
    fi

    process_spawn compositor picom "${args[@]}"

    # Verify picom didn't crash immediately
    sleep 0.3
    local pid="${MANAGED_PIDS[compositor]:-}"
    if [[ -n "$pid" ]] && ! kill -0 "$pid" 2>/dev/null; then
        log_warn "picom exited immediately"
        unset "MANAGED_PIDS[compositor]"
        unset "MANAGED_PGIDS[compositor]"
    fi
}

compositor_mask_autostart() {
    local desktop="$HOME/.config/autostart/picom.desktop"

    if [[ -f "$desktop" ]]; then
        if ! cp "$desktop" "${desktop}.tde-backup"; then
            log_warn "Could not backup picom autostart — skipping mask"
            return 0
        fi
    fi

    mkdir -p "$(dirname "$desktop")"
    printf '[Desktop Entry]\nHidden=true\n' > "$desktop"
    _PICOM_MASKED=true
}

compositor_restore_autostart() {
    [[ "$_PICOM_MASKED" != "true" ]] && return 0

    local desktop="$HOME/.config/autostart/picom.desktop"
    local backup="${desktop}.tde-backup"

    if [[ -f "$backup" ]]; then
        mv "$backup" "$desktop"
    elif [[ -f "$desktop" ]] && grep -q "Hidden=true" "$desktop" 2>/dev/null; then
        rm -f "$desktop"
    fi
    _PICOM_MASKED=false
}
