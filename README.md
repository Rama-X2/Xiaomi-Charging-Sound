# Xiaomi Charging Sound (Universal Magisk Module)

A universal Magisk module that adds the authentic Xiaomi (MIUI/HyperOS) charging connection (plug-in) and disconnection (plug-out) sounds to any Android device running any custom ROM (such as AOSP, LineageOS, SuperiorOS, Pixel Experience, etc.).

**Current Version:** v1.4.0

---

## ❓ What is it for?

On stock Android (AOSP) and many custom ROMs (e.g., SuperiorOS running on Redmi 10a), charging sounds are either completely missing, disabled, or limited. Specifically:
1. **No Disconnect Sound:** Stock Android does not natively support playing a sound when the charger is unplugged.
2. **Missing Sounds on Custom ROMs:** Some custom ROMs omit charging audio assets or settings entirely, resulting in silence when plugging and unplugging.
3. **Xiaomi Sound Experience:** This module brings the premium, satisfying charging and discharging sound effects from Xiaomi's MIUI/HyperOS to any custom ROM.

---

## ⚙️ How does it work?

To ensure it works reliably on every Android version and custom ROM without any battery drain, this module implements a **dual-mechanism** approach:

### 1. Fallback System File Overlay
The module systemlessly replaces default Android charging sound files in the system partitions:
- `/system/media/audio/ui/ChargingStarted.ogg`
- `/product/media/audio/ui/ChargingStarted.ogg`
If your ROM natively supports charging connection sounds, it will play the Xiaomi sound automatically using this overlay.

### 2. Primary Background Daemon & Headless Java Player (Universal)
Since stock Android lacks a charger disconnection sound, we run a custom daemon in the background to handle playbacks:
- **Startup & Settings Toggle:** At boot, `service.sh` runs as a root service. It executes `settings put secure charging_sounds_enabled 0` to disable the system's native charging sounds. This prevents the phone from playing duplicate sounds when connected.
- **Power State Polling:** The daemon runs a lightweight shell loop that polls the status of `/sys/class/power_supply/battery/status` and `/sys/class/power_supply/*/online` once per second. Reading these kernel nodes takes less than 1 microsecond and the CPU completely sleeps between checks, resulting in **0% battery drain**.
- **Headless Audio Playback:** When a plug-in or plug-out event is detected, the daemon launches a headless Java application (`PlayAudio.dex`) via Android's `app_process` command.
- **Android Media Mixer Integration:** The Java helper uses the Android framework's native `android.media.MediaPlayer` API. This ensures the sound plays through the system's official audio mixer (respecting volume levels and audio focus) completely in the background without launching any app UI. Once the 2-3 second sound finishes playing, the Java process terminates immediately and frees up all RAM.

---

## 📦 Magisk Module Directory Structure

```
module-magisk-suara-charging-xiaomi-terhubung-dan-terputus/
├── module.prop         (Module metadata - v1.4.0)
├── service.sh          (Startup background daemon - Unix LF format)
├── PlayAudio.dex       (Headless Android Java compiled helper)
├── charging.ogg        (Official Xiaomi plug-in sound - 82 KB)
├── disconnect.ogg      (Official Xiaomi plug-out sound - 7 KB)
├── changelog.txt       (English changelog)
├── README.md           (English guide - v1.4.0)
├── META-INF/
│   └── com/google/android/
│       ├── update-binary (Magisk installation wrapper script)
│       └── updater-script (Containing "#MAGISK")
├── system/
│   └── media/audio/ui/ (Fallback sound overlays)
└── product/
    └── media/audio/ui/ (Fallback sound overlays)
```

---

## 📲 Installation

1. Download `Xiaomi-Charging-Sound-v1.4.0.zip` or `xiaomi-charging-sound-universal.zip`.
2. Open the **Magisk** application on your device.
3. Go to the **Modules** tab, tap **Install from storage**, and select the ZIP.
4. Reboot your device.

## 🔍 Debugging
If no sound is played, you can view the execution logs by running:
```bash
su
cat /data/adb/modules/xiaomi_charging_sound/log.txt
```
