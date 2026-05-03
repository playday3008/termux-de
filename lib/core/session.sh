#!/usr/bin/env bash
# Session lock, PID tracking, status, stop

SESSION_PID_FILE="${CONFIG_DIR}/session.pids"

session_acquire_lock() {
    mkdir -p "$CONFIG_DIR"

    # Check for running session via PID file
    if [[ -f "$SESSION_PID_FILE" ]]; then
        local de_pid
        de_pid=$(grep "^de:" "$SESSION_PID_FILE" 2>/dev/null | cut -d: -f2 || true)
        if [[ -n "$de_pid" ]] && kill -0 "$de_pid" 2>/dev/null; then
            die "Session already running (DE PID $de_pid). Use 'termux-de stop' first."
        fi
    fi

    # flock for start atomicity
    local lock_file="${CONFIG_DIR}/launch.lock"
    exec 9>"$lock_file"
    flock -n 9 || die "Another instance is starting. Try again."
}

session_init() {
    local ts
    ts=$(date +%Y-%m-%dT%H:%M:%S)
    {
        printf '# DE=%s GPU=%s LAUNCHER=%s STARTED=%s\n' \
            "${CHOSEN_DE}" "${GPU_DRIVER_NAME}" "$$" "$ts"
        printf 'launcher:%s:single\n' "$$"
    } > "$SESSION_PID_FILE"
}

session_record_pid() {
    local role="$1" pid="$2" type="${3:-single}"
    printf '%s:%s:%s\n' "$role" "$pid" "$type" >> "$SESSION_PID_FILE"
}

_session_kill_pid() {
    local pid="$1" type="$2" sig="${3:-TERM}"
    local -a targets=()
    [[ "$type" == "group" ]] && targets+=("-$pid")
    targets+=("$pid")
    for t in "${targets[@]}"; do
        kill "-${sig}" -- "$t" 2>/dev/null && return 0
    done
    return 0
}

session_status() {
    if [[ ! -f "$SESSION_PID_FILE" ]]; then
        echo "No session running."
        return 1
    fi

    local meta
    meta=$(head -1 "$SESSION_PID_FILE" | sed 's/^# //')
    echo "Session: $meta"

    local total=0 alive=0
    while IFS=: read -r role pid _type; do
        [[ "$role" == \#* || -z "$role" ]] && continue
        (( ++total ))
        if kill -0 "$pid" 2>/dev/null; then
            printf '  %-12s %s (alive)\n' "$role" "$pid"
            (( ++alive ))
        else
            printf '  %-12s %s (dead)\n' "$role" "$pid"
        fi
    done < "$SESSION_PID_FILE"

    if (( alive == 0 )); then
        echo "Session stale — cleaning up."
        rm -f "$SESSION_PID_FILE"
        return 2
    fi

    echo "${alive}/${total} processes alive."
    return 0
}

session_stop() {
    if [[ ! -f "$SESSION_PID_FILE" ]]; then
        echo "No session running."
        return 1
    fi

    echo "Stopping session..."

    # Collect PIDs and types
    local -a pids=() types=()
    while IFS=: read -r role pid type; do
        [[ "$role" == \#* || -z "$role" ]] && continue
        pids+=("$pid")
        types+=("${type:-single}")
    done < "$SESSION_PID_FILE"

    # SIGTERM in reverse order
    local i
    for (( i=${#pids[@]}-1; i>=0; i-- )); do
        if kill -0 "${pids[$i]}" 2>/dev/null; then
            _session_kill_pid "${pids[$i]}" "${types[$i]}"
        fi
    done

    # Grace period
    sleep "${TDE_SHUTDOWN_GRACE_SECS:-2}"

    # SIGKILL survivors
    for (( i=${#pids[@]}-1; i>=0; i-- )); do
        if kill -0 "${pids[$i]}" 2>/dev/null; then
            _session_kill_pid "${pids[$i]}" "${types[$i]}" 9
        fi
    done

    # Restore picom autostart if masked
    if declare -f compositor_restore_autostart >/dev/null 2>&1; then
        compositor_restore_autostart
    else
        local desktop="$HOME/.config/autostart/picom.desktop"
        local backup="${desktop}.tde-backup"
        if [[ -f "$backup" ]]; then
            mv "$backup" "$desktop"
        elif [[ -f "$desktop" ]] && grep -q "Hidden=true" "$desktop" 2>/dev/null; then
            rm -f "$desktop"
        fi
    fi

    rm -f "$SESSION_PID_FILE"
    echo "Session stopped."
}

cleanup_stale() {
    [[ ! -f "$SESSION_PID_FILE" ]] && return 0

    local -a stale_pids=() stale_types=()
    while IFS=: read -r role pid type; do
        [[ "$role" == \#* || -z "$role" ]] && continue
        if kill -0 "$pid" 2>/dev/null; then
            _session_kill_pid "$pid" "${type:-single}"
            stale_pids+=("$pid")
            stale_types+=("${type:-single}")
        fi
    done < "$SESSION_PID_FILE"

    if (( ${#stale_pids[@]} > 0 )); then
        sleep 1
        local i
        for (( i=0; i<${#stale_pids[@]}; i++ )); do
            if kill -0 "${stale_pids[$i]}" 2>/dev/null; then
                _session_kill_pid "${stale_pids[$i]}" "${stale_types[$i]}" 9
            fi
        done
    fi

    rm -f "$SESSION_PID_FILE"
}
