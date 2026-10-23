{ ... }:

{
  # Installs starship and hooks it into bash, zsh and fish
  programs.starship.enable = true;

  # Config is kept as a plain TOML file in configs/ at the repo root
  # (path is relative to this file, so the repo can live anywhere)
  xdg.configFile."starship.toml".source = ../configs/starship.toml;
}
