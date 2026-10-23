{ config, lib, pkgs, ... }:

let
  pluginDir = "${config.xdg.configHome}/tmux/plugins";

  autostartPosix = ''
    if [[ $- == *i* ]] && [ -z "$TMUX" ] && [ -z "$NVIM" ] && [ -z "$NO_TMUX" ] \
       && [ "$TERM_PROGRAM" != "vscode" ] && command -v tmux >/dev/null 2>&1; then
      exec tmux new-session -A -s main
    fi
  '';

  autostartFish = ''
    if status is-interactive
      and not set -q TMUX
      and not set -q NVIM
      and not set -q NO_TMUX
      and test "$TERM_PROGRAM" != vscode
      and command -q tmux
      exec tmux new-session -A -s main
    end
  '';
in
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    escapeTime = 10;

    extraConfig = lib.mkMerge [
      # Plain tmux config lives in configs/ at the repo root (path is relative to this file)
      (builtins.readFile ../configs/tmux.conf)
      (lib.mkAfter ''
        run '${pluginDir}/tpm/tpm'
      '')
    ];
  };

  home.activation.tpm = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    tpm_dir="${pluginDir}/tpm"
    if [ ! -d "$tpm_dir/.git" ]; then
      run mkdir -p "${pluginDir}"
      run ${pkgs.git}/bin/git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir" \
        || echo "tpm: clone fehlgeschlagen"
    else
      run ${pkgs.git}/bin/git -C "$tpm_dir" pull --ff-only \
        || echo "tpm: pull fehlgeschlagen, behalte aktuelle Version"
    fi

    if [ -x "$tpm_dir/bin/install_plugins" ]; then
      (
        export PATH="${lib.makeBinPath [ pkgs.git pkgs.tmux ]}:$PATH"
        run "$tpm_dir/bin/install_plugins"
      ) || echo "tpm: Plugin-Installation fehlgeschlagen"
    fi
  '';

  programs.fish.interactiveShellInit =
    lib.mkIf config.programs.fish.enable (lib.mkAfter autostartFish);
  programs.zsh.initContent =
    lib.mkIf config.programs.zsh.enable (lib.mkAfter autostartPosix);
  programs.bash.initExtra =
    lib.mkIf config.programs.bash.enable autostartPosix;
}
