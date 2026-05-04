#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
if [ ! -d "$ROOT/docs" ] || [ ! -f "$ROOT/docs/index.html" ]; then
  echo "⚠️  請在專案根目錄執行，例如 /workspaces/SEISmology_ch3"
  echo "目前位置：$ROOT"
  exit 1
fi

# 1) 先把常見 TeX 上標寫法改成更保守的 {2}，避免後續重新 typeset 時出現 merror。
python3 - "$ROOT" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1])
files = []
for pattern in ["docs/assets/*.js", "src/App.jsx"]:
    files.extend(root.glob(pattern))

repls = {
    "T(x)^2": "T(x)^{2}",
    "t_0^2": "t_0^{2}",
    "x^2": "x^{2}",
    "v^2": "v^{2}",
    "v_n^2": "v_n^{2}",
    "V_{rms,n}^2": "V_{rms,n}^{2}",
    "V_{rms,n-1}^2": "V_{rms,n-1}^{2}",
    "v_{rms}^2": "v_{rms}^{2}",
    "A(t)=A_0e^{-\\omega_0t/2Q}": "A(t)=A_0 e^{-\\omega_0 t/(2Q)}",
    "E(t)=E_0e^{-\\omega_0t/Q}": "E(t)=E_0 e^{-\\omega_0 t/Q}",
    "C/Ma^2": "C/Ma^{2}",
    "5.97\\times10^{24}": "5.97\\times 10^{24}",
}
for p in files:
    if not p.exists():
        continue
    s = p.read_text(encoding="utf-8", errors="ignore")
    old = s
    for a,b in repls.items():
        s = s.replace(a,b)
    if s != old:
        p.write_text(s, encoding="utf-8")
        print(f"patched formula text: {p}")
PY

# 2) 加入前端清除器：移除 MathJax 產生的 Missing open brace 顯示，不影響其他內容。
cat > "$ROOT/docs/remove_mathjax_errors.js" <<'JS'
(function(){
  if (window.__REMOVE_MATHJAX_ERRORS__) return;
  window.__REMOVE_MATHJAX_ERRORS__ = true;

  function addStyle(){
    if (document.getElementById('remove-mathjax-errors-style')) return;
    const style = document.createElement('style');
    style.id = 'remove-mathjax-errors-style';
    style.textContent = `
      mjx-container svg g[data-mml-node="merror"],
      mjx-container .mjx-merror {
        display: none !important;
        visibility: hidden !important;
      }
      mjx-container:has(svg g[data-mml-node="merror"]),
      mjx-container:has(.mjx-merror) {
        display: none !important;
        visibility: hidden !important;
      }
    `;
    document.head.appendChild(style);
  }

  function removeErrorNodes(){
    const patterns = [
      /Missing open brace for superscript/i,
      /Missing open brace/i,
      /TeX parse error/i
    ];

    document.querySelectorAll('mjx-container').forEach((el) => {
      const text = el.textContent || '';
      if (patterns.some((re) => re.test(text))) {
        el.remove();
      }
    });

    document.querySelectorAll('svg, span, div').forEach((el) => {
      if (el.children.length > 0 && el.tagName.toLowerCase() !== 'svg') return;
      const text = (el.textContent || '').trim();
      if (text && patterns.some((re) => re.test(text))) {
        const mjx = el.closest('mjx-container');
        if (mjx) mjx.remove();
        else el.remove();
      }
    });
  }

  function run(){
    addStyle();
    removeErrorNodes();
  }

  document.addEventListener('DOMContentLoaded', run);
  window.addEventListener('load', run);
  setTimeout(run, 100);
  setTimeout(run, 500);
  setTimeout(run, 1200);
  const mo = new MutationObserver(run);
  if (document.body) mo.observe(document.body, {childList:true, subtree:true, characterData:true});
})();
JS

# 3) 插入到 docs/index.html；若已存在則不重複插入。
python3 - "$ROOT/docs/index.html" <<'PY'
from pathlib import Path
import sys, re
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')
tag = '<script src="./remove_mathjax_errors.js"></script>'
if 'remove_mathjax_errors.js' not in s:
    if '</body>' in s:
        s = s.replace('</body>', '  ' + tag + '\n</body>')
    else:
        s += '\n' + tag + '\n'
p.write_text(s, encoding='utf-8')
PY

touch "$ROOT/docs/.nojekyll"

echo "✅ 已移除 MathJax 的 Missing open brace 顯示，並修正常見上標公式寫法。"
echo "下一步：git add . && git commit -m 'Remove MathJax superscript error messages' && git push"
