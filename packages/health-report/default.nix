{ pkgs, server-status }:

pkgs.writeShellScriptBin "health-report" ''
  echo "AUTOMATED HEALTH REPORT"
  echo "Generated: $(date)"
  echo ""
  ${server-status}/bin/server-status
  echo ""
  echo "--- Disk Usage ---"
  ${pkgs.coreutils}/bin/df -h / | ${pkgs.gawk}/bin/awk 'NR==2 {print "  Root FS: " $5 " used (" $4 " free)"}'
''


