{ pkgs, lib, ... }:

let
  # Browser used by Puppeteer: google-chrome from Nix on every platform
  chromeBinary = "${pkgs.google-chrome}/bin/google-chrome";

  puppeteerConfig = pkgs.writeText "puppeteer-config.json" (builtins.toJSON {
    executablePath = chromeBinary;
    headless = true;
    # Needed in WSL / containers; harmless elsewhere
    args = [ "--no-sandbox" ];
  });

  # mmdc with the Puppeteer config always applied
  mermaid-cli = pkgs.symlinkJoin {
    name = "mermaid-cli-wrapped";
    paths = [ pkgs.mermaid-cli ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/mmdc --add-flags "-p ${puppeteerConfig}"
    '';
  };
in
{
  # google-chrome is unfree
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "google-chrome" ];

  home.packages = [ mermaid-cli pkgs.google-chrome ];
}
