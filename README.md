# Arch Cleaner

A lightweight and automated Bash script to optimize and free up disk space on Arch Linux systems, designed for storage-constrained environments like virtual machines ,small drives or pentesting distros.

---

## Features

Arch Cleaner dynamically calculates the recovered disk space and features an error-handling and privilege-escalation safety system.

*   **Pacman Cache Cleanup:** Safely clears the downloaded package buffer.
*   **Log Maintenance:** Silently purges historical `systemd` journal logs (`journalctl`), retaining only the last 7 days.
*   **Orphan Removal:** Detects and removes residual dependencies that are no longer required by any installed program.

---

## Available Options

The script supports the following command-line arguments:

| Short Option | Long Option | Description |
| :--- | :--- | :--- |
| `-h` | `--help` | Shows this help menu with options and examples. |
| `-v` | `--verbose` | Verbose mode. Shows detailed command output in the console. |
| `-p` | `--paccache` | Uses the `paccache -r` utility instead of completely wiping with `pacman -Scc`. |
| `-a` | `--aur` | Includes `yay` and `paru` cache cleanup in the Home directory. |
| `-u` | `--user` | Includes user thumbnail cache removal in the Home directory. |

---

## Installation and Usage

### Prerequisites
The script requires superuser privileges for system-level tasks. However, it should be executed using `sudo` rather than directly as the root user so it can correctly identify your actual user's Home path.

### Clone and Execute
```bash
# Clone the repository
git clone [https://github.com/D4vKry/arch-cleaner.git](https://github.com/D4vKry/arch-cleaner.git)
cd arch-cleaner
chmod +x cleaner.sh
sudo ./cleaner.sh
```

Any issues, bugs, or Pull Requests are welcome in the repository's issues section.
