syntax on
set mouse=a
set nu
set nowrap

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set relativenumber
set scrolloff=8
" thick cursor when enter insert mode
set guicursor=""
" no highlight search
set nohlsearch

set noswapfile
set nobackup
set undofile
set undodir=$HOME/.vim/undodir


set signcolumn=yes



let mapleader=" "

call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

" Make sure you use single quotes

" On-demand loading
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'morhetz/gruvbox'

" Use release branch (recommended)
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'honza/vim-snippets'
Plug 'vim-airline/vim-airline'

" Plug '~/share-dir/wenhaoxiong/test-plugin'
"
" lsp
"
"  Uncomment these if you want to manage LSP servers from neovim
" Plug 'williamboman/mason.nvim'
" Plug 'williamboman/mason-lspconfig.nvim'

" LSP Support
Plug 'neovim/nvim-lspconfig'
" Autocompletion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

" git Support
Plug 'tpope/vim-fugitive'

" undo tree
Plug 'mbbill/undotree'

" auto pairs
Plug 'windwp/nvim-autopairs'

" comments
Plug 'numToStr/Comment.nvim'

" Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v3.x'}

call plug#end()
" You can revert the settings after the call like so:
"   filetype indent off   " Disable file-type-specific indentation
"   syntax off            " Disable syntax highlighting
"

" let g:coc_disable_startup_warning = 1
"source ~/.config/nvim/config/coc.vim
source ~/.config/nvim/config/nerdtree.vim
source ~/.config/nvim/config/remap.vim
"source ~/.config/nvim/config/coc-git.vim
source ~/.config/nvim/config/fzf.vim
source ~/.config/nvim/config/undotree.vim

lua require('wenhaoxiong')
lua require('auto-pairs')
lua require('comments')

set background=dark
colorscheme gruvbox
