#----------
# Variables
#----------
export LANG=en_US.UTF-8
# export LC_ALL=en_US.UTF-8

# https://ianyepan.github.io/posts/moving-away-from-ohmyzsh/
#----------------------------
# Shell History
#----------------------------
HISTFILE=~/.zsh_history
HISTSIZE=125000
SAVEHIST=122500
#  This  option  works  like  APPEND_HISTORY  except that new history lines are
#  added to the $HISTFILE incrementally (as soon as they are entered), rather
#  than waiting until the shell exits.  The file will still be periodically
#  re-written to trim it when the number of lines grows 20% beyond the value
#  specified by $SAVEHIST (see also the HIST_SAVE_BY_COPY option).
setopt INC_APPEND_HISTORY
# If the internal history needs to be trimmed to add the current command line,
# setting this option will cause the oldest history event that has a duplicate
# to be lost before losing a unique event from the list.   You  should  be  sure
# to set the value of HISTSIZE to a larger number than SAVEHIST in order to give
# you some room for the duplicated events, otherwise this option will behave
# just like HIST_IG‐
# NORE_ALL_DUPS once the history fills up with unique events.
setopt HIST_EXPIRE_DUPS_FIRST
# When searching for history entries in the line editor, do not display
# duplicates of a line previously found, even if the duplicates are not
# contiguous.
setopt HIST_IGNORE_ALL_DUPS
# Do not enter command lines into the history list if they are duplicates of the
# previous event.
setopt HIST_IGNORE_DUPS
# When searching for history entries in the line editor, do not display
# duplicates of a line previously found, even if the duplicates are not
# contiguous.
setopt HIST_FIND_NO_DUPS
# When writing out the history file, older commands that duplicate newer ones
# are omitted.
setopt HIST_SAVE_NO_DUPS
# Whenever the user enters a line with history expansion, don't execute the line
# directly; instead, perform history expansion and reload the line into the
# editing buffer.
setopt HIST_VERIFY

fpath+=~/.zfunc
zstyle :compinstall filename '${HOME}/.zshrc'

export GOPATH="$HOME/go"

export PATH=$HOME/bin:$HOME/.local/bin:$HOME/go/bin:/usr/local/bin:/usr/local/go/bin:/usr/local:/usr/bin$PATH
if command -v code >/dev/null 2>&1; then
  export BROWSER="$(dirname "$(dirname "$(command -v code)")")/helpers/browser.sh"
fi

#----------------------------
# Eval some Stuff
#----------------------------
eval "$(direnv hook zsh)"
eval "$(mise completion zsh)"
# eval "$(gh tp completion zsh)"
#-----------------------------
# Prompt Things
#-----------------------------
autoload -Uz colors && colors
setopt promptsubst
autoload -Uz vcs_info

# vcs_info configuration
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '%F{green}*%f'
zstyle ':vcs_info:git:*' unstagedstr '%F{red}*%f'
zstyle ':vcs_info:git:*' formats ' %F{cyan}%b%f%u%c'
zstyle ':vcs_info:git:*' actionformats ' %F{cyan}%b%f|%F{red}%a%f%u%c'

precmd() { vcs_info }

PROMPT='%F{blue}%~%f${vcs_info_msg_0_} %F{magenta}❯%f '

#-----------------------------
# Alias stuff
#-----------------------------
#alias ls='ls --color -F'
#alias ll='ls --color -lh'
# Return all `history` not just the default last 16
# https://derflounder.wordpress.com/2022/01/30/zsh-history-command-doesnt-show-all-history-entries-by-default/
alias history='history 1'
# WSL4Lyfe!
alias ssh='ssh.exe'
alias ssh-add='ssh-add.exe'
alias :q='exit'
alias miso='mise'

#
# GH CLI
#
alias gpv='gh pr view -w'
# https://github.com/Phantas0s/.dotfiles/blob/cb761b6a72e3593881dea6c0e922c71d0b6b81aa/aliases/aliases
# +----+
# | ls |
# +----+

alias ls='ls --color=auto'
alias l='ls -l'
alias ll='ls -lahF'
alias lls='ls -lahFtr'
alias la='ls -A'
alias lc='ls -CF'

# +------+
# | wget |
# +------+
#alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"

# +----+
# | cp |
# +----+

alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias la='ls -alh'

# +------+
# | grep |
# +------+

alias grep="grep -P -i --color=auto"

# +------+
# | xlip |
# +------+

alias cb='xclip -sel clip'

# +--------+
# | Golang |
# +--------+

alias gob="go build"
alias gor="go run"
alias goc="go clean -i"
alias gta="go test ./..."    # go test all
alias gia="go install ./..." # go install all

# +------+
# | Hugo |
# +------+

alias hugostart="hugo server -DEF --ignoreCache --disableFastRender"

# +-----+
# | Git |
# +-----+

alias gs='git status'
alias gss='git status -s'
alias ga='git add'
alias gp='git push'
alias gpraise='git blame'
alias gpo='git push origin'
alias gpof='git push origin --force-with-lease'
alias gpofn='git push origin --force-with-lease --no-verify'
alias gpt='git push --tag'
alias gtd='git tag --delete'
alias gtdr='git tag --delete origin'
alias grb='git branch -r' # display remote branch
alias gplo='git pull origin'
alias gb='git branch '
alias gc='git commit'
alias gd='git diff --ignore-space-at-eol --diff-filter=M'
alias gco='git checkout '
alias gl='git log --oneline'
alias gr='git remote'
alias grs='git remote show'
alias glol='git log --graph --abbrev-commit --oneline --decorate'
alias gclean="git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 git branch -d"                                                                                                                                                                             # Delete local branch merged with master
alias gblog="git for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:red)%(refname:short)%(color:reset) - %(color:yellow)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:blue)%(committerdate:relative)%(color:reset))'" # git log for each branches
alias gsub="git submodule update --remote"                                                                                                                                                                                                                                    # pull submodules
alias gj="git-jump"                                                                                                                                                                                                                                                           # Open in vim quickfix list files of interest (git diff, merged...)

# +--------+
# | docker |
# +--------+
alias dockls="docker container ls | awk 'NR > 1 {print \$NF}'"                # display names of running containers
alias dockRr='docker rm $(docker ps -a -q)'                                   # delete every containers / images
alias dockRr='docker rm $(docker ps -a -q) && docker rmi $(docker images -q)' # delete every containers / images
alias dockstats='docker stats $(docker ps -q)'                                # stats on images
alias dockimg='docker images'                                                 # list images installed
alias dockprune='docker system prune -a'                                      # prune everything
alias dockceu='docker-compose run --rm -u $(id -u):$(id -g)'                  # run as the host user
alias dockce='docker-compose run --rm'

export EDITOR=vim
export GIT_EDITOR=vim
export GIT_PAGER='vim -R -c "set ft=diff" -'
# Disable ANSI color codes when git pipes output to a pager so vim receives
# clean text it can syntax-highlight itself via ft=diff.
[[ -z "$(git config --global color.pager)" ]] && git config --global color.pager false
bindkey -v
export KEYTIMEOUT=1

#-----------------------------
# Functions
#-----------------------------
# Make this a function
#  xclip -selection clipboard -i < file.txt

#------------------------------
# ShellFuncs
#------------------------------
# -- coloured manuals
man() {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}

autoload -Uz compinit && compinit
# TODO Revisit https://thevaluable.dev/zsh-completion-guide-examples/
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/completion.zsh
# case insensitive (all), partial-word and substring completion

unsetopt menu_complete # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
  adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
  clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
  gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
  ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
  named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
  operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
  rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
  usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

# https://wiki.archlinux.org/title/Zsh#Key_bindings
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Up]}" ]] && bindkey -- "${key[Up]}" up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

# https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#manual-git-clone
#-----------------------------
# ZSH Autosuggestions
#-----------------------------
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

fpath+=~/.zfunc
autoload -Uz compinit
compinit

eval "$(/usr/bin/mise activate zsh)"

# pnpm
export PNPM_HOME="/home/bmorriso/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
