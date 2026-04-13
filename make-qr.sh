#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <url> [output.png] [module_size]"
  echo "Example: $0 'http://garage-config.local' garage-qr.png 10"
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

url="$1"

# ensure QR directory exists
mkdir -p QR

# default output filename (sanitized) placed inside QR/
default_name=$(echo "$url" | sed -E 's#https?://##; s/[^A-Za-z0-9._-]/_/g').png
out="QR/${2:-$default_name}"
module_size="${3:-10}"

# check qrencode
if ! command -v qrencode >/dev/null 2>&1; then
  echo "Error: qrencode not found. Install it (e.g. 'sudo apt install qrencode' or 'brew install qrencode')."
  exit 2
fi

# run
qrencode -o "$out" -s "$module_size" "$url"
echo "QR saved to: $out (module size: $module_size)"

# Try to open the generated file with the system default viewer
open_cmd=""

if command -v xdg-open >/dev/null 2>&1; then
  open_cmd="xdg-open"
elif command -v open >/dev/null 2>&1; then
  open_cmd="open"
elif command -v gnome-open >/dev/null 2>&1; then
  open_cmd="gnome-open"
elif command -v kde-open >/dev/null 2>&1; then
  open_cmd="kde-open"
elif command -v x-www-browser >/dev/null 2>&1; then
  open_cmd="x-www-browser"
elif command -v cmd.exe >/dev/null 2>&1; then
  # Windows (Git Bash / WSL)
  open_cmd="cmd.exe /C start \"\""
fi

if [ -n "$open_cmd" ]; then
  if [ "$open_cmd" = "cmd.exe /C start \"\"" ]; then
    # If on WSL, convert path to Windows form if wslpath is available
    if command -v wslpath >/dev/null 2>&1; then
      winpath=$(wslpath -w "$out")
      cmd.exe /C start "" "$winpath" >/dev/null 2>&1 || true
    else
      cmd.exe /C start "" "$out" >/dev/null 2>&1 || true
    fi
  else
    # run in background so the script exits immediately
    "$open_cmd" "$out" >/dev/null 2>&1 &
  fi
  echo "Opened: $out"
else
  echo "No suitable opener command found. Open the file manually: $out"
fi
