#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 BẮT ĐẦU CÀI ĐẶT H-TOOL..."

# 1. SETUP TERMUX
termux-setup-storage
pkg update -y && pkg upgrade -y
pkg install git proot-distro -y 

# 2. CÀI UBUNTU
if ! proot-distro list | grep -q "ubuntu (installed)"; then
    echo "⏳ Đang cài đặt Ubuntu..."
    proot-distro install ubuntu
fi

# 3. CẤU HÌNH (Dùng EOF để tránh lỗi ngoặc)
echo "🔄 Đang cấu hình môi trường..."
proot-distro login ubuntu -- bash << 'EOF'
    # Cài gói hệ thống
    apt update -y
    apt install python3 python3-pip python3-dev build-essential libssl-dev libffi-dev git tesseract-ocr libtesseract-dev -y

    # Fix lỗi pip
    echo '🛠 Cập nhật pip...'
    python3 -m pip install --upgrade --ignore-installed pip setuptools wheel --break-system-packages

    # Chạy setup.py (Nếu file nằm ở thư mục hiện tại khi bạn chạy lệnh curl/bash)
    # Lưu ý: Trong môi trường proot, thư mục /root là riêng biệt.
    # Script này chỉ cài thư viện môi trường. 
    
    echo '✅ Đã cài xong gói hệ thống Ubuntu!'
    echo '👉 Để chạy tool:'
    echo '1. proot-distro login ubuntu'
    echo '2. cd đến thư mục chứa tool (vd: /sdcard/Download/ToolHB)'
    echo '3. python3 setup.py (để cài lib python) hoặc python3 H-Tool.py'
EOF
