{
  description = "My Neovim config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
  };

  outputs = { nixpkgs, flake-utils, ... } @inputs:
    flake-utils.lib.eachDefaultSystem(system:
      let
        pkgs = import nixpkgs { 
          inherit system; 
          overlays = [
            inputs.neovim-nightly-overlay.overlay
            inputs.neorg-overlay.overlays.default
          ];
        };
        nvimBin = pkg: "${pkg}/bin/nvim";
        bldNeovimCfg = {pkgs, modules ? []}: import ./modules {
          inherit pkgs;
          config = { ... }: {
            imports = modules;
          };
        };
        bldNeovimPkg = pkgs: modules: (bldNeovimCfg {inherit pkgs modules;}).neovim;

        nvimBaseCfg = import ./configs/basic.nix;
        nvimRustCfg = import ./configs/rust.nix { inherit pkgs; lib = pkgs.lib; };
        nvimCCfg = import ./configs/c.nix { inherit pkgs; lib = pkgs.lib; };

        nvimPkg = bldNeovimPkg pkgs [ nvimBaseCfg ];
        nvimRustPkg = bldNeovimPkg pkgs [ nvimRustCfg ];
        nvimCPkg = bldNeovimPkg pkgs [ nvimCCfg ];
      in
      {
        lib = {
          nvim = (import ./modules/lib pkgs.lib).nvim;
          inherit bldNeovimCfg;
        };

        overlays.default = final: prev: {
          neovim-nix = nvimPkg;
          neovim-nix-rs = nvimRustPkg;
          neovim-nix-c = nvimCPkg;
        };

        apps = rec {
          neovim-nix = {
            type = "app";
            program = nvimBin nvimPkg;
          };
          neovim-nix-rs = {
            type = "app";
            program = nvimBin nvimRustPkg;
          };
          neovim-nix-c = {
            type = "app";
            program = nvimBin nvimCPkg;
          };
          default = neovim-nix;
        };

        packages = rec {
          neovim-nix = nvimPkg;
          neovim-nix-rs = nvimRustPkg;
          neovim-nix-c = nvimCPkg;
          default = neovim-nix;
        };
      }
    );
}
