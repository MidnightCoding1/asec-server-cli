asec_monitor() {
  tput civis
  trap 'tput cnorm; clear; return' INT

  clear
  echo "ASEC LIVE MONITOR (CTRL+C to exit)"
  echo

  while true; do
    CPU=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1)
    RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    RAM_USED=$(free -m | awk '/Mem:/ {print $3}')

    tput cup 2 0
    printf "CPU Load : %-10s\n" "$CPU"
    printf "RAM      : %s / %s MB\n" "$RAM_USED" "$RAM_TOTAL"

    sleep 1
  done
}
