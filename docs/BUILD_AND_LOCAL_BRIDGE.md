# Build output and local bridge inspection

## Raycast extension build

- **Development (live reload):**  
  `cd affine-raycast && npm run dev`  
  This runs `ray develop`. Raycast loads the extension **from the project directory** (the `affine-raycast` folder). No separate “build link” — the dev server uses the repo as the extension source.

- **Production build:**  
  `cd affine-raycast && npm run build`  
  This runs `ray build -e dist`. The **build output** is written to:
  - **`affine-raycast/dist/`** — the `-e dist` flag makes the CLI write the built extension into a `dist` folder inside the project.

  To install that build into Raycast’s extensions directory (optional):
  - Copy or symlink the contents of `affine-raycast/dist/` into Raycast’s extension folder (e.g. on macOS: `~/.config/raycast/extensions/affine-raycast/`), or
  - Use Raycast’s “Import Extension” and point it at the `affine-raycast` project folder; for development, `npm run dev` is enough.

**Summary:** The “build link” for the extension is the **`affine-raycast`** directory when using `npm run dev`, and **`affine-raycast/dist/`** when using `npm run build`.

---

## Inspecting AFFiNE desktop app DB (for local search fix)

The local bridge reads `storage.db` per workspace. If search or doc list is empty, the schema may differ from what we guess. To inspect the real structure on your machine:

1. **Using the script (macOS, AFFiNE desktop installed):**
   ```bash
   chmod +x scripts/inspect-affine-db.sh
   ./scripts/inspect-affine-db.sh
   ```
   To inspect a specific workspace:
   ```bash
   ./scripts/inspect-affine-db.sh '<workspace_id>'
   ```
   Workspace IDs are the directory names under:
   `~/Library/Application Support/@affine/electron/workspaces/`.

2. **Using sqlite3 manually:**
   ```bash
   AFFINE_WS="$HOME/Library/Application Support/@affine/electron/workspaces"
   ls "$AFFINE_WS"                                    # list workspace IDs
   sqlite3 "$AFFINE_WS/<workspace_id>/storage.db" ".tables"
   sqlite3 "$AFFINE_WS/<workspace_id>/storage.db" ".schema"
   sqlite3 "$AFFINE_WS/<workspace_id>/storage.db" "PRAGMA table_info('<table_name>');"
   ```

3. **Use the output** to update `affine-raycast/src/affine-local-bridge.ts`: in `tryGetDocsFromTable`, add handling for the real table and column names (doc id, title, dates) you see in the schema.
