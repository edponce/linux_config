# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# Set display to main monitor if only a single monitor is active
# This prevents displaying in non-connected monitor when in suspend/lock/logout state
# and monitor is disconnected.
if [ "$(command -v xrandr)" ]; then
    if [ $(xrandr --listactivemonitors | awk -F':' '/Monitors/ { print $2 }') -eq 1 ]; then
        [ "$(command -v monitor_change)" ] && monitor_change -p 0
    fi
fi

# Set keymap: model, layout, and disable Caps Lock
[ "$(command -v setxkbmap)" ] && setxkbmap -model pc104 -layout us -option caps:none

# Enable numlock
[ "$(command -v numlockx)" ] && numlockx on

# General environment settings
export VISUAL="$(which vim)"
export EDITOR="$VISUAL"
#export MAIL="/var/spool/mail/$USER"
export MAILPATH=/var/spool/mail/$USER?"$USER, you've got mail!":/var/spool/mail/mail?"root, you've got mail!"
export PAGER="$(which less)"

# If running bash, include .bashrc if it exists
if [ -n "$BASH_VERSION" ]; then
    ss="$HOME/.bashrc"
    [ -f "$ss" ] && . "$ss"
fi

# General/local environment settings
environ_files=(
"$HOME/.shell_environ"
"$HOME/.shell_environ2"
)
for f in "${environ_files[@]}"; do
    [ -f "$f" ] && . "$f"
done

unset environ_files f
