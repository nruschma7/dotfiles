# Gemeinsame Konfiguration für alle Systeme.
# username/homeDirectory kommen aus flake.nix, die Shell aus hosts/<name>.nix.
{ ... }:

{
  imports = [
    ./modules/neovim.nix
    ./modules/dotnet.nix
    ./modules/tmux.nix
  ];

  # Nicht nachträglich ändern, bestimmt nur Defaults für Zustandsdaten
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
