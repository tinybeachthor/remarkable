{ pkgs
, mach-nix
}:

let
  version = "0.8.2";

  paper2remarkable = mach-nix.mkPython {
    requirements = ''
      paper2remarkable == ${version}
    '';
    ignoreDataOutdated = true;
  };

in

pkgs.runCommand "p2r" {
  buildInputs = with pkgs; [
    makeWrapper

    cairo
    glib
    pango
    imagemagick
  ];
  propagatedBuildInputs = with pkgs; [
    pdftk
    ghostscript
    rmapi

    poppler
  ];
} ''
  mkdir $out

  mkdir $out/bin
  makeWrapper ${paper2remarkable}/bin/p2r $out/bin/p2r \
    --prefix LD_LIBRARY_PATH : ${pkgs.stdenv.lib.makeLibraryPath (with pkgs; [
      cairo
      glib.out
      pango.out
      imagemagick
    ])} \
    --prefix PATH : ${pkgs.stdenv.lib.makeBinPath (with pkgs; [
      ghostscript
      poppler
      pdftk
      rmapi
    ])} \
''
