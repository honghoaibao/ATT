#!/data/data/com.termux/files/usr/bin/bash

# --- CẤU HÌNH (HÃY SỬA LINK NÀY) ---
# Link đến repository chứa H-Tool.py và setup.py của bạn
GITHUB_REPO_URL="https://github.com/Huongdev2704/Setup_Tool" 
# Tên thư mục sẽ lưu tool (thường là tên repo)
TOOL_DIR_NAME="Setup_Tool"

echo "🚀 BẮT ĐẦU CÀI ĐẶT TOOL TỪ GITHUB..."

# 1. SETUP TERMUX (Cấp quyền & Cài Proot)
termux-setup-storage
pkg update -y && pkg upgrade -y
pkg install git proot-distro -y 

# 2. CÀI UBUNTU
if ! proot-distro list | grep -q "ubuntu (installed)"; then
    echo "⏳ Đang cài đặt Ubuntu..."
    proot-distro install ubuntu
fi

# 3. VÀO UBUNTU ĐỂ SETUP (Dùng EOF chuẩn để tránh lỗi dấu ngoặc)
echo "🔄 Đang kết nối vào Ubuntu..."
proot-distro login ubuntu -- bash << EOF

    # --- [BÊN TRONG UBUNTU] ---
    
    # 3.1. Cập nhật & Cài gói hệ thống cần thiết
    echo "📦 Cài đặt gói hệ thống (Git, Python, Tesseract OCR)..."
    apt update -y
    apt install python3 python3-pip python3-dev build-essential libssl-dev libffi-dev git tesseract-ocr libtesseract-dev -y

    # 3.2. Fix lỗi pip cũ
    echo "🛠 Cập nhật pip hệ thống..."
    python3 -m pip install --upgrade --ignore-installed pip setuptools wheel --break-system-packages

    # 3.3. Tải Tool từ GitHub
    cd /root
    if [ -d "$TOOL_DIR_NAME" ]; then
        echo "📂 Tool đã tồn tại, đang cập nhật phiên bản mới nhất..."
        cd "$TOOL_DIR_NAME"
        git pull
    else
        echo "⬇️ Đang tải tool về máy..."
        git clone "$GITHUB_REPO_URL" "$TOOL_DIR_NAME"
        cd "$TOOL_DIR_NAME"
    fi

    # 3.4. Chạy setup.py để cài thư viện Python
    echo "📦 Đang cài đặt thư viện Python (qua setup.py)..."
    if [ -f "setup.py" ]; then
        python3 setup.py
    else
        echo "⚠️ Lỗi: Không tìm thấy file setup.py trong thư mục tải về!"
    fi

    # 3.5. Hoàn tất
    echo "--------------------------------------------------"
    echo "✅ CÀI ĐẶT THÀNH CÔNG!"
    echo "👉 Để vào tool, hãy dùng lệnh sau:"
    echo "   proot-distro login ubuntu -- bash -c 'cd /root/$TOOL_DIR_NAME && python3 H-Tool.py'"
    echo "--------------------------------------------------"

EOF        cat > setup.py << 'PY_END'
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
