# dotfiles

> **Personal use only.** This repository is my own dotfiles setup. It is built
> for my machines and my habits, and it may lack professionalism: expect
> hardcoded values, rough edges, missing documentation and opinionated choices.
> Feel free to look around or borrow ideas, but use it at your own risk and don't
> expect support.

Declarative dotfiles managed with [Nix](https://nixos.org) flakes and
[Home Manager](https://github.com/nix-community/home-manager).

## Hosts

| Name      | System                     | Shell |
|-----------|----------------------------|-------|
| `cachyos` | CachyOS (x86_64-linux)     | fish  |
| `macos`   | macOS (aarch64-darwin)     | zsh   |
| `wsl`     | WSL, work environment      | bash  |

## What's included

- **Neovim** with all dependencies for [LazyVim](https://www.lazyvim.org)
  (compiler, ripgrep, fd, lazygit, Nerd Font, ...). The Neovim config itself
  lives in a separate git repository and is cloned/updated to `~/.config/nvim`
  on every switch.
- **tmux** with [tpm](https://github.com/tmux-plugins/tpm), started
  automatically in interactive shells (set `NO_TMUX=1` to skip it).
- **.NET SDK** (latest stable).
- **Shell setup** per host (fish, zsh or bash).

## Layout

```
.
├── Makefile          # shortcuts for the common commands
├── setup.sh          # installs Nix on a fresh machine
├── flake.nix         # inputs and one Home Manager configuration per host
├── home.nix          # configuration shared by all hosts
├── hosts/            # host-specific parts (currently: which shell)
│   ├── cachyos.nix
│   ├── macos.nix
│   └── wsl.nix
└── modules/
    ├── dotnet.nix
    ├── neovim.nix
    ├── tmux.nix
    └── shells/       # fish.nix, zsh.nix, bash.nix
```

## Usage

Requires Nix with flakes enabled (`experimental-features = nix-command flakes`).
On a fresh machine, `setup.sh` takes care of installing Nix (see below).

```bash
make              # list all targets
make switch       # build and activate the config for the current host
make build        # build only, don't activate
make update       # update all flake inputs
make update-nixpkgs
make generations  # list Home Manager generations
make gc           # remove old generations and unused store paths
```

The host is detected automatically (macOS, WSL, otherwise CachyOS). Override it
with `make switch HOST=wsl`.

### First setup on a new machine

1. Clone this repository anywhere you like.
2. Run `./setup.sh` to install Nix. Open a new shell afterwards so that `nix`
   is in your `PATH`.
3. Make sure flakes are enabled (`experimental-features = nix-command flakes`),
   in case `setup.sh` didn't already do that.
4. Check `username` and `homeDirectory` for the host in `flake.nix`.
5. Run `make switch`. Existing files that Home Manager wants to manage are
   renamed with a `.backup` suffix.

## Notes

- Flakes only see files known to git, so new files must be staged. `make switch`
  and `make build` do this automatically (`git add -A`).
- The Neovim config is deliberately **not** managed by Home Manager, because
  LazyVim writes into its own config directory (`lazy-lock.json`, ...).
- If the nvim config repo can't be cloned, an existing `~/.config/nvim` is left
  untouched.