asec_monitor() {
  RX_PREV=0
  TX_PREV=0

  IFACE=$(ip route | awk '/default/ {print $5}' | head -n1)

  while true; do
    clear

    echo "ASEC SERVER MONITOR"
    echo "==================="

    # CPU
    CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | sed 's/^ //')
    echo "CPU Load: $CPU_LOAD"

    # RAM
    RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    RAM_USED=$(free -m | awk '/Mem:/ {print $3}')
    RAM_PCT=$(awk "BEGIN {printf \"%.2f\", ($RAM_USED/$RAM_TOTAL)*100}")
    echo "RAM: $RAM_USED / $RAM_TOTAL MB ($RAM_PCT%)"

    # Storage
    STATS=$(df -m . | tail -1)
    ST_TOTAL=$(echo "$STATS" | awk '{print $2}')
    ST_USED=$(echo "$STATS" | awk '{print $3}')
    ST_FREE=$(echo "$STATS" | awk '{print $4}')
    ST_PCT=$(awk "BEGIN {printf \"%.2f\", ($ST_USED/$ST_TOTAL)*100}")
    echo "Storage: $ST_FREE MB free ($ST_PCT% used)"

    # Battery
    if [ -d "/sys/class/power_supply" ]; then
      BAT=$(ls /sys/class/power_supply 2>/dev/null | grep -E "BAT|battery" | head -n1)
      if [ -n "$BAT" ]; then
        CAP=$(cat /sys/class/power_supply/$BAT/capacity)
        STAT=$(cat /sys/class/power_supply/$BAT/status)
        echo "Battery: $CAP% ($STAT)"
      else
        echo "Battery: n/a"
      fi
    fi

    # Network speed (MB/s)
    RX=$(cat /sys/class/net/$IFACE/statistics/rx_bytes 2>/dev/null)
    TX=$(cat /sys/class/net/$IFACE/statistics/tx_bytes 2>/dev/null)

    if [ "$RX_PREV" -ne 0 ]; then
      RX_RATE=$(awk "BEGIN {printf \"%.2f\", ($RX-$RX_PREV)/1024/1024}")
      TX_RATE=$(awk "BEGIN {printf \"%.2f\", ($TX-$TX_PREV)/1024/1024}")
      echo "Network: ↓ $RX_RATE MB/s | ↑ $TX_RATE MB/s"
    else
      echo "Network: calculating..."
    fi

    RX_PREV=$RX
    TX_PREV=$TX

    # IP
    IP_LOCAL=$(ip addr 2>/dev/null | awk '/inet / && !/127.0.0.1/ {print $2}' | head -n1)
    echo "IP: ${IP_LOCAL:-unknown}"

    echo
    echo "Press CTRL+C to exit"

    sleep 1
  done
}
