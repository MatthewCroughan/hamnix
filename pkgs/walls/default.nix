{ lib
, makeDesktopItem
, symlinkJoin
, writeShellScriptBin
, runCommand
, wine
, wineFlags ? ""
, pname ? "walls"
, stateLocation ? "$HOME/.${pname}/state"
, location ? "$HOME/.${pname}"
}:

let
  desktopItems = makeDesktopItem {
    name = pname;
    exec = "${script}/bin/${pname}";
    icon = null;
    comment = "Walls cave survey software";
    desktopName = pname;
    categories = "Game;";
  };

  msiFile = builtins.fetchurl {
    url = "https://github.com/wallscavesurvey/walls/releases/download/2020-10-05/WallsInstaller-2020-10-05.msi";
    sha256 = "1a9rrzblqv26nlkx6hmb7mynycp4rsbl13xfzmhn6hr268h3nz50";
  };

  winePrefix = runCommand pname { buildInputs = [ wine ]; } ''
    export WINEARCH="win32"
    export WINEPREFIX="$TMP/tmpPrefix"
    mkdir -p $WINEPREFIX
    wine msiexec /i ${msiFile}
    sleep 5 # FIXME RACE CONDITION WITH WINE
    mv $WINEPREFIX $out
    ls -lah $out/drive_c/*
  '';

  script = writeShellScriptBin pname ''
    export WINEARCH="win32"
    export WINEPREFIX="${location}"
    PATH=${wine}/bin:$PATH
    WALLS="$WINEPREFIX/drive_c/Program Files/Walls Cave Survey/Walls v2/walls3d.exe"
    if [ ! -d "$WINEPREFIX" ]; then
      cp -r --no-preserve=mode ${winePrefix} ${location}
      mkdir -p ${stateLocation}
    fi
    ls -lah "$WINEPREFIX/drive_c/Program Files/Walls Cave Survey/Walls v2/walls3d.exe"
    wine start /d "${stateLocation}" ${wineFlags} /unix "$WALLS" "$@"
    wineserver -w
  '';
in
symlinkJoin {
  name = pname;
  paths = [ desktopItems script ];
  meta = {
    description = "Walls cave survey software";
    homepage = "https://github.com/wallscavesurvey/walls";
    maintainer = lib.maintainers.matthewcroughan;
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
