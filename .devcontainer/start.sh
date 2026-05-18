#!/bin/bash

# بارگذاری تنظیمات
source /tmp/nikvpn-config.env 2>/dev/null || {
    UUID_VLESS=$(grep -o '"id": *"[^"]*"' /etc/xray/config-vless-xhttp.json 2>/dev/null | head -1 | grep -o '"[^"]*"$' | tr -d '"')
    UUID_XTLS=$(grep -o '"id": *"[^"]*"' /etc/xray/config-vless-xtls.json 2>/dev/null | head -1 | grep -o '"[^"]*"$' | tr -d '"')
}

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           🔐 NikVPN Mobile - Codespace 🚀                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# بررسی CODESPACE_NAME
if [ -z "$CODESPACE_NAME" ]; then
    echo "⚠️  CODESPACE_NAME یافت نشد. لطفاً در codespace کار کنید."
    exit 1
fi

SNI="${CODESPACE_NAME}-443.app.github.dev"

echo "📍 Codespace: $CODESPACE_NAME"
echo "🔗 Server: 94.130.50.12"
echo ""

# اگر Xray در حال اجرا است، متوقف کنید
tmux kill-session -t nikvpn 2>/dev/null || true

# ایجاد نشست tmux
tmux new-session -d -s nikvpn

# نمایش اختیارات انتخاب کانفیگ
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   کدام کانفیگ را می‌خواهید استفاده کنید؟"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1️⃣  VLESS + xHTTP (مورد استفاده موثر)"
echo "  2️⃣  VLESS + XTLS (بازدهی بالاتر)"
echo ""
read -p "  انتخاب کنید (1 یا 2): " CONFIG_CHOICE

case $CONFIG_CHOICE in
    1)
        CONFIG_FILE="/etc/xray/config-vless-xhttp.json"
        CONFIG_NAME="VLESS xHTTP"
        CONFIG_PORT="443"
        UUID=$UUID_VLESS
        ;;
    2)
        CONFIG_FILE="/etc/xray/config-vless-xtls.json"
        CONFIG_NAME="VLESS XTLS"
        CONFIG_PORT="8443"
        UUID=$UUID_XTLS
        ;;
    *)
        echo "❌ انتخاب نامعتبر!"
        exit 1
        ;;
esac

echo ""
echo "✅ شروع Xray با کانفیگ: $CONFIG_NAME"
echo ""

# ایجاد کانفیگ نهایی با SNI
sed "s/PLACEHOLDER_SNI/${SNI}/g" "$CONFIG_FILE" > /tmp/xray-final-config.json

# اجرای Xray
tmux send-keys -t nikvpn "sudo /usr/local/bin/xray run -c /tmp/xray-final-config.json &>/tmp/xray.log" Enter
sleep 2

# بررسی اینکه آیا Xray درست اجرا شد
if pgrep -x "xray" > /dev/null; then
    echo "✅ Xray با موفقیت اجرا شد!"
else
    echo "❌ خطا در اجرای Xray"
    echo "📋 لاگ ها:"
    cat /tmp/xray.log 2>/dev/null || echo "فایل لاگ دسترسی ندارد"
    exit 1
fi

# ایجاد نشست keepalive
tmux new-window -t nikvpn -n keepalive
tmux send-keys -t nikvpn:keepalive "while true; do curl -s --max-time 5 https://github.com/ -o /dev/null; sleep 180; done" Enter

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   🎉 راه‌اندازی کامل شد!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  📌 اطلاعات کانفیگ:"
echo "  • نام کانفیگ: $CONFIG_NAME"
echo "  • پورت: $CONFIG_PORT"
echo "  • UUID: $UUID"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# نمایش منوی اصلی
show-menu
