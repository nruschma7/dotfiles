{ ... }:

{
  imports = [
    ./modules/cargo.nix
    ./modules/dotnet.nix
    ./modules/python.nix
    ./modules/tmux.nix
    ./modules/starship.nix
    ./modules/neovim.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
