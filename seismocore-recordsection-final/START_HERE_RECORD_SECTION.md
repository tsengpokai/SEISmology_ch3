# 這次新增了什麼？

新增子頁：**繪製走時與波形剖面圖**。

你可以在首頁章節卡片或上方導覽列看到「實作」按鈕，點進去即可看到：

1. 彩色版走時與波形剖面圖。
2. 黑白版 Record Section。
3. 中央氣象署地震報告截圖。
4. 資料處理流程與圖表解讀。
5. 互動式讀圖輔助標籤與滑桿。

## 在 Codespaces 更新後要執行

```bash
npm install --no-audit --no-fund --progress=false
npm run deploy:docs
git add .
git commit -m "Add record section project page"
git push
```

GitHub Pages 設定維持：

```text
Branch: main
Folder: /docs
```
