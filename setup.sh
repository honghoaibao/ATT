#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 BẮT ĐẦU CÀI ĐẶT H-TOOL (PHƯƠNG PHÁP AN TOÀN)..."

# 1. SETUP TERMUX
termux-setup-storage
pkg update -y && pkg upgrade -y
pkg install git proot-distro -y 

# 2. CÀI UBUNTU
if ! proot-distro list | grep -q "ubuntu (installed)"; then
    echo "⏳ Đang cài đặt Ubuntu..."
    proot-distro install ubuntu
fi

# 3. TẠO SCRIPT TẠM THỜI (Để tránh lỗi quote)
# Chúng ta ghi nội dung cần chạy vào file setup_internal.sh
cat > setup_internal.sh << 'END_SCRIPT'
    echo "🔄 Đang chạy cấu hình bên trong Ubuntu..."
    
    # Cài gói hệ thống
    apt update -y
    apt install python3 python3-pip python3-dev build-essential libssl-dev libffi-dev git tesseract-ocr libtesseract-dev -y

    # Fix lỗi pip
    echo "🛠 Cập nhật pip..."
    python3 -m pip install --upgrade --ignore-installed pip setuptools wheel --break-system-packages

    # Kiểm tra và chạy setup.py
    if [ -f setup.py ]; then
        echo "📦 Tìm thấy setup.py, đang chạy..."
        python3 setup.py
    else
        echo "⚠️ Không tìm thấy setup.py tại thư mục hiện tại."
        echo "⬇️ Đang tải setup.py mẫu..."
        # Tự tạo setup.py nếu thiếu (Dự phòng)
        cat > setup.py << 'PY_END'
import os, sys
os.system("pip install --upgrade cryptography requests curl_cffi tabulate beautifulsoup4 uiautomator2 colorama pystyle opencv-python-headless numpy termcolor adbutils rich pillow pytesseract --break-system-packages")
with open("libraries_installed.txt", "w") as f: f.write("Done")
PY_END
        python3 setup.py
    fi
    
    echo "✅ Cài đặt hoàn tất!"
END_SCRIPT

# 4. CHẠY SCRIPT TẠM BÊN TRONG UBUNTU
# Lệnh này sẽ đưa file setup_internal.sh vào ubuntu và chạy nó
chmod +x setup_internal.sh
proot-distro login ubuntu -- bash setup_internal.sh

# 5. DỌN DẸP
rm setup_internal.sh

echo "👉 Để chạy tool: proot-distro login ubuntu -- python3 H-Tool.py"
