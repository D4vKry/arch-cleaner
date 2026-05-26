# Arch Cleaner

A lightweight and automated Bash script to optimize and free up disk space on Arch Linux systems, designed for storage-constrained environments like virtual machines, small drives or pentesting distributions.


<img width="616" height="323" alt="imaxe" src="https://github.com/user-attachments/assets/3319021e-6198-43e3-babc-c4844b5b0b77" />


## Features

Arch Cleaner dynamically calculates the recovered disk space and features an error-handling and privilege-escalation safety system.

*   **Pacman Cache Cleanup:** Safely retains only the last 3 versions of installed packages using `paccache` by default.
*   **Log Maintenance:** Silently purges historical `systemd` journal logs (`journalctl`), retaining only the last 7 days.
*   **Orphan Removal:** Detects and removes residual dependencies that are no longer required by any installed program.


## Available Options

The script supports the following command-line arguments:

| Short Option | Long Option | Description |
| :--- | :--- | :--- |
| `-h` | `--help` | Shows this help menu with options and examples. |
| `-v` | `--verbose` | Verbose mode. Shows detailed command output in the console. |
| `-f` | `--force-all` | Forces a complete wipe of the pacman cache using `pacman -Scc` instead of the safe `paccache` default. |
| `-a` | `--aur` | Includes `yay` and `paru` cache cleanup in the Home directory. |
| `-u` | `--user` | Includes user thumbnail cache removal in the Home directory. |


## Installation and Usage

### Prerequisites
The script requires superuser privileges for system-level tasks. However, it should be executed using `sudo` rather than directly as the root user so it can correctly identify your actual user's Home path. Also you need paccache for the default options, you can install it via pacman
```bash
sudo pacman -S pacman-contrib
```
If you don't want to install paccache, you can use the script with -f option (not recommended).

### Clone and Execute
```bash
git clone https://github.com/D4vKry/arch-cleaner.git
cd arch-cleaner
chmod +x cleaner.sh
sudo ./cleaner.sh
```

Any issues, bugs, or Pull Requests are welcome in the repository's issues section.

Project protected by MIT License, free to use.
