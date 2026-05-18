#!/bin/bash
CONFIG="/etc/xray/config.json"
UUID=$(grep -o '"id": *"[^"]*"' "$CONFIG" | head -1 | grep -o '"[^"]*"$' | tr -d '"')

if [ -z "$UUID" ]; then
    echo "[NikVPN] Error: UUID not found in config."
    exit 1
fi

SNI="${CODESPACE_NAME}-443.app.github.dev"
LINK="vless://${UUID}@94.130.50.12:443?encryption=none&security=tls&sni=${SNI}&host=${SNI}&fp=chrome&allowInsecure=1&type=xhttp&mode=packet-up&path=%2F#nikvpn-mobile"

echo ""
echo "========================================"
echo "🔗 NikVPN Mobile - Your VLESS xHTTP Link"
echo "========================================"
echo "${LINK}"
echo ""

# ذخیره لینک در فایل (مسیر داینامیک بر اساس current workspace)
CURRENT_DIR=$(pwd)
LINK_FILE="${CURRENT_DIR}/nikvpn-link.txt"
echo "$LINK" > "$LINK_FILE"
echo "📁 Link saved to: $LINK_FILE"

echo "📌 Make sure port 443 is PUBLIC (check PORTS tab)"
echo "🌐 Also open port 8080 in browser to get your link easily"
echo "========================================"
echo ""
