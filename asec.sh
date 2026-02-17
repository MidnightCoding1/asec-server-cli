#!/bin/sh

ASEC_ROOT="$(cd "$(dirname "$0")" && pwd)"

# load modules
. "$ASEC_ROOT/core/version.sh"
. "$ASEC_ROOT/core/help.sh"
. "$ASEC_ROOT/core/system.sh"

CMD="$1"

case "$CMD" in
  "" | "help")
    asec_help
    ;;
  "version")
    asec_version
    ;;
  "system")
    asec_system_status
    ;;
  *)
    echo "[asec] unknown command: $CMD"
    echo "use: asec help"
    ;;
esac
