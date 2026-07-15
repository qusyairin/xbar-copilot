#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:$PATH"

AUTH="$HOME/.local/share/opencode/auth.json"
GITHUB_ICON="iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAABmJLR0QA/wD/AP+gvaeTAAABd0lEQVQ4jZ3UPWtUURAG4Ie72RVCUliEoEWKkFSCwU47/8HqCi75BXZpEywsJI1ki7SSNloGAv6BoFWsxMJVNyEG0iSNhQSESCzuOeTs9cT9eGG4587He2aGmUMeDbTxFl38CtINuqfBZyg8wQEuB0gPrf8R1dAZgqgqGyhyhOOQRXmVKzMaP2INXxLdWWjDOS6whQfYSXweRbJGpWcvgn4CTcxV2jKT/D9P4r6jMYHHmE+cJsP3AruVSv6EbCNmk/MCmkXIIsVnw+NNuCSiCV+TtL+NQBaxl8R3C9xKjJ/GIDxOzrcLZaMjakbHzeRcwKHxS67hNInvFdhPHBbxcATCZ/rHaB+W9U/9Ce4NILqBFfyuxLYpB/sYR8pl7yln8B1WUa8Q7eKnf9fvKPVtBeV73HHVl+pgw3aGrG/1IjZdrd407mMqQ/gyQ9bJ+CkS0g94rXxIBxF2XPN8RbSUPb3Eesa+Hmw/ZMq8DvWQ3d2MbSnY6hmbv8gAkQuzLhgMAAAAAElFTkSuQmCC"

if [ ! -f "$AUTH" ]; then
  echo "? | templateImage=$GITHUB_ICON"
  echo "---"
  echo "auth.json not found"
  exit 0
fi

TOKEN=$(jq -r '.["github-copilot"].access // .["github-copilot"].token // .["github-copilot"].access_token' "$AUTH")
JSON=$(curl -s -H "Authorization: Bearer $TOKEN" https://api.github.com/copilot_internal/user)

USED=$(echo "$JSON" | jq -r '.quota_snapshots.premium_interactions.credits_used')
TOTAL=$(echo "$JSON" | jq -r '.quota_snapshots.premium_interactions.entitlement')
RESET=$(echo "$JSON" | jq -r '.quota_reset_date')

if [ -z "$USED" ] || [ "$USED" = "null" ]; then
  echo "! | templateImage=$GITHUB_ICON"
  echo "---"
  echo "Token expired or API error"
  echo "Refresh | refresh=true"
  exit 0
fi

PCT=$(echo "scale=1; $USED * 100 / $TOTAL" | bc -l)

COLOR=green
(( $(echo "$PCT > 50" | bc -l) )) && COLOR=orange
(( $(echo "$PCT > 80" | bc -l) )) && COLOR=red

LABEL_LINE="$USED / $TOTAL premium requests"

BAR_PNG=$(PCT="$PCT" COLOR="$COLOR" LABEL="$LABEL_LINE" python3 - <<'PYEOF'
import os, base64, io
from PIL import Image, ImageDraw, ImageFont

pct = min(float(os.environ["PCT"]), 100.0)
color_name = os.environ["COLOR"]
label = os.environ["LABEL"]

colors = {"green": (52, 199, 89), "orange": (255, 149, 0), "red": (255, 59, 48)}
rgb = colors.get(color_name, (52, 199, 89))

font = ImageFont.truetype("/System/Library/Fonts/Menlo.ttc", 13)
width = int(font.getlength(label))
height, radius = 14, 7
fill_width = int(round(width * pct / 100))

img = Image.new("RGBA", (width, height), (0, 0, 0, 0))

track_mask = Image.new("L", (width, height), 0)
ImageDraw.Draw(track_mask).rounded_rectangle([0, 0, width - 1, height - 1], radius=radius, fill=255)
img.paste(Image.new("RGBA", (width, height), (90, 90, 90, 255)), (0, 0), track_mask)

if fill_width > 0:
    fill_mask = Image.new("L", (width, height), 0)
    fd = ImageDraw.Draw(fill_mask)
    fd.rounded_rectangle([0, 0, width - 1, height - 1], radius=radius, fill=255)
    if fill_width < width:
        fd.rectangle([fill_width, 0, width, height], fill=0)
    img.paste(Image.new("RGBA", (width, height), rgb + (255,)), (0, 0), fill_mask)

buf = io.BytesIO()
img.save(buf, format="PNG")
print(base64.b64encode(buf.getvalue()).decode())
PYEOF
)

echo "${PCT}% | color=$COLOR templateImage=$GITHUB_ICON"
echo "---"
echo " | image=$BAR_PNG"
echo "$LABEL_LINE | font=Menlo"
echo "Resets $RESET | font=Menlo"
echo "---"
echo "Refresh now | refresh=true"
