{ lib, nixpkgs }:

let
  discoverModules = dir:
    let
      walk = prefix: base:
        lib.concatMapAttrs
          (name: type:
            let
              relName = if prefix == "" then name else "${prefix}/${name}";
            in
              if type == "directory" then
                walk relName (base + "/${name}")
              else if type == "regular" 
                      && lib.hasSuffix ".nix" name
                      && !(lib.hasPrefix "_" name)
                      && name != "default.nix" then
                { ${lib.removeSuffix ".nix" relName} = base + "/${name}"; }
              else
                { }
          )
          (builtins.readDir base);
    in
      walk "" dir;

  selectModules = available: selected:
    let 
      unknown = lib.subtractLists (lib.attrNames available) selected;
      grouped = lib.groupBy (x: x) selected;
      duplicates = lib.attrNames (lib.filterAttrs (_: v: builtins.length v > 1) grouped);
    in 
      assert lib.assertMsg (unknown == [ ])
        "mkHost: unknown module(s): ${lib.concatStringsSep ", " unknown}. Available: ${lib.concatStringsSep ", " (lib.attrNames available)}";
      assert lib.assertMsg (duplicates == [])
        "mkHost: duplicate module(s): ${lib.concatStringsSep ", " duplicates}";
      map (name: available.${name}) selected;

  packageDirsOf = dir:
    lib.filterAttrs (name: type: type == "directory") (builtins.readDir dir);

  mkOverlay = dir: final: prev:
    lib.mapAttrs (name: _: final.callPackage (dir + "/${name}") { }) (packageDirsOf dir);
in
{
  inherit mkOverlay;

  discoverPackages = dir: pkgs:
    lib.mapAttrs (name: _: pkgs.callPackage (dir + "/${name}") { }) (packageDirsOf dir);

  mkHost = { system, hostPath, modulesDir, packagesDir, selectedModules }:
    let
      available = discoverModules modulesDir;
      moduleList = selectModules available selectedModules;
    in
    lib.nixosSystem {
      inherit system;
      modules = [
        hostPath
        { nixpkgs.overlays = [ (mkOverlay packagesDir) ]; }
      ] ++ moduleList;
    };
}

