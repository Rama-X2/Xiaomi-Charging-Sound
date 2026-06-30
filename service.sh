#!/system/bin/sh

# Wait for boot completion
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

# Sleep an extra 5 seconds to ensure system services are stabilized
sleep 5

MODDIR="/data/adb/modules/xiaomi_charging_sound"
PLAY_DEX="$MODDIR/PlayAudio.dex"
CONNECT_SOUND="$MODDIR/charging.ogg"
DISCONNECT_SOUND="$MODDIR/disconnect.ogg"

# Initialize log file
echo "$(date '+%Y-%m-%d %H:%M:%S') - Service starting..." > "$MODDIR/log.txt"

# Disable system-native charging sound to prevent double playback
settings put secure charging_sounds_enabled 0 >> "$MODDIR/log.txt" 2>&1

log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$MODDIR/log.txt"
}

export CLASSPATH="$PLAY_DEX"
# Start the persistent Java daemon process in the background and redirect output to log.txt
app_process /system/bin PlayAudio "$CONNECT_SOUND" "$DISCONNECT_SOUND" >> "$MODDIR/log.txt" 2>&1 &

# Prevent the daemon from being terminated by Android's Low Memory Killer (LMK)
PID=$!
if [ ! -z "$PID" ]; then
    echo -1000 > "/proc/$PID/oom_score_adj" 2>/dev/null
    log_msg "Started Java daemon with PID $PID and set oom_score_adj to -1000"
else
    log_msg "Warning: Failed to retrieve PID of Java daemon"
fi
