# Affine – AFFiNE for Raycast

## Checklist

- [x] I read the [extension guidelines](https://manual.raycast.com/extensions)
- [x] I read the [documentation about publishing](https://developers.raycast.com/basics/publish-an-extension)
- [x] I ran `npm run build` and tested this distribution build in Raycast
- [x] I checked that files in the assets folder are used by the extension itself
- [x] I checked that assets used by the README are placed outside of the metadata folder

## Summary

**Affine** is the AFFiNE Raycast extension: it lets you search and open AFFiNE workspaces and documents from Raycast, with optional desktop app links and MCP setup for Raycast AI.

### Commands

- **Search Affine Documents** – Search across all workspaces and open a doc in the browser or in the AFFiNE desktop app.
- **Open Affine Workspace** – List workspaces and open one in the browser.
- **Open Affine Document** – List documents in the default workspace and open one (browser or desktop app).
- **New Affine Document** – Open AFFiNE in the browser to create a new document.
- **Setup Affine AI (MCP)** – In-app instructions to add the AFFiNE MCP server so Raycast AI can read/write docs.

### Features

- Uses the official AFFiNE GraphQL API (same as [affine-mcp-server](https://github.com/DAWNCR0W/affine-mcp-server)).
- **Desktop app links:** “Open in Desktop App” and “Copy Desktop App URL” use the `affine://` scheme (inferred from AFFiNE’s Electron app) so links open in the AFFiNE desktop app instead of the browser.
- Preferences: AFFiNE URL (default `https://app.affine.pro`), API Token (from AFFiNE → Settings → Integrations → MCP Server), optional Default Workspace ID.

### Setup required

Users must set **AFFiNE URL** and **API Token** in the extension preferences. Token is created in AFFiNE (Cloud or self-hosted) under Settings → Integrations → MCP Server. README in the extension describes this.

### Assets

- **Icon:** `icon.png` at the extension root is referenced in `package.json` and used by the extension.
- **README:** The README does not reference any images; no README media assets.

### Testing

- `npm run build` completes successfully.
- Extension was tested in Raycast with the distribution build: search, open doc/workspace, open in desktop app, copy desktop URL, new doc, and setup MCP command all work as expected.
