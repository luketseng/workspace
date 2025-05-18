# Modern .bashrc configuration
# Focused on development efficiency and user experience
# Optimized for Python, YAML, JSON, JavaScript, and Shell development

# ============================================================================
# Basic Configuration
# ============================================================================

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# History Configuration
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Window size check
shopt -s checkwinsize

# ============================================================================
# Environment Variables
# ============================================================================

# Editor and Language Settings
export EDITOR=vim
export VISUAL=vim
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Development Tools Path
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"  # For Rust tools
export PATH="$HOME/.npm-global/bin:$PATH"  # For Node.js tools

# Python Development
export PYTHONPATH="${PYTHONPATH}:$HOME/.local/lib/python3.x/site-packages"
export PIPENV_VENV_IN_PROJECT=1  # Create virtualenv in project directory

# ============================================================================
# Modern Prompt Configuration
# ============================================================================

# Git status in prompt (using POSIX-compliant function declaration)
git_branch_name() {
    branch=$(git symbolic-ref HEAD 2>/dev/null | awk -F/ '{print $NF}')
    if [ -z "$branch" ]; then
        echo ""
    else
        # Get last commit time
        last_commit=$(git log --pretty=format:%at -1 2>/dev/null)
        if [ -n "$last_commit" ]; then
            now=$(date +%s)
            sec=$((now-last_commit))
            min=$((sec/60))
            hr=$((min/60))
            day=$((hr/24))
            if [ $min -lt 60 ]; then
                info="${min}m"
            elif [ $hr -lt 24 ]; then
                info="${hr}h$((min%60))m"
            else
                info="${day}d$((hr%24))h"
            fi
            echo "($branch $info)"
        else
            echo "($branch)"
        fi
    fi
}

# Command execution time
timer_start() {
    timer=${timer:-$SECONDS}
}

timer_stop() {
    timer_show=$(($SECONDS - $timer))
    unset timer
}

# Only set up timer if we're in an interactive shell
if [ -n "$PS1" ]; then
    # Use trap only if DEBUG is supported
    if trap -p DEBUG >/dev/null 2>&1; then
        trap 'timer_start' DEBUG
    fi
    PROMPT_COMMAND=timer_stop
fi

# Modern prompt with git status and execution time
# Only set PS1 if we're in an interactive shell
if [ -n "$PS1" ]; then
    # Check if we have color support
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # Original color scheme with execution time
        PS1='\[\033[1;32m\]\u@\h\[\033[00m\]:\[\033[1;33m\]\w\[\033[1;36m\]$(git_branch_name)\[\033[00m\] [${timer_show}s] \$ '
    else
        # Fallback to non-color prompt
        PS1='\u@\h:\w$(git_branch_name) [${timer_show}s] \$ '
    fi
fi

# ============================================================================
# Development Efficiency Aliases
# ============================================================================

# Basic Aliases
alias cls='clear'
alias cp='cp -i'
alias du='du -h --max-depth=1'
alias h='history | grep'
alias mv='mv -i'
alias rrm='/bin/rm -i'	# real rm
alias vi='vim'

# Directory Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Python Development
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'

# Node.js Development
alias nrd='npm run dev'
alias nrs='npm run start'
alias nrt='npm run test'

# Docker Shortcuts
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'

# Git Shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'

# File Operations
alias ls='ls --color=auto --group-directories-first'
alias lt='ls -t'
alias ll='ls -lh'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

# ============================================================================
# Development Helper Functions
# ============================================================================

# Create and activate Python virtual environment
function venv_create() {
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
}

# Quick JSON formatting
function json_format() {
    if [ -z "$1" ]; then
        python3 -m json.tool
    else
        python3 -m json.tool "$1"
    fi
}

# YAML validation
function yaml_validate() {
    if [ -z "$1" ]; then
        echo "Usage: yaml_validate <file>"
        return 1
    fi
    python3 -c "import yaml; yaml.safe_load(open('$1'))"
}

# Quick directory creation and navigation
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find process using port
function port_usage() {
    if [ -z "$1" ]; then
        echo "Usage: port_usage <port>"
        return 1
    fi
    lsof -i ":$1"
}

# Create archive with common formats (using POSIX-compliant function declaration)
archive() {
    if [ -z "$1" ]; then
        echo "Usage: archive <format> <source1> [source2 ...] [destination]"
        echo "Formats: tar, tgz, txz, zip"
        echo "Examples:"
        echo "  archive tgz folder1 folder2 file1.txt"
        echo "  archive tgz folder1 folder2 -o custom_name"
        echo "  archive tgz '*.txt' '*.log' -o logs"
        return 1
    fi

    local format=$1
    shift  # Remove format from arguments

    # Check if format is valid
    case $format in
        tar|tgz|txz|zip)
            ;;
        *)
            echo "Unsupported format: $format"
            echo "Supported formats: tar, tgz, txz, zip"
            return 1
            ;;
    esac

    # Process arguments
    local sources=()
    local dest=""
    local use_custom_name=false

    while [ $# -gt 0 ]; do
        case "$1" in
            -o|--output)
                if [ -z "$2" ]; then
                    echo "Error: -o requires a destination name"
                    return 1
                fi
                dest="$2"
                use_custom_name=true
                shift 2
                ;;
            *)
                # Handle glob patterns
                if [[ "$1" == *"*"* ]]; then
                    # Expand glob pattern
                    for file in $1; do
                        if [ -e "$file" ]; then
                            sources+=("$file")
                        fi
                    done
                else
                    sources+=("$1")
                fi
                shift
                ;;
        esac
    done

    # Validate sources
    if [ ${#sources[@]} -eq 0 ]; then
        echo "Error: No source files or directories specified"
        return 1
    fi

    # Check if all sources exist
    for source in "${sources[@]}"; do
        if [ ! -e "$source" ]; then
            echo "Error: Source '$source' does not exist"
            return 1
        fi
    done

    # Set default destination if not specified
    if [ -z "$dest" ]; then
        if [ ${#sources[@]} -eq 1 ]; then
            # Single source: use its name
            dest=$(basename "${sources[0]}")
        else
            # Multiple sources: use 'archive' as base name
            dest="archive"
        fi
    fi

    # Create archive based on format
    case $format in
        tar)
            tar -cf "${dest}.tar" "${sources[@]}"
            ;;
        tgz)
            tar -czf "${dest}.tar.gz" "${sources[@]}"
            ;;
        txz)
            tar -cJf "${dest}.tar.xz" "${sources[@]}"
            ;;
        zip)
            # For zip, we need to change to the parent directory to maintain relative paths
            local current_dir=$(pwd)
            local parent_dir=$(dirname "$(realpath "${sources[0]}")")
            cd "$parent_dir"
            zip -r "${current_dir}/${dest}.zip" $(basename "${sources[@]}")
            cd "$current_dir"
            ;;
    esac

    # Show result
    if [ $? -eq 0 ]; then
        echo "Created archive: ${dest}.${format}"
        if [ "$format" = "tgz" ]; then
            echo "Archive: ${dest}.tar.gz"
        elif [ "$format" = "txz" ]; then
            echo "Archive: ${dest}.tar.xz"
        else
            echo "Archive: ${dest}.${format}"
        fi
    fi
}

# Extract archive with flexible options (using POSIX-compliant function declaration)
extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <archive> [options] [files...]"
        echo "Options:"
        echo "  -d, --dir <directory>    Extract to specific directory"
        echo "  -l, --list              List contents without extracting"
        echo "  -f, --files <pattern>   Extract only files matching pattern"
        echo "  -v, --verbose          Show extraction progress"
        echo "Examples:"
        echo "  extract archive.tar.gz                    # Extract all files"
        echo "  extract archive.tar.gz -d /path/to/dest   # Extract to specific directory"
        echo "  extract archive.tar.gz -f '*.txt'         # Extract only .txt files"
        echo "  extract archive.tar.gz file1.txt file2    # Extract specific files"
        echo "  extract archive.tar.gz -l                 # List contents only"
        return 1
    fi

    local archive=$1
    shift

    # Check if archive exists
    if [ ! -f "$archive" ]; then
        echo "Error: Archive '$archive' does not exist"
        return 1
    fi

    # Default values
    local dest="."
    local list_only=false
    local pattern=""
    local verbose=""
    local files=()

    # Parse options
    while [ $# -gt 0 ]; do
        case "$1" in
            -d|--dir)
                if [ -z "$2" ]; then
                    echo "Error: -d requires a directory path"
                    return 1
                fi
                dest="$2"
                shift 2
                ;;
            -l|--list)
                list_only=true
                shift
                ;;
            -f|--files)
                if [ -z "$2" ]; then
                    echo "Error: -f requires a pattern"
                    return 1
                fi
                pattern="$2"
                shift 2
                ;;
            -v|--verbose)
                verbose="v"
                shift
                ;;
            *)
                # Collect files to extract
                files+=("$1")
                shift
                ;;
        esac
    done

    # Create destination if it doesn't exist
    if [ "$dest" != "." ] && [ ! -d "$dest" ]; then
        mkdir -p "$dest"
    fi

    # Get archive type
    local archive_type
    case "$archive" in
        *.tar)      archive_type="tar" ;;
        *.tar.gz|*.tgz) archive_type="tgz" ;;
        *.tar.xz|*.txz) archive_type="txz" ;;
        *.zip)      archive_type="zip" ;;
        *.rar)      archive_type="rar" ;;
        *.7z)       archive_type="7z" ;;
        *)          echo "Unsupported archive format: $archive"; return 1 ;;
    esac

    # List contents if requested
    if [ "$list_only" = true ]; then
        case $archive_type in
            tar|tgz|txz)
                tar -t${verbose}f "$archive"
                ;;
            zip)
                unzip -l "$archive"
                ;;
            rar)
                unrar l "$archive"
                ;;
            7z)
                7z l "$archive"
                ;;
        esac
        return 0
    fi

    # Extract files
    case $archive_type in
        tar|tgz|txz)
            local tar_opts="-x${verbose}f"
            case $archive_type in
                tgz) tar_opts="${tar_opts}z" ;;
                txz) tar_opts="${tar_opts}J" ;;
            esac

            if [ ${#files[@]} -gt 0 ]; then
                # Extract specific files
                tar $tar_opts "$archive" -C "$dest" "${files[@]}"
            elif [ -n "$pattern" ]; then
                # Extract files matching pattern
                tar $tar_opts "$archive" -C "$dest" --wildcards "$pattern"
            else
                # Extract all files
                tar $tar_opts "$archive" -C "$dest"
            fi
            ;;
        zip)
            if [ ${#files[@]} -gt 0 ]; then
                # Extract specific files
                unzip -o "$archive" "${files[@]}" -d "$dest"
            elif [ -n "$pattern" ]; then
                # Extract files matching pattern
                unzip -o "$archive" "$pattern" -d "$dest"
            else
                # Extract all files
                unzip -o "$archive" -d "$dest"
            fi
            ;;
        rar)
            if [ ${#files[@]} -gt 0 ]; then
                # Extract specific files
                unrar x "$archive" "${files[@]}" "$dest"
            elif [ -n "$pattern" ]; then
                # Extract files matching pattern
                unrar x "$archive" "$pattern" "$dest"
            else
                # Extract all files
                unrar x "$archive" "$dest"
            fi
            ;;
        7z)
            if [ ${#files[@]} -gt 0 ]; then
                # Extract specific files
                7z x "$archive" "${files[@]}" -o"$dest"
            elif [ -n "$pattern" ]; then
                # Extract files matching pattern
                7z x "$archive" "$pattern" -o"$dest"
            else
                # Extract all files
                7z x "$archive" -o"$dest"
            fi
            ;;
    esac

    # Show result
    if [ $? -eq 0 ]; then
        if [ "$list_only" = false ]; then
            echo "Extraction completed to: $dest"
        fi
    else
        echo "Extraction failed"
        return 1
    fi
}

# List contents of archive (using POSIX-compliant function declaration)
archive_list() {
    if [ -z "$1" ]; then
        echo "Usage: archive_list <archive>"
        return 1
    fi

    local archive=$1

    case $archive in
        *.tar)
            tar -tvf "$archive"
            ;;
        *.tar.gz|*.tgz)
            tar -tzvf "$archive"
            ;;
        *.tar.xz|*.txz)
            tar -tJvf "$archive"
            ;;
        *.zip)
            unzip -l "$archive"
            ;;
        *.rar)
            unrar l "$archive"
            ;;
        *.7z)
            7z l "$archive"
            ;;
        *)
            echo "Unsupported archive format: $archive"
            return 1
            ;;
    esac
}

# Quick archive aliases
alias tarc='archive tar'    # Create .tar
alias targz='archive tgz'   # Create .tar.gz
alias tarxz='archive txz'   # Create .tar.xz
alias tarzip='archive zip'  # Create .zip
alias untar='extract'       # Extract any supported archive
alias tarls='archive_list'  # List archive contents

# ============================================================================
# User Experience Enhancements
# ============================================================================

# Command not found handler
function command_not_found_handle() {
    echo "Command not found: $1"
    echo "Try: apt search $1"
    return 127
}

# Directory change with history
function cd() {
    builtin cd "$@"
    if [ $? -eq 0 ]; then
        pwd > ~/.last_dir
    fi
}

# Quick return to last directory
function back() {
    if [ -f ~/.last_dir ]; then
        cd "$(cat ~/.last_dir)"
    fi
}

# ============================================================================
# Load Additional Configurations
# ============================================================================

# Load bash completion if available
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Load local customizations if available
if [ -f "$HOME/.bash_local" ]; then
    . "$HOME/.bash_local"
fi

# ============================================================================
# Custom Help System
# ============================================================================

# Welcome message function
zhelp_welcome() {
    echo "=================================================="
    echo "Welcome to your development environment!"
    echo "=================================================="
    echo ""
    echo "Available development tools:"
    echo ""
    echo "  Python Development:"
    echo "    - py, pip, venv, activate, venv_create"
    echo "    - json_format, yaml_validate"
    echo ""
    echo "  Node.js Development:"
    echo "    - nrd (npm run dev)"
    echo "    - nrs (npm run start)"
    echo "    - nrt (npm run test)"
    echo ""
    echo "  Docker Operations:"
    echo "    - d (docker)"
    echo "    - dc (docker-compose)"
    echo "    - dps (docker ps)"
    echo "    - di (docker images)"
    echo ""
    echo "  Git Operations:"
    echo "    - gs (git status)"
    echo "    - ga (git add)"
    echo "    - gc (git commit)"
    echo "    - gp (git push)"
    echo "    - gl (git pull)"
    echo "    - gd (git diff)"
    echo "    - gb (git branch)"
    echo ""
    echo "  File Operations:"
    echo "    - ls, ll, la, l (list files)"
    echo "    - grep (colored search)"
    echo "    - du (disk usage)"
    echo ""
    echo "  Archive Operations:"
    echo "    - tarc, targz, tarxz, tarzip (create archives)"
    echo "    - untar (extract archives)"
    echo "    - tarls (list archive contents)"
    echo ""
    echo "  Tmux Session Management:"
    echo "    - tms (save session)"
    echo "    - tml (list saved sessions)"
    echo "    - tmr (restore session)"
    echo "    - tma (attach to session)"
    echo "    - tmn (new session)"
    echo "    - tmk (kill session)"
    echo "    - tmls (list sessions)"
    echo ""
    echo "  Trash System:"
    echo "    - trash (move to trash)"
    echo "    - trash-list (list trash contents)"
    echo "    - trash-restore (restore from trash)"
    echo "    - trash-empty (empty trash)"
    echo "    - trash-clean (clean old files)"
    echo ""
    echo "  Directory Navigation:"
    echo "    - .., ..., .... (go up directories)"
    echo "    - ~ (go to home)"
    echo "    - back (return to last directory)"
    echo "    - mkcd (create and enter directory)"
    echo ""
    echo "=================================================="
    echo "Use 'zhelp' to see detailed command information:"
    echo "  zhelp archive    # Show archive commands"
    echo "  zhelp all        # Show all commands"
    echo "=================================================="
}

# Custom help command to show all available functions and aliases
zhelp() {
    local category="$1"

    # Show all categories if no specific category is requested
    if [ -z "$category" ]; then
        echo "Available command categories:"
        echo "  archive   - Archive operations (tar, zip, etc.)"
        echo "  git       - Git shortcuts"
        echo "  python    - Python development tools"
        echo "  node      - Node.js development tools"
        echo "  docker    - Docker shortcuts"
        echo "  file      - File operations"
        echo "  dir       - Directory navigation"
        echo "  tmux      - Tmux session management"
        echo "  trash     - Trash system commands"
        echo "  all       - Show all commands"
        echo ""
        echo "Usage: zhelp <category>"
        echo "Example: zhelp archive"
        return 0
    fi

    case "$category" in
        archive)
            echo "Archive Commands:"
            echo "  tarc <source> [source2 ...] [-o name]    - Create .tar archive"
            echo "  targz <source> [source2 ...] [-o name]   - Create .tar.gz archive"
            echo "  tarxz <source> [source2 ...] [-o name]   - Create .tar.xz archive"
            echo "  tarzip <source> [source2 ...] [-o name]  - Create .zip archive"
            echo ""
            echo "  untar <archive> [options] [files...]     - Extract archive"
            echo "    Options:"
            echo "      -d, --dir <dir>     Extract to directory"
            echo "      -l, --list          List contents"
            echo "      -f, --files <pat>   Extract matching files"
            echo "      -v, --verbose       Show progress"
            echo ""
            echo "  tarls <archive>                         - List archive contents"
            echo ""
            echo "Examples:"
            echo "  1. Create archives:"
            echo "     targz project/ -o backup              # Create project.tar.gz"
            echo "     tarzip docs/ src/ -o release          # Create release.zip"
            echo "     tarc *.log -o logs                    # Create logs.tar"
            echo ""
            echo "  2. Extract archives:"
            echo "     untar backup.tar.gz                   # Extract to current dir"
            echo "     untar backup.tar.gz -d /backup        # Extract to /backup"
            echo "     untar backup.tar.gz -f '*.txt'        # Extract only .txt files"
            echo "     untar backup.tar.gz -l                # List contents only"
            echo "     untar backup.tar.gz -v                # Show extraction progress"
            echo ""
            echo "  3. List archive contents:"
            echo "     tarls backup.tar.gz                   # List .tar.gz contents"
            echo "     tarls release.zip                     # List .zip contents"
            echo "     tarls logs.tar                        # List .tar contents"
            ;;
        git)
            echo "Git Shortcuts:"
            echo "  gs    - git status"
            echo "  ga    - git add"
            echo "  gc    - git commit"
            echo "  gp    - git push"
            echo "  gl    - git pull"
            echo "  gd    - git diff"
            echo "  gb    - git branch"
            ;;
        python)
            echo "Python Development:"
            echo "  py           - python3"
            echo "  pip          - pip3"
            echo "  venv         - Create virtual environment"
            echo "  activate     - Activate virtual environment"
            echo "  venv_create  - Create and activate venv"
            ;;
        node)
            echo "Node.js Development:"
            echo "  nrd    - npm run dev"
            echo "  nrs    - npm run start"
            echo "  nrt    - npm run test"
            ;;
        docker)
            echo "Docker Shortcuts:"
            echo "  d     - docker"
            echo "  dc    - docker-compose"
            echo "  dps   - docker ps"
            echo "  di    - docker images"
            ;;
        file)
            echo "File Operations:"
            echo "  ls    - List with colors and directory grouping"
            echo "  ll    - Long list format"
            echo "  la    - List all files"
            echo "  l     - List in columns"
            echo "  grep  - Colored grep"
            ;;
        dir)
            echo "Directory Navigation:"
            echo "  ..    - Go up one directory"
            echo "  ...   - Go up two directories"
            echo "  ....  - Go up three directories"
            echo "  ~     - Go to home directory"
            echo "  back  - Return to last directory"
            echo "  mkcd  - Create and enter directory"
            ;;
        tmux)
            echo "Tmux Session Management:"
            echo "  tms              - Save current session state"
            echo "  tml              - List saved sessions"
            echo "  tmr [file]       - Restore session (most recent or specified)"
            echo "  tma              - Attach to existing session"
            echo "  tmn              - Create new session"
            echo "  tmk <session>    - Kill specified session"
            echo "  tmls             - List all active sessions"
            ;;
        trash)
            echo "Trash System Commands:"
            echo "  trash <file> [file2 ...]  - Move files to trash"
            echo "  trash -l                  - List trash contents"
            echo "  trash -r <file>           - Restore file from trash"
            echo "  trash -e                  - Empty trash"
            echo "  trash -c                  - Clean old files"
            echo ""
            echo "Aliases:"
            echo "  trash-list                - List trash contents"
            echo "  trash-restore             - Restore file from trash"
            echo "  trash-empty               - Empty trash"
            echo "  trash-clean               - Clean old files"
            ;;
        all)
            # Show all categories
            zhelp archive
            echo ""
            zhelp git
            echo ""
            zhelp python
            echo ""
            zhelp node
            echo ""
            zhelp docker
            echo ""
            zhelp file
            echo ""
            zhelp dir
            echo ""
            zhelp tmux
            echo ""
            zhelp trash
            ;;
        *)
            echo "Unknown category: $category"
            echo "Use 'zhelp' without arguments to see available categories"
            return 1
            ;;
    esac
}

# Update welcome message
if [ -n "$PS1" ]; then
    echo "=================================================="
    echo "Welcome to your development environment!"
    echo "Type 'zhelp_welcome' to see available tools and commands"
    echo ""
    echo "Quick Help:"
    echo "  Vim:    Press ',hh' to show vim help"
    echo "  Tmux:   Press 'Ctrl-A ?' to show tmux help"
    echo "=================================================="
fi

# ============================================================================
# Tmux Session Management
# ============================================================================

# Save current tmux session state
tmux_save() {
    local session_file="${HOME}/.tmux-sessions/$(date +%Y%m%d_%H%M%S).json"
    mkdir -p "$(dirname "$session_file")"

    # Save session info in JSON format
    tmux list-windows -a -F "#{session_name}|#{window_name}|#{pane_current_path}|#{window_layout}" | \
    awk -F'|' '{
        printf "{\"session\":\"%s\",\"window\":\"%s\",\"path\":\"%s\",\"layout\":\"%s\"}\n",
        $1, $2, $3, $4
    }' > "$session_file"

    echo "Session saved to: $session_file"
}

# List saved sessions
tmux_list() {
    local sessions_dir="${HOME}/.tmux-sessions"
    if [ ! -d "$sessions_dir" ]; then
        echo "No saved sessions found"
        return 1
    fi

    echo "Available saved sessions:"
    for session in "$sessions_dir"/*.json; do
        if [ -f "$session" ]; then
            local date=$(basename "$session" .json | sed 's/_/ /')
            echo "  $(basename "$session") - $date"
        fi
    done
}

# Restore tmux session
tmux_restore() {
    local session_file="$1"
    if [ -z "$session_file" ]; then
        # If no file specified, use the most recent
        session_file=$(ls -t "${HOME}/.tmux-sessions"/*.json 2>/dev/null | head -n1)
        if [ -z "$session_file" ]; then
            echo "No saved sessions found"
            return 1
        fi
    fi

    if [ ! -f "$session_file" ]; then
        echo "Session file not found: $session_file"
        return 1
    fi

    # Start tmux server if not running
    tmux start-server

    # Read and restore session
    while IFS= read -r line; do
        local session=$(echo "$line" | jq -r '.session')
        local window=$(echo "$line" | jq -r '.window')
        local path=$(echo "$line" | jq -r '.path')
        local layout=$(echo "$line" | jq -r '.layout')

        if [ -d "$path" ]; then
            if ! tmux has-session -t "$session" 2>/dev/null; then
                # Create new session
                tmux new-session -d -s "$session" -n "$window" -c "$path"
            else
                # Create new window in existing session
                tmux new-window -d -t "$session:" -n "$window" -c "$path"
            fi

            # Restore window layout if available
            if [ -n "$layout" ]; then
                tmux select-window -t "$session:$window"
                tmux select-layout "$layout"
            fi
        fi
    done < "$session_file"

    echo "Session restored from: $session_file"
}

# Enhanced tmux session management aliases
alias tms='tmux_save'           # Save current session
alias tml='tmux_list'           # List saved sessions
alias tmr='tmux_restore'        # Restore most recent session
alias tma='tmux attach'         # Attach to existing session
alias tmn='tmux new-session'    # Create new session
alias tmk='tmux kill-session'   # Kill session
alias tmls='tmux list-sessions' # List all sessions

# ============================================================================
# Enhanced Trash System
# ============================================================================

# Trash directory configuration
export TRASH_DIR="${HOME}/.trash"
export TRASH_INFO_DIR="${TRASH_DIR}/.info"
export TRASH_MAX_DAYS=30  # Files older than this will be automatically cleaned

# Create trash directories if they don't exist
mkdir -p "$TRASH_DIR" "$TRASH_INFO_DIR"

# Enhanced trash function
trash() {
    if [ $# -eq 0 ]; then
        echo "Usage: trash <file1> [file2 ...]"
        echo "       trash -l              # List trash contents"
        echo "       trash -r <file>       # Restore file from trash"
        echo "       trash -e              # Empty trash"
        echo "       trash -c              # Clean old files (older than ${TRASH_MAX_DAYS} days)"
        return 1
    fi

    case "$1" in
        -l|--list)
            # List trash contents with details
            echo "Trash contents:"
            echo "----------------------------------------"
            for file in "$TRASH_DIR"/*; do
                if [ -e "$file" ] && [ "$(basename "$file")" != ".info" ]; then
                    local info_file="${TRASH_INFO_DIR}/$(basename "$file").info"
                    if [ -f "$info_file" ]; then
                        local original_path=$(cat "$info_file")
                        local delete_time=$(stat -c "%y" "$file")
                        local size=$(du -h "$file" | cut -f1)
                        printf "%-30s | %s | %s | %s\n" \
                            "$(basename "$file")" \
                            "$delete_time" \
                            "$size" \
                            "$original_path"
                    fi
                fi
            done
            echo "----------------------------------------"
            ;;

        -r|--restore)
            # Restore file from trash
            if [ -z "$2" ]; then
                echo "Error: Please specify a file to restore"
                return 1
            fi

            local trash_file="${TRASH_DIR}/$2"
            local info_file="${TRASH_INFO_DIR}/$2.info"

            if [ ! -e "$trash_file" ]; then
                echo "Error: File not found in trash"
                return 1
            fi

            if [ ! -f "$info_file" ]; then
                echo "Error: File info not found"
                return 1
            fi

            local original_path=$(cat "$info_file")
            local restore_dir=$(dirname "$original_path")

            # Create original directory if it doesn't exist
            mkdir -p "$restore_dir"

            # Restore file
            mv "$trash_file" "$original_path"
            rm -f "$info_file"
            echo "Restored: $2 -> $original_path"
            ;;

        -e|--empty)
            # Empty trash
            read -p "Are you sure you want to empty the trash? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -rf "${TRASH_DIR:?}"/*
                rm -rf "${TRASH_INFO_DIR:?}"/*
                echo "Trash emptied"
            fi
            ;;

        -c|--clean)
            # Clean old files
            local count=0
            find "$TRASH_DIR" -type f -mtime +${TRASH_MAX_DAYS} -not -path "*/\.*" | while read -r file; do
                local info_file="${TRASH_INFO_DIR}/$(basename "$file").info"
                rm -f "$file" "$info_file"
                ((count++))
            done
            echo "Cleaned $count old files from trash"
            ;;

        *)
            # Move files to trash
            for file in "$@"; do
                if [ ! -e "$file" ]; then
                    echo "Error: File not found: $file"
                    continue
                fi

                local filename=$(basename "$file")
                local trash_path="${TRASH_DIR}/${filename}"
                local info_path="${TRASH_INFO_DIR}/${filename}.info"

                # Handle filename conflicts
                if [ -e "$trash_path" ]; then
                    local timestamp=$(date +%Y%m%d_%H%M%S)
                    local new_filename="${filename%.*}_${timestamp}.${filename##*.}"
                    trash_path="${TRASH_DIR}/${new_filename}"
                    info_path="${TRASH_INFO_DIR}/${new_filename}.info"
                fi

                # Save original path and move file
                echo "$(realpath "$file")" > "$info_path"
                mv "$file" "$trash_path"
                echo "Moved to trash: $file"
            done
            ;;
    esac
}

# Alias rm to use trash
alias rm='trash'

# Add trash-related aliases
alias trash-list='trash -l'
alias trash-restore='trash -r'
alias trash-empty='trash -e'
alias trash-clean='trash -c'
