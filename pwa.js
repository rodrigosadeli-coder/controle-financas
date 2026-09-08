/*
 * PWA - Finanças Família Pedrosa de Lima
 * Registro do service worker, aviso de atualização, botão de instalar e atalhos.
 */
(function () {
  'use strict';

  var deferredPrompt = null;
  var updateAccepted = false;
  var installBtn = document.getElementById('btnInstalarApp');

  function storageGet(key) {
    try { return window.localStorage.getItem(key); } catch (e) { return null; }
  }

  function storageSet(key, value) {
    try { window.localStorage.setItem(key, value); } catch (e) { /* modo privado */ }
  }

  function isStandalone() {
    return window.matchMedia('(display-mode: standalone)').matches ||
           window.navigator.standalone === true;
  }

  /* ---------- Aviso de nova versão ---------- */

  function showUpdateToast(worker) {
    if (document.getElementById('pwaUpdateToast')) return;

    var toast = document.createElement('div');
    toast.id = 'pwaUpdateToast';
    toast.className = 'pwa-toast';

    var text = document.createElement('span');
    text.className = 'pwa-toast-text';
    text.textContent = 'Nova versão disponível';

    var updateBtn = document.createElement('button');
    updateBtn.type = 'button';
    updateBtn.className = 'pwa-toast-btn';
    updateBtn.textContent = 'Atualizar';
    updateBtn.addEventListener('click', function () {
      updateAccepted = true;
      updateBtn.disabled = true;
      updateBtn.textContent = 'Atualizando...';
      worker.postMessage({ type: 'SKIP_WAITING' });
    });

    var closeBtn = document.createElement('button');
    closeBtn.type = 'button';
    closeBtn.className = 'pwa-toast-close';
    closeBtn.setAttribute('aria-label', 'Dispensar');
    closeBtn.textContent = '✕';
    closeBtn.addEventListener('click', function () { toast.remove(); });

    toast.appendChild(text);
    toast.appendChild(updateBtn);
    toast.appendChild(closeBtn);
    document.body.appendChild(toast);
  }

  /* ---------- Service worker ---------- */

  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function () {
      navigator.serviceWorker.register('/sw.js').then(function (registration) {
        if (registration.waiting && navigator.serviceWorker.controller) {
          showUpdateToast(registration.waiting);
        }

        registration.addEventListener('updatefound', function () {
          var incoming = registration.installing;
          if (!incoming) return;

          incoming.addEventListener('statechange', function () {
            // Sem controller a instalação é a primeira: não há o que avisar
            if (incoming.state === 'installed' && navigator.serviceWorker.controller) {
              showUpdateToast(incoming);
            }
          });
        });
      }).catch(function (error) {
        console.warn('[PWA] Falha ao registrar o service worker:', error);
      });
    });

    navigator.serviceWorker.addEventListener('controllerchange', function () {
      // Só recarrega quando o próprio usuário pediu a atualização
      if (!updateAccepted) return;
      updateAccepted = false;
      window.location.reload();
    });
  }

  /* ---------- Botão de instalar (Desktop e Android) ---------- */

  window.addEventListener('beforeinstallprompt', function (event) {
    event.preventDefault();
    deferredPrompt = event;
    if (installBtn) installBtn.hidden = false;
  });

  if (installBtn) {
    installBtn.addEventListener('click', function () {
      if (!deferredPrompt) return;
      installBtn.disabled = true;
      deferredPrompt.prompt();
      deferredPrompt.userChoice.then(function (choice) {
        deferredPrompt = null;
        installBtn.disabled = false;
        if (choice.outcome === 'accepted') installBtn.hidden = true;
      });
    });
  }

  window.addEventListener('appinstalled', function () {
    deferredPrompt = null;
    if (installBtn) installBtn.hidden = true;
  });

  /* ---------- Dica de instalação no iOS (sem prompt nativo) ---------- */

  var IOS_HINT_KEY = 'pwa_dica_ios_dispensada';

  function isIOS() {
    return /iphone|ipad|ipod/i.test(window.navigator.userAgent) ||
           (window.navigator.platform === 'MacIntel' && window.navigator.maxTouchPoints > 1);
  }

  if (isIOS() && !isStandalone() && !storageGet(IOS_HINT_KEY)) {
    var hint = document.createElement('div');
    hint.className = 'pwa-ios-hint';

    var hintText = document.createElement('span');
    hintText.innerHTML = 'Para instalar: toque em <strong>Compartilhar</strong> e depois em <strong>Adicionar à Tela de Início</strong>.';

    var hintClose = document.createElement('button');
    hintClose.type = 'button';
    hintClose.className = 'pwa-toast-close';
    hintClose.setAttribute('aria-label', 'Dispensar');
    hintClose.textContent = '✕';
    hintClose.addEventListener('click', function () {
      hint.remove();
      storageSet(IOS_HINT_KEY, '1');
    });

    hint.appendChild(hintText);
    hint.appendChild(hintClose);
    document.body.appendChild(hint);
  }

  /* ---------- Atalhos do ícone (?action=) ---------- */

  var action = new URLSearchParams(window.location.search).get('action');
  var ACTIONS = { nova: 'openAddModal', calendario: 'openCalendarModal' };

  if (action && ACTIONS[action]) {
    var handler = ACTIONS[action];
    var tries = 0;

    var timer = setInterval(function () {
      var container = document.getElementById('appContainer');
      var visible = container && window.getComputedStyle(container).display !== 'none';

      if (visible && typeof window[handler] === 'function') {
        clearInterval(timer);
        setTimeout(function () { window[handler](); }, 400);
      } else if (++tries > 120) {
        // Desiste após ~60s: o usuário provavelmente parou na tela de login
        clearInterval(timer);
      }
    }, 500);
  }
})();
