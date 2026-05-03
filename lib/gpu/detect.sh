#!/usr/bin/env bash
# GPU driver auto-detection

gpu_detect() {
    local egl
    egl=$(getprop ro.hardware.egl 2>/dev/null || true)

    if [[ "${egl,,}" == "adreno" ]]; then
        echo "turnip"
        return 0
    fi

    # Check for hardware Vulkan (not software)
    if command -v vulkaninfo &>/dev/null; then
        local hw_device
        hw_device=$(timeout 5 vulkaninfo --summary 2>/dev/null \
            | grep -i "deviceName" \
            | grep -iv "llvmpipe\|lavapipe\|swrast\|cpu" \
            | head -1 || true)
        if [[ -n "$hw_device" ]]; then
            log_info "Detected hardware Vulkan: $hw_device" >&2
            echo "zink"
            return 0
        fi
    fi

    echo "virpipe"
}
