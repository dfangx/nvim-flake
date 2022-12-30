{ pkgs, lib, ... }:

with lib;
let
  baseCfg = import ./basic.nix;
in
mkMerge [
  baseCfg
  {
    vim = {
      dap = {
        enable = true;
        debuggers = {
          lldb = {
            type = "executable";
            command = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
            name = "lldb";
            env.__raw = ''
              function()
                local variables = {}
                for k, v in pairs(vim.fn.environ()) do
                  table.insert(variables, string.format("%s=%s", k, v))
                end
                return variables
              end
            '';
          };
        };
        configurations = rec {
          c = [
            {
              name = "Launch";
              type = "lldb";
              request = "launch";
              cwd = "\${workspaceFolder}";
              stopOnEntry = false;
              args = { };
              program.__raw = ''
                function() 
                  return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end
              '';
            }
            {
              name = "Attach to process";
              type = "lldb";
              request = "attach";
              pid.__raw = "require('dap.utils').pick_process";
              args = {};
            }
          ];
          cpp = c;
        };
      };

      cmp.lsp = true;

      lsp = {
        enable = true;
        servers = [
          {
            name = "ccls";
          }
        ];
      };
    };
  }
]

