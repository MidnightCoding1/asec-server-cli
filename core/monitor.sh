asec_monitor() {
  # hide cursor
  tput civis
  trap 'tput cnorm; clear; exit' INT TERM

  IFACE=$(ip route | awk '/default/ {print $5}' | head -n1)
  RX_PREV=0
  TX_PREV=0

  draw_ui() {
    clear
    COLS=$(tput cols)

    echo "┌──────────────────────── SYSTEM ────────────────────────┐"
    echo "│ CPU Load     :                                          │"
    echo "│ RAM Usage    :                                          │"
    echo "│ Storage Free :                                          │"
    echo "└─────────────────────────────────────────────────────────┘"

    echo "┌──────────────────────── NETWORK ───────────────────────┐"
    echo "│ Download     :                                          │"
    echo "│ Upload       :                                          │"
    echo "│ IP Address   :                                          │"
    echo "└─────────────────────────────────────────────────────────┘"

    echo "┌──────────────────────── POWER ─────────────────────────┐"
    echo "│ Battery      :                                          │"
    echo "└─────────────────────────────────────────────────────────┘"

    echo
    echo "Press CTRL+C to exit"
  }

  color_pct() {
    VAL=$1
    if [ "$VAL" -lt 50 ]; then
      printf "\033[32m%s\033[0m" "$2"
    elif [ "$VAL" -lt 80 ]; then
      printf "\033[33m%s\033[0m" "$2"
    else
      printf "\033[31m%s\033[0m" "$2"
    fi
  }

  draw_ui

  while true; do
    # detect resize
    CUR_COLS=$(tput cols)
    if [ "$CUR_COLS" != "$COLS" ]; then
      draw_ui
    fi

    # CPU
    CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | sed 's/^ //')

    # RAM
    RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    RAM_USED=$(free -m | awk '/Mem:/ {print $3}')
    RAM_PCT=$((RAM_USED * 100 / RAM_TOTAL))

    # Storage
    STATS=$(df -m . | tail -1)
    ST_FREE=$(echo "$STATS" | awk '{print $4}')
    ST_TOTAL=$(echo "$STATS" | awk '{print $2}')
    ST_PCT=$((100 - (ST_FREE * 100 / ST_TOTAL)))

    # Battery
    BAT_CAP="n/a"
    if [ -d "/sys/class/power_supply" ]; then
      BAT=$(ls /sys/class/power_supply 2>/dev/null | grep -E "BAT|battery" | head -n1)
      [ -n "$BAT" ] && BAT_CAP=$(cat /sys/class/power_supply/$BAT/capacity)
    fi

    # Network
    RX=$(cat /sys/class/net/$IFACE/statistics/rx_bytes 2>/dev/null)
    TX=$(cat /sys/class/net/$IFACE/statistics/tx_bytes 2>/dev/null)

    if [ "$RX_PREV" -ne 0 ]; then
      RX_RATE=$(awk "BEGIN {printf \"%.2f\", ($RX-$RX_PREV)/1024/1024}")
      TX_RATE=$(awk "BEGIN {printf \"%.2f\", ($TX-$TX_PREV)/1024/1024}")
    else
      RX_RATE="..."
      TX_RATE="..."
    fi

    RX_PREV=$RX
    TX_PREV=$TX

    IP_LOCAL=$(ip addr 2>/dev/null | awk '/inet / && !/127.0.0.1/ {print $2}' | head -n1)

    # update values (fixed cursor positions)
    tput cup 1 17;  printf "%-20s" "$CPU_LOAD"
    tput cup 2 17;  color_pct "$RAM_PCT" "$RAM_USED / ${RAM_TOTAL}MB ($RAM_PCT%%)"
    tput cup 3 17;  color_pct "$ST_PCT" "$ST_FREE MB free"

    tput cup 6 17;  printf "%-20s" "$RX_RATE MB/s"
    tput cup 7 17;  printf "%-20s" "$TX_RATE MB/s"
    tput cup 8 17;  printf "%-20s" "${IP_LOCAL:-n/a}"

    tput cup 11 17; printf "%-20s" "$BAT_CAP%"

    sleep 1
  done
}
