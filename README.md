# Noice

A spatial ambient-sound **menu bar app** for macOS.

You sit at the center; drag sounds around you on a canvas. **Where you place it is the mix** —
radial distance sets volume, left/right sets stereo pan.

## Features (v1)

- 🎛 **Spatial canvas** — drag sound "pucks" around a center listener
- 🔊 **Layering** — stack as many sounds as you like
- 🎚 **Per-sound + master volume**
- ▶️ **Play / pause**, seamless looping
- 💾 **Presets** — save & recall named mixes
- 🌙 **Sleep timer** with gentle fade-out (15–120 min)
- 🚀 **Launch at login**
- ⌨️ **Media keys / Control Center** play-pause
- 🔁 Restores your last mix on reopen
- 🪶 Low CPU

Sounds (17 real looping field recordings, bundled under `Resources/Sounds`),
grouped by category in the palette:

- **Weather** — Rain, Thunder, Wind
- **Water** — Ocean, Stream
- **Nature** — Forest, Fire, Birds, Crickets
- **Places** — City, Café
- **Ambient** — Chimes, Fan, Train
- **Noise** — White, Pink, Brown

Starter **themes** (curated mixes seeded as presets on first run): Rainy Café,
Cozy Fire, Ocean Sleep, Forest Morning, Deep Focus.

All sounds are loudness-normalized to ~−20 LUFS (two-pass `ffmpeg loudnorm`)
so layers sit at an even level. Swap/extend by dropping `.m4a` files into
`Resources/Sounds` and adding a row to `Sound.catalog`.

### Audio credits / licensing

All bundled audio is open-licensed:

- Most loops are from [Blankie](https://github.com/codybrom/blankie) (rain,
  thunder/storm, stream, fire/fireplace, birds, crickets/summer-night, city,
  wind, ocean/waves, forest, café, fan, train, white/pink/brown noise).
- Wind chimes is from [Moodist](https://github.com/remvze/moodist).

See those projects for the underlying sample licenses and attributions.

## Build & run

```sh
./build.sh release      # builds Noice.app
open Noice.app          # launches as a menu-bar agent (no dock icon)
```

Requires macOS 14+, Xcode 16+ / Swift 6 toolchain.

## Architecture

| File | Role |
|------|------|
| `NoiceApp.swift` | `MenuBarExtra` entry point |
| `AppState.swift` | Controller: layers, presets, timer, playback |
| `Audio/AudioEngine.swift` | `AVAudioEngine`, one looping player node per layer |
| `Audio/SoundGenerator.swift` | Procedural ambient loops (filtered noise) |
| `Views/CanvasView.swift` | Spatial drag canvas (distance→volume, x→pan) |
| `Views/*` | Palette, puck, controls |
| `Persistence.swift` | Session + presets in UserDefaults (JSON) |
| `LaunchAtLogin.swift` | `SMAppService` toggle |
| `NowPlayingController.swift` | Media keys via `MPRemoteCommandCenter` |

## Roadmap / not yet built

- Custom file import (drag your own loops in; engine is already file-backed)
- Shareable preset files, iCloud sync, global hotkey
- App icon, notch-aware layout, scheduling
- More sounds (17 loops bundled today)

Skipped by choice: 3D spatial audio / AirPods head tracking (not needed).
