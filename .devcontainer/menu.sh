#!/bin/bash

# بارگذاری متغیرهای محیط
source /tmp/nikvpn-config.env 2>/dev/null
source /tmp/nikvpn-links.env 2>/dev/null

show_menu() {
    clear
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║            🔐 NikVPN Mobile - منوی کنترل                     ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  1️⃣  📱 نمایش لینک‌های کانفیگ و QR Codes"
    echo "  2️⃣  🎨 نمایش QR Codes (بزرگتر)"
    echo "  3️⃣  🔍 نمایش لاگ‌های Xray"
    echo "  4️⃣  🔄 شروع دوباره Xray"
    echo "  5️⃣  📊 وضعیت Xray"
    echo "  6️⃣  🖥️  ورود به tmux (پیشرفته)"
    echo "  0️⃣  ❌ خروج"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    read -p "  گزینه را انتخاب کنید: " choice
    echo ""
    
    case $choice in
        1)
            bash /usr/local/bin/show-configs.sh
            read -p "  برای ادامه Enter را فشار دهید..."
            show_menu
            ;;
        2)
            bash /usr/local/bin/generate-qr.sh
            read -p "  برای ادامه Enter را فشار دهید..."
            show_menu
            ;;
        3)
            clear
            echo "📋 لاگ‌های Xray (آخرین 50 خط):"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            tail -50 /tmp/xray.log 2>/dev/null || echo "فایل لاگ یافت نشد"
            echo ""
            read -p "  برای ادامه Enter را فشار دهید..."
            show_menu
            ;;
        4)
            echo "🔄 در حال راه‌اندازی مجدد Xray..."
            tmux kill-session -t nikvpn 2>/dev/null || true
            sleep 2
            bash /usr/local/bin/start.sh
            ;;
        5)
            clear
            echo "📊 وضعیت Xray:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            if pgrep -x "xray" > /dev/null; then
                echo "✅ Xray در حال اجرا است"
                echo ""
                echo "نشست‌های tmux:"
                tmux list-sessions
                echo ""
                echo "پروسس Xray:"
                ps aux | grep xray | grep -v grep
            else
                echo "❌ Xray در حال اجرا نیست"
            fi
            echo ""
            read -p "  برای ادامه Enter را فشار دهید..."
            show_menu
            ;;
        6)
            clear
            echo "🖥️  ورود به tmux..."
            echo "  • نمایش پنجره‌ها: tmux list-windows -t nikvpn"
            echo "  • ضمیمه شدن به نشست: tmux attach -t nikvpn"
            echo "  • خروج: Ctrl+B سپس D"
            echo ""
            tmux attach -t nikvpn
            show_menu
            ;;
        0)
            clear
            echo "👋 خداحافظ!"
            echo ""
            exit 0
            ;;
        *)
            echo "❌ گزینه نامعتبر!"
            sleep 2
            show_menu
            ;;
    esac
}

# اگر این اسکریپت مستقل اجرا شود
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    show_menu
fi
