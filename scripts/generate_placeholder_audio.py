"""
Generate two small placeholder WAV files:
- private_assets/sfx/beep.wav   (short click)
- private_assets/sfx/success.wav (3-note ding)

Run from project root:
  python scripts/generate_placeholder_audio.py
"""
import os
import wave
import struct
import math

OUT_DIR = os.path.join("private_assets", "sfx")
os.makedirs(OUT_DIR, exist_ok=True)

def write_sine(filename, freq=440.0, duration=0.12, volume=0.3, sample_rate=44100):
    n_samples = int(sample_rate * duration)
    wav = wave.open(filename, 'w')
    wav.setparams((1, 2, sample_rate, n_samples, 'NONE', 'not compressed'))
    for i in range(n_samples):
        t = float(i) / sample_rate
        val = volume * math.sin(2.0 * math.pi * freq * t)
        packed = struct.pack('<h', int(val * 32767.0))
        wav.writeframes(packed)
    wav.close()

def write_success(filename, notes=(523.25, 659.25, 783.99), durations=(0.12,0.12,0.12), gap=0.04):
    sample_rate = 44100
    frames = []
    for idx, f in enumerate(notes):
        dur = durations[idx] if idx < len(durations) else durations[-1]
        n = int(sample_rate * dur)
        for i in range(n):
            t = float(i) / sample_rate
            val = 0.28 * math.sin(2.0 * math.pi * f * t)
            frames.append(struct.pack('<h', int(val * 32767.0)))
        g = int(sample_rate * gap)
        for _ in range(g):
            frames.append(struct.pack('<h', 0))
    wav = wave.open(filename, 'w')
    wav.setparams((1, 2, sample_rate, len(frames), 'NONE', 'not compressed'))
    wav.writeframes(b''.join(frames))
    wav.close()

def main():
    beep_file = os.path.join(OUT_DIR, "beep.wav")
    success_file = os.path.join(OUT_DIR, "success.wav")
    print("Generating placeholder audio:")
    print(" -", beep_file)
    write_sine(beep_file, freq=880.0, duration=0.08, volume=0.25)
    print(" -", success_file)
    write_success(success_file)
    print("Done. Placeholders written to", OUT_DIR)

if __name__ == "__main__":
    main()
