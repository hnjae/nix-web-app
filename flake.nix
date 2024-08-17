{
  description = "Declarative web app manager for home-manager";

  outputs = {
    homeManagerModules.default = import ./modules/home-manager.nix;
  };
}
