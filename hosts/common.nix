{ ... }:

{
  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; fsType = "ext4"; };
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  system.stateVersion = "23.11";

  users.users.demo = {
    isNormalUser = true;
    password = "demo";
    extraGroups = [ "wheel" ];
  };
  security.sudo.wheelNeedsPassword = false;
}

