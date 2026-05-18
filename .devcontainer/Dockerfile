FROM ubuntu:24.04

# تنظیمات سیستم
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    uuid-runtime \
    tmux \
    qrencode \
    jq \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# کپی فایل‌های setup
COPY setup.sh /usr/local/bin/setup.sh
COPY start.sh /usr/local/bin/start.sh
COPY show-configs.sh /usr/local/bin/show-configs.sh
COPY generate-qr.sh /usr/local/bin/generate-qr.sh
COPY menu.sh /usr/local/bin/menu.sh

# اعطای دسترسی اجرایی
RUN chmod +x /usr/local/bin/setup.sh \
    && chmod +x /usr/local/bin/start.sh \
    && chmod +x /usr/local/bin/show-configs.sh \
    && chmod +x /usr/local/bin/generate-qr.sh \
    && chmod +x /usr/local/bin/menu.sh

# ایجاد پوشه کانفیگ
RUN mkdir -p /etc/xray

# اجرای setup
RUN bash /usr/local/bin/setup.sh

# نقطه ورود پیش‌فرض
ENTRYPOINT ["/bin/bash"]
