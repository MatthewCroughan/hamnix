{ lib
, makeDesktopItem
, symlinkJoin
, writeShellScriptBin

, winetricks
, xvfb-run

, wine
, wineFlags ? ""
, pname ? "rufzxp"
, stateLocation ? "$HOME/.rufzxp/state"
, location ? "$HOME/.rufzxp"
, tricks ? [ "dotnet20" ]
}:

let
  src = builtins.fetchurl {
    url = "https://www.rufzxp.net/software/rufzxp_fw2_0_setup_1_1_2.exe";
    name = "rufzxp_fw2_0_setup_1_1_2.exe";
    sha256 = "1wxin6mm1f5xzys0nb8m6xrwq5j7kckfvs4h1kw2ahg4c9hp84zz";
  };
  icon = null;

  # concat winetricks args
  tricksFmt = with builtins;
    if (length tricks) > 0 then
      concatStringsSep " " tricks
    else
      "-V";

  script = writeShellScriptBin pname ''
    export WINEARCH="win64"
    export WINEPREFIX="${location}"
    PATH=${wine}/bin:${winetricks}/bin:${xvfb-run}/bin:$PATH
    USER="$(whoami)"
    RUFZXP="$WINEPREFIX/drive_c/Program Files/RufzXP/RufzXP.exe"
    if [ ! -d "$WINEPREFIX" ]; then
      # install tricks
      xvfb-run sh -c 'winetricks -q -f ${tricksFmt}'
      wineserver -k
      # install RufzXP
      xvfb-run sh -c 'wine ${src} /silent'
      wineserver -k
    fi
    mkdir ${stateLocation}
    wine start /d "${stateLocation}" ${wineFlags} /unix "$RUFZXP" "$@"
    wineserver -w
  '';

  desktopItems = makeDesktopItem {
    name = pname;
    exec = "${script}/bin/${pname}";
    inherit icon;
    comment = "RufzXP is an excellent training software for improving code speed and CW practice, particularly (ultra) high speed memory copying of true amateur radio calls.";
    desktopName = "RufzXP";
    categories = "Game;";
  };

in
symlinkJoin {
  name = pname;
  paths = [ desktopItems script ];

  meta = {
    description = "RufzXP installer and runner";
    homepage = "https://www.rufzxp.net/";
    maintainer = lib.maintainers.matthewcroughan;
    platforms = with lib.platforms; [ "i686-linux" "x86_64-linux" ];
  };
}
