{
  description = "Declarative web app manager for home-manager";

  outputs = _: {
    homeManagerModules.default = import ./modules/home-manager.nix;
  };
}
