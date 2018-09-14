"set nocompatible              " required
"filetype off                  " required
"
"" set the runtime path to include Vundle and initialize
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()
"
"" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')
"
"" let Vundle manage Vundle, required
"Plugin 'gmarik/Vundle.vim'
"
"" Add all your plugins here (note older versions of Vundle used Bundle instead of Plugin)
"
""All of your Plugins must be added before the following line
"call vundle#end()            " required
"filetype plugin indent on    " required
"
"" Enable folding
"set foldmethod=indent
"set foldlevel=99
"
"" Enable folding with the spacebar
" nnoremap <space> za
"
"Plugin 'tmhedberg/SimpylFold'

" ============================================
" Remove trailing whitespace when writing a buffer, but not for diff files.
" From Vigil <vim5632@rainslide.net>
function RemoveTrailingWhitespace()
    if &ft != "diff"
        let b:curcol = col(".")
        let b:curline = line(".")
        silent! %s/\s\+$//
        silent! %s/\(\s*\n\)\+\%$//
        call cursor(b:curline, b:curcol)
    endif
endfunction
autocmd BufWritePre * call RemoveTrailingWhitespace()
" ============================================
"$ ls /usr/share/vim/vimNN/colors/ # where vimNN is vim version, e.g. vim74
"blue.vim  darkblue.vim  default.vim  delek.vim  desert.vim  elflord.vim
"evening.vim  koehler.vim  morning.vim  murphy.vim  pablo.vim  peachpuff.vim
"README.txt  ron.vim  shine.vim  slate.vim  torte.vim  zellner.vim
color desert
" set encoding=utf-8
" enable syntax highlighting
syntax enable

" show line numbers
set nonumber

" comment color
hi Comment ctermfg=lightblue

" set tabs to have 4 spaces (tabstop)
set ts=4

" when using the >> or << commands, shift lines by 4 spaces (shiftwidth)
set sw=4

" smarttab (sta)
set smarttab

" expand tabs into spaces
set expandtab

" softtabstop
set sts=4

" indent when moving to the next line while writing code
set autoindent

" show a visual line under the cursor's current line
"set cursorline

" show the matching part of the pair for [] {} and ()
set showmatch

" enable all Python syntax highlighting features
let python_highlight_all = 1

" 256 color terminal
set t_Co=256
