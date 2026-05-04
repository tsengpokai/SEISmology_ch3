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
