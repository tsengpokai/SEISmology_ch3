# SeismoCore Explore 啟動說明

這是保留 React/Vite 動態功能的版本，不是純靜態版。為避免 Codespaces 上 `npm install` 卡住，本壓縮檔已附 `node_modules`，可直接啟動。

## 最穩定啟動方式

```bash
npm run dev
```

Codespaces 會跳出 5173 Port，按 Open in Browser。

## 不要一開始就跑 npm install

此包已附 `node_modules`。若你執行 `npm install` 時遇到 `Exit handler never called!`，通常是 npm 快取或 npm 本身卡住，不是 React 程式碼錯誤。

## 若一定要重裝

```bash
npm cache clean --force
rm -rf ~/.npm/_cacache ~/.npm/_logs node_modules package-lock.json dist .vite
npm install --no-audit --no-fund --progress=false --legacy-peer-deps
npm run dev
```

## 部署 GitHub Pages

本專案保留 `.github/workflows/deploy.yml`，push 到 main 後可由 GitHub Actions 建置與部署。
