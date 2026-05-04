#!/usr/bin/env bash
# CPU software rendering via llvmpipe/lavapipe

GPU_DRIVER_NAME="lavapipe"
GPU_NEEDS_SERVER=false

gpu_setup_env() {
    export GALLIUM_DRIVER=llvmpipe
    export MESA_GL_VERSION_OVERRIDE="${TDE_GL_VERSION:-4.0}"
    export MESA_GLES_VERSION_OVERRIDE="${TDE_GLES_VERSION:-3.1}"
    local lvp_icds=("${PREFIX}/share/vulkan/icd.d"/lvp_icd.*.json)
    export VK_ICD_FILENAMES="${lvp_icds[0]}"
}

gpu_start_server() { :; }
