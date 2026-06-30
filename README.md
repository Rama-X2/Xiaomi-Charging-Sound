# Xiaomi Charging Sound (Universal Magisk Module)

A universal Magisk module that adds the authentic Xiaomi (MIUI/HyperOS) charging connection (plug-in) and disconnection (plug-out) sounds to any Android device running any custom ROM (such as AOSP, LineageOS, SuperiorOS, Pixel Experience, etc.).

**Current Version:** v2.0.0

---

## ❓ What is it for?

On AOSP/LineageOS and many custom ROMs (especially MTK-based Redmi 10a running SuperiorOS Android 13), charging sounds are either completely missing, disabled, or limited. Specifically:
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
- **Persistent Java Daemon:** The JVM is launched once at boot to host the monitoring loop. Inside Java, it polls battery/charger driver nodes (`/sys/class/power_supply`) every 250ms. Since it uses `Thread.sleep()`, it consumes **0% CPU in standby**.
- **OOM Protection:** The JVM daemon's OOM score adjustment (`oom_score_adj`) is set to `-1000` (equivalent to system-critical services like Zygote or System Server), ensuring it is never killed by Android's Low Memory Killer even when playing resource-heavy games.
- **Instant Playback (under 10ms):** Because the JVM is already running, there is zero process-spawning delay. Sound playback triggers instantaneously upon plug-in or plug-out.
- **Audio Stream Isolation:** The player uses Android's native `MediaPlayer` API configured with `USAGE_ASSISTANCE_SONIFICATION`. This routes the playback through the system's Notification stream instead of the Music/Media stream, isolating it from your media volume adjustments.
- **Anti-Overlap Cutoff:** If the charger is plugged or unplugged rapidly, any ongoing charging sound is immediately cut off and reset, playing the new sound without overlap or stuttering.
- **MediaDataSource Bypass:** On Android 13+, passing a file path to `MediaPlayer` triggers a Scoped Storage verification (`convertToModernFd`) which crashes on headless JVMs because no Application Context is available. To resolve this, our helper implements a custom `MediaDataSource` callback. The player streams the OGG audio bytes directly from memory, completely bypassing file descriptor conversion checks.
- **Uninstall Cleanup:** The `uninstall.sh` script executes when the module is removed via Magisk to cleanly restore your device's default charging sound setting (`secure charging_sounds_enabled 1`).

---

## 📦 Magisk Module Directory Structure

```
Xiaomi-Charging-Sound-v2.0.0/
├── module.prop         (Module metadata - v2.0.0)
├── service.sh          (Startup background daemon - Unix LF format)
├── PlayAudio.dex       (Persistent Android Java daemon helper with MediaDataSource)
├── charging.ogg        (Official Xiaomi plug-in sound - 82 KB)
├── disconnect.ogg      (Official Xiaomi plug-out sound - 7 KB)
├── changelog.txt       (English changelog - v2.0.0)
├── README.md           (English guide - v2.0.0)
├── uninstall.sh        (Magisk cleanup script to restore default system settings)
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

1. Download `Xiaomi-Charging-Sound-v2.0.0.zip` or `xiaomi-charging-sound-universal.zip`.
2. Open the **Magisk** application on your device.
3. Go to the **Modules** tab, tap **Install from storage**, and select the ZIP.
4. Reboot your device.

## 🔍 Debugging
If no sound is played, you can view the execution logs by running:
```bash
su
cat /data/adb/modules/xiaomi_charging_sound/log.txt
```
