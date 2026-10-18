{
  description = "Meine Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      # Baut eine Home-Manager-Konfiguration: gemeinsame home.nix + hostspezifische Module
      mkHome = { system, username, homeDirectory, modules }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./home.nix
            { home = { inherit username homeDirectory; }; }
          ] ++ modules;
        };
    in {
      homeConfigurations = {
        cachyos = mkHome {
          system = "x86_64-linux";
          username = "ruschi";
          homeDirectory = "/home/ruschi";
          modules = [ ./hosts/cachyos.nix ];
        };

        macos = mkHome {
          system = "aarch64-darwin";
          username = "ruschi";
          homeDirectory = "/Users/ruschi";
          modules = [ ./hosts/macos.nix ];
        };

        wsl = mkHome {
          system = "x86_64-linux";
          username = "ruschi";
          homeDirectory = "/home/ruschi";
          modules = [ ./hosts/wsl.nix ];
        };
      };
    };
}
