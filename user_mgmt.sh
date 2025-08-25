#!/bin/bash
# =====================================================
# Project: User Management and Backup Script in Linux
# Author: Ali Fareed
# =====================================================

# ----------- Helper Functions -----------------
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root. Use sudo."
        exit 1
    fi
}

usage() {
    echo "========================================"
    echo " User Management & Backup Script "
    echo "========================================"
    echo "Options:"
    echo " 1) Add User        : $0 adduser <username> [shell] [home_dir]"
    echo " 2) Delete User     : $0 deluser <username>"
    echo " 3) Modify User     : $0 moduser <username> <new_shell>"
    echo " 4) Create Group    : $0 addgroup <groupname>"
    echo " 5) Delete Group    : $0 delgroup <groupname>"
    echo " 6) Add User to Grp : $0 user2grp <username> <groupname>"
    echo " 8) Help            : $0 -h | --help"
    echo "========================================"
}

# ----------- User Management -----------------
add_user() {
    user=$1
    shell=${2:-/bin/bash}
    home=${3:-/home/$user}

    if id "$user" &>/dev/null; then
        echo "User '$user' already exists."
    else
        useradd -m -d "$home" -s "$shell" "$user"
        echo "User '$user' created with home: $home and shell: $shell"
    fi
}

del_user() {
    user=$1
    if id "$user" &>/dev/null; then
        read -p "Do you also want to remove home directory? (y/n): " choice
        if [[ $choice == "y" ]]; then
            userdel -r "$user"
            echo "User '$user' and home directory removed."
        else
            userdel "$user"
            echo "User '$user' removed."
        fi
    else
        echo "User '$user' does not exist."
    fi
}

mod_user() {
    user=$1
    new_shell=$2
    if id "$user" &>/dev/null; then
        usermod -s "$new_shell" "$user"
        echo "User '$user' shell changed to $new_shell"
    else
        echo "User '$user' does not exist."
    fi
}

# ----------- Group Management -----------------
add_group() {
    group=$1
    if getent group "$group" >/dev/null; then
        echo "Group '$group' already exists."
    else
        groupadd "$group"
        echo "Group '$group' created."
    fi
}

del_group() {
    group=$1
    if getent group "$group" >/dev/null; then
        groupdel "$group"
        echo "Group '$group' deleted."
    else
        echo "Group '$group' does not exist."
    fi
}

user_to_group() {
    user=$1
    group=$2
    if id "$user" &>/dev/null && getent group "$group" >/dev/null; then
        usermod -aG "$group" "$user"
        echo "User '$user' added to group '$group'"
    else
        echo "Either user or group does not exist."
    fi
}


# ----------- Main Logic -----------------
check_root

case $1 in
    adduser) add_user $2 $3 $4 ;;
    deluser) del_user $2 ;;
    moduser) mod_user $2 $3 ;;
    addgroup) add_group $2 ;;
    delgroup) del_group $2 ;;
    user2grp) user_to_group $2 $3 ;;
    -h|--help|"") usage ;;
    *) echo "Invalid option. Use -h for help." ;;

esac