#!/bin/bash
set -e

echo "[NikVPN Mobile] 🚀 شروع راه‌اندازی..."

# دانلود آخرین نسخه Xray
LATEST=$(curl -sL "https://api.github.com/repos/XTLS/Xray-core/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)

if [ -z "$LATEST" ]; then
    LATEST="v1.8.10"
fi

TMPDIR="$(mktemp -d)"

echo "[NikVPN Mobile] ⬇️  در حال دانلود Xray ${LATEST}..."
curl -sL "https://github.com/XTLS/Xray-core/releases/download/${LATEST}/Xray-linux-64.zip" -o "${TMPDIR}/xray.zip"
unzip -q "${TMPDIR}/xray.zip" -d "${TMPDIR}"
install -m 755 "${TMPDIR}/xray" /usr/local/bin/xray

echo "[NikVPN Mobile] 📍 در حال دانلود GeoIP..."
curl -sL "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat" -o /usr/local/bin/geoip.dat

echo "[NikVPN Mobile] 🌐 در حال دانلود GeoSite..."
curl -sL "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat" -o /usr/local/bin/geosite.dat

# تولید دو UUID برای دو کانفیگ
UUID_VLESS=$(uuidgen)
UUID_XTLS=$(uuidgen)

echo "[NikVPN Mobile] 🔐 تولید UUIDs..."
echo "  • VLESS xHTTP: $UUID_VLESS"
echo "  • VLESS XTLS: $UUID_XTLS"

# کپی فایل‌های کانفیگ
cp /usr/local/bin/../share/config-vless-xhttp.json /etc/xray/config-vless-xhttp.json 2>/dev/null || {
    cat > /etc/xray/config-vless-xhttp.json << 'EOF'
{
  "log": {
    "loglevel": "warning",
    "access": "none",
    "error": "/tmp/xray-error.log"
  },
  "dns": {
    "servers": [
      {
        "address": "https://1.1.1.1/dns-query",
        "domains": ["geosite:geolocation-!cn"],
        "queryStrategy": "UseIP"
      },
      "8.8.8.8",
      "localhost"
    ],
    "queryStrategy": "UseIPv4"
  },
  "inbounds": [
    {
      "tag": "vless-in",
      "port": 443,
      "listen": "0.0.0.0",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "PLACEHOLDER_UUID_VLESS",
            "flow": "",
            "level": 0
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "tls",
        "tlsSettings": {
          "serverName": "PLACEHOLDER_SNI"
        },
        "xhttpSettings": {
          "mode": "packet-up",
          "path": "/",
          "maxUploadSize": 1000000,
          "maxConcurrentUploads": 10
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"],
        "routeOnly": false
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv4"
      }
    },
    {
      "tag": "block",
      "protocol": "blackhole",
      "settings": {
        "response": {
          "type": "http"
        }
      }
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "ip": ["geoip:private"],
        "outboundTag": "block"
      },
      {
        "type": "field",
        "protocol": ["bittorrent"],
        "outboundTag": "block"
      },
      {
        "type": "field",
        "domain": ["geosite:category-ads-all"],
        "outboundTag": "block"
      }
    ]
  },
  "policy": {
    "levels": {
      "0": {
        "handshake": 4,
        "connIdle": 300,
        "uplinkOnly": 2,
        "downlinkOnly": 5,
        "bufferSize": 512
      }
    }
  }
}
EOF
}

cat > /etc/xray/config-vless-xtls.json << 'EOF'
{
  "log": {
    "loglevel": "warning",
    "access": "none",
    "error": "/tmp/xray-error-optimized.log"
  },
  "dns": {
    "servers": [
      {
        "address": "https://1.1.1.1/dns-query",
        "domains": ["geosite:geolocation-!cn"],
        "queryStrategy": "UseIP"
      },
      {
        "address": "https://dns.quad9.net:5053/dns-query",
        "domains": ["geosite:cn"],
        "queryStrategy": "UseIPv4"
      },
      "8.8.8.8",
      "localhost"
    ],
    "queryStrategy": "UseIPv4"
  },
  "inbounds": [
    {
      "tag": "vless-xtls-in",
      "port": 8443,
      "listen": "0.0.0.0",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "PLACEHOLDER_UUID_XTLS",
            "flow": "xtls-rprx-vision",
            "level": 0
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "serverName": "PLACEHOLDER_SNI",
          "alpn": ["h2", "http/1.1"],
          "minVersion": "1.2",
          "cipherSuites": [
            "TLS_AES_256_GCM_SHA384",
            "TLS_CHACHA20_POLY1305_SHA256",
            "TLS_AES_128_GCM_SHA256"
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"],
        "routeOnly": false
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv4"
      }
    },
    {
      "tag": "block",
      "protocol": "blackhole",
      "settings": {
        "response": {
          "type": "http"
        }
      }
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "ip": ["geoip:private"],
        "outboundTag": "block"
      },
      {
        "type": "field",
        "protocol": ["bittorrent"],
        "outboundTag": "block"
      },
      {
        "type": "field",
        "domain": ["geosite:category-ads-all"],
        "outboundTag": "block"
      }
    ]
  },
  "policy": {
    "levels": {
      "0": {
        "handshake": 4,
        "connIdle": 300,
        "uplinkOnly": 2,
        "downlinkOnly": 5,
        "bufferSize": 1024,
        "statsUserUplink": false,
        "statsUserDownlink": false
      }
    },
    "system": {
      "statsInboundUplink": false,
      "statsInboundDownlink": false
    }
  }
}
EOF

# جایگزینی UUIDs
sed -i "s/PLACEHOLDER_UUID_VLESS/${UUID_VLESS}/" /etc/xray/config-vless-xhttp.json
sed -i "s/PLACEHOLDER_UUID_XTLS/${UUID_XTLS}/" /etc/xray/config-vless-xtls.json

# ذخیره UUIDs برای استفاده در show-configs
cat > /tmp/nikvpn-config.env << ENVEOF
export UUID_VLESS="${UUID_VLESS}"
export UUID_XTLS="${UUID_XTLS}"
ENVEOF

rm -rf "${TMPDIR}"
echo ""
echo "✅ [NikVPN Mobile] راه‌اندازی کامل شد!"
echo "   Xray ${LATEST} با موفقیت نصب شد"
echo ""
