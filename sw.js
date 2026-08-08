// Conecta Gestão — Service Worker
// Escrito à mão (o projeto é HTML/CSS/JS puro, sem Vite/Workbox).
const CACHE_VERSION = 'cg-v1';
const APP_SHELL_CACHE = CACHE_VERSION + '-shell';
const IMAGE_CACHE = CACHE_VERSION + '-images';
const ASSET_CACHE = CACHE_VERSION + '-assets';
const ALL_CACHES = [APP_SHELL_CACHE, IMAGE_CACHE, ASSET_CACHE];

const APP_SHELL = [
  '/',
  '/index.html',
  '/conecta-gestao-painel-admin.html',
  '/conecta-gestao-cadastro.html',
  '/conecta-gestao-dashboard-prefeito.html',
  '/conecta-gestao-ia.html',
  '/conecta-gestao-avaliacoes.html',
  '/conecta-gestao-relatorios.html',
  '/conecta-gestao-avaliar-evento.html',
  '/manifest.webmanifest',
  '/manifest-admin.webmanifest',
  '/manifest-cadastro.webmanifest',
  '/manifest-dashboard.webmanifest',
  '/manifest-ia.webmanifest',
  '/manifest-avaliacoes.webmanifest',
  '/manifest-relatorios.webmanifest',
  '/manifest-avaliar-evento.webmanifest',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
  '/icons/icon-maskable-512.png',
];

// Nunca cachear nada que vá pro Supabase (autenticação, banco, storage) —
// tem que ser sempre dado fresco da rede, nunca do cache.
function isSupabaseRequest(url) {
  return url.hostname.endsWith('.supabase.co');
}

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(APP_SHELL_CACHE)
      .then((cache) => cache.addAll(APP_SHELL))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys
          .filter((key) => !ALL_CACHES.includes(key))
          .map((key) => caches.delete(key))
      ))
      .then(() => self.clients.claim())
  );
});

async function networkFirst(request, cacheName) {
  const cache = await caches.open(cacheName);
  try {
    const response = await fetch(request);
    if (response && response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  } catch (err) {
    const cached = await cache.match(request);
    if (cached) return cached;
    throw err;
  }
}

async function cacheFirst(request, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(request);
  if (cached) return cached;
  const response = await fetch(request);
  if (response && response.ok) {
    cache.put(request, response.clone());
  }
  return response;
}

async function staleWhileRevalidate(request, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(request);
  const networkPromise = fetch(request).then((response) => {
    if (response && response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  }).catch(() => cached);
  return cached || networkPromise;
}

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);

  // Nunca interceptar chamadas ao Supabase (auth, dados, storage) —
  // sempre direto na rede, nunca cache.
  if (isSupabaseRequest(url)) return;

  // Navegação entre páginas (HTML): tenta rede primeiro, cai pro cache offline.
  if (request.mode === 'navigate') {
    event.respondWith(networkFirst(request, APP_SHELL_CACHE));
    return;
  }

  // Imagens e ícones: cache primeiro (mudam pouco).
  if (request.destination === 'image') {
    event.respondWith(cacheFirst(request, IMAGE_CACHE));
    return;
  }

  // Demais assets estáticos same-origin (manifests etc.) e a lib CDN
  // (PapaParse): busca na rede mas atualiza o cache em segundo plano.
  if (url.origin === self.location.origin || request.destination === 'script') {
    event.respondWith(staleWhileRevalidate(request, ASSET_CACHE));
  }
});
