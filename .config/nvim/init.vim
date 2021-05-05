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

" THEME
augroup MyColors
  autocmd!
  autocmd ColorScheme * hi Visual ctermbg=0
                    \ | hi! link SignColumn LspDiagnosticsDefaultError
augroup END
colorscheme peachpuff

" ------------- LUA ------------- 
lua << EOF

-- PLUGIN MANAGER
vim.cmd 'packadd paq-nvim'
local paq = require'paq-nvim'.paq
paq { 'savq/paq-nvim', opt=true }

-- PLUGINS
paq 'neovim/nvim-lspconfig'
paq 'numToStr/Navigator.nvim'

-- Navigator
require('Navigator').setup({
    auto_save = 'current',
    disable_on_zoom = true
})
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
map('n', "<M-h>", "<CMD>lua require('Navigator').left()<CR>", opts)
map('n', "<M-k>", "<CMD>lua require('Navigator').up()<CR>", opts)
map('n', "<M-l>", "<CMD>lua require('Navigator').right()<CR>", opts)
map('n', "<M-j>", "<CMD>lua require('Navigator').down()<CR>", opts)
map('n', "<M-p>", "<CMD>lua require('Navigator').previous()<CR>", opts)

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

  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

end

-- no syntax highlighting when entering vim in diff mode
if vim.wo.diff then vim.cmd 'syntax off' end

EOF
