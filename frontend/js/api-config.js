(function () {
  const isDev = location.hostname === 'localhost' || location.hostname === '127.0.0.1';
  const API_BASE = isDev ? 'http://localhost:8000' : location.origin;
  const WS_BASE = isDev ? 'ws://localhost:8000' : (location.protocol === 'https:' ? 'wss://' : 'ws://') + location.host;
  window.API_CONFIG = { websocket: { kids: WS_BASE + '/ws/kids' }, api: { base: API_BASE } };
})();
