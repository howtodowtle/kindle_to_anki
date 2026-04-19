#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")" && pwd)
tracker="$repo_root/last_imports.txt"

usage() {
    cat <<EOF
Usage: $0 <lang> [db_path]

  lang      language code (e.g., en, ca). Must match queries/query_<lang>.sql.
  db_path   path to vocab.db. Defaults to newest vocab_dbs/*.db.

Exports words looked up since the last-import date in $tracker.
If <lang> has no entry, exports everything (since 1970-01-01).

After importing the CSV into Anki, record the date:
  ./mark_imported.sh <lang>
EOF
    exit 1
}

[ $# -ge 1 ] || usage
lang=$1
db=${2:-$(ls -t "$repo_root"/vocab_dbs/*.db 2>/dev/null | head -1 || true)}

query="$repo_root/queries/query_${lang}.sql"
today=$(date +%Y_%m_%d)
output="$repo_root/output/kindle_vocab_${lang}_dedup_${today}.csv"

[ -n "$db" ] && [ -f "$db" ] || { echo "DB not found: ${db:-<none>}" >&2; exit 1; }
[ -f "$query" ] || { echo "Query not found: $query" >&2; exit 1; }

since=$(awk -v l="$lang" '$1==l {print $2; exit}' "$tracker" 2>/dev/null || true)
since=${since:-1970-01-01}

echo "Language:  $lang"
echo "Database:  $db"
echo "Since:     $since"
echo "Output:    $output"

mkdir -p "$repo_root/output"
sed "s/{{SINCE}}/$since/g" "$query" | sqlite3 -separator "|" "$db" > "$output"

rows=$(wc -l < "$output" | tr -d ' ')
echo "Rows:      $rows"
echo
echo "After importing to Anki, run: ./mark_imported.sh $lang"
