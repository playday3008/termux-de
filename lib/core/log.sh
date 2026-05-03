#!/usr/bin/env bash
# Logging functions and ERR trap handler

_LOG_TEE_PID=""

log_info() { printf '[%s] INFO: %s\n' "$(date +%H:%M:%S)" "$*"; }
log_warn() { printf '[%s] WARN: %s\n' "$(date +%H:%M:%S)" "$*" >&2; }
log_error() { printf '[%s] ERROR: %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

die() {
    log_error "$@"
    exit 1
}

init_log() {
    local log_dir="${CONFIG_DIR}/logs"
    mkdir -p "$log_dir"

    LOG_FILE="${log_dir}/$(date +%Y-%m-%dT%H-%M-%S)_${DE_NAME:-unknown}_${GPU_DRIVER_NAME:-unknown}.log"

    exec > >(tee -a "$LOG_FILE") 2>&1
    _LOG_TEE_PID=$!

    trap '_log_err_handler $LINENO "$BASH_COMMAND" $?' ERR

    log_info "Session started: DE=${DE_NAME:-unknown} GPU=${GPU_DRIVER_NAME:-unknown}"

    _log_rotate
}

_log_err_handler() {
    local lineno="$1" cmd="$2" code="$3"
    log_error "line ${lineno}: ${cmd} (exit ${code})"
}

_log_rotate() {
    local log_dir="${CONFIG_DIR}/logs"
    local retention="${TDE_LOG_RETENTION_DAYS:-7}"
    find "$log_dir" -name "*.log" -mtime "+${retention}" -delete 2>/dev/null || true
}

cmd_logs() {
    local log_dir="${CONFIG_DIR}/logs"
    if [[ "${LOGS_TAIL:-false}" == "true" ]]; then
        local latest
        latest=$(find "$log_dir" -name "*.log" -printf '%T@ %p\n' 2>/dev/null \
            | sort -rn | head -1 | cut -d' ' -f2-)
        if [[ -n "${latest:-}" ]]; then
            tail -f "$latest"
        else
            echo "No logs found."
        fi
    else
        local files
        files=$(find "$log_dir" -name "*.log" -printf '%T@ %p\n' 2>/dev/null \
            | sort -rn | head -20 | cut -d' ' -f2-) || true
        if [[ -n "${files:-}" ]]; then
            echo "$files"
        else
            echo "No logs found."
        fi
    fi
}
