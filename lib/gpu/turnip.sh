#!/usr/bin/env bash
# Adreno GPU via Turnip Vulkan + Zink GL translation

GPU_DRIVER_NAME="turnip"
GPU_NEEDS_SERVER=false

gpu_setup_env() {
    export MESA_LOADER_DRIVER_OVERRIDE=zink
    export GALLIUM_DRIVER=zink
    export ZINK_DESCRIPTORS=lazy
    export TU_DEBUG=noconform
    export MESA_GL_VERSION_OVERRIDE="${TDE_GL_VERSION:-4.3COMPAT}"
    export MESA_GLES_VERSION_OVERRIDE="${TDE_GLES_VERSION:-3.2}"
}

gpu_start_server() { :; }
