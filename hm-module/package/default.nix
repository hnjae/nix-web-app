{
  desktopName,
  categories ? [],
  keywords ? [],
  #
  url,
  isolateProfile,
  icon,
  #
  binary,
  variant,
  #
  writeScript,
  dash,
  runCommandLocal,
  symlinkJoin,
  makeDesktopItem,
  lib,
  ...
}: let
  appId = let
    # e.g.) "chrome-music.apple.com__-Default";
    withoutProtocol = builtins.replaceStrings ["https://" "http://"] ["" ""] url;
    urlParts = lib.splitString "/" withoutProtocol;
    domain = builtins.head urlParts;
    rest = builtins.concatStringsSep "_" (builtins.tail urlParts);
  in "${variant}-${domain}__${rest}-Default";

  desktopItemPkg = makeDesktopItem {
    inherit desktopName categories keywords;

    name = appId;
    icon = appId;

    exec = writeScript appId (
      # NOTE: Wrap with a script to use environment variables
      lib.concatLines [
        ''
          #!${dash}/bin/dash
        ''
        (
          builtins.concatStringsSep " " (
            [binary ''--app="${url}"'']
            ++ (
              lib.lists.optional isolateProfile
              ''--user-data-dir="''${XDG_STATE_HOME:-''${HOME}/.local/state}/webapp/${appId}"''
            )
          )
        )
      ]
    );

    terminal = false;

    startupWMClass = appId;
    startupNotify = false;

    type = "Application";
  };

  iconPkg = runCommandLocal appId {} ''
    mkdir -p "$out/share/icons/hicolor/scalable/apps/"

    cp --reflink=auto \
      "${icon}" \
      "$out/share/icons/hicolor/scalable/apps/${appId}.svg"

    paths=(
      "$out/share/icons/hicolor/512x512/apps/"
      "$out/share/icons/hicolor/256x256/apps/"
      "$out/share/icons/hicolor/128x128/apps/"
      "$out/share/icons/hicolor/64x64/apps/"
      "$out/share/icons/hicolor/48x48/apps/"
      "$out/share/icons/hicolor/32x32/apps/"
      "$out/share/icons/hicolor/16x16/apps/"
    )
    for path in "''${paths[@]}"; do
      mkdir -p "''$path"
      ln -s \
        "$out/share/icons/hicolor/scalable/apps/${appId}.svg" \
        "''${path}/${appId}.svg"
    done
  '';
in
  symlinkJoin {
    name = appId;
    paths = [desktopItemPkg iconPkg];
  }
