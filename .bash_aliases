# Common directories 
alias down='cd ~/Downloads'

# Work directories 
alias dissertation='cd ~/Documents/utk/dissertation/thesis_template'
alias intro='cd ~/Documents/utk/sp17/cosc505'
alias evidence='cd ~/Documents/utk/sp17/cosc690'
alias masprng='cd ~/Documents/utk/sprng/masprng'
alias mcg='cd ~/Documents/utk/modified_cg'
alias word2vec='cd ~/Documents/utk/word2vec/word2vec_dev'
alias pgs='cd ~/Documents/pgs'
alias mri='cd ~/Documents/utk/mri'
alias rdf='cd ~/Documents/utk/rdf_analysis'

# Commands/utilities
alias clear='tput clear'
alias hs='history 15'
alias hss='history 30'
alias hsss='history 50'
alias dropbox_start='dbus-launch dropbox start'
alias iotop='sudo iotop'
alias powertop='sudo powertop'
alias imagemagick='display-im6'
alias screen='cmd_clear screen'
alias screen0='cmd_clear screen -c ~/.screen/screenrc0'

# NVIDIA, settings and visual profiler
alias nvidia-settingsx='optirun nvidia-settings -c :8' 
alias nvvpx='optirun nvvp'

# Session control
# Move to openbox config, https://wiki.archlinux.org/index.php/openbox 
alias goodbye='sudo systemctl poweroff'
alias restart='sudo systemctl reboot'
alias powernap='sudo systemctl suspend'
alias hibernate='sudo systemctl hibernate'
alias lockscreen='lxsession-default lock'
alias logout='lxsession-default quit'

#alias battery='upower -i `upower -e | grep battery` | grep -E "state|percentage"'
alias battery='acpi -b -i'

# Computers
# see ~/.ssh/config

# Entertainment
alias relax='cvlc -I ncurses -Z -L ~/Music/Cultura\ Profetica/M.O.T.A.'
alias music='cvlc -I ncurses -Z -L ~/Music'
alias steamx='nvidiax -p 3 -t 1 -r steam'
