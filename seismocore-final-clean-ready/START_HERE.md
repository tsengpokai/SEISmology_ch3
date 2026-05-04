# 先看這裡：GitHub Pages 正確部署方式

你的網頁目前空白，主因不是 React 程式壞掉，而是 GitHub Pages 正在讀取「Vite 開發用 index.html」，它裡面還寫著：

```html
<script type="module" src="/src/main.jsx"></script>
```

GitHub Pages 不會自動把 JSX 編譯成瀏覽器可直接執行的 JavaScript，因此會空白。

本修正版保留 React + Vite 動態互動版，並額外提供 `docs/` 資料夾。`docs/` 已經是打包好的網站，可直接給 GitHub Pages 顯示。

## 使用方式

1. 將本資料夾全部上傳 / 覆蓋到你的 GitHub repo。
2. 到 GitHub repo 的 `Settings > Pages`。
3. Source 選 `Deploy from a branch`。
4. Branch 選 `main`，資料夾選 `/docs`。
5. 儲存後等待約 1–3 分鐘，再開啟：

```text
https://tsengpokai.github.io/SEISmology_ch3/
```

## 重要

不要把 GitHub Pages 設成 `main / root`，因為 root 是 Vite 原始碼，不是打包後網站。

若要在 Codespaces 預覽原始碼版本，可用：

```bash
npm install --no-audit --no-fund --progress=false
npm run dev
```

但只要是正式 GitHub Pages 部署，請用 `main / docs`。
