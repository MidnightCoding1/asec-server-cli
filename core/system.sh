asec_system_status() {
  echo "┌──────────────────────────────┐"
  echo "│ ASEC SYSTEM STATUS           │"
  echo "├───────────────┬──────────────┤"

  CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | sed 's/^ //')

  RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
  RAM_USED=$(free -m | awk '/Mem:/ {print $3}')

  STATS=$(df -m . | tail -1)
  ST_TOTAL=$(echo "$STATS" | awk '{print $2}')
  ST_USED=$(echo "$STATS" | awk '{print $3}')
  ST_FREE=$(echo "$STATS" | awk '{print $4}')
  ST_PCT=$(awk "BEGIN {printf \"%.2f\", ($ST_USED/$ST_TOTAL)*100}")

  if [ -d "/sys/class/power_supply" ]; then
    BAT=$(ls /sys/class/power_supply 2>/dev/null | grep -E "BAT|battery" | head -n1)
    if [ -n "$BAT" ]; then
      BAT_CAP=$(cat /sys/class/power_supply/$BAT/capacity)
      BAT_STAT=$(cat /sys/class/power_supply/$BAT/status | cut -c1-5)
    else
      BAT_CAP="n/a"
      BAT_STAT=""
    fi
  else
    BAT_CAP="n/a"
    BAT_STAT=""
  fi

  IP_LOCAL=$(ip addr 2>/dev/null | awk '/inet / && !/127.0.0.1/ {print $2}' | head -n1)

  printf "│ %-13s │ %-12s │\n" "CPU Load" "$CPU_LOAD"
  printf "│ %-13s │ %-12s │\n" "RAM Usage" "$RAM_USED / ${RAM_TOTAL}MB"
  printf "│ %-13s │ %-12s │\n" "Storage Free" "$ST_FREE MB"
  printf "│ %-13s │ %-12s │\n" "Storage Used" "$ST_PCT %"
  printf "│ %-13s │ %-12s │\n" "Battery" "$BAT_CAP% $BAT_STAT"
  printf "│ %-13s │ %-12s │\n" "IP Address" "${IP_LOCAL:-n/a}"

  echo "└───────────────┴──────────────┘"
}
