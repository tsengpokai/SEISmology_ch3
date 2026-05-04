# 震探地心 SeismoCore Explore

互動式地震學第三章教學網頁：地震波與地球結構。

## 本修正版內容

- 保留原始深藍／板岩灰／象牙白網頁設計與互動模擬。
- 新增 `public/textbook/` 課本圖片資料夾，共 22 張 webp 圖片。
- 在 3.1–3.8 各子章節加入「課本圖像輔助說明」區塊與中文圖說。
- 修正圖片路徑，改用 `import.meta.env.BASE_URL` 產生相對於 GitHub Pages repo 的正確路徑。
- 新增圖片載入失敗提示與 React ErrorBoundary，避免錯誤時只出現空白頁。
- 將 React / Vite 版本固定為穩定版本，降低 Codespaces 與 GitHub Pages 部署差異。

## 在 GitHub Codespaces 預覽

```bash
npm install
npm run dev
```

開啟 Codespaces 跳出的預覽網址即可。

## 打包測試

```bash
npm run build
```

本版本已通過 `npm run build`。

## GitHub Pages

已提供 `.github/workflows/deploy.yml`，推送到 `main` 或 `master` 後可透過 GitHub Pages Actions 部署。

若要啟用 Pages：

1. 進入 Repository 的 Settings。
2. 左側選 Pages。
3. Source 選 GitHub Actions。
4. 推送程式碼後等待 Actions 完成。

## 真實 SAC / ObsPy 繪圖

`local_obspy_plot.py` 是本機版 ObsPy 繪圖腳本，用於真實 SAC 波形資料；瀏覽器內的 Seismo-Code Lab 則使用 synthetic waveforms 示範 Record Section。
