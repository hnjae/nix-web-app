{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.web-app;
in {
  options.web-app = (import ./share/option.nix) {inherit lib pkgs;};

  config = lib.mkIf (cfg.apps != []) {
    environment.defaultPackages = (import ./share/packages) {inherit cfg pkgs;};
  };
}
