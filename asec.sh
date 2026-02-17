#!/bin/sh

ASEC_ROOT="$(cd "$(dirname "$0")" && pwd)"

. "$ASEC_ROOT/core/version.sh"
. "$ASEC_ROOT/core/help.sh"

CMD="$1"

case "$CMD" in
  "" | "help")
    asec_help
    ;;
  "version")
    asec_version
    ;;
  *)
    echo "[asec] unknown command: $CMD"
    echo "use: asec help"
    ;;
esac
