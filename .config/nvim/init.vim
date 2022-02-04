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

" set statusline+=%f\ ->\ %{nvim_treesitter#statusline()}

" ------------ LUA -------------
lua << EOF

-- PLUGINS
require 'packer'.startup(function()
  use 'wbthomason/packer.nvim'
  use 'neovim/nvim-lspconfig'
  use { 'nvim-treesitter/nvim-treesitter', run=':TSUpdate' }
  use 'mfussenegger/nvim-dap'
  -- use 'rcarriga/nvim-dap-ui'
  use 'numToStr/Navigator.nvim'
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'RRethy/nvim-base16'
  use 'tpope/vim-unimpaired'
  use 'tpope/vim-commentary'
  use 'tpope/vim-surround'
  use 'tpope/vim-repeat'
  use { 'tpope/vim-fugitive', cmd = {'Git'} }
  use { 'mattn/emmet-vim', ft={'html', 'htmldjango'} }
  use { 'Vimjas/vim-python-pep8-indent', ft={'python'} }
end)


-- Navigator
require('Navigator').setup({
    auto_save = 'current',
    disable_on_zoom = true
})

-- Telescope
local actions = require('telescope.actions')
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },
    },
  }
}

-- Mappings
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
map('n', "<M-h>", "<CMD>lua require('Navigator').left()<CR>", opts)
map('n', "<M-k>", "<CMD>lua require('Navigator').up()<CR>", opts)
map('n', "<M-l>", "<CMD>lua require('Navigator').right()<CR>", opts)
map('n', "<M-j>", "<CMD>lua require('Navigator').down()<CR>", opts)

-- LSP CONFIG
local nvim_lsp = require('lspconfig')
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  --if client.resolved_capabilities.document_formatting then
  --  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  --elseif client.resolved_capabilities.document_range_formatting then
  --  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  --end

  print("LSP")

end

-- PYTHON
nvim_lsp.pyright.setup {
  on_attach = on_attach,
  settings = {
    python = {
      venvPath = '/Users/e/.venv'
    }
  }
}

-- TYPESCRIPT
nvim_lsp.tsserver.setup {
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = false
    on_attach(client)
  end
}

-- ELM
nvim_lsp.elmls.setup {
  on_attach = on_attach
}

-- EFM
local prettier = require "efm/prettier"
local eslint = require "efm/eslint"
local black = require "efm/black"

require "lspconfig".efm.setup {
  init_options = {documentFormatting = true},
  settings = {
    rootMarkers = {".git/"},
    languages = {
      typescript = {prettier, eslint},
      python = {black}
    }
  }
}

-- DAP
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

-- no syntax highlighting when entering vim in diff mode
if vim.wo.diff then
  vim.cmd 'syntax off'
end

EOF

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
nnoremap <leader>gl :Git log --name-only<CR>
" nnoremap <leader>gp :Git push<CR>
" nnoremap <leader>gu :Git pull --ff-only<CR>
" nnoremap <leader>gr :Git pull --rebase --autostash<CR>

nnoremap <C-p> :Telescope find_files previewer=false<CR>
nnoremap <A-p> :Telescope find_files hidden=true no_ignore=true previewer=false<CR>
nnoremap <leader>s :Telescope grep_string search=
nnoremap <leader>l :Telescope live_grep grep_open_files=true<CR>
nnoremap <leader>b :Telescope buffers<CR>
nnoremap <leader>h :Telescope help_tags<CR>
nnoremap <leader>/ :Telescope search_history<CR>
nnoremap <leader>: :Telescope command_history<CR>
nnoremap <leader>r :Telescope resume<CR>

nnoremap <leader>f :lua vim.lsp.buf.formatting()<CR>

nnoremap <leader>db :lua require'dap'.toggle_breakpoint()<CR>
nnoremap <leader>dc :lua require'dap'.continue()<CR>

" THEME
augroup CustomAU | au!
  autocmd ColorScheme * hi DiffAdd guibg=#1d2f21
                    \ | hi DiffDelete guibg=#2d1f21
                    \ | hi DiffChange guibg=#1c2d3b
                    \ | hi DiffText guibg=#2f4e66
                    \ | hi MatchParen guibg=#373b41
  autocmd FileType htmldjango setlocal commentstring={#\ %s\ #}
augroup END

colorscheme base16-tomorrow-night
