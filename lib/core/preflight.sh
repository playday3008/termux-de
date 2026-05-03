#!/usr/bin/env bash
# Dependency validation with install hints

declare -A BIN_TO_PKG=(
    [dbus-run-session]=dbus
    [pulseaudio]=pulseaudio
    [pactl]=pulseaudio
    [glxinfo]=mesa-demos
    [xdpyinfo]=xorg-xdpyinfo
    [vulkaninfo]=vulkan-tools
    [picom]=picom
    [termux-x11]=termux-x11-nightly
    [virgl_test_server]=virglrenderer
    [virgl_test_server_android]=virglrenderer-android
    # DE launchers
    [startplasma-x11]=plasma-desktop
    [kwin_x11]=kwin-x11
    [xfce4-session]=xfce4
    [openbox]=openbox
    [i3]=i3
    [startlxqt]=lxqt
    [mate-session]=mate-session-manager
    [startfluxbox]=fluxbox
    [icewm-session]=icewm
    [awesome]=awesome
    [bspwm]=bspwm
    [sxhkd]=sxhkd
    [fvwm]=fvwm
    [jwm]=jwm
)

declare -A PKG_TO_REPO=(
    [plasma-desktop]=x11-repo
    [kwin-x11]=x11-repo
    [xfce4]=x11-repo
    [openbox]=x11-repo
    [i3]=x11-repo
    [lxqt]=x11-repo
    [mate-session-manager]=x11-repo
    [fluxbox]=x11-repo
    [icewm]=x11-repo
    [awesome]=x11-repo
    [bspwm]=x11-repo
    [sxhkd]=x11-repo
    [fvwm]=x11-repo
    [jwm]=x11-repo
    [picom]=x11-repo
    [xorg-xdpyinfo]=x11-repo
    [termux-x11-nightly]=x11-repo
    [mesa-demos]=x11-repo
)

declare -A REPO_SETUP=(
    [x11-repo]="pkg install x11-repo"
)

preflight_check() {
    local -a required=(dbus-run-session termux-x11 xdpyinfo pulseaudio pactl glxinfo)
    required+=("${DE_REQUIRED_BINS[@]}")

    if [[ "${GPU_NEEDS_SERVER:-false}" == "true" ]]; then
        case "${GPU_DRIVER_NAME:-}" in
            virpipe) required+=(virgl_test_server_android) ;;
            zink)    required+=(virgl_test_server) ;;
        esac
    fi

    # Lavapipe ICD required for virpipe — Qt6 needs a working Vulkan instance
    if [[ "${GPU_DRIVER_NAME:-}" == "virpipe" ]]; then
        local lvp_icds=("${PREFIX}/share/vulkan/icd.d"/lvp_icd.*.json)
        if [[ ! -f "${lvp_icds[0]}" ]]; then
            log_error "Lavapipe Vulkan ICD not found (required for software rendering)"
            printf '  Qt6/KDE needs a Vulkan instance even in software mode.\n' >&2
            printf '\n  Install with:\n' >&2
            printf '    pkg install mesa-vulkan-icd-swrast\n\n' >&2
            exit 1
        fi
    fi

    [[ "${DE_HAS_COMPOSITOR:-true}" == "false" ]] && required+=(picom)

    local -a missing=()
    for bin in "${required[@]}"; do
        command -v "$bin" &>/dev/null || missing+=("$bin")
    done

    if (( ${#missing[@]} > 0 )); then
        _preflight_print_instructions "${missing[@]}"
        exit 1
    fi

    # Optional bins: warn only
    local opt_bins=("${DE_OPTIONAL_BINS[@]+"${DE_OPTIONAL_BINS[@]}"}")
    for bin in "${opt_bins[@]}"; do
        [[ -z "$bin" ]] && continue
        command -v "$bin" &>/dev/null \
            || log_warn "$bin not found. Try: pkg search $bin"
    done
}

_preflight_print_instructions() {
    local -a bins=("$@")
    local -A repos_needed=()
    local -A pkgs_needed=()

    log_error "Missing required binaries:"
    for bin in "${bins[@]}"; do
        local pkg="${BIN_TO_PKG[$bin]:-}"
        if [[ -n "$pkg" ]]; then
            printf '  %s (package: %s)\n' "$bin" "$pkg" >&2
            pkgs_needed[$pkg]=1
            local repo="${PKG_TO_REPO[$pkg]:-}"
            [[ -n "$repo" ]] && repos_needed[$repo]=1
        else
            printf '  %s — try: pkg search %s\n' "$bin" "$bin" >&2
        fi
    done

    echo "" >&2
    echo "Install with:" >&2

    for repo in "${!repos_needed[@]}"; do
        local setup="${REPO_SETUP[$repo]:-}"
        [[ -n "$setup" ]] && printf '  %s\n' "$setup" >&2
    done

    if (( ${#pkgs_needed[@]} > 0 )); then
        printf '  pkg install %s\n' "${!pkgs_needed[*]}" >&2
    fi
}
