asec_system_status() {
  color() {
    [ "$1" -lt 50 ] && printf "\033[32m%s\033[0m" "$2" ||
    [ "$1" -lt 80 ] && printf "\033[33m%s\033[0m" "$2" ||
    printf "\033[31m%s\033[0m" "$2"
  }

  CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | sed 's/^ //')

  RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
  RAM_USED=$(free -m | awk '/Mem:/ {print $3}')
  RAM_PCT=$((RAM_USED * 100 / RAM_TOTAL))

  STATS=$(df -m . | tail -1)
  ST_FREE=$(echo "$STATS" | awk '{print $4}')
  ST_TOTAL=$(echo "$STATS" | awk '{print $2}')
  ST_PCT=$((100 - (ST_FREE * 100 / ST_TOTAL)))

  BAT_CAP="n/a"
  if [ -d "/sys/class/power_supply" ]; then
    BAT=$(ls /sys/class/power_supply 2>/dev/null | grep -E "BAT|battery" | head -n1)
    [ -n "$BAT" ] && BAT_CAP=$(cat /sys/class/power_supply/$BAT/capacity)
  fi

  IP_LOCAL=$(ip addr 2>/dev/null | awk '/inet / && !/127.0.0.1/ {print $2}' | head -n1)

  echo "┌──────────────────── SYSTEM STATUS ────────────────────┐"
  printf "│ CPU Load     : %-37s │\n" "$CPU_LOAD"
  printf "│ RAM Usage    : "; color "$RAM_PCT" "$RAM_USED / ${RAM_TOTAL}MB ($RAM_PCT%)"; echo " │"
  printf "│ Storage Free : "; color "$ST_PCT" "$ST_FREE MB"; echo " │"
  printf "│ Battery      : %-37s │\n" "$BAT_CAP%"
  printf "│ IP Address   : %-37s │\n" "${IP_LOCAL:-n/a}"
  echo "└───────────────────────────────────────────────────────┘"
}
