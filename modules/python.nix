# python.nix
{ pkgs, ... }:

let
  # Build a custom Python 3 environment bundling libtmux and pip
  tmuxPython = pkgs.python3.withPackages (ps: with ps; [
    libtmux
    pip
  ]);
in
{
  # Expose the wrapped python3 (with libtmux built-in) to user's PATH
  home.packages = [
    tmuxPython
  ];

  xdg.configFile."pip/pip.conf".text = ''
    [global]
    break-system-packages = true
  '';
}
