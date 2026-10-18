{ config, lib, pkgs, ... }:

let
  # tpm und alle seine Plugins liegen beschreibbar hier (nicht im Nix-Store)
  pluginDir = "${config.xdg.configHome}/tmux/plugins";

  # Autostart für bash und zsh. Überspringt: bereits in tmux, nvim-Terminal,
  # VS Code und alles, wo NO_TMUX gesetzt ist (z. B. `NO_TMUX=1 bash`).
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
    escapeTime = 10; # kein Verzögern der Esc-Taste in Neovim

    extraConfig = lib.mkMerge [
      ''
        # If fresh install: `tmux source ~/.tmux.conf` + `prefix + I
        # https://github.com/tmux-plugins/tpm?tab=readme-ov-file#installing-plugins
        set-option -w -g aggressive-resize on

        set -g mouse on
        bind-key b set-option status
        # set -g status off

        # Start windows and panes at 1, not 0
        set -g base-index 1
        setw -g pane-base-index 1
        # Ensure window index numbers get reordered on delete.
        set-option -g renumber-windows on

        # open new windows in same dir
        # tmux set-option default-path "$PWD"
        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"

        # easy session
        bind C command-prompt -p "New Session:" "new-session -A -s '%%'"
        # TODO: create prompt to select and kill session
        bind-key S 'display-popup -w 80% -E "tmux list-sessions | fzf"'

        # Easy copy mode
        # bind Enter copy-mode
        # bind -n M-Enter copy-mode

        # VIM -------------------------------------------------------------------------------------------------------
        # vim coloring
        set-option -ga terminal-overrides ",xterm-256color:Tc"
        # like vim split
        bind h split-window -v
        bind v split-window -h
        # Copy mode  ------------------------------------------------------------------------------------------------
        setw -g mode-keys vi
        bind -T copy-mode-vi v send -X begin-selection
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel
        bind P paste-buffer
        bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel
        # Set focus-events on (important for Neovim autoread)
        set -g focus-events on
        # ------------------------------------------------------------------------------------------------


        # Set prefix to Alt-Space or backtick
        # unbind C-b
        set -g prefix M-`
        # set -g prefix2 M-Space
        set -g prefix2 C-b
        # bind M-` send-prefix
        # bind M-Space send-prefix

        set -g default-terminal "tmux-256color"
        set -ag terminal-overrides ",xterm-256color:RGB"

        set -g @plugin 'tmux-plugins/tpm'

        set -g history-limit 50000
        set -g display-time 4000
        set -g status-interval 5


        # mouse copy
        set-option -s set-clipboard off
        bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"

        # set -g @plugin 'tmux-plugins/tmux-prefix-highlight'

        set -g @plugin 'tmux-plugins/tmux-yank'

        # set -g @plugin 'ofirgall/tmux-window-name'

        # Persist Sessions -------------------------------
        set -g @plugin 'tmux-plugins/tmux-resurrect'
        set -g @plugin 'tmux-plugins/tmux-continuum'

        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '1'
        set -g @resurrect-strategy-nvim 'session'
        # save sessions on detach
        bind d run-shell '~/.tmux/plugins/tmux-resurrect/scripts/save.sh && tmux detach'
        # ------------------------------------------------

        # THEMES -----------------------------------------
        set-option -g status-justify centre
        set -g @plugin 'dracula/tmux'
        # https://draculatheme.com/tmux
        set -g @dracula-plugins "cpu-usage ram-usage git"
        # set -g @dracula-show-powerline true
        set -g @dracula-show-flags true
        set -g @dracula-refresh-rate 3
        set -g @dracula-show-left-icon session
        set -g @dracula-border-contrast false
        set -g @dracula-show-empty-plugins false
        # ------------------------------------------------


        set -g @plugin 'christoomey/vim-tmux-navigator'

        run '~/.tmux/plugins/tpm/tpm'
      ''
      # Muss die letzte Zeile der tmux.conf sein
      (lib.mkAfter ''
        run '${pluginDir}/tpm/tpm'
      '')
    ];
  };

  # tpm klonen/aktualisieren und die in der tmux.conf eingetragenen Plugins installieren
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

  # Autostart in der jeweils verwendeten Shell (nur wenn sie in hosts/*.nix aktiviert ist)
  programs.fish.interactiveShellInit =
    lib.mkIf config.programs.fish.enable (lib.mkAfter autostartFish);
  programs.zsh.initContent =
    lib.mkIf config.programs.zsh.enable (lib.mkAfter autostartPosix);
  programs.bash.initExtra =
    lib.mkIf config.programs.bash.enable autostartPosix;
}
