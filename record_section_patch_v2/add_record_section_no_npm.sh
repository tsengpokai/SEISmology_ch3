#!/usr/bin/env bash
set -euo pipefail

# No-npm patch for SeismoCore Explore.
# It adds a dynamic standalone subpage under docs/record-section/ and injects a safe entry button into docs/index.html.

ROOT="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSET_DIR="$SCRIPT_DIR/assets"

if [ ! -f "$ROOT/package.json" ] && [ ! -f "$ROOT/index.html" ] && [ ! -d "$ROOT/docs" ]; then
  echo "⚠️  請在專案根目錄執行，例如 /workspaces/SEISmology_ch3"
  echo "目前位置：$ROOT"
  exit 1
fi

if [ ! -d "$ASSET_DIR" ]; then
  echo "⚠️  找不到 assets 資料夾。請先解壓整個 seismocore-record-section-no-npm-patch.zip，再執行本腳本。"
  exit 1
fi

mkdir -p "$ROOT/docs/record-section"
mkdir -p "$ROOT/record-section"

cp "$ASSET_DIR/record_section_color.png" "$ROOT/docs/record-section/record_section_color.png"
cp "$ASSET_DIR/record_section_bw.png" "$ROOT/docs/record-section/record_section_bw.png"
cp "$ASSET_DIR/cwa_report.png" "$ROOT/docs/record-section/cwa_report.png"
cp "$ASSET_DIR/record_section_color.png" "$ROOT/record-section/record_section_color.png"
cp "$ASSET_DIR/record_section_bw.png" "$ROOT/record-section/record_section_bw.png"
cp "$ASSET_DIR/cwa_report.png" "$ROOT/record-section/cwa_report.png"

touch "$ROOT/docs/.nojekyll" || true

cat > "$ROOT/docs/record-section/index.html" <<'HTML'
<!doctype html>
<html lang="zh-Hant">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>繪製走時與波形剖面圖｜SeismoCore Explore</title>
  <meta name="description" content="利用 Taiwan GDMS / CWASN SAC 地震資料繪製 Record Section 走時與波形剖面圖的互動作品頁。" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700;800&family=Source+Serif+4:opsz,wght@8..60,400;8..60,600;8..60,700&display=swap" rel="stylesheet">
  <style>
    :root{
      --bg:#081321; --panel:#0f2033; --panel2:#13283f; --text:#eef5f8; --muted:#9eb2c4;
      --ivory:#fff8e7; --gold:#d9b76f; --cyan:#78d2ff; --blue:#14345a; --line:rgba(255,255,255,.12);
      --shadow:0 20px 70px rgba(0,0,0,.35); --radius:28px;
    }
    :root.light{--bg:#f7f4ed;--panel:#fffffb;--panel2:#f1eee7;--text:#172335;--muted:#5c6a7d;--ivory:#172335;--gold:#9b6a1d;--cyan:#0c6b96;--blue:#e9eef7;--line:rgba(14,30,52,.14);--shadow:0 18px 60px rgba(26,40,60,.14)}
    *{box-sizing:border-box} html{scroll-behavior:smooth} body{margin:0;font-family:Inter,system-ui,-apple-system,"Noto Sans TC",sans-serif;background:var(--bg);color:var(--text);overflow-x:hidden}
    body::before{content:"";position:fixed;inset:0;pointer-events:none;z-index:-2;background:
      radial-gradient(circle at 12% 18%,rgba(120,210,255,.22),transparent 28%),
      radial-gradient(circle at 82% 12%,rgba(217,183,111,.16),transparent 26%),
      linear-gradient(120deg,rgba(255,255,255,.045) 1px,transparent 1px),
      linear-gradient(30deg,rgba(255,255,255,.035) 1px,transparent 1px);background-size:auto,auto,48px 48px,72px 72px}
    body::after{content:"";position:fixed;inset:0;pointer-events:none;z-index:-1;opacity:.18;background-image:url("data:image/svg+xml,%3Csvg width='900' height='220' viewBox='0 0 900 220' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M0 110 C70 45 120 180 190 110 S320 45 390 110 520 180 590 110 720 45 790 110 860 180 900 110' fill='none' stroke='%23ffffff' stroke-width='1.3'/%3E%3Cpath d='M0 145 C70 80 120 215 190 145 S320 80 390 145 520 215 590 145 720 80 790 145 860 215 900 145' fill='none' stroke='%23ffffff' stroke-width='.7'/%3E%3C/svg%3E");animation:drift 24s linear infinite}
    @keyframes drift{from{background-position:0 0}to{background-position:900px 0}}
    .nav{position:sticky;top:0;z-index:20;display:flex;align-items:center;justify-content:space-between;padding:14px 5vw;background:color-mix(in srgb,var(--bg) 84%,transparent);backdrop-filter:blur(18px);border-bottom:1px solid var(--line)}
    .brand{display:flex;gap:12px;align-items:center;text-decoration:none;color:var(--text);font-weight:800}.brand-mark{width:38px;height:38px;border-radius:50%;background:conic-gradient(from 160deg,var(--cyan),var(--gold),#274a72,var(--cyan));box-shadow:0 0 26px rgba(120,210,255,.35)}
    .nav-actions{display:flex;gap:10px;align-items:center}.pill{border:1px solid var(--line);background:rgba(255,255,255,.06);color:var(--text);border-radius:999px;padding:10px 14px;text-decoration:none;font-weight:700;cursor:pointer}.pill:hover{transform:translateY(-1px);border-color:color-mix(in srgb,var(--cyan) 60%,var(--line))}
    .hero{min-height:78vh;display:grid;grid-template-columns:1.04fr .96fr;gap:34px;align-items:center;padding:70px 5vw 40px}.eyebrow{color:var(--gold);font-weight:800;letter-spacing:.14em;text-transform:uppercase;font-size:.82rem}.hero h1{font-family:"Playfair Display","Noto Serif TC",serif;font-size:clamp(2.55rem,6vw,6.6rem);line-height:.96;margin:14px 0}.lead{font-size:clamp(1.03rem,1.8vw,1.28rem);line-height:1.8;color:var(--muted);max-width:790px}.hero-card{background:linear-gradient(150deg,rgba(255,255,255,.1),rgba(255,255,255,.035));border:1px solid var(--line);border-radius:var(--radius);padding:24px;box-shadow:var(--shadow);position:relative;overflow:hidden}.hero-card::before{content:"";position:absolute;inset:-35%;background:radial-gradient(circle,rgba(120,210,255,.16),transparent 35%);animation:pulse 5s ease-in-out infinite}.hero-card>*{position:relative}.hero-stats{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-top:22px}.stat{padding:16px;border-radius:20px;background:rgba(255,255,255,.055);border:1px solid var(--line)}.stat b{display:block;font-size:1.4rem;color:var(--cyan)}
    @keyframes pulse{50%{transform:scale(1.08);opacity:.55}}
    .figure-stage{position:relative;border-radius:24px;overflow:hidden;border:1px solid var(--line);background:#fff;min-height:420px;display:grid;place-items:center}.figure-stage img{width:100%;height:100%;max-height:620px;object-fit:contain;display:block;background:#fff}.overlay{position:absolute;inset:0;pointer-events:none;opacity:0;transition:.35s}.overlay.on{opacity:1}.trend{position:absolute;left:8%;right:7%;top:13%;height:78%;}.tag{position:absolute;background:rgba(8,19,33,.88);color:#fff;border:1px solid rgba(255,255,255,.25);border-radius:999px;padding:8px 12px;font-weight:800;font-size:.86rem;box-shadow:0 10px 28px rgba(0,0,0,.25)}.tag1{left:12%;top:24%}.tag2{left:42%;top:49%}.tag3{right:10%;bottom:14%}.tag4{right:10%;top:8%}
    .controls{display:flex;flex-wrap:wrap;gap:12px;margin-top:16px}.seg{display:flex;border:1px solid var(--line);border-radius:18px;overflow:hidden;background:rgba(255,255,255,.045)}.seg button{border:0;background:transparent;color:var(--text);padding:12px 15px;font-weight:800;cursor:pointer}.seg button.active{background:linear-gradient(135deg,var(--cyan),var(--gold));color:#06111d}.control-card{flex:1;min-width:230px;border:1px solid var(--line);border-radius:18px;background:rgba(255,255,255,.045);padding:14px}.control-card label{display:flex;justify-content:space-between;font-weight:800;color:var(--text);margin-bottom:8px}.control-card input{width:100%}
    .section{padding:44px 5vw}.grid{display:grid;grid-template-columns:repeat(12,1fr);gap:18px}.card{grid-column:span 4;background:linear-gradient(145deg,rgba(255,255,255,.085),rgba(255,255,255,.035));border:1px solid var(--line);border-radius:24px;padding:24px;box-shadow:var(--shadow)}.wide{grid-column:span 8}.full{grid-column:1/-1}.card h2,.card h3{font-family:"Playfair Display","Noto Serif TC",serif;margin:0 0 12px}.card p,.card li{color:var(--muted);line-height:1.85}.card ul{padding-left:1.2rem}.step{display:flex;gap:14px;margin:14px 0}.num{width:34px;height:34px;border-radius:50%;display:grid;place-items:center;flex:0 0 34px;background:var(--blue);color:var(--cyan);border:1px solid var(--line);font-weight:900}.quote{font-family:"Source Serif 4","Noto Serif TC",serif;font-size:1.2rem;color:var(--ivory);line-height:1.8}.mini{font-size:.92rem}.analysis-table{width:100%;border-collapse:collapse;overflow:hidden;border-radius:18px}.analysis-table th,.analysis-table td{border:1px solid var(--line);padding:13px;text-align:left;vertical-align:top}.analysis-table th{color:var(--gold);background:rgba(255,255,255,.055)}
    .quiz button{width:100%;text-align:left;margin:8px 0;padding:13px 14px;border-radius:16px;border:1px solid var(--line);background:rgba(255,255,255,.045);color:var(--text);cursor:pointer}.quiz button.good{background:rgba(95,210,150,.2);border-color:rgba(95,210,150,.55)}.shake{animation:shake .35s linear}@keyframes shake{25%{transform:translateX(4px)}50%{transform:translateX(-4px)}75%{transform:translateX(2px)}}
    .footer{padding:34px 5vw 70px;color:var(--muted);text-align:center}.backtop{position:fixed;right:20px;bottom:20px;z-index:30}.badge{display:inline-flex;gap:7px;align-items:center;border:1px solid var(--line);border-radius:999px;padding:8px 12px;color:var(--muted);font-size:.88rem;margin:4px;background:rgba(255,255,255,.045)}
    @media (max-width:960px){.hero{grid-template-columns:1fr;padding-top:42px}.card,.wide{grid-column:1/-1}.hero-stats{grid-template-columns:1fr}.figure-stage{min-height:280px}.nav{align-items:flex-start}.nav-actions{flex-wrap:wrap;justify-content:flex-end}}
  </style>
</head>
<body>
  <nav class="nav">
    <a class="brand" href="../"><span class="brand-mark"></span><span>SeismoCore Explore</span></a>
    <div class="nav-actions"><a class="pill" href="../">返回主網站</a><button class="pill" id="themeBtn">亮暗切換</button></div>
  </nav>

  <header class="hero">
    <div>
      <div class="eyebrow">Student Research Lab｜Taiwan GDMS × CWASN</div>
      <h1>繪製走時與波形剖面圖</h1>
      <p class="lead">這個作品頁記錄我從 Taiwan GDMS 取得地震資料後，透過 Antigravity 協助設計 Python / ObsPy 流程，將多測站 SAC 波形整理成 Record Section。它把「每個測站收到地震波的時間」依照震央距排列，讓原本分散的地震紀錄變成可以判讀波傳路徑、初達波與能量衰減的視覺化剖面。</p>
      <div class="hero-stats">
        <div class="stat"><b>117</b><span>有效測站波形</span></div>
        <div class="stat"><b>0.5–5 Hz</b><span>帶通濾波範圍</span></div>
        <div class="stat"><b>130 s</b><span>截取時間窗</span></div>
      </div>
      <div style="margin-top:18px">
        <span class="badge">事件時間：2026-05-01 12:39:55 UTC</span>
        <span class="badge">資料來源：CWA / CWASN / GDMS</span>
        <span class="badge">工具：ObsPy + Matplotlib</span>
      </div>
    </div>
    <div class="hero-card">
      <div class="figure-stage" id="stage">
        <img id="mainFigure" src="record_section_color.png" alt="彩色地震走時與波形剖面圖">
        <div class="overlay on" id="overlay">
          <svg class="trend" viewBox="0 0 1000 680" preserveAspectRatio="none">
            <path d="M70 105 C230 145 350 230 500 330 C650 425 760 520 930 610" fill="none" stroke="rgba(120,210,255,.92)" stroke-width="6" stroke-linecap="round" stroke-dasharray="16 12"/>
            <path d="M70 170 C260 190 430 265 590 365 C720 445 820 515 930 560" fill="none" stroke="rgba(217,183,111,.9)" stroke-width="4" stroke-linecap="round" stroke-dasharray="8 14"/>
          </svg>
          <span class="tag tag1">近震央測站：較早出現強振幅</span>
          <span class="tag tag2">能量帶隨距離向晚時間移動</span>
          <span class="tag tag3">遠距測站：波形較分散、頻率較低</span>
          <span class="tag tag4">讀圖輔助線</span>
        </div>
      </div>
      <div class="controls">
        <div class="seg" aria-label="切換圖像">
          <button class="active" data-img="color">彩色成果圖</button>
          <button data-img="bw">黑白初版圖</button>
          <button data-img="report">CWA 地震報告</button>
        </div>
        <button class="pill" id="overlayBtn">顯示 / 隱藏讀圖輔助</button>
      </div>
      <div class="controls">
        <div class="control-card"><label>amp_scale 波形放大倍率 <span id="ampVal">8.0</span></label><input id="amp" type="range" min="2" max="14" step="0.5" value="8"></div>
        <div class="control-card"><label>Time Window 顯示時間窗 <span id="twVal">120 s</span></label><input id="tw" type="range" min="60" max="150" step="10" value="120"></div>
      </div>
    </div>
  </header>

  <section class="section">
    <div class="grid">
      <article class="card wide">
        <h2>這張 Record Section 在看什麼？</h2>
        <p class="quote">把每一個測站的垂直向波形，依照「震央距」由近到遠排開；橫向小幅擺動是地震波振幅，縱軸是發震後經過的秒數。當許多測站的波形一起排列，波的到時就會形成斜向的能量帶，這就是走時曲線在真實波形上的樣子。</p>
        <table class="analysis-table">
          <tr><th>圖上元素</th><th>代表意義</th></tr>
          <tr><td>X 軸：Distance (km)</td><td>測站與震央之間的距離。越往右代表測站越遠，地震波通常越晚抵達。</td></tr>
          <tr><td>Y 軸：Time / Travel Time (s)</td><td>相對於發震時間的經過秒數。黑白圖使用時間向下增加；彩色圖保留原本輸出風格，時間刻度用於比較不同測站到時。</td></tr>
          <tr><td>每一條垂直波形</td><td>一個測站的 Z 分量紀錄。波形左右擺動越大，代表正規化後振幅越明顯。</td></tr>
          <tr><td>斜向能量帶</td><td>代表同一組地震相位在不同距離的到達時間。若斜率穩定，可推估表觀速度；若彎曲或分叉，可能暗示速度結構、反射、折射或散射。</td></tr>
        </table>
      </article>
      <aside class="card">
        <h3>教授小提醒</h3>
        <p>這張圖不是單純「很多地震波疊在一起」，而是把空間距離與時間放在同一張圖中。只要你能看出哪一排波形比較早動、哪一排比較晚動，就已經在做走時判讀了。</p>
        <p class="mini">滑桿不會改變原始圖片，而是幫你理解繪圖參數：amp_scale 越大，波形左右擺動越明顯；時間窗越長，越能看到後續尾波與散射能量。</p>
      </aside>
    </div>
  </section>

  <section class="section">
    <div class="grid">
      <article class="card full">
        <h2>我們能從圖表看出什麼？</h2>
        <div class="grid" style="gap:14px">
          <div class="card"><h3>1. 距離越遠，到時越晚</h3><p>近震央測站通常較早出現明顯波形；遠距測站的主要能量往較晚時間移動，這正是走時曲線的基本概念。</p></div>
          <div class="card"><h3>2. 初達波能形成趨勢線</h3><p>若把各測站最早明顯振動點連起來，會形成一條近似斜線或曲線。其斜率可理解為慢度，與波速有關。</p></div>
          <div class="card"><h3>3. 波形不只一條到時</h3><p>圖中後段仍可看到強弱不同的能量，可能包含 S 波、反射波、散射波或局部構造造成的複雜波群。</p></div>
          <div class="card"><h3>4. 遠距波形較分散</h3><p>距離增加後，振幅常因幾何擴散、衰減與散射而變弱，波形也可能變得更寬、更混亂。</p></div>
          <div class="card"><h3>5. 彩色版提升辨識度</h3><p>彩色版本讓不同測站更容易分辨；黑白版本則較接近傳統地震剖面圖，可觀察整體能量帶。</p></div>
          <div class="card"><h3>6. 真實資料比理論更複雜</h3><p>理論走時曲線乾淨明確，但真實資料含雜訊、不同測站品質、場址效應與濾波影響，因此判讀需搭配地震報告與測站資訊。</p></div>
        </div>
      </article>
    </div>
  </section>

  <section class="section">
    <div class="grid">
      <article class="card wide">
        <h2>從 GDMS 到圖表：我的處理流程</h2>
        <div class="step"><div class="num">1</div><div><b>取得地震事件資料</b><p>先從 Taiwan GDMS / 中央氣象署地震事件頁面找到 2026/05/01 事件，確認震央、深度、規模與測站資料。</p></div></div>
        <div class="step"><div class="num">2</div><div><b>讀取 SAC 波形</b><p>使用 ObsPy 一次讀取 CWASN 資料夾中的 Z 分量 SAC 檔案，建立多測站波形資料流。</p></div></div>
        <div class="step"><div class="num">3</div><div><b>測站去重與品質優先</b><p>若同一測站有多種感測器，依 HHZ、EHZ、HLZ 等優先順序選擇較適合的垂直分量，避免同測站重複出現在圖上。</p></div></div>
        <div class="step"><div class="num">4</div><div><b>截取、去平均、濾波</b><p>截取發震前後約 130 秒，進行 demean 與 0.5–5.0 Hz 帶通濾波，使主要地震訊號更清楚。</p></div></div>
        <div class="step"><div class="num">5</div><div><b>計算震央距並繪圖</b><p>優先讀取 SAC header 中的 dist 或 gcarc；若缺少則由測站與震央座標計算。最後使用 <code>X = distance + normalized amplitude × amp_scale</code> 生成剖面圖。</p></div></div>
      </article>
      <aside class="card">
        <h3>這份作品的價值</h3>
        <p>它把第三章的走時、波形、測站距離、濾波與實際地震資料串起來。原本課本中的 T-x 曲線是理論線條，而這份作品把它轉成真實地震紀錄中的波形剖面，能直接連結「公式」與「觀測」。</p>
      </aside>
    </div>
  </section>

  <section class="section">
    <div class="grid">
      <article class="card wide quiz" id="quiz">
        <h2>快問快答</h2>
        <p>Record Section 中，為什麼遠距離測站的主要振動通常較晚出現？</p>
        <button data-good="0">因為遠距離測站的儀器一定比較慢。</button>
        <button data-good="1">因為地震波需要時間傳播，震央距越大，走時通常越長。</button>
        <button data-good="0">因為遠距離測站只能記錄 S 波，不能記錄 P 波。</button>
        <p id="quizMsg" class="mini"></p>
      </article>
      <article class="card">
        <h3>延伸思考</h3>
        <p>若把各測站的 P 波初達點手動拾取，再對距離與到時做線性或分段擬合，就能進一步估計表觀速度，連回 3.2 折射震測中的 T-x 走時曲線。</p>
      </article>
    </div>
  </section>

  <a class="pill backtop" href="#top" onclick="scrollTo({top:0,behavior:'smooth'});return false;">回到頂端</a>
  <footer class="footer">SeismoCore Explore｜Record Section Student Project｜Taiwan GDMS / CWASN data visualization</footer>

<script>
(function(){
  const root = document.documentElement;
  const saved = localStorage.getItem('seismo-theme');
  if(saved === 'light') root.classList.add('light');
  document.getElementById('themeBtn').addEventListener('click',()=>{root.classList.toggle('light');localStorage.setItem('seismo-theme',root.classList.contains('light')?'light':'dark')});

  const img = document.getElementById('mainFigure');
  const overlay = document.getElementById('overlay');
  const map = {
    color:{src:'record_section_color.png',alt:'彩色地震走時與波形剖面圖'},
    bw:{src:'record_section_bw.png',alt:'黑白地震走時與波形剖面圖'},
    report:{src:'cwa_report.png',alt:'中央氣象署地震報告截圖'}
  };
  document.querySelectorAll('[data-img]').forEach(btn=>btn.addEventListener('click',()=>{
    document.querySelectorAll('[data-img]').forEach(b=>b.classList.remove('active'));
    btn.classList.add('active');
    const item = map[btn.dataset.img];
    img.src = item.src; img.alt = item.alt;
    overlay.classList.toggle('on', btn.dataset.img !== 'report' && !overlay.dataset.off);
  }));
  document.getElementById('overlayBtn').addEventListener('click',()=>{
    overlay.dataset.off = overlay.classList.contains('on') ? '1' : '';
    overlay.classList.toggle('on');
  });
  const amp=document.getElementById('amp'), ampVal=document.getElementById('ampVal');
  amp.addEventListener('input',()=>ampVal.textContent=Number(amp.value).toFixed(1));
  const tw=document.getElementById('tw'), twVal=document.getElementById('twVal');
  tw.addEventListener('input',()=>twVal.textContent=tw.value+' s');
  document.querySelectorAll('#quiz button').forEach(btn=>btn.addEventListener('click',()=>{
    document.querySelectorAll('#quiz button').forEach(b=>b.classList.remove('good'));
    const msg=document.getElementById('quizMsg');
    if(btn.dataset.good==='1'){btn.classList.add('good');msg.textContent='答對了！這就是走時圖最核心的判讀：距離增加，傳播時間通常也增加。';document.body.classList.add('shake');setTimeout(()=>document.body.classList.remove('shake'),360)}
    else{msg.textContent='再想想：Record Section 的核心是「距離」與「到達時間」的關係。'}
  }));
})();
</script>
</body>
</html>
HTML

# Root copy for local preview from project root when not using docs as Pages folder.
cp "$ROOT/docs/record-section/index.html" "$ROOT/record-section/index.html"

inject_link() {
  local file="$1"
  [ -f "$file" ] || return 0
  if grep -q "record-section-launcher" "$file"; then
    echo "入口按鈕已存在：$file"
    return 0
  fi
  python3 - "$file" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')
snippet = r'''
<script id="record-section-launcher">
(function(){
  function addRecordSectionLauncher(){
    if(document.getElementById('recordSectionLauncher')) return;
    var a=document.createElement('a');
    a.id='recordSectionLauncher';
    a.href='./record-section/';
    a.textContent='實作｜繪製走時與波形剖面圖';
    a.style.cssText='position:fixed;left:18px;bottom:18px;z-index:99999;padding:12px 16px;border-radius:999px;background:linear-gradient(135deg,#78d2ff,#d9b76f);color:#06111d;font:800 14px Inter,system-ui,sans-serif;text-decoration:none;box-shadow:0 14px 36px rgba(0,0,0,.28);border:1px solid rgba(255,255,255,.35)';
    document.body.appendChild(a);
  }
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',addRecordSectionLauncher);
  else addRecordSectionLauncher();
})();
</script>
'''
if '</body>' in s:
    s = s.replace('</body>', snippet + '\n</body>')
else:
    s += snippet
p.write_text(s, encoding='utf-8')
PY
  echo "已加入入口按鈕：$file"
}

inject_link "$ROOT/docs/index.html"
inject_link "$ROOT/index.html"

cat > "$ROOT/RECORD_SECTION_NO_NPM_README.md" <<'MD'
# 繪製走時與波形剖面圖：無 npm 更新說明

本次更新不執行 `npm install`，只新增一個動態子頁：

- `docs/record-section/index.html`：GitHub Pages 用
- `record-section/index.html`：本機根目錄預覽用

並在 `docs/index.html` 與 `index.html` 注入一個左下角入口按鈕：

「實作｜繪製走時與波形剖面圖」

GitHub Pages 設定請維持：

- Branch: `main`
- Folder: `/docs`

更新後只需要：

```bash
git add .
git commit -m "Add record section practice page without npm"
git push
```
MD

echo "✅ 已完成：無 npm 新增『繪製走時與波形剖面圖』子網頁"
echo "下一步請執行："
echo "git add ."
echo "git commit -m 'Add record section practice page without npm'"
echo "git push"
