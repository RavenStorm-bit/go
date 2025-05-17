#!/usr/bin/env bash
# env_report.sh - Generate a report of the current environment and installed tools.

set -e

printf 'Environment Report generated on %s\n\n' "$(date)"

# Basic system information
printf 'Hostname: %s\n' "$(hostname)"
printf 'Kernel: %s\n' "$(uname -a)"
printf 'Architecture: %s\n' "$(uname -m)"
printf 'User: %s\n' "$(whoami)"
printf 'Home: %s\n' "$HOME"
printf 'Shell: %s\n' "$SHELL"
printf 'Current directory: %s\n\n' "$(pwd)"

printf 'Environment variables:\n'
env | sort

# Helper to check existence and version of commands
check_cmd() {
    cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        path=$(command -v "$cmd")
        printf '\n%s found at %s\n' "$cmd" "$path"
        if "$cmd" --version >/dev/null 2>&1; then
            "$cmd" --version | head -n 1
        elif "$cmd" -version >/dev/null 2>&1; then
            "$cmd" -version | head -n 1
        else
            "$cmd" version 2>/dev/null | head -n 1 || true
        fi
    else
        printf '\n%s not found\n' "$cmd"
    fi
}

printf '\nChecking common tools:\n'
for tool in go python3 python node npm gcc g++ make git docker java javac perl ruby rustc cargo; do
    check_cmd "$tool"
done

printf '\nPackage manager information:\n'
if command -v apt >/dev/null 2>&1; then
    echo "apt found at $(command -v apt)"
    echo "Sample installed packages:"; apt list --installed 2>/dev/null | head -n 10
elif command -v dpkg >/dev/null 2>&1; then
    echo "dpkg found at $(command -v dpkg)"
    echo "Sample installed packages:"; dpkg -l | head -n 10
elif command -v yum >/dev/null 2>&1; then
    echo "yum found at $(command -v yum)"
    echo "Sample installed packages:"; yum list installed 2>/dev/null | head -n 10
elif command -v apk >/dev/null 2>&1; then
    echo "apk found at $(command -v apk)"
    echo "Sample installed packages:"; apk info 2>/dev/null | head -n 10
else
    echo "No known package manager detected"
fi
