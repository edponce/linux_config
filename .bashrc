# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Append to the history file, don't overwrite it
shopt -s histappend

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# Disable Ctrl + d to close terminal window
set -o ignoreeof

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x "/usr/bin/lesspipe" ] && eval "$(SHELL="/bin/sh" lesspipe)"

# Try to force terminal to use 256 color in X sessions
if [ -n "$DISPLAY" ] && [ "$TERM" = "xterm" ]; then
    export TERM="xterm-256color"
fi

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    *xterm-*color*) color_prompt="yes" ;;
esac

# Uncomment for a colored prompt, if the terminal has the capability
#force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
    if [ -x "/usr/bin/tput" ] && tput setaf 1 >& /dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt="yes"
    fi
fi

# Set colors, do not unset these variables
if [ "$color_prompt" = "yes" ]; then
    typeset -r off_c="\[\033[00m\]"
    typeset -r black_c="\[\033[01;30m\]"
    typeset -r red_c="\[\033[01;31m\]"
    typeset -r green_c="\[\033[01;32m\]"
    typeset -r yellow_c="\[\033[01;33m\]"
    typeset -r blue_c="\[\033[01;34m\]"
    typeset -r magenta_c="\[\033[01;35m\]"
    typeset -r cyan_c="\[\033[01;36m\]"
    typeset -r white_c="\[\033[01;37m\]"

    # Colors for GCC warnings and errors
    export GCC_COLORS="error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01"
fi

# Colorize files
if [ -x "/usr/bin/dircolors" ]; then
    test -r "$HOME/.dircolors" && eval "$(dircolors -b "$HOME/.dircolors")" || eval "$(dircolors -b)"
fi

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL="ignoreboth"

# Settings for history length, see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=100000
HISTTIMEFORMAT="[%F %T] "
# Commands to ignore and not save in history (make sure it ends with ':')
HISTIGNORE="ls -l:ls -a:ls -la:ls -lh:ls -lah:LS:sl:pwd:cd:cd :cd ..:ps:ps -A:"
HISTIGNORE+="exit:clear:history:env:date:vi:vim:cal:calendar:"
for each in "$HOME/.shell_aliases" "$HOME/.shell_aliases2"; do
    if [ -f "$each" ]; then
        HISTIGNORE+="$(grep '^\W*alias' "$each" | sed 's/=/ /' | awk '{ print $2 }' | tr '\n' ':')"
    fi
done

# Controls for sync_history function, do not unset these variables
history_last_sync_seconds=$SECONDS
typeset -ir history_max_sync_seconds=90
typeset -r history_backup_dir="$HOME/.history"

prompt_command() {
    local -ir err_cmd_val=$? # get error from last command
    local err_cmd
    local history_last
    local file_num
    local history_basefile
    local history_backupfile
    local -i history_val
    local history_curr
    local git_toplevel
    local git_project
    local git_branch
    local git_branch_str
    local -i git_branch_cnt
    local prompt_symbol

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
        [ -d "$history_backup_dir" ] || mkdir "$history_backup_dir"
        file_num=$(ls "$history_backup_dir" | awk -F. '{ print $2 }' | sort | tail -n 1)
        if [[ $file_num = *[[:digit:]] ]]; then
            file_num=$((file_num + 1))
        else
            file_num=0
        fi
        history_basefile="$(basename "$HISTFILE")"
        history_backupfile="$history_backup_dir/${history_basefile#*.}.$file_num"
        grep -v "^#" "$HISTFILE" > "$history_backupfile"
        gzip "$history_backupfile"
        cat /dev/null > "$HISTFILE"
        history -c
        history -r
    fi

    history_val=$((history_last + 1))
    history_curr="(${cyan_c}${history_val}${off_c})"

    # Check if current dir is part of a .git repo, but hide $HOME git repo
    git_toplevel="$(git rev-parse --show-toplevel 2> /dev/null)"
    if [ $? -eq 0 ] && [ "$git_toplevel" != "$HOME" ]; then
        git_project=$(grep -v 'Unnamed' "$git_toplevel/.git/description")
        git_branch_str="$(git branch | grep '^\*' | awk '{ print $NF }')"
        git_branch_cnt=$(git branch | wc -l)
        if [ $git_branch_cnt -eq 1 ]; then
            git_branch="[${cyan_c}${git_project:-?}${off_c}:${green_c}${git_branch_str:-?}${off_c}]"
        else
            git_branch="[${cyan_c}${git_project:-?}${off_c}:${yellow_c}${git_branch_str:-?}${off_c}]"
        fi
    fi

    # Check if error occurred from last command
    if [ $err_cmd_val -ne 0 ]; then
        err_cmd="[${red_c}${err_cmd_val}${off_c}]"
    fi

    # Set prompt symbol depending on terminal
    case "$TERM" in
        screen*) prompt_symbol="${yellow_c}\$${off_c}" ;; # GNU Screen
        *) prompt_symbol="${green_c}\$${off_c}" ;; # LXTerminal
    esac

    # Set default interactive prompt
    PS1="${history_curr}${err_cmd}${git_branch} \W${prompt_symbol} "
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

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f "/usr/share/bash-completion/bash_completion" ]; then
    . "/usr/share/bash-completion/bash_completion"
  elif [ -f "/etc/bash_completion" ]; then
    . "/etc/bash_completion"
  fi
fi

# General/local environment and alias settings
shell_files=(
              "$HOME/.shell_environ"
              "$HOME/.shell_environ2"
              "$HOME/.shell_aliases"
              "$HOME/.shell_aliases2"
             )
for each in "${shell_files[@]}"; do
    if [ -f "$each" ]; then
        . "$each"
    fi
done

unset color_prompt shell_files

