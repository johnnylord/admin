#!/bin/bash

if [ $USER != "root" ]; then
    echo "Please execute install.sh with sudo permission"
    exit 1
fi

if [ $# -ne 1 ]; then
    echo "Please enter [username] after install.sh"
    exit 1
fi

# Check user is valid or not
USERNAME=$1
grep -Fq "/home/${USERNAME}:" /etc/passwd
if [ $? -eq 1 ]; then
    echo "${USERNAME} is not registered in the system"
    exit 1
fi
echo "Setup environment for user '${USERNAME}'"

# Install neovim editor
# ====================================================================
apt-get install -y software-properties-common
add-apt-repository -y ppa:neovim-ppa/stable
apt-get update
apt-get install -y neovim
apt-get install -y python-dev python-pip python3-dev python3-pip

# Change editor alternatives
update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
update-alternatives --set vi
update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
update-alternatives --set vim
update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
update-alternatives --set editor

# Setup configuration file
NVIM_DIR="/home/${USERNAME}/.config/nvim"
mkdir -p ${NVIM_DIR}
cp neovim/init.vim "${NVIM_DIR}/init.vim"

# Install vim-plug plugin manager
VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
VIM_PLUG_DIR="/home/${USERNAME}/.local/share/nvim/site/autoload"
mkdir -p ${VIM_PLUG_DIR}
wget -O "${VIM_PLUG_DIR}/plug.vim" ${VIM_PLUG_URL}

# Update file permission
chown -R ${USERNAME}:${USERNAME} ${NVIM_DIR}
chown -R ${USERNAME}:${USERNAME} ${VIM_PLUG_DIR}

# Install tmux
# =====================================================================
apt-get install -y tmux

# Setup configuration file
TMUX_CONF_FILE="/home/${USERNAME}/.tmux.conf"
cp "tmux/tmux.conf" ${TMUX_CONF_FILE}

# Update file permission
chown ${USERNAME}:${USERNAME} ${TMUX_CONF_FILE}

# Install pyenv & pyenv virtualenv
# =====================================================================
PYENV_DIR="/home/${USERNAME}/.pyenv"
PYENV_URL="https://github.com/pyenv/pyenv.git"
PYENV_VIRT_URL="https://github.com/pyenv/pyenv-virtualenv.git"

if [ ! -d ${PYENV_DIR} ]; then
    git clone ${PYENV_URL} ${PYENV_DIR}
    mkdir -p "${PYENV_DIR}/plugins"
    git clone ${PYENV_VIRT_URL} "${PYENV_DIR}/plugins/pyenv-virtualenv"
    chown ${USERNAME}:${USERNAME} ${PYENV_DIR}
fi

# Install zsh shell
# =====================================================================
apt-get install -y zsh

# Change user shell
usermod --shell /bin/zsh ${USERNAME}

# Setup configuration files
ZSHRC="/home/${USERNAME}/.zshrc"
cp shell/zshrc ${ZSHRC}
chown ${USERNAME}:${USERNAME} ${ZSHRC}

# Install oh-my-zsh plugins
OH_MY_ZSH_DIR="/home/${USERNAME}/.oh-my-zsh"
OH_MY_ZSH_CUSTOM_DIR="${OH_MY_ZSH_DIR}/custom"
OH_MY_ZSH_PLUGIN_DIR="${OH_MY_ZSH_CUSTOM_DIR}/plugins"

OH_MY_ZSH_URL="https://github.com/robbyrussell/oh-my-zsh.git"

ZSH_AUTOSUGGESTION_DIR="${OH_MY_ZSH_PLUGIN_DIR}/zsh-autosuggestions"
ZSH_AUTOSUGGESTION_URL="https://github.com/zsh-users/zsh-autosuggestions.git"

ZSH_SYNTAX_HIGHLIGHT_DIR="${OH_MY_ZSH_PLUGIN_DIR}/zsh-syntax-highlighting"
ZSH_SYNTAX_HIGHLIGHT_URL="https://github.com/zsh-users/zsh-syntax-highlighting.git"

ZSH_PYENV_DIR="${OH_MY_ZSH_PLUGIN_DIR}/zsh-pyenv"
ZSH_PYENV_URL="https://github.com/mattberther/zsh-pyenv.git"

if [ ! -d ${OH_MY_ZSH_DIR} ]; then
    git clone ${OH_MY_ZSH_URL} ${OH_MY_ZSH_DIR}
    if [ ! -d ${OH_MY_ZSH_PLUGIN_DIR} ]; then
        mkdir -p ${OH_MY_ZSH_PLUGIN_DIR}
    fi
fi
cp shell/aliases.zsh ${OH_MY_ZSH_CUSTOM_DIR}
cp shell/exports.zsh ${OH_MY_ZSH_CUSTOM_DIR}
cp shell/robbyrussell.zsh-theme ${OH_MY_ZSH_CUSTOM_DIR}

if [ ! -d ${ZSH_AUTOSUGGESTION_DIR} ]; then
    git clone ${ZSH_AUTOSUGGESTION_URL} ${ZSH_AUTOSUGGESTION_DIR}
fi

if [ ! -d ${ZSH_SYNTAX_HIGHLIGHT_DIR} ]; then
    git clone ${ZSH_SYNTAX_HIGHLIGHT_URL} ${ZSH_SYNTAX_HIGHLIGHT_DIR}
fi

if [ ! -d ${ZSH_PYENV_DIR} ]; then
    git clone ${ZSH_PYENV_URL} ${ZSH_PYENV_DIR}
fi

chown -R ${USERNAME}:${USERNAME} ${OH_MY_ZSH_DIR}

# Install Handy tools
apt-get install -y \
    ctags \
    htop \
    ncdu \
    net-tools
