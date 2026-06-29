#!/system/bin/sh

# Wait for boot completion
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

# Sleep an extra 5 seconds to ensure system services are stabilized
sleep 5

# Disable system-native charging sound to prevent double playback
settings put secure charging_sounds_enabled 0

# Paths
MODDIR="/data/adb/modules/xiaomi_charging_sound"
PLAY_DEX="$MODDIR/PlayAudio.dex"
CONNECT_SOUND="$MODDIR/charging.ogg"
DISCONNECT_SOUND="$MODDIR/disconnect.ogg"
STATUS_FILE="/sys/class/power_supply/battery/status"

# Function to play sound
play_sound() {
    local file="$1"
    if [ -f "$file" ]; then
        export CLASSPATH="$PLAY_DEX"
        # Run in background to prevent blocking the monitoring loop
        app_process /system/bin PlayAudio "$file" >/dev/null 2>&1 &
    fi
}

# Helper to check if status means plugged in
is_plugged() {
    local status="$1"
    if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
        return 0 # True
    else
        return 1 # False
    fi
}

# Get initial state
if [ -f "$STATUS_FILE" ]; then
    initial_status=$(cat "$STATUS_FILE")
else
    initial_status="Discharging"
fi

if is_plugged "$initial_status"; then
    last_plugged=1
else
    last_plugged=0
fi

# Monitoring loop
while true; do
    if [ -f "$STATUS_FILE" ]; then
        current_status=$(cat "$STATUS_FILE")
    else
        current_status="Discharging"
    fi

    if is_plugged "$current_status"; then
        current_plugged=1
    else
        current_plugged=0
    fi

    if [ "$current_plugged" -ne "$last_plugged" ]; then
        if [ "$current_plugged" -eq 1 ]; then
            play_sound "$CONNECT_SOUND"
        else
            play_sound "$DISCONNECT_SOUND"
        fi
        last_plugged="$current_plugged"
    fi
    
    sleep 1
done
