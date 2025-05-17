#!/usr/bin/env bash
# env_report.sh - Generate a comprehensive environment report.

set -euo pipefail

printf 'Environment Report generated on %s\n\n' "$(date)"

# ----- System Information -----
printf 'System Information:\n'
printf 'Hostname: %s\n' "$(hostname)"
printf 'Architecture: %s\n' "$(uname -m)"
printf 'Kernel: %s\n' "$(uname -r)"
printf 'Uptime: %s\n' "$(uptime -p 2>/dev/null || true)"

if [ -f /etc/os-release ]; then
    echo "OS Release:"; cat /etc/os-release
fi

# CPU and Memory
printf '\nCPU Information:\n'
if command -v lscpu >/dev/null 2>&1; then
    lscpu
else
    head -n 20 /proc/cpuinfo
fi

printf '\nMemory Information:\n'
if command -v free >/dev/null 2>&1; then
    free -h
else
    head -n 5 /proc/meminfo
fi

printf '\nDisk Usage:\n'
df -h

# ----- Environment Variables -----
printf '\nEnvironment Variables:\n'
env | sort

# ----- Common Tools -----
check_cmd() {
    local tool=$1
    if command -v "$tool" >/dev/null 2>&1; then
        printf '\n%s found at %s\n' "$tool" "$(command -v "$tool")"
        "$tool" --version 2>/dev/null | head -n 1 || \
        "$tool" -version 2>/dev/null | head -n 1 || \
        "$tool" version 2>/dev/null | head -n 1 || true
    else
        printf '\n%s not found\n' "$tool"
    fi
}

printf '\nChecking common tools:\n'
for t in go python3 python node npm gcc g++ make git docker java javac perl ruby rustc cargo pip3 pip; do
    check_cmd "$t"
done

# ----- Package Managers -----
printf '\nPackage Manager Information:\n'
if command -v apt >/dev/null 2>&1; then
    echo "apt found at $(command -v apt)"
    echo "Sample installed packages:"; apt list --installed 2>/dev/null | head -n 10
elif command -v dnf >/dev/null 2>&1; then
    echo "dnf found at $(command -v dnf)"
    echo "Sample installed packages:"; dnf list installed 2>/dev/null | head -n 10
elif command -v yum >/dev/null 2>&1; then
    echo "yum found at $(command -v yum)"
    echo "Sample installed packages:"; yum list installed 2>/dev/null | head -n 10
elif command -v pacman >/dev/null 2>&1; then
    echo "pacman found at $(command -v pacman)"
    echo "Sample installed packages:"; pacman -Q 2>/dev/null | head -n 10
elif command -v apk >/dev/null 2>&1; then
    echo "apk found at $(command -v apk)"
    echo "Sample installed packages:"; apk info 2>/dev/null | head -n 10
elif command -v brew >/dev/null 2>&1; then
    echo "brew found at $(command -v brew)"
    echo "Sample installed packages:"; brew list --versions 2>/dev/null | head -n 10
elif command -v rpm >/dev/null 2>&1; then
    echo "rpm found at $(command -v rpm)"
    echo "Sample installed packages:"; rpm -qa | head -n 10
elif command -v dpkg >/dev/null 2>&1; then
    echo "dpkg found at $(command -v dpkg)"
    echo "Sample installed packages:"; dpkg -l | head -n 10
else
    echo "No known package manager detected"
fi

