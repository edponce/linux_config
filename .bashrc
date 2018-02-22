# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return ;;
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
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Try to force terminal to use 256 color in X sessions
if [ -n "$DISPLAY" ] && [ "$TERM" = xterm ]; then
    export TERM=xterm-256color
fi

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    *xterm-*color*) color_prompt=yes ;;
esac

# Uncomment for a colored prompt, if the terminal has the capability
#force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 > /dev/null 2>&1; then
        # We have color support, assume it's compliant with ECMA-48 (ISO/IEC-6429).
        # Lack of such support is extremely rare,
        # and such a case would tend to support setf rather than setaf.
        color_prompt=yes
    fi
fi

# Set colors, do not unset these variables
if [ "$color_prompt" = yes ]; then
    off_c="\[\033[00m\]"
    black_c="\[\033[01;30m\]"
    red_c="\[\033[01;31m\]"
    green_c="\[\033[01;32m\]"
    yellow_c="\[\033[01;33m\]"
    blue_c="\[\033[01;34m\]"
    magenta_c="\[\033[01;35m\]"
    cyan_c="\[\033[01;36m\]"
    white_c="\[\033[01;37m\]"

    # Colors for GCC warnings and errors
    export GCC_COLORS="error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01"
fi

# Colorize files
if [ -x /usr/bin/dircolors ]; then
    test -r "$HOME/.dircolors" && eval "$(dircolors -b "$HOME/.dircolors")" || eval "$(dircolors -b)"
fi

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Settings for history length, see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=100000
HISTTIMEFORMAT="[%F %T] "
# Commands to ignore and not save in history (make sure it ends with ':')
HISTIGNORE="ls -l:ls -a:ls -la:ls -lh:ls -lah:LS:sl:pwd:cd:cd :cd ..:ps:ps -A:"
HISTIGNORE+="exit:clear:history:env:date:vi:vim:cal:calendar:"
for f in "$HOME/.shell_aliases" "$HOME/.shell_aliases2"; do
    if [ -f "$f" ]; then
        HISTIGNORE+="$(awk '/^\s*alias/ { sub("="," "); print $2 }' "$f" | tr '\n' ':')"
    fi
done

# Controls for sync_history function, do not unset these variables
hist_last_sync_sec=$SECONDS
hist_max_sync_sec=90
hist_backup_dir="$HOME/.local_history"

prompt_command() {
    last_cmd_val=$? # get error from last command
    last_cmd_str=""
    hist_last_val=0
    hist_file_num=0
    hist_base_file=""
    hist_backup_file=""
    hist_curr_val=0
    hist_curr_str=""
    repo_toplevel=""
    repo_project=""
    repo_branch=""
    repo_branch_str=""
    repo_branch_cnt=0
    prompt_symbol_str=""

    # History consistency between shells
    if [ $((SECONDS - hist_last_sync_sec)) -gt $hist_max_sync_sec ]; then
        history -a
        history -c
        history -r
    fi

    # Get number of last history command
    hist_last_val=$(history 1 | awk '{ print $1 }')
    if [[ ! $hist_last_val = *[[:digit:]] ]]; then
        hist_last_val=0
    elif [ $hist_last_val -ge $HISTSIZE ]; then
        hist_last_val=0
        [ -d "$hist_backup_dir" ] || mkdir "$hist_backup_dir"
        hist_file_num=$(ls "$hist_backup_dir" | awk -F. '{ print $2 }' | sort | tail -n 1)
        if [[ $hist_file_num = *[[:digit:]] ]]; then
            hist_file_num=$((hist_file_num + 1))
        else
            hist_file_num=0
        fi
        hist_base_file="$(basename "$HISTFILE")"
        hist_backup_file="$hist_backup_dir/${hist_base_file#*.}.$hist_file_num"
        grep -v "^#" "$HISTFILE" > "$hist_backup_file"
        gzip "$hist_backup_file"
        cat /dev/null > "$HISTFILE"
        history -c
        history -r
    fi

    hist_curr_val=$((hist_last_val + 1))
    hist_curr_str="(${cyan_c}${hist_curr_val}${off_c})"

    # Check if current dir is part of a Git repo, but hide $HOME git repo
    repo_toplevel="$(git rev-parse --show-toplevel 2> /dev/null)"
    if [ $? -eq 0 ] && [ "$repo_toplevel" != "$HOME" ]; then
        repo_project=$(grep -iv 'unnamed' "$repo_toplevel/.git/description" | head -n 1)
        repo_branch="$(git branch | awk '/^\*/ { print $NF }')"
        repo_branch_cnt=$(git branch | wc -l)
        if [ $repo_branch_cnt -eq 1 ]; then
            repo_branch_str="[${cyan_c}${repo_project:-?}${off_c}:${green_c}${repo_branch:-?}${off_c}]"
        else
            repo_branch_str="[${cyan_c}${repo_project:-?}${off_c}:${yellow_c}${repo_branch:-?}${off_c}]"
        fi
    else
        # Check if current dir is part of a SVN repo
        repo_toplevel="$(svn info 2> /dev/null)"
        if [ $? -eq 0 ]; then
            repo_project="$(svn info | awk -F/ '/^Relative URL/ { print $2 }')"
            repo_branch="$(svn info | awk -F/ '/^Relative URL/ { if ($3 == "trunk") print $3; else print $4 }')"
            repo_branch_str="[${magenta_c}${repo_project:-?}${off_c}:${green_c}${repo_branch:-?}${off_c}]"
        fi
    fi

    # Check if error occurred from last command
    if [ $last_cmd_val -ne 0 ]; then
        last_cmd_str="[${red_c}${last_cmd_val}${off_c}]"
    fi

    # Set prompt symbol depending on terminal
    case "$TERM" in
        screen*) prompt_symbol_str="${yellow_c}\$${off_c}" ;; # GNU Screen
        *) prompt_symbol_str="${green_c}\$${off_c}" ;;
    esac

    # Set default interactive prompt
    PS1="${hist_curr_str}${last_cmd_str}${repo_branch_str} \W${prompt_symbol_str} "

    unset last_cmd_val last_cmd_str prompt_symbol_str
    unset hist_last_val hist_file_num hist_base_file hist_backup_file hist_curr_val hist_curr_str
    unset repo_toplevel repo_project repo_branch repo_branch_str repo_branch_cnt
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
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# General/local alias settings
alias_files=(
"$HOME/.shell_aliases"
"$HOME/.shell_aliases2"
)
for f in "${alias_files[@]}"; do
    [ -f "$f" ] && . "$f"
done

unset color_prompt alias_files f

