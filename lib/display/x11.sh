#!/usr/bin/env bash
# Termux X11 display server

display_start() {
    local display="${DISPLAY:-:0}"
    local num="${display#:}"

    # Clean stale socket
    rm -f "${TMPDIR}/.X11-unix/X${num}" 2>/dev/null || true

    process_spawn display termux-x11 "$display"

    # Launch Android activity (non-fatal)
    am start --user 0 \
        -n com.termux.x11/com.termux.x11.MainActivity \
        >/dev/null 2>&1 \
        || log_warn "Could not launch Termux:X11 app"
}

display_wait_ready() {
    local display="${DISPLAY:-:0}"
    local attempt=0

    # Phase 1: fast poll 0.1s × 10
    while (( attempt < 10 )); do
        xdpyinfo -display "$display" &>/dev/null && return 0
        sleep 0.1
        (( ++attempt ))
    done

    # Phase 2: slow poll 0.5s × 20
    while (( attempt < 30 )); do
        xdpyinfo -display "$display" &>/dev/null && return 0
        sleep 0.5
        (( ++attempt ))
    done

    die "Display server not ready after ${attempt} attempts"
}

display_stop() {
    process_kill display
}
