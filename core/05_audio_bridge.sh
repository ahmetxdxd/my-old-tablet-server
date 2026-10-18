#!/system/bin/sh
# ==============================================================================
# My Tablet Server - Android Hardware Audio Bridge Installer
# ==============================================================================
# - Routes Linux audio through Android's native AudioTrack/MediaPlayer layer.
# - 127.0.0.1:4711 -> Raw PCM Stereo Stream (AudioTrack)
# - 127.0.0.1:4712 -> Instant Media File Playback (MediaPlayer)
# - Zero crackling, full Marvell PMIC hardware calibration retained.
# ==============================================================================

TARGET="/data/local/linux"
JAR_SRC="/data/local/tmp/packages/audio_bridge.jar"

echo "[Audio-Bridge] 1/3 - Deploying AudioBridge Dalvik binary..."
cp "$JAR_SRC" "$TARGET/audio_bridge.jar" 2>/dev/null
cp "$JAR_SRC" "/data/local/audio_bridge.jar" 2>/dev/null
chmod 644 "$TARGET/audio_bridge.jar" "/data/local/audio_bridge.jar" 2>/dev/null

echo "[Audio-Bridge] 2/3 - Creating Android Audio Daemon Starter..."
cat > "/data/local/start_audio_bridge.sh" << 'EOF'
#!/system/bin/sh
if pgrep -f "AudioBridgeServer" >/dev/null 2>&1; then
    exit 0
fi

export CLASSPATH=/data/local/audio_bridge.jar
(trap "" 1; /system/bin/app_process / AudioBridgeServer >/dev/null 2>&1 </dev/null &)
EOF
chmod 755 "/data/local/start_audio_bridge.sh"
cp "/data/local/start_audio_bridge.sh" "$TARGET/start_audio_bridge.sh" 2>/dev/null

echo "[Audio-Bridge] 3/3 - Starting Audio Daemon and Setting Media Volume..."
sh /data/local/start_audio_bridge.sh 2>/dev/null || true

# Set media stream volume to 80% (level 12/15)
media volume --stream 3 --set 12 2>/dev/null || true

echo "[Audio-Bridge] Completed. Native hardware audio bridge is running."
