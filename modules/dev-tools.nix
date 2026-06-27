{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    htop
    tmux
    server-status
    health-report
  ];
}
