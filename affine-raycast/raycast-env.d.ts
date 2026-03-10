/// <reference types="@raycast/api">

/* 🚧 🚧 🚧
 * This file is auto-generated from the extension's manifest.
 * Do not modify manually. Instead, update the `package.json` file.
 * 🚧 🚧 🚧 */

/* eslint-disable @typescript-eslint/ban-types */

type ExtensionPreferences = {
  /** AFFiNE URL - Base URL of your AFFiNE instance (e.g. https://app.affine.pro) */
  "baseUrl": string,
  /** API Token - AFFiNE API token from Settings → Integrations → MCP Server */
  "apiToken": string,
  /** Default Workspace ID - Default workspace for listing docs (optional) */
  "workspaceId"?: string
}

/** Preferences accessible in all the extension's commands */
declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Preferences accessible in the `search-docs` command */
  export type SearchDocs = ExtensionPreferences & {}
  /** Preferences accessible in the `open-workspace` command */
  export type OpenWorkspace = ExtensionPreferences & {}
  /** Preferences accessible in the `open-doc` command */
  export type OpenDoc = ExtensionPreferences & {}
  /** Preferences accessible in the `new-doc` command */
  export type NewDoc = ExtensionPreferences & {}
  /** Preferences accessible in the `setup-mcp` command */
  export type SetupMcp = ExtensionPreferences & {}
}

declare namespace Arguments {
  /** Arguments passed to the `search-docs` command */
  export type SearchDocs = {}
  /** Arguments passed to the `open-workspace` command */
  export type OpenWorkspace = {}
  /** Arguments passed to the `open-doc` command */
  export type OpenDoc = {}
  /** Arguments passed to the `new-doc` command */
  export type NewDoc = {}
  /** Arguments passed to the `setup-mcp` command */
  export type SetupMcp = {}
}

