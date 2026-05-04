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
