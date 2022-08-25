if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

export PATH=/opt/homebrew/opt/libpq/bin:$PATH

export LANG=en_US.UTF-8
export EDITOR=nvim

alias textedit='open -a textedit'
alias finder='open -a finder'

alias vi='nvim'
alias ls='ls -G'
alias ll='ls -alG'
alias dc='docker-compose'
alias ip='curl -4 ifconfig.co'

alias gs='git status'
alias gl='git log --name-only'
alias gp='git push'
alias gu='git pull --ff-only'
alias gr='git pull --rebase --autostash'

bindkey -s "^o" "cd ..\n"
function chpwd() {
    emulate -L zsh
    ls -al
}

function workon () {
  source $HOME/.venv/$1/bin/activate
}
