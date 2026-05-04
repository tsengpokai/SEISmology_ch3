#!/usr/bin/env bash
set -e
mkdir -p src .github/workflows

cat > 'index.html' <<'EOF_index_html'
<!doctype html>
<html lang="zh-Hant">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>震探地心 SeismoCore Explore</title>
    <meta name="description" content="地震學第三章：地震波與地球結構互動式教學網頁" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700;800&family=Source+Serif+4:opsz,wght@8..60,400;8..60,600;8..60,700&display=swap" rel="stylesheet">
    <script>
      window.MathJax = {
        tex: { inlineMath: [['$', '$'], ['\\(', '\\)']], displayMath: [['$$', '$$'], ['\\[', '\\]']] },
        svg: { fontCache: 'global' },
        options: { skipHtmlTags: ['script', 'noscript', 'style', 'textarea', 'pre', 'code'] }
      };
    </script>
    <script defer src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js"></script>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>

EOF_index_html

cat > 'vite.config.js' <<'EOF_vite_config_js'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// base: './' 讓專案可以直接部署到 GitHub Pages 的任意 repo 路徑。
export default defineConfig({
  plugins: [react()],
  base: './',
  server: {
    host: '0.0.0.0',
    port: 5173
  }
});

EOF_vite_config_js

cat > 'package.json' <<'EOF_package_json'
{
  "name": "seismocore-explore",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite --host 0.0.0.0",
    "build": "vite build",
    "preview": "vite preview --host 0.0.0.0"
  },
  "dependencies": {
    "@vitejs/plugin-react": "latest",
    "vite": "latest",
    "react": "latest",
    "react-dom": "latest"
  },
  "devDependencies": {}
}

EOF_package_json

cat > 'README.md' <<'EOF_README_md'
# 震探地心 SeismoCore Explore

互動式教學網頁：**地震學第三章：地震波與地球結構**。本專案使用 Vite + React，適合 GitHub Codespaces、GitHub Pages 與一般靜態網站部署。

## 功能總覽

- 母導覽頁：地球剖面 SVG、第三章關鍵三問、8 個章節入口。
- 3.1–3.8 子章節：每節包含重點摘要、公式、教授小提醒、收納式重點整理、互動模擬與小測驗。
- 互動模擬：
  - 3.1 解析度比較器
  - 3.2 折射/反射 T-x 走時沙盒
  - 3.3 反射雙曲線、NMO 與 Dix 方程式實驗
  - 3.4 球體地球射線彎曲與最深點
  - 3.5 體波相位點擊挑戰
  - 3.6 SPO/LPO 與剪力波分裂
  - 3.7 Q 值與距離控制的衰減模擬
  - 3.8 密度、壓力與地球層圈互動圖
- Seismo-Code Lab：使用 Pyodide + NumPy + Matplotlib 在瀏覽器內產生 synthetic record section。
- 支援 MathJax LaTeX、深色/淺色模式、響應式版面。

## 在 Codespaces 或本機啟動

```bash
npm install
npm run dev
```

接著開啟 Vite 顯示的網址。若使用 Codespaces，請在 Ports 面板開啟 `5173`。

## 打包

```bash
npm run build
```

輸出會在 `dist/`。

## 部署到 GitHub Pages

方式一：使用本專案附的 GitHub Actions

1. 將整個資料夾推送到 GitHub repo。
2. 到 repo 的 `Settings > Pages`。
3. Source 選 `GitHub Actions`。
4. 推送到 `main` 後會自動 build 並部署。

方式二：手動部署

```bash
npm install
npm run build
```

把 `dist/` 內容放到 GitHub Pages 指定分支或靜態網站空間。

## Seismo-Code Lab 注意事項

瀏覽器端不能保證安裝完整 ObsPy，因此網頁內建的 Lab 使用 NumPy/Matplotlib 生成類似 record section 的合成波形，用於教學展示。若要處理真實 SAC 檔案，請在本機 Python 環境執行 `local_obspy_plot.py`，流程包含：

- 使用 `obspy.read("*Z.D*.SAC")` 讀取垂直分量。
- 以 HHZ > EHZ > HLZ/HNZ 的優先順序做測站去重。
- 截取發震前後時間窗、demean、bandpass、必要時降採樣。
- 從 SAC header 的 `dist`、`gcarc` 或測站/震央座標取得震央距。
- 使用 `X = distance + normalized_amplitude * amp_scale` 繪製 record section。

## 主要檔案

```text
index.html
vite.config.js
package.json
src/main.jsx
src/App.jsx
src/styles.css
local_obspy_plot.py
.github/workflows/deploy.yml
```

EOF_README_md

cat > 'local_obspy_plot.py' <<'EOF_local_obspy_plot_py'
"""Local SAC record-section plotting script.

This script is designed for a local Python environment with ObsPy installed.
Edit data_dir and event_time before running.
"""

from pathlib import Path
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from obspy import read, UTCDateTime
from obspy.geodetics import locations2degrees

# ===== Edit these values =====
event_time = UTCDateTime(2026, 5, 1, 12, 39, 55)
data_dir = Path(r"c:\Users\kyle0\Desktop\seismoiogy_ch3\20260501123955_CWASN")
file_pattern = str(data_dir / "*Z.D*.SAC")
output_path = data_dir.parent / "record_section.png"
amp_scale = 8.0
freqmin, freqmax = 0.5, 5.0
# =============================

print("Reading SAC files...", flush=True)
st = read(file_pattern)
print("Total Z-component traces loaded:", len(st), flush=True)

# Keep the best Z component per station: HHZ > EHZ > HLZ/HNZ > others
station_dict = {}
for tr in st:
    sta = tr.stats.station
    chan = tr.stats.channel
    priority = 0
    if chan.endswith("Z"):
        if chan.startswith("HH"):
            priority = 3
        elif chan.startswith("EH"):
            priority = 2
        elif chan.startswith(("HL", "HN")):
            priority = 1
    if sta not in station_dict or priority > station_dict[sta][1]:
        station_dict[sta] = (tr, priority)

traces = [item[0] for item in station_dict.values()]
print("Unique stations selected:", len(traces), flush=True)

start_trim = event_time - 10
end_trim = event_time + 120
valid = []
for tr in traces:
    tr = tr.copy()
    tr.trim(start_trim, end_trim)
    if tr.stats.npts < 10 or len(tr.data) == 0:
        continue
    tr.detrend("demean")
    tr.filter("bandpass", freqmin=freqmin, freqmax=freqmax)
    if tr.stats.sampling_rate > 20.0:
        factor = int(tr.stats.sampling_rate / 10.0)
        if factor > 1:
            tr.decimate(factor=factor, no_filter=True)
    valid.append(tr)

print("Traces after trim/filter:", len(valid), flush=True)

plot_data = []
for tr in valid:
    dist_km = None
    if hasattr(tr.stats, "sac"):
        sac = tr.stats.sac
        if hasattr(sac, "dist") and sac.dist != -12345.0:
            dist_km = sac.dist
        elif hasattr(sac, "gcarc") and sac.gcarc != -12345.0:
            dist_km = sac.gcarc * 111.19
        elif (
            hasattr(sac, "stla") and hasattr(sac, "evla") and
            sac.stla != -12345.0 and sac.evla != -12345.0
        ):
            deg = locations2degrees(sac.evla, sac.evlo, sac.stla, sac.stlo)
            dist_km = deg * 111.19

    if dist_km is None or len(tr.data) == 0:
        continue
    max_amp = max(abs(tr.data.max()), abs(tr.data.min()))
    if max_amp <= 0:
        continue
    norm_data = tr.data / max_amp
    time_offset = tr.stats.starttime - event_time
    times = tr.times() + time_offset
    plot_data.append((dist_km, norm_data, times, tr.stats.station))

plot_data.sort(key=lambda row: row[0])
print("Valid traces to plot:", len(plot_data), flush=True)

colors = [
    "#CC0000", "#FF8C00", "#006400", "#4169E1", "#8B008B",
    "#000000", "#B22222", "#87CEEB", "#228B22", "#FF4500",
]
fig, ax = plt.subplots(figsize=(14, 9))
ax.set_title(str(event_time) + " (UTC)", fontsize=16, fontweight="bold", pad=30)
ax.set_xlabel("Distance (km)", fontsize=13)
ax.set_ylabel("Time after origin (s)", fontsize=13)

for i, (dist_km, norm_data, times, sta_name) in enumerate(plot_data):
    color = colors[i % len(colors)]
    x = dist_km + norm_data * amp_scale
    ax.plot(x, times, color=color, linewidth=0.5)
    ax.text(dist_km, -2, sta_name, fontsize=5, color=color,
            ha="center", va="bottom", rotation=90, fontweight="bold")

ax.set_xlim(0, 400)
ax.set_ylim(0, 115)
ax.grid(True, linestyle="-", alpha=0.3, color="gray")
ax.set_yticks(range(0, 120, 10))
fig.patch.set_facecolor("white")
ax.set_facecolor("white")
for spine in ax.spines.values():
    spine.set_edgecolor("black")
    spine.set_linewidth(0.8)

fig.savefig(output_path, dpi=200, bbox_inches="tight", facecolor="white")
plt.close(fig)
print("Done. Image saved to:", output_path, flush=True)

EOF_local_obspy_plot_py

cat > 'src/main.jsx' <<'EOF_src_main_jsx'
import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.jsx';
import './styles.css';

createRoot(document.getElementById('root')).render(<App />);

EOF_src_main_jsx

cat > 'src/App.jsx' <<'EOF_src_App_jsx'
import React, { useEffect, useMemo, useRef, useState } from 'react';

const modules = [
  {
    id: '3.1',
    hash: 'm31',
    title: '3.1 簡介',
    subtitle: '為什麼地震波像地球的 X 光？',
    icon: '◎',
    depth: '0–660 km',
    accent: '#67e8f9',
    summary: '地震學利用波速、振幅與走時，推估地球內部的彈性性質與分層結構；相比重力與磁力，它能提供更高解析度的深部影像。',
    formula: '$T(s,r)=\\\\int_s^r \\\\frac{1}{v(x)}\\\\,dx$',
    formulaLabel: '走時是射線路徑上慢度的積分',
    note: '測站真正量到的是「到達時間」，扣掉發震時間後才是走時。單一走時只能告訴我們整條路徑的平均效果，所以必須用大量測站與大量地震一起反推。',
    bullets: [
      '地震波速與彈性性質是建立地球結構模型的核心。',
      'P 波與 S 波在不同材料中的傳播差異，可以指出固態、液態與不連續面。',
      '正向問題是已知速度求走時；逆向問題是由走時反推速度，較困難但最關鍵。',
      '本章從平坦分層、球體地球、非均向性、衰減到地函地核成分逐步展開。'
    ],
    quiz: {
      question: '為什麼地震學比重力、磁力資料更能限制核幔邊界？',
      options: ['因為地震波對速度與介面跳變很敏感', '因為地震波只在空氣中傳播', '因為重力資料不受密度控制'],
      answer: 0,
      explain: 'P、S 波在核幔邊界附近的速度與可傳播性會劇烈改變，能直接限制邊界深度與物性。'
    },
    component: 'resolution'
  },
  {
    id: '3.2',
    hash: 'm32',
    title: '3.2 折射震測法',
    subtitle: '直接波、反射波、頭波如何在 T-x 圖上分家？',
    icon: '∿',
    depth: '地殼—上部地函',
    accent: '#38bdf8',
    summary: '折射震測利用速度較快下層產生的臨界折射與頭波，從走時曲線的斜率與截距求出地層速度與厚度。',
    formula: '$T_D=\\\\frac{x}{v_0},\\\\quad T_R=\\\\frac{2\\\\sqrt{(x/2)^2+h_0^2}}{v_0},\\\\quad T_H=\\\\frac{x}{v_1}+\\\\tau_1$',
    formulaLabel: '直接波、反射波與頭波走時',
    note: '把 T-x 圖想成賽跑紀錄：近距離直接波最快；距離夠遠後，頭波雖然一開始多繞了一段，但因為在高速層奔跑，最後會反超成為初達波。',
    bullets: [
      '頭波出現的條件是 $v_1>v_0$，且入射角達到臨界角 $\\\\sin i_c=v_0/v_1$。',
      '直接波斜率為 $1/v_0$；頭波斜率為 $1/v_1$，所以高速層線段更平。',
      '傾斜層需要做逆向剖面，用 up-dip 與 down-dip 的視速度反推真實速度與傾角。',
      '低速層與薄層可能形成盲區，使初達波方法低估或漏判構造。'
    ],
    quiz: {
      question: '若地下第二層速度低於第一層，傳統折射震測最容易出現什麼問題？',
      options: ['無法形成可判讀的臨界折射頭波', '所有波都會變成 S 波', '走時永遠等於零'],
      answer: 0,
      explain: '低速層不滿足高速下層的臨界折射條件，因此可能不會在初達走時中被看見。'
    },
    component: 'refraction'
  },
  {
    id: '3.3',
    hash: 'm33',
    title: '3.3 反射震測法',
    subtitle: '用雙曲線、NMO 與 Dix 方程式拆解地下速度',
    icon: '⌁',
    depth: '沉積盆地—深部地殼',
    accent: '#22d3ee',
    summary: '反射震測觀察地下介面反射回來的波，透過雙曲線走時、NMO 校正、CMP 疊加與 Dix 方程式得到速度與構造影像。',
    formula: '$T(x)^2=t_0^2+\\\\frac{x^2}{v_{rms}^2},\\\\quad v_n^2=\\\\frac{V_{rms,n}^2t_n-V_{rms,n-1}^2t_{n-1}}{t_n-t_{n-1}}$',
    formulaLabel: '反射雙曲線與 Dix 層速度公式',
    note: '反射震測像是用回音定位地下界面。偏移距越大，回音會晚一點到，這個晚到量就是 NMO；校正後把很多回音疊起來，真實反射會變清楚，雜訊會被平均掉。',
    bullets: [
      '水平單層反射走時在 T-x 圖上呈雙曲線。',
      'NMO 校正後進行 CMP 疊加，可增強反射訊號並壓低隨機雜訊。',
      'Dix 方程式能由 RMS 速度逐層反推 interval velocity。',
      '偏移歸位 migration 可把傾斜地層或繞射訊號搬回較接近真實的位置。'
    ],
    quiz: {
      question: '反射波在 T-x 圖上最典型的形狀是什麼？',
      options: ['雙曲線', '完全水平線', '隨機鋸齒線'],
      answer: 0,
      explain: '水平層反射走時滿足 $T(x)^2=t_0^2+x^2/v^2$，所以是雙曲線。'
    },
    component: 'reflection'
  },
  {
    id: '3.4',
    hash: 'm34',
    title: '3.4 球體地球中的地震波',
    subtitle: '射線參數 p 如何決定最深點？',
    icon: '◌',
    depth: '全球尺度',
    accent: '#818cf8',
    summary: '當距離超過數百公里，地球曲率不可忽略；球體 Snell 定律中的射線參數 $p=r\\\\sin i/v$ 會控制波線彎曲與最深點。',
    formula: '$p=\\\\frac{r\\\\sin i}{v},\\\\quad p=\\\\frac{dT}{d\\\\Delta}$',
    formulaLabel: '球體地球的射線參數與走時曲線斜率',
    note: 'p 可以想成一條波線的身分證。p 大的射線比較貼近地表，p 小的射線下潛較深；速度隨深度增加時，射線會逐漸彎回地表。',
    bullets: [
      '球體模型中的 Snell 定律多了半徑 $r$，所以與平坦分層不同。',
      '當入射角到達 $90^\\\\circ$，射線到達最深點並折返。',
      '高速跳躍可能造成 triplication 與 caustic，低速層可能形成 shadow zone。',
      'Herglotz-Wiechert 積分可由走時曲線反推徑向速度，但低速層會造成困難。'
    ],
    quiz: {
      question: '在球體地球中，射線到達最深點時入射角約為多少？',
      options: ['90°', '0°', '360°'],
      answer: 0,
      explain: '最深點又稱 turning point，此時射線方向近似水平，入射角達 $90^\\\\circ$。'
    },
    component: 'spherical'
  },
  {
    id: '3.5',
    hash: 'm35',
    title: '3.5 體波走時研究',
    subtitle: 'P、S、PP、PcP、PKP：相位名稱就是路徑履歷',
    icon: '⟲',
    depth: '地函—地核',
    accent: '#a78bfa',
    summary: '全球體波走時資料建立了 JB、IASP91、PREM 等參考模型，也用相位命名規則描述波是否反射、穿核或繞射。',
    formula: '$P, S, PP, PcP, PKP, PKIKP, Pdiff$',
    formulaLabel: '常見體波相位名稱',
    note: '相位名稱不是亂碼，而是旅行紀錄。P 表示 P 波、S 表示 S 波、c 表示核幔邊界反射、K 表示穿過外核、I 表示穿過內核。',
    bullets: [
      '410 km 與 660 km 附近的速度跳躍對應地函過渡帶礦物相變。',
      'CMB 約 2890 km 深，P 波速度驟降、S 波消失，是外核為液態的重要證據。',
      'P 波陰影區約在 98°–145°，PKP 則在更遠距離重新出現。',
      'pP 與 P 的走時差常用於估算深層地震震源深度。'
    ],
    quiz: {
      question: 'PKP 中的 K 代表什麼？',
      options: ['波穿過外地核', '波停在地殼', '波變成表面波'],
      answer: 0,
      explain: 'K 代表 Kern/Core，也就是 P 波進入外地核後再回到地函。'
    },
    component: 'bodywaves'
  },
  {
    id: '3.6',
    hash: 'm36',
    title: '3.6 非均向性地球結構',
    subtitle: '同一塊岩石，不同方向竟然跑不一樣快',
    icon: '◇',
    depth: '地殼—上部地函',
    accent: '#f0abfc',
    summary: '真實地球常非均向，波速會隨傳播方向或偏振方向改變；SPO 與 LPO 是主要成因，剪力波分裂是重要觀測。',
    formula: '$v_{fast}>v_{slow},\\\\quad \\\\delta t=L\\\\left(\\\\frac{1}{v_{slow}}-\\\\frac{1}{v_{fast}}\\\\right)$',
    formulaLabel: '剪力波快慢分裂與時間差',
    note: '非均向性像木紋：沿著紋理與垂直紋理敲下去，反應不同。地函中橄欖石晶格排列會記錄地函流動方向，因此剪力波分裂能幫我們看見深部變形。',
    bullets: [
      'SPO 來自巨觀層理、葉理或平行裂隙。',
      'LPO 來自微觀礦物晶格在應力與流動下的排列。',
      '完全非均向性最多需要 21 個獨立彈性常數；橫向等向性常用 5 個常數描述。',
      '海洋上部地函的 Pn 快速方位常與海底擴張方向平行。'
    ],
    quiz: {
      question: '剪力波進入非均向介質後，最典型的現象是？',
      options: ['分裂成快波與慢波', '完全消失', '變成重力異常'],
      answer: 0,
      explain: '兩個垂直偏振方向速度不同，因此會分裂並產生抵達時間差。'
    },
    component: 'anisotropy'
  },
  {
    id: '3.7',
    hash: 'm37',
    title: '3.7 衰減與非彈性',
    subtitle: '波為什麼越傳越小、越傳越鈍？',
    icon: '≈',
    depth: '全地球',
    accent: '#fb7185',
    summary: '地震波振幅會因幾何擴散、聚焦/散焦、散射與非彈性衰減而變小；其中非彈性會把能量真正轉成熱。',
    formula: '$A(t)=A_0e^{-\\\\omega_0t/2Q},\\\\quad E(t)=E_0e^{-\\\\omega_0t/Q}$',
    formulaLabel: '品質因子 Q 控制非彈性衰減',
    note: 'Q 值像「保鮮度」。Q 高表示波形比較能維持，Q 低表示能量容易被內部摩擦吃掉，高頻成分會特別快消失。',
    bullets: [
      '幾何擴散是能量攤大，不是總能量消失。',
      '散射會把能量丟到晚到的尾波中。',
      '非彈性是唯一真正把機械能轉成熱的衰減機制。',
      '衰減對溫度與流體非常敏感，可用來尋找高溫或含流體區域。'
    ],
    quiz: {
      question: '哪一種衰減機制會讓地震波總能量真正轉成熱？',
      options: ['非彈性衰減', '幾何擴散', '單純座標軸縮放'],
      answer: 0,
      explain: '非彈性衰減包含內部摩擦、晶粒邊界滑動等，會把機械能轉成熱能。'
    },
    component: 'attenuation'
  },
  {
    id: '3.8',
    hash: 'm38',
    title: '3.8 地函與地核組成',
    subtitle: '從密度、壓力與轉動慣量拼出地球材料',
    icon: '●',
    depth: '0–6371 km',
    accent: '#fbbf24',
    summary: '要從波速走到成分解釋，必須結合平均密度、轉動慣量、Adams-Williamson 方程式、壓力與礦物相變。',
    formula: '$\\\\frac{d\\\\rho}{dr}=-\\\\frac{\\\\rho(r)g(r)}{\\\\Phi(r)},\\\\quad \\\\Phi=\\\\alpha^2-\\\\frac{4}{3}\\\\beta^2=K/\\\\rho$',
    formulaLabel: 'Adams-Williamson 方程式',
    note: '地球平均密度約 5.5 g/cm³，但地表岩石約 3 g/cm³，表示深部一定有更重的材料。轉動慣量小於均勻球，也證明質量集中在地心附近。',
    bullets: [
      '地球質量約 $5.97\\\\times10^{24}$ kg，平均密度約 5.5 g/cm³。',
      '無因次轉動慣量 $C/Ma^2\\\\approx0.33$，低於均勻球的 0.4，顯示質量向中心集中。',
      '410 km 與 660 km 密度跳躍與礦物相變有關，不只是壓力壓縮。',
      'CMB 的密度跳躍極大，地函底部到外核頂部約由 5.57 躍至 9.90 g/cm³。'
    ],
    quiz: {
      question: '若地球是完全均勻球體，$C/Ma^2$ 約為多少？',
      options: ['0.4', '0.03', '1.4'],
      answer: 0,
      explain: '均勻球體的無因次轉動慣量約 0.4；地球約 0.33，表示質量更集中在內部。'
    },
    component: 'composition'
  }
];

const phaseInfo = {
  P: 'P：只以 P 波形式穿越地函，是最基本的直達體波。',
  S: 'S：剪力波，只能在固體中傳播，外地核為液態所以 S 波不能穿過外核。',
  PP: 'PP：P 波在地表反射一次後再抵達測站。',
  PcP: 'PcP：P 波在核幔邊界 CMB 反射後返回地表。',
  PKP: 'PKP：P 波進入外核（K）後再回到地函，是穿核相位。',
  PKIKP: 'PKIKP：P 波穿過外核與內核，是研究內核的重要相位。',
  Pdiff: 'Pdiff：P 波沿著核幔邊界繞射，常與陰影區邊緣有關。'
};

function useHashRoute() {
  const [hash, setHash] = useState(() => window.location.hash.replace('#', '') || 'dashboard');
  useEffect(() => {
    const onHash = () => setHash(window.location.hash.replace('#', '') || 'dashboard');
    window.addEventListener('hashchange', onHash);
    return () => window.removeEventListener('hashchange', onHash);
  }, []);
  const navigate = (next) => {
    window.location.hash = next;
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };
  return [hash, navigate];
}

function useMathJax(deps = []) {
  useEffect(() => {
    const id = window.setTimeout(() => {
      if (window.MathJax?.typesetPromise) window.MathJax.typesetPromise().catch(() => {});
    }, 80);
    return () => window.clearTimeout(id);
  }, deps);
}

function App() {
  const [hash, navigate] = useHashRoute();
  const [theme, setTheme] = useState(() => localStorage.getItem('seismocore-theme') || 'dark');
  const activeModule = modules.find((m) => m.hash === hash);

  useEffect(() => {
    document.documentElement.dataset.theme = theme;
    localStorage.setItem('seismocore-theme', theme);
  }, [theme]);

  useMathJax([hash, theme]);

  return (
    <div className="app-shell">
      <WaveBackground />
      <TopBar
        active={activeModule?.hash || 'dashboard'}
        navigate={navigate}
        theme={theme}
        setTheme={setTheme}
      />
      <main>
        {activeModule ? (
          <ModulePage module={activeModule} navigate={navigate} />
        ) : (
          <Dashboard navigate={navigate} />
        )}
      </main>
      <Footer />
    </div>
  );
}

function WaveBackground() {
  return (
    <div className="ambient" aria-hidden="true">
      <div className="ambient-grid" />
      <svg className="ambient-wave" viewBox="0 0 1200 600" preserveAspectRatio="none">
        {Array.from({ length: 9 }).map((_, i) => (
          <path
            key={i}
            d={`M 0 ${120 + i * 42} C 220 ${40 + i * 28}, 320 ${230 + i * 25}, 520 ${140 + i * 28} S 830 ${80 + i * 34}, 1200 ${170 + i * 36}`}
            className="ambient-line"
          />
        ))}
      </svg>
    </div>
  );
}

function TopBar({ active, navigate, theme, setTheme }) {
  return (
    <header className="topbar glass">
      <button className="brand" onClick={() => navigate('dashboard')} aria-label="回到首頁">
        <span className="brand-mark">S</span>
        <span>
          <strong>震探地心</strong>
          <em>SeismoCore Explore</em>
        </span>
      </button>
      <nav className="topnav" aria-label="章節導覽">
        {modules.map((m) => (
          <button
            key={m.hash}
            className={active === m.hash ? 'active' : ''}
            onClick={() => navigate(m.hash)}
            title={m.title}
          >
            {m.id}
          </button>
        ))}
      </nav>
      <button className="theme-toggle" onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}>
        {theme === 'dark' ? '☾ Dark' : '☀ Light'}
      </button>
    </header>
  );
}

function Dashboard({ navigate }) {
  return (
    <section className="dashboard page-rise">
      <div className="hero-grid">
        <div className="hero-copy">
          <p className="eyebrow">Chapter 3 · Seismic Waves and Earth Structure</p>
          <h1>震探地心<br /><span>SeismoCore Explore</span></h1>
          <p className="hero-lead">
            我們不能把地球切開，但可以讀懂地震波留下的時間差、路徑與振幅。
            從淺層折射到穿越地核的 PKP，本章就是一套「用波看穿地球」的語言。
          </p>
          <div className="hero-actions">
            <button className="primary-btn" onClick={() => navigate('m32')}>開始玩折射 / 反射模擬</button>
            <button className="ghost-btn" onClick={() => navigate('lab')}>前往 Seismo-Code Lab</button>
          </div>
        </div>
        <EarthDashboard navigate={navigate} />
      </div>

      <section className="question-panel glass">
        <div>
          <p className="eyebrow">第三章關鍵三問</p>
          <h2>走時曲線到底告訴我們什麼？</h2>
        </div>
        <div className="question-grid">
          <MiniCard title="波為何會彎？" text="速度隨深度改變，Snell 定律讓波線逐漸折返或進入陰影區。" />
          <MiniCard title="圖上的斜率是誰？" text="T-x 或 T-Δ 曲線的斜率，就是慢度或射線參數的線索。" />
          <MiniCard title="地核怎麼被發現？" text="P 波陰影區、S 波消失與 PKP 重現，指出外核為液態、內核為固態。" />
        </div>
      </section>

      <section className="module-grid">
        {modules.map((m) => (
          <button key={m.hash} className="module-card glass" style={{ '--accent': m.accent }} onClick={() => navigate(m.hash)}>
            <span className="module-icon">{m.icon}</span>
            <span className="module-id">{m.id}</span>
            <h3>{m.title.replace(`${m.id} `, '')}</h3>
            <p>{m.subtitle}</p>
            <small>{m.depth}</small>
          </button>
        ))}
      </section>

      <section id="lab" className="code-lab-section">
        <SeismoCodeLab />
      </section>
    </section>
  );
}

function EarthDashboard({ navigate }) {
  const rings = [
    { r: 172, label: '3.1 全章入口', hash: 'm31', color: '#67e8f9' },
    { r: 145, label: '3.2–3.3 地殼探測', hash: 'm32', color: '#38bdf8' },
    { r: 114, label: '3.4 球體射線', hash: 'm34', color: '#818cf8' },
    { r: 82, label: '3.5 體波相位', hash: 'm35', color: '#a78bfa' },
    { r: 49, label: '3.8 地核組成', hash: 'm38', color: '#fbbf24' }
  ];
  return (
    <div className="earth-panel glass">
      <svg viewBox="0 0 420 420" className="earth-svg" role="img" aria-label="地球剖面章節導覽">
        <defs>
          <radialGradient id="coreGlow" cx="50%" cy="50%" r="62%">
            <stop offset="0" stopColor="#fbbf24" stopOpacity="0.95" />
            <stop offset="0.35" stopColor="#fb7185" stopOpacity="0.76" />
            <stop offset="0.66" stopColor="#2563eb" stopOpacity="0.58" />
            <stop offset="1" stopColor="#0f172a" stopOpacity="0.82" />
          </radialGradient>
          <filter id="glow"><feGaussianBlur stdDeviation="4" result="blur"/><feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge></filter>
        </defs>
        <circle cx="210" cy="210" r="186" fill="url(#coreGlow)" opacity="0.95" />
        <path d="M210 24 A186 186 0 0 1 396 210 L210 210 Z" fill="rgba(255,255,255,.12)" />
        {rings.map((ring) => (
          <g key={ring.hash} onClick={() => navigate(ring.hash)} className="earth-ring" tabIndex="0" role="button">
            <circle cx="210" cy="210" r={ring.r} fill="none" stroke={ring.color} strokeWidth="1.8" opacity="0.78" />
            <circle cx={210 + ring.r * 0.7} cy={210 - ring.r * 0.7} r="5" fill={ring.color} filter="url(#glow)" />
          </g>
        ))}
        <path className="ray-orbit" d="M64 174 C115 48, 288 48, 356 210 C294 312, 148 324, 64 174" />
        <path className="ray-orbit delay" d="M88 270 C150 182, 272 182, 338 282" />
        <circle className="quake-dot" cx="64" cy="174" r="7" />
        <text x="30" y="38" className="earth-label">Click layers</text>
        <text x="284" y="398" className="earth-label">CMB / Core</text>
      </svg>
      <div className="earth-list">
        {rings.map((ring) => (
          <button key={ring.hash} onClick={() => navigate(ring.hash)}>
            <span style={{ background: ring.color }} />{ring.label}
          </button>
        ))}
      </div>
    </div>
  );
}

function MiniCard({ title, text }) {
  return (
    <article className="mini-card">
      <h3>{title}</h3>
      <p>{text}</p>
    </article>
  );
}

function ModulePage({ module, navigate }) {
  useMathJax([module.hash]);
  return (
    <article className="module-page page-rise" style={{ '--accent': module.accent }}>
      <div className="module-hero glass">
        <button className="back-btn" onClick={() => navigate('dashboard')}>← 回母導覽頁</button>
        <p className="eyebrow">Module {module.id} · {module.depth}</p>
        <h1>{module.title}</h1>
        <p className="hero-lead">{module.subtitle}</p>
        <div className="formula-pill">{module.formula}</div>
      </div>

      <div className="content-grid">
        <section className="knowledge-card glass">
          <p className="eyebrow">專業知識</p>
          <h2>{module.formulaLabel}</h2>
          <p>{module.summary}</p>
          <FormulaCard formula={module.formula} />
          <div className="bullet-list">
            {module.bullets.map((b) => <p key={b}>▸ {b}</p>)}
          </div>
        </section>
        <ProfessorNote note={module.note} />
      </div>

      <section className="interactive-zone glass">
        <div className="zone-title">
          <p className="eyebrow">Interactive Lab</p>
          <h2>動手玩：{module.subtitle}</h2>
        </div>
        <InteractiveSwitch type={module.component} />
      </section>

      <section className="accordion-zone">
        <Accordion title="本節重點整理" defaultOpen>
          <ul>
            {module.bullets.map((b) => <li key={b}>{b}</li>)}
          </ul>
        </Accordion>
        <Accordion title="讀圖提示">
          <p>{getReadingTip(module.component)}</p>
        </Accordion>
      </section>

      <Quiz quiz={module.quiz} accent={module.accent} />

      <div className="module-next glass">
        <button onClick={() => navigate('dashboard')}>回章節總覽</button>
        <button onClick={() => navigate(nextModule(module.hash).hash)}>下一章：{nextModule(module.hash).id}</button>
      </div>
    </article>
  );
}

function FormulaCard({ formula }) {
  return (
    <div className="formula-card">
      <span>公式核心</span>
      <div>{formula}</div>
    </div>
  );
}

function ProfessorNote({ note }) {
  return (
    <aside className="prof-note glass-lite">
      <div className="prof-avatar">教</div>
      <p className="eyebrow">教授小提醒</p>
      <p>{note}</p>
    </aside>
  );
}

function Accordion({ title, children, defaultOpen = false }) {
  const [open, setOpen] = useState(defaultOpen);
  return (
    <section className="accordion glass">
      <button onClick={() => setOpen(!open)}>
        <span>{title}</span>
        <strong>{open ? '−' : '+'}</strong>
      </button>
      {open && <div className="accordion-body">{children}</div>}
    </section>
  );
}

function Quiz({ quiz, accent }) {
  const [selected, setSelected] = useState(null);
  const correct = selected === quiz.answer;
  useEffect(() => {
    if (correct) {
      document.body.classList.add('quake-feedback');
      const id = setTimeout(() => document.body.classList.remove('quake-feedback'), 420);
      return () => clearTimeout(id);
    }
  }, [correct]);
  return (
    <section className="quiz glass" style={{ '--accent': accent }}>
      <p className="eyebrow">Quick Quiz</p>
      <h2>{quiz.question}</h2>
      <div className="quiz-options">
        {quiz.options.map((option, i) => (
          <button
            key={option}
            className={selected === i ? (i === quiz.answer ? 'correct' : 'wrong') : ''}
            onClick={() => setSelected(i)}
          >
            {option}
          </button>
        ))}
      </div>
      {selected !== null && (
        <p className="quiz-result">
          {correct ? '答對！震波回饋已觸發。' : '再想一下：看斜率、看介面、看能量守恆。'} {quiz.explain}
        </p>
      )}
    </section>
  );
}

function InteractiveSwitch({ type }) {
  switch (type) {
    case 'resolution': return <ResolutionExplorer />;
    case 'refraction': return <RefractionSandbox />;
    case 'reflection': return <ReflectionLab />;
    case 'spherical': return <SphericalRayLab />;
    case 'bodywaves': return <BodyWaveChallenge />;
    case 'anisotropy': return <AnisotropyLab />;
    case 'attenuation': return <AttenuationSimulator />;
    case 'composition': return <CompositionDensityLab />;
    default: return null;
  }
}

function getReadingTip(type) {
  const tips = {
    resolution: '走時曲線不要只看單一點，應該看大量震源—測站組合形成的整體趨勢；單一路徑只是一條積分限制。',
    refraction: 'T-x 圖中斜率越小代表速度越快。直接波通過原點，反射波是雙曲線，頭波是帶截距的直線。',
    reflection: '反射資料先在時間域看雙曲線，再透過 NMO、CMP 疊加與 migration 逐步轉成構造影像。',
    spherical: '球體地球的走時曲線若出現斷裂、三叉或陰影區，通常代表速度梯度或不連續面有重要變化。',
    bodywaves: '相位名稱可拆字讀：c 是 CMB 反射、K 是外核路徑、I 是內核路徑、diff 是繞射。',
    anisotropy: '看非均向性時不要只問哪裡快，要問「哪個方向快、哪個偏振快」，這才會連到構造方向。',
    attenuation: '振幅變小不一定代表能量消失；先分清楚幾何擴散、散射與真正非彈性耗能。',
    composition: '波速模型不是成分模型。成分推論還要同時滿足密度、壓力、轉動慣量與高壓礦物物理。'
  };
  return tips[type] || '';
}

function nextModule(hash) {
  const idx = modules.findIndex((m) => m.hash === hash);
  return modules[(idx + 1) % modules.length];
}

function Slider({ label, value, min, max, step, unit, onChange }) {
  return (
    <label className="slider-row">
      <span>{label}<strong>{value}{unit || ''}</strong></span>
      <input type="range" min={min} max={max} step={step} value={value} onChange={(e) => onChange(Number(e.target.value))} />
    </label>
  );
}

function ResolutionExplorer() {
  const [data, setData] = useState(55);
  const [contrast, setContrast] = useState(65);
  const seismic = Math.round(30 + data * 0.55 + contrast * 0.35);
  const gravity = Math.round(15 + data * 0.2 + contrast * 0.22);
  const magnetic = Math.round(18 + data * 0.18 + contrast * 0.25);
  return (
    <div className="interactive-grid two">
      <div className="sim-card">
        <svg viewBox="0 0 620 330" className="wide-svg">
          <defs>
            <linearGradient id="subsurface" x1="0" x2="0" y1="0" y2="1">
              <stop offset="0" stopColor="rgba(125,211,252,.18)" />
              <stop offset="1" stopColor="rgba(30,41,59,.55)" />
            </linearGradient>
          </defs>
          <rect x="28" y="42" width="560" height="246" rx="22" fill="url(#subsurface)" stroke="rgba(148,163,184,.35)" />
          <path d="M28 108 H588 M28 176 H588 M28 242 H588" stroke="rgba(226,232,240,.2)" strokeDasharray="8 8" />
          <ellipse cx="210" cy="210" rx={45 + contrast * 0.18} ry="22" fill="rgba(251,191,36,.55)" />
          <ellipse cx="395" cy="148" rx="36" ry={18 + contrast * 0.12} fill="rgba(244,114,182,.45)" />
          {Array.from({ length: 12 }).map((_, i) => {
            const x = 52 + i * 45;
            const bend = (Math.sin(i) * contrast) / 9;
            return <path key={i} className="scan-ray" d={`M${x} 42 C${x + bend} 110, ${x - bend} 180, ${x + bend * 0.7} 288`} />;
          })}
          <text x="54" y="72" className="svg-label">Seismic rays: 多路徑交叉 → 解析度高</text>
          <text x="54" y="312" className="svg-label small">重力/磁力多為平滑場，深部位置與形狀較不容易唯一決定</text>
        </svg>
      </div>
      <div className="control-panel">
        <Slider label="震源與測站資料量" value={data} min={10} max={100} step={1} unit="%" onChange={setData} />
        <Slider label="介面速度/密度對比" value={contrast} min={10} max={100} step={1} unit="%" onChange={setContrast} />
        <div className="bar-stack">
          <MetricBar label="地震學解析度" value={Math.min(seismic, 100)} />
          <MetricBar label="重力資料約束" value={Math.min(gravity, 100)} />
          <MetricBar label="磁力資料約束" value={Math.min(magnetic, 100)} />
        </div>
        <p className="sim-explain">重點：地震波提供的是「沿路徑的慢度積分」，資料越密，路徑交叉越多，越能把地下速度異常定位出來。</p>
      </div>
    </div>
  );
}

function MetricBar({ label, value }) {
  return (
    <div className="metric-bar">
      <span>{label}</span>
      <div><i style={{ width: `${value}%` }} /></div>
      <strong>{value}</strong>
    </div>
  );
}

function RefractionSandbox() {
  const canvasRef = useRef(null);
  const [v0, setV0] = useState(5.8);
  const [v1, setV1] = useState(8.0);
  const [h, setH] = useState(18);
  const [x, setX] = useState(52);
  const critical = v1 > v0 ? Math.asin(v0 / v1) * 180 / Math.PI : null;
  const tau = v1 > v0 ? 2 * h * Math.sqrt(1 / (v0 * v0) - 1 / (v1 * v1)) : null;
  const td = x / v0;
  const tr = 2 * Math.sqrt((x / 2) ** 2 + h ** 2) / v0;
  const th = tau ? x / v1 + tau : null;
  const first = Math.min(td, tr, th || Infinity);

  useEffect(() => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    const W = canvas.width;
    const H = canvas.height;
    ctx.clearRect(0, 0, W, H);
    ctx.lineWidth = 1;
    ctx.strokeStyle = 'rgba(148,163,184,.35)';
    ctx.fillStyle = 'rgba(226,232,240,.78)';
    ctx.font = '12px Inter';
    const pad = 44;
    const xMax = 90;
    const yMax = Math.max(18, 90 / Math.min(v0, v1) + 4);
    const sx = (xx) => pad + xx / xMax * (W - pad * 1.35);
    const sy = (tt) => H - pad - tt / yMax * (H - pad * 1.3);
    ctx.beginPath(); ctx.moveTo(pad, 15); ctx.lineTo(pad, H - pad); ctx.lineTo(W - 18, H - pad); ctx.stroke();
    ctx.fillText('T (s)', 8, 25); ctx.fillText('x (km)', W - 56, H - 14);
    const drawCurve = (fn, color, label, dashed = false) => {
      ctx.save();
      ctx.strokeStyle = color; ctx.lineWidth = 2.4;
      if (dashed) ctx.setLineDash([8, 7]);
      ctx.beginPath();
      for (let i = 0; i <= 180; i++) {
        const xx = i / 180 * xMax;
        const tt = fn(xx);
        if (i === 0) ctx.moveTo(sx(xx), sy(tt)); else ctx.lineTo(sx(xx), sy(tt));
      }
      ctx.stroke();
      ctx.setLineDash([]);
      ctx.fillStyle = color; ctx.fillText(label, sx(66), sy(fn(66)) - 8);
      ctx.restore();
    };
    drawCurve((xx) => xx / v0, '#67e8f9', 'Direct');
    drawCurve((xx) => 2 * Math.sqrt((xx / 2) ** 2 + h ** 2) / v0, '#fbbf24', 'Reflection');
    if (tau) drawCurve((xx) => xx / v1 + tau, '#fb7185', 'Head wave');
    ctx.fillStyle = '#ffffff';
    ctx.beginPath(); ctx.arc(sx(x), sy(first), 5, 0, Math.PI * 2); ctx.fill();
  }, [v0, v1, h, x, tau, first]);

  return (
    <div className="interactive-grid">
      <div className="sim-card">
        <svg viewBox="0 0 620 330" className="wide-svg">
          <rect x="30" y="42" width="560" height="110" rx="18" fill="rgba(125,211,252,.16)" />
          <rect x="30" y="152" width="560" height="136" rx="18" fill="rgba(251,191,36,.12)" />
          <line x1="30" y1="152" x2="590" y2="152" stroke="rgba(251,191,36,.6)" strokeWidth="2" />
          <circle cx="70" cy="72" r="8" fill="#fb7185" />
          <circle cx={70 + x * 5.2} cy="72" r="7" fill="#67e8f9" />
          <path d={`M70 72 L${70 + x * 5.2} 72`} stroke="#67e8f9" strokeWidth="3" />
          <path d={`M70 72 L${70 + x * 2.6} 152 L${70 + x * 5.2} 72`} stroke="#fbbf24" strokeWidth="3" fill="none" />
          {v1 > v0 && <path d={`M70 72 L${70 + h * 3.8} 152 L${70 + x * 5.2 - h * 3.8} 152 L${70 + x * 5.2} 72`} stroke="#fb7185" strokeWidth="3" fill="none" strokeDasharray="9 7" />}
          <text x="45" y="132" className="svg-label">Layer 1：v₀ = {v0.toFixed(1)} km/s</text>
          <text x="45" y="188" className="svg-label">Layer 2：v₁ = {v1.toFixed(1)} km/s</text>
          <text x="410" y="302" className="svg-label small">h₀ = {h} km · x = {x} km</text>
        </svg>
      </div>
      <div className="control-panel">
        <Slider label="上層速度 v₀" value={v0} min={3.5} max={7.0} step={0.1} unit=" km/s" onChange={setV0} />
        <Slider label="下層速度 v₁" value={v1} min={4.0} max={9.5} step={0.1} unit=" km/s" onChange={setV1} />
        <Slider label="界面深度 h₀" value={h} min={5} max={35} step={1} unit=" km" onChange={setH} />
        <Slider label="測站距離 x" value={x} min={8} max={85} step={1} unit=" km" onChange={setX} />
        <div className="numbers">
          <span>臨界角：{critical ? `${critical.toFixed(1)}°` : '無，v₁ 必須大於 v₀'}</span>
          <span>TD：{td.toFixed(2)} s</span>
          <span>TR：{tr.toFixed(2)} s</span>
          <span>TH：{th ? `${th.toFixed(2)} s` : '不成立'}</span>
        </div>
      </div>
      <div className="sim-card chart-card">
        <canvas ref={canvasRef} width="620" height="360" />
      </div>
    </div>
  );
}

function ReflectionLab() {
  const canvasRef = useRef(null);
  const [h, setH] = useState(2.2);
  const [vrms1, setVrms1] = useState(3.1);
  const [vrms2, setVrms2] = useState(4.4);
  const [t1, setT1] = useState(1.1);
  const [t2, setT2] = useState(2.0);
  const [offset, setOffset] = useState(3.0);
  const t0 = 2 * h / vrms1;
  const tx = Math.sqrt(t0 ** 2 + (offset / vrms1) ** 2);
  const nmo = tx - t0;
  const dix = Math.sqrt(Math.max(0.01, (vrms2 ** 2 * t2 - vrms1 ** 2 * t1) / (t2 - t1)));

  useEffect(() => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    const W = canvas.width, H = canvas.height, pad = 44;
    ctx.clearRect(0, 0, W, H);
    ctx.strokeStyle = 'rgba(148,163,184,.35)';
    ctx.beginPath(); ctx.moveTo(pad, 20); ctx.lineTo(pad, H - pad); ctx.lineTo(W - 24, H - pad); ctx.stroke();
    const sx = (x) => pad + (x + 5) / 10 * (W - pad * 1.4);
    const sy = (t) => H - pad - t / 3.1 * (H - pad * 1.4);
    ctx.strokeStyle = '#22d3ee'; ctx.lineWidth = 2.5; ctx.beginPath();
    for (let i = 0; i <= 220; i++) {
      const x = -5 + i / 220 * 10;
      const t = Math.sqrt(t0 ** 2 + (x / vrms1) ** 2);
      if (i === 0) ctx.moveTo(sx(x), sy(t)); else ctx.lineTo(sx(x), sy(t));
    }
    ctx.stroke();
    ctx.setLineDash([7, 6]); ctx.strokeStyle = '#fbbf24'; ctx.beginPath(); ctx.moveTo(sx(-5), sy(t0)); ctx.lineTo(sx(5), sy(t0)); ctx.stroke(); ctx.setLineDash([]);
    ctx.fillStyle = '#e2e8f0'; ctx.font = '12px Inter'; ctx.fillText('Reflection hyperbola', sx(1.6), sy(Math.sqrt(t0 ** 2 + (1.6 / vrms1) ** 2)) - 12);
    ctx.fillText('zero-offset t₀', sx(-4.8), sy(t0) - 8);
    ctx.fillText('offset x', W - 76, H - 14); ctx.fillText('T', 15, 28);
    ctx.fillStyle = '#fff'; ctx.beginPath(); ctx.arc(sx(offset), sy(tx), 5, 0, Math.PI * 2); ctx.fill();
  }, [h, vrms1, t0, tx, offset]);

  return (
    <div className="interactive-grid">
      <div className="sim-card chart-card"><canvas ref={canvasRef} width="620" height="360" /></div>
      <div className="control-panel">
        <Slider label="反射界面深度 h" value={h} min={0.8} max={5.0} step={0.1} unit=" km" onChange={setH} />
        <Slider label="上覆 RMS 速度" value={vrms1} min={1.8} max={5.5} step={0.1} unit=" km/s" onChange={setVrms1} />
        <Slider label="觀測 offset" value={offset} min={0} max={5} step={0.1} unit=" km" onChange={setOffset} />
        <div className="numbers">
          <span>垂直雙程走時 t₀：{t0.toFixed(2)} s</span>
          <span>偏移走時 T(x)：{tx.toFixed(2)} s</span>
          <span>NMO：{nmo.toFixed(2)} s</span>
        </div>
        <hr />
        <Slider label="第 1 介面 Vrms" value={vrms1} min={1.8} max={5.5} step={0.1} unit="" onChange={setVrms1} />
        <Slider label="第 2 介面 Vrms" value={vrms2} min={2.0} max={7.0} step={0.1} unit="" onChange={setVrms2} />
        <Slider label="t₁" value={t1} min={0.5} max={1.7} step={0.1} unit=" s" onChange={setT1} />
        <Slider label="t₂" value={t2} min={1.8} max={3.5} step={0.1} unit=" s" onChange={setT2} />
        <p className="sim-explain">Dix 推得第 2 層速度約 <strong>{dix.toFixed(2)} km/s</strong>。</p>
      </div>
    </div>
  );
}

function SphericalRayLab() {
  const [p, setP] = useState(68);
  const [gradient, setGradient] = useState(62);
  const bottom = Math.round(120 + (100 - p) * 45 + gradient * 12);
  const angle = Math.round(24 + (100 - p) * 1.15);
  const shadow = p < 28;
  const curveDepth = 94 + (100 - p) * 1.35;
  return (
    <div className="interactive-grid two">
      <div className="sim-card">
        <svg viewBox="0 0 620 430" className="wide-svg earth-lab-svg">
          <defs>
            <radialGradient id="earthModel" cx="50%" cy="50%" r="60%">
              <stop offset="0" stopColor="rgba(251,191,36,.85)" />
              <stop offset=".42" stopColor="rgba(249,115,22,.45)" />
              <stop offset=".72" stopColor="rgba(37,99,235,.35)" />
              <stop offset="1" stopColor="rgba(15,23,42,.95)" />
            </radialGradient>
          </defs>
          <circle cx="310" cy="390" r="320" fill="url(#earthModel)" stroke="rgba(226,232,240,.25)" />
          <circle cx="310" cy="390" r="145" fill="rgba(248,113,113,.16)" stroke="rgba(251,191,36,.45)" />
          <circle cx="310" cy="390" r="70" fill="rgba(251,191,36,.25)" stroke="rgba(251,191,36,.55)" />
          <path className="sphere-ray" d={`M105 112 C190 ${curveDepth}, 430 ${curveDepth}, 515 112`} />
          <path className="sphere-ray faint" d={`M130 126 C220 ${curveDepth + 45}, 400 ${curveDepth + 45}, 490 126`} />
          {shadow && <path d="M396 90 A310 310 0 0 1 540 190" stroke="#fb7185" strokeWidth="16" strokeOpacity=".25" fill="none" />}
          <circle cx="105" cy="112" r="8" fill="#fb7185" />
          <circle cx="515" cy="112" r="8" fill="#67e8f9" />
          <line x1="310" y1="390" x2="310" y2={curveDepth} stroke="rgba(226,232,240,.25)" strokeDasharray="6 8" />
          <text x="76" y="86" className="svg-label">Earthquake</text>
          <text x="482" y="86" className="svg-label">Station</text>
          <text x="348" y="302" className="svg-label small">Bottoming depth ≈ {bottom} km</text>
          <text x="42" y="392" className="svg-label small">p = r sin i / v · Δ ≈ {angle}°</text>
        </svg>
      </div>
      <div className="control-panel">
        <Slider label="射線參數 p" value={p} min={15} max={95} step={1} unit="" onChange={setP} />
        <Slider label="速度隨深度增加強度" value={gradient} min={20} max={95} step={1} unit="%" onChange={setGradient} />
        <div className="numbers">
          <span>估計震央距 Δ：{angle}°</span>
          <span>最深點：約 {bottom} km</span>
          <span>走時曲線斜率：p = dT/dΔ</span>
          <span>{shadow ? '可能進入陰影區：低 p 射線接近地核效應' : '目前為平滑折返射線'}</span>
        </div>
        <p className="sim-explain">向下傳播時通常 $v$ 變大、$r$ 變小；為了讓 $p$ 維持不變，$\sin i$ 必須改變，射線因而彎曲並返回地表。</p>
      </div>
    </div>
  );
}

function BodyWaveChallenge() {
  const [phase, setPhase] = useState('PKP');
  return (
    <div className="interactive-grid two">
      <div className="sim-card">
        <svg viewBox="0 0 620 440" className="wide-svg bodywave-svg">
          <defs>
            <clipPath id="earthClip"><circle cx="310" cy="220" r="185" /></clipPath>
            <radialGradient id="bodyEarth"><stop offset="0" stopColor="#fbbf24" /><stop offset=".36" stopColor="#f97316" /><stop offset=".63" stopColor="#334155" /><stop offset="1" stopColor="#0f172a" /></radialGradient>
          </defs>
          <circle cx="310" cy="220" r="185" fill="url(#bodyEarth)" stroke="rgba(226,232,240,.28)" />
          <circle cx="310" cy="220" r="93" fill="rgba(251,191,36,.18)" stroke="rgba(251,191,36,.55)" />
          <circle cx="310" cy="220" r="48" fill="rgba(251,191,36,.32)" stroke="rgba(251,191,36,.65)" />
          <path className={phase === 'P' ? 'phase-path active' : 'phase-path'} onClick={() => setPhase('P')} d="M153 122 C242 184, 365 182, 467 124" />
          <path className={phase === 'S' ? 'phase-path active s' : 'phase-path s'} onClick={() => setPhase('S')} d="M148 314 C240 250, 376 250, 472 313" />
          <path className={phase === 'PP' ? 'phase-path active pp' : 'phase-path pp'} onClick={() => setPhase('PP')} d="M151 124 C218 68, 272 56, 310 36 C348 56, 402 68, 469 124" />
          <path className={phase === 'PcP' ? 'phase-path active pcp' : 'phase-path pcp'} onClick={() => setPhase('PcP')} d="M154 122 C240 230, 281 298, 310 313 C339 298, 380 230, 466 122" />
          <path className={phase === 'PKP' ? 'phase-path active pkp' : 'phase-path pkp'} onClick={() => setPhase('PKP')} d="M150 122 C248 252, 282 260, 310 220 C338 260, 372 252, 470 122" />
          <path className={phase === 'PKIKP' ? 'phase-path active pkikp' : 'phase-path pkikp'} onClick={() => setPhase('PKIKP')} d="M150 122 C232 272, 288 255, 310 220 C332 185, 388 168, 470 122" />
          <path className={phase === 'Pdiff' ? 'phase-path active diff' : 'phase-path diff'} onClick={() => setPhase('Pdiff')} d="M145 122 C178 300, 442 300, 475 122" />
          <circle cx="150" cy="122" r="8" fill="#fb7185" />
          <circle cx="470" cy="122" r="8" fill="#67e8f9" />
          <text x="270" y="424" className="svg-label small">點擊波路徑解鎖相位名稱</text>
          <text x="405" y="224" className="svg-label small">Outer core: K</text>
          <text x="292" y="222" className="svg-label small">I</text>
        </svg>
      </div>
      <div className="control-panel phase-panel">
        <p className="eyebrow">Phase Challenge</p>
        <h3>{phase}</h3>
        <p>{phaseInfo[phase]}</p>
        <div className="phase-buttons">
          {Object.keys(phaseInfo).map((p) => <button key={p} className={phase === p ? 'active' : ''} onClick={() => setPhase(p)}>{p}</button>)}
        </div>
        <p className="sim-explain">顏色提示：穿越外核的路徑會偏金色；在 CMB 反射或沿 CMB 繞射的路徑，會貼近核幔邊界。</p>
      </div>
    </div>
  );
}

function AnisotropyLab() {
  const [mode, setMode] = useState('SPO');
  const [ani, setAni] = useState(8);
  const fast = 4.6 + ani * 0.05;
  const slow = 4.6 - ani * 0.035;
  const delay = (80 * (1 / slow - 1 / fast)).toFixed(2);
  return (
    <div className="interactive-grid two">
      <div className="sim-card anis-card">
        <svg viewBox="0 0 620 330" className="wide-svg">
          <rect x="38" y="44" width="544" height="238" rx="24" fill="rgba(125,211,252,.1)" stroke="rgba(226,232,240,.22)" />
          {mode === 'SPO' ? (
            Array.from({ length: 8 }).map((_, i) => <rect key={i} x="68" y={72 + i * 24} width="484" height="10" rx="5" fill={i % 2 ? 'rgba(148,163,184,.28)' : 'rgba(103,232,249,.18)'} />)
          ) : (
            Array.from({ length: 38 }).map((_, i) => {
              const x = 78 + (i % 10) * 48;
              const y = 78 + Math.floor(i / 10) * 48;
              return <g key={i} transform={`translate(${x} ${y}) rotate(${-24 + (i % 4) * 8})`}><ellipse cx="0" cy="0" rx="22" ry="6" fill="rgba(251,191,36,.35)" stroke="rgba(251,191,36,.45)" /></g>;
            })
          )}
          <ellipse className="wavefront fast" cx="260" cy="168" rx={75 + ani * 4} ry="54" fill="none" />
          <ellipse className="wavefront slow" cx="260" cy="168" rx="70" ry={70 + ani * 2.2} fill="none" />
          <path className="split-wave" d="M90 168 C160 120, 220 120, 300 168 S430 216, 530 168" />
          <text x="74" y="306" className="svg-label small">{mode}: {mode === 'SPO' ? '巨觀層理/裂隙方向控制速度' : '微觀晶格排列控制速度'}</text>
        </svg>
      </div>
      <div className="control-panel">
        <div className="toggle-group">
          <button className={mode === 'SPO' ? 'active' : ''} onClick={() => setMode('SPO')}>SPO 層狀構造</button>
          <button className={mode === 'LPO' ? 'active' : ''} onClick={() => setMode('LPO')}>LPO 晶格排列</button>
        </div>
        <Slider label="非均向性強度" value={ani} min={1} max={18} step={1} unit="%" onChange={setAni} />
        <div className="numbers">
          <span>快波速度：{fast.toFixed(2)} km/s</span>
          <span>慢波速度：{slow.toFixed(2)} km/s</span>
          <span>80 km 後時間差：約 {delay} s</span>
        </div>
        <p className="sim-explain">水平層狀或橄欖石晶格定向排列，都會讓某些方向的波跑得更快。S 波因此可分裂成兩個偏振方向互相垂直的波包。</p>
      </div>
    </div>
  );
}

function AttenuationSimulator() {
  const canvasRef = useRef(null);
  const [q, setQ] = useState(120);
  const [distance, setDistance] = useState(220);
  const [freq, setFreq] = useState(4.5);
  useEffect(() => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    const W = canvas.width, H = canvas.height;
    ctx.clearRect(0, 0, W, H);
    ctx.strokeStyle = 'rgba(148,163,184,.28)';
    ctx.beginPath();
    for (let y = 40; y < H; y += 40) { ctx.moveTo(30, y); ctx.lineTo(W - 20, y); }
    for (let x = 40; x < W; x += 60) { ctx.moveTo(x, 20); ctx.lineTo(x, H - 30); }
    ctx.stroke();
    const draw = (attenuated) => {
      ctx.beginPath();
      ctx.lineWidth = attenuated ? 2.8 : 1.5;
      ctx.strokeStyle = attenuated ? '#fb7185' : 'rgba(103,232,249,.55)';
      for (let i = 0; i < W - 70; i++) {
        const t = i / (W - 70) * 12;
        const spread = attenuated ? 80 / distance : 1;
        const intrinsic = attenuated ? Math.exp(-Math.PI * freq * distance / (q * 90)) : 1;
        const lowpass = attenuated ? Math.exp(-t / (2.5 + q / 70)) : 1;
        const amp = 72 * spread * intrinsic * lowpass;
        const f2 = attenuated ? freq * (0.62 + q / 600) : freq;
        const y = H / 2 + Math.sin(t * Math.PI * f2) * amp * Math.exp(-t / 9) + Math.sin(t * 4.4) * amp * 0.25;
        const x = 38 + i;
        if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
      }
      ctx.stroke();
    };
    draw(false); draw(true);
    ctx.fillStyle = '#e2e8f0'; ctx.font = '12px Inter';
    ctx.fillText('cyan: 原始波形', 42, 28); ctx.fillText('rose: 距離 + Q 衰減後', 170, 28);
  }, [q, distance, freq]);
  const amp = (80 / distance * Math.exp(-Math.PI * freq * distance / (q * 90))).toFixed(3);
  return (
    <div className="interactive-grid">
      <div className="sim-card chart-card"><canvas ref={canvasRef} width="720" height="360" /></div>
      <div className="control-panel">
        <Slider label="品質因子 Q" value={q} min={30} max={500} step={5} unit="" onChange={setQ} />
        <Slider label="傳播距離" value={distance} min={60} max={520} step={10} unit=" km" onChange={setDistance} />
        <Slider label="主頻率" value={freq} min={1} max={9} step={0.1} unit=" Hz" onChange={setFreq} />
        <div className="numbers">
          <span>相對振幅：約 {amp}</span>
          <span>幾何擴散：~ 1/r</span>
          <span>非彈性：~ exp(-ωt/2Q)</span>
        </div>
        <p className="sim-explain">距離增加會讓能量攤大；Q 越低，內在衰減越強，高頻成分越快消失，波形會變得低頻、鈍化。</p>
      </div>
    </div>
  );
}

function CompositionDensityLab() {
  const [depth, setDepth] = useState(2890);
  const density = densityAt(depth);
  const pressure = pressureAt(depth);
  const layer = layerAt(depth);
  return (
    <div className="interactive-grid two">
      <div className="sim-card">
        <svg viewBox="0 0 620 370" className="wide-svg density-svg">
          <defs>
            <linearGradient id="densGrad" x1="0" x2="1">
              <stop offset="0" stopColor="#0f172a" /><stop offset=".35" stopColor="#1d4ed8" /><stop offset=".65" stopColor="#f97316" /><stop offset="1" stopColor="#fbbf24" />
            </linearGradient>
          </defs>
          <rect x="70" y="58" width="480" height="38" rx="19" fill="rgba(103,232,249,.18)" />
          <rect x="70" y="116" width="480" height="58" rx="22" fill="rgba(129,140,248,.22)" />
          <rect x="70" y="194" width="480" height="78" rx="24" fill="rgba(249,115,22,.18)" />
          <rect x="70" y="292" width="480" height="38" rx="19" fill="rgba(251,191,36,.28)" />
          <line x1={70 + depth / 6371 * 480} y1="42" x2={70 + depth / 6371 * 480} y2="342" stroke="#fff" strokeWidth="2" />
          <circle cx={70 + depth / 6371 * 480} cy="42" r="6" fill="#fb7185" />
          <text x="80" y="84" className="svg-label">Mantle: phase transitions near 410 & 660 km</text>
          <text x="80" y="148" className="svg-label">Lower mantle: self-compression</text>
          <text x="80" y="238" className="svg-label">Outer core: liquid, dense Fe alloy</text>
          <text x="80" y="318" className="svg-label">Inner core: solid</text>
          <polyline points="70,340 110,325 142,305 248,265 288,246 372,176 458,102 550,68" fill="none" stroke="url(#densGrad)" strokeWidth="4" />
          <text x="398" y="354" className="svg-label small">depth →</text>
        </svg>
      </div>
      <div className="control-panel">
        <Slider label="深度" value={depth} min={0} max={6371} step={10} unit=" km" onChange={setDepth} />
        <div className="numbers big">
          <span>所在層圈：{layer}</span>
          <span>估計密度：{density.toFixed(2)} g/cm³</span>
          <span>估計壓力：{pressure.toFixed(0)} GPa</span>
          <span>地球平均密度：約 5.5 g/cm³</span>
          <span>轉動慣量 $C/Ma^2$：約 0.33</span>
        </div>
        <p className="sim-explain">Adams-Williamson 方程式描述均勻材料因自體壓縮造成的密度增加；若密度跳躍遠大於壓縮效果，通常暗示相變或成分改變。</p>
      </div>
    </div>
  );
}

function densityAt(depth) {
  if (depth < 35) return 2.8 + depth / 35 * 0.3;
  if (depth < 410) return 3.3 + (depth - 35) / 375 * 0.4;
  if (depth < 660) return 3.8 + (depth - 410) / 250 * 0.7;
  if (depth < 2890) return 4.4 + (depth - 660) / 2230 * 1.17;
  if (depth < 5150) return 9.9 + (depth - 2890) / 2260 * 2.2;
  return 12.8 + (depth - 5150) / 1221 * 0.25;
}
function pressureAt(depth) {
  if (depth < 410) return depth / 410 * 13.3;
  if (depth < 2890) return 13.3 + (depth - 410) / 2480 * (136 - 13.3);
  if (depth < 5150) return 136 + (depth - 2890) / 2260 * (330 - 136);
  return 330 + (depth - 5150) / 1221 * 34;
}
function layerAt(depth) {
  if (depth < 35) return '地殼 Crust';
  if (depth < 410) return '上部地函 Upper Mantle';
  if (depth < 660) return '地函過渡帶 Transition Zone';
  if (depth < 2890) return '下部地函 Lower Mantle';
  if (depth < 5150) return '液態外核 Outer Core';
  return '固態內核 Inner Core';
}

const defaultLabCode = String.raw`# Seismo-Code Lab: browser-safe record section demo
# 調整 amp_scale、freqmin、freqmax，觀察走時波型剖面圖如何改變。
# 這裡用 NumPy/Matplotlib 生成「類 SAC 測站資料」；真正 SAC + ObsPy 版本見 README 的 local_obspy_plot.py。

import numpy as np
import matplotlib.pyplot as plt
import io, base64

amp_scale = 8.0
freqmin = 0.5
freqmax = 5.0
np.random.seed(7)

stations = ["NACB", "TWG", "TATO", "YHNB", "ECL", "CHY", "ALS", "TPU", "LAY", "HWA", "WFS", "SML"]
dist_km = np.linspace(28, 360, len(stations))
time = np.linspace(0, 115, 900)

def ricker(t, t0, f=2.8):
    x = np.pi * f * (t - t0)
    return (1 - 2*x*x) * np.exp(-x*x)

fig, ax = plt.subplots(figsize=(11, 7), dpi=140)
colors = ["#CC0000", "#FF8C00", "#006400", "#4169E1", "#8B008B", "#000000", "#B22222", "#87CEEB", "#228B22", "#FF4500"]

for i, (sta, d) in enumerate(zip(stations, dist_km)):
    p_arrival = d / 6.2 + 2.5
    s_arrival = d / 3.55 + 4.0
    waveform = ricker(time, p_arrival, 3.0) + 0.65 * ricker(time, s_arrival, 1.6)
    waveform += 0.05 * np.sin(time * 0.5 + i) + 0.025 * np.random.randn(len(time))
    waveform /= np.max(np.abs(waveform))
    ax.plot(d + waveform * amp_scale, time, lw=0.65, color=colors[i % len(colors)])
    ax.text(d, -3, sta, rotation=90, ha="center", va="top", fontsize=7, color=colors[i % len(colors)], fontweight="bold")

# 理論 P/S 走時線，輔助判讀 record section
xline = np.linspace(0, 390, 100)
ax.plot(xline, xline / 6.2 + 2.5, "--", lw=1.2, color="tab:blue", label="P pick trend")
ax.plot(xline, xline / 3.55 + 4.0, "--", lw=1.2, color="tab:orange", label="S pick trend")

ax.set_xlim(0, 400)
ax.set_ylim(0, 115)
ax.set_xlabel("Distance (km)")
ax.set_ylabel("Time after origin (s)")
ax.set_title("Synthetic CWASN-style Record Section")
ax.grid(True, alpha=0.28)
ax.legend(loc="upper left")
fig.tight_layout()

buf = io.BytesIO()
fig.savefig(buf, format="png", facecolor="white", bbox_inches="tight")
record_section_png = "data:image/png;base64," + base64.b64encode(buf.getvalue()).decode("ascii")
print(f"Done. Plotted {len(stations)} stations. amp_scale={amp_scale}, band={freqmin}-{freqmax} Hz")
`;

function SeismoCodeLab() {
  const [code, setCode] = useState(defaultLabCode);
  const [status, setStatus] = useState('尚未載入 Pyodide');
  const [output, setOutput] = useState('點擊「載入並執行」後，會在瀏覽器中生成 record section。');
  const [image, setImage] = useState('');
  const pyodideRef = useRef(null);

  async function loadPyodideRuntime() {
    if (pyodideRef.current) return pyodideRef.current;
    setStatus('正在載入 Pyodide 與科學繪圖套件，第一次需要較久...');
    if (!window.loadPyodide) {
      await new Promise((resolve, reject) => {
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/pyodide/v0.26.4/full/pyodide.js';
        script.onload = resolve;
        script.onerror = reject;
        document.head.appendChild(script);
      });
    }
    const pyodide = await window.loadPyodide({ indexURL: 'https://cdn.jsdelivr.net/pyodide/v0.26.4/full/' });
    pyodide.setStdout({ batched: (msg) => setOutput((prev) => `${prev}\n${msg}`) });
    pyodide.setStderr({ batched: (msg) => setOutput((prev) => `${prev}\n[stderr] ${msg}`) });
    await pyodide.loadPackage(['numpy', 'matplotlib']);
    pyodideRef.current = pyodide;
    setStatus('Pyodide 已就緒');
    return pyodide;
  }

  async function runCode() {
    try {
      setOutput('');
      setImage('');
      const pyodide = await loadPyodideRuntime();
      setStatus('正在執行 Python...');
      await pyodide.runPythonAsync(code);
      const png = pyodide.globals.get('record_section_png');
      if (png) setImage(png);
      setStatus('執行完成');
    } catch (err) {
      setStatus('執行失敗');
      setOutput(String(err));
    }
  }

  return (
    <section className="code-lab glass">
      <div className="zone-title">
        <p className="eyebrow">The Seismo-Code Lab</p>
        <h2>地震波走時繪圖實驗室</h2>
        <p>瀏覽器版使用 Pyodide + NumPy + Matplotlib 產生合成 record section；在本機處理 SAC 檔時，請使用 README 內的 ObsPy 版本。</p>
      </div>
      <div className="lab-grid">
        <div className="editor-panel">
          <div className="editor-toolbar">
            <button className="primary-btn" onClick={runCode}>載入並執行</button>
            <button className="ghost-btn" onClick={() => setCode(defaultLabCode)}>還原範例</button>
            <span>{status}</span>
          </div>
          <textarea spellCheck="false" value={code} onChange={(e) => setCode(e.target.value)} />
        </div>
        <div className="output-panel">
          <pre>{output}</pre>
          {image ? <img src={image} alt="Record section generated by Pyodide" /> : <div className="empty-output">圖形輸出會出現在這裡</div>}
        </div>
      </div>
    </section>
  );
}

function Footer() {
  return (
    <footer className="footer">
      <p>震探地心 SeismoCore Explore · Chapter 3 interactive learning site</p>
      <p>Designed for GitHub Pages / Codespaces deployment.</p>
    </footer>
  );
}

export default App;

EOF_src_App_jsx

cat > 'src/styles.css' <<'EOF_src_styles_css'
:root {
  --bg: #f7f3ea;
  --bg2: #e7edf4;
  --text: #172033;
  --muted: #526071;
  --card: rgba(255, 252, 244, 0.78);
  --card-strong: rgba(255, 252, 244, 0.92);
  --line: rgba(38, 53, 77, 0.16);
  --shadow: 0 24px 70px rgba(15, 23, 42, 0.14);
  --deep: #0f172a;
  --ivory: #fffaf0;
  --slate: #475569;
  --accent: #67e8f9;
}

:root[data-theme="dark"] {
  --bg: #07111f;
  --bg2: #101927;
  --text: #e5eefb;
  --muted: #9fb0c5;
  --card: rgba(15, 23, 42, 0.72);
  --card-strong: rgba(15, 23, 42, 0.9);
  --line: rgba(226, 232, 240, 0.16);
  --shadow: 0 24px 80px rgba(0, 0, 0, 0.36);
  --deep: #020617;
  --ivory: #fffaf0;
  --slate: #94a3b8;
}

* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body {
  margin: 0;
  font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  color: var(--text);
  background:
    radial-gradient(circle at 12% 8%, rgba(103, 232, 249, .22), transparent 28%),
    radial-gradient(circle at 86% 18%, rgba(167, 139, 250, .2), transparent 32%),
    linear-gradient(135deg, var(--bg), var(--bg2));
  min-height: 100vh;
}
button, input, textarea { font: inherit; }
button { cursor: pointer; }

.app-shell { min-height: 100vh; position: relative; overflow-x: hidden; }
main { width: min(1220px, calc(100% - 34px)); margin: 0 auto; padding: 108px 0 56px; }
.glass {
  background: var(--card);
  border: 1px solid var(--line);
  box-shadow: var(--shadow);
  backdrop-filter: blur(22px);
}
.glass-lite {
  background: rgba(255,255,255,.06);
  border: 1px solid var(--line);
  backdrop-filter: blur(16px);
}

.ambient { position: fixed; inset: 0; pointer-events: none; overflow: hidden; z-index: -1; }
.ambient-grid {
  position: absolute; inset: 0;
  background-image:
    linear-gradient(var(--line) 1px, transparent 1px),
    linear-gradient(90deg, var(--line) 1px, transparent 1px);
  background-size: 44px 44px;
  mask-image: radial-gradient(circle at 50% 20%, black, transparent 75%);
  opacity: .46;
}
.ambient-wave { position: absolute; inset: 0; width: 100%; height: 100%; opacity: .42; }
.ambient-line { fill: none; stroke: rgba(103,232,249,.32); stroke-width: 1.1; stroke-dasharray: 7 14; animation: dash 22s linear infinite; }
@keyframes dash { to { stroke-dashoffset: -400; } }

.topbar {
  position: fixed; left: 50%; top: 16px; transform: translateX(-50%); z-index: 20;
  width: min(1220px, calc(100% - 34px));
  border-radius: 24px;
  min-height: 68px;
  padding: 10px 12px;
  display: flex; align-items: center; gap: 12px;
}
.brand {
  display: flex; align-items: center; gap: 12px;
  border: 0; background: transparent; color: var(--text); padding: 7px 10px; border-radius: 18px;
}
.brand:hover { background: rgba(125,211,252,.12); }
.brand-mark {
  width: 42px; height: 42px; border-radius: 50%; display: grid; place-items: center;
  background: linear-gradient(145deg, #0f172a, #1e3a8a 55%, #67e8f9);
  color: #fff; font-family: Playfair Display, serif; font-size: 25px; box-shadow: 0 0 28px rgba(103,232,249,.28);
}
.brand strong { display: block; font-weight: 800; letter-spacing: .03em; }
.brand em { display: block; font-style: normal; font-size: 11px; color: var(--muted); }
.topnav { display: flex; gap: 5px; overflow-x: auto; flex: 1; justify-content: center; padding: 2px; }
.topnav button, .theme-toggle {
  border: 1px solid var(--line); color: var(--text); background: rgba(255,255,255,.08);
  border-radius: 999px; padding: 9px 12px; transition: .25s ease;
}
.topnav button:hover, .topnav button.active, .theme-toggle:hover {
  transform: translateY(-2px); background: rgba(103,232,249,.16); border-color: rgba(103,232,249,.5);
}
.theme-toggle { white-space: nowrap; }

.page-rise { animation: rise .55s cubic-bezier(.2,.8,.2,1) both; }
@keyframes rise { from { opacity: 0; transform: translateY(16px); } to { opacity: 1; transform: translateY(0); } }

.hero-grid { display: grid; grid-template-columns: 1.05fr .95fr; gap: 22px; align-items: stretch; min-height: 590px; }
.hero-copy { padding: 64px 6px 36px; }
.eyebrow { margin: 0 0 12px; color: var(--accent); text-transform: uppercase; letter-spacing: .16em; font-size: 12px; font-weight: 800; }
h1, h2, h3 { margin: 0; line-height: 1.08; }
h1 { font-family: Playfair Display, Source Serif 4, serif; font-size: clamp(48px, 8vw, 102px); letter-spacing: -.045em; }
h1 span { color: transparent; background: linear-gradient(90deg, #67e8f9, #a78bfa, #fbbf24); background-clip: text; -webkit-background-clip: text; }
h2 { font-family: Playfair Display, Source Serif 4, serif; font-size: clamp(28px, 4vw, 48px); letter-spacing: -.025em; }
h3 { font-size: 22px; }
.hero-lead { color: var(--muted); font-size: clamp(17px, 2vw, 21px); line-height: 1.8; max-width: 740px; }
.hero-actions { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 28px; }
.primary-btn, .ghost-btn, .back-btn, .module-next button {
  border: 1px solid transparent; border-radius: 999px; padding: 12px 18px; transition: .25s ease;
}
.primary-btn { background: linear-gradient(135deg, #1d4ed8, #06b6d4); color: white; box-shadow: 0 12px 30px rgba(6,182,212,.22); }
.ghost-btn, .back-btn, .module-next button { background: rgba(255,255,255,.08); color: var(--text); border-color: var(--line); }
.primary-btn:hover, .ghost-btn:hover, .back-btn:hover, .module-next button:hover { transform: translateY(-2px); filter: brightness(1.06); }

.earth-panel { border-radius: 34px; padding: 20px; display: grid; grid-template-rows: 1fr auto; min-height: 570px; overflow: hidden; }
.earth-svg { width: 100%; height: min(72vh, 480px); }
.earth-ring { cursor: pointer; outline: none; transition: .25s ease; }
.earth-ring:hover circle:first-child { stroke-width: 4; opacity: 1; }
.ray-orbit { fill: none; stroke: #67e8f9; stroke-width: 2; stroke-dasharray: 8 10; animation: dash 10s linear infinite; filter: drop-shadow(0 0 8px rgba(103,232,249,.7)); }
.ray-orbit.delay { animation-duration: 15s; stroke: #fbbf24; opacity: .75; }
.quake-dot { fill: #fb7185; filter: drop-shadow(0 0 14px #fb7185); animation: pulse 1.8s infinite; }
@keyframes pulse { 50% { transform: scale(1.25); opacity: .7; } }
.earth-label, .svg-label { fill: var(--text); font: 700 16px Inter; }
.svg-label.small, .earth-label { font-size: 12px; fill: var(--muted); }
.earth-list { display: grid; gap: 8px; grid-template-columns: repeat(2, 1fr); }
.earth-list button { display: flex; align-items: center; gap: 8px; padding: 10px; border: 1px solid var(--line); border-radius: 14px; background: rgba(255,255,255,.06); color: var(--text); }
.earth-list span { width: 10px; height: 10px; border-radius: 999px; }

.question-panel { margin-top: 22px; border-radius: 34px; padding: 28px; display: grid; grid-template-columns: .8fr 1.2fr; gap: 22px; }
.question-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; }
.mini-card { padding: 18px; border-radius: 22px; border: 1px solid var(--line); background: rgba(255,255,255,.08); }
.mini-card p { margin-bottom: 0; color: var(--muted); line-height: 1.65; }
.module-grid { margin-top: 22px; display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
.module-card { text-align: left; color: var(--text); border-radius: 26px; padding: 22px; min-height: 210px; transition: .28s cubic-bezier(.2,.8,.2,1); position: relative; overflow: hidden; }
.module-card::before { content: ''; position: absolute; inset: auto 18px 0 18px; height: 4px; border-radius: 99px; background: var(--accent); box-shadow: 0 0 22px var(--accent); }
.module-card:hover { transform: translateY(-8px) scale(1.01); border-color: color-mix(in srgb, var(--accent), transparent 35%); }
.module-icon { font-size: 36px; color: var(--accent); }
.module-id { float: right; color: var(--muted); font-weight: 800; }
.module-card h3 { margin-top: 18px; }
.module-card p { color: var(--muted); line-height: 1.55; }
.module-card small { color: var(--accent); font-weight: 800; }

.module-page { padding-bottom: 30px; }
.module-hero { border-radius: 34px; padding: 34px; position: relative; overflow: hidden; }
.module-hero::after { content: ''; position: absolute; right: -70px; top: -120px; width: 300px; height: 300px; border-radius: 50%; background: radial-gradient(circle, var(--accent), transparent 62%); opacity: .18; }
.module-hero h1 { font-size: clamp(40px, 6vw, 78px); }
.formula-pill { display: inline-block; margin-top: 20px; border: 1px solid color-mix(in srgb, var(--accent), transparent 50%); background: rgba(103,232,249,.08); border-radius: 18px; padding: 12px 16px; color: var(--text); }
.back-btn { margin-bottom: 24px; }
.content-grid { display: grid; grid-template-columns: 1.35fr .65fr; gap: 20px; margin-top: 20px; }
.knowledge-card, .prof-note, .interactive-zone, .quiz, .accordion, .module-next, .code-lab { border-radius: 30px; padding: 26px; }
.knowledge-card p, .prof-note p, .accordion-body, .quiz-result, .sim-explain { color: var(--muted); line-height: 1.75; }
.formula-card { border: 1px solid var(--line); border-radius: 22px; padding: 18px; margin: 22px 0; background: rgba(255,255,255,.07); overflow-x: auto; }
.formula-card span { display: block; color: var(--accent); font-weight: 800; margin-bottom: 8px; }
.bullet-list p { margin: 12px 0; }
.prof-note { align-self: start; position: sticky; top: 110px; }
.prof-avatar { width: 50px; height: 50px; border-radius: 50%; display: grid; place-items: center; background: linear-gradient(135deg, var(--accent), #1d4ed8); color: white; font-weight: 900; margin-bottom: 18px; }

.interactive-zone { margin-top: 20px; }
.zone-title { margin-bottom: 20px; }
.interactive-grid { display: grid; grid-template-columns: 1.15fr .85fr; gap: 18px; align-items: start; }
.interactive-grid.two { grid-template-columns: 1fr .8fr; }
.sim-card, .control-panel { border: 1px solid var(--line); border-radius: 26px; background: rgba(255,255,255,.06); padding: 18px; }
.wide-svg { width: 100%; min-height: 310px; display: block; }
.chart-card canvas { width: 100%; height: auto; display: block; background: rgba(255,255,255,.03); border-radius: 18px; }
.control-panel { display: grid; gap: 16px; }
.slider-row { display: grid; gap: 8px; }
.slider-row span { display: flex; justify-content: space-between; color: var(--muted); }
.slider-row strong { color: var(--text); }
input[type="range"] { width: 100%; accent-color: var(--accent); }
.numbers { display: grid; grid-template-columns: repeat(2, minmax(0,1fr)); gap: 10px; }
.numbers.big { grid-template-columns: 1fr; }
.numbers span { border: 1px solid var(--line); border-radius: 16px; padding: 11px; background: rgba(255,255,255,.06); font-size: 14px; color: var(--text); }
hr { width: 100%; border: 0; border-top: 1px solid var(--line); }
.scan-ray { fill: none; stroke: rgba(103,232,249,.45); stroke-width: 1.3; stroke-dasharray: 4 8; animation: dash 6s linear infinite; }
.bar-stack { display: grid; gap: 12px; }
.metric-bar { display: grid; grid-template-columns: 120px 1fr 34px; gap: 10px; align-items: center; font-size: 13px; }
.metric-bar div { height: 10px; border-radius: 999px; background: rgba(148,163,184,.22); overflow: hidden; }
.metric-bar i { display: block; height: 100%; border-radius: inherit; background: linear-gradient(90deg, #1d4ed8, #67e8f9); }

.sphere-ray { fill: none; stroke: #67e8f9; stroke-width: 3.4; stroke-dasharray: 9 10; animation: dash 7s linear infinite; filter: drop-shadow(0 0 10px rgba(103,232,249,.55)); }
.sphere-ray.faint { stroke: #a78bfa; opacity: .5; animation-duration: 10s; }
.phase-path { fill: none; stroke: rgba(148,163,184,.5); stroke-width: 5; stroke-linecap: round; cursor: pointer; transition: .25s ease; }
.phase-path:hover, .phase-path.active { stroke-width: 8; filter: drop-shadow(0 0 12px currentColor); }
.phase-path.active { stroke: #67e8f9; }
.phase-path.s.active { stroke: #f0abfc; }
.phase-path.pp.active { stroke: #fbbf24; }
.phase-path.pcp.active { stroke: #fb7185; }
.phase-path.pkp.active, .phase-path.pkikp.active { stroke: #fbbf24; }
.phase-path.diff.active { stroke: #a78bfa; }
.phase-panel h3 { font-family: Playfair Display, serif; font-size: 68px; color: var(--accent); }
.phase-buttons { display: flex; flex-wrap: wrap; gap: 8px; }
.phase-buttons button, .toggle-group button { border: 1px solid var(--line); background: rgba(255,255,255,.07); color: var(--text); border-radius: 999px; padding: 9px 12px; }
.phase-buttons button.active, .toggle-group button.active { background: rgba(103,232,249,.16); border-color: var(--accent); }
.toggle-group { display: flex; gap: 10px; flex-wrap: wrap; }
.wavefront { stroke-width: 3; stroke-dasharray: 10 10; animation: dash 8s linear infinite; }
.wavefront.fast { stroke: #67e8f9; }
.wavefront.slow { stroke: #fb7185; animation-duration: 12s; }
.split-wave { fill: none; stroke: #fbbf24; stroke-width: 3; filter: drop-shadow(0 0 10px rgba(251,191,36,.38)); }

.accordion-zone { margin-top: 20px; display: grid; gap: 12px; }
.accordion { padding: 0; overflow: hidden; }
.accordion > button { width: 100%; display: flex; align-items: center; justify-content: space-between; padding: 20px 24px; border: 0; background: transparent; color: var(--text); font-weight: 800; }
.accordion-body { padding: 0 24px 22px; }
.accordion-body li { margin: 10px 0; }
.quiz { margin-top: 20px; }
.quiz-options { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-top: 18px; }
.quiz-options button { border: 1px solid var(--line); border-radius: 18px; padding: 16px; background: rgba(255,255,255,.06); color: var(--text); transition: .25s ease; }
.quiz-options button:hover { transform: translateY(-2px); }
.quiz-options button.correct { border-color: #22c55e; background: rgba(34,197,94,.15); }
.quiz-options button.wrong { border-color: #fb7185; background: rgba(251,113,133,.15); }
.quake-feedback { animation: shake .36s ease; }
@keyframes shake { 0%,100% { transform: translateX(0); } 20% { transform: translateX(-4px); } 40% { transform: translateX(4px); } 60% { transform: translateX(-3px); } 80% { transform: translateX(3px); } }
.module-next { margin-top: 20px; display: flex; justify-content: space-between; gap: 12px; }

.code-lab-section { margin-top: 24px; scroll-margin-top: 120px; }
.code-lab { margin-top: 0; }
.lab-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
.editor-panel, .output-panel { border: 1px solid var(--line); border-radius: 24px; overflow: hidden; background: rgba(2,6,23,.15); }
.editor-toolbar { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; padding: 12px; border-bottom: 1px solid var(--line); }
.editor-toolbar span { color: var(--muted); font-size: 13px; }
.editor-panel textarea {
  width: 100%; min-height: 520px; border: 0; resize: vertical; padding: 18px;
  background: rgba(2,6,23,.82); color: #e2e8f0; font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; line-height: 1.55;
}
.output-panel { padding: 14px; }
.output-panel pre { min-height: 90px; white-space: pre-wrap; color: var(--muted); margin: 0 0 14px; }
.output-panel img { width: 100%; border-radius: 18px; background: white; }
.empty-output { min-height: 360px; display: grid; place-items: center; border: 1px dashed var(--line); border-radius: 18px; color: var(--muted); }
.footer { text-align: center; color: var(--muted); padding: 30px; font-size: 13px; }

@media (max-width: 980px) {
  main { padding-top: 126px; }
  .topbar { flex-wrap: wrap; }
  .topnav { order: 3; flex-basis: 100%; justify-content: flex-start; }
  .hero-grid, .content-grid, .interactive-grid, .interactive-grid.two, .question-panel, .lab-grid { grid-template-columns: 1fr; }
  .module-grid { grid-template-columns: repeat(2, 1fr); }
  .question-grid, .quiz-options { grid-template-columns: 1fr; }
  .prof-note { position: static; }
}
@media (max-width: 620px) {
  main { width: min(100% - 20px, 1220px); }
  .module-grid, .numbers { grid-template-columns: 1fr; }
  .hero-copy { padding-top: 30px; }
  .earth-list { grid-template-columns: 1fr; }
  .module-hero, .knowledge-card, .interactive-zone, .quiz, .code-lab { padding: 20px; border-radius: 24px; }
  .brand em { display: none; }
}

EOF_src_styles_css

cat > '.github/workflows/deploy.yml' <<'EOF__github_workflows_deploy_yml'
name: Deploy SeismoCore Explore

on:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 20
      - name: Install dependencies
        run: npm install
      - name: Build
        run: npm run build
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./dist

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4

EOF__github_workflows_deploy_yml

echo '完成：已建立 SeismoCore Explore 專案檔案。接著執行 npm install && npm run dev'
