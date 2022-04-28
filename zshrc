# Use a color terminal
export TERM='xterm-256color'

# Exit if non-interactive
case $- in
  *i*) ;;
    *) return;;
esac

# Settings for umask
if (( EUID == 0 )); then
    umask 002
else
    umask 022
fi

## Functions

# List all occurrences of programm in current PATH
plap() {
    emulate -L zsh
    if [[ $# = 0 ]] ; then
        echo "Usage:    $0 program"
        echo "Example:  $0 zsh"
        echo "Lists all occurrences of program in the current PATH."
    else
        ls -l ${^path}/*$1*(*N)
    fi
}

# Find out which libs define a symbol
lcheck() {
    if [[ -n "$1" ]] ; then
        nm -go /usr/lib/lib*.a 2>/dev/null | grep ":[[:xdigit:]]\{8\} . .*$1"
    else
        echo "Usage: lcheck <function>" >&2
    fi
}

# Download a file and display it locally
uopen() {
    emulate -L zsh
    if ! [[ -n "$1" ]] ; then
        print "Usage: uopen \$URL/\$file">&2
        return 1
    else
        FILE=$1
        MIME=$(curl --head $FILE | \
               grep Content-Type | \
               cut -d ' ' -f 2 | \
               cut -d\; -f 1)
        MIME=${MIME%$'\r'}
        curl $FILE | see ${MIME}:-
    fi
}

# Memory overview
memusage() {
    ps aux | awk '{if (NR > 1) print $5;
                   if (NR > 2) print "+"}
                   END { print "p" }' | dc
}

# print hex value of a number
hex() {
    emulate -L zsh
    if [[ -n "$1" ]]; then
        printf "%x\n" $1
    else
        print 'Usage: hex <number-to-convert>'
        return 1
    fi
}

docker-clean-images() {
    # If there are dangling docker images, remove them
  if [[ $(docker images -a --filter=dangling=true -q) ]];
    then
    tput setaf 3; docker rmi $(docker images -a --filter=dangling=true -q) ; tput setaf 9
    else
        printf "\033[0;31mThere are no dangling images.\n"
    fi
}

docker-clean-ps() {
    # If there are stopped containers, remove them
  if [[ $(docker ps --filter=status=exited --filter=status=created -q) ]];
    then
    tput setaf 3; docker rm $(docker ps --filter=status=exited --filter=status=created -q) ; tput setaf 9
    else
        printf "\033[0;31mThere are no stopped containers.\n"
    fi
}

dfs() {
    df $* | sed -n '1p;/^\//p;'
}

# creates an alias and precedes the command with sudo if $EUID is not zero.
salias() {
  emulate -L zsh
  local only=0 ; local multi=0
  local key val
  while getopts ":hao" opt; do
    case $opt in
      o) only=1 ;;
      a) multi=1 ;;
      h)
        printf 'usage: salias [-hoa] <alias-expression>\n'
        printf '  -h      shows this help text.\n'
        printf '  -a      replace '\'' ; '\'' sequences with '\'' ; sudo '\''.\n'
        printf '          be careful using this option.\n'
        printf '  -o      only sets an alias if a preceding sudo would be needed.\n'
        return 0
        ;;
      *) salias -h >&2; return 1 ;;
    esac
  done
  shift "$((OPTIND-1))"

  if (( ${#argv} > 1 )) ; then
    printf 'Too many arguments %s\n' "${#argv}"
    return 1
  fi

  key="${1%%\=*}" ;  val="${1#*\=}"
  if (( EUID == 0 )) && (( only == 0 )); then
    alias -- "${key}=${val}"
  elif (( EUID > 0 )) ; then
    (( multi > 0 )) && val="${val// ; / ; sudo }"
    alias -- "${key}=sudo ${val}"
  fi

  return 0
}

# Check if we can read given files and source those we can.
function xsource () {
  if (( ${#argv} < 1 )) ; then
    printf 'usage: xsource FILE(s)...\n' >&2
    return 1
  fi

  while (( ${#argv} > 0 )) ; do
    [[ -r "$1" ]] && source "$1"
    shift
  done
  return 0
}

# Check if we can read a given file and 'cat(1)' it.
xcat() {
  emulate -L zsh
  if (( ${#argv} != 1 )) ; then
    printf 'usage: xcat FILE\n' >&2
    return 1
  fi

  [[ -r $1 ]] && cat $1
  return 0
}

# start timer
preexec() {
  timer=${timer:-$SECONDS}
}

# calculate execution time
precmd() {
  if [ $timer ]; then
    timer_show=$(($SECONDS - $timer))
    export EXECUTETIME="%F{238}${timer_show}s"
    unset timer
  fi
}

## Set important settings &options early

xsource /etc/default/locale

# enable parameter expansion, command substitution and arithmetic expansion in prompts
setopt PROMPT_SUBST

# append history list to the history file; this is the default but we make sure
# because it's required for share_history.
setopt append_history

# import new commands from the history file also in other zsh-session
setopt share_history

# save each command's beginning timestamp and the duration to the history file
setopt extended_history

# remove command lines from the history list when the first character on the
# line is a space
setopt histignorespace

# if a command is issued that can't be executed as a normal command, and the
# command is the name of a directory, perform the cd command to that directory.
setopt auto_cd

# in order to use #, ~ and ^ for filename generation grep word
# *~(*.gz|*.bz|*.bz2|*.zip|*.Z) -> searches for word not in compressed files
# don't forget to quote '^', '~' and '#'!
setopt extended_glob

# display PID when suspending processes as well
setopt longlistjobs

# report the status of backgrounds jobs immediately
setopt notify

# whenever a command completion is attempted, make sure the entire command path
# is hashed first.
setopt hash_list_all

# not just at the end
setopt completeinword

# Don't send SIGHUP to background processes when the shell exits.
setopt nohup

# make cd push the old directory onto the directory stack.
setopt auto_pushd

# avoid "beep"ing
setopt nobeep

# don't push the same dir twice.
setopt pushd_ignore_dups

# * shouldn't match dotfiles. ever.
setopt noglobdots

# use zsh style word splitting
setopt noshwordsplit

# don't error out when unset parameters are used
setopt unset

# add `|' to output redirections in the history
setopt histallowclobber

# try to avoid the 'zsh: no matches found...'
setopt nonomatch

# warning if file exists ('cat /dev/null > ~/.zshrc')
setopt NO_clobber

# don't warn me about bg processes when exiting
#setopt nocheckjobs

# alert me if something failed
#setopt printexitvalue

# Allow comments even in interactive shells
setopt interactivecomments

# if a new command line being added to the history list duplicates an older
# one, the older command is removed from the list
setopt histignorealldups

# History file settings
HISTFILE=~/.histfile
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=3000
SAVEHIST=10000

## Completion and git prompt setup

xsource ~/.config/git-prompt.sh

zstyle ':completion:*:*:git:*' script ~/.config/git-completion.bash
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' max-errors 2 numeric
zstyle ':completion:*' prompt '1'

# provides '.' completion
zstyle ':completion:*' special-dirs true

zstyle :compinstall filename '/home/peterm/.zshrc'

# add custom functions to fpath
fpath=(~/.config/zsh/functions $fpath)

# enable completion system
autoload -Uz compinit && compinit


## zsh-autosuggestions

source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh


## Key bindings

# use vi mode binds
bindkey -v

# bind up/down arrows to search history
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[OA" history-beginning-search-backward-end
bindkey "^[OB" history-beginning-search-forward-end

# disable terminal freeze/unfreeze behavior
stty -ixon

# bind forward search history to ctrl-t
bindkey "^T" forward-search-history

# bind beginning of line to ctrl-s
bindkey "^S" beginning-of-line

# fix some other binds
bindkey "^[f" forward-word
bindkey "^[b" backward-word
bindkey "^K" kill-line
bindkey "^E" end-of-line
bindkey "^O" accept-line-and-down-history

## use the vi navigation keys (hjkl) besides cursor keys in menu completion
#bindkey -M menuselect 'h' vi-backward-char        # left
#bindkey -M menuselect 'k' vi-up-line-or-history   # up
#bindkey -M menuselect 'l' vi-forward-char         # right
#bindkey -M menuselect 'j' vi-down-line-or-history # bottom

## set command prediction from history, see 'man 1 zshcontrib'
#is4 && zrcautoload predict-on && \
#zle -N predict-on         && \
#zle -N predict-off        && \
#bindkey "^X^Z" predict-on && \
#bindkey "^Z" predict-off

## define word separators (for stuff like backward-word, forward-word, backward-kill-word,..)
#WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>' # the default
#WORDCHARS=.
#WORDCHARS='*?_[]~=&;!#$%^(){}'
#WORDCHARS='${WORDCHARS:s@/@}'

#bindkey '\eq' push-line-or-edit

# Prompt

NEWLINE=$'\n'
PROMPT_PRE='%(!.%F{9}.%F{10})%n%F{15}@%F{7}%m %F{243}- %D{%a %b %d %H:%M:%S} - %(?.%F{10}0.%F{9}%?)%f'
PROMPT_SUF='${EXECUTETIME}${NEWLINE}%F{7}%0~%f%b %(!.%F{9}.%F{10})%#%F{7} '

# insert git status if repo
PROMPT=$PROMPT_PRE'$(git branch &>/dev/null;\
if [ $? -eq 0 ]; then \
  echo "$(echo `git status` | grep "nothing to commit" > /dev/null 2>&1; \
  if [ "$?" -eq "0" ]; then \
    echo "%F{28}"$(__git_ps1 " (%s)"); \
  else \
    echo "%F{1}"$(__git_ps1 " (%s)"); \
  fi) '$PROMPT_SUF'"; \
else \
  echo " '$PROMPT_SUF'"; \
fi)'

## aliases ##

alias less='less -R'

alias ls='ls -CF --color=always'
alias ll='ls -lF'
alias lla='ll -a'
alias lll='ll | less'
alias llal='lla | less'
alias lsl='ls | less'
alias la='ls -CFa'
alias lal='ls -CFa | less'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias fhere='find . -name '
alias df='df -Tha --total'
alias du='du -ch'
alias dus='du | sort -h'
alias dul='dus | less'
alias free='free -mt'
alias ps='ps auxf'
alias psl='ps | less'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias mkdir='mkdir -pv'
alias histg='history | grep'
alias x='exit'
alias clr='clear'
alias sudo='sudo '

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && (echo terminal; exit 0) || (echo error; exit 1))" "$([ $? = 0 ] && echo Task finished || echo Something went wrong!)" "$(history | sed -n "\$s/^\s*[0-9]\+\s*\(.*\)[;&|]\s*alert\$/\1/p")"'

## global aliases (for those who like them) ##

#alias -g '...'='../..'
#alias -g '....'='../../..'
#alias -g BG='& exit'
#alias -g C='|wc -l'
#alias -g G='|grep'
#alias -g H='|head'
#alias -g Hl=' --help |& less -r'
#alias -g K='|keep'
#alias -g L='|less'
#alias -g LL='|& less -r'
#alias -g M='|most'
#alias -g N='&>/dev/null'
#alias -g R='| tr A-z N-za-m'
#alias -g SL='| sort | less'
#alias -g S='| sort'
#alias -g T='|tail'
#alias -g V='| vim -'


## miscellaneous code ##

# Use a default width of 80 for manpages for more convenient reading
export MANWIDTH=${MANWIDTH:-80}

# Set a search path for the cd builtin
cdpath=(.. ~)

## tmux autoload ##

# if tmux is installed, attach to the main session, or create it
if [ `command -v tmux` > /dev/null ]; then
  if [ ! "$TMUX" ]; then
    tmux -2 attach -t main || tmux -2 new -s main
  else
    source ~/.profile
  fi
fi

## EOF
