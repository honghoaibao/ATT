#!/usr/bin/env python3
import os
import sys
import importlib.util
import subprocess

# Danh sách thư viện cần thiết cho Tool Auto TikTok
REQUIRED_LIBRARIES = [
    'cryptography', 'requests', 'curl_cffi', 'tabulate', 'beautifulsoup4',
    'uiautomator2', 'colorama', 'pystyle', 'opencv-python-headless', 'numpy', 
    'termcolor', 'adbutils', 'rich', 'pillow', 'pytesseract'
]

FLAG_FILE = "libraries_installed.txt"

def install(package):
    try:
        # Dùng sys.executable để đảm bảo cài đúng vào python đang chạy
        subprocess.check_call([sys.executable, "-m", "pip", "install", "--upgrade", package, "--break-system-packages"])
    except Exception as e:
        print(f"⚠️ Lỗi khi cài {package}: {e}")

def install_libraries():
    # Nếu đã có file flag thì bỏ qua (để mở tool cho nhanh)
    if os.path.exists(FLAG_FILE):
        return

    print("🚀 Lần đầu chạy tool, đang kiểm tra và cài đặt thư viện Python...")
    
    # Cài đặt từng thư viện
    for lib in REQUIRED_LIBRARIES:
        # Kiểm tra xem thư viện đã có chưa
        if importlib.util.find_spec(lib) is None:
            print(f"📦 Đang cài đặt: {lib}...")
            install(lib)
        else:
            print(f"✅ Đã có: {lib}")
    
    # Tạo file đánh dấu đã cài xong
    with open(FLAG_FILE, 'w') as f:
        f.write("Done")
    
    print("\n✅ TẤT CẢ THƯ VIỆN ĐÃ SẴN SÀNG!")
    print("👉 Vui lòng chạy lệnh: python3 H-Tool.py")
    sys.exit() # Thoát để người dùng tự chạy tool chính

if __name__ == "__main__":
    install_libraries()
