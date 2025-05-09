{
  appimageTools,
  fetchurl,
  webkitgtk_4_1,
  libsoup_3,
  libpng,
  lib,
}:
let
  pname = "qidi-slicer";
  version = "1.2.3";

  src = fetchurl {
    url = "https://github.com/QIDITECH/QIDISlicer/releases/download/V${version}/QIDISlicer_${version}_Linux_Ubuntu24.AppImage";
    hash = "sha256-76bdVQu+xCf6uCwkHcpLNNna5MgHm4vbuwMFoQ26N0Y=";
  };

  appimageContents = appimageTools.extract {
    inherit version pname src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraPkgs = pkgs: [
    webkitgtk_4_1
    libsoup_3
    libpng
  ];

  extraInstallCommands = ''
    ln -s "$out/bin/qidi-slicer" "$out/bin/qidi-gcodeviewer"
    install -m 444 -D ${appimageContents}/QIDISlicer.desktop $out/share/applications/QIDISlicer.desktop
    install -m 444 -D ${appimageContents}/usr/bin/resources/icons/QIDISlicer.svg $out/share/icons/hicolor/scalable/apps/QIDISlicer.svg
  '';

  meta = {
    description = "Slicer for QIDI 3D Printers, based on PrusaSlicer";
    longDescription = ''
      QIDISlicer is a 3D printer slicing software that works with all QIDI Technology printers and filaments.
      It is easy to use and has all the functions you need to learn 3D printing.
    '';
    homepage = "https://github.com/QIDITECH/QIDISlicer";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ j0hax ];
    mainProgram = "qidi-slicer";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
