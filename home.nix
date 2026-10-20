{ ... }:

{
  imports = [
    ./modules/neovim.nix
    ./modules/dotnet.nix
    ./modules/python.nix
    ./modules/tmux.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
