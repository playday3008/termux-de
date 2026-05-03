#!/usr/bin/env bash
# Shared GPU environment setup, orchestration, and validation

gpu_setup_base_env() {
    export MESA_VK_WSI_DEBUG=sw
    export MESA_NO_ERROR=1
    export QT_XCB_GL_INTEGRATION=xcb_glx
    export vblank_mode=0
}

gpu_setup() {
    gpu_setup_base_env
    gpu_setup_env

    if [[ "${GPU_NEEDS_SERVER}" == "true" ]]; then
        gpu_start_server
        _gpu_wait_server
    fi
}

_gpu_wait_server() {
    local socket="${TMPDIR}/.virgl_test"
    local attempt=0

    # Phase 1: 0.1s × 5
    while (( attempt < 5 )); do
        [[ -S "$socket" ]] && { log_info "GPU server socket ready"; return 0; }
        sleep 0.1
        (( ++attempt ))
    done

    # Phase 2: 0.3s × 5
    while (( attempt < 10 )); do
        [[ -S "$socket" ]] && { log_info "GPU server socket ready"; return 0; }
        sleep 0.3
        (( ++attempt ))
    done

    # Phase 3: 0.5s × 10
    while (( attempt < 20 )); do
        [[ -S "$socket" ]] && { log_info "GPU server socket ready"; return 0; }
        sleep 0.5
        (( ++attempt ))
    done

    die "GPU server socket not found after timeout: $socket"
}

gpu_validate() {
    local renderer
    renderer=$(timeout 5 glxinfo 2>/dev/null | grep -i "OpenGL renderer" || true)
    if [[ -z "$renderer" ]]; then
        log_warn "GPU validation: glxinfo returned no renderer"
        return 0
    fi
    log_info "GPU: $renderer"
}
