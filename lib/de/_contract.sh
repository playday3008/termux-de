#!/usr/bin/env bash
# DE module contract — REFERENCE ONLY, not sourced.
#
# Every DE module must define:
#
#   DE_NAME="name"                     Identifier (lowercase, [a-z0-9_-])
#   DE_LABEL="Human Name"             Display name
#   DE_HAS_COMPOSITOR=true|false       Built-in compositor?
#   DE_REQUIRED_BINS=("bin1" "bin2")   Required binaries
#   DE_OPTIONAL_BINS=("bin3")          Optional binaries (warn if missing)
#
#   de_start()    Launch DE via process_spawn
#   de_env()      Optional: export DE-specific env vars
