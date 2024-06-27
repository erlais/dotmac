-- TODO: builtin completion
-- TODO: snippets
-- TODO: DAP?
-- TODO: A different python ls?
-- TODO: Add js, html ls and their formatting tools

-------------------------------------------------------------------------------
-- Options --------------------------------------------------------------------
-------------------------------------------------------------------------------
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
vim.opt.statusline = ' %f%m %=%l,%c   %p%%   [%{&fileencoding?&fileencoding:&encoding}] '

vim.wo.number = true
vim.wo.signcolumn = 'yes'
vim.wo.wrap = true
vim.wo.list = true
vim.wo.foldlevel = 99
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'

vim.bo.expandtab = true
vim.bo.textwidth = 0
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2

vim.g.mapleader = ' '


-------------------------------------------------------------------------------
-- Backups --------------------------------------------------------------------
-------------------------------------------------------------------------------
vim.opt.backup = true
vim.opt.backupdir = os.getenv("HOME") .. '/.local/share/nvim/backup//'
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('timestamp_backup', { clear = true }),
  pattern = '*',
  callback = function()
    vim.opt.backupext = '-' .. vim.fn.strftime('%Y-%m-%d_%H%M')
  end,
})


-------------------------------------------------------------------------------
-- Plugin Init ----------------------------------------------------------------
-------------------------------------------------------------------------------
require('packer').startup(function()
  use 'wbthomason/packer.nvim'

  -- lsp
  use 'neovim/nvim-lspconfig'
  use 'mfussenegger/nvim-dap'
  use 'rcarriga/nvim-dap-ui'
  use 'mattn/emmet-vim'
  use { 'nvim-treesitter/nvim-treesitter', run=':TSUpdate' }
  -- :TSInstall python, lua, markdown, vimdoc, help etc...

  -- git
  use 'sindrets/diffview.nvim'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'

  -- utils
  use 'numToStr/Navigator.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'tpope/vim-unimpaired'
  use 'tpope/vim-surround'
  use 'tpope/vim-repeat'

  -- dependencies
  use 'nvim-tree/nvim-web-devicons'
  use 'nvim-lua/plenary.nvim'

  -- theme
  use 'RRethy/nvim-base16'

end)


-------------------------------------------------------------------------------
-- Plugin: Navigator ----------------------------------------------------------
-------------------------------------------------------------------------------
local nav = require('Navigator')
nav.setup({
    auto_save = 'nil',
    disable_on_zoom = true
})
vim.keymap.set({'n', 't'}, '<M-h>', nav.left)
vim.keymap.set({'n', 't'}, '<M-l>', nav.right)
vim.keymap.set({'n', 't'}, '<M-k>', nav.up)
vim.keymap.set({'n', 't'}, '<M-j>', nav.down)


-------------------------------------------------------------------------------
-- Plugin: Telescope ----------------------------------------------------------
-------------------------------------------------------------------------------
local ta = require('telescope.actions')
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ['<C-j>'] = ta.move_selection_next,
        ['<C-k>'] = ta.move_selection_previous,
        ['<esc>'] = ta.close,
      },
    },
  },
}
local tb = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', function() tb.find_files({previewer=false}) end)
vim.keymap.set('n', '<A-p>', function() tb.find_files({hidden=true, no_ignore=true, previewer=false}) end)
vim.keymap.set('n', '<leader>l', function() tb.live_grep({grep_open_files=true}) end)
vim.keymap.set('n', '<leader>b', tb.buffers)
vim.keymap.set('n', '<leader>h', tb.help_tags)
vim.keymap.set('n', '<leader>/', tb.search_history)
vim.keymap.set('n', '<leader>:', tb.command_history)
vim.keymap.set('n', '<leader>r', tb.resume)
vim.keymap.set('n', '<leader>y', tb.registers)
vim.keymap.set('n', '<leader>t', tb.lsp_document_symbols)
vim.keymap.set('n', '<leader>s', ':telescope grep_string search=')


-------------------------------------------------------------------------------
-- Plugin: Git Tools ----------------------------------------------------------
-------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>gg', ':Git<cr>')
vim.keymap.set('n', '<leader>gc', ':Git commit<cr>')
vim.keymap.set('n', '<leader>gb', ':Git blame<cr>')
vim.keymap.set('n', '<leader>gd', ':DiffviewOpen<cr>')
vim.keymap.set('n', '<leader>gl', ':DiffviewFileHistory %<cr>')
vim.keymap.set('n', '<leader>gL', ':DiffviewFileHistory<cr>')


-------------------------------------------------------------------------------
-- LSP: Language Configs ------------------------------------------------------
-------------------------------------------------------------------------------

-- Python
require'lspconfig'.ruff_lsp.setup{}  -- ruff for formatting
require('lspconfig').pyright.setup {
  settings = {
    python = {
      venvPath = '/Users/e/.venv',
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = 'openFilesOnly',
        useLibraryCodeForTypes = true,
        typeCheckingMode = 'off',
      }
    }
  }
}

-- Typescript
require('lspconfig').tsserver.setup {
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = false
    on_attach(client)
  end
}

-------------------------------------------------------------------------------
-- LSP: Global Mappings -------------------------------------------------------
-------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)


-------------------------------------------------------------------------------
-- LSP: Attach & Buffer Mappings ----------------------------------------------
-------------------------------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Completion
    -- local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })

    local opts = { buffer = ev.buf, silent = true }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set({'n', 'v'}, '<leader>f', vim.lsp.buf.format, opts)

  end,
})

-------------------------------------------------------------------------------
-- LSP: Diagnostics -----------------------------------------------------------
-------------------------------------------------------------------------------
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


-------------------------------------------------------------------------------
-- LSP: Styling ---------------------------------------------------------------
-------------------------------------------------------------------------------
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = "single",
})


-------------------------------------------------------------------------------
-- LSP: Formatters ------------------------------------------------------------
-------------------------------------------------------------------------------
local prettier = require "efm/prettier"
local eslint = require "efm/eslint"
local black = require "efm/black"

-- require "lspconfig".efm.setup {
--   filetypes = { 'python', 'typescript'},
--   init_options = {documentFormatting = true, documentRangeFormatting = true},
--   settings = {
--     rootMarkers = {".git/"},
--     languages = {
--       typescript = {prettier, eslint},
--       python = {black},
--     }
--   }
-- }


-------------------------------------------------------------------------------
-- DAP (TODO) -----------------------------------------------------------------
-------------------------------------------------------------------------------
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


-------------------------------------------------------------------------------
-- Filetype Options -----------------------------------------------------------
-------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "htmldjango",
  callback = function(args)
    vim.bo[args.buf].commentstring = '{# %s #}'
  end
})


-------------------------------------------------------------------------------
-- Theme ----------------------------------------------------------------------
-------------------------------------------------------------------------------
vim.cmd 'colorscheme base16-tomorrow-night'
vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#1d2f21" })
vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#2d1f21" })
vim.api.nvim_set_hl(0, "DiffChange", { bg = "#1c2d3b" })
vim.api.nvim_set_hl(0, "DiffText", { bg = "#2f4e66" })
vim.api.nvim_set_hl(0, "MatchParen", { bg = "#373b41" })
if vim.wo.diff then
  vim.cmd('syntax off')
end


-------------------------------------------------------------------------------
-- General Mappings -----------------------------------------------------------
-------------------------------------------------------------------------------
vim.keymap.set('n', 'Y', 'Y')
vim.keymap.set('n', '0', '_')
vim.keymap.set('n', '<leader>a', 'ggVG')
vim.keymap.set('v', '<leader>y', '"*y')
vim.keymap.set('v', '<leader>Y', '"*Y')
vim.keymap.set('n', '<leader>p', '"*P')
vim.keymap.set('n', '<leader><bs>', ':noh<cr>')
vim.keymap.set('n', '<leader><del>', ':tabclose<cr>')

vim.keymap.set('n', '<leader>1', '1gt')
vim.keymap.set('n', '<leader>2', '2gt')
vim.keymap.set('n', '<leader>3', '3gt')
vim.keymap.set('n', '<leader>4', '4gt')
vim.keymap.set('n', '<leader>5', '5gt')
vim.keymap.set('n', '<leader>6', '6gt')
vim.keymap.set('n', '<leader>7', '7gt')
vim.keymap.set('n', '<leader>8', '8gt')
vim.keymap.set('n', '<leader>9', '9gt')

vim.keymap.set('n', '<leader>x', function() print(vim.fn['nvim_treesitter#statusline']()) end)
