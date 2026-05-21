#!/bin/bash
# automatic cleaner cache an logs in arch

VERBOSE=0
FORCE_CLEAN_ALL=0
USE_AUR=0
USE_USER=0

for arg in "$@"; do
    case $arg in
        -h|--help)
            echo "Usage: ./cleaner.sh [options]"
            echo ""
            echo "Options:"
            echo "  -h, --help       Show this help menu"
            echo "  -v, --verbose    Show detailed command output"
            echo "  -f, --force-all  Force completely wipe pacman cache (pacman -Scc)"
            echo "  -a, --aur        Clean yay and paru cache"
            echo "  -u, --user       Clean user thumbnails cache"
            echo ""
            echo "Examples:"
            echo "  sudo ./cleaner.sh -va"
            echo "  sudo ./cleaner.sh --force-all --user"
            exit 0
            ;;
        --verbose) VERBOSE=1 ;;
        --force-all) FORCE_CLEAN_ALL=1 ;;
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
                    f) FORCE_CLEAN_ALL=1 ;;
                    a) USE_AUR=1 ;;
                    u) USE_USER=1 ;;
                    h)
                        echo "Usage: ./cleaner.sh [options]"
                        echo ""
                        echo "Options:"
                        echo "  -h, --help       Show this help menu"
                        echo "  -v, --verbose    Show detailed command output"
                        echo "  -f, --force-all  Force completely wipe pacman cache (pacman -Scc)"
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

 --- ARCH CLEANER by @D4vKry ---
 
EOF

HOMEDIR="/home/$SUDO_USER"
if [ -z "$SUDO_USER" ] || [ "$SUDO_USER" = "root" ]; then
    HOMEDIR="/root"
fi

USED_BEFORE=$(df -m / | awk 'NR==2 {print $3}')

echo "[*] Starting cleaner..."

echo "[*] Removing pacman cache..."
if [ "$FORCE_CLEAN_ALL" -eq 1 ]; then
    echo "[!] Warning: Completely wiping pacman cache..."
    if [ "$VERBOSE" -eq 1 ]; then
        yes | pacman -Scc
    else
        yes | pacman -Scc > /dev/null 2>&1
    fi
else
    if command -v paccache >/dev/null 2>&1; then
        if [ "$VERBOSE" -eq 1 ]; then
            paccache -r
        else
            paccache -r > /dev/null 2>&1
        fi
    else
        echo "[-] paccache command not found, skipping safe cache clean."
    fi
fi

echo "[*] Cleaning systemd logs..."
if [ "$VERBOSE" -eq 1 ]; then
    journalctl --vacuum-time=7d
else
    journalctl --vacuum-time=7d > /dev/null 2>&1
fi

echo "[*] Looking for orphan packages..."
ORPHANS=$(pacman -Qtdq 2>/dev/null) 

if [ -n "$ORPHANS" ]; then
    echo "[+] Found orphans, removing them..."
    if [ "$VERBOSE" -eq 1 ]; then
        pacman -Rns $ORPHANS --noconfirm
    else
        pacman -Rns $ORPHANS --noconfirm > /dev/null 2>&1
    fi
else
    echo "[-] There are no orphan packages."
fi

if [ "$USE_AUR" -eq 1 ] && [ "$HOMEDIR" != "/root" ]; then
    echo "[*] Removing AUR cache..."
    if [ -d "$HOMEDIR/.cache/yay" ]; then
        if [ "$VERBOSE" -eq 1 ]; then
            rm -rfv "$HOMEDIR/.cache/yay"
        else
            rm -rf "$HOMEDIR/.cache/yay"
        fi
    fi
    if [ -d "$HOMEDIR/.cache/paru" ]; then
        if [ "$VERBOSE" -eq 1 ]; then
            rm -rfv "$HOMEDIR/.cache/paru"
        else
            rm -rf "$HOMEDIR/.cache/paru"
        fi
    fi
fi

if [ "$USE_USER" -eq 1 ] && [ "$HOMEDIR" != "/root" ]; then
    echo "[*] Removing user thumbnails cache..."
    if [ -d "$HOMEDIR/.cache/thumbnails" ]; then
        if [ "$VERBOSE" -eq 1 ]; then
            rm -rfv "$HOMEDIR/.cache/thumbnails"
        else
            rm -rf "$HOMEDIR/.cache/thumbnails"
        fi
    fi
fi

USED_AFTER=$(df -m / | awk 'NR==2 {print $3}')
FREED_MB=$((USED_BEFORE - USED_AFTER))

echo "[+] Cleaning finished, space freed: ${FREED_MB} MiB."
