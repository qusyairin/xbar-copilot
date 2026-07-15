# copilot-xbar

Shows GitHub Copilot premium-request quota in the macOS menu bar via [xbar](https://xbarapp.com).

<img width="275" alt="image" src="https://github.maybank.com/user-attachments/assets/5102ade5-a2cf-47e8-8b74-dba2f3845087" />

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

