# absolute project root
ASEC_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

LOCAL_ROOT="$ASEC_ROOT/data/local"
SITE_ROOT="$LOCAL_ROOT/sites"
LOCAL_DB="$LOCAL_ROOT/servers.db"

asec_local_init() {
  mkdir -p "$SITE_ROOT"
  touch "$LOCAL_DB"
}

asec_local_start() {
  asec_local_init

  echo
  echo "Create local server"
  echo "-------------------"

  printf "Name (identifier): "
  read -r NAME

  if [ -z "$NAME" ]; then
    echo "aborted: name required"
    return
  fi

  if grep -q "^$NAME|" "$LOCAL_DB"; then
    echo "aborted: server with this name already exists"
    return
  fi

  SITE_DIR="$SITE_ROOT/$NAME"

  if [ -d "$SITE_DIR" ]; then
    echo "aborted: site directory already exists"
    return
  fi

  printf "Port (default 8000): "
  read -r PORT
  PORT=${PORT:-8000}

  printf "Description (optional): "
  read -r DESC

  echo
  echo "Preparing site directory..."
  mkdir -p "$SITE_DIR"

  # default index.html
  cat > "$SITE_DIR/index.html" <<EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>$NAME</title>
</head>
<body>
  <h1>$NAME</h1>
  <p>Local site created by asec-server-cli</p>
</body>
</html>
EOF

  echo "Starting local web server..."
  echo

  (
    cd "$SITE_DIR" || exit 1
    python3 -m http.server "$PORT" >/dev/null 2>&1 &
    echo $! > "$LOCAL_ROOT/.last_pid"
  )

  PID=$(cat "$LOCAL_ROOT/.last_pid")
  rm -f "$LOCAL_ROOT/.last_pid"

  echo "$NAME|$PORT|$SITE_DIR|$PID|$DESC" >> "$LOCAL_DB"

  echo "Local server started"
  echo "--------------------"
  echo "Name        : $NAME"
  echo "Directory   : $SITE_DIR"
  echo "Port        : $PORT"
  echo "URL         : http://localhost:$PORT"
  [ -n "$DESC" ] && echo "Description : $DESC"
  echo
}

asec_local_list() {
  asec_local_init

  if [ ! -s "$LOCAL_DB" ]; then
    echo
    echo "No local servers running"
    echo
    return
  fi

  echo
  echo "ACTIVE LOCAL SERVERS"
  echo "----------------------------------------------------------"
  printf "%-12s %-6s %-20s %-8s %s\n" "NAME" "PORT" "DIR" "PID" "DESCRIPTION"
  echo "----------------------------------------------------------"

  while IFS="|" read -r NAME PORT DIR PID DESC; do
    if kill -0 "$PID" 2>/dev/null; then
      printf "%-12s %-6s %-20s %-8s %s\n" \
        "$NAME" "$PORT" "$(basename "$DIR")" "$PID" "$DESC"
    fi
  done < "$LOCAL_DB"

  echo "----------------------------------------------------------"
  echo
}
