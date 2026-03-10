# Desktop app deep link format (inferred from AFFiNE codebase)

This describes how to open a **document** in the AFFiNE **desktop app** (macOS/Windows/Linux) via a URL, as implemented in the Raycast extension. The format was inferred from the official AFFiNE repo, not from public docs.

## Source references (AFFiNE repo)

- **Protocol registration:** `packages/frontend/apps/electron/src/main/deep-link.ts`  
  - `setAsDefaultProtocolClient(protocol)` with `protocol = 'affine'` (stable), `'affine-canary'`, `'affine-beta'`, `'affine-internal'`, or `'affine-dev'` (dev).
- **URL handling:** Same file, `handleAffineUrl(url)`:
  - `affine://authentication?...` → auth flow (magic-link, oauth, open-app-signin).
  - `affine://...?new-tab=1` and pathname starting with `/workspace` → **new tab** via `addTabWithUrl(url)`.
  - Otherwise → `loadUrlInActiveTab` (not implemented) or `openUrlInHiddenWindow`.
- **Building the link in the web app:** `packages/frontend/core/src/modules/open-in-app/utils.ts`  
  - `getOpenUrlInDesktopAppLink(url, newTab, scheme)` builds:  
    `{scheme}://{host}{pathname}?{params}#{hash}` with optional `new-tab=1`.
- **Tab parsing:** `packages/frontend/apps/electron/src/main/windows-manager/tab-views.ts`  
  - `parseFullPathname(url)` expects pathname like `/workspace/{workspaceId}/{docId}` (basename `/workspace/{workspaceId}`, pathname `/{docId}`).

## URL format for opening a document

- **Scheme:** `affine` (stable desktop app). Other builds use `affine-canary`, `affine-beta`, etc.
- **Host:** Same as the **web app host** (e.g. `app.affine.pro` for Cloud).
- **Path:** `/workspace/{workspaceId}/{docId}`.
- **Query:** Optional `new-tab=1` to open in a new tab (recommended; the “current tab” path is not implemented in Electron).

**Example:**

```text
affine://app.affine.pro/workspace/<workspaceId>/<docId>?new-tab=1
```

The extension builds this in `desktopAppUrl(baseUrl, workspaceId, docId, newTab)` in `affine-api.ts` and exposes “Open in Desktop App” and “Copy Desktop App URL” in Search Docs and Open Document.

---

## Using the same format with MCP

The AFFiNE MCP server ([affine-mcp-server](https://github.com/DAWNCR0W/affine-mcp-server)) returns document references (workspace ID, doc ID) and may include **web** URLs (e.g. `https://app.affine.pro/workspace/{workspaceId}/{docId}`). To open those docs in the **desktop app** instead of the browser, use the same URL scheme:

- **Convert:** From base URL `B` (e.g. `https://app.affine.pro`), workspace ID `W`, doc ID `D`:
  - Desktop URL: `affine://<host>/workspace/<W>/<D>?new-tab=1`
  - where `<host>` is the host of `B` (e.g. `app.affine.pro`).

**In practice:**

- Use the **Raycast extension**: when the AI mentions a doc, run "Search AFFiNE Documents" or "Open AFFiNE Document", find the same doc, and choose **Open in Desktop App** or **Copy Desktop App URL**.
- Or convert manually: if you have the web URL, replace `https://` with `affine://` and add `?new-tab=1` (e.g. `https://app.affine.pro/workspace/abc/xyz` → `affine://app.affine.pro/workspace/abc/xyz?new-tab=1`).

If the MCP server ever adds an option to return desktop app URLs (e.g. via an env var), it would use this same format; the spec is above and in the AFFiNE Electron source.
