// نظام الإدارة المتكامل — Service Worker
// يستخدم استراتيجية Network First مع Fallback للكاش للموارد الخارجية

const CACHE_NAME = 'inv-app-v3';
const CORE_ASSETS = [
    './index.html',
    './manifest.json'
];

// تثبيت الـ Service Worker وحفظ الملفات الأساسية
self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME).then(cache => {
            console.log('[SW] Opening cache');
            return cache.addAll(CORE_ASSETS);
        })
    );
    self.skipWaiting();
});

// تفعيل الـ Service Worker وحذف الإصدارات القديمة
self.addEventListener('activate', event => {
    event.waitUntil(
        caches.keys().then(cacheNames =>
            Promise.all(
                cacheNames
                    .filter(name => name !== CACHE_NAME)
                    .map(name => caches.delete(name))
            )
        )
    );
    self.clients.claim();
});

// استدعاء الملفات — Network First مع Fallback للكاش
self.addEventListener('fetch', event => {
    // تجاهل طلبات غير GET والطلبات من chrome-extension
    if (event.request.method !== 'GET') return;
    if (!event.request.url.startsWith('http')) return;

    event.respondWith(
        fetch(event.request)
            .then(networkResponse => {
                // حفظ نسخة في الكاش إذا نجح الطلب
                if (networkResponse && networkResponse.status === 200) {
                    const cloned = networkResponse.clone();
                    caches.open(CACHE_NAME).then(cache => cache.put(event.request, cloned));
                }
                return networkResponse;
            })
            .catch(() => caches.match(event.request))
    );
});