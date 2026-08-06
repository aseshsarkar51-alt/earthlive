// EarthLive service worker.
// Bump CACHE whenever the shell changes — activate() below purges every
// older cache, which is what stops a stale index.html being served after a
// deploy. 'transformers-cache' is deliberately preserved: it holds the
// on-device search model, which we never want to re-download.
const CACHE = 'earthlive-v3';
const KEEP = [CACHE, 'transformers-cache'];

self.addEventListener('install', () => { self.skipWaiting(); });

self.addEventListener('activate', (e) => {
  e.waitUntil((async () => {
    const names = await caches.keys();
    await Promise.all(names.filter(n => !KEEP.includes(n)).map(n => caches.delete(n)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET' || req.mode !== 'navigate') return;
  e.respondWith((async () => {
    try {
      // cache:'reload' skips the browser HTTP cache too, so a fresh deploy
      // shows up on the next visit instead of up to 10 minutes later.
      const fresh = await fetch(req, { cache: 'reload' });
      const c = await caches.open(CACHE);
      c.put(req, fresh.clone());
      return fresh;
    } catch (err) {
      const hit = await caches.match(req);
      return hit || Response.error();   // offline fallback
    }
  })());
});
