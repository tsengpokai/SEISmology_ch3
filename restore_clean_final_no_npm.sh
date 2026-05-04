#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
if [ ! -d "$ROOT/docs" ] || [ ! -f "$ROOT/docs/index.html" ]; then
  echo "⚠️  請在專案根目錄執行，例如 /workspaces/SEISmology_ch3"
  echo "目前位置：$ROOT"
  exit 1
fi

python3 - "$ROOT/docs/index.html" <<'PY'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')
# 移除上一輪造成版面跑掉或留下指令文字的補丁腳本引用
for name in ["final_ui_fix_patch.js", "phase35-corrector.js"]:
    s = re.sub(r'\s*<script[^>]+src=["\']\./' + re.escape(name) + r'["\'][^>]*></script>\s*', '\n', s)
p.write_text(s, encoding='utf-8')
PY

rm -f "$ROOT/docs/final_ui_fix_patch.js" "$ROOT/docs/phase35-corrector.js"

cat > "$ROOT/docs/clean_interactive_fix.js" <<'JS'

(function(){
  if (window.__SEISMO_CLEAN_FIX__) return;
  window.__SEISMO_CLEAN_FIX__ = true;

  function addStyle(){
    if (document.getElementById('seismo-clean-fix-style')) return;
    const style = document.createElement('style');
    style.id = 'seismo-clean-fix-style';
    style.textContent = `
      .clean-grid{display:grid;grid-template-columns:minmax(0,1.12fr) minmax(320px,.88fr);gap:22px;align-items:stretch}
      .clean-grid.single{grid-template-columns:1fr}
      .clean-card{background:linear-gradient(180deg,rgba(255,255,255,.075),rgba(255,255,255,.035));border:1px solid rgba(148,163,184,.22);border-radius:30px;padding:22px;overflow:hidden;box-shadow:0 18px 50px rgba(0,0,0,.16)}
      .clean-card h3{margin:0 0 12px;font-size:1.24rem}
      .clean-svg{display:block;width:100%;height:auto}
      .clean-control{display:grid;gap:10px;margin:0 0 16px}
      .clean-control label{display:flex;justify-content:space-between;gap:16px;font-weight:800;color:rgba(226,232,240,.92)}
      .clean-control strong{white-space:nowrap;color:#e2e8f0}
      .clean-control input{width:100%;accent-color:#67e8f9}
      .clean-metrics{display:grid;gap:12px;margin-top:14px}
      .clean-metric{display:grid;grid-template-columns:150px 1fr 46px;gap:12px;align-items:center;color:rgba(226,232,240,.88)}
      .clean-track{height:14px;border-radius:999px;background:rgba(100,116,139,.36);overflow:hidden}
      .clean-fill{height:100%;border-radius:999px;background:linear-gradient(90deg,#2563eb,#67e8f9);transition:width .22s ease}
      .clean-readout{display:grid;grid-template-columns:repeat(auto-fit,minmax(170px,1fr));gap:10px;margin-top:14px}
      .clean-chip{padding:11px 13px;border-radius:18px;border:1px solid rgba(148,163,184,.20);background:rgba(148,163,184,.10);color:rgba(226,232,240,.9);font-weight:650}
      .clean-hint{margin-top:14px;padding:14px 16px;border-radius:20px;background:rgba(56,189,248,.10);border:1px solid rgba(56,189,248,.22);color:rgba(226,232,240,.86);line-height:1.75}
      .clean-phase-layout{display:grid;grid-template-columns:minmax(0,1.08fr) minmax(300px,.92fr);gap:22px;align-items:stretch}
      .clean-phase-title{font-size:.9rem;letter-spacing:.13em;text-transform:uppercase;color:#c4b5fd;font-weight:900;margin-bottom:10px}
      .clean-phase-name{font-family:Georgia,serif;font-size:4rem;line-height:1;color:#c4b5fd;margin:0 0 14px}
      .clean-phase-desc{line-height:1.86;color:rgba(226,232,240,.88);font-size:1.04rem}
      .clean-phase-rule{margin-top:14px;padding:14px 16px;border-radius:20px;background:rgba(167,139,250,.11);border:1px solid rgba(167,139,250,.25);color:rgba(226,232,240,.92);line-height:1.75}
      .clean-phase-buttons{display:flex;flex-wrap:wrap;gap:10px;margin-top:16px}
      .clean-phase-buttons button{border:1px solid rgba(148,163,184,.26);background:rgba(30,41,59,.52);color:#e2e8f0;border-radius:999px;padding:10px 15px;font-weight:850;cursor:pointer}
      .clean-phase-buttons button.active{background:#a78bfa;color:#101827;border-color:#c4b5fd}
      .clean-legend{display:flex;gap:10px;flex-wrap:wrap;margin-top:12px;color:rgba(226,232,240,.74);font-size:.95rem}
      .clean-legend span{display:inline-flex;align-items:center;gap:6px}
      .clean-line{width:28px;height:4px;border-radius:999px;display:inline-block}
      .clean-record-imgwrap{position:relative;background:white;border-radius:26px;padding:8px;overflow:hidden;min-height:330px;display:grid;place-items:center}
      .clean-record-frame{position:relative;width:100%;height:100%;overflow:hidden;border-radius:20px;background:#fff}
      .clean-record-frame img{display:block;width:100%;height:auto;transform-origin:center center;transition:transform .25s ease,clip-path .25s ease,filter .25s ease}
      .clean-record-overlay{position:absolute;inset:0;pointer-events:none;transition:opacity .25s ease}
      .clean-record-overlay.off{opacity:0}
      .clean-tip{position:absolute;background:rgba(255,255,255,.94);border:1px solid rgba(148,163,184,.36);color:#334155;border-radius:16px;padding:9px 11px;font-size:.92rem;line-height:1.5;box-shadow:0 10px 28px rgba(15,23,42,.16)}
      .clean-tip.a{left:18px;top:26%}
      .clean-tip.b{right:24px;top:45%}
      .clean-record-buttons{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:12px}
      .clean-record-buttons button{border:1px solid rgba(148,163,184,.26);background:rgba(30,41,59,.52);color:#e2e8f0;border-radius:999px;padding:10px 14px;font-weight:850;cursor:pointer}
      .clean-record-buttons button.active{background:rgba(16,185,129,.2);border-color:rgba(52,211,153,.5)}
      @media (max-width:980px){.clean-grid,.clean-phase-layout{grid-template-columns:1fr}.clean-metric{grid-template-columns:1fr}.clean-phase-name{font-size:3rem}}
    `;
    document.head.appendChild(style);
  }

  function slider(label, value, min, max, step, unit, id){
    return `<div class="clean-control"><label for="${id}"><span>${label}</span><strong id="${id}_label">${value}${unit||''}</strong></label><input id="${id}" type="range" min="${min}" max="${max}" step="${step}" value="${value}"></div>`;
  }

  function getHash(){ return (window.location.hash || '').replace('#',''); }
  function getZone(){ return document.querySelector('.module-page .interactive-zone'); }
  function getGrid(){ const z=getZone(); return z ? z.querySelector('.interactive-grid, .interactive-grid.two, .interactive-grid.one') : null; }

  function patch31(){
    if(getHash() !== 'm31') return;
    const target = getGrid();
    if(!target || target.dataset.clean31 === '1') return;
    target.dataset.clean31 = '1';
    target.innerHTML = `
      <div class="clean-grid">
        <div class="clean-card"><svg id="clean31_svg" class="clean-svg" viewBox="0 0 620 340"></svg></div>
        <div class="clean-card">
          ${slider('震源與測站資料量',55,10,100,1,'%', 'clean31_data')}
          ${slider('介面速度／密度對比',65,10,100,1,'%', 'clean31_contrast')}
          <div class="clean-metrics">
            <div class="clean-metric"><span>地震學解析度</span><div class="clean-track"><div id="clean31_seis" class="clean-fill"></div></div><strong id="clean31_seis_t"></strong></div>
            <div class="clean-metric"><span>重力資料約束</span><div class="clean-track"><div id="clean31_g" class="clean-fill"></div></div><strong id="clean31_g_t"></strong></div>
            <div class="clean-metric"><span>磁力資料約束</span><div class="clean-track"><div id="clean31_m" class="clean-fill"></div></div><strong id="clean31_m_t"></strong></div>
          </div>
          <p class="clean-hint">資料量越高，波線交叉越密，越能把地下異常的位置與形狀約束出來；介面對比越強，地震波反應越明顯。</p>
        </div>
      </div>`;
    const dataEl=document.getElementById('clean31_data');
    const conEl=document.getElementById('clean31_contrast');
    const svg=document.getElementById('clean31_svg');
    function render(){
      const data=+dataEl.value, contrast=+conEl.value;
      document.getElementById('clean31_data_label').textContent=data+'%';
      document.getElementById('clean31_contrast_label').textContent=contrast+'%';
      const vals={seis:Math.min(100,Math.round(30+data*.55+contrast*.35)),g:Math.min(100,Math.round(15+data*.20+contrast*.22)),m:Math.min(100,Math.round(18+data*.18+contrast*.25))};
      Object.entries(vals).forEach(([k,v])=>{document.getElementById('clean31_'+k).style.width=v+'%';document.getElementById('clean31_'+k+'_t').textContent=v;});
      const n=Math.max(5,Math.round(data/6));
      let rays='';
      for(let i=0;i<n;i++){
        const x=48+i*(524/(n-1||1));
        const b=(Math.sin(i*.85)*.8+.18)*contrast*.38;
        rays+=`<path d="M${x.toFixed(1)} 42 C${(x+b).toFixed(1)} 118 ${(x-b).toFixed(1)} 190 ${(x+b*.8).toFixed(1)} 288" stroke="rgba(103,232,249,${Math.min(.9,.28+data/120).toFixed(2)})" stroke-width="${(1.1+data/80).toFixed(2)}" fill="none" stroke-dasharray="6 8"/>`;
      }
      const r1=28+contrast*.52, r2=18+contrast*.30;
      svg.innerHTML=`
        <defs><linearGradient id="resGrad" x1="0" x2="0" y1="0" y2="1"><stop offset="0%" stop-color="rgba(125,211,252,.19)"/><stop offset="100%" stop-color="rgba(30,41,59,.56)"/></linearGradient></defs>
        <rect x="28" y="42" width="560" height="246" rx="24" fill="url(#resGrad)" stroke="rgba(148,163,184,.34)"/>
        <path d="M28 108H588M28 176H588M28 242H588" stroke="rgba(226,232,240,.18)" stroke-dasharray="8 8"/>
        <ellipse cx="210" cy="208" rx="${r1}" ry="${18+contrast*.12}" fill="rgba(251,191,36,.54)"/>
        <ellipse cx="398" cy="146" rx="${r2}" ry="${13+contrast*.15}" fill="rgba(244,114,182,.44)"/>
        ${rays}
        <text x="52" y="72" fill="rgba(226,232,240,.95)" font-size="14" font-weight="800">Seismic rays：多路徑交叉 → 解析度提高</text>
        <text x="52" y="314" fill="rgba(226,232,240,.78)" font-size="13">資料量 ${data}%：${n} 條射線；對比 ${contrast}%：異常體更清楚</text>`;
    }
    dataEl.addEventListener('input', render); conEl.addEventListener('input', render); render();
  }

  function patch33(){
    if(getHash() !== 'm33') return;
    const target = getGrid();
    if(!target || target.dataset.clean33 === '1') return;
    target.dataset.clean33='1';
    target.innerHTML=`
      <div class="clean-grid">
        <div class="clean-card"><svg id="clean33_svg" class="clean-svg" viewBox="0 0 620 360"></svg></div>
        <div class="clean-card">
          ${slider('反射界面深度 h',2.2,.8,5,.1,' km','clean33_h')}
          ${slider('上覆 RMS 速度',3.1,1.8,5.5,.1,' km/s','clean33_v1')}
          ${slider('觀測 offset',3,0,5,.1,' km','clean33_off')}
          <div class="clean-readout">
            <div class="clean-chip">t₀：<b id="clean33_t0"></b></div>
            <div class="clean-chip">T(x)：<b id="clean33_tx"></b></div>
            <div class="clean-chip">NMO：<b id="clean33_nmo"></b></div>
          </div>
          <hr style="border-color:rgba(148,163,184,.18);margin:16px 0">
          ${slider('第 1 介面 Vrms',3.1,1.8,5.5,.1,' km/s','clean33_vrms1')}
          ${slider('第 2 介面 Vrms',4.4,2,7,.1,' km/s','clean33_vrms2')}
          ${slider('t₁',1.1,.5,1.7,.1,' s','clean33_t1')}
          ${slider('t₂',2,1.8,3.5,.1,' s','clean33_t2')}
          <div class="clean-card" style="margin-top:14px;padding:14px"><svg id="clean33_dix" class="clean-svg" viewBox="0 0 520 190"></svg></div>
        </div>
      </div>`;
    const ids=['h','v1','off','vrms1','vrms2','t1','t2'];
    const el=Object.fromEntries(ids.map(k=>[k,document.getElementById('clean33_'+k)]));
    const svg=document.getElementById('clean33_svg'), dixSvg=document.getElementById('clean33_dix');
    function syncV(from){ const v=(+from.value).toFixed(1); el.v1.value=v; el.vrms1.value=v; }
    el.v1.addEventListener('input',()=>{syncV(el.v1);render();});
    el.vrms1.addEventListener('input',()=>{syncV(el.vrms1);render();});
    ['h','off','vrms2','t1','t2'].forEach(k=>el[k].addEventListener('input',render));
    function render(){
      const h=+el.h.value, v1=+el.v1.value, off=+el.off.value, v2=+el.vrms2.value;
      let t1=+el.t1.value, t2=+el.t2.value;
      if(t2<=t1+.1){t2=+(t1+.1).toFixed(1);el.t2.value=t2;}
      [['h',h,' km'],['v1',v1,' km/s'],['off',off,' km'],['vrms1',v1,' km/s'],['vrms2',v2,' km/s'],['t1',t1,' s'],['t2',t2,' s']].forEach(([k,v,u])=>document.getElementById('clean33_'+k+'_label').textContent=v+u);
      const t0=2*h/v1, tx=Math.sqrt(t0*t0+(off/v1)**2), nmo=tx-t0;
      const dix=Math.sqrt(Math.max(.01,(v2*v2*t2-v1*v1*t1)/Math.max(.05,t2-t1)));
      document.getElementById('clean33_t0').textContent=t0.toFixed(2)+' s';
      document.getElementById('clean33_tx').textContent=tx.toFixed(2)+' s';
      document.getElementById('clean33_nmo').textContent=nmo.toFixed(2)+' s';
      const W=620,H=360,pad=48,sx=x=>pad+(x+5)/10*(W-pad*1.45),sy=t=>H-pad-t/3.2*(H-pad*1.45);
      let path=''; for(let i=0;i<=220;i++){const x=-5+i/220*10,t=Math.sqrt(t0*t0+(x/v1)**2);path+=(i?'L':'M')+sx(x)+' '+sy(t)+' ';}
      svg.innerHTML=`<rect x="12" y="12" width="596" height="336" rx="24" fill="rgba(15,23,42,.18)" stroke="rgba(148,163,184,.22)"/><path d="M${pad} 20L${pad} ${H-pad}L${W-24} ${H-pad}" stroke="rgba(148,163,184,.45)" fill="none"/><path d="${path}" stroke="#22d3ee" stroke-width="4" fill="none"/><path d="M${sx(-5)} ${sy(t0)}L${sx(5)} ${sy(t0)}" stroke="#fbbf24" stroke-width="3" stroke-dasharray="10 8"/><circle cx="${sx(off)}" cy="${sy(tx)}" r="6" fill="#fff"/><text x="72" y="72" fill="rgba(226,232,240,.95)" font-size="14" font-weight="800">Reflection hyperbola</text><text x="72" y="98" fill="rgba(226,232,240,.76)" font-size="13">t₀=${t0.toFixed(2)} s；T(x)=${tx.toFixed(2)} s；NMO=${nmo.toFixed(2)} s</text>`;
      const bw=320,bw1=Math.max(20,Math.min(bw,v1/6*320)),bw2=Math.max(20,Math.min(bw,v2/7*320)),bwD=Math.max(20,Math.min(bw,dix/8*320));
      dixSvg.innerHTML=`<text x="12" y="20" fill="rgba(226,232,240,.92)" font-size="14" font-weight="800">Dix interval velocity：${dix.toFixed(2)} km/s</text><text x="12" y="52" fill="rgba(226,232,240,.86)" font-size="13">第 1 介面 Vrms</text><rect x="142" y="39" width="${bw1}" height="16" rx="8" fill="#22d3ee"/><text x="468" y="52" fill="rgba(226,232,240,.86)" font-size="13">${v1.toFixed(1)}</text><text x="12" y="105" fill="rgba(226,232,240,.86)" font-size="13">第 2 介面 Vrms</text><rect x="142" y="92" width="${bw2}" height="16" rx="8" fill="#38bdf8"/><text x="468" y="105" fill="rgba(226,232,240,.86)" font-size="13">${v2.toFixed(1)}</text><text x="12" y="158" fill="#fbbf24" font-size="13" font-weight="800">Dix 速度</text><rect x="142" y="144" width="${bwD}" height="18" rx="9" fill="#fbbf24"/><text x="424" y="158" fill="#fbbf24" font-size="13" font-weight="800">${dix.toFixed(2)}</text>`;
    }
    render();
  }

  const phaseData={
    P:['P','P：壓縮波，可在固體與液體中傳播；此處示意為在地函中轉折的直達 P 波。','壓縮波路徑','P'],
    S:['S','S：剪力波，只能在固體中傳播；直接 S 波不會進入液態外核。','剪力波只在固態地函內','S'],
    PP:['PP','PP：P 波在地表反射一次後抵達測站。','地表反射一次','PP'],
    SS:['SS','SS：S 波在地表反射一次；全程仍在固態地函內。','S + 地表反射 + S','SS'],
    PcP:['PcP','PcP：P 波在核幔邊界 CMB 反射後回到地表。','P 在 CMB 反射','PcP'],
    ScS:['ScS','ScS：S 波到達 CMB 後反射，因外核不傳 S 波。','S 在 CMB 反射','ScS'],
    PKP:['PKP','PKP：P 波穿過外核 K，再回到地函。','K 代表外核中的 P 波','PKP'],
    PKIKP:['PKIKP','PKIKP：P 波穿過外核與內核，是研究內核的重要相位。','穿過外核 K 與內核 I','PKIKP'],
    PKiKP:['PKiKP','PKiKP：P 波進入外核後，在內核邊界 ICB 反射。','i 代表內核邊界反射','PKiKP'],
    Pdiff:['Pdiff','Pdiff：P 波沿核幔邊界附近繞射，常見於 P 波陰影區邊緣。','沿 CMB 繞射','Pdiff'],
    SKS:['SKS','SKS：地函段是 S，進入外核後轉為 K，也就是外核中的 P 波，再出外核轉回 S。','外核段是 K，不是 S','SKS']
  };

  function phaseSvg(type){
    const pStroke='stroke="#67e8f9" stroke-width="5" fill="none" stroke-linecap="round"';
    const sStroke='stroke="#e9a8ff" stroke-width="5" fill="none" stroke-linecap="round" stroke-dasharray="11 9"';
    const kStroke='stroke="#fbbf24" stroke-width="5" fill="none" stroke-linecap="round"';
    const iStroke='stroke="#ffffff" stroke-width="5" fill="none" stroke-linecap="round"';
    const paths={
      P:`<path ${pStroke} d="M110 130 C180 82 340 82 410 130"/>`,
      S:`<path ${sStroke} d="M110 130 C180 76 340 76 410 130"/>`,
      PP:`<path ${pStroke} d="M110 130 C180 42 238 36 260 30 C282 36 340 42 410 130"/>`,
      SS:`<path ${sStroke} d="M110 130 C180 42 238 36 260 30 C282 36 340 42 410 130"/>`,
      PcP:`<path ${pStroke} d="M110 130 C160 235 220 278 260 278 C300 278 360 235 410 130"/>`,
      ScS:`<path ${sStroke} d="M110 130 C160 235 220 278 260 278 C300 278 360 235 410 130"/>`,
      PKP:`<path ${pStroke} d="M110 130 C160 215 180 230 191 236"/><path ${kStroke} d="M191 236 C230 255 290 255 329 236"/><path ${pStroke} d="M329 236 C340 230 360 215 410 130"/>`,
      PKIKP:`<path ${pStroke} d="M110 130 C160 220 185 235 198 240"/><path ${kStroke} d="M198 240 C224 228 238 214 260 200"/><path ${iStroke} d="M260 200 C282 186 296 172 322 160"/><path ${kStroke} d="M322 160 C345 156 372 145 410 130"/>`,
      PKiKP:`<path ${pStroke} d="M110 130 C160 220 190 235 198 240"/><path ${kStroke} d="M198 240 C226 230 248 190 260 162 C272 190 294 230 322 240"/><path ${pStroke} d="M322 240 C352 225 378 180 410 130"/>`,
      Pdiff:`<path ${pStroke} d="M110 130 C155 215 180 240 205 254"/><path ${pStroke} d="M205 254 A78 78 0 0 0 315 254"/><path ${pStroke} d="M315 254 C340 240 365 215 410 130"/>`,
      SKS:`<path ${sStroke} d="M110 130 C150 205 170 226 191 236"/><path ${kStroke} d="M191 236 C230 255 290 255 329 236"/><path ${sStroke} d="M329 236 C350 226 370 205 410 130"/>`
    };
    return `<svg class="clean-svg" viewBox="0 0 520 360" aria-label="${type}相位路徑">
      <defs><radialGradient id="coreg"><stop offset="0" stop-color="#fbbf24"/><stop offset=".36" stop-color="#f59e0b"/><stop offset=".63" stop-color="#334155"/><stop offset="1" stop-color="#0f172a"/></radialGradient></defs>
      <circle cx="260" cy="200" r="150" fill="url(#coreg)" stroke="rgba(226,232,240,.26)"/>
      <circle cx="260" cy="200" r="78" fill="rgba(251,191,36,.14)" stroke="rgba(251,191,36,.48)"/>
      <circle cx="260" cy="200" r="38" fill="rgba(251,191,36,.28)" stroke="rgba(251,191,36,.58)"/>
      <circle cx="110" cy="130" r="7" fill="#fb7185"/><circle cx="410" cy="130" r="7" fill="#67e8f9"/>
      <text x="72" y="114" fill="rgba(226,232,240,.9)" font-size="13" font-weight="700">Source</text><text x="405" y="114" fill="rgba(226,232,240,.9)" font-size="13" font-weight="700">Receiver</text>
      <text x="205" y="88" fill="rgba(226,232,240,.78)" font-size="13" font-weight="700">Solid mantle</text><text x="322" y="205" fill="rgba(226,232,240,.78)" font-size="12" font-weight="700">Outer core = K</text><text x="256" y="204" fill="rgba(226,232,240,.78)" font-size="13" font-weight="700">I</text>
      ${paths[type]||paths.P}
    </svg>`;
  }

  function patch35(){
    if(getHash() !== 'm35') return;
    const target=getGrid();
    if(!target || target.dataset.clean35 === '1') return;
    target.dataset.clean35='1';
    let current='S';
    target.innerHTML=`
      <div class="clean-phase-layout">
        <div class="clean-card"><div id="clean35_svg"></div><div class="clean-legend"><span><i class="clean-line" style="background:#67e8f9"></i>P：壓縮路徑</span><span><i class="clean-line" style="background:#fbbf24"></i>K：外核中的 P 波</span><span><i class="clean-line" style="background:#e9a8ff"></i>S：剪力波路徑，不進外核</span><span><i class="clean-line" style="background:#fff"></i>I：內核中的 P 波</span></div></div>
        <div class="clean-card"><div class="clean-phase-title">Phase Challenge</div><h3 id="clean35_name" class="clean-phase-name"></h3><div id="clean35_desc" class="clean-phase-desc"></div><div id="clean35_rule" class="clean-phase-rule"></div><div id="clean35_buttons" class="clean-phase-buttons"></div></div>
      </div>`;
    function render(){
      const [name,desc,rule,draw]=phaseData[current];
      document.getElementById('clean35_name').textContent=name;
      document.getElementById('clean35_desc').textContent=desc;
      document.getElementById('clean35_rule').textContent=rule;
      document.getElementById('clean35_svg').innerHTML=phaseSvg(draw);
      const order=['P','S','PP','SS','PcP','ScS','PKP','PKIKP','PKiKP','Pdiff','SKS'];
      const btns=document.getElementById('clean35_buttons');
      btns.innerHTML=order.map(p=>`<button class="${p===current?'active':''}" data-p="${p}">${p}</button>`).join('');
      btns.querySelectorAll('button').forEach(b=>b.addEventListener('click',()=>{current=b.dataset.p;render();}));
    }
    render();
  }

  function patchPractice(){
    const hash=getHash();
    const hasPractice = hash.includes('practice') || hash.includes('record') || hash === 'work' || !!Array.from(document.querySelectorAll('h1,h2,h3,.eyebrow')).find(el=>(el.textContent||'').includes('Record Section Viewer') || (el.textContent||'').includes('彩色版：多測站'));
    if(!hasPractice) return;
    const zone=getZone() || document.querySelector('.module-page') || document.querySelector('main');
    if(!zone) return;
    const target=zone.querySelector('.interactive-grid, .interactive-grid.two, .interactive-grid.one') || zone;
    if(!target || target.dataset.cleanPractice==='1') return;
    target.dataset.cleanPractice='1';
    const color='./record-section/record_section_color.png', bw='./record-section/record_section_bw.png', rep='./record-section/cwa_report.png';
    target.innerHTML=`
      <div class="clean-grid">
        <div class="clean-card">
          <div class="clean-record-buttons"><button class="active" data-rs="color">彩色版</button><button data-rs="bw">黑白版</button><button data-rs="report">地震報告</button><button id="cleanRSOverlay" class="active">讀圖輔助標籤</button></div>
          <h3 id="cleanRSTitle">彩色版：多測站分色與標籤</h3>
          <div class="clean-record-imgwrap"><div class="clean-record-frame"><img id="cleanRSImg" src="${color}" alt="Record Section"><div id="cleanRSOverlayBox" class="clean-record-overlay"><svg viewBox="0 0 1000 680" preserveAspectRatio="none" style="position:absolute;inset:0;width:100%;height:100%"><path d="M70 105 C230 145 350 230 500 330 C650 425 760 520 930 610" fill="none" stroke="rgba(120,210,255,.92)" stroke-width="6" stroke-dasharray="16 12"/><path d="M70 170 C260 190 430 265 590 365 C720 445 820 515 930 560" fill="none" stroke="rgba(217,183,111,.9)" stroke-width="4" stroke-dasharray="8 14"/></svg><div class="clean-tip a">Time：發震後秒數</div><div class="clean-tip b">斜向能量帶：可追蹤的波群走時趨勢</div></div></div></div>
        </div>
        <div class="clean-card">
          ${slider('示意振幅放大 amp_scale',6,2,14,.5,'×','cleanRS_amp')}
          ${slider('示意時間窗',80,60,150,10,' s','cleanRS_tw')}
          <div class="clean-readout"><div class="clean-chip">事件時間：2026-05-01 12:39:55 UTC</div><div class="clean-chip">資料網路：CWASN / Taiwan GDMS</div><div class="clean-chip">成功繪製：117 個測站</div><div class="clean-chip">濾波頻帶：0.5–5.0 Hz</div><div class="clean-chip">X = distance + normalized amplitude × amp_scale</div></div>
        </div>
      </div>`;
    const img=document.getElementById('cleanRSImg'), amp=document.getElementById('cleanRS_amp'), tw=document.getElementById('cleanRS_tw'), overlay=document.getElementById('cleanRSOverlayBox'), title=document.getElementById('cleanRSTitle');
    let current='color', overlayOn=true;
    function apply(){
      const a=+amp.value,t=+tw.value;
      document.getElementById('cleanRS_amp_label').textContent=a+'×';
      document.getElementById('cleanRS_tw_label').textContent=t+' s';
      const sx=1+(a-6)*.045, crop=Math.max(0,Math.min(38,((150-t)/90)*38));
      if(current==='color'){img.src=color;title.textContent='彩色版：多測站分色與標籤';img.style.filter='none';}
      if(current==='bw'){img.src=bw;title.textContent='黑白版：原始風格走時與波形剖面圖';img.style.filter='grayscale(1)';}
      if(current==='report'){img.src=rep;title.textContent='中央氣象署地震報告';img.style.filter='none';}
      img.style.transform=current==='report'?'scaleX(1)':`scaleX(${sx.toFixed(3)})`;
      img.style.clipPath=current==='report'?'inset(0 0 0 0)':`inset(0 0 ${crop.toFixed(1)}% 0)`;
      overlay.classList.toggle('off', !overlayOn || current==='report');
    }
    amp.addEventListener('input',apply); tw.addEventListener('input',apply);
    target.querySelectorAll('[data-rs]').forEach(btn=>btn.addEventListener('click',()=>{current=btn.dataset.rs;target.querySelectorAll('[data-rs]').forEach(b=>b.classList.remove('active'));btn.classList.add('active');apply();}));
    document.getElementById('cleanRSOverlay').addEventListener('click',e=>{overlayOn=!overlayOn;e.currentTarget.classList.toggle('active',overlayOn);apply();});
    apply();
  }

  function run(){
    addStyle();
    patch31();
    patch33();
    patch35();
    patchPractice();
  }

  const mo = new MutationObserver(run);
  if(document.body) mo.observe(document.body,{childList:true,subtree:true});
  window.addEventListener('hashchange',()=>setTimeout(run,120));
  document.addEventListener('DOMContentLoaded',run);
  window.addEventListener('load',run);
  setInterval(run,1000);
})();

JS

if ! grep -q 'clean_interactive_fix.js' "$ROOT/docs/index.html"; then
  python3 - "$ROOT/docs/index.html" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')
tag = '<script src="./clean_interactive_fix.js"></script>'
if '</body>' in s:
    s = s.replace('</body>', '  ' + tag + '\n</body>')
else:
    s += '\n' + tag + '\n'
p.write_text(s, encoding='utf-8')
PY
fi

touch "$ROOT/docs/.nojekyll"

echo "✅ 已恢復並套用乾淨修正版（免 npm）"
echo "已移除：final_ui_fix_patch.js、phase35-corrector.js"
echo "已新增：docs/clean_interactive_fix.js"
echo "下一步：git add . && git commit -m 'Clean final interaction fixes' && git push"
