"==============================================================================
" Vim Configuration
"==============================================================================

"==============================================================================
" Basic Settings
"==============================================================================
" Editor behavior
syntax on                              " 啟用語法高亮
set nonumber                           " 顯示行號
set norelativenumber                   " 顯示相對行號
set cursorline                         " 高亮當前行
set wrap                               " 自動換行
set showcmd                            " 顯示命令
set wildmenu                           " 命令行補全
set showmatch                          " 顯示匹配的括號
set hlsearch                           " 搜索結果高亮
set incsearch                          " 增量搜索
set ignorecase                         " 搜索忽略大小寫
set smartcase                          " 智能大小寫搜索
set backspace=indent,eol,start         " 退格鍵工作方式
set ruler                              " 顯示游標位置
set laststatus=2                       " 總是顯示狀態欄
set scrolloff=5                        " 始終顯示游標上下 5 行內容
set mouse-=a                           " 啟用滑鼠
set clipboard=unnamed                  " 使用系統剪貼板
set history=1000                       " 命令歷史數量
set t_Co=256                           " 啟用256色
set background=dark                    " 深色背景

" Indentation and formatting
set autoindent                         " 自動縮進
set smartindent                        " 智能縮進
set tabstop=4                          " Tab 寬度為 4 個空格
set softtabstop=4                      " 編輯時 Tab 寬度為 4 個空格
set shiftwidth=4                       " 縮進寬度為 4 個空格
set expandtab                          " 使用空格代替 Tab

" Encoding
set encoding=utf-8                     " 編碼設置為 UTF-8
set fileencoding=utf-8                 " 文件編碼

"==============================================================================
" Plugins
"==============================================================================
call plug#begin('~/.vim/plugged')

" Code quality and formatting
Plug 'dense-analysis/ale'              " Linting and fixing
Plug 'psf/black'                       " Python formatter

" UI enhancements
Plug 'vim-airline/vim-airline'         " Status line
Plug 'vim-airline/vim-airline-themes'  " Status line themes
Plug 'Yggdroot/indentLine'             " Indent guides
Plug 'preservim/nerdtree'              " File tree
Plug 'preservim/tagbar'                " Code structure display

" Themes
Plug 'tomasr/molokai'                  " Molokai theme
Plug 'morhetz/gruvbox'                 " Gruvbox theme
Plug 'joshdick/onedark.vim'            " One Dark theme

" Language support
Plug 'elzr/vim-json'                   " JSON support
Plug 'Shougo/neocomplcache'            " Code completion

call plug#end()

"==============================================================================
" Plugin Settings
"==============================================================================
" ALE (Linting)
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚠'
let g:ale_fix_on_save = 0
" Tell ALE exactly where to find the black executable
let g:ale_python_black_executable = expand('~/.local/bin/black')
let g:ale_python_black_options = '--line-length=120'

" Linters configuration
let g:ale_linters = {
    \   'python': ['flake8'],
    \   'yaml': ['yamllint'],
    \}

" Fixers configuration
let g:ale_fixers = {
    \   '*': ['remove_trailing_lines', 'trim_whitespace'],
    \   'python': ['black', 'remove_trailing_lines', 'trim_whitespace'],
    \   'yaml': ['remove_trailing_lines', 'trim_whitespace'],
    \   'javascript': ['prettier', 'eslint', 'remove_trailing_lines', 'trim_whitespace'],
    \}

let g:ale_echo_msg_format = '[%linter%] %s'

" Airline settings
let g:airline_powerline_fonts = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'default'
let g:airline_theme = 'bubblegum'
"let g:airline_theme = 'onedark'

" JSON settings
let g:vim_json_syntax_conceal = 0

" Indent guides
let g:indentLine_char = '┊'

" Code completion
let g:neocomplcache_enable_at_startup = 1

"==============================================================================
" Vim Airline custom user/plugin overrides and mappings
"==============================================================================

" Override airline theme normal mode palette (personal preference)
function! AirlineOverrideNormalMode()
    let g:airline#themes#bubblegum#palette.normal = {
        \ 'airline_a': ['#afd787', '#444444', 236, 7, ''],
        \ 'airline_b': ['#b2b2b2', '#3a3a3a', 249, 237, ''],
        \ 'airline_c': ['#afd787', '#444444', 7, 238, ''],
        \ 'airline_x': ['#afd787', '#444444', 7, 238, ''],
        \ 'airline_y': ['#b2b2b2', '#3a3a3a', 249, 237, ''],
        \ 'airline_z': ['#303030', '#afd787', 236, 7, ''],
        \ 'airline_a_to_airline_b': ['#afd787', '#3a3a3a', '150', '237', ''],
        \ 'airline_b_to_airline_c': ['#3a3a3a', '#444444', '237', '238', ''],
        \ 'airline_c_to_airline_x': ['#444444', '#444444', '238', '238', ''],
        \ 'airline_x_to_airline_y': ['#3a3a3a', '#444444', '237', '238', ''],
        \ 'airline_y_to_airline_z': ['#afd787', '#3a3a3a', '150', '237', ''],
        \ }
endfunction

" Apply the custom airline palette after the theme loads
" autocmd VimEnter * call AirlineOverrideNormalMode()
autocmd User AirlineAfterTheme call AirlineOverrideNormalMode()

"==============================================================================
" Theme Settings
"==============================================================================
" Available themes: desert, molokai, gruvbox, onedark
let g:current_theme = 'desert'  " Default theme
" colorscheme gruvbox             " Apply the gruvbox theme

" Theme switching function
function! ToggleTheme()
    if g:current_theme == 'desert'
        let g:current_theme = 'molokai'
        colorscheme molokai
    elseif g:current_theme == 'molokai'
        let g:current_theme = 'gruvbox'
        colorscheme gruvbox
    elseif g:current_theme == 'gruvbox'
        let g:current_theme = 'onedark'
        colorscheme onedark
    else
        let g:current_theme = 'desert'
        colorscheme desert
    endif
endfunction

" Show current theme
function! ShowCurrentTheme()
    echohl WarningMsg
    echo "Current theme: " . g:current_theme
    echohl None
endfunction

"==============================================================================
" Line Number Settings
"==============================================================================
" Line number mode cycling function
function! ToggleLineNumber()
    if !exists('b:line_number_mode')
        let b:line_number_mode = 0
    endif

    if b:line_number_mode == 0
        " Mode 0: Only absolute line numbers
        set number
        set norelativenumber
        let b:line_number_mode = 1
        echo "Line numbers: absolute only"
    elseif b:line_number_mode == 1
        " Mode 1: Both absolute and relative line numbers
        set number
        set relativenumber
        let b:line_number_mode = 2
        echo "Line numbers: absolute + relative"
    else
        " Mode 2: No line numbers
        set nonumber
        set norelativenumber
        let b:line_number_mode = 0
        echo "Line numbers: disabled"
    endif
endfunction

"==============================================================================
" Help Window
"==============================================================================
function! ShowVimHelp()
    new
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal modifiable
    setlocal nonumber
    setlocal norelativenumber
    setlocal foldcolumn=0

    " Help content
    put ='Vim Quick Help'
    put ='=============='
    put =''
    put ='Basic Commands:'
    put ='  ,ev     - Edit .vimrc'
    put ='  ,sv     - Reload .vimrc'
    put ='  ,tt     - Toggle theme'
    put ='  ,tl     - Show current theme'
    put ='  ,hh     - Show this help'
    put =''
    put ='Theme Management:'
    put ='  Available themes: (default: desert)'
    put ='    - desert'
    put ='    - molokai'
    put ='    - gruvbox'
    put ='    - onedark'
    put =''
    put ='Code Quality:'
    put ='  ,f      - Fix current file (ALE)'
    put ='  ,d      - Show error details (ALE)'
    put ='  ,aj     - Next error (ALE)'
    put ='  ,ak     - Previous error (ALE)'
    put =''
    put ='Window Management:'
    put ='  ,ln     - Toggle line numbers (cycle through:'
    put ='             absolute → absolute+relative → none)'
    put ='  ,/      - Clear search highlight'
    put =''
    put ='Press q to close this help'

    " Set buffer as readonly
    setlocal nomodifiable
    setlocal readonly

    " Map q to close help
    nnoremap <buffer> q :q<CR>

    " Go to top of buffer
    normal! gg
endfunction

"==============================================================================
" Key Mappings
"==============================================================================
" Leader key
let mapleader = ","

" Quick edit and reload vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" ALE shortcuts
nmap <leader>f :ALEFix<CR>
nmap <leader>d :ALEDetail<CR>
nmap <silent> <leader>aj :ALENext<CR>
nmap <silent> <leader>ak :ALEPrevious<CR>

" Line number toggle
nnoremap <leader>ln :call ToggleLineNumber()<CR>

" Clear search highlight
noremap <leader>/ :nohlsearch<CR>

" Theme and help key bindings
nnoremap <leader>tt :call ToggleTheme()<CR>
nnoremap <leader>tl :call ShowCurrentTheme()<CR>
nnoremap <leader>hh :call ShowVimHelp()<CR>

" Tagbar settings
nmap <F8> :TagbarToggle<CR>
nnoremap <leader>t :TagbarToggle<CR>
nnoremap <leader>T :TagbarOpen<CR>
" let g:tagbar_width = 30
let g:tagbar_compact = 1
let g:tagbar_autofocus = 1

" NERDTree settings
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>nf :NERDTreeFind<CR>
nnoremap <leader>l :bnext<CR>
nnoremap <leader>h :bprev<CR>

"==============================================================================
" Visual Settings
"==============================================================================
" Highlight extra whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Define custom save command with ALE fix and newline handling
function! SaveWithALEAndNewline()
    if &filetype == ''
        " Skip for files without a filetype
        execute 'write'
        return
    endif

    " Create a one-time autocommand that will execute after ALE fix is completed
    augroup ALEFixAndSave
        autocmd!
        autocmd User ALEFixPost call AfterALEFixCompleted()
    augroup END

    " Run ALEFix (asynchronously)
    ALEFix
endfunction

function! AfterALEFixCompleted()
    " Add an empty line at the end of file if the last line is not empty
    if getline('$') != ''
        call append(line('$'), '')
    endif

    " Save the file
    execute 'write'

    " Clean up the autocommand group
    autocmd! ALEFixAndSave
    augroup! ALEFixAndSave
endfunction

" Automatically run ALEFix and add a blank line at the end when saving a file
augroup SaveWithFixAndNewline
    autocmd!
    autocmd BufWriteCmd * call SaveWithALEAndNewline()
    " If you want to restrict this behavior to specific filetypes only (e.g. Python and JavaScript),
    " comment out the line above and uncomment the one below:
    " autocmd BufWriteCmd *.py,*.js call SaveWithALEAndNewline()
augroup END

" Replace wq with ALEFix and append newline
command! -nargs=0 WqFix call s:WqWithFix()

function! s:WqWithFix()
    if &filetype != ''
        " exec ALEFix
        ALEFix
        "  wait ALEFix finish
        while exists('*ale#engine#IsRunning') && ale#engine#IsRunning()
            sleep 100m
        endwhile
    endif
    " append newline
    if getline('$') != ''
        call append(line('$'), '')
    endif
    write
    quit
endfunction

cabbrev wq WqFix

