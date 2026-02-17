asec_system_status() {
  echo "SYSTEM STATUS"
  echo "-------------"

  # CPU Load (1 min)
  CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | sed 's/^ //')
  echo "CPU Load: $CPU_LOAD"

  # RAM (MB exact)
  if command -v free >/dev/null 2>&1; then
    RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    RAM_USED=$(free -m | awk '/Mem:/ {print $3}')
    RAM_FREE=$(free -m | awk '/Mem:/ {print $4}')
    echo "RAM: $RAM_USED MB used / $RAM_TOTAL MB total (free: $RAM_FREE MB)"
  else
    echo "RAM: not available"
  fi

  # Storage (MB)
  STORAGE_LINE=$(df -m . | tail -1)
  ST_TOTAL=$(echo "$STORAGE_LINE" | awk '{print $2}')
  ST_USED=$(echo "$STORAGE_LINE" | awk '{print $3}')
  ST_FREE=$(echo "$STORAGE_LINE" | awk '{print $4}')
  echo "Storage: $ST_USED MB used / $ST_TOTAL MB total (free: $ST_FREE MB)"

  # Battery (Linux / Termux)
  if [ -d "/sys/class/power_supply" ]; then
    BAT_PATH=$(ls /sys/class/power_supply 2>/dev/null | grep -E "BAT|battery" | head -n1)
    if [ -n "$BAT_PATH" ]; then
      BAT_CAP=$(cat /sys/class/power_supply/$BAT_PATH/capacity 2>/dev/null)
      BAT_STAT=$(cat /sys/class/power_supply/$BAT_PATH/status 2>/dev/null)
      echo "Battery: $BAT_CAP% ($BAT_STAT)"
    else
      echo "Battery: not detected"
    fi
  else
    echo "Battery: not supported"
  fi

  # Network (local IP)
  IP_LOCAL=$(ip addr 2>/dev/null | awk '/inet / && !/127.0.0.1/ {print $2}' | head -n1)
  echo "IP: ${IP_LOCAL:-unknown}"
}
