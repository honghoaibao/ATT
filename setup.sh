#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 BẮT ĐẦU CÀI ĐẶT H-TOOL..."

# --- PHẦN 1: SETUP TERMUX ---
termux-setup-storage
pkg update -y && pkg upgrade -y
# Chỉ cần cài gói này là đủ, không cần git clone proot-distro thủ công như script cũ
pkg install git proot-distro -y 

# --- PHẦN 2: CÀI UBUNTU ---
echo "⏳ Đang cài đặt hệ điều hành Ubuntu..."
proot-distro install ubuntu

# --- PHẦN 3: CẤU HÌNH MÔI TRƯỜNG BÊN TRONG UBUNTU ---
echo "🔄 Đang cài đặt các thư viện cần thiết..."
proot-distro login ubuntu -- bash -c "
    # 1. Cập nhật và cài các gói hệ thống quan trọng (Sửa lỗi không build được cryptography/adbutils)
    apt update -y
    apt install python3 python3-pip python3-dev build-essential libssl-dev libffi-dev git -y

    # 2. SỬA LỖI SETUPTOOLS (Quan trọng nhất)
    echo '🛠 Nâng cấp pip và setuptools để tránh lỗi build...'
    pip3 install --upgrade pip setuptools wheel --break-system-packages

    # 3. Cài đặt các thư viện cho Tool của bạn
    echo '📦 Đang cài đặt thư viện: cryptography, uiautomator2, numpy...'
    # Lưu ý: Thêm adbutils và pillow để chắc chắn
    pip3 install --upgrade cryptography requests curl_cffi tabulate beautifulsoup4 uiautomator2 colorama pystyle opencv-python-headless numpy termcolor adbutils --break-system-packages

    # 4. (Tuỳ chọn) Tải tool về nếu chưa có
    # cd /root
    # git clone https://github.com/Huongdev2704/TenRepoCuaBan.git (Thay link của bạn vào đây nếu muốn)

    echo '✅ CÀI ĐẶT HOÀN TẤT! MỞ TOOL NGAY:'
    echo '👉 python3 H-Tool.py'
"
