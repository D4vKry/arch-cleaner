#!/bin/bash
# automatic cleaner cache an logs in arch

VERBOSE=0
USE_PACCACHE=0
USE_AUR=0
USE_USER=0

# options
for arg in "$@"; do
    case $arg in
        -h|--help)
            echo "Usage: ./cleaner.sh [options]"
            echo ""
            echo "Options:"
            echo "  -h, --help       Show this help menu"
            echo "  -v, --verbose    Show detailed command output"
            echo "  -p, --paccache   Use paccache instead of pacman -Scc"
            echo "  -a, --aur        Clean yay and paru cache"
            echo "  -u, --user       Clean user thumbnails cache"
            echo ""
            echo "Examples:"
            echo "  sudo ./cleaner.sh -va"
            echo "  sudo ./cleaner.sh --paccache --user"
            exit 0
            ;;
        --verbose) VERBOSE=1 ;;
        --paccache) USE_PACCACHE=1 ;;
        --aur) USE_AUR=1 ;;
        --user) USE_USER=1 ;;
        --*)
            echo "[-] Option $arg not found."
            exit 1
            ;;
        -*)
            flags="${arg#\-}"
            for (( i=0; i<${#flags}; i++ )); do
                char="${flags:$i:1}"
                case $char in
                    v) VERBOSE=1 ;;
                    p) USE_PACCACHE=1 ;;
                    a) USE_AUR=1 ;;
                    u) USE_USER=1 ;;
                    h)
                        echo "Usage: ./cleaner.sh [options]"
                        echo ""
                        echo "Options:"
                        echo "  -h, --help       Show this help menu"
                        echo "  -v, --verbose    Show detailed command output"
                        echo "  -p, --paccache   Use paccache instead of pacman -Scc"
                        echo "  -a, --aur        Clean yay and paru cache"
                        echo "  -u, --user       Clean user thumbnails cache"
                        echo ""
                        echo "Examples:"
                        echo "  sudo ./cleaner.sh -va"
                        exit 0
                        ;;
                    *)
                        echo "[-] Option -$char not found."
                        exit 1
                        ;;
                esac
            done
            ;;
        *)
            echo "[-] Argument $arg not found."
            exit 1
            ;;
    esac
done

if [ "$(whoami)" != "root" ];then
    echo "[-] Please run the script as root"
    exit 1
fi

cat << "EOF"


      ___________
     /=//==//=/  \
    |=||==||=|    |
    |=||==||=|~-, |
    |=||==||=|^.`;|
     \=\\==\\=\`=.:
      `"""""""`^-,`.
              `.~,'
            ',~^:,
            `.^;`.
             ^-.~=;.
               `.^.:`.

 --- ARCH CLEANER by @D4vKry :)---
 --- Any issue or PR report it in the repository ---
 
EOF
USED_BEFORE=$(df -m / | awk 'NR==2 {print $3}')

echo "[*] Starting cleaner..."

# 1.- removing caché from pacman
echo "[*] Removing pacman cache..."
if [ "$USE_PACCACHE" -eq 1 ]; then
    if command -v paccache >/dev/null 2>&1; then
        if [ "$VERBOSE" -eq 1 ]; then
            paccache -r
        else
            paccache -r > /dev/null 2>&1
        fi
    else
        echo "[-] paccache command not found, falling back to pacman..."
        if [ "$VERBOSE" -eq 1 ]; then
            pacman -Scc --noconfirm
        else
            pacman -Scc --noconfirm > /dev/null 2>&1
        fi
    fi
else
    if [ "$VERBOSE" -eq 1 ]; then
        pacman -Scc --noconfirm
    else
        pacman -Scc --noconfirm > /dev/null 2>&1
    fi
fi

# 2.- cleaning systemd logs, leaving only those from the last week
echo "[*] Cleaning systemd logs..."
if [ "$VERBOSE" -eq 1 ]; then
    journalctl --vacuum-time=7d
else
    journalctl --vacuum-time=7d > /dev/null 2>&1
fi

# 3.- removing orphan packages
echo "[*] Looking for orphan packages..."
ORPHANS=$(pacman -Qtdq 2>/dev/null) 

if [ -n "$ORPHANS" ]; then
    echo "[+] Founded, removing it..."
    if [ "$VERBOSE" -eq 1 ]; then
        pacman -Rns $ORPHANS --noconfirm
    else
        pacman -Rns $ORPHANS --noconfirm > /dev/null 2>&1
    fi
else
    echo "[-] There's no orphan packages."
fi

if [ "$USE_AUR" -eq 1 ] && [ -n "$SUDO_USER" ]; then
    echo "[*] Removing AUR cache..."
    if [ -d "/home/$SUDO_USER/.cache/yay" ]; then
        if [ "$VERBOSE" -eq 1 ]; then
            rm -rfv "/home/$SUDO_USER/.cache/yay"
        else
            rm -rf "/home/$SUDO_USER/.cache/yay"
        fi
    fi
    if [ -d "/home/$SUDO_USER/.cache/paru" ]; then
        if [ "$VERBOSE" -eq 1 ]; then
            rm -rfv "/home/$SUDO_USER/.cache/paru"
        else
            rm -rf "/home/$SUDO_USER/.cache/paru"
        fi
    fi
fi

if [ "$USE_USER" -eq 1 ] && [ -n "$SUDO_USER" ]; then
    echo "[*] Removing user thumbnails cache..."
    if [ -d "/home/$SUDO_USER/.cache/thumbnails" ]; then
        if [ "$VERBOSE" -eq 1 ]; then
            rm -rfv "/home/$SUDO_USER/.cache/thumbnails"
        else
            rm -rf "/home/$SUDO_USER/.cache/thumbnails"
        fi
    fi
fi

USED_AFTER=$(df -m / | awk 'NR==2 {print $3}')
FREED_MB=$((USED_BEFORE - USED_AFTER))

echo "[+] Cleaning finished, space freeded: ${FREED_MB} MiB."
