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

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
