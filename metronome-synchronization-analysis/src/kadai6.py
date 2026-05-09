import cv2
import math
from pathlib import Path
import numpy as np

def calc_angle(centroid, pivot, frame_h):
    """
    centroid: (x, y) 重心
    pivot:    (px, py) 支点座標
    frame_h:  フレーム高さ
    return:   角度(deg) or None
    """
    if centroid is None:
        return None
    cx, cy = centroid
    px, py = pivot
    vx = cx - px
    vy = py - cy 

    if vy > 0:
        cosine_value = vy / math.sqrt(vx ** 2 + vy ** 2)
    else :
        cosine_value = -vy / math.sqrt(vx ** 2 + vy ** 2)
    theta = math.acos(cosine_value)
    
    if vx < 0:
        degree = -(math.degrees(theta))
    if vx >= 0:
        degree = math.degrees(theta)

    return degree

def draw_text_with_outline(frame, text, pos, font_scale, color, thickness):
    x, y = pos
    cv2.putText(frame, text, (x, y), cv2.FONT_HERSHEY_SIMPLEX,
                font_scale, (0, 0, 0), thickness + 4)
    cv2.putText(frame, text, (x, y), cv2.FONT_HERSHEY_SIMPLEX,
                font_scale, color, thickness)

# --- 設定セクション ---
SCRIPT_DIR    = Path(__file__).resolve().parent
VIDEO_PATH    = str(SCRIPT_DIR / '4623044_kadai6.MP4')
OUTPUT_PATH   = str(SCRIPT_DIR / '4623044_kadai6_result_5s.mp4')
OUTPUT_SECONDS = 5
SHOW_PREVIEW  = False
PRINT_ANALYSIS = False
START_FRAME   = 1600  # 読み始めのフレーム
times = []
angles1 = []
angles2 = []
angles3 = []
frame_idx = 0

# 各オブジェクトのpivot座標
PIVOT_M1      = (828, 564)   # メトロノーム1の支点
PIVOT_M2      = (1191, 542)   # メトロノーム2の支点
PIVOT_BOARD   = (530, 373)   # 板の支点


# メトロノーム貼紙（同色2箇所）のHSV範囲
STICKER_LOWER = np.array([160, 80, 90])
STICKER_UPPER = np.array([179, 180, 190])

# 板のHSV範囲
BOARD_LOWER   = np.array([10, 30, 100])
BOARD_UPPER   = np.array([80, 150, 220])

# ----------------------------------------------------------------
cap = cv2.VideoCapture(VIDEO_PATH)
if not cap.isOpened():
    raise FileNotFoundError(f"Cannot open video: {VIDEO_PATH}")

fps = cap.get(cv2.CAP_PROP_FPS)
if fps <= 0:
    raise ValueError(f"Invalid FPS: {fps}")
print(f"FPS = {fps:.2f}")
print(f"Saving result video to: {OUTPUT_PATH}")

# 開始フレームを設定
cap.set(cv2.CAP_PROP_POS_FRAMES, START_FRAME)

frame_w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
frame_h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
writer = cv2.VideoWriter(OUTPUT_PATH, fourcc, fps, (frame_w, frame_h))
if not writer.isOpened():
    raise RuntimeError(f"Cannot create output video: {OUTPUT_PATH}")

max_frames = round(fps * OUTPUT_SECONDS)
#初期化
prev_m1, prev_m2 = None, None
i = 1
frame_idx = 0
times = []

while i and frame_idx < max_frames:
    ret, frame = cap.read()
    if not ret:
        break
    
    frame_idx += 1
    t = frame_idx / fps
    times.append(t)
    frame_h, frame_w = frame.shape[:2]

    # BGR→HSV変換
    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)

    # --- メトロノーム貼紙 (同色2箇所) の検出 ---
    mask = cv2.inRange(hsv, STICKER_LOWER, STICKER_UPPER)
    mask = cv2.medianBlur(mask, 11)
    cnts, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    metro1_centroid = metro2_centroid = None
    if len(cnts) >= 2:
        # 面積トップ2の輪郭を取得
        top2 = sorted(cnts, key=cv2.contourArea, reverse=True)[:2]
        cents = []
        for c in top2:
            M = cv2.moments(c)
            if M['m00'] > 0:
                cx = int(M['m10'] / M['m00'])
                cy = int(M['m01'] / M['m00'])
                cents.append((cx, cy))
                x, y, w, h = cv2.boundingRect(c)
                cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 0, 255), 4)
        if prev_m1 is not None and prev_m2 is not None and len(cents) == 2:
            # 上フレームの M1 に近い方を新 M1 に
            d0 = (cents[0][0]-prev_m1[0])**2 + (cents[0][1]-prev_m1[1])**2
            d1 = (cents[1][0]-prev_m1[0])**2 + (cents[1][1]-prev_m1[1])**2
            if d0 < d1:
                metro1_centroid, metro2_centroid = cents[0], cents[1]
            else:
                metro1_centroid, metro2_centroid = cents[1], cents[0]
        else:
            # 初回または例外時は x 座標順
            metro1_centroid, metro2_centroid = sorted(cents, key=lambda p: p[0])
        #prev を更新
        prev_m1, prev_m2 = metro1_centroid, metro2_centroid

        # 描画
        cv2.circle(frame, metro1_centroid, 6, (0, 0, 255), -1)  # 赤
        cv2.circle(frame, metro2_centroid, 6, (0, 0, 255), -1)
        cv2.putText(frame, "M1", (metro1_centroid[0] + 10, metro1_centroid[1] - 10),
            cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
        cv2.putText(frame, "M2", (metro2_centroid[0] + 10, metro2_centroid[1] - 10),
            cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)


    # 板の検出
    mask_b = cv2.inRange(hsv, BOARD_LOWER, BOARD_UPPER)
    mask_b = cv2.medianBlur(mask_b, 11)
    cntb, _ = cv2.findContours(mask_b, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    board_centroid = None
    if cntb:
        c = max(cntb, key=cv2.contourArea)
        M = cv2.moments(c)
        if M['m00'] > 0:
            bx = int(M['m10'] / M['m00'])
            by = int(M['m01'] / M['m00'])
            board_centroid = (bx, by)
            cv2.circle(frame, board_centroid, 6, (255, 0, 0), -1)  # 青
            x, y, w, h = cv2.boundingRect(c)
            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 255), 4)
            
    if board_centroid is not None:
        cv2.circle(frame, board_centroid, 6,  (0, 255, 255), -1)
        cv2.putText(frame, "Board", (board_centroid[0] + 10, board_centroid[1] - 10),
                cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)


    # --- 角度計算 ---
    angle1 = calc_angle(metro1_centroid, PIVOT_M1, frame_h)
    angle2 = calc_angle(metro2_centroid, PIVOT_M2, frame_h)
    angle3 = calc_angle(board_centroid, PIVOT_BOARD, frame_h)
    angles1.append(angle1)
    angles2.append(angle2)
    angles3.append(angle3)
    
    if PRINT_ANALYSIS:
        print("="*40)
        print("時系列解析結果：")
        print(f"左メトロノーム角度 ={angle1:.2f}" if angle1 is not None else "左メトロノーム角度 = --")
        print(f"右メトロノーム角度 ={angle2:.2f}" if angle2 is not None else "右メトロノーム角度 = --")
        print(f"板の角度= {angle3:.2f}" if angle3 is not None else "板の角度= --")

    # --- 結果をテキスト表示 ---
    labels = [
        f"M1 Angle: {angle1:.1f}" if angle1 is not None else "M1 Angle: --",
        f"M2 Angle: {angle2:.1f}" if angle2 is not None else "M2 Angle: --",
        f"Board Angle: {angle3:.1f}" if angle3 is not None else "Board  : --"
    ]
    text_x = int(frame_w * 0.08)
    text_y = int(frame_h * 0.58)
    line_gap = 60
    for idx, txt in enumerate(labels):
        draw_text_with_outline(
            frame,
            txt,
            (text_x, text_y + idx * line_gap),
            1.35,
            (255, 255, 255),
            3
        )

    writer.write(frame)
    if SHOW_PREVIEW:
        cv2.imshow("Result", frame)
        #cv2.imshow("Mask_b",mask_b) 
        if cv2.waitKey(1) & 0xFF == 27:
            break

cap.release()
writer.release()
cv2.destroyAllWindows()
print(f"Saved {frame_idx / fps:.2f} seconds: {OUTPUT_PATH}")
