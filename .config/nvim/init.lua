-- TODO: backups in increments
-- TODO: builtin completion
-- TODO: fix emmet
-- TODO: DAP?
-- TODO: Check out neogit
-- TODO: Fix S-K in vim help

-- GLOBAL OPTIONS
vim.opt.hidden = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.joinspaces = false
vim.opt.gdefault = true
vim.opt.inccommand = 'nosplit'
vim.opt.mouse = 'a'
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 6
vim.opt.shortmess:append('Ic')

-- WINDOW OPTIONS
vim.wo.number = true
vim.wo.signcolumn = 'yes'
vim.wo.wrap = true
vim.wo.list = true

-- BUFFER OPTIONS
vim.bo.expandtab = true
vim.bo.textwidth = 0
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2

-- FOLDS
vim.wo.foldlevel = 99
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'

vim.g.mapleader = ' '

-- TODO: is this needed?
vim.cmd('filetype plugin on')

vim.opt.statusline = '%f -> %{nvim_treesitter#statusline()}%=%c %p %y'

-- PLUGINS --
require 'packer'.startup(function()
  use 'wbthomason/packer.nvim'
  use 'neovim/nvim-lspconfig'
  use 'mfussenegger/nvim-dap'
  use 'rcarriga/nvim-dap-ui'
  use 'numToStr/Navigator.nvim'
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'RRethy/nvim-base16'
  use 'tpope/vim-unimpaired'
  use 'tpope/vim-surround'
  use 'tpope/vim-repeat'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'
  use { 'nvim-treesitter/nvim-treesitter', run=':TSUpdate' }  -- :TSInstall python
  use { 'mattn/emmet-vim', ft={'html', 'htmldjango'} }
end)

local key_map = vim.keymap.set

-- Navigator --
local nav = require('Navigator')
nav.setup({
    auto_save = 'nil',
    disable_on_zoom = true
})
key_map({'n', 't'}, '<M-h>', nav.left)
key_map({'n', 't'}, '<M-l>', nav.right)
key_map({'n', 't'}, '<M-k>', nav.up)
key_map({'n', 't'}, '<M-j>', nav.down)


-- Telescope --
local actions = require('telescope.actions')
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
        ['<esc>'] = actions.close,
      },
    },
  },
}
local builtin = require('telescope.builtin')
key_map('n', '<C-p>', function() builtin.find_files({previewer=false}) end)
key_map('n', '<A-p>', function() builtin.find_files({hidden=true, no_ignore=true, previewer=false}) end)
key_map('n', '<leader>l', function() builtin.live_grep({grep_open_files=true}) end)
key_map('n', '<leader>b', builtin.buffers)
key_map('n', '<leader>h', builtin.help_tags)
key_map('n', '<leader>/', builtin.search_history)
key_map('n', '<leader>:', builtin.command_history)
key_map('n', '<leader>r', builtin.resume)
key_map('n', '<leader>y', builtin.registers)
key_map('n', '<leader>t', builtin.lsp_document_symbols)
key_map('n', '<leader>s', ':Telescope grep_string search=')


---- LSP ----
local lspconfig = require('lspconfig')

-- Python --
lspconfig.pyright.setup {
  on_attach = on_attach,
  settings = {
    python = {
      venvPath = '/Users/e/.venv',
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = 'openFilesOnly',
        useLibraryCodeForTypes = true,
        typeCheckingMode = 'off'
      }
    }
  }
}

-- Typescript --
lspconfig.tsserver.setup {
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = false
    on_attach(client)
  end
}

key_map('n', '<leader>e', vim.diagnostic.open_float)
key_map('n', '[d', vim.diagnostic.goto_prev)
key_map('n', ']d', vim.diagnostic.goto_next)
key_map('n', '<leader>q', vim.diagnostic.setloclist)


vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Completion
    -- local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })

    local opts = { buffer = ev.buf, silent = true }
    key_map('n', 'gD', vim.lsp.buf.declaration, opts)
    key_map('n', 'gd', vim.lsp.buf.definition, opts)
    key_map('n', 'K', vim.lsp.buf.hover, opts)
    key_map('n', 'gi', vim.lsp.buf.implementation, opts)
    key_map('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    key_map('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    key_map('n', '<leader>rn', vim.lsp.buf.rename, opts)
    key_map('n', 'gr', vim.lsp.buf.references, opts)
    key_map({'n', 'v'}, '<leader>f', vim.lsp.buf.format, opts)

  end,
})

vim.diagnostic.config({
  virtual_text = false,
  float = { border = "single" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '●',
      [vim.diagnostic.severity.WARN] = '●',
      [vim.diagnostic.severity.HINT] = '●',
      [vim.diagnostic.severity.INFO] = '●',
    }
  }
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = "single",
})


-- Formatters
local prettier = require "efm/prettier"
local eslint = require "efm/eslint"
local black = require "efm/black"

require "lspconfig".efm.setup {
  init_options = {documentFormatting = true, documentRangeFormatting = true},
  settings = {
    rootMarkers = {".git/"},
    languages = {
      typescript = {prettier, eslint},
      python = {black}
    }
  }
}

-- DAP --
local dap = require('dap')
dap.adapters.python = {
  type = 'executable';
  command = os.getenv('HOME') .. '/.venv/debugpy/bin/python';
  args = { '-m', 'debugpy.adapter' };
}
local indxlib_autotest = function (job_name, flag)
  return {
    type = 'python';
    request = 'launch';
    name = 'autotest: ' .. job_name;
    program = '${fileDirname}/autotest.py';
    args = { '-s', '${fileBasenameNoExtension}', flag };
    pythonPath = os.getenv('HOME') .. '/.venv/indxlib/bin/python';
  }
end;
dap.configurations.python = {
  {
    type = 'python';
    request = 'launch';
    name = 'Launch file';
    program = '${file}';
    pythonPath = function()
      return '/opt/homebrew/bin/python3'
    end;
  },
  indxlib_autotest('category_index', '-i'),
  indxlib_autotest('category_get', '-c'),
  indxlib_autotest('parse_product', '-p'),
  indxlib_autotest('parse_product_multi_pid', '-u'),
}

-- require("dapui").setup()

-- MISC
if vim.wo.diff then -- no syntax highlighting in diff mode
  vim.cmd('syntax off')
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "htmldjango",
  callback = function(args)
    vim.bo[args.buf].commentstring = '{# %s #}'
  end
})

-- THEME
vim.cmd 'colorscheme base16-tomorrow-night'
vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#1d2f21" })
vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#2d1f21" })
vim.api.nvim_set_hl(0, "DiffChange", { bg = "#1c2d3b" })
vim.api.nvim_set_hl(0, "DiffText", { bg = "#2f4e66" })
vim.api.nvim_set_hl(0, "MatchParen", { bg = "#373b41" })

-- General mappings
key_map('n', 'Y', 'Y')
key_map('n', '0', '_')
key_map('n', '<leader>a', 'ggVG')
key_map('n', '<leader>y', '"*y')
key_map('n', '<leader>Y', '"*Y')
key_map('n', '<leader>p', '"*P')
key_map('n', '<leader><bs>', ':noh<cr>')

key_map('n', '<leader>1', '1gt')
key_map('n', '<leader>2', '2gt')
key_map('n', '<leader>3', '3gt')
key_map('n', '<leader>4', '4gt')
key_map('n', '<leader>5', '5gt')
key_map('n', '<leader>6', '6gt')
key_map('n', '<leader>7', '7gt')
key_map('n', '<leader>8', '8gt')
key_map('n', '<leader>9', '9gt')

key_map('n', '<leader>gg', ':Git<cr>')
key_map('n', '<leader>gc', ':Git commit<cr>')
key_map('n', '<leader>gl', ':Git log %<cr>')
key_map('n', '<leader>gL', ':Git log --name-only<cr>')
key_map('n', '<leader>gb', ':Git blame<cr>')

