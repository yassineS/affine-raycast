# AFFiNE Raycast Extension

Quick commands to search and open AFFiNE workspaces and documents from Raycast. Uses the AFFiNE GraphQL API (same as [DAWNCR0W/affine-mcp-server](https://github.com/DAWNCR0W/affine-mcp-server)).

## Commands

- **Search AFFiNE Documents** – Search across all workspaces and open a doc in the browser.
- **Open AFFiNE Workspace** – List workspaces and open one in the browser.
- **Open AFFiNE Document** – List documents in your default workspace and open one.
- **New AFFiNE Document** – Open AFFiNE in the browser (optionally in a specific workspace).
- **Setup AFFiNE AI (MCP)** – In-app instructions to add the AFFiNE MCP server so Raycast AI can read/write your docs (use this + the extension for both quick commands and AI).

**Local desktop app (branch `feature/local-bridge`):** Set **Data source** to "Local desktop app" to list workspaces and docs from the AFFiNE desktop app’s local storage and open them via `affine://`. No API token needed. See [../docs/LOCAL_BRIDGE_FEASIBILITY.md](../docs/LOCAL_BRIDGE_FEASIBILITY.md).

## Setup

1. **Extension preferences** (Raycast → Preferences → Extensions → AFFiNE):
   - **AFFiNE URL**: Use `https://app.affine.pro` for Cloud and for the **desktop app** (desktop has no HTTP API; use Cloud sync). Self-hosted: e.g. `http://localhost:3010`.
   - **API Token**: From AFFiNE → Settings → Integrations → MCP Server (Cloud or your self-hosted instance).
   - **Default Workspace ID** (optional): Required for “Open AFFiNE Document”. Find it in the browser URL when you open a workspace.

2. **Icon**: Place a 512×512 PNG as `assets/icon.png` (or use Raycast’s “Create Extension” to generate assets).

## Development

```bash
cd affine-raycast
npm install
npm run dev
```

Raycast will load the extension from this folder. `npm run build` writes to `~/.config/raycast/extensions/`; run it on a machine where Raycast is installed. For full doc content and AI (summarize, create, append), use **Option A** (Raycast MCP + affine-mcp-server) as described in the repo root [README](../README.md).
