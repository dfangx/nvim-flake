{ config, pkgs, lib, ... }:
{
  imports = [
    ./options.nix
    ./mappings.nix
    ./core.nix
  ];
}
