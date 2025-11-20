# ... (phần trên giữ nguyên)

proot-distro login ubuntu -- bash -c "
    apt update -y && apt upgrade -y
    apt install python3 python3-pip python3-dev build-essential libssl-dev libffi-dev -y

    # --- QUAN TRỌNG: Di chuyển đến thư mục chứa tool (ví dụ thư mục bạn mount hoặc clone) ---
    # Nếu tool nằm ngay thư mục gốc của user root thì không cần cd
    # cd /đường/dẫn/tới/thư/mục/chứa/setup.py 
    
    echo '📦 Đang cài đặt các thư viện Python...'
    pip3 install --upgrade cryptography requests curl_cffi tabulate beautifulsoup4 uiautomator2 colorama pystyle opencv-python-headless numpy termcolor --break-system-packages

    # Tạo flag báo đã xong
    echo 'Libraries installed' > libraries_installed.txt
    
    echo '✅ Setup hoàn tất.'
"
