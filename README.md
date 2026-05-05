# termux-de

Desktop environment launcher for Termux on Android. Pure Bash. Supports 12 DEs over Termux:X11 with GPU acceleration via Mesa drivers.

## Supported DEs

awesome, bspwm, fluxbox, fvwm, i3, icewm, jwm, lxqt, mate, openbox, plasma, xfce

## Usage

```bash
./termux-de start                   # launch default DE
./termux-de start --de=plasma       # specific DE
./termux-de start --software        # force CPU software rendering
./termux-de start --driver=turnip   # force GPU driver
./termux-de start --daemon          # daemonize after launch
./termux-de list                    # available DEs
./termux-de status                  # session info
./termux-de stop                    # stop running session
./termux-de logs                    # list session logs
./termux-de logs --tail             # follow latest log
```

## GPU Drivers

Auto-detected based on hardware:

| Driver | When | Method |
|--------|------|--------|
| turnip | Adreno GPU | Native Vulkan via freedreno |
| zink | Mesa Vulkan ICD present | Vulkan-to-GL translation |
| virpipe | Fallback | ANGLE-accelerated via virgl |
| lavapipe | `--software` | CPU software via llvmpipe |

Override with `--driver=<name>` or `--software` for CPU fallback.

## Architecture

Thin orchestrator (~215 lines) sources modules from `lib/`:

```
lib/core/       config, logging, process management, session, preflight
lib/display/    display server (X11, Wayland-ready)
lib/gpu/        GPU driver detection and setup
lib/audio/      PulseAudio management
lib/compositor/ picom compositor management
lib/de/         desktop environment modules
```

## Configuration

Config priority: CLI flags > environment variables > `~/.config/termux-de/config` > defaults.

All config variables use the `TDE_` prefix. See `./termux-de --help` for details.

## Requirements

- [Termux](https://termux.dev)
- [Termux:X11](https://github.com/nicknj4/termux-x11)
- Mesa (for GPU acceleration)
- At least one supported DE installed
