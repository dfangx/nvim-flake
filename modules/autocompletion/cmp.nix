{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.vim.cmp;
  srcType = type: mkOption {
    type = types.attrsOf types.str;
    default = { };
    description = "Completion package and source names for ${type}";
  };
in
{
  options.vim.cmp = {
    enable = mkEnableOption "Whether to enable nvim-cmp";
    lsp = mkEnableOption ''
      Enable LSP support. When enabled, the following sources are added:
        Insert:
          - nvim_lsp
          - nvim_lsp_signature_help
        Search:
          - nvim_lsp_document_symbol
          - buffer
      LSP capabilities are exposed through: cmpLsp = require'cmp_nvim_lsp'
    '';
    sources = mkOption {
      type = types.submodule {
        options = {
          insert = srcType "insert";
          search = srcType "search";
        };
      };
      description = "Completion sources";
      default = { };
    };

    snippetEngine = mkOption {
      type = types.enum [ "luasnip" ];
      default = "luasnip";
      description = "Snippet engine to use. By default, luasnip is enabled.";
    };

    keymaps = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Mappings for cmp";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = map (s: pkgs.vimPlugins."${s}" ) ([
      "nvim-cmp"
      cfg.snippetEngine
    ]
    ++ (attrNames cfg.sources.insert)
    ++ (attrNames cfg.sources.search));

    vim.cmp.sources = mkIf cfg.lsp {
      insert = {
        cmp-nvim-lsp = "nvim_lsp";
        cmp-nvim-lsp-signature-help = "nvim_lsp_signature_help";
      };
      search = {
        cmp-nvim-lsp-document-symbol = "nvim_lsp_document_symbol";
        cmp-buffer = "buffer";
      };
    };

    vim.luaRequires = mkIf cfg.lsp {
      cmpLsp = "cmp_nvim_lsp";
    };
    
    vim.luaConfig = let
      cmpInsSources = mapAttrsToList (_: n: { name = n; }) cfg.sources.insert;
      cmpSearchSources = mapAttrsToList (_: n: { name = n; }) cfg.sources.search;
      snippetLuaCmd = optionalString (cfg.snippetEngine == "luasnip") "require'luasnip'.lsp_expand(args.body)";
      rawMappings = mapAttrs (k: v: { __raw = v; }) cfg.keymaps;
    in
    ''
      local cmp = require'cmp'
      cmp.setup({
        snippet = {
            expand = function(args)
                ${snippetLuaCmd}
            end
        },
        mapping = cmp.mapping.preset.insert(${nvim.lua.toLuaObject rawMappings}),
        sources = cmp.config.sources(${nvim.lua.toLuaObject cmpInsSources})
      })
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(${nvim.lua.toLuaObject cmpSearchSources})
      })
    '';
  };
}
