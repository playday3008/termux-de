#!/usr/bin/env bash
# Display server contract — REFERENCE ONLY, not sourced.
#
# Every display backend must define:
#
#   display_start()        Start server. Uses process_spawn for PID tracking.
#   display_wait_ready()   Block until server accepts connections.
#   display_stop()         Graceful stop via process_kill.
#
# After display_start(), DISPLAY must be exported.
#
# Current backends:
#   x11.sh    — Termux X11
#
# Future backends:
#   wayland.sh — Wayland compositor (Xwayland or native)
