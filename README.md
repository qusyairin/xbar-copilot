# copilot-xbar

Shows GitHub Copilot premium-request quota in the macOS menu bar via [xbar](https://xbarapp.com).

<img width="302" height="190" alt="image" src="https://github.com/user-attachments/assets/47b5b067-b1c2-4394-a1c3-d46cb01fd482" />


<img width="304" height="187" alt="image" src="https://github.com/user-attachments/assets/6c4ad43b-f5f8-4561-89a3-f3968651d6fa" />






## Requirements

- Homebrew, `jq`, `bc`
- xbar (`brew install --cask xbar`)
- OpenCode logged in to GitHub Copilot, so `~/.local/share/opencode/auth.json` exists

## Install

```bash
ln -s "$(pwd)/copilot.1m.sh" ~/Library/Application\ Support/xbar/plugins/copilot.1m.sh
```

Open xbar, click the icon, then **Refresh all**.

## Notes

- The filename's `.15m.` segment controls the refresh interval (`s`/`m`/`h`/`d` suffixes). Rename to change it, then Refresh all.
- If the token lookup breaks, check the actual auth.json structure:
  ```bash
  jq '.["github-copilot"]' ~/.local/share/opencode/auth.json
  ```
  and adjust the `jq` selector in the script.

