{
  description = "A nixvim configuration";

  inputs = {
    nixpkgs = {url = "github:nixos/nixpkgs/nixos-24.11";};
    nixvim = {url = "github:nix-community/nixvim";};
    flake-utils = {url = "github:numtide/flake-utils";};
  };

  outputs = { self, nixpkgs, nixvim, flake-utils, ... }@inputs:
    let config = import ./config; # import the module directly
    in
    {
      nixvimModule = config;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        nixvimLib = nixvim.lib.${system};
        pkgs = import nixpkgs { inherit system; };
        nixvim' = nixvim.legacyPackages.${system};
        nvim = nixvim'.makeNixvimWithModule {
          inherit pkgs;
          module = config;
            
        };
      in
      {
        formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;

        checks = {
          default = nixvimLib.check.mkTestDerivationFromNvim {
            inherit nvim;
            name = "My nixvim configuration";
          };
        };


        packages = {
          # Lets you run `nix run .` to start nixvim
          default = nvim;
        };

        devShells.default = import ./shell.nix { inherit pkgs; };
      });
}
