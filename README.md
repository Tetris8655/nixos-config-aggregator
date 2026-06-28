# NixOS Configuration Aggregator

A structured, scalable approach to managing multiple NixOS configurations from a single flake. 

This project demonstrates how to use a custom Nix library to automatically discover modules, selectively apply them to specific hosts, and strictly validate configurations before they build. It eliminates "import hell" by dynamically wiring packages, overlays, and system modules.

---

## Project Architecture

The repository is organized to separate core logic from host-specific configurations:

- **`lib/`**: The brain of the operation. Contains custom functions for recursive module discovery (`discoverModules`), strict selection validation (`selectModules`), and host generation (`mkHost`).
- **`hosts/`**: Machine-specific definitions. Each host gets its own directory and a minimal `configuration.nix`.
- **`modules/`**: Reusable system components (e.g., `web-server`, `database`, `networking/firewall-strict`). These are automatically discovered and loaded by name.
- **`packages/`**: Custom derivations and scripts (like `health-report`). These are automatically bundled into an overlay and exposed to all hosts.

---

## Demonstration & Proof of Concept

The following commands demonstrate the core capabilities of this aggregation pattern. 

| **Demo Step** | **Command** | **What it proves** |
| :--- | :--- | :--- |
| **Aggregation works** | `nix flake show` | All hosts and custom packages are successfully discovered and exposed by the flake. |
| **Configs build** | `nix flake check` | Every selected module and host configuration evaluates without errors. |
| **Nested module loads** | `nix eval .#nixosConfigurations.web-host.config.networking.firewall.allowedTCPPorts` | Subdirectory discovery works (e.g., loading `networking/firewall-strict` applies port 22 & 80). |
| **Selective loading** | Compare `web-host` vs `db-host` outputs | Modules are strictly host-specific. The database host doesn't get Nginx, and the web host doesn't get PostgreSQL. |
| **Fail-loud validation** | Uncomment `missing-host` in `flake.nix`, then run `nix flake check` | Invalid module selections or typos throw an immediate, readable assertion error rather than failing deep in the build process. |
| **Live tools** | Run `health-report` on a built VM | Custom packages and overlays are automatically wired into the `pkgs` arguments of the modules. |

---

## Core Features

### 1. Dynamic Module Discovery
Instead of manually writing `imports = [ ../../modules/web-server.nix ]`, hosts simply declare a list of required modules by their relative names:

```nix
selectedModules = [ "web-server" "dev-tools" "networking/firewall-strict" ];
```

The `lib.discoverModules` function recursively walks the `modules/` directory to find and map these files automatically.

### 2. "Fail-Loud" Safety
If a host requests a module that doesn't exist, or accidentally duplicates a module in its list, the evaluation fails immediately with a clear error message:

> `mkHost: unknown module(s): nonexisting`  
> `mkHost: duplicate module(s) in selection: web-server`

### 3. Automatic Overlays
Any package defined in the `packages/` directory is automatically discovered, built, and injected into a custom overlay. This means tools like `server-status` are instantly available in `pkgs` across all host configurations without manual wiring.
