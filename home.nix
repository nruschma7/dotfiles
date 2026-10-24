{ ... }:

{
  imports = [
    ./modules/cargo.nix
    ./modules/dotnet.nix
    ./modules/python.nix
    ./modules/tmux.nix
    ./modules/starship.nix
    ./modules/texlive.nix
    ./modules/text-slides.nix
    ./modules/mermaidjs.nix
    ./modules/neovim.nix
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
