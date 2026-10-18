{ pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      git
      gcc                # C-Compiler für nvim-treesitter
      gnumake
      tree-sitter        # tree-sitter CLI (nvim-treesitter)
      curl

      ripgrep            # Live-Grep (Snacks/Telescope)
      fd                 # Dateisuche
      fzf                # fzf-lua Extra
      lazygit            # <leader>gg

      unzip
      gzip
      gnutar
      wget

      nodejs
      python3
      luarocks
      lua-language-server

      imagemagick
      ghostscript
      tectonic
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      mermaid-cli        # Mermaid-Diagramme (snacks.image)
      wl-clipboard       # Clipboard unter Wayland
      xclip              # Clipboard unter X11
    ];
  };

  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.enable = pkgs.stdenv.isLinux;

  xdg.configFile."nvim/init.lua".enable = lib.mkForce false;

  home.activation.nvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    git="${pkgs.git}/bin/git"
    repo="https://github.com/nruschma7/nvim-config.git"
    nvim_dir="$HOME/.config/nvim"

    if [ -d "$nvim_dir/.git" ]; then
      run "$git" -C "$nvim_dir" pull --ff-only \
        || echo "nvim config: pull fehlgeschlagen, behalte aktuelle Version"
    else
      tmp_dir="$nvim_dir.new"
      run rm -rf "$tmp_dir"
      if run "$git" clone "$repo" "$tmp_dir"; then
        if [ -e "$nvim_dir" ] || [ -L "$nvim_dir" ]; then
          backup="$nvim_dir.bak-$(date +%Y%m%d-%H%M%S)"
          echo "nvim config: bestehende Config wird nach $backup gesichert"
          run mv "$nvim_dir" "$backup"
        fi
        run mv "$tmp_dir" "$nvim_dir"
      else
        echo "nvim config: clone fehlgeschlagen, bestehende Config bleibt unberührt"
        run rm -rf "$tmp_dir"
      fi
    fi
  '';
}