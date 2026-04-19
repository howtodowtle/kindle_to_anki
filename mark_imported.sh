#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")" && pwd)
tracker="$repo_root/last_imports.txt"

[ $# -ge 1 ] || { echo "Usage: $0 <lang> [YYYY-MM-DD]" >&2; exit 1; }
lang=$1
date=${2:-$(date +%Y-%m-%d)}

touch "$tracker"
if grep -q "^${lang} " "$tracker"; then
    sed -i '' "s|^${lang} .*|${lang} ${date}|" "$tracker"
else
    printf '%s %s\n' "$lang" "$date" >> "$tracker"
fi
echo "Marked: $lang $date"
