// Minimal synth fallback
const AudioContextCtor = window.AudioContext || window.webkitAudioContext;
let ctx = null;
function ensure() { if (!ctx) ctx = new AudioContextCtor(); return ctx; }
export function playBeep(){ const c=ensure(); if(!c) return; const o=c.createOscillator(), g=c.createGain(); o.type='sine'; o.frequency.value=880; o.connect(g); g.connect(c.destination); g.gain.setValueAtTime(0.15,c.currentTime); o.start(); o.stop(c.currentTime+0.12); }
export default { playBeep };
