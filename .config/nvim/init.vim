" TODO: backups in increments
" TODO: builtin completion + emmet?
" TODO: general mappings in the end
" TODO: DAP?
" TODO: Go full lua?

" GLOBAL OPTIONS
set hidden
set ignorecase
set smartcase
set nojoinspaces
set gdefault
set inccommand=nosplit
set shortmess+=Ic
set mouse=a
set scrolloff=3
set sidescrolloff=6

" WINDOW OPTIONS
set number
set signcolumn=yes
set wrap
set list

" BUFFER OPTIONS
set textwidth=0
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2

let mapleader = " "

filetype plugin on

set statusline+=%f\ ->\ %{nvim_treesitter#statusline()}

" FOLDS
set foldlevel=99
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()


lua << EOF

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


-- Navigator --
local nav = require('Navigator')
nav.setup({
    auto_save = 'nil',
    disable_on_zoom = true
})
vim.keymap.set({'n', 't'}, '<M-h>', nav.left)
vim.keymap.set({'n', 't'}, '<M-l>', nav.right)
vim.keymap.set({'n', 't'}, '<M-k>', nav.up)
vim.keymap.set({'n', 't'}, '<M-j>', nav.down)


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
vim.keymap.set('n', '<C-p>', function() builtin.find_files({previewer=false}) end)
vim.keymap.set('n', '<A-p>', function() builtin.find_files({hidden=true, no_ignore=true, previewer=false}) end)
vim.keymap.set('n', '<leader>l', function() builtin.live_grep({grep_open_files=true}) end)
vim.keymap.set('n', '<leader>b', builtin.buffers)
vim.keymap.set('n', '<leader>h', builtin.help_tags)
vim.keymap.set('n', '<leader>/', builtin.search_history)
vim.keymap.set('n', '<leader>:', builtin.command_history)
vim.keymap.set('n', '<leader>r', builtin.resume)
vim.keymap.set('n', '<leader>y', builtin.registers)
vim.keymap.set('n', '<leader>t', builtin.lsp_document_symbols)
vim.keymap.set('n', '<leader>s', ':Telescope grep_string search=')


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

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)


vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

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


local signs = { Error = "●", Warn = "●", Hint = "●", Info = "●" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
  virtual_text = false,
})


-- Formatters -v
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
  vim.cmd 'syntax off'
end
vim.cmd 'colorscheme base16-tomorrow-night'

EOF

" General mappings "
nnoremap Y Y
nnoremap 0 _
nnoremap <leader>a ggVG
vnoremap <leader>y "*y
nnoremap <leader>Y "*Y
nnoremap <leader>p "*p
nnoremap <leader>P "*P
nnoremap <silent> <leader><BS> :noh<CR>

nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
nnoremap <leader>6 6gt
nnoremap <leader>7 7gt
nnoremap <leader>8 8gt
nnoremap <leader>9 9gt

nnoremap <leader>gg :Git<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gL :Git log --name-only<CR>
nnoremap <leader>gl :Git log %<CR>
nnoremap <leader>gb :Git blame<CR>

nnoremap <leader>db :lua require'dap'.toggle_breakpoint()<CR>
nnoremap <leader>dc :lua require'dap'.continue()<CR>

" THEME "
augroup CustomAU | au!
  autocmd ColorScheme * hi DiffAdd guibg=#1d2f21
                    \ | hi DiffDelete guibg=#2d1f21
                    \ | hi DiffChange guibg=#1c2d3b
                    \ | hi DiffText guibg=#2f4e66
                    \ | hi MatchParen guibg=#373b41
  autocmd FileType htmldjango setlocal commentstring={#\ %s\ #}
augroup END
