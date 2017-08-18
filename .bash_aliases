# Common directories 
alias down='cd ~/Downloads'
alias games='cd ~/Documents/games'

# Work directories 
alias resume='cd ~/Documents/personal/resume'
alias dissertation='cd ~/Documents/utk/dissertation/thesis_template'
alias evidence='cd ~/Documents/utk/sp17/cosc690'
alias masprng='cd ~/Documents/utk/sprng/masprng'
alias mcg='cd ~/Documents/utk/modified_cg'
alias word2vec='cd ~/Documents/utk/word2vec/word2vec_dev'
alias pgs='cd ~/Documents/pgs'
alias mri='cd ~/Documents/utk/mri'
alias rdf='cd ~/Documents/utk/rdf_analysis'
alias caaqa='cd ~/Documents/caaqa/6ed'
alias sacnas='cd ~/Documents/utk/sacnas_chapter'
alias nuc='cd ~/Documents/utk/sp16/COSC\ 575\ HPC\ ModelVisual'

# Commands/utilities
alias clear='tput clear'
alias hs='history 15'
alias hss='history 30'
alias hsss='history 50'
alias dropbox_start='dbus-launch dropbox start'
alias iotop='sudo iotop'
alias ntop='sudo ntop -u ntop -P /var/lib/ntop -a /var/log/ntop/access.log -i wlp2s0 -p /etc/ntop/protocol.list -O /var/log/ntop'
alias powertop='sudo powertop'
alias imagemagick='display-im6'
alias mag1='xmag -source 480x135 -mag 3'
alias mag2='xmag -source 960x270 -mag 2'

# NVIDIA, settings and visual profiler
alias nvidia-settingsx='optirun nvidia-settings -c :8' 
alias nvvpx='optirun nvvp'

# Session control
alias poweroff='sudo systemctl poweroff'
alias reboot='sudo systemctl reboot'
alias suspend='sudo systemctl suspend'
alias hibernate='sudo systemctl hibernate'

#alias battery='upower -i `upower -e | grep battery` | grep -E "state|percentage"'
alias battery='acpi -b -i'

# Computers
# see ~/.ssh/config

# Entertainment
alias relax='cvlc -I ncurses -Z -L ~/Music/Cultura\ Profetica/M.O.T.A.'
alias music='cvlc -I ncurses -Z -L ~/Music'
alias steamx='nvidiax -p 3 -t 1 -r steam'
