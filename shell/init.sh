#!/bin/bash -x

# Define absolute path to workspace directory
WORKSPACE_DIR=/home/$USER/git/workspace
echo "WORKSPACE_DIR=/home/$USER/git/workspace"
echo "The current user is: $USER"

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
  # Clone workspace repository
  git clone git@github.com:luketseng/workspace.git "$WORKSPACE_DIR"
fi

# Backup existing .bashrc and replace with new one
mv ~/.bashrc ~/.bashrc.bak
cp $WORKSPACE_DIR/config/.bashrc ~/

# Copy .vimrc and .vim directory to home directory
cp $WORKSPACE_DIR/config/.vimrc ~/
#cp -r $WORKSPACE_DIR/config/.vim ~/

# tmux config
sudo cp $WORKSPACE_DIR/config/tmux/tmux-session /bin/
cp $WORKSPACE_DIR/config/tmux/.tmux.conf ~/

# Reload .bashrc
source ~/.bashrc

echo "Setup completed successfully."
