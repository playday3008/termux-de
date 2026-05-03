#!/usr/bin/env bash
# Generic hardware Vulkan via Zink GL translation

GPU_DRIVER_NAME="zink"
GPU_NEEDS_SERVER=false

gpu_setup_env() {
    if command -v vulkaninfo &>/dev/null; then
        if ! timeout 3 vulkaninfo --summary 2>/dev/null | grep -qi "deviceName"; then
            log_warn "No Vulkan device found — zink may fall back to software rendering"
        fi
    else
        log_warn "vulkaninfo not available — cannot verify Vulkan support for zink"
    fi

    export GALLIUM_DRIVER=zink
    export ZINK_DESCRIPTORS=lazy
    export MESA_GL_VERSION_OVERRIDE="${TDE_GL_VERSION:-4.3COMPAT}"
    export MESA_GLES_VERSION_OVERRIDE="${TDE_GLES_VERSION:-3.2}"
}

gpu_start_server() { :; }
