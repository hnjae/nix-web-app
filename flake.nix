{
  description = "Declarative web app manager.";

  outputs = _: {
    homeManagerModules.default = import ./modules/home-manager.nix;
    nixosModules.default = import ./modules/nixos.nix;
  };
}
