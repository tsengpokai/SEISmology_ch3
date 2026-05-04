#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
if [ ! -d "$ROOT/docs" ] || [ ! -f "$ROOT/docs/index.html" ]; then
  echo "⚠️  請在你的專案根目錄執行此腳本（裡面要有 docs/index.html）"
  echo "目前位置：$ROOT"
  exit 1
fi

cat > "$ROOT/docs/final_ui_fix_patch.js" <<'JS'
(function(){
  if (window.__SEISMO_FINAL_UI_PATCH__) return;
  window.__SEISMO_FINAL_UI_PATCH__ = true;

  function injectStyle(){
    if (document.getElementById('seismo-final-fix-style')) return;
    const style = document.createElement('style');
    style.id = 'seismo-final-fix-style';
    style.textContent = `
      .final-fix-grid{display:grid;grid-template-columns:1.1fr .9fr;gap:18px;align-items:stretch}
      .final-fix-grid.one{grid-template-columns:1fr}
      .final-fix-card{background:linear-gradient(180deg,rgba(255,255,255,.06),rgba(255,255,255,.03));border:1px solid rgba(148,163,184,.22);border-radius:28px;padding:18px;overflow:hidden}
      .final-fix-card h3,.final-fix-card h4{margin:0 0 10px 0}
      .final-fix-sub{color:rgba(226,232,240,.78);font-size:.96rem;line-height:1.75}
      .final-fix-svg{width:100%;height:auto;display:block}
      .final-slider{display:grid;gap:10px;margin-bottom:12px}
      .final-slider label{display:flex;justify-content:space-between;gap:12px;font-weight:700;align-items:center}
      .final-slider input{width:100%}
      .final-bars{display:grid;gap:10px;margin-top:14px}
      .final-bar{display:grid;grid-template-columns:150px 1fr 42px;gap:10px;align-items:center}
      .final-bar .track{height:14px;background:rgba(100,116,139,.35);border-radius:999px;overflow:hidden}
      .final-bar .fill{height:100%;border-radius:999px;background:linear-gradient(90deg,#2563eb,#67e8f9)}
      .final-numbers{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:10px;margin:14px 0}
      .final-chip{background:rgba(148,163,184,.11);border:1px solid rgba(148,163,184,.18);border-radius:18px;padding:10px 12px;font-weight:600}
      .final-note{margin-top:12px;padding:12px 14px;border-radius:18px;background:rgba(167,139,250,.12);border:1px solid rgba(167,139,250,.22);line-height:1.75}
      .phase-buttons-fix{display:flex;flex-wrap:wrap;gap:10px;margin-top:16px}
      .phase-buttons-fix button{border:1px solid rgba(148,163,184,.24);background:rgba(30,41,59,.52);color:#e2e8f0;border-radius:999px;padding:12px 16px;font-weight:800;cursor:pointer}
      .phase-buttons-fix button.active{background:#a78bfa;color:#0f172a;border-color:#c4b5fd}
      .phase-panel-fix{display:grid;grid-template-columns:1fr;gap:16px}
      .phase-title-fix{color:#c4b5fd;letter-spacing:.12em;text-transform:uppercase;font-size:.9rem;font-weight:800}
      .phase-name-fix{font-size:4.2rem;line-height:1;margin:0;color:#c4b5fd;font-family:Georgia,serif}
      .phase-rule-fix{padding:14px;border-radius:20px;background:rgba(244,114,182,.10);border:1px solid rgba(244,114,182,.24);line-height:1.8;font-weight:600}
      .record-switch{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:10px}
      .record-switch button,.record-switch .overlay-btn{border:1px solid rgba(148,163,184,.24);background:rgba(30,41,59,.45);color:#e2e8f0;border-radius:999px;padding:10px 14px;font-weight:800;cursor:pointer}
      .record-switch button.active,.record-switch .overlay-btn.active{background:rgba(16,185,129,.18);border-color:rgba(52,211,153,.55)}
      .record-figure{position:relative;background:#fff;border-radius:28px;padding:8px;overflow:hidden;min-height:340px;display:grid;place-items:center}
      .record-figure-inner{width:100%;height:100%;overflow:hidden;border-radius:22px;background:#fff;position:relative}
      .record-figure img{width:100%;height:auto;display:block;transform-origin:center center;transition:transform .25s ease, clip-path .25s ease, filter .25s ease}
      .record-overlay{position:absolute;inset:0;pointer-events:none;opacity:1;transition:opacity .25s ease}
      .record-overlay.off{opacity:0}
      .record-tip{position:absolute;background:rgba(255,255,255,.94);color:#334155;border:1px solid rgba(148,163,184,.35);border-radius:18px;padding:10px 12px;max-width:180px;line-height:1.55;font-size:.95rem;box-shadow:0 10px 26px rgba(15,23,42,.18)}
      .record-tip.left{left:16px;top:130px}
      .record-tip.mid{right:28px;top:180px}
      .record-tip.small{right:16px;top:20px;max-width:none}
      .record-diag{position:absolute;left:8%;right:7%;top:12%;height:72%}
      .record-controls{display:grid;gap:12px}
      .record-controls .final-chip{min-height:46px}
      .mini-head{font-size:.86rem;letter-spacing:.12em;text-transform:uppercase;color:#22c55e;font-weight:900;margin-bottom:8px}
      .secondary-chart{margin-top:12px;padding:12px;border-radius:20px;background:rgba(148,163,184,.08);border:1px solid rgba(148,163,184,.18)}
      .secondary-chart svg{width:100%;height:auto;display:block}
      .tiny-muted{font-size:.92rem;color:rgba(226,232,240,.78);line-height:1.75}
      @media (max-width: 980px){
        .final-fix-grid{grid-template-columns:1fr}
        .final-bar{grid-template-columns:1fr}
        .phase-name-fix{font-size:3.1rem}
      }
    `;
    document.head.appendChild(style);
  }

  function injectScriptTag(){
    // no-op in runtime
  }

  function findByText(selector, text){
    const els = Array.from(document.querySelectorAll(selector));
    return els.find(el => (el.textContent || '').includes(text));
  }

  function getActiveModuleSubtitle(){
    const heroLead = document.querySelector('.module-page .module-hero .hero-lead');
    return heroLead ? heroLead.textContent.trim() : '';
  }

  function getActiveInteractiveGrid(){
    const zone = document.querySelector('.module-page .interactive-zone');
    if (!zone) return null;
    return zone.querySelector('.interactive-grid, .interactive-grid.two, .interactive-grid.one') || zone.querySelector(':scope > div:last-child');
  }

  function slider(label, value, min, max, step, unit, id){
    return `<div class="final-slider"><label for="${id}"><span>${label}</span><strong id="${id}_val">${value}${unit || ''}</strong></label><input id="${id}" type="range" min="${min}" max="${max}" step="${step}" value="${value}"></div>`;
  }

  function patch31(zone){
    if (!zone || zone.dataset.finalPatch31 === '1') return;
    zone.dataset.finalPatch31 = '1';
    zone.innerHTML = `
      <div class="final-fix-grid">
        <div class="final-fix-card">
          <svg viewBox="0 0 620 340" class="final-fix-svg" id="m31_svg" aria-label="地震射線解析度示意圖"></svg>
        </div>
        <div class="final-fix-card">
          ${slider('震源與測站資料量', 55, 10, 100, 1, '%', 'm31_data')}
          ${slider('介面速度／密度對比', 65, 10, 100, 1, '%', 'm31_contrast')}
          <div class="final-bars">
            <div class="final-bar"><span>地震學解析度</span><div class="track"><div class="fill" id="m31_bar_seis"></div></div><strong id="m31_txt_seis"></strong></div>
            <div class="final-bar"><span>重力資料約束</span><div class="track"><div class="fill" id="m31_bar_g"></div></div><strong id="m31_txt_g"></strong></div>
            <div class="final-bar"><span>磁力資料約束</span><div class="track"><div class="fill" id="m31_bar_m"></div></div><strong id="m31_txt_m"></strong></div>
          </div>
          <div class="final-note">現在推桿會直接作用：<b>震源與測站資料量</b>會改變左圖的射線條數與交叉密度；<b>介面速度／密度對比</b>會改變異常體尺寸與資料解析差異，讓你更直觀看出「資料越密、解析度越高」。</div>
        </div>
      </div>`;

    const dataEl = document.getElementById('m31_data');
    const contrastEl = document.getElementById('m31_contrast');
    const svg = document.getElementById('m31_svg');
    function render(){
      const data = Number(dataEl.value);
      const contrast = Number(contrastEl.value);
      document.getElementById('m31_data_val').textContent = data + '%';
      document.getElementById('m31_contrast_val').textContent = contrast + '%';
      const seismic = Math.min(100, Math.round(30 + data * 0.55 + contrast * 0.35));
      const gravity = Math.min(100, Math.round(15 + data * 0.2 + contrast * 0.22));
      const magnetic = Math.min(100, Math.round(18 + data * 0.18 + contrast * 0.25));
      [['seis',seismic],['g',gravity],['m',magnetic]].forEach(([k,v])=>{
        document.getElementById('m31_bar_'+k).style.width = v + '%';
        document.getElementById('m31_txt_'+k).textContent = v;
      });
      const n = Math.max(5, Math.round(data / 6));
      let rays = '';
      for(let i=0;i<n;i++){
        const x = 40 + i * (540 / (n - 1 || 1));
        const bend = ((Math.sin(i*0.9) * 0.65) + 0.2) * contrast * 0.35;
        const wobble = 28 + (data * 0.08);
        rays += `<path d="M ${x.toFixed(1)} 42 C ${(x+bend).toFixed(1)} ${(110+wobble).toFixed(1)}, ${(x-bend).toFixed(1)} ${(182-wobble*0.25).toFixed(1)}, ${(x+bend*0.8).toFixed(1)} 288" stroke="rgba(103,232,249,${Math.min(.92,.28 + data/120).toFixed(2)})" stroke-width="${(1.2 + data/90).toFixed(2)}" fill="none" stroke-dasharray="6 8" />`;
      }
      const ell1rx = 26 + contrast * 0.48;
      const ell1ry = 18 + contrast * 0.12;
      const ell2rx = 18 + contrast * 0.28;
      const ell2ry = 12 + contrast * 0.15;
      svg.innerHTML = `
        <defs>
          <linearGradient id="m31_subsurface" x1="0" x2="0" y1="0" y2="1">
            <stop offset="0%" stop-color="rgba(125,211,252,.18)" />
            <stop offset="100%" stop-color="rgba(30,41,59,.55)" />
          </linearGradient>
        </defs>
        <rect x="28" y="42" width="560" height="246" rx="24" fill="url(#m31_subsurface)" stroke="rgba(148,163,184,.35)" />
        <path d="M28 108 H588 M28 176 H588 M28 242 H588" stroke="rgba(226,232,240,.2)" stroke-dasharray="8 8" />
        <ellipse cx="210" cy="208" rx="${ell1rx}" ry="${ell1ry}" fill="rgba(251,191,36,.55)" />
        <ellipse cx="398" cy="146" rx="${ell2rx}" ry="${ell2ry}" fill="rgba(244,114,182,.46)" />
        ${rays}
        <text x="52" y="72" fill="rgba(226,232,240,.95)" font-size="14" font-weight="700">Seismic rays：多路徑交叉 → 解析度提高</text>
        <text x="52" y="312" fill="rgba(226,232,240,.85)" font-size="13">資料量 ${data}% → 射線 ${n} 條；對比 ${contrast}% → 速度/密度異常更容易被定位</text>
      `;
    }
    [dataEl, contrastEl].forEach(el => el.addEventListener('input', render));
    render();
  }

  function patch33(zone){
    if (!zone || zone.dataset.finalPatch33 === '1') return;
    zone.dataset.finalPatch33 = '1';
    zone.innerHTML = `
      <div class="final-fix-grid">
        <div class="final-fix-card">
          <svg viewBox="0 0 620 360" class="final-fix-svg" id="m33_main_svg" aria-label="反射雙曲線圖"></svg>
        </div>
        <div class="final-fix-card">
          ${slider('反射界面深度 h', 2.2, 0.8, 5.0, 0.1, ' km', 'm33_h')}
          ${slider('上覆 RMS 速度', 3.1, 1.8, 5.5, 0.1, ' km/s', 'm33_v1')}
          ${slider('觀測 offset', 3.0, 0, 5.0, 0.1, ' km', 'm33_off')}
          <div class="final-numbers">
            <div class="final-chip">垂直雙程走時 t₀：<b id="m33_t0"></b></div>
            <div class="final-chip">偏移走時 T(x)：<b id="m33_tx"></b></div>
            <div class="final-chip">NMO：<b id="m33_nmo"></b></div>
          </div>
          <hr style="border-color:rgba(148,163,184,.18);margin:16px 0">
          ${slider('第 1 介面 Vrms', 3.1, 1.8, 5.5, 0.1, ' km/s', 'm33_vrms1b')}
          ${slider('第 2 介面 Vrms', 4.4, 2.0, 7.0, 0.1, ' km/s', 'm33_vrms2')}
          ${slider('t₁', 1.1, 0.5, 1.7, 0.1, ' s', 'm33_t1')}
          ${slider('t₂', 2.0, 1.8, 3.5, 0.1, ' s', 'm33_t2')}
          <div class="secondary-chart">
            <svg viewBox="0 0 520 190" id="m33_dix_svg"></svg>
          </div>
          <div class="final-note">現在 <b>第 2 介面 Vrms、t₁、t₂</b> 不只會改數字，也會同步改變下方的 <b>Dix interval velocity</b> 與雙層時間窗示意，所以推桿的作用會清楚可見。</div>
        </div>
      </div>`;

    const hEl = document.getElementById('m33_h');
    const v1El = document.getElementById('m33_v1');
    const offEl = document.getElementById('m33_off');
    const v1bEl = document.getElementById('m33_vrms1b');
    const v2El = document.getElementById('m33_vrms2');
    const t1El = document.getElementById('m33_t1');
    const t2El = document.getElementById('m33_t2');
    const mainSvg = document.getElementById('m33_main_svg');
    const dixSvg = document.getElementById('m33_dix_svg');
    function syncV1(from){
      const v = Number(from.value).toFixed(1);
      v1El.value = v;
      v1bEl.value = v;
    }
    v1El.addEventListener('input',()=>{syncV1(v1El); render();});
    v1bEl.addEventListener('input',()=>{syncV1(v1bEl); render();});
    [hEl, offEl, v2El, t1El, t2El].forEach(el => el.addEventListener('input', render));
    function render(){
      const h = Number(hEl.value);
      const vrms1 = Number(v1El.value);
      let t1 = Number(t1El.value);
      let t2 = Number(t2El.value);
      if (t2 <= t1 + 0.1){
        t2 = Number((t1 + 0.1).toFixed(1));
        t2El.value = t2;
      }
      const vrms2 = Number(v2El.value);
      const offset = Number(offEl.value);
      const t0 = 2 * h / vrms1;
      const tx = Math.sqrt(t0*t0 + (offset/vrms1)*(offset/vrms1));
      const nmo = tx - t0;
      const dix = Math.sqrt(Math.max(0.01, (vrms2*vrms2*t2 - vrms1*vrms1*t1) / Math.max(0.05, (t2 - t1))));
      [['m33_h',h,' km'],['m33_v1',vrms1,' km/s'],['m33_off',offset,' km'],['m33_vrms1b',vrms1,' km/s'],['m33_vrms2',vrms2,' km/s'],['m33_t1',t1,' s'],['m33_t2',t2,' s']].forEach(([id,val,unit])=>document.getElementById(id+'_val').textContent = val + unit);
      document.getElementById('m33_t0').textContent = t0.toFixed(2) + ' s';
      document.getElementById('m33_tx').textContent = tx.toFixed(2) + ' s';
      document.getElementById('m33_nmo').textContent = nmo.toFixed(2) + ' s';

      const pad = 48, W=620, H=360;
      const sx = x => pad + (x + 5) / 10 * (W - 1.5*pad);
      const sy = t => H - pad - t / 3.2 * (H - 1.45*pad);
      let path = '';
      for(let i=0;i<=220;i++){
        const x = -5 + i/220*10;
        const t = Math.sqrt(t0*t0 + (x/vrms1)*(x/vrms1));
        path += (i===0?`M ${sx(x)} ${sy(t)}`:` L ${sx(x)} ${sy(t)}`);
      }
      mainSvg.innerHTML = `
        <rect x="12" y="12" width="596" height="336" rx="24" fill="rgba(15,23,42,.18)" stroke="rgba(148,163,184,.22)" />
        <path d="M ${pad} 20 L ${pad} ${H-pad} L ${W-24} ${H-pad}" stroke="rgba(148,163,184,.45)" fill="none" />
        <path d="${path}" stroke="#22d3ee" stroke-width="4" fill="none" />
        <path d="M ${sx(-5)} ${sy(t0)} L ${sx(5)} ${sy(t0)}" stroke="#fbbf24" stroke-width="3" stroke-dasharray="10 8" fill="none" />
        <circle cx="${sx(offset)}" cy="${sy(tx)}" r="6" fill="#ffffff" />
        <text x="72" y="72" fill="rgba(226,232,240,.95)" font-size="14" font-weight="700">Reflection hyperbola</text>
        <text x="72" y="98" fill="rgba(226,232,240,.76)" font-size="13">零偏移 t₀ = ${t0.toFixed(2)} s；偏移走時 T(x) = ${tx.toFixed(2)} s</text>
        <text x="${sx(1.6)}" y="${sy(Math.sqrt(t0*t0 + (1.6/vrms1)*(1.6/vrms1))) - 10}" fill="rgba(226,232,240,.76)" font-size="13">雙曲線反射到時</text>
        <text x="${sx(-4.8)}" y="${sy(t0)-10}" fill="#fbbf24" font-size="13">zero-offset t₀</text>
        <text x="${W-84}" y="${H-16}" fill="rgba(226,232,240,.76)" font-size="13">offset x</text>
      `;

      const y1 = 52, y2 = 112, bw=320;
      const bw1 = Math.max(20, Math.min(bw, vrms1/6*320));
      const bw2 = Math.max(20, Math.min(bw, vrms2/7*320));
      const bwD = Math.max(20, Math.min(bw, dix/8*320));
      dixSvg.innerHTML = `
        <text x="12" y="20" fill="rgba(226,232,240,.92)" font-size="14" font-weight="700">Dix 方程式動態解讀</text>
        <text x="12" y="42" fill="rgba(226,232,240,.76)" font-size="12">只要調整第 2 介面 Vrms、t₁、t₂，下列條帶與 interval velocity 會立即改變。</text>
        <text x="12" y="${y1}" fill="rgba(226,232,240,.9)" font-size="13">第 1 介面 Vrms</text>
        <rect x="132" y="${y1-12}" width="${bw1}" height="16" rx="8" fill="#22d3ee" />
        <text x="462" y="${y1}" fill="rgba(226,232,240,.9)" font-size="13">${vrms1.toFixed(1)} km/s</text>
        <text x="12" y="${y2}" fill="rgba(226,232,240,.9)" font-size="13">第 2 介面 Vrms</text>
        <rect x="132" y="${y2-12}" width="${bw2}" height="16" rx="8" fill="#38bdf8" />
        <text x="462" y="${y2}" fill="rgba(226,232,240,.9)" font-size="13">${vrms2.toFixed(1)} km/s</text>
        <text x="12" y="152" fill="rgba(226,232,240,.9)" font-size="13">Dix interval velocity</text>
        <rect x="132" y="140" width="${bwD}" height="18" rx="9" fill="#fbbf24" />
        <text x="438" y="153" fill="#fbbf24" font-size="13" font-weight="700">${dix.toFixed(2)} km/s</text>
        <path d="M 22 176 H 488" stroke="rgba(148,163,184,.3)" />
        <line x1="110" y1="168" x2="110" y2="188" stroke="rgba(226,232,240,.7)" />
        <line x1="${110 + t1*120}" y1="168" x2="${110 + t1*120}" y2="188" stroke="#22d3ee" stroke-width="3" />
        <line x1="${110 + t2*120}" y1="168" x2="${110 + t2*120}" y2="188" stroke="#38bdf8" stroke-width="3" />
        <text x="104" y="166" fill="rgba(226,232,240,.7)" font-size="12">0</text>
        <text x="${96 + t1*120}" y="166" fill="#22d3ee" font-size="12">t₁=${t1.toFixed(1)} s</text>
        <text x="${96 + t2*120}" y="166" fill="#38bdf8" font-size="12">t₂=${t2.toFixed(1)} s</text>
      `;
    }
    render();
  }

  const phaseInfoFix = {
    P: {desc:'P：壓縮波，只在地函中轉折後回到地表，是最基本的直達體波。', rule:'路徑限制：P 可在固體與液體中傳播，所以可穿過地函，也可在其他相位中穿核。', draw:'P'},
    S: {desc:'S：剪力波，只能在固體中傳播。外地核為液態，所以直接 S 波絕對不能穿過 outer core。', rule:'路徑限制：S 線必須停留在 solid mantle，不得畫入 outer core。', draw:'S'},
    PP: {desc:'PP：P 波在地表反射一次後再回到測站，可視為 P 的一次 surface bounce。', rule:'路徑限制：反射點在地表；不需要進入核心。', draw:'PP'},
    SS: {desc:'SS：S 波在地表反射一次後再傳到測站；全程仍待在固態地函內。', rule:'路徑限制：SS 仍不得進入 outer core。', draw:'SS'},
    PcP: {desc:'PcP：P 波在核幔邊界（CMB）反射後返回地表。它會碰到 CMB，但不穿過外核。', rule:'路徑限制：只能在 CMB 反射，不能進入 outer core。', draw:'PcP'},
    ScS: {desc:'ScS：S 波在核幔邊界反射後回到地表。因外核不傳 S 波，所以它在 CMB 處反射。', rule:'路徑限制：S 段只在地函內，於 CMB 反射。', draw:'ScS'},
    PKP: {desc:'PKP：P 波進入外核（K）後再回到地函，是典型穿越液態外核的 P 相位。', rule:'路徑限制：可以穿 outer core，但不必穿 inner core。', draw:'PKP'},
    PKIKP: {desc:'PKIKP：P 波穿過外核（K）與內核（I），是研究內核的重要穿核相位。', rule:'路徑限制：必須穿過 outer core 與 inner core。', draw:'PKIKP'},
    PKiKP: {desc:'PKiKP：P 波穿過外核後，在內核邊界（i）反射，再回到地函。', rule:'路徑限制：進入 outer core、碰到 ICB 反射，但不穿越整個 inner core。', draw:'PKiKP'},
    Pdiff: {desc:'Pdiff：P 波沿核幔邊界附近繞射，常出現在陰影區邊緣。', rule:'路徑限制：貼著 CMB 走，不直接深入 outer core 中央。', draw:'Pdiff'},
    SKS: {desc:'SKS：在地函中是 S 波，進入外核後轉成 P 波（K），出外核後再轉回 S 波。', rule:'路徑限制：外核段不是 S，而是 K = P in outer core。', draw:'SKS'}
  };

  function earthSvgForPhase(phase){
    const base = `
      <defs>
        <radialGradient id="earthFixGrad"><stop offset="0" stop-color="#fbbf24"/><stop offset="0.36" stop-color="#f97316"/><stop offset="0.68" stop-color="#334155"/><stop offset="1" stop-color="#0f172a"/></radialGradient>
      </defs>
      <circle cx="260" cy="200" r="150" fill="url(#earthFixGrad)" stroke="rgba(226,232,240,.28)" />
      <circle cx="260" cy="200" r="78" fill="rgba(251,191,36,.18)" stroke="rgba(251,191,36,.55)" />
      <circle cx="260" cy="200" r="38" fill="rgba(251,191,36,.25)" stroke="rgba(251,191,36,.55)" />
      <circle cx="110" cy="130" r="6" fill="#fb7185" />
      <circle cx="410" cy="130" r="6" fill="#67e8f9" />
      <text x="74" y="115" fill="rgba(226,232,240,.9)" font-size="12">Source</text>
      <text x="406" y="115" fill="rgba(226,232,240,.9)" font-size="12">Receiver</text>
      <text x="326" y="204" fill="rgba(226,232,240,.82)" font-size="11">Outer core = K</text>
      <text x="255" y="203" fill="rgba(226,232,240,.82)" font-size="11">I</text>`;
    const strokeP = 'stroke="#fbbf24" stroke-width="6" fill="none" stroke-linecap="round"';
    const strokeS = 'stroke="#e9a8ff" stroke-width="6" fill="none" stroke-linecap="round" stroke-dasharray="12 10"';
    const thinP = 'stroke="#fbbf24" stroke-width="5" fill="none" stroke-linecap="round"';
    const thinS = 'stroke="#e9a8ff" stroke-width="5" fill="none" stroke-linecap="round" stroke-dasharray="10 8"';
    const paths = {
      P: `<path ${thinP} d="M110 130 C 180 176, 335 178, 410 130" />`,
      S: `<path ${strokeS} d="M110 130 C 170 260, 350 260, 410 130" />`,
      PP: `<path ${thinP} d="M110 130 C 180 74, 230 54, 260 40 C 290 54, 340 74, 410 130" />`,
      SS: `<path ${strokeS} d="M110 130 C 180 88, 230 64, 260 46 C 290 64, 340 88, 410 130" />`,
      PcP: `<path ${thinP} d="M110 130 C 175 222, 225 270, 260 278 C 295 270, 345 222, 410 130" />`,
      ScS: `<path ${strokeS} d="M110 130 C 175 222, 225 270, 260 278 C 295 270, 345 222, 410 130" />`,
      PKP: `<path ${thinP} d="M110 130 C 180 240, 224 236, 260 208 C 296 236, 340 240, 410 130" />`,
      PKIKP: `<path ${thinP} d="M110 130 C 180 250, 235 220, 260 200 C 285 180, 340 150, 410 130" />`,
      PKiKP: `<path ${thinP} d="M110 130 C 178 246, 232 220, 260 162 C 288 220, 342 246, 410 130" />`,
      Pdiff: `<path ${thinP} d="M110 130 C 168 228, 200 272, 225 278" /><path ${thinP} d="M225 278 A 38 38 0 0 0 295 278" /><path ${thinP} d="M295 278 C 320 272, 352 228, 410 130" />`,
      SKS: `<path ${strokeS} d="M110 130 C 155 205, 188 225, 212 228" /><path ${thinP} d="M212 228 C 230 214, 244 206, 260 204 C 276 206, 290 214, 308 228" /><path ${strokeS} d="M308 228 C 332 225, 365 205, 410 130" />`
    };
    return `<svg viewBox="0 0 520 360" class="final-fix-svg" aria-label="${phase} 相位示意圖">${base}${paths[phase] || paths.P}</svg>`;
  }

  function patch35(zone){
    if (!zone || zone.dataset.finalPatch35 === '1') return;
    zone.dataset.finalPatch35 = '1';
    zone.innerHTML = `
      <div class="final-fix-grid one">
        <div class="final-fix-card phase-panel-fix">
          <div class="phase-title-fix">Corrected Phase Challenge</div>
          <h3 class="phase-name-fix" id="m35_name">S</h3>
          <div class="final-fix-sub" id="m35_desc"></div>
          <div class="phase-rule-fix" id="m35_rule"></div>
          <div id="m35_svg_wrap"></div>
          <div class="phase-buttons-fix" id="m35_buttons"></div>
          <div class="final-note">已依你的要求刪除左邊那張錯誤示意圖。現在只保留一個修正版互動區，而且 <b>S / SS / ScS</b> 都不會被畫進 <b>outer core</b>；若看到 <b>SKS</b>，外核中的 K 也會明確表示那一段是 <b>P wave in outer core</b>。</div>
        </div>
      </div>`;

    const btnWrap = document.getElementById('m35_buttons');
    const phaseOrder = ['P','S','PP','SS','PcP','ScS','PKP','PKIKP','PKiKP','Pdiff','SKS'];
    let current = 'S';
    function render(){
      document.getElementById('m35_name').textContent = current;
      document.getElementById('m35_desc').textContent = phaseInfoFix[current].desc;
      document.getElementById('m35_rule').textContent = phaseInfoFix[current].rule;
      document.getElementById('m35_svg_wrap').innerHTML = earthSvgForPhase(phaseInfoFix[current].draw);
      btnWrap.innerHTML = phaseOrder.map(p => `<button class="${p===current?'active':''}" data-p="${p}">${p}</button>`).join('');
      btnWrap.querySelectorAll('button').forEach(btn => btn.addEventListener('click', ()=>{ current = btn.dataset.p; render(); }));
    }
    render();
  }

  function patchPractice(){
    const host = findByText('.module-page, .interactive-zone, .glass, .glass-lite, section, article, div', '彩色版：多測站分色與標籤') || findByText('.module-page, .interactive-zone, .glass, .glass-lite, section, article, div', 'RECORD SECTION VIEWER');
    if (!host) return;
    let zone = host.closest('.interactive-zone') || host.closest('.module-page') || host;
    let target = zone.querySelector('.interactive-grid, .interactive-grid.two, .interactive-grid.one');
    if (!target) {
      target = host;
    }
    if (target.dataset.finalPatchPractice === '1') return;
    target.dataset.finalPatchPractice = '1';
    const colorPath = './record-section/record_section_color.png';
    const bwPath = './record-section/record_section_bw.png';
    const reportPath = './record-section/cwa_report.png';
    target.innerHTML = `
      <div class="final-fix-grid">
        <div class="final-fix-card">
          <div class="mini-head">Record Section Viewer</div>
          <div class="record-switch">
            <button class="active" data-img="color">彩色版</button>
            <button data-img="bw">黑白版</button>
            <button data-img="report">地震報告</button>
            <button class="overlay-btn active" id="rs_overlay_btn">讀圖輔助標籤</button>
          </div>
          <h3 id="rs_title">彩色版：多測站分色與標籤</h3>
          <div class="record-figure">
            <div class="record-figure-inner" id="rs_frame">
              <img id="rs_img" src="${colorPath}" alt="彩色 Record Section">
              <div class="record-overlay" id="rs_overlay">
                <svg class="record-diag" viewBox="0 0 1000 680" preserveAspectRatio="none">
                  <path d="M70 105 C230 145 350 230 500 330 C650 425 760 520 930 610" fill="none" stroke="rgba(120,210,255,.92)" stroke-width="6" stroke-linecap="round" stroke-dasharray="16 12"/>
                  <path d="M70 170 C260 190 430 265 590 365 C720 445 820 515 930 560" fill="none" stroke="rgba(217,183,111,.9)" stroke-width="4" stroke-linecap="round" stroke-dasharray="8 14"/>
                </svg>
                <div class="record-tip left">Time：發震後秒數；往下或往上依圖軸設定判讀</div>
                <div class="record-tip mid">連續斜帶：可追蹤的波群走時趨勢</div>
                <div class="record-tip small">讀圖輔助</div>
              </div>
            </div>
          </div>
          <p class="tiny-muted" style="margin-top:10px">下面兩個推桿現在會有實際示意效果：<b>amp_scale</b> 會改變波形橫向放大感；<b>時間窗</b> 會改變可見圖幅高度。這些是教學示意，不會修改原始地震資料。</p>
        </div>
        <div class="final-fix-card">
          <div class="record-controls">
            ${slider('示意振幅放大 amp_scale', 6, 2, 14, 0.5, '×', 'rs_amp')}
            ${slider('示意時間窗', 80, 60, 150, 10, ' s', 'rs_tw')}
            <div class="final-chip">事件時間：2026-05-01 12:39:55 UTC</div>
            <div class="final-chip">資料網路：CWASN / Taiwan GDMS</div>
            <div class="final-chip">成功繪製：117 個測站</div>
            <div class="final-chip">濾波頻帶：0.5–5.0 Hz</div>
            <div class="final-chip">座標公式：X = distance + normalized amplitude × amp_scale</div>
            <div class="final-note">如果切到地震報告，示意推桿會暫時只更新數值，不再對報告圖做扭曲示意；切回彩色版／黑白版時，效果會立即恢復。</div>
          </div>
        </div>
      </div>`;

    const img = document.getElementById('rs_img');
    const overlay = document.getElementById('rs_overlay');
    const amp = document.getElementById('rs_amp');
    const tw = document.getElementById('rs_tw');
    const title = document.getElementById('rs_title');
    const overlayBtn = document.getElementById('rs_overlay_btn');
    let current = 'color';
    let overlayOn = true;
    function applyFigure(){
      const ampVal = Number(amp.value);
      const twVal = Number(tw.value);
      document.getElementById('rs_amp_val').textContent = ampVal + '×';
      document.getElementById('rs_tw_val').textContent = twVal + ' s';
      const scaleX = 1 + (ampVal - 6) * 0.045;
      const cropBottom = Math.max(0, Math.min(38, ((150 - twVal) / 90) * 38));
      if (current === 'color') {
        img.src = colorPath; img.alt = '彩色 Record Section'; title.textContent = '彩色版：多測站分色與標籤';
        img.style.transform = `scaleX(${scaleX.toFixed(3)})`;
        img.style.clipPath = `inset(0 0 ${cropBottom.toFixed(1)}% 0)`;
        img.style.filter = 'none';
      } else if (current === 'bw') {
        img.src = bwPath; img.alt = '黑白 Record Section'; title.textContent = '黑白版：原始風格走時與波形剖面圖';
        img.style.transform = `scaleX(${scaleX.toFixed(3)})`;
        img.style.clipPath = `inset(0 0 ${cropBottom.toFixed(1)}% 0)`;
        img.style.filter = 'grayscale(1)';
      } else {
        img.src = reportPath; img.alt = '中央氣象署地震報告'; title.textContent = '中央氣象署地震報告';
        img.style.transform = 'scaleX(1)';
        img.style.clipPath = 'inset(0 0 0 0)';
        img.style.filter = 'none';
      }
      overlay.classList.toggle('off', !overlayOn || current === 'report');
    }
    amp.addEventListener('input', applyFigure);
    tw.addEventListener('input', applyFigure);
    target.querySelectorAll('[data-img]').forEach(btn => btn.addEventListener('click', ()=>{
      current = btn.dataset.img;
      target.querySelectorAll('[data-img]').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      applyFigure();
    }));
    overlayBtn.addEventListener('click', ()=>{
      overlayOn = !overlayOn;
      overlayBtn.classList.toggle('active', overlayOn);
      applyFigure();
    });
    applyFigure();
  }

  function runPatches(){
    injectStyle();
    const subtitle = getActiveModuleSubtitle();
    const zone = getActiveInteractiveGrid();
    if (subtitle.includes('X 光')) patch31(zone);
    if (subtitle.includes('Dix 方程式')) patch33(zone);
    if (subtitle.includes('相位名稱就是路徑履歷')) patch35(zone);
    patchPractice();
  }

  const mo = new MutationObserver(() => runPatches());
  if (document.body) mo.observe(document.body, {childList:true, subtree:true});
  document.addEventListener('DOMContentLoaded', runPatches);
  window.addEventListener('load', runPatches);
  setInterval(runPatches, 1200);
})();
JS

if ! grep -q 'final_ui_fix_patch.js' "$ROOT/docs/index.html"; then
  python3 - "$ROOT/docs/index.html" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')
tag = '<script src="./final_ui_fix_patch.js"></script>'
if tag not in s:
    if '</body>' in s:
        s = s.replace('</body>', f'  {tag}\n</body>')
    else:
        s += '\n' + tag + '\n'
p.write_text(s, encoding='utf-8')
PY
fi

touch "$ROOT/docs/.nojekyll"

echo "✅ 已完成最後修正補丁（免 npm）"
echo "1) docs/final_ui_fix_patch.js 已建立"
echo "2) docs/index.html 已自動插入 script"
echo "3) 接著請執行：git add . && git commit -m 'Final interactive fixes' && git push"
