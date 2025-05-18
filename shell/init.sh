#!/bin/bash

# Define absolute path to workspace directory
GIT_DIR="/home/$USER/git"
WORKSPACE_DIR="/home/$USER/git/workspace"
echo "The current user is: $USER"
echo "WORKSPACE_DIR=$WORKSPACE_DIR"

#will replace your current shell with a new instance, and therefore only preserve your current shell's environment variables (including ones you've defined ad hoc, in-session).
#In other words: Any ad-hoc changes to the current shell in terms of shell variables, shell functions, shell options, command history are lost.
echo "------- [INFO] Please run command: 'exec bash init.sh' if want to reload ~/.bashrc without source"

# Check if the user has root permission
#if [ "$EUID" -ne 0 ]; then
#  echo "Please run this script with root permission."
#  exit 1
#fi

# Check if the git folder exists, if not, create it
# Check if Git folder exists
if [ ! -d "$GIT_DIR" ]; then
  # Create Git folder
  mkdir -p "$GIT_DIR"
  echo "Created Git folder: $GIT_DIR"
else
  echo "Git folder already exists: $GIT_DIR"
fi

# Clone workspace repository
if [ -d "$WORKSPACE_DIR" ]; then
  read -p "$WORKSPACE_DIR already exists. Do you want to overwrite it? (Y/N): " choice
  case "$choice" in
    y|Y ) rm -rf "$WORKSPACE_DIR";;
    n|N ) echo "rm -fr cancelled.";;
    * ) echo "Invalid choice. Setup cancelled."; exit 1;;
  esac
fi

# Check if workspace directory exists
if [ ! -d "$WORKSPACE_DIR" ]; then
  echo "Cloning workspace repository to $WORKSPACE_DIR..."
  # Clone workspace repository
  if ! git clone git@github.com:luketseng/workspace.git "$WORKSPACE_DIR"; then
    echo "Failed to clone workspace repository. Please check your internet connection and try again."
    exit 1
  fi
fi

# Backup existing .bashrc and replace with new one
echo "Backing up existing .bashrc and replacing with new one..."
if [ -f ~/.bashrc ]; then
  mv ~/.bashrc ~/.bashrc.bak
fi
if ! cp $WORKSPACE_DIR/config/.bashrc ~/; then
  echo "Failed to copy .bashrc file. Please check the file path and try again."
  exit 1
fi

# Copy .vimrc and .vim directory to home directory
echo "Copying .vimrc and .vim directory to home directory..."
if ! cp $WORKSPACE_DIR/config/.vimrc ~/; then
  echo "Failed to copy .vimrc file. Please check the file path and try again."
  exit 1
fi
#if ! cp -r $WORKSPACE_DIR/config/.vim ~; then
#  echo "Failed to copy .vim directory. Please check the directory path and try again."
#  exit 1
#fi

# tmux config
echo "Copying tmux config..."
if ! sudo cp $WORKSPACE_DIR/config/tmux/tmux-session /bin/; then
  echo "Failed to copy tmux-session file. Please check the file path and try again."
  exit 1
fi
if ! cp $WORKSPACE_DIR/config/tmux/.tmux.conf ~/; then
  echo "Failed to copy .tmux.conf file. Please check the file path and try again."
  exit 1
fi

# Reload .bashrc
if ! source ~/.bashrc; then
  echo "Failed to reload .bashrc file. Please check the file path and try again."
  exit 1
fi
echo "------- [INFO] Please run command: 'source ~/.bashrc' if run bash without 'exec'"

# Set system timezone
echo "Current system timezone: $(timedatectl | grep 'Time zone')"
read -p "Do you want to change the timezone to Asia/Taipei? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Changing timezone to Asia/Taipei..."
    sudo timedatectl set-timezone Asia/Taipei
    echo "Timezone changed! The current system timezone is:"
    timedatectl | grep 'Time zone'
else
    echo "No changes were made."
fi


echo "Init setup completed."
