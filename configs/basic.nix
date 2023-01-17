{
  vim = rec {
    viAlias = true;
    vimAlias = true;

    neorg = {
      enable = true;
      concealer = true;
      completion = {
        enable = true;
        engine = "nvim-cmp";
      };
      journal = {
        config = {
          strategy = "flat";
          workspace = "journal";
        };
      };
      dirman = {
        config = {
          workspaces = {
            journal = "~/neorg";
            notes = "~/neorg/notes";
          };
        };
      };
    };

    colorschemes = {
      colorscheme = "nord";
      nord = {
        italic = true;
        italicComments = true;
        underline = true;
        uniformDiffBackground = true;
        cursorLineNumberBackground = true;
      };
    };

    treesitter = {
      enable = true;
      highlight = true;
      fold = true;
    };

    autopairs = {
      enable = true;
      fastWrap = true;
    };

    lsp = {
      enable = true;
      defaultOnAttach = ''
        vim.o.omnifunc = 'v:lua.vim.lsp.omnifunc'
  
        -- Set autocommands conditional on server_capabilities
        if client.server_capabilities.document_highlight then
          vim.api.nvim_exec([[
            hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
            hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
            hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
            augroup lsp_document_highlight
            autocmd!
            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            augroup END
          ]], 
          false)
        end
  
        local opts = { noremap = true, silent = true }
        vim.api.nvim_buf_set_keymap(0, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', 'gc', '<cmd>lua vim.lsp.buf.incoming_calls()<cr>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', '<leader>E', '<cmd>lua vim.lsp.diagnostic.open_float()<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
      '';
      defaultCapabilities = ''
        capabilities = cmpLsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        capabilities.textDocument.completion.completionItem.resolveSupport = {
          properties = {
            'documentation',
            'detail',
            'additionalTextEdits',
          }
        }
      '';
      servers = [
        {
          name = "rnix";
        }
      ];
    };

    cmp = {
      enable = true;
      lsp = true;
      snippetEngine = "luasnip";
      sources = {
        insert = {
          cmp_luasnip = "luasnip";
          cmp-path = "path";
          cmp-nvim-lua = "nvim_lua";
        };
        search = {
          cmp-buffer = "buffer";
        };
      };
      keymaps = {
        "<TAB>" = "cmp.mapping.select_next_item()";
        "<S-TAB>" = "cmp.mapping.select_prev_item()";
        "<C-e>" = "cmp.mapping.abort()";
        "<CR>" = "cmp.mapping.confirm({ select = true })";
      };
    };

    keymaps = {
      normal = {
        "<leader>ff" = 
          if fzf.enable then
            ":FzfLua files<cr>"
          else
            ":find";
        "<leader>fs" = 
          if fzf.enable then
            ":FzfLua fzf.files({ actions = { [\\\"default\\\"] = fzfActions.file_split } })<cr>"
          else
            ":sfind";
        "<leader>fv" = 
          if fzf.enable then
            ":FzfLua fzf.files({ actions = { [\\\"default\\\"] = fzfActions.file_vsplit } })<cr>"
          else
            ":vert :sfind";
        "<leader>ft" = 
          if fzf.enable then
            ":FzfLua fzf.files({ actions = { [\\\"default\\\"] = fzfActions.file_tabedit } })<cr>"
          else
            ":tabfind";
        "S" = "a<cr><cr>";
        "<leader>O" = "O<esc>";
        "<leader>o" = "o<esc>";
        "]b" = ":bn<cr>";
        "[b" = ":bp<cr>";
        "<leader>bb" = 
          if fzf.enable then
            ":FzfLua buffers<cr>"
          else
            ":ls<cr>:b";
        "<leader>bd" = ":bd<cr>";
        "<leader>h" = { silent = true; action = "<c-w>H"; };
        "<leader>l" = { silent = true; action = "<c-w>L"; };
        "<leader>j" = { silent = true; action = "<c-w>J"; };
        "<leader>k" = { silent = true; action = "<c-w>K"; };
        "<leader>s" = "<c-w>s";
        "<leader>v" = "<c-w>v";
        "<leader><" = { silent = true; action = "10<c-w><"; };
        "<leader>>" = { silent = true; action = "10<c-w>>"; };
        "<leader>+" = { silent = true; action = "10<c-w>+"; };
        "<leader>-" = { silent = true; action = "10<c-w>-"; };
        "<c-j>" = "<c-w>j";
        "<c-k>" = "<c-w>k";
        "<c-l>" = "<c-w>l";
        "<c-h>" = "<c-w>h";
        "<space>" = "<noop>";
        "<leader>e" = "<cmd>Lexplore<cr>";
      };
    };

    globalVars = {
      mapleader = " ";
      localmapleader = " ";
      netrw_liststyle = 3;
      netrw_winsize = 20;
      netrw_banner = 0;
      netrw_altv = 1;
      tex_flavor = "latex";
      netrw_browsex_viewer = "xdg-open";
      notes_home = "~/notes";
    };

    opts = {
      set = {
        autochdir = true;
        completeopt = "menuone,noinsert,noselect";
        cursorline = true;
        lazyredraw = true;
        showcmd = true;
        wildmenu = true;
        wildmode = "list:full,full";
        showmatch = true;
        showmode = true;
        pastetoggle = "<F1>";
        hidden = true;
        history = 1000;
        writebackup = true;
        backup = false;
        undofile = true;
        foldenable = true;
        foldlevelstart = 0;
        number = true;
        relativenumber = true;
        softtabstop = 4;
        shiftwidth = 4;
        expandtab = true;
        splitbelow = true;
        splitright = true;
        omnifunc = "syntaxcomplete#Complete";
        autoread = true;
        scrolloff = 1;
        sidescrolloff = 5;
        guicursor = "";
        ignorecase = true;
        smartcase = true;
        mouse = "";
        wildignore = "*.bmp,*.gif,*.ico,*.png,*.pdf,*.psd";
      };
      append = {
        tags = ".git/tags;/";
      };
    };

    fzf.enable = true;

    lualine.enable = true;

    autocommands = {
      vimStart = {
        clear = true;
        commands = [
          {
            events = [ "VimResized" ];
            pattern = [ "*" ];
            command = "wincmd =";
          }
        ];
      };
      lsp = {
        clear = true;
        commands = [
          {
            events = [
              "BufWrite"
              "BufEnter"
              "InsertLeave"
            ];
            pattern = [ "*" ];
            command = ":lua vim.diagnostic.setloclist({open = false})";
          }
        ];
      };
    };

    userCommands = {
      W = "w";
      Q = "q";
    };
  };
}
