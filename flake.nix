{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, ... }:
  let
    settings = (if (builtins.pathExists ./settings.nix)
                      then
                        (import ./settings.nix)
                      else
                        (import ./settings-default.nix)
                      );

    nixpkgs = (if (settings.packages == "stable")
              then
                inputs.nixpkgs
              else
                inputs.nixpkgs-unstable
              );

    overlay-unstable = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = settings.system;
          config.allowUnfree = true;
        };
    };

    pkgs = (import nixpkgs {
              system = settings.system;
              config = {
                allowUnfree = true;
                allowUnfreePredicate = (_: true);
              };
              overlays = [ overlay-unstable ];
            });

    mkSystem = config: nixpkgs.lib.nixosSystem {
      system = settings.system;
      specialArgs = {
        inherit inputs;
        inherit pkgs;
        inherit settings;
      };
      modules = [
        config
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.default
      ];
    };

    mkHome = config: inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit inputs;
        inherit settings;
      };
      modules = [ config ];
    };
  in {
    nixosConfigurations.default = mkSystem ./hosts/default/configuration.nix;
    nixosConfigurations.tama = mkSystem ./hosts/tama/configuration.nix;

    homeConfigurations = {
      ${settings.user.name} = mkHome ./users/main-user.nix;
      "root" = mkHome ./users/root.nix;
    };
  };
}
