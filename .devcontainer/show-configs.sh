#!/bin/bash

# بارگذاری تنظیمات
source /tmp/nikvpn-config.env 2>/dev/null || {
    UUID_VLESS=$(grep -o '"id": *"[^"]*"' /etc/xray/config-vless-xhttp.json 2>/dev/null | head -1 | grep -o '"[^"]*"$' | tr -d '"')
    UUID_XTLS=$(grep -o '"id": *"[^"]*"' /etc/xray/config-vless-xtls.json 2>/dev/null | head -1 | grep -o '"[^"]*"$' | tr -d '"')
}

if [ -z "$CODESPACE_NAME" ]; then
    echo "⚠️  CODESPACE_NAME یافت نشد!"
    exit 1
fi

SNI="${CODESPACE_NAME}-443.app.github.dev"
SERVER="94.130.50.12"

# تولید لینک‌های کانفیگ
LINK_VLESS="vless://${UUID_VLESS}@${SERVER}:443?encryption=none&security=tls&sni=${SNI}&host=${SNI}&fp=chrome&allowInsecure=1&type=xhttp&mode=packet-up&path=%2F#nikvpn-mobile-xhttp"

LINK_XTLS="vless://${UUID_XTLS}@${SERVER}:8443?encryption=none&security=tls&sni=${SNI}&host=${SNI}&flow=xtls-rprx-vision&fp=chrome&allowInsecure=1&type=tcp#nikvpn-mobile-xtls"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    🔐 NikVPN Mobile - لینک‌ها                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# نمایش لینک VLESS xHTTP
echo "┌─────────────────────────────────────────────────────────────────┐"
echo "│ 1️⃣  VLESS + xHTTP                                              │"
echo "└─────────────────────────────────────────────────────────────────┘"
echo ""
echo "🔗 لینک کانفیگ:"
echo "${LINK_VLESS}"
echo ""
echo "📱 QR Code:"
echo "${LINK_VLESS}" | qrencode -t ANSI -s 1 -m 1
echo ""

# نمایش لینک VLESS XTLS
echo "┌─────────────────────────────────────────────────────────────────┐"
echo "│ 2️⃣  VLESS + XTLS (توصیه‌شده برای بازدهی بالاتر)              │"
echo "└─────────────────────────────────────────────────────────────────┘"
echo ""
echo "🔗 لینک کانفیگ:"
echo "${LINK_XTLS}"
echo ""
echo "📱 QR Code:"
echo "${LINK_XTLS}" | qrencode -t ANSI -s 1 -m 1
echo ""

# ذخیره لینک‌ها برای استفاده بعدی
cat > /tmp/nikvpn-links.env << ENVEOF
export LINK_VLESS="${LINK_VLESS}"
export LINK_XTLS="${LINK_XTLS}"
ENVEOF

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📌 نکات مهم:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ مطمئن شوید پورت 443 PUBLIC است (تب PORTS را بررسی کنید)"
echo "✅ یکی از QR Codes را با دوربین موبایل خود اسکن کنید"
echo "✅ برای بهترین عملکرد، VLESS XTLS را انتخاب کنید"
echo ""
