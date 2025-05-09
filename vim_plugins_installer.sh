#!/bin/bash

# Detect OS type
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
elif [ -f /etc/centos-release ]; then
    OS="centos"
else
    echo "Unable to detect operating system. Exiting."
    exit 1
fi

echo "Detected OS: $OS"

# Install dependencies
install_dependencies() {
    echo "Installing required packages..."

    if [ "$OS" == "centos" ]; then
        sudo yum update -y
        sudo yum install -y git curl vim python3 python3-pip
    elif [ "$OS" == "ubuntu" ] || [ "$OS" == "debian" ]; then
        sudo apt-get update
        sudo apt-get install -y git curl vim python3 python3-pip
    else
        echo "Unsupported operating system."
        exit 1
    fi

    pip3 install --user black yamllint

    echo "Dependencies installed."
}

# Backup existing configuration
backup_vimrc() {
    if [ -f ~/.vimrc ]; then
        echo "Backing up existing .vimrc to .vimrc.backup..."
        cp ~/.vimrc ~/.vimrc.backup
    fi

    if [ -d ~/.vim ]; then
        echo "Backing up existing .vim directory to .vim.backup..."
        cp -r ~/.vim ~/.vim.backup
    fi
}

# Install Vim-plug
install_vim_plug() {
    echo "Installing Vim-plug plugin manager..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    echo "Vim-plug installed."
}

# Create .vimrc configuration
create_vimrc() {
    echo "Creating new .vimrc configuration file..."

    cat > ~/.vimrc << 'EOF'
call plug#begin('~/.vim/plugged')

Plug 'dense-analysis/ale'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'elzr/vim-json'
Plug 'psf/black'
Plug 'Yggdroot/indentLine'
Plug 'Shougo/neocomplcache'

call plug#end()

" Basic settings
syntax on                      " 啟用語法高亮
set number                     " 顯示行號
set relativenumber             " 顯示相對行號
set cursorline                 " 高亮當前行
set wrap                       " 自動換行
set showcmd                    " 顯示命令
set wildmenu                   " 命令行補全
set showmatch                  " 顯示匹配的括號
set hlsearch                   " 搜索結果高亮
set incsearch                  " 增量搜索
set ignorecase                 " 搜索忽略大小寫
set smartcase                  " 智能大小寫搜索
set backspace=indent,eol,start " 退格鍵工作方式
set ruler                      " 顯示游標位置
set laststatus=2               " 總是顯示狀態欄
set autoindent                 " 自動縮進
set smartindent                " 智能縮進
set tabstop=4                  " Tab 寬度為 4 個空格
set softtabstop=4              " 編輯時 Tab 寬度為 4 個空格
set shiftwidth=4               " 縮進寬度為 4 個空格
set expandtab                  " 使用空格代替 Tab
set encoding=utf-8             " 編碼設置為 UTF-8
set fileencoding=utf-8         " 文件編碼
set scrolloff=5                " 始終顯示游標上下 5 行內容
set mouse-=a                   " 啟用滑鼠
set clipboard=unnamed          " 使用系統剪貼板
set history=1000               " 命令歷史數量
set background=dark            " 深色背景
colorscheme desert             " 使用 desert 主題 (Vim 默認主題之一)

" ALE settings
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚠'
let g:ale_fix_on_save = 1

" Set Python's line length limit to 100 characters (or whatever value you want)
" let g:ale_python_autopep8_options = '--aggressive --aggressive --max-line-length 79'
" let g:ale_python_flake8_options = '--max-line-length=99'
" let g:ale_python_pylint_options = '--max-line-length=100'
let g:ale_python_black_options = '--line-length=120'

let g:ale_linters = {
\   'python': ['flake8'],
\   'yaml': ['yamllint'],
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['black'],
\   'yaml': [],
\   'javascript': ['prettier', 'eslint', 'remove_trailing_lines', 'trim_whitespace'],
\}
let g:ale_echo_msg_format = '[%linter%] %s'

" Airline settings
let g:airline_powerline_fonts = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'default'
let g:airline_theme = 'bubblegum'

" vim-json settings
let g:vim_json_syntax_conceal = 0

" indentLine settings
let g:indentLine_char = '┊'

" neocomplcache settings
let g:neocomplcache_enable_at_startup = 1

" Leader key definition
let mapleader = ","

" Quick edit and reload vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" ALE shortcuts
nmap <leader>f :ALEFix<CR>
nmap <leader>d :ALEDetail<CR>
nmap <silent> <leader>aj :ALENext<CR>
nmap <silent> <leader>ak :ALEPrevious<CR>

" Toggle relative line numbers
nnoremap <leader>ln :set relativenumber!<CR>

" Clear search highlight
noremap <leader>/ :nohlsearch<CR>

" highlight extra whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
EOF

    echo ".vimrc created."
}

# Install plugins
install_plugins() {
    echo "Installing Vim plugins..."
    vim +PlugInstall +qall
    echo "Vim plugins installed."
}

# Main function
main() {
    echo "===== Vim Plugin Installation Script ====="
    install_dependencies
    backup_vimrc
    install_vim_plug
    create_vimrc
    install_plugins
    echo "✅ Installation complete. Please restart Vim to apply configuration."
}

main
