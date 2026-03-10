# Publish AFFiNE extension to the Raycast Store

This describes how to publish the **affine-raycast** extension so it appears in the Raycast Store (Manage Extensions → Browse Store).

## Before you publish

1. **Raycast account**  
   Create an account at [raycast.com](https://raycast.com) if you haven’t. Your **username** (e.g. from your profile URL) must go in `package.json` → `author`. The Store uses this to attribute the extension.

2. **Author in package.json**  
   In `affine-raycast/package.json`, set `author` to your **Raycast username** (not your full name). It must match the pattern `[a-zA-Z0-9-*._~]+` (no spaces) and must be an existing Raycast account, e.g.:
   ```json
   "author": "your_raycast_username"
   ```
   Create an account at [raycast.com](https://raycast.com) if needed; your profile URL is `https://raycast.com/YourUsername`. Extensions that use an invalid or non-existent author fail `npm run lint` (404 from Raycast API).

3. **Icon 512×512**  
   The Store requires a **512×512 px** PNG icon.  
   - Put it at `affine-raycast/assets/icon.png` (or the path set in `package.json` → `icon`).  
   - Resize your current icon to 512×512 (e.g. with Preview, [icon.ray.so](https://icon.ray.so/), or any image editor).  
   - It should look good in both light and dark themes.

4. **Optional: Title case**  
   The linter may suggest “Affine” instead of “AFFiNE”. “AFFiNE” is the official product name; you can keep it and the review team may accept it. If they ask for title case, switch to “Affine”.

## Steps to publish

All commands are run from the **affine-raycast** directory.

```bash
cd affine-raycast
npm install
```

1. **Validate**
   - `npm run build` – must complete without errors (writes to `dist/` or your configured output).
   - `npm run lint` – fix any reported issues. If the linter complains only about author, ensure `author` is your Raycast username and that you’re logged in at raycast.com.

2. **Publish**
   - `npm run publish`  
   - This runs `npx @raycast/api@latest publish`, which will:
     - Use your GitHub auth (you may be prompted to log in).
     - Open a **pull request** on the [raycast/extensions](https://github.com/raycast/extensions) repo with your extension.

3. **Review**
   - The Raycast team will review the PR and may request changes.
   - Once the PR is merged, the extension is published to the Store.

4. **Share**
   - In Raycast: **Manage Extensions** → search for your extension → `⌘⌥.` to copy the Store link.

## If the publish script is missing

If `npm run publish` fails because there is no `publish` script, add it in `affine-raycast/package.json`:

```json
"scripts": {
  "build": "ray build -e dist",
  "dev": "ray develop",
  "lint": "ray lint",
  "publish": "npx @raycast/api@latest publish"
}
```

## Manual alternative

You can skip `npm run publish` and submit manually:

1. Fork [github.com/raycast/extensions](https://github.com/raycast/extensions).
2. Add the contents of **affine-raycast** (excluding `node_modules`) into a folder under `extensions` in the fork (see existing extensions for structure).
3. Open a pull request to `main` with a short description of the extension.

## References

- [Prepare an Extension for Store](https://developers.raycast.com/basics/prepare-an-extension-for-store)
- [Publish an Extension](https://developers.raycast.com/basics/publish-an-extension)
- [Extension guidelines](https://manual.raycast.com/extensions)
