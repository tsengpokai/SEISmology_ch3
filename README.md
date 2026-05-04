# 震探地心 SeismoCore Explore

互動式教學網頁：地震學第三章「地震波與地球結構」。本專案保留 React + Vite 動態互動功能，並已提供可直接部署到 GitHub Pages 的 `docs/` 打包版。

## 正式部署

到 GitHub Repo：

```text
Settings > Pages > Deploy from a branch > main > /docs
```

不要選 `main / root`，因為 root 是 Vite 原始碼。

## 本機 / Codespaces 開發預覽

```bash
npm install --no-audit --no-fund --progress=false
npm run dev
```

## 重新產生 docs

```bash
npm run deploy:docs
```

## 功能

- 母導覽頁：動態地球剖面、第三章關鍵三問、8 個章節入口。
- 子章節 3.1–3.8：每節包含摘要、公式、教授小提醒、互動模擬、課本圖片圖說與 Quiz。
- 互動內容：折射/反射 T-x 沙盒、Dix 方程式、球體地球射線彎曲、體波相位挑戰、SPO/LPO 非均向性、Q 值衰減、密度壓力互動圖。
- 支援深色 / 淺色模式、MathJax LaTeX、響應式版面。
