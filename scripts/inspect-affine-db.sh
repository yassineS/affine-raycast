#!/usr/bin/env bash
# Inspect AFFiNE desktop app SQLite storage.db structure.
# Run on a Mac with AFFiNE desktop app installed and sqlite3 in PATH.
# Usage: ./scripts/inspect-affine-db.sh [workspace_id]

set -e
APP_SUPPORT="${HOME}/Library/Application Support"

# Try both layouts: AFFiNE (capital) with workspaces/affine-cloud|local, and @affine/electron/workspaces
find_workspace_dirs() {
  for root in "${APP_SUPPORT}/AFFiNE" "${APP_SUPPORT}/@affine/electron"; do
    if [[ ! -d "$root/workspaces" ]]; then continue; fi
    for sub in "$root/workspaces"/*/; do
      [[ -d "$sub" ]] || continue
      for ws in "$sub"*/; do
        [[ -d "$ws" ]] || continue
        if [[ -f "${ws}storage.db" ]]; then
          echo "${ws}storage.db"
        fi
      done
    done
    # Flat: workspaces/{id}/storage.db
    for ws in "$root/workspaces"/*/; do
      [[ -d "$ws" ]] || continue
      if [[ -f "${ws}storage.db" ]]; then
        echo "${ws}storage.db"
      fi
    done
  done
}

if [[ -n "$1" ]]; then
  found=""
  for root in "${APP_SUPPORT}/AFFiNE" "${APP_SUPPORT}/@affine/electron"; do
    for sub in "affine-cloud" "local" ""; do
      if [[ -n "$sub" ]]; then
        candidate="${root}/workspaces/${sub}/$1/storage.db"
      else
        candidate="${root}/workspaces/$1/storage.db"
      fi
      if [[ -f "$candidate" ]]; then
        found="$candidate"
        break 2
      fi
    done
  done
  if [[ -z "$found" ]]; then
    echo "Workspace $1 not found."
    exit 1
  fi
  DBS=("$found")
else
  DBS=($(find_workspace_dirs | sort -u))
fi

if [[ ${#DBS[@]} -eq 0 ]]; then
  echo "No AFFiNE storage.db found. Tried:"
  echo "  ${APP_SUPPORT}/AFFiNE/workspaces/affine-cloud|local/<id>/storage.db"
  echo "  ${APP_SUPPORT}/@affine/electron/workspaces/<id>/storage.db"
  exit 1
fi

for db in "${DBS[@]}"; do
  ws_id=$(basename "$(dirname "$db")")
  echo "========== $db (workspace: $ws_id) =========="
  echo ""
  echo "--- Tables ---"
  sqlite3 "$db" ".tables"
  echo ""
  echo "--- Schema (sqlite_master) ---"
  sqlite3 "$db" "SELECT type, name, sql FROM sqlite_master ORDER BY type, name;"
  echo ""
  echo "--- PRAGMA table_info for each table ---"
  for table in $(sqlite3 "$db" "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"); do
    echo "  Table: $table"
    sqlite3 "$db" "PRAGMA table_info(\"$table\");"
    echo ""
  done
  echo "--- Sample: updates (doc_id, created_at) ---"
  sqlite3 "$db" "SELECT doc_id, created_at FROM updates LIMIT 5;"
  echo ""
  echo "--- Distinct doc_id count ---"
  sqlite3 "$db" "SELECT COUNT(DISTINCT doc_id) FROM updates;"
  echo ""
done

echo "Done. Use this output to update affine-raycast/src/affine-local-bridge.ts if needed."
