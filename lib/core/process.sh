#!/usr/bin/env bash
# Process group management: spawn, kill, shutdown

declare -A MANAGED_PIDS=()
declare -A MANAGED_PGIDS=()

process_spawn() {
    local role="$1"; shift
    local svc_log="${CONFIG_DIR}/logs/${role}.log"
    setsid "$@" 9<&- >"$svc_log" 2>&1 &
    local pid=$!
    MANAGED_PIDS[$role]=$pid
    MANAGED_PGIDS[$role]=$pid
    if declare -f session_record_pid >/dev/null 2>&1; then
        session_record_pid "$role" "$pid" group
    fi
    log_info "Started $role (PID $pid)"
}

process_kill() {
    local role="$1"
    local pgid="${MANAGED_PGIDS[$role]:-}"
    local pid="${MANAGED_PIDS[$role]:-}"
    [[ -z "$pid" ]] && return 0

    log_info "Stopping $role (PID $pid)"

    # SIGTERM to process group
    if [[ -n "$pgid" ]]; then
        kill -- -"$pgid" 2>/dev/null || true
    else
        kill "$pid" 2>/dev/null || true
    fi

    # Poll until dead or grace period expires
    local grace="${TDE_SHUTDOWN_GRACE_SECS:-2}"
    local max_checks=$(( grace * 5 ))
    local checks=0
    while kill -0 "$pid" 2>/dev/null && (( checks < max_checks )); do
        sleep 0.2
        (( ++checks ))
    done

    # SIGKILL if still alive
    if kill -0 "$pid" 2>/dev/null; then
        log_warn "$role did not exit gracefully, sending SIGKILL"
        if [[ -n "$pgid" ]]; then
            kill -9 -- -"$pgid" 2>/dev/null || true
        fi
        kill -9 "$pid" 2>/dev/null || true
    fi

    unset "MANAGED_PIDS[$role]"
    unset "MANAGED_PGIDS[$role]"
}

shutdown() {
    [[ "${_SHUTDOWN_DONE:-}" == "true" ]] && return 0
    _SHUTDOWN_DONE=true

    log_info "Shutting down session"

    # Stop in reverse launch order, using module stop functions when available
    [[ -n "${MANAGED_PIDS[de]:-}" ]] && process_kill de
    [[ -n "${MANAGED_PIDS[compositor]:-}" ]] && process_kill compositor

    if declare -f display_stop >/dev/null 2>&1; then
        display_stop
    elif [[ -n "${MANAGED_PIDS[display]:-}" ]]; then
        process_kill display
    fi

    [[ -n "${MANAGED_PIDS[gpu_server]:-}" ]] && process_kill gpu_server

    if declare -f audio_stop >/dev/null 2>&1; then
        audio_stop
    elif [[ -n "${MANAGED_PIDS[audio]:-}" ]]; then
        process_kill audio
    fi

    # Restore picom autostart if masked
    if declare -f compositor_restore_autostart >/dev/null 2>&1; then
        compositor_restore_autostart
    fi

    # Release flock
    exec 9>&- 2>/dev/null || true

    rm -f "${SESSION_PID_FILE:-}"
    log_info "Session ended"

    # Flush tee process so final log lines aren't lost
    if [[ -n "${_LOG_TEE_PID:-}" ]] && kill -0 "${_LOG_TEE_PID}" 2>/dev/null; then
        exec >/dev/null 2>/dev/null
        wait "${_LOG_TEE_PID}" 2>/dev/null || true
    fi
}
