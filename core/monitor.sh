asec_monitor() {
  IFACE=$(ip route | awk '/default/ {print $5}' | head -n1)
  RX_PREV=0
  TX_PREV=0

  clear
  echo "┌──────────────────────────────┐"
  echo "│ ASEC LIVE MONITOR            │"
  echo "├───────────────┬──────────────┤"
  echo "│ CPU Load      │              │"
  echo "│ RAM Usage     │              │"
  echo "│ Storage Free  │              │"
  echo "│ Net Down      │              │"
  echo "│ Net Up        │              │"
  echo "│ Battery       │              │"
  echo "│ IP Address    │              │"
  echo "└───────────────┴──────────────┘"
  echo
  echo "CTRL+C to exit"

  while true; do
    CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | sed 's/^ //')

    RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    RAM_USED=$(free -m | awk '/Mem:/ {print $3}')

    STATS=$(df -m . | tail -1)
    ST_FREE=$(echo "$STATS" | awk '{print $4}')

    if [ -d "/sys/class/power_supply" ]; then
      BAT=$(ls /sys/class/power_supply 2>/dev/null | grep -E "BAT|battery" | head -n1)
      if [ -n "$BAT" ]; then
        BAT_CAP=$(cat /sys/class/power_supply/$BAT/capacity)
      else
        BAT_CAP="n/a"
      fi
    else
      BAT_CAP="n/a"
    fi

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

    tput cup 3 18;  printf "%-12s" "$CPU_LOAD"
    tput cup 4 18;  printf "%-12s" "$RAM_USED / ${RAM_TOTAL}MB"
    tput cup 5 18;  printf "%-12s" "$ST_FREE MB"
    tput cup 6 18;  printf "%-12s" "$RX_RATE MB/s"
    tput cup 7 18;  printf "%-12s" "$TX_RATE MB/s"
    tput cup 8 18;  printf "%-12s" "$BAT_CAP%"
    tput cup 9 18;  printf "%-12s" "${IP_LOCAL:-n/a}"

    sleep 1
  done
}
