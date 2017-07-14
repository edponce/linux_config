#!/usr/bin/python3

import argparse
import subprocess


def parse_args():
    '''
    Parse command line arguments
    '''
    parser = argparse.ArgumentParser(prog='xscreen', description='Layouts for arranging windows in X')
    parser.add_argument('-l', '--layout_id', type=int, default=1,
                        dest='layout_id', help='layout identifier')
    parser.add_argument('-s', '--shift', action='store_true',
                        dest='shifted', help='shift layout to allow space for Xpad notes')
    args = parser.parse_args()

    # Validate
    if args.layout_id < 1 or args.layout_id > 4:
        print('Error: invalid layout value.')
        exit(1)

    return args


def get_active_screen_dims():
    '''
    Get screen dimensions and offsets based on active window
    '''
    screen_dims = []

    # Get active window and dimensions
    win_id = subprocess.getoutput('xdotool getactivewindow')
    desktop = int(subprocess.getoutput('xdotool get_desktop_for_window ' + win_id)) 
    str_win_dims = subprocess.getoutput('. ~/bin/custom_utils; window_position ' + win_id + '; echo "${win_dims[@]} ${win_offs[@]}"').split()
    win_dims = [int(x) for x in str_win_dims]

    # Consider active window is in lower-left screen
    str_screen_dims = subprocess.getoutput('. ~/bin/custom_utils; screen_position 1; echo "${screen_dims[@]} ${screen_offs[@]}"').split()
    screen_dims = [int(x) for x in str_screen_dims]

    # Check for multiple screens
    num_monitors = int(subprocess.getoutput("xrandr --listactivemonitors | awk -F':' '/Monitors/ { print $2 }'"))
    if num_monitors > 1:
        win_x = win_dims[0] + win_dims[2]
        win_y = win_dims[1] + win_dims[3]

        # Check if active window is in second screen
        if win_x > screen_dims[0] or win_y > screen_dims[1]:
            str_screen_dims = subprocess.getoutput('. ~/bin/custom_utils; screen_position 2; echo "${screen_dims[@]} ${screen_offs[@]}"').split()
            screen_dims = [int(x) for x in str_screen_dims]
    
    return desktop, screen_dims


def get_windows_list():
    '''
    Get lists of visible window IDs and names
    '''
    win_ids = []
    win_names = []
    
    # Get list of visible windows
    win_list = subprocess.getoutput('wmctrl -l').split('\n')
    for win_line in win_list:
        wline = win_line.split()
        win_id = wline[0]

        # Ignore specified windows
        win_name = subprocess.getoutput("xprop -id " + win_id + " | awk -F'=' '/_OB_APP_NAME/ { print $2 }' | sed 's/\"//g'").strip()
        if not win_name in ['pcmanfm', 'xpad']:
            win_ids.append(win_id)
            win_names.append(win_name)

    return win_ids, win_names


def set_layout(layout_id, shifted, desktop, screen_dims, win_ids, win_names):
    '''
    Arrange windows based on layout ID
    '''
    '''
    1 -> Dual vertical split (default)
    2 -> Dual horizontal split
    3 -> Triple vertical split
    4 -> Four-way split
    5 -> Dual vertical split with shift
    6 -> Dual horizontal split with shift
    7 -> Triple vertical split with shift
    8 -> Four-way split with shift
    '''
    print(layout_id)
    print(shifted)
    print(desktop)
    print(screen_dims)
    print(win_ids)
    print(win_names)
    num_wins = len(win_ids)

    # Arrange preferred windows first
    win_pref = ['lxterminal', 'Navigator']

    '''
    if layout_id == 1:
        print(layout_id)
    elif layout_id == 2:
        print(layout_id)
    elif layout_id == 3:
        print(layout_id)
    elif layout_id == 4:
        print(layout_id)
    '''

    # Arrange window
    win_id = win_ids[0]
    win_offx = 0
    win_offy = 0
    win_x = 1920 # based on maximize
    win_y = 1066 # based on maximize
    #print('wmctrl -i -r ' + win_id + ' -e 0,' + str(win_offx) + ',' + str(win_offy) + ',' + str(win_x) + ',' + str(win_y))
    subprocess.getoutput('wmctrl -i -r ' + win_id + ' -e 0,' + str(win_offx) + ',' + str(win_offy) + ',' + str(win_x) + ',' + str(win_y))


if __name__ == '__main__':
    args = parse_args()
    desktop, screen_dims = get_active_screen_dims()
    win_ids, win_names = get_windows_list()
    set_layout(args.layout_id, args.shifted, desktop, screen_dims, win_ids, win_names)

