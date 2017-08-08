#!/usr/bin/python3

import sys
import os
import argparse
from argparse import RawTextHelpFormatter
import subprocess


def parse_args():
    '''
    Parse command line arguments
    '''
    parser = argparse.ArgumentParser(prog='xscreen', description='Layouts for arranging windows in X', formatter_class=RawTextHelpFormatter)
    parser.add_argument('-l', '--layout_id', type=int, default=1,
                        dest='layout_id', help='layout identifier, default=1')
    parser.add_argument('-s', '--screen_id', type=int, default=0,
                        dest='screen_id', help='screen/monitor identifier\n'
                                               '*0 -> screen with active window\n'
                                               ' 1 -> lower-left screen\n'
                                               ' 2 -> second screen')
    parser.add_argument('-w', '--win_select', type=int, default=0,
                        dest='win_select', help='window select identifier\n'
                                                '*0 -> visible windows in active screen/monitor\n'
                                                ' 1 -> visible windows in active desktop')
    args = parser.parse_args()

    # Validate
    if args.layout_id < 0 or args.layout_id > 9:
        print('Error: invalid layout value.')
        sys.exit(os.EX_USAGE)
    if args.screen_id < 0 or args.screen_id > 2:
        print('Error: invalid screen value.')
        sys.exit(os.EX_USAGE)
    if args.win_select < 0 or args.win_select > 1:
        print('Error: invalid window select value.')
        sys.exit(os.EX_USAGE)

    return args


def get_active_screen_dims(screen_id = 0):
    '''
    Get screen dimensions and offsets based on active window
    '''
    # Get active desktop
    desktop = int(subprocess.getoutput('xdotool get_desktop'))

    # Get active window as int and convert to hex
    win_id_active_int = int(subprocess.getoutput('xdotool getactivewindow'))
    win_id_active = '{0:#0{1}x}'.format(win_id_active_int, 10)

    # Get dimensions and offsets of lower-left screen
    str_screen_dims = subprocess.getoutput('. ~/bin/custom_utils; screen_position 1; echo "${screen_dims[@]} ${screen_offs[@]}"').split()
    screen_all_dims = [int(x) for x in str_screen_dims]

    # Use screen with active window
    if screen_id == 0:

        # Check for multiple screens
        num_monitors = int(subprocess.getoutput("xrandr --listactivemonitors | awk -F':' '/Monitors/ { print $2 }'"))
        if num_monitors > 1:
            # Get active window dimensions
            str_win_dims = subprocess.getoutput('. ~/bin/custom_utils; window_position ' + win_id_active + '; echo "${win_dims[@]} ${win_offs[@]}"').split()
            win_dims = [int(x) for x in str_win_dims]
            win_x = win_dims[0] + win_dims[2]
            win_y = win_dims[1] + win_dims[3]

            # Check if active window is not in lower-left screen
            if win_x > screen_all_dims[0] or win_y > screen_all_dims[1]:
                str_screen_dims = subprocess.getoutput('. ~/bin/custom_utils; screen_position 2; echo "${screen_dims[@]} ${screen_offs[@]}"').split()
                screen_all_dims = [int(x) for x in str_screen_dims]

    # Use second screen
    elif screen_id == 2:
        # Check for multiple screens
        num_monitors = int(subprocess.getoutput("xrandr --listactivemonitors | awk -F':' '/Monitors/ { print $2 }'"))
        if num_monitors > 1:
            str_screen_dims = subprocess.getoutput('. ~/bin/custom_utils; screen_position 2; echo "${screen_dims[@]} ${screen_offs[@]}"').split()
            screen_all_dims = [int(x) for x in str_screen_dims]
   
    # Screen dimensions and offsets
    screen_dims = screen_all_dims[0:2]
    screen_offs = screen_all_dims[2:4]

    return desktop, win_id_active, screen_dims, screen_offs


def get_windows_list(desktop = 1, win_select = 0, screen_dims = [], screen_offs = []):
    '''
    Get lists of visible window IDs and names
    '''
    # Window queues
    win_ids = []
    win_names = []
    
    # Check if screens are available
    if not screen_dims or not screen_offs:
        print('Warning: incomplete screen/monitor properties.')
        return win_ids, win_names

    # Get list of visible windows
    win_list = subprocess.getoutput('wmctrl -l -G').split('\n')
    for wline in win_list:
        win_line = wline.split()
        win_id = win_line[0]
        win_desk = int(win_line[1])
        win_off = [int(win_line[2]), int(win_line[3])]
        win_dim = [int(win_line[4]), int(win_line[5])]

        # Skip windows in other desktops or minimized
        if win_desk != desktop or not subprocess.getoutput("xwininfo -id " + win_id + " | grep 'IsViewable'"):
            continue

        if win_select == 0:
            # Skip windows not in active screen/monitor
            if win_off[0] >= screen_offs[0] + screen_dims[0] or win_off[0] + win_dim[0] <= screen_offs[0] or win_off[1] >= screen_offs[1] + screen_dims[1] or win_off[1] + win_dim[1] <= screen_offs[1]:
                continue

        # Ignore specified windows
        win_name = subprocess.getoutput("xprop -id " + win_id + " | awk -F'=' '/_OB_APP_NAME/ { print $2 }' | tr -d ' \"'").strip()
        if not win_name in ['pcmanfm', 'xpad', 'galculator']:
            win_ids.insert(0, win_id)
            win_names.insert(0, win_name)

    return win_ids, win_names


def create_layout(layout_id = 1, screen_dims = [], screen_offs = []):
    '''
    Create layout based on screen dimensions
    
    '''
    # Window layout coordinates (integers), [[x0,y0],[x1,y1],...]
    win_dims = []
    win_offs = []

    # Check if screens are available
    if not screen_dims or not screen_offs:
        print('Warning: incomplete screen/monitor properties.')
        return win_dims, win_offs

    # Do not consider taskbar space
    screen_dims[1] -= 14

    if layout_id == 0:
        # h2v1 -> 3 windows
        wx = int(screen_dims[0] / 2)
        wy = int(screen_dims[1] / 2)

        for j in range(0,2):
            win_dims.insert(0, [wx, wy])
            win_offs.insert(0, [0, j*wy])
        win_dims.insert(0, [wx, screen_dims[1]])
        win_offs.insert(0, [wx, 0])

    elif layout_id == 1:
        # v1h2 -> 3 windows
        wx = int(screen_dims[0] / 2)
        wy = int(screen_dims[1] / 2)

        win_dims.insert(0, [wx, screen_dims[1]])
        win_offs.insert(0, [0, 0])
        for j in range(0,2):
            win_dims.insert(0, [wx, wy])
            win_offs.insert(0, [wx, j*wy])

    elif layout_id == 2:
        # v2 -> 2 windows
        wx = int(screen_dims[0] / 2)

        for i in range(0,2):
            win_dims.insert(0, [wx, screen_dims[1]])
            win_offs.insert(0, [i*wx, 0])

    elif layout_id == 3:
        # v3 -> 3 windows
        wx = int(screen_dims[0] / 3);

        for i in range(0,3):
            win_dims.insert(0, [wx, screen_dims[1]])
            win_offs.insert(0, [i*wx, 0])

    elif layout_id == 4:
        # h2v2 -> 4 windows
        wx = int(screen_dims[0] / 2)
        wy = int(screen_dims[1] / 2)

        for i in range(0,2):
            for j in range(0,2):
                win_dims.insert(0, [wx, wy])
                win_offs.insert(0, [i*wx, j*wy])

    elif layout_id == 5:
        # h2 -> 2 windows
        wy = int(screen_dims[1] / 2)

        for i in range(0,2):
            win_dims.insert(0, [screen_dims[0], wy])
            win_offs.insert(0, [0, i*wy])

    elif layout_id == 6:
        # h2v3 -> 6 windows
        wx = int(screen_dims[0] / 3)
        wy = int(screen_dims[1] / 2)

        for i in range(0,3):
            for j in range(0,2):
                win_dims.insert(0, [wx, wy])
                win_offs.insert(0, [i*wx, j*wy])

    elif layout_id == 7:
        # h3 -> 3 windows
        wy = int(screen_dims[1] / 3)

        for i in range(0,3):
            win_dims.insert(0, [screen_dims[0], wy])
            win_offs.insert(0, [0, i*wy])

    elif layout_id == 8:
        # h4v4 -> 8 windows
        wx = int(screen_dims[0] / 4)
        wy = int(screen_dims[1] / 2)

        for i in range(0,4):
            for j in range(0,2):
                win_dims.insert(0, [wx, wy])
                win_offs.insert(0, [i*wx, j*wy])

    elif layout_id == 9:
        # h1v2 -> 3 windows
        wx = int(screen_dims[0] / 2)
        wy = int(screen_dims[1] / 2)

        win_dims.insert(0, [screen_dims[0], wy])
        win_offs.insert(0, [0, 0])
        for i in range(0,2):
            win_dims.insert(0, [wx, wy])
            win_offs.insert(0, [i*wx, wy])

    # Add screen offsets to window offsets
    for wi in range(0, len(win_dims)):
        win_offs[wi][0] += screen_offs[0]
        win_offs[wi][1] += screen_offs[1]

    return win_dims, win_offs


def set_layout(win_id_active = '', win_ids = [], win_names = [], win_dims = [], win_offs = []):
    '''
    Arrange windows based on layout
    '''
    # Check if windows are available 
    if not win_ids or not win_names or not win_dims or not win_offs:
        print('Warning: incomplete windows properties for layout.')
        return 0

    # Create dictionary where keys -> win_names, values -> win_ids
    win_dict = {}
    num_wins = len(win_ids)
    for wi in range(0, num_wins):
        win_name = win_names[wi]
        win_id = win_ids[wi]
        if win_name in  win_dict.keys():
            win_dict[win_name] += [win_id]
        else:
            win_dict[win_name] = [win_id]

    # LIFO priority queue for arrangement of windows
    if win_id_active in win_dict.values():
        win_name_active = list(win_dict.keys())[list(win_dict.values()).index([win_id_active])]
        win_priority = ['libreoffice', 'gedit', 'evince', win_name_active, 'lxterminal']
    else:
        #win_priority = ['Navigator', 'libreoffice', 'gedit', 'evince', 'lxterminal']
        win_priority = ['libreoffice', 'gedit', 'evince', 'lxterminal']

    # Process all windows
    max_wins = len(win_dims)
    while win_dict:

        # Handle windows with priority
        if win_priority:
            wprior = win_priority.pop()
            if wprior in win_dict.keys():
                wids = win_dict.pop(wprior)
                win_name = wprior
            else:
                continue
        else:
            witem = win_dict.popitem()
            win_name = witem[0]
            wids = witem[1]

        # Process current set of windows
        while wids and win_dims and win_offs:
            win_id = wids.pop()
            win_grav = 0
            win_dim = win_dims.pop()
            win_off = win_offs.pop()

            # Special cases (e.g., decorated vs. undecorated)
            if win_name in ['lxterminal']:
                win_dim[1] += 2
            else:
                if not win_name in ['Navigator','evince', 'gedit', 'sun-awt-X11-XFramePeer']:
                    win_off[1] += 26
                if not win_name in ['gedit']:
                    if win_dim[1] > 28: win_dim[1] -= 28
                if win_dim[0] > 2: win_dim[0] -= 2

            # Activate window and arrange
            subprocess.getoutput('xdotool windowactivate {}'.format(win_id))
            subprocess.getoutput('wmctrl -i -r {} -b remove,maximized_vert,maximized_horz'.format(win_id))
            subprocess.getoutput('wmctrl -i -r {} -b remove,fullscreen'.format(win_id))
            subprocess.getoutput('wmctrl -i -r {} -e {},{},{},{},{}'.format(win_id, win_grav, win_off[0], win_off[1], win_dim[0], win_dim[1]))

    # Activate window
    subprocess.getoutput('xdotool windowactivate {}'.format(win_id_active))

    return 0


if __name__ == '__main__':
    args = parse_args()
    desktop, win_id_active, screen_dims, screen_offs = get_active_screen_dims(args.screen_id)
    win_ids, win_names = get_windows_list(desktop, args.win_select, screen_dims, screen_offs)
    win_dims, win_offs = create_layout(args.layout_id, screen_dims, screen_offs)
    set_layout(win_id_active, win_ids, win_names, win_dims, win_offs)
    sys.exit(os.EX_OK)

