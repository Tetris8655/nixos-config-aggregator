{ pkgs, ... }:

{
  services.nginx = {
    enable = true;

    virtualHosts."localhost" = {
      default = true;
      locations."/".return = "200 'Nginx is successfully running on NixOS!\n'";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
