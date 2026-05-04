(function () {
  const PHASES = {
    P: {
      title: 'P',
      desc: 'P：壓縮波，只以 P 波型態在固態地函中傳播；在約 98° 前可作為直達 P，相位不進入外核。',
      note: '路徑限制：只在 mantle 內轉折，不穿越外核。',
      segments: [{ d: 'M154 122 C220 165 400 165 466 122', cls: 'p' }]
    },
    S: {
      title: 'S',
      desc: 'S：剪力波，只能在固體中傳播。外地核為液態，因此 S 波絕對不能穿過外核；直接 S 只在地函中傳播，遇到核幔邊界附近會形成 S 波陰影區或轉為繞射/反射相關相位。',
      note: '路徑限制：S 線必須停留在 solid mantle，不得畫入 outer core。',
      segments: [{ d: 'M154 122 C225 330 395 330 466 122', cls: 's' }]
    },
    PP: {
      title: 'PP',
      desc: 'PP：P 波在地表反射一次後再抵達測站；整條路徑仍是 P 波，且不進入地核。',
      note: 'P + 地表反射 + P。',
      segments: [{ d: 'M154 122 C210 68 260 48 310 38 C360 48 410 68 466 122', cls: 'p' }]
    },
    SS: {
      title: 'SS',
      desc: 'SS：S 波在地表反射一次後再抵達測站；全程是 S 波，且只在固態地函中傳播。',
      note: 'S + 地表反射 + S；仍不得進入外核。',
      segments: [{ d: 'M154 122 C210 70 260 48 310 38 C360 48 410 70 466 122', cls: 's' }]
    },
    PcP: {
      title: 'PcP',
      desc: 'PcP：P 波下行至核幔邊界 CMB，在 CMB 反射後以 P 波回到地表；小寫 c 代表 core-mantle boundary reflection。',
      note: 'P 到 CMB 反射，不進入外核。',
      segments: [{ d: 'M154 122 C220 245 275 300 310 306 C345 300 400 245 466 122', cls: 'p reflect' }]
    },
    ScS: {
      title: 'ScS',
      desc: 'ScS：S 波在核幔邊界 CMB 反射。由於外核為液態，S 波不能透射進外核，因此 ScS 常是很清楚的 CMB 反射相位。',
      note: 'S 到 CMB 全反射，不穿越 outer core。',
      segments: [{ d: 'M154 122 C220 245 275 300 310 306 C345 300 400 245 466 122', cls: 's reflect' }]
    },
    PKP: {
      title: 'PKP',
      desc: 'PKP：P 波進入外核後仍以 P 波傳播；K 代表外核（Kern/Core）路徑。PKP 穿過 outer core，但不一定進入 inner core。',
      note: 'P → K（外核 P 波）→ P。',
      segments: [
        { d: 'M154 122 C205 175 238 220 262 242', cls: 'p' },
        { d: 'M262 242 C286 264 334 264 358 242', cls: 'k' },
        { d: 'M358 242 C382 220 415 175 466 122', cls: 'p' }
      ]
    },
    PKIKP: {
      title: 'PKIKP',
      desc: 'PKIKP：P 波穿過地函、外核、內核、外核，再回到地函；I 代表內核中的 P 波路徑，是研究內核的重要相位。',
      note: 'P → K → I → K → P，會穿越 inner core。',
      segments: [
        { d: 'M154 122 C208 178 242 212 275 222', cls: 'p' },
        { d: 'M275 222 C288 216 298 212 310 210', cls: 'k' },
        { d: 'M310 210 C322 208 333 204 345 198', cls: 'i' },
        { d: 'M345 198 C380 190 414 174 466 122', cls: 'p' }
      ]
    },
    PKiKP: {
      title: 'PKiKP',
      desc: 'PKiKP：P 波進入外核後，在內核邊界 ICB 反射，再回到外核與地函；小寫 i 代表 inner-core boundary reflection。',
      note: 'P → K → i 反射 → K → P，不穿透內核。',
      segments: [
        { d: 'M154 122 C216 190 258 235 310 252', cls: 'p' },
        { d: 'M310 252 C362 235 404 190 466 122', cls: 'k reflect' }
      ]
    },
    Pdiff: {
      title: 'Pdiff',
      desc: 'Pdiff：P 波到達核幔邊界附近後，沿 CMB 繞射進入 P 波陰影區邊緣；它不是穿過外核，而是貼著 CMB 傳播。',
      note: 'P 到 CMB，沿 CMB 繞射。',
      segments: [
        { d: 'M154 122 C215 220 245 294 278 304', cls: 'p' },
        { d: 'M278 304 A96 96 0 0 0 342 304', cls: 'diff' },
        { d: 'M342 304 C375 294 405 220 466 122', cls: 'p' }
      ]
    },
    SKS: {
      title: 'SKS',
      desc: 'SKS：波在地函中以 S 波下行，進入液態外核後轉換為 P 波（K），離開外核後再轉回 S 波。這不是 S 波穿過外核，而是 S → P → S 的轉換相位。',
      note: 'S → K(P in outer core) → S；外核段不是 S。',
      segments: [
        { d: 'M154 122 C215 210 246 242 270 250', cls: 's' },
        { d: 'M270 250 C294 266 326 266 350 250', cls: 'k' },
        { d: 'M350 250 C374 242 405 210 466 122', cls: 's' }
      ]
    },
    SKKS: {
      title: 'SKKS',
      desc: 'SKKS：與 SKS 類似，但外核中的 K 段包含一次在 CMB 下方的反射，因此名稱中有兩個 K。地函段是 S，外核段是 P。',
      note: 'S → K → K → S；S 仍未穿越液態外核。',
      segments: [
        { d: 'M154 122 C210 215 240 260 265 270', cls: 's' },
        { d: 'M265 270 C285 312 335 312 355 270', cls: 'k reflect' },
        { d: 'M355 270 C380 260 410 215 466 122', cls: 's' }
      ]
    }
  };

  function css() {
    if (document.getElementById('sc35-css')) return;
    const style = document.createElement('style');
    style.id = 'sc35-css';
    style.textContent = `
      .sc35-fixed-panel{border:1px solid rgba(148,163,184,.28);border-radius:28px;padding:22px;margin:18px 0;background:linear-gradient(145deg,rgba(255,255,255,.08),rgba(255,255,255,.035));box-shadow:0 18px 70px rgba(0,0,0,.25);}
      .sc35-grid{display:grid;grid-template-columns:minmax(300px,1.08fr) minmax(280px,.92fr);gap:20px;align-items:stretch;}
      .sc35-canvas{min-height:430px;border:1px solid rgba(148,163,184,.22);border-radius:24px;background:rgba(8,19,33,.42);display:grid;place-items:center;overflow:hidden;}
      .sc35-svg{width:100%;height:auto;max-height:520px;}
      .sc35-info{border:1px solid rgba(148,163,184,.22);border-radius:24px;padding:22px;background:rgba(15,32,51,.55);}
      .sc35-kicker{font-weight:900;letter-spacing:.28em;text-transform:uppercase;color:#a78bfa;font-size:.78rem;margin-bottom:14px;}
      .sc35-title{font-family:Playfair Display,serif;font-size:clamp(3rem,8vw,5.4rem);line-height:.88;margin:0 0 18px;color:#c4b5fd;}
      .sc35-desc{font-size:1.02rem;line-height:1.82;color:#d8e1ef;}
      .sc35-note{margin:16px 0;padding:14px 16px;border-left:4px solid #f472b6;background:rgba(244,114,182,.1);border-radius:14px;color:#fce7f3;line-height:1.65;}
      .sc35-buttons{display:flex;flex-wrap:wrap;gap:9px;margin-top:16px;}
      .sc35-buttons button{border:1px solid rgba(148,163,184,.35);background:rgba(255,255,255,.06);color:#e2e8f0;border-radius:999px;padding:9px 13px;font-weight:900;cursor:pointer;}
      .sc35-buttons button.active{background:#a78bfa;color:#081321;border-color:#a78bfa;box-shadow:0 0 0 4px rgba(167,139,250,.16);}
      .sc35-legend{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:8px;margin-top:14px;color:#a7b6c8;font-size:.92rem;}
      .sc35-legend span{display:inline-flex;align-items:center;gap:8px;}
      .sc35-chip{display:inline-block;width:26px;height:4px;border-radius:999px;background:#67e8f9;}
      .sc35-chip.s{background:#f0abfc;border-top:2px dashed #f0abfc;}
      .sc35-chip.k{background:#fbbf24;}.sc35-chip.i{background:#fff;}.sc35-chip.diff{background:#34d399;}
      .sc35-path{fill:none;stroke-width:7;stroke-linecap:round;stroke-linejoin:round;filter:drop-shadow(0 0 8px rgba(255,255,255,.18));opacity:.96;}
      .sc35-path.p{stroke:#67e8f9;}.sc35-path.s{stroke:#f0abfc;stroke-dasharray:13 10;}.sc35-path.k{stroke:#fbbf24;}.sc35-path.i{stroke:#ffffff;stroke-width:8;}.sc35-path.diff{stroke:#34d399;stroke-dasharray:8 8;}.sc35-path.reflect{filter:drop-shadow(0 0 10px rgba(251,191,36,.3));}
      .sc35-label{fill:#e2e8f0;font-family:Inter,system-ui,sans-serif;font-weight:800;font-size:14px;}
      .sc35-small{fill:#94a3b8;font-family:Inter,system-ui,sans-serif;font-weight:700;font-size:12px;}
      .sc35-warning{margin-top:18px;padding:14px 16px;border:1px solid rgba(251,191,36,.35);border-radius:18px;background:rgba(251,191,36,.1);color:#fde68a;line-height:1.7;}
      @media(max-width:900px){.sc35-grid{grid-template-columns:1fr}.sc35-legend{grid-template-columns:1fr}.sc35-canvas{min-height:300px}}
    `;
    document.head.appendChild(style);
  }

  function makePanel() {
    const panel = document.createElement('section');
    panel.id = 'sc35-fixed-panel';
    panel.className = 'sc35-fixed-panel';
    panel.innerHTML = `
      <div class="sc35-grid">
        <div class="sc35-canvas">
          <svg class="sc35-svg" viewBox="0 0 620 430" aria-label="Correct body-wave phase paths">
            <defs>
              <radialGradient id="sc35-core" cx="50%" cy="50%" r="55%">
                <stop offset="0%" stop-color="#facc15" stop-opacity=".95"/>
                <stop offset="48%" stop-color="#f59e0b" stop-opacity=".78"/>
                <stop offset="100%" stop-color="#f97316" stop-opacity=".15"/>
              </radialGradient>
            </defs>
            <rect x="0" y="0" width="620" height="430" fill="rgba(8,19,33,.05)"/>
            <circle cx="310" cy="210" r="176" fill="rgba(30,41,59,.28)" stroke="rgba(226,232,240,.22)" stroke-width="2"/>
            <circle cx="310" cy="210" r="96" fill="url(#sc35-core)" stroke="rgba(251,191,36,.38)" stroke-width="2"/>
            <circle cx="310" cy="210" r="42" fill="rgba(253,224,71,.55)" stroke="rgba(255,255,255,.28)" stroke-width="1.5"/>
            <text x="310" y="101" class="sc35-small" text-anchor="middle">Solid mantle</text>
            <text x="390" y="216" class="sc35-small">Outer core = K：液態，只能傳 P，不傳 S</text>
            <text x="310" y="214" class="sc35-small" text-anchor="middle">I</text>
            <circle cx="154" cy="122" r="8" fill="#fb7185"/><text x="118" y="107" class="sc35-label">Source</text>
            <circle cx="466" cy="122" r="8" fill="#67e8f9"/><text x="477" y="107" class="sc35-label">Receiver</text>
            <g id="sc35-paths"></g>
          </svg>
        </div>
        <div class="sc35-info">
          <div class="sc35-kicker">Corrected Phase Challenge</div>
          <h3 class="sc35-title" id="sc35-phase-title">S</h3>
          <p class="sc35-desc" id="sc35-phase-desc"></p>
          <div class="sc35-note" id="sc35-phase-note"></div>
          <div class="sc35-buttons" id="sc35-buttons"></div>
          <div class="sc35-legend">
            <span><i class="sc35-chip"></i>P：壓縮波路徑</span>
            <span><i class="sc35-chip s"></i>S：剪力波路徑，不進外核</span>
            <span><i class="sc35-chip k"></i>K：外核中的 P 波</span>
            <span><i class="sc35-chip i"></i>I：內核中的 P 波</span>
            <span><i class="sc35-chip diff"></i>diff：沿 CMB 繞射</span>
          </div>
          <div class="sc35-warning">已修正：S、SS、ScS 等 S 波相位不會畫入液態外核；SKS / SKKS 的外核段是 K，也就是 P 波在外核中傳播，不是 S 波穿過外核。</div>
        </div>
      </div>
    `;
    return panel;
  }

  function draw(phase) {
    const phaseData = PHASES[phase] || PHASES.S;
    const group = document.getElementById('sc35-paths');
    const title = document.getElementById('sc35-phase-title');
    const desc = document.getElementById('sc35-phase-desc');
    const note = document.getElementById('sc35-phase-note');
    if (!group || !title || !desc || !note) return;
    group.innerHTML = phaseData.segments.map(seg => `<path class="sc35-path ${seg.cls}" d="${seg.d}"></path>`).join('');
    title.textContent = phaseData.title;
    desc.textContent = phaseData.desc;
    note.textContent = phaseData.note;
    document.querySelectorAll('#sc35-buttons button').forEach(btn => btn.classList.toggle('active', btn.dataset.phase === phase));
  }

  function install() {
    if (location.hash && location.hash !== '#m35') return;
    css();
    if (document.getElementById('sc35-fixed-panel')) return;

    const candidates = Array.from(document.querySelectorAll('section, article, div'))
      .filter(el => el.textContent && el.textContent.includes('Phase Challenge') && el.textContent.includes('顏色提示'))
      .sort((a, b) => a.textContent.length - b.textContent.length);
    const old = candidates[0];
    const panel = makePanel();
    if (old) {
      old.style.display = 'none';
      old.insertAdjacentElement('afterend', panel);
    } else {
      const target = Array.from(document.querySelectorAll('h2,h3')).find(h => h.textContent.includes('動手玩'));
      (target ? target.parentElement : document.body).appendChild(panel);
    }

    const buttons = document.getElementById('sc35-buttons');
    Object.keys(PHASES).forEach(key => {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.dataset.phase = key;
      btn.textContent = key;
      btn.addEventListener('click', () => draw(key));
      buttons.appendChild(btn);
    });
    draw('S');
  }

  function schedule() { setTimeout(install, 280); setTimeout(install, 900); setTimeout(install, 1800); }
  window.addEventListener('hashchange', schedule);
  window.addEventListener('load', schedule);
  schedule();
})();
