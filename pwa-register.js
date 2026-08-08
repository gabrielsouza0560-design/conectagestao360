// Conecta Gestão — registro do Service Worker + botão "Instalar aplicativo"
// Script único, incluído em todas as telas.
(function () {
  if (window.__cgPwaRegistered) return; // evita listener duplicado se o script for incluído 2x
  window.__cgPwaRegistered = true;

  // ---------- Service Worker ----------
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function () {
      navigator.serviceWorker.register('/sw.js').catch(function (err) {
        console.warn('Não foi possível registrar o Service Worker.', err);
      });
    });

    // Atualização automática: quando o novo SW assume o controle, recarrega uma vez.
    let refrescando = false;
    navigator.serviceWorker.addEventListener('controllerchange', function () {
      if (refrescando) return;
      refrescando = true;
      window.location.reload();
    });
  }

  // ---------- Botão "Instalar aplicativo" ----------
  let deferredPrompt = null;

  function jaInstalado() {
    return window.matchMedia('(display-mode: standalone)').matches
      || window.navigator.standalone === true; // Safari/iOS
  }

  function criarBotao() {
    if (document.getElementById('cg-install-btn')) return document.getElementById('cg-install-btn');
    const btn = document.createElement('button');
    btn.id = 'cg-install-btn';
    btn.type = 'button';
    btn.textContent = '📲 Instalar aplicativo';
    btn.style.cssText = [
      'position:fixed', 'left:12px', 'bottom:12px', 'z-index:999',
      'display:none', 'align-items:center', 'gap:6px',
      'background:linear-gradient(135deg,#2563EB,#60A5FA)', 'color:#fff',
      'border:none', 'border-radius:999px', 'padding:11px 18px',
      'font-family:Inter,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif',
      'font-size:13px', 'font-weight:700', 'cursor:pointer',
      'box-shadow:0 6px 18px rgba(37,99,235,.4)',
    ].join(';');
    btn.addEventListener('click', async function () {
      if (!deferredPrompt) return;
      btn.disabled = true;
      deferredPrompt.prompt();
      const { outcome } = await deferredPrompt.userChoice;
      if (outcome === 'accepted') {
        esconderBotao();
      }
      deferredPrompt = null;
      btn.disabled = false;
    });
    document.body.appendChild(btn);
    return btn;
  }

  function mostrarBotao() {
    if (jaInstalado()) return;
    const btn = criarBotao();
    btn.style.display = 'flex';
  }

  function esconderBotao() {
    const btn = document.getElementById('cg-install-btn');
    if (btn) btn.style.display = 'none';
  }

  if (!jaInstalado()) {
    window.addEventListener('beforeinstallprompt', function (event) {
      event.preventDefault();
      deferredPrompt = event;
      mostrarBotao();
    });
  }

  window.addEventListener('appinstalled', function () {
    deferredPrompt = null;
    esconderBotao();
  });
})();
