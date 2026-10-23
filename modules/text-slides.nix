{ config, lib, pkgs, ... }:

let
  srcDir = "${config.xdg.dataHome}/text-slides";

  # GHC from Nix: properly wrapped, so it finds gmp etc. without any linker tricks.
  # Stack is told to use it instead of downloading its own GHC (see below).
  ghc = pkgs.haskell.compiler.ghc910;

  # Libraries the Haskell toolchain needs to link against
  libs = [ pkgs.gmp pkgs.zlib pkgs.ncurses ];
  libFlags = lib.concatMapStringsSep " "
    (p: "--extra-lib-dirs=${lib.getLib p}/lib --extra-include-dirs=${lib.getDev p}/include") libs;
  libPath = lib.makeLibraryPath libs;
  ldFlags = lib.concatMapStringsSep " " (p: "-L${lib.getLib p}/lib -rpath ${lib.getLib p}/lib") libs;
  incFlags = lib.concatMapStringsSep " " (p: "-isystem ${lib.getDev p}/include") libs;
in
{
  home.packages = with pkgs; [
    stack
    pandoc        # text-slides calls pandoc at runtime
    mermaid-cli   # needed for ~~~mermaid blocks
  ];

  # `stack install` puts the binary into ~/.local/bin
  home.sessionPath = [ "$HOME/.local/bin" ];

  # Clone/update the repo and (re)build text-slides with stack on every switch
  home.activation.textSlides = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Activation runs with a minimal PATH, so everything stack needs must be listed here.
    # /usr/bin comes last as a fallback for host tools (e.g. ldd, which matches the host glibc).
    export PATH="${lib.makeBinPath [ pkgs.git pkgs.stack ghc pkgs.gcc pkgs.gnumake pkgs.perl pkgs.gawk pkgs.gnutar pkgs.gzip pkgs.bzip2 pkgs.xz pkgs.curl pkgs.pkg-config ]}:$PATH:/usr/bin"

    # Make the Nix gcc/linker find gmp, zlib and ncurses
    export LIBRARY_PATH="${libPath}:''${LIBRARY_PATH:-}"
    export NIX_LDFLAGS="${ldFlags} ''${NIX_LDFLAGS:-}"
    export NIX_CFLAGS_COMPILE="${incFlags} ''${NIX_CFLAGS_COMPILE:-}"

    if [ ! -d "${srcDir}/.git" ]; then
      run mkdir -p "$(dirname "${srcDir}")"
      run git clone https://github.com/skogsbaer/text-slides "${srcDir}" \
        || echo "text-slides: clone failed"
    else
      run git -C "${srcDir}" pull --ff-only \
        || echo "text-slides: pull failed, keeping current version"
    fi

    if [ -d "${srcDir}" ]; then
      # The first build compiles all dependencies (takes a while)
      (
        cd "${srcDir}"
        # Use the Nix GHC; --compiler overrides the exact version pinned by the resolver
        ghc_ver="$(ghc --numeric-version)"
        run stack install --system-ghc --no-install-ghc --compiler "ghc-$ghc_ver" ${libFlags}
      ) \
        || echo "text-slides: build failed"
    fi
  '';
}
