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
