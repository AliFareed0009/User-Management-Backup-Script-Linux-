#!/bin/bash
# =====================================================
# Project: Backup Script in Linux
# Author: Ali Fareed
# =====================================================

# ----------- Helper Functions -----------------
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "❌ This script must be run as root. Use sudo."
        exit 1
    fi
}

usage() {
    echo "================"
    echo " Backup Script "
    echo "================"
    echo "Options:"
    echo " 1) Backup Dir      : $0 backup <directory> <backup_dest>"
    echo " 2) Help            : $0 -h | --help"
    echo "================"
}

# ----------- Backup Feature -----------------
backup_dir() {
    dir=$1
    dest=$2
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_file="$dest/backup_$(basename $dir)_$timestamp.tar.gz"

    if [[ -d "$dir" ]]; then
        tar -czf "$backup_file" "$dir"
        echo "📦 Backup of '$dir' created at: $backup_file"
    else
        echo "❌ Directory '$dir' does not exist."
    fi
}

# ----------- Main Logic -----------------
check_root

case $1 in
    backup) backup_dir $2 $3 ;;
    -h|--help|"") usage ;;
    *) echo "❌ Invalid option. Use -h for help." ;;
esac
