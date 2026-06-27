{ pkgs }:

pkgs.writeShellScriptBin "server-status" ''
  echo "|Company Server Status|"
  echo -n "Hostname: "; hostname
  echo -n "Uptime:   "; uptime
  echo ""
  echo "--- Service Health ---"

  if ! systemctl list-unit-files nginx.service >/dev/null 2>&1; then
    echo "  Nginx:      not installed on this host"
  elif systemctl is-active --quiet nginx; then
    echo "  Nginx:      RUNNING"
  else
    echo "  Nginx:      OFFLINE"
  fi

  if ! systemctl list-unit-files postgresql.service >/dev/null 2>&1; then
    echo "  PostgreSQL: not installed on this host"
  elif systemctl is-active --quiet postgresql; then
    echo "  PostgreSQL: RUNNING"
    echo -n "    Databases: "
    ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/psql -tAc \
      "SELECT datname FROM pg_database WHERE datistemplate = false;" \
      2>/dev/null | tr '\n' ' '
    echo ""
  else
    echo "  PostgreSQL: OFFLINE"
  fi
''

