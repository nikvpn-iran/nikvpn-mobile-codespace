#!/bin/bash

# بارگذاری لینک‌ها
source /tmp/nikvpn-links.env 2>/dev/null || {
    bash /usr/local/bin/show-configs.sh
    source /tmp/nikvpn-links.env
}

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║               📱 NikVPN Mobile - QR Codes                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# QR Code 1
echo "🔵 VLESS + xHTTP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${LINK_VLESS}" | qrencode -t ANSI -s 2 -m 2
echo ""

# QR Code 2
echo "🟢 VLESS + XTLS (بهتر)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${LINK_XTLS}" | qrencode -t ANSI -s 2 -m 2
echo ""
