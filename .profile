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

# If running bash, include .bashrc if it exists
if [ -n "$BASH_VERSION" ]; then
    if [ -f $HOME/.bashrc ]; then
        . $HOME/.bashrc
    fi
fi

# Environment utilities (e.g., set_envvar)
. $HOME/bin/environ_utils

# User private bin paths
#export PATH="$HOME/bin:${PATH:+:$PATH}"
#export PATH="$HOME/.local/bin:${PATH:+:$PATH}"
env_values=(
            $HOME/bin
            $HOME/.local/bin
           )
set_envvar PATH "${env_values[@]}"

unset env_values

