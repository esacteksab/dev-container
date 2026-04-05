" -----------------------------------------------------------------------
" Basics
" -----------------------------------------------------------------------
set nocompatible          " Use Vim defaults, not Vi

" -----------------------------------------------------------------------
" Appearance & syntax
" -----------------------------------------------------------------------
syntax enable             " Enable syntax highlighting
set background=dark       " Assume a dark terminal background
" set number                " Show line numbers
" set cursorline            " Highlight the current line
set showmatch             " Briefly jump to matching bracket on insert
set nowrap                " Don't soft-wrap long lines

" -----------------------------------------------------------------------
" Indentation
" -----------------------------------------------------------------------
set expandtab             " Insert spaces instead of tabs
set tabstop=4             " Width of a tab character
set shiftwidth=4          " Width used by >> / << and auto-indent
set softtabstop=4         " Spaces inserted/removed when pressing Tab/Backspace
set autoindent
set smartindent

" -----------------------------------------------------------------------
" Search
" -----------------------------------------------------------------------
set hlsearch              " Highlight search matches
set incsearch             " Show matches as you type
set ignorecase            " Case-insensitive search …
set smartcase             " … unless the pattern contains an uppercase letter

" -----------------------------------------------------------------------
" Usability
" -----------------------------------------------------------------------
set backspace=indent,eol,start  " Allow backspace over anything in insert mode
set wildmenu                    " Command-line completion with menu
set laststatus=2                " Always show the status line
set ruler                       " Show cursor position line
set scrolloff=4                 " Keep at least 4 lines visible around cursor
set sidescrolloff=8
set encoding=utf-8
set fileencoding=utf-8

" -----------------------------------------------------------------------
" diff mode — used when git opens diff output in vim
" -----------------------------------------------------------------------
if &diff
  syntax on
  set diffopt+=iwhite     " Ignore whitespace-only changes
endif
