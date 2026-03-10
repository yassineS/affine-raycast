# AFFiNE + Raycast Integration

Use [AFFiNE](https://affine.pro) from [Raycast](https://raycast.com) with **quick commands** and **AI**: search, open docs/workspaces, and let Raycast AI read/write your AFFiNE content.

**Recommended: use both.**  
- **Quick commands** (search, open workspace, open doc, new doc) → install the **affine-raycast** extension below.  
- **AI** (summarize docs, create/append content, comments, 46 tools) → add the **AFFiNE MCP server** in Raycast MCP settings.

The integration uses **[DAWNCR0W/affine-mcp-server](https://github.com/DAWNCR0W/affine-mcp-server)** (46 tools, full document read/write, WebSocket + GraphQL). See the [plan](.cursor/plans/affine_mcp_comparison_and_raycast_plugin_56ac3305.plan.md) for the comparison with Paperfeed/affine-mcp.

---

## Use both (recommended)

1. **Extension (quick commands)**  
   - Go to [Option B](#option-b-dedicated-raycast-extension), run `npm run dev` in `affine-raycast`, and set AFFiNE URL + API Token in the extension preferences.  
   - You get: Search AFFiNE Documents, Open Workspace, Open Document, New Document.

2. **MCP (AI)**  
   - Go to [Option A](#option-a-raycast-mcp-ai) and add the AFFiNE MCP server (command `affine-mcp`, env: `AFFINE_BASE_URL`, `AFFINE_API_TOKEN`).  
   - In Raycast AI (AI Chat / AI Commands), @-mention the AFFiNE server to search, read, create, and edit docs.

Same credentials (URL + API token) work for both. You can also use the extension command **“Setup AFFiNE AI (MCP)”** for in-app instructions. **Self-hosted (Docker, etc.):** set your instance URL (e.g. `http://localhost:3010`) in extension preferences and MCP env (`AFFINE_BASE_URL`); create an API token in that instance. **macOS/Windows/Linux desktop app:** The desktop app does not run an HTTP server (data is in local SQLite), so localhost will not work. Use **AFFiNE Cloud** instead: sign in to Cloud in the desktop app, enable Cloud sync for your workspace(s), then set AFFiNE URL to `https://app.affine.pro` and use an API token from Cloud (Settings → Integrations → MCP Server at app.affine.pro). Desktop and Raycast/MCP will see the same synced data.

---

## Option A: Raycast MCP (AI)

Use Raycast’s MCP support so Raycast AI can search workspaces, read docs, create/append content, and manage comments via the AFFiNE MCP server.

### 1. Install the AFFiNE MCP server

```bash
npm i -g affine-mcp-server
```

Or run without global install:

```bash
npx -y -p affine-mcp-server affine-mcp -- --version
```

### 2. Get AFFiNE credentials

**Recommended: interactive login (writes config so you don’t need env vars):**

```bash
affine-mcp login
```

- **AFFiNE Cloud** (`app.affine.pro`): use an API token from **Settings → Integrations → MCP Server**.
- **Self‑hosted / local app**: use the URL of your instance (e.g. `http://localhost:3010` for Docker/self-hosted). Create an API token in that instance (Settings → Integrations → MCP Server). You can use email/password (`affine-mcp login`) or paste a token.

**Or use environment variables:**

- `AFFINE_BASE_URL` – e.g. `https://app.affine.pro` (Cloud) or `http://localhost:3010` (local/self-hosted).
- `AFFINE_API_TOKEN` – from AFFiNE (Settings → Integrations → MCP Server, or from `affine-mcp login`).
- `AFFINE_WORKSPACE_ID` (optional) – default workspace; you can find it in the browser URL when you open a workspace.

### 3. Add the server to Raycast MCP

Raycast uses **stdio only** for MCP. The server runs as `affine-mcp`.

**If you used `affine-mcp login`** (config in `~/.config/affine-mcp/config`):

- In Raycast: **Install Server** (or edit MCP config).
- Command: `affine-mcp`  
  (ensure `affine-mcp` is on your PATH, e.g. after `npm i -g affine-mcp-server`).

**If you use environment variables:**

- Copy [mcp-config.example.json](mcp-config.example.json) and set:
  - `AFFINE_BASE_URL`
  - `AFFINE_API_TOKEN`
  - `AFFINE_WORKSPACE_ID` (optional).
- In Raycast, add this server (command `affine-mcp`, env from the example).

Example config (env block only; command is `affine-mcp`):

```json
{
  "mcpServers": {
    "affine": {
      "command": "affine-mcp",
      "env": {
        "AFFINE_BASE_URL": "https://app.affine.pro",
        "AFFINE_API_TOKEN": "ut_xxx",
        "AFFINE_WORKSPACE_ID": "optional-workspace-id"
      }
    }
  }
}
```

With **npx** (no global install):

```json
{
  "mcpServers": {
    "affine": {
      "command": "npx",
      "args": ["-y", "-p", "affine-mcp-server", "affine-mcp"],
      "env": {
        "AFFINE_BASE_URL": "https://app.affine.pro",
        "AFFINE_API_TOKEN": "ut_xxx"
      }
    }
  }
}
```

### 4. Use with Raycast AI

- In **AI Commands**, **AI Chat**, or **Presets**, @-mention the AFFiNE MCP server.
- You can ask to search workspaces, read a doc, create or append content, manage comments, etc. (full 46-tool surface).

**Open MCP-referenced docs in the desktop app:** The MCP returns web URLs. To open the same doc in the AFFiNE desktop app, use the extension: run **Search AFFiNE Documents** or **Open AFFiNE Document**, pick the doc, then **Open in Desktop App** (or **Copy Desktop App URL**). Same `affine://` format as the extension; see [docs/DESKTOP_DEEPLINK.md](docs/DESKTOP_DEEPLINK.md#using-the-same-format-with-mcp).

**Tips:**

- Prefer **token auth** (or one-time `affine-mcp login`) so the server starts without blocking.
- On AFFiNE Cloud, use `AFFINE_API_TOKEN`; email/password can be blocked by Cloudflare.
- Restart Raycast after changing PATH or MCP config if tools don’t appear.

---

## Option B: Dedicated Raycast extension (quick commands)

The **affine-raycast** extension adds quick commands: search docs, open a doc/workspace in the browser, and open “new doc”. It uses AFFiNE’s GraphQL API. Use it together with Option A so you have both quick commands and AI.

- **Search AFFiNE Documents** – search across workspaces and open in browser.
- **Open AFFiNE Workspace** – list workspaces and open one in browser.
- **Open AFFiNE Document** – list docs in the default workspace and open one.
- **New AFFiNE Document** – open AFFiNE in browser to create a new doc.
- **Setup AFFiNE AI (MCP)** – in-app instructions to add the MCP server so Raycast AI can use AFFiNE.

Setup:

1. Open the `affine-raycast` folder in the repo.
2. Run `npm install && npm run dev`.
3. In Raycast, configure the extension preferences: **AFFiNE URL**, **API Token**, and optional **Default Workspace ID**.

Add **Option A** (MCP) to enable AI: summarize docs, create/append content, manage comments, etc.

**Desktop app local bridge:** A feasibility plan for supporting the AFFiNE desktop app (local SQLite) from the Raycast extension—without Cloud—is in [docs/LOCAL_BRIDGE_FEASIBILITY.md](docs/LOCAL_BRIDGE_FEASIBILITY.md). It outlines a read-only local bridge, schema discovery, and phased implementation.

---

## Summary

| What you get | How |
|--------------|-----|
| **Both** quick commands + AI | Extension (Option B) + MCP server (Option A); same URL + token. |
| AI only (read/write, 46 tools) | Option A: add AFFiNE MCP in Raycast, @-mention in AI Chat. |
| Quick commands only | Option B: install affine-raycast extension and set preferences. |

Both options use **DAWNCR0W/affine-mcp-server** as the reference for AFFiNE + Raycast (and AI).
