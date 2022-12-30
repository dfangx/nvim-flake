{  
  pkgs
  ,config
  ,lib ? pkgs.lib 
}:
let
  inherit (pkgs) wrapNeovim neovim-nightly;

  extendedLib = import ./lib lib;
  nvimModules = import ./modules.nix { 
    inherit pkgs; 
    lib = extendedLib;
  };

  module = extendedLib.evalModules {
    modules = [config] ++ nvimModules;
  };

  nvimCfg = module.config.vim;

  neovim = wrapNeovim neovim-nightly {
    viAlias = nvimCfg.viAlias;
    vimAlias = nvimCfg.vimAlias;
    configure = {
      customRC = nvimCfg.builtConfig;
      packages.myVimPackage = {
        start = nvimCfg.startPlugins;
        opt = nvimCfg.optPlugins;
      };
    };
  };
in
  {
    inherit neovim;
  }
