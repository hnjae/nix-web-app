{
  cfg,
  pkgs,
}:
builtins.map
(
  app: (
    pkgs.callPackage ./web-app (let
      executor =
        if (app.executor == null)
        then cfg.executor
        else app.executor;
    in {
      inherit
        (app)
        desktopName
        categories
        keywords
        isolateProfile
        url
        icon
        ;
      inherit (executor) variant binary;
    })
  )
)
cfg.apps
