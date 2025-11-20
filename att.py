#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
HB TOOL - Clean & Cool (Safe Logic Fix)
--------------------------------
Fix: Thêm xác minh User sau khi chuyển acc
"""

import subprocess, time, random, sys, io, re, os
from datetime import datetime, timedelta
from PIL import Image
import pytesseract
import cv2 
import numpy as np 

# --- Thư viện Rich ---
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.text import Text
from rich.progress import Progress, BarColumn, TextColumn, TimeRemainingColumn
from rich.style import Style
from rich import box

# --- CẤU HÌNH ---
HS_FB_X, HS_FB_Y = 970, 2323  # Tọa độ nút Hồ sơ (Góc phải dưới)
LST_ACC_X, LST_ACC_Y = 530, 580 # Tọa độ nút mở danh sách acc (Trên cùng)

console = Console()
# -------------------- GIAO DIỆN & HELPER --------------------
class Theme:
    PRIMARY = "bold #00BCD4"    # Màu chính (Xanh ngọc)
    SECONDARY = "bold #B0BEC5"  # Màu phụ (Xám xanh)
    ACCENT = "bold #4CAF50"     # Màu nhấn (Xanh lá)
    WARN = "#FF9800"            # Cảnh báo (Cam)
    ERR = "bold #F44336"        # Lỗi (Đỏ)
    
def clear_scr(): 
    os.system('cls' if os.name == 'nt' else 'clear')

def log(msg, style="white", icon="●"):
    t = datetime.now().strftime("%H:%M")
    console.print(f"[{Theme.SECONDARY}]{t}[/{Theme.SECONDARY}] [{style}]{icon} {msg}[/{style}]")
# -------------------- ADB & TỐI ƯU THIẾT BỊ --------------------
def adb(cmd):
    try:
        # Timeout 10s để tránh treo tool
        return subprocess.run(["adb"] + cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=10)
    except: return None

def is_adb():
    res = adb(["devices"])
    return bool(res and b"device" in res.stdout.split(b'\n')[1])

def cool_down(): 
    """Hạ độ sáng về 0 để mát máy"""
    adb(["shell", "settings", "put", "system", "screen_brightness", "0"])

def restore_light(): 
    """Khôi phục độ sáng"""
    adb(["shell", "settings", "put", "system", "screen_brightness", "150"])

def adb_tap(x, y): 
    adb(["shell", "input", "tap", str(x), str(y)])

def swipe_smooth():
    """Vuốt ngẫu nhiên để tránh bị phát hiện"""
    x, y1, y2 = 540 + random.randint(-20,20), 1500, 400
    adb(["shell", "input", "swipe", str(x), str(y1), str(x), str(y2), str(random.randint(250, 450))])
# -------------------- XỬ LÝ ẢNH & OCR --------------------
def ss():
    try:
        res = adb(["exec-out", "screencap", "-p"])
        return Image.open(io.BytesIO(res.stdout)) if res else None
    except: return None

def get_current_user_id():
    """
    Xác minh ID hiện tại (Cắt vùng nhỏ dưới avatar để OCR nhanh)
    """
    img = ss()
    if img is None: return ""
    w, h = img.size
    # Cắt vùng chứa ID (khoảng 20-80% chiều ngang, 12-25% chiều dọc)
    img_crop = img.crop((int(w*0.2), int(h*0.12), int(w*0.8), int(h*0.25)))
    
    try:
        config = '--psm 7 -c tessedit_char_whitelist=@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.'
        text = pytesseract.image_to_string(img_crop, config=config).strip()
        return re.sub(r'[^a-zA-Z0-9_.]', '', text).replace('@', '')
    except: return ""

def ocr_menu_list():
    """Quét danh sách khi menu thả xuống"""
    img = ss()
    if img is None: return [], []
    w, h = img.size
    img_c = img.crop((int(w*0.2), int(h*0.2), int(w*0.8), h)) 
    
    try:
        gray = cv2.cvtColor(np.array(img_c), cv2.COLOR_RGB2GRAY)
        _, thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)
        data = pytesseract.image_to_data(thresh, config='--psm 6', output_type=pytesseract.Output.DICT)
        
        accs, pos = [], []
        seen = set()
        for i, text in enumerate(data['text']):
            clean = re.sub(r'[^a-zA-Z0-9_.]', '', text.strip())
            if len(clean) > 3 and "add" not in clean.lower() and clean not in seen:
                accs.append(clean)
                # Tính lại tọa độ thực tế
                x = data['left'][i] + int(w*0.2) - 50
                y = data['top'][i] + data['height'][i]//2 + int(h*0.2)
                pos.append((x, y))
                seen.add(clean)
        return accs, pos
    except: return [], []
# -------------------- LOGIC CHUYỂN ACC (SAFE FIX) --------------------
def switch_account_safe(target_acc):
    target_clean = target_acc.replace('.','').replace('_','').lower()
    
    # Thử tối đa 2 lần nếu lỗi
    for attempt in range(2):
        log(f"Chuyển sang {target_acc} (Lần {attempt+1})...", Theme.SECONDARY)
        
        # 1. Về Profile
        adb_tap(HS_FB_X, HS_FB_Y) 
        time.sleep(2)
        
        # Check nếu đang ở đúng acc thì thôi
        if target_clean in get_current_user_id().lower():
             log("Đang ở đúng acc này rồi.", Theme.ACCENT, "✔")
             return True

        # 2. Mở list & OCR lại từ đầu
        adb_tap(LST_ACC_X, LST_ACC_Y) 
        time.sleep(2)
        curr_accs, curr_pos = ocr_menu_list()
        
        found_idx = -1
        for i, name in enumerate(curr_accs):
            if target_clean in name.replace('.','').replace('_','').lower():
                found_idx = i; break
        
        if found_idx != -1:
            # 3. Click & Chờ load
            x, y = curr_pos[found_idx]
            adb_tap(x, y)
            time.sleep(6)
            adb_tap(500, 1200) # Blind tap đóng popup
            
            # 4. VERIFY (Kiểm tra lại ID)
            adb_tap(HS_FB_X, HS_FB_Y); time.sleep(2)
            if target_clean in get_current_user_id().lower():
                log(f"Đã chuyển thành công sang {target_acc}", Theme.ACCENT, "✔")
                return True
            else:
                log(f"Chuyển hụt! Thử lại...", Theme.WARN, "⚠")
        else:
            log(f"Không thấy {target_acc} trong list.", Theme.WARN)
            adb(["shell", "input", "keyevent", "4"]) # Back
            time.sleep(1)
            
    return False
# -------------------- LOGIC NUÔI --------------------
def run_farm(acc, minutes, like_pct):
    end = datetime.now() + timedelta(minutes=minutes)
    swipes = likes = 0
    
    with Progress(
        TextColumn("[bold cyan]{task.fields[acc]}"),
        BarColumn(style="black", complete_style="cyan"),
        TimeRemainingColumn(),
        TextColumn("{task.fields[stat]}"),
        console=console
    ) as p:
        task = p.add_task("Run", total=int(minutes*60), acc=acc, stat="")
        
        while datetime.now() < end:
            # Xem video (Random 3-6 giây)
            time.sleep(random.uniform(3, 6)) 
            
            # Random Tim
            if random.random() < like_pct:
                adb_tap(1000, 1300); likes += 1
                time.sleep(0.5)
                
            swipe_smooth(); swipes += 1
            
            # Cập nhật thanh tiến trình
            remaining = (end - datetime.now()).total_seconds()
            p.update(task, completed=int(minutes*60) - remaining, stat=f"♥ {likes} | ⇧ {swipes}")
            
            if not is_adb(): break
    return swipes, likes
# -------------------- MAIN (ĐÃ FIX MỞ APP) --------------------
def main():
    console.print(Panel("[bold yellow]HB TOOL (SAFE MODE)[/bold yellow]", style=Theme.PRIMARY))
    
    if not is_adb(): return console.print("No ADB Device!", style=Theme.ERR)
    
    # --- BƯỚC FIX: MỞ APP TRƯỚC ---
    log("Đang mở TikTok để khởi tạo...", Theme.PRIMARY)
    adb(["shell", "monkey", "-p", "com.zhiliaoapp.musically", "-c", "android.intent.category.LAUNCHER", "1"])
    
    # Chờ 10s cho app load xong hẳn (Feed hiện lên)
    with Progress(SpinnerColumn(), TextColumn("[progress.description]{task.description}"), transient=True) as progress:
        progress.add_task("Đang đợi TikTok load...", total=None)
        time.sleep(10) 
    # -------------------------------

    # Sau khi app lên rồi mới bắt đầu quét
    log("Bắt đầu quét danh sách...", Theme.SECONDARY)
    cool_down() # Kích hoạt chế độ mát máy
    
    # Quy trình vào menu chuyển acc
    adb_tap(HS_FB_X, HS_FB_Y) # Tap Hồ sơ
    time.sleep(3)             # Chờ vào trang hồ sơ
    adb_tap(LST_ACC_X, LST_ACC_Y) # Tap tên acc
    time.sleep(3)             # Chờ xổ list
    
    # Bắt đầu OCR
    accs, _ = ocr_menu_list()
    
    if not accs: 
        restore_light(); return console.print("OCR Failed - Không thấy acc nào (Check lại tọa độ hoặc ngôn ngữ máy)", style=Theme.ERR)
    
    console.print(f"List Acc: {accs}")
    adb(["shell", "am", "force-stop", "com.zhiliaoapp.musically"])
    
    # Vòng lặp nuôi từng acc
    for acc in accs:
        console.rule(f"[bold]Account: {acc}[/bold]")
        
        # Mở lại app để nuôi
        adb(["shell", "monkey", "-p", "com.zhiliaoapp.musically", "-c", "android.intent.category.LAUNCHER", "1"])
        time.sleep(8) # Chờ app lên
        
        if switch_account_safe(acc):
            # Cấu hình: 2 phút/acc, 50% tỉ lệ tim
            run_farm(acc, 2.0, 0.5) 
        else:
            log(f"Skip {acc} do lỗi chuyển.", Theme.ERR)
            
        adb(["shell", "am", "force-stop", "com.zhiliaoapp.musically"])
        time.sleep(3) # Nghỉ 3s cho máy nguội bớt

    restore_light()
    console.print("Done.", style=Theme.ACCENT)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        restore_light()
        print("\nĐã dừng tool.")
