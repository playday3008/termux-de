#!/usr/bin/env bash
# PulseAudio management: start, attach, stop

_PA_OWNED=false

audio_start() {
    local pa_socket="${XDG_RUNTIME_DIR}/pulse/native"

    if pulseaudio --check 2>/dev/null; then
        if [[ -S "$pa_socket" ]]; then
            log_info "PulseAudio already running — attaching"
            _PA_OWNED=false
            return 0
        fi
        # PA running but socket not at expected path — restart with correct XDG_RUNTIME_DIR
        log_warn "PulseAudio running but socket missing at ${pa_socket} — restarting"
        pulseaudio --kill 2>/dev/null || true
        sleep 0.3
    fi

    log_info "Starting PulseAudio"
    pulseaudio --start --exit-idle-time=-1 2>/dev/null \
        || die "Failed to start PulseAudio"

    _PA_OWNED=true

    local uid pa_pid
    uid=$(id -u)
    pa_pid=$(pgrep -x -U "$uid" pulseaudio 2>/dev/null | head -1 || true)
    if [[ -n "$pa_pid" ]]; then
        # shellcheck disable=SC2154
        MANAGED_PIDS[audio]=$pa_pid
        if declare -f session_record_pid >/dev/null 2>&1; then
            session_record_pid audio "$pa_pid"
        fi
        log_info "PulseAudio started (PID $pa_pid)"
    fi
}

audio_stop() {
    if [[ "$_PA_OWNED" == "true" ]]; then
        log_info "Stopping PulseAudio"
        pulseaudio --kill 2>/dev/null || true
    fi
}
