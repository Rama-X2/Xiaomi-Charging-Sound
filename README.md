# Xiaomi Charging Sound (Universal Magisk Module)

A universal Magisk module that adds the authentic Xiaomi (MIUI/HyperOS) charging connect and disconnect sounds to any Android device running any custom ROM (such as AOSP, LineageOS, SuperiorOS, etc.).

## Features
- **Authentic Sounds:** Connect and disconnect sounds extracted from official Xiaomi system dumps.
- **Universal Compatibility:** Works on all Android versions and custom ROMs.
- **Zero Lag / Low Overhead:** Uses a super-efficient shell polling loop (1-second intervals) that uses 0% CPU in standby.
- **Clean Execution:** Plays sounds headless in the background using `app_process` with a custom Java helper (`PlayAudio.dex`). It does not open any apps or windows.
- **Safe & Independent:** Does not interfere with other audio, charger controllers, or battery protection modules (e.g. Miyabi Charger Protector).

## How it Works
1. Upon boot, `service.sh` waits for system stabilization.
2. It disables the native system charging sound (`charging_sounds_enabled`) to avoid duplicate sound triggers.
3. It monitors the battery status file (`/sys/class/power_supply/battery/status`) in the background.
4. When a plug-in or plug-out event is detected, it runs the headless `PlayAudio.dex` app to play the corresponding `.ogg` sound file, which plays through the Android system mixer and terminates immediately.

## Installation
1. Download `xiaomi-charging-sound-universal.zip`.
2. Open the **Magisk** application on your device.
3. Go to the **Modules** tab, tap **Install from storage**, and select the ZIP.
4. Reboot your device.
