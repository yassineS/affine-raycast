# Local Bridge Feasibility: AFFiNE Desktop App in Raycast Extension

**Goal:** Allow the Raycast extension (and optionally MCP) to work with the AFFiNE **macOS/Windows/Linux desktop app** by reading local storage instead of calling the Cloud GraphQL API.

**Status:** Phase 1 implemented on branch `feature/local-bridge`. This doc summarizes feasibility and the phased implementation plan.

---

## 1. What the extension needs today (Cloud API)

| Capability        | Cloud (current)                         | Local bridge would need to provide                   |
|-------------------|-----------------------------------------|------------------------------------------------------|
| List workspaces   | `workspaces { id, public, createdAt }`  | Discover workspace IDs + metadata                    |
| List docs         | `workspace(id).docs`                    | Per-workspace list of doc IDs + titles               |
| Search docs       | `searchDocs(keyword, limit)`            | Keyword search across local docs                     |
| Open doc          | Browser: `baseUrl/workspace/wsId/docId` | Open in **desktop app** (e.g. URL scheme)            |
| New doc           | Open base URL                           | Open app or create flow                              |

---

## 2. AFFiNE desktop app storage (what we know)

- **Path (macOS), current app:** `~/Library/Application Support/AFFiNE/workspaces/affine-cloud/{workspace_id}/storage.db` or `.../local/{workspace_id}/storage.db`. Older: `@affine/electron/workspaces/{workspace_id}/storage.db`
- **Path (Windows):**  
  `%APPDATA%\@affine\electron\workspaces\{workspace_id}\storage.db`
- **Path (Linux):**  
  `~/.config/@affine/electron/workspaces/{workspace_id}/storage.db`

- **Per workspace:** One SQLite file (`storage.db`) per workspace.
- **Content:** Data is synced between **Yjs (ydoc)** and SQLite (duplex sync). So the DB likely stores:
  - Yjs update blobs and/or
  - Normalized tables (e.g. for blobs, doc metadata) — exact schema is **not** publicly documented and may change between AFFiNE versions.

**Workspace discovery:** Workspace IDs can be inferred by **listing the `workspaces` directory** (each subdirectory name is a workspace id). No separate “workspace list” JSON file is required for discovery.

---

## 3. Technical feasibility

### 3.1 Raycast extension environment

- Extensions run in **Node.js** and can use `fs`, `path`, and other Node APIs.
- File system access is **not** heavily sandboxed; reading `~/Library/Application Support/...` is possible if the user has granted Raycast the necessary permissions (or by default on macOS).
- We can use **`better-sqlite3`** or **`sql.js`** (WASM, no native deps) to open SQLite. Raycast extensions typically support npm deps; `sql.js` is easier for distribution (no native bindings).

### 3.2 What we can do without reverse‑engineering the full schema

| Feature            | Feasibility | Notes |
|--------------------|------------|--------|
| **Discover workspaces** | ✅ High   | List `workspaces/*` directories; directory name = workspace id. Optional: read a metadata file if AFFiNE ever adds one. |
| **List docs per workspace** | ⚠️ Medium | Requires knowing how doc list/titles are stored in `storage.db`. Either: (a) reverse‑engineer SQLite tables/views, or (b) parse Yjs blobs (harder). AFFiNE may store doc metadata in a table; need a one‑time schema spike. |
| **Search docs**    | ⚠️ Medium–Low | Would require either: (a) SQLite FTS over doc content, or (b) loading doc list and then filtering by title/text. Full‑text search likely needs decoding Yjs/doc content. |
| **Open in desktop app** | ✅ High   | AFFiNE registers URL schemes: `affine://`, `affine-canary://`, `affine-beta://`. We can open e.g. `affine://workspace/{workspaceId}/{docId}` (exact path to be confirmed in AFFiNE docs or source). |
| **New doc**        | ✅ Medium  | Open app via `affine://` (e.g. `affine://new` or workspace root) if supported; otherwise “open app” only. |

### 3.3 Risks and constraints

1. **Schema stability**  
   SQLite layout is internal to AFFiNE. Tables/columns might change with app updates. Any bridge that reads the DB directly should:
   - Prefer the most stable surface (e.g. workspace id from filesystem; doc list from whatever table AFFiNE uses long‑term).
   - Defend against missing tables/columns and document “best effort” compatibility.

2. **Concurrent access**  
   The desktop app keeps `storage.db` open. SQLite supports multiple readers; writing from the extension could be risky. **Recommendation:** bridge is **read‑only** (list workspaces, list docs, optional search). No writing to the DB from the extension.

3. **Platform paths**  
   We must resolve the app data directory per OS (macOS / Windows / Linux). Well‑documented in AFFiNE community; straightforward to implement.

4. **MCP**  
   The current MCP server is HTTP/GraphQL-based. To support “local only” MCP we’d need either:
   - A **separate** MCP server that talks to the local bridge (e.g. reads from the same SQLite or a small local HTTP server that the bridge implements), or
   - Extend the existing MCP server to accept a “local mode” that uses the bridge. Out of scope for the initial Raycast‑only bridge; can be a later phase.

---

## 4. Proposed architecture (inside the Raycast extension)

- **Data source abstraction:**  
  - **Cloud:** existing `affine-api.ts` (GraphQL + token).  
  - **Local:** new module e.g. `affine-local-bridge.ts` that:
    - Resolves workspace root path (macOS/Windows/Linux).
    - Lists workspace IDs (directories under `workspaces/`).
    - For each workspace, opens `workspaces/{id}/storage.db` and returns doc list (and optionally search results) using whatever schema we discover in the spike.
- **Preference:**  
  User chooses “Cloud” vs “Local (desktop app)” in extension preferences. When “Local”:
  - No API token needed.
  - Workspace list and doc list (and optional search) come from the local bridge.
  - “Open” uses `affine://...` (or fallback “open app” only).
- **Open in app:**  
  Use Raycast’s “Open URL” (or equivalent) with `affine://workspace/{workspaceId}/{docId}`. If the scheme isn’t documented, we confirm it from AFFiNE’s Electron/URL-handling code.

---

## 5. Phased plan

### Phase 0: Schema spike (1–2 days)

- **Goal:** Confirm we can get “list of docs (id + title)” from one `storage.db` without writing.
- **Steps:**
  1. On a machine with the AFFiNE desktop app installed, locate `workspaces/{workspace_id}/storage.db`.
  2. Open it with a SQLite browser; list tables and (if possible) identify tables that store doc id / title / updated time.
  3. If the schema is Yjs‑centric (e.g. single table of blobs), check whether AFFiNE’s code (e.g. `packages/workspace`, `nbstore`, sqlite provider) exposes or implies a stable way to get doc list.
  4. Document findings (table names, columns, and any version notes) in this repo.
- **Outcome:** Go/no‑go for Phase 1. If we cannot get a doc list without heavy Yjs decoding, we may limit the bridge to “list workspaces + open app” only.

### Phase 1: Minimal local bridge (3–5 days)

- **Scope:**
  - Resolve workspace root path (macOS/Windows/Linux).
  - List workspaces (directory names = ids).
  - If Phase 0 succeeded: list docs (id + title + updated) per workspace from SQLite (read‑only).
  - Preference: “Use local desktop app” vs “Use AFFiNE Cloud”.
  - When local: show workspaces and docs in existing Raycast commands (search, open doc, open workspace); “Open” uses `affine://...` (or “open app”).
- **No search** in this phase (only list + open).

### Phase 2: Search (optional, 2–4 days)

- If Phase 0/1 show that doc content or searchable metadata is available in SQLite (or via a simple heuristic, e.g. title substring), add a local search that mirrors “Search AFFiNE Documents” for the local source.
- If full‑text search is too fragile (e.g. depends on decoding Yjs), we can document “search only when using Cloud” and keep local as list + open.

### Phase 3: MCP / AI (optional, later)

- Separate design: either a small local HTTP server that exposes the same data, or an MCP server that links to the same bridge logic. Not part of the initial Raycast-only scope.

---

## 6. Recommendation

- **Feasibility:** A **read‑only local bridge** inside the Raycast extension is **feasible** for:
  - Discovering workspaces and (if the schema allows) listing docs with id/title/updated.
  - Opening the desktop app to a workspace/doc via `affine://`.
- **Critical dependency:** A **one‑time schema spike** (Phase 0) on `storage.db` to see how to get doc list (and optionally search). Without that, we can still ship “list workspaces + open app” only.
- **Scope for “as part of the Raycast extension”:** Implement the bridge inside the extension (new module + preference + wiring to existing commands). Keep Cloud path unchanged. No MCP changes in the first iteration.

---

## 7. Implementation status (feature/local-bridge)

- **Data source:** "Data source" preference: Cloud vs Local desktop app. Path resolution (macOS/Windows/Linux), workspace list from filesystem, doc list from `storage.db` via sql.js (best-effort table discovery), local search by title, open via `affine://workspace/{id}` and `affine://workspace/{id}/{docId}`. All commands respect Data source.

## 8. Next steps

1. **Run Phase 0** on a Mac (or Windows/Linux) with AFFiNE desktop installed: inspect one `storage.db`, document tables and a safe way to get doc id/title/updated.
2. **Confirm** `affine://` URL format (and variants) in AFFiNE’s Electron or docs.
3. **Implement Phase 1** (path resolution, workspace list, doc list from DB, preference, open via scheme).
4. **Optionally** add local search (Phase 2) depending on Phase 0 results and maintainability.

---

## 9. Inspecting the DB and build output

- **DB structure (CLI):** Run `./scripts/inspect-affine-db.sh` on a Mac with AFFiNE desktop installed. It prints tables, schema, and row counts. Use the output to adjust `tryGetDocsFromTable()` in `affine-local-bridge.ts` if the doc list is empty.
- **Build output:** See [BUILD_AND_LOCAL_BRIDGE.md](BUILD_AND_LOCAL_BRIDGE.md) for where `npm run build` writes (`affine-raycast/dist/`) and how to inspect the DB with sqlite3.

## 10. References

- AFFiNE Electron storage: `~/Library/Application Support/@affine/electron/workspaces/{workspace_id}/storage.db` (macOS).
- PR #2037 (store local data to local db): syncs ydoc with SQLite duplex.
- PR #8811 (nbstore sqlite implementation): SQLite as storage backend.
- URL scheme: `affine://`, `affine-canary://`, `affine-beta://` (Electron).
- Raycast: Node environment, file system access possible; consider `sql.js` for portable SQLite in the extension.
