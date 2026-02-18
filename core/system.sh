asec_system_status() {
  CPU=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1)

  RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
  RAM_USED=$(free -m | awk '/Mem:/ {print $3}')

  DISK=$(df -m . | tail -1)
  DISK_FREE=$(echo "$DISK" | awk '{print $4}')

  BAT="n/a"
  if [ -d /sys/class/power_supply ]; then
    B=$(ls /sys/class/power_supply | grep BAT | head -n1)
    [ -n "$B" ] && BAT=$(cat /sys/class/power_supply/$B/capacity)
  fi

  IP=$(ip addr | awk '/inet / && !/127/ {print $2}' | head -n1)

  echo
  echo "SYSTEM STATUS"
  echo "----------------------------"
  echo "CPU Load     : $CPU"
  echo "RAM          : $RAM_USED / $RAM_TOTAL MB"
  echo "Disk Free    : $DISK_FREE MB"
  echo "Battery      : $BAT%"
  echo "IP           : $IP"
  echo
}
