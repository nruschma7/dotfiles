{ ... }:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
        source /usr/share/cachyos-fish-config/cachyos-config.fish
      end
    '';
  };
}
