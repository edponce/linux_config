# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=100000
HISTTIMEFORMAT="[%F %T] "
HISTIGNORE="l:ll:la:ls:ls -l:ls -la:ls -lh:LS:sl:pwd:cd:cd :cd ..:date:ps:vi:vim:history:"
#HISTIGNORE+="$(grep '^alias' $HOME/.bash_aliases | sed 's/=/ /' | cut -d' ' -f2 | tr '\n' ':')"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\[\033[01;32m\]\$\[\033[00m\] '

    # Controls for sync_history function
    history_last_sync_seconds=$SECONDS
    declare -r history_max_sync_seconds=60

    # Colors
    declare -r off_c="\[\033[00m\]"
    declare -r black_c="\[\033[01;30m\]"
    declare -r red_c="\[\033[01;31m\]"
    declare -r green_c="\[\033[01;32m\]"
    declare -r yellow_c="\[\033[01;33m\]"
    declare -r blue_c="\[\033[01;34m\]"
    declare -r magenta_c="\[\033[01;35m\]"
    declare -r cyan_c="\[\033[01;36m\]"
    declare -r white_c="\[\033[01;37m\]"
    declare -r history_backup_dir="$HOME/.history"

    prompt_command() {
        local -r err_cmd_val=$? # get error from last command
        local err_cmd 

        local history_last file_num history_basefile history_backupfile 
        local history_val history_curr git_branch git_branch_str prompt_symbol

        # History consistency between shells
        if [ $((SECONDS - history_last_sync_seconds)) -gt $history_max_sync_seconds ]; then
            history -a
            history -c
            history -r
        fi

        # Get number of last history command
        history_last=$(history 1 | awk '{ print $1 }')
        if [[ ! $history_last = *[[:digit:]] ]]; then
            history_last=0
        elif [ $history_last -ge $HISTSIZE ]; then
            history_last=0
            [ ! -d "$history_backup_dir" ] && mkdir "$history_backup_dir"
            file_num=$(ls "$history_backup_dir" | awk -F. '{ print $2 }' | sort | tail -n 1)
            if [[ $file_num = *[[:digit:]] ]]; then
                file_num=$((file_num + 1))
            else
                file_num=0
            fi
            history_basefile=$(basename "$HISTFILE")
            history_backupfile="$history_backup_dir/${history_basefile#*.}.$file_num"
            grep -v "^#" "$HISTFILE" > "$history_backupfile"
            gzip "$history_backupfile"
            cat /dev/null > "$HISTFILE"
            history -c
            history -r
        fi 

        history_val=$((history_last + 1))
        history_curr="(${cyan_c}${history_val}${off_c})"

        # Check if current dir has a .git repo, but hide $HOME git repo
        git_branch=
        if [ "$PWD" != "$HOME" ]; then
            if [ ! -z "$(ls -A | grep '^.git$')" ]; then
                git_branch_str="$(git branch | grep '\*' | awk '{ print $NF }')"
                git_branch="${cyan_c}${git_branch_str:-?}${off_c}:"
            fi
        fi

        # Check if error occurred from last command
        err_cmd=
        if [ $err_cmd_val -ne 0 ]; then
            err_cmd="[${red_c}${err_cmd_val}${off_c}]"
        fi

        # Set prompt symbol depending on terminal
        if [ -z "$STY" ]; then
            # LXTerminal
            prompt_symbol="${green_c}\$${off_c}"
        else
            # GNU Screen
            prompt_symbol="${yellow_c}\$${off_c}"
        fi

        # Set default interactive prompt
        PS1="${debian_chroot:+($debian_chroot)}${history_curr}${err_cmd} ${git_branch}\W${prompt_symbol} "
    }
    
    prompt_234_command() {
        # Set prompts
        PS2="...${green_c}>${off_c} " # continuation interactive prompt
        PS3="select${cyan_c}>${off_c} " # used by 'select' in shell script
        PS4="$0${red_c}>${off_c} " # used by 'set -x' to prefix tracing output
    }

    # Update prompt commands
    PROMPT_COMMAND=prompt_command
    prompt_234_command
    #######################################
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Disable Ctrl + D to close terminal window
set -o ignoreeof

# Java VM environment
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"

# Set linker library paths
# CUDA libraries
# /usr/local/cuda -> /usr/local/cuda-8.0
# /usr/local/cuda/lib64 -> /usr/local/cuda/targets/x86_64-linux/lib
export LD_LIBRARY_PATH="/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# OpenMP
export OMP_NUM_THREADS=$(lscpu | awk -v fac=2 '/^CPU\(s\):/ { print "scale=0;"($2+fac-1)"/"fac }' | bc)
export OMP_THREAD_LIMIT=$(lscpu | awk '/^CPU\(s\):/ { print $2 }')
export OMP_SCHEDULE="dynamic,1"

# RISC-V
export RISCV="/opt/riscv"
#export PATH="$RISCV/bin${PATH:+:$PATH}"
# NVIDIA path
# created symlinks in /usr/bin to files:
#export PATH="/usr/lib/nvidia-current/bin${PATH:+:$PATH}" 
# CUDA path
#export PATH="/usr/local/cuda/bin:${PATH:+:$PATH}"
#export PATH="/usr/local/cuda/extras/demo_suite:${PATH:+:$PATH}"
#export PATH="/usr/local/cuda/samples/bin/x86_64/linux/release${PATH:+:$PATH}"
# SASv9.4 root directory
#export PATH="/usr/local/SASHome/SASFoundation/9.4:${PATH:+:$PATH}"
# Python local bin directory (required for Jupyter notebook)
#export PATH="$HOME/.local/bin:${PATH:+:$PATH}"
# Rstudio
#export PATH="/usr/local/lib/rstudio/bin:${PATH:+:$PATH}"
# EPSXE (games)
#export PATH="$HOME/Documents/games:${PATH:+:$PATH}"
env_values=(
"$RISCV/bin"
"/usr/local/cuda/extras/demo_suite"
"/usr/local/cuda/bin"
"/usr/local/SASHome/SASFoundation/9.4"
"/usr/local/lib/rstudio/bin"
"$HOME/Documents/games"
"$HOME/.local/bin"
"$HOME/bin"
)
. ~/bin/set_envvar PATH "${env_values[@]}"
unset env_values num_cpus

