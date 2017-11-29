# Common directories
alias down='cd $HOME/Downloads'
alias doc='cd $HOME/Documents'

# Commands/utilities
alias clear='tput clear'
alias h='history 25'
alias hh='history 50'
alias hhh='history 100'
alias dropbox_start='dbus-launch dropbox start; sleep 3'
alias iotop='sudo iotop'
alias ntop='ntop -u ntop -P /var/lib/ntop -a /var/log/ntop/access.log -i enp0s25 -p /etc/ntop/protocol.list -O /var/log/ntop'
alias powertop='sudo powertop'
alias imagemagick='display-im6'
alias mag1='xmag -source 480x135 -mag 3'
alias mag2='xmag -source 960x270 -mag 2'

# Session control
alias poweroff='sudo systemctl poweroff'
alias reboot='sudo systemctl reboot'
alias suspend='sudo systemctl suspend'
alias hibernate='sudo systemctl hibernate'

# ls and handy aliases (with color support)
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
if [ -x /usr/bin/dircolors ]; then
    test -r $HOME/.dircolors && eval "$(dircolors -b $HOME/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Add an "alert" alias for long running commands.
# Use like so: sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n 1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

