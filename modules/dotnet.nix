{ pkgs, ... }:

let
  dotnetSdk = pkgs.dotnetCorePackages.sdk_10_0;
in
{
  home.packages = [ dotnetSdk ];
}
