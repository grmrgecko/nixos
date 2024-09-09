{
  description = "Nixos config flake";

  # Package sources.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flatpaks.url = "github:GermanBread/declarative-flatpak/stable-v3";
  };

  # Flake outputs, NixOS and Home Configurations.
  outputs = inputs@{ self, flatpaks, ... }:
  let
    # Load settings.nix or the default if not exists.
    settings = (if (builtins.pathExists ./settings.nix)
                      then
                        (import ./settings.nix)
                      else
                        (import ./settings-default.nix)
                      );

    # Based on loaded settings, set the nixpkgs version.
    nixpkgs = (if (settings.packages == "stable")
              then
                inputs.nixpkgs
              else
                inputs.nixpkgs-unstable
              );

    # Based on loaded settings, set the home-manager version.
    home-manager = (if (settings.packages == "stable")
              then
                inputs.home-manager
              else
                inputs.home-manager-unstable
              );

    # Setup an overlay for unstable packages to include on stable environments.
    overlay-unstable = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = settings.system;
          config.allowUnfree = true;
        };
    };

    # Setup the main packages config with the overlays.
    pkgs = (import nixpkgs {
              system = settings.system;
              config = {
                allowUnfree = true;
                allowUnfreePredicate = (_: true);
              };
              overlays = [ overlay-unstable ];
            });

    # Function to configure a system with our defaults.
    mkSystem = config: nixpkgs.lib.nixosSystem {
      system = settings.system;
      specialArgs = {
        inherit inputs;
        inherit pkgs;
        inherit settings;
      };
      modules = [
        inputs.disko.nixosModules.disko
        home-manager.nixosModules.default
        flatpaks.nixosModules.default
        config
      ];
    };

    # Function to configure home-manager for a user.
    mkHome = config: home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit inputs;
        inherit settings;
      };
      modules = [
        flatpaks.homeManagerModules.default
        config
      ];
    };
  in {
    # NixOS configurations, in most cases we use default with a profile.
    # Any host that needs specific configurations separate from what is included by default,
    # will need its own configuration for its hostname.
    nixosConfigurations.default = mkSystem ./hosts/default/configuration.nix;
    nixosConfigurations.tama = mkSystem ./hosts/tama/configuration.nix;

    # Home manager configurations, we do the main user from the configuration and root.
    homeConfigurations = {
      ${settings.user.name} = mkHome ./users/main-user.nix;
      "root" = mkHome ./users/root.nix;
    };
  };
}
