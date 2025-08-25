# User Management & Backup Script (Linux)

A portable Bash script that provides **user & group management** utility with a friendly CLI.

> Script file: `user_mgmt_backup.sh`

---

## ✨ Features
- **Users**: add, delete (optionally remove home), and modify shell
- **Groups**: create, delete, add user to group
- **CLI help**: clear, self-documented usage (`-h`/`--help`)
- **Safety**: checks for root privileges; input validation & existence checks
- **Portability**: relies only on core utilities (`useradd`, `usermod`, `groupadd`, etc.)

---

## ✅ Requirements
- Linux distribution (Debian/Ubuntu, RHEL/CentOS/Alma/Rocky, Fedora, openSUSE, etc.)
- Bash 4+ (default on most distros)
- Utilities: `useradd`, `userdel`, `usermod`, `groupadd`, `groupdel`, `getent`,
- Root privileges (run with `sudo` or as `root`)

---

## 📦 Installation
```bash
# 1) Save the script
curl -o user_mgmt.sh <paste-raw-url-or-place-locally>

# 2) Make it executable
chmod +x user_mgmt.sh

# 3) (Recommended) Place it in a directory on your PATH
sudo mv user_mgmt.sh /usr/local/bin/user_mgmt
```
> After step 3 you can run it as `user_mgmt` from anywhere.

---

## 🧭 Usage (CLI)
Run with `sudo`:
```bash
sudo ./user_mgmt.sh <command> [args...]

```

### Commands
| Command | Description | Syntax |
|---|---|---|
| `adduser` | Create a new user with optional shell and home | `adduser <username> [shell] [home_dir]` |
| `deluser` | Delete a user (prompts to remove home) | `deluser <username>` |
| `moduser` | Change a user's login shell | `moduser <username> <new_shell>` |
| `addgroup` | Create a new group | `addgroup <groupname>` |
| `delgroup` | Delete a group | `delgroup <groupname>` |
| `user2grp` | Add user to supplementary group | `user2grp <username> <groupname>` |
| `-h, --help` | Show help/usage | `-h` or `--help` |

### Examples
```bash
# Add a user with defaults (home /home/ali, shell /bin/bash)
sudo ./user_mgmt.sh adduser ali

# Add with custom shell & home
sudo ./user_mgmt.sh adduser devops /bin/zsh /srv/devops

# Delete a user (choose whether to remove home when prompted)
sudo ./user_mgmt.sh deluser ali

# Change user shell
sudo ./user_mgmt.sh moduser ali /bin/zsh

# Group ops
sudo ./user_mgmt.sh addgroup wheel
sudo ./user_mgmt.sh user2grp ali wheel

```

---

## 🔐 Security Considerations
- **Root only:** user/group operations require elevated privileges. The script enforces this (`$EUID` check).
- **Least privilege:** prefer `sudo` over logging in as root. Limit which admins can invoke the script with sudoers policy.
- **Validation:** the script validates existence of users/groups/paths and prompts before destructive actions (home removal).

### Optional: sudoers entry (example)
```
# Allow members of admin group to run the tool without password
%admin ALL=(root) NOPASSWD: /usr/local/bin/user_mgmt_backup
```
> Adjust group name/path for your environment. Review with your security policy.

---

## 🚀 Performance & Portability
- Uses native system tools (`useradd`, `usermod`, etc.) → fast and reliable
- No distro-specific flags are used; works across major distros
- On systems using BusyBox or minimal containers, ensure these utilities are available

---

## 🧪 Testing Checklist
1. **User creation**: create a test user, verify with `id <user>`
2. **Modify shell**: change shell; check `/etc/passwd` or `getent passwd <user>`
3. **Group ops**: create group, add user, check `groups <user>`
4. **Delete user**: confirm prompt; verify user removal and (if chosen) home deletion
5. **Backup**: run backup of a small directory; verify archive exists and can be listed: `tar -tzf <file>`
6. **Error paths**: try creating an existing user/group, or backing up a missing dir → script should respond clearly without crashing

---

## 🐞 Troubleshooting
- `This script must be run as root` → use `sudo`.
- `useradd: command not found` → install core user management tools (`passwd`/`shadow` packages vary by distro).
- Non‑interactive deletion prompt in automation → wrap `deluser` with `yes` or modify script to accept `--remove-home` (see next section).

---

## 🔧 Optional Enhancements
- `--remove-home` flag for non-interactive deletions
- `--list-users` / `--list-groups` discovery commands

---

## 📜 Script Source (for convenience)
> If you haven’t saved it yet, copy to `user_mgmt_backup.sh` and make executable.

```bash
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
```

---

## 🧾 License
```
MIT License
Copyright (c) 2025 Ali Fareed

Permission is hereby granted, free of charge, to any person obtaining a copy
```

---

## 🤝 Contributing
1. Fork the repo
2. Create a feature branch
3. Add tests where practical (bash bats, shellcheck)

---

## 📣 Notes
- If your distro uses `adduser` wrapper instead of `useradd`, keep this script as‑is; it calls `useradd`/`usermod` which are universally available on standard Linux.
