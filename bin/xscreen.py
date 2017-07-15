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
    desktop = int(subprocess.getoutput('xdotool get_desktop')) 
    win_id = subprocess.getoutput('xdotool getactivewindow')
    str_win_dims = subprocess.getoutput('. ~/bin/custom_utils; window_position ' + win_id + '; echo "${win_dims[@]} ${win_offs[@]}"').split()
    win_dims = [int(x) for x in str_win_dims]

    # Get dimensions of lower-left screen
    str_screen_dims = subprocess.getoutput('. ~/bin/custom_utils; screen_position 1; echo "${screen_dims[@]} ${screen_offs[@]}"').split()
    screen_dims = [int(x) for x in str_screen_dims]

    # Check for multiple screens
    num_monitors = int(subprocess.getoutput("xrandr --listactivemonitors | awk -F':' '/Monitors/ { print $2 }'"))
    if num_monitors > 1:
        win_x = win_dims[0] + win_dims[2]
        win_y = win_dims[1] + win_dims[3]

        # Check if active window is not in lower-left screen 
        if win_x > screen_dims[0] or win_y > screen_dims[1]:
            str_screen_dims = subprocess.getoutput('. ~/bin/custom_utils; screen_position 2; echo "${screen_dims[@]} ${screen_offs[@]}"').split()
            screen_dims = [int(x) for x in str_screen_dims]
    
    return desktop, screen_dims


def get_windows_list(desktop):
    '''
    Get lists of visible window IDs and names
    '''
    win_ids = []
    win_names = []
    
    # Get list of visible windows
    win_list = subprocess.getoutput('wmctrl -l').split('\n')
    for wline in win_list:
        win_line = wline.split()
        win_id = win_line[0]
        win_desk = int(win_line[1])

        # Use windows in given desktop
        if win_desk == desktop:

            # Ignore specified windows
            win_name = subprocess.getoutput("xprop -id " + win_id + " | awk -F'=' '/_OB_APP_NAME/ { print $2 }' | sed 's/\"//g'").strip()
            if not win_name in ['xpad']:
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

    # If no or single window, do not do anything
    if num_wins < 2:
        print('Debug: few windows, nothing to do.')
        return

    # Create dictionary where keys -> win_names, values -> win_ids
    win_dict = dict()
    for wi in range(0, num_wins):
        win_name = win_names[wi]
        win_id = win_ids[wi]
        if win_name in  win_dict.keys():
            win_dict[win_name] += [win_id]
        else:
            win_dict[win_name] = [win_id]

    print(win_dict.keys())
    print(win_dict.values())

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

    # Priority stack for arrangement of windows [lowest to highest]
    win_priority = ['Navigator', 'lxterminal']

    while win_dict:
        if win_priority:
            wids = win_dict[win_priority.pop()]

        if not wids:
            # Process remaining windows

    # Arrange window
    win_id = win_ids[0]
    win_grav = 0


    win_offx = 0
    win_offy = 0
    win_x = 1920 # based on maximize
    win_y = 1066 # based on maximize

    cmd = 'wmctrl -i -r {} -e {},{},{},{},{}'.format(win_id, win_grav, win_offx, win_offy, win_x, win_y)
    print(cmd)
    #subprocess.getoutput(cmd)


if __name__ == '__main__':
    args = parse_args()
    desktop, screen_dims = get_active_screen_dims()
    win_ids, win_names = get_windows_list(desktop)
    set_layout(args.layout_id, args.shifted, desktop, screen_dims, win_ids, win_names)

