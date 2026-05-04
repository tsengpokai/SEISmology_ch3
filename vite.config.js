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
