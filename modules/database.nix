{ pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "company_app" ];
    ensureUsers = [{
      name = "company_app";
      ensureDBOwnership = true;
    }];
    
    authentication = pkgs.lib.mkForce ''
      local all all trust
      host all all 127.0.0.1/32 trust
    '';
  };
}
