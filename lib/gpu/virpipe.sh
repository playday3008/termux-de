#!/usr/bin/env bash
# Software rendering via virpipe (universal fallback)

GPU_DRIVER_NAME="virpipe"
GPU_NEEDS_SERVER=true

gpu_setup_env() {
    export GALLIUM_DRIVER=virpipe
    export MESA_GL_VERSION_OVERRIDE="${TDE_GL_VERSION:-4.0}"
    export MESA_GLES_VERSION_OVERRIDE="${TDE_GLES_VERSION:-3.1}"
    # Lavapipe gives Qt6 a working software Vulkan; blocks turnip/zink from hijacking GL
    local lvp_icds=("${PREFIX}/share/vulkan/icd.d"/lvp_icd.*.json)
    export VK_ICD_FILENAMES="${lvp_icds[0]}"
}

gpu_start_server() {
    process_spawn gpu_server virgl_test_server_android
}
