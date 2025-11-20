#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 BẮT ĐẦU CÀI ĐẶT H-TOOL (PHIÊN BẢN FIX LỖI)..."

# 1. SETUP TERMUX
termux-setup-storage
pkg update -y && pkg upgrade -y
pkg install git proot-distro -y 

# 2. CÀI UBUNTU
echo "⏳ Đang cài đặt hệ điều hành Ubuntu..."
proot-distro install ubuntu

# 3. CẤU HÌNH MÔI TRƯỜNG BÊN TRONG UBUNTU
echo "🔄 Đang cài đặt các thư viện cần thiết..."
proot-distro login ubuntu -- bash -c "
    # Cài gói hệ thống
    apt update -y
    apt install python3 python3-pip python3-dev build-essential libssl-dev libffi-dev git -y

    # --- [SỬA LỖI RECORD FILE TẠI ĐÂY] ---
    # Thêm --ignore-installed để ghi đè lên bản pip/cryptography của hệ thống mà không cần uninstall
    
    echo '🛠 Cập nhật pip và công cụ build (Force Install)...'
    python3 -m pip install --upgrade --ignore-installed pip setuptools wheel --break-system-packages

    echo '📦 Đang cài đặt thư viện (Fix lỗi cryptography)...'
    python3 -m pip install --upgrade --ignore-installed cryptography requests curl_cffi tabulate beautifulsoup4 uiautomator2 colorama pystyle opencv-python-headless numpy termcolor adbutils --break-system-packages

    echo 'Libraries installed' > libraries_installed.txt

    echo '✅ CÀI ĐẶT THÀNH CÔNG!'
    echo '👉 Chạy tool bằng lệnh: (proot-distro login ubuntu -- bash -c "cd /sdcard/download/toolhb && python3 att.py")'
"
