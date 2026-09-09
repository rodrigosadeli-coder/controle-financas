/*
 * Service Worker - Finanças Família Pedrosa de Lima
 *
 * Escopo: apenas o app shell fica offline. Nenhum dado financeiro é cacheado:
 * toda chamada ao Supabase passa direto pela rede, sempre.
 *
 * Ao publicar uma nova versão, incremente CACHE_VERSION.
 */

const CACHE_VERSION = 'v2';
const SHELL_CACHE = `financas-shell-${CACHE_VERSION}`;
const ASSET_CACHE = `financas-assets-${CACHE_VERSION}`;

const SHELL_URL = '/index.html';

const SHELL_ASSETS = [
  '/',
  '/pwa.js',
  '/manifest.webmanifest',
  '/icons/icon.svg',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
  '/icons/icon-maskable-512.png',
  '/icons/apple-touch-icon.png',
  '/icons/favicon-32.png'
];

// CDNs com URLs versionadas, seguras para cachear
const CACHEABLE_ORIGINS = [
  'https://cdn.jsdelivr.net',
  'https://cdnjs.cloudflare.com',
  'https://fonts.googleapis.com',
  'https://fonts.gstatic.com'
];

/*
 * Bibliotecas externas de que o app depende para sequer inicializar.
 * Precisam ser baixadas no install: as tags <script> da página são no-cors e
 * devolvem resposta opaca, que não dá para validar.
 */
const VENDOR_ASSETS = [
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2',
  'https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js',
  'https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.25/jspdf.plugin.autotable.min.js',
  'https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700&family=Inter:wght@300;400;500;600&display=swap'
];

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const shell = await caches.open(SHELL_CACHE);
    // O shell é obrigatório; os demais não podem derrubar a instalação
    await shell.add(SHELL_URL);
    await Promise.allSettled(SHELL_ASSETS.map((asset) => shell.add(asset)));

    const assets = await caches.open(ASSET_CACHE);
    await Promise.allSettled(VENDOR_ASSETS.map((asset) => assets.add(asset)));
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(
      keys
        .filter((key) => key !== SHELL_CACHE && key !== ASSET_CACHE)
        .map((key) => caches.delete(key))
    );
    await self.clients.claim();
  })());
});

self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

/*
 * O index.html é a aplicação inteira e muda a cada release, então a rede sempre
 * tem prioridade. O cache só entra quando não há conexão.
 */
async function networkFirst(request) {
  const cache = await caches.open(SHELL_CACHE);
  try {
    const response = await fetch(request);
    if (response && response.ok) {
      cache.put(SHELL_URL, response.clone());
    }
    return response;
  } catch (error) {
    const cached = await cache.match(SHELL_URL);
    if (cached) return cached;
    throw error;
  }
}

/*
 * Respostas opacas (status 0) vêm de <script>/<link> cross-origin, que a página
 * busca em modo no-cors. Não dá para inspecionar o status, mas são as URLs fixas
 * das CDNs já filtradas por CACHEABLE_ORIGINS — sem elas não há offline nenhum.
 */
function isCacheable(response) {
  return !!response && (response.ok || response.type === 'opaque');
}

async function staleWhileRevalidate(request, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(request);

  const networkFetch = fetch(request)
    .then((response) => {
      if (isCacheable(response)) cache.put(request, response.clone());
      return response;
    })
    .catch(() => null);

  if (cached) return cached;

  const response = await networkFetch;
  if (response) return response;
  return new Response('', { status: 504, statusText: 'Offline' });
}

self.addEventListener('fetch', (event) => {
  const request = event.request;

  if (request.method !== 'GET') return;

  const url = new URL(request.url);

  if (url.protocol !== 'http:' && url.protocol !== 'https:') return;

  // Dado financeiro nunca vem do cache
  if (url.hostname.endsWith('.supabase.co')) return;

  if (request.mode === 'navigate') {
    event.respondWith(networkFirst(request));
    return;
  }

  if (url.origin === self.location.origin) {
    event.respondWith(staleWhileRevalidate(request, SHELL_CACHE));
    return;
  }

  if (CACHEABLE_ORIGINS.includes(url.origin)) {
    event.respondWith(staleWhileRevalidate(request, ASSET_CACHE));
  }
});
