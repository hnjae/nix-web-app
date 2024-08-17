{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
  typeExecutor = types.submodule {
    options = {
      binary = mkOption {
        type = types.either types.path types.nonEmptyStr;
        description = ''
          The binary to run the web app. This must be a Chromium-based browser
          and should support the `user-data-dir` and `app` flags.

          You shall include the following arguments in `commandLineArgs`.

            * --ozone-platform-hint=auto
            * --enable-features=UseOzonePlatform

          If you are unsure, it might be helpful to start with the example below.

          If you do not add these arguments, the WM_CLASS will be the browser
          you specified. This means your desktop environment or other programs
          might not be able to distinguish between the installed web app and the
          browser.
        '';
        example = "${
          pkgs.ungoogled-chromium.override {
            enableWideVine = true;
            commandLineArgs =
              builtins.concatStringsSep
              " " [
                "--ozone-platform-hint=auto"
                "--enable-features=UseOzonePlatform"
              ];
          }
        }/bin/chromium";
      };
      variant = mkOption {
        type = types.str;
        description = ''
          The type of chromium. This value becomes the prefix of the WM_CLASS
          of the web app being created.

          You should use the following values.

            * Chromium/Google Chrome: chrome
            * Brave: brave.
            * Microsoft Edge: msedge

          If icons are not visible or things are not working properly, you may
          need to check the WM_CLASS value. It should follow a pattern like
          "chrome-music.apple.com__-Default".

          For browsers not on the list, check the WM_CLASS and use its prefix.
        '';
      };
    };
  };
in {
  enable = mkEnableOption "enable web-app";
  executor = mkOption {
    type = typeExecutor;
    default = {
      binary = "${
        pkgs.ungoogled-chromium.override {
          enableWideVine = true;
          commandLineArgs =
            builtins.concatStringsSep
            " " [
              "--ozone-platform-hint=auto"
              "--enable-features=UseOzonePlatform"
            ];
        }
      }/bin/chromium";
      variant = "chrome";
    };
  };
  apps = mkOption {
    type = types.listOf (
      types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
          };
          desktopName = mkOption {
            type = types.str;
            description = ''
              Name of the web app shown in the menu.
            '';
          };
          url = mkOption {
            type = types.str;
            example = "https://music.apple.com";
            apply = url: (
              let
                inherit (builtins) substring stringLength;
                urlLen = stringLength url;
                lastChar = substring (urlLen - 1) 1 url;
              in
                if lastChar == "/"
                then substring 0 (urlLen - 1) url
                else url
            );
          };
          icon = mkOption {
            type = types.path;
            default = "${pkgs.whitesur-icon-theme}/share/icons/WhiteSur/apps/scalable/chromium.svg";
            description = "
                Path of the app icon.

                Icons that are not in SVG format have not been tested.
              ";
          };
          isolateProfile = mkOption {
            type = types.bool;
            default = true;
            description = ''
              This option determines whether to isolate the profile of the web app.

              When you open a link in the web app, it will be handled within
              the same profile as the web app. Therefore, if you frequently
              open links in the web app, you might consider using the default
              browser profile instead of creating an isolated one.

              Isolated profile will be located under the XDG_STATE_HOME directory.
            '';
          };
          executor = mkOption {
            type = types.nullOr typeExecutor;
            default = null;
            description = "application-specific executor";
          };
          categories = mkOption {
            type = types.listOf types.str;
            default = [];
            example = ["Utility"];
          };
          keywords = mkOption {
            type = types.listOf types.str;
            default = [];
            example = ["Video" "Player"];
          };
        };
      }
    );
  };
}
