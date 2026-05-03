#!/usr/bin/env bash
# PulseAudio management: start, attach, stop

_PA_OWNED=false

audio_start() {
    local uid
    uid=$(id -u)

    local pa_pid
    pa_pid=$(pgrep -x -U "$uid" pulseaudio 2>/dev/null | head -1 || true)

    if [[ -n "$pa_pid" ]]; then
        # PA running — check if TCP module loaded
        if pactl list modules short 2>/dev/null | grep -q module-native-protocol-tcp; then
            log_info "PulseAudio running with TCP — attaching"
            _PA_OWNED=false
            return 0
        fi
        # Load TCP module into running instance
        log_info "PulseAudio running — loading TCP module"
        pactl load-module module-native-protocol-tcp auth-anonymous=1 >/dev/null 2>&1 \
            || log_warn "Failed to load PulseAudio TCP module"
        _PA_OWNED=false
        return 0
    fi

    # Start fresh PA
    log_info "Starting PulseAudio"
    pulseaudio --start \
        --load="module-native-protocol-tcp auth-anonymous=1" \
        --exit-idle-time=-1 \
        2>/dev/null \
        || die "Failed to start PulseAudio"

    _PA_OWNED=true

    # Record PID
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
