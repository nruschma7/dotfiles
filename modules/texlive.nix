{ ... }:

{
  programs.texlive = {
    enable = true;

    # scheme-medium covers pandoc/beamer PDF output; the extra collection adds
    # more LaTeX packages (including mylatexformat for text-slides).
    # Switch to `scheme-full` if you want everything (several GB).
    extraPackages = tpkgs: {
      inherit (tpkgs)
        scheme-medium
        collection-latexextra
        ;
    };
  };
}
