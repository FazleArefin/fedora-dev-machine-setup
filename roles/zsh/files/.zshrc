# 📂 Paths & Environment
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export TERM="xterm-256color"

# 📜 History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=$HISTSIZE

# ⚡ Zinit Setup
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

# 🏗️ Core Library & Completions (Immediate)
zinit light zsh-users/zsh-completions
zinit snippet OMZL::completion.zsh

# 🚀 Turbo Mode Plugins (Loaded in background after prompt appears)
zinit ice wait"0" lucid; zinit snippet OMZL::git.zsh
zinit ice wait"0" lucid; zinit snippet OMZL::theme-and-appearance.zsh

# Oh-My-Zsh Plugins
zinit ice wait"0" lucid; zinit snippet OMZP::colored-man-pages
zinit ice wait"0" lucid; zinit snippet OMZP::docker
zinit ice wait"0" lucid; zinit snippet OMZP::git
zinit ice wait"0" lucid; zinit snippet OMZP::git-extras
zinit ice wait"0" lucid; zinit snippet OMZP::pip
zinit ice wait"0" lucid; zinit snippet OMZP::pylint
zinit ice wait"0" lucid; zinit snippet OMZP::python
zinit ice wait"0" lucid; zinit snippet OMZP::rust
zinit ice wait"0" lucid; zinit snippet OMZP::sudo

# 🔍 Suggesting & Highlighting (Highlighting MUST be last)
zinit ice wait"0" lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

zinit ice wait"0" lucid
zinit light zsh-users/zsh-syntax-highlighting

# 🎨 Themes Section

# pure theme
zinit light mafredri/zsh-async
zinit ice pick"pure.zsh" src"pure.zsh"
zinit light sindresorhus/pure

# Powerlevel10k: The most popular and fastest option
# zinit ice depth"1"; zinit light romkatv/powerlevel10k

# Bullet Train: Requires specific file picking
# zinit ice pick"bullet-train.zsh-theme"; zinit light caiogondim/bullet-train.zsh

# Spaceship: Highly customizable
# zinit ice pick"spaceship.zsh"; zinit light spaceship-prompt/spaceship-prompt


# 🔑 SSH-Agent Fix
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
     echo "Initialising new SSH agent..."
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
     echo succeeded
     chmod 600 "${SSH_ENV}"
     . "${SSH_ENV}" > /dev/null
     /usr/bin/ssh-add;
}

if [ -f "${SSH_ENV}" ]; then
     source "${SSH_ENV}" > /dev/null
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
          start_agent;
     }
else
     start_agent;
fi

# 🛤️ System Paths
export PATH=$PATH:$HOME/.cargo/bin        # Rust
export GOPATH=$HOME/go                    # Go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/.local/bin        # pipx / local binaries

# 🐍 Python Settings
export PIPENV_VENV_IN_PROJECT=1

# 📎 External Configs
[[ -f ~/.shell_aliases.sh ]] && source ~/.shell_aliases.sh
[[ -f ~/.shell_functions.sh ]] && source ~/.shell_functions.sh
[[ -f ~/.shell_variables.sh ]] && source ~/.shell_variables.sh

# 🔎 Tools & Utilities
source <(fzf --zsh)
eval "$(zoxide init zsh)"
