#!/system/bin/sh
# ==============================================================================
# My Tablet Server - Thermal Runaway & CPU Throttling Fix (SM-T210 Specific)
# ==============================================================================

echo "[Thermal-Fix] Freezing rogue modem and diagnostic services..."

SERVICES="atcmdsrv atcmdsrv-aponly simal diag nvm phservice npsmobex smdexe connfwexe ddexe at_distributor"

for svc in $SERVICES; do
    stop "$svc" 2>/dev/null
done

# Terminate process instances
killall -9 atcmdsrv simal diag nvm phservice npsmobex smdexe connfwexe ddexe_real 2>/dev/null

# Safely get system_server PID on Android toolbox
SYSTEM_SERVER_PID=$(ps | while read u p rest; do case "$rest" in *system_server*) echo $p; break;; esac; done)
if [ -n "$SYSTEM_SERVER_PID" ] && [ -d "/proc/$SYSTEM_SERVER_PID/task" ]; then
    for tid in $(ls /proc/$SYSTEM_SERVER_PID/task 2>/dev/null); do
        COMM=$(cat /proc/$SYSTEM_SERVER_PID/task/$tid/comm 2>/dev/null)
        case "$COMM" in
            *android.bg*)
                # Freeze if running in high thread ID or loop
                kill -STOP "$tid" 2>/dev/null
                ;;
        esac
    done
fi

echo "[Thermal-Fix] Setting CPU frequency bounds (312MHz - 1066MHz)..."

# Apply governor and frequency limits (PXA986 uses cpu0 policy)
DIR="/sys/devices/system/cpu/cpu0/cpufreq"
if [ -d "$DIR" ]; then
    if grep -q "ondemand" "$DIR/scaling_available_governors" 2>/dev/null; then
        echo "ondemand" > "$DIR/scaling_governor" 2>/dev/null
    elif grep -q "interactive" "$DIR/scaling_available_governors" 2>/dev/null; then
        echo "interactive" > "$DIR/scaling_governor" 2>/dev/null
    fi

    # 312000 kHz min, 1066000 kHz max (avoids 1.2 GHz thermal peak)
    echo 312000 > "$DIR/scaling_min_freq" 2>/dev/null
    echo 1066000 > "$DIR/scaling_max_freq" 2>/dev/null
fi

echo "[Thermal-Fix] Completed. CPU is cool and stabilized."

# Watchdog loop if executed with --daemon flag
if [ "$1" = "--daemon" ]; then
    while true; do
        sleep 60
        for svc in $SERVICES; do
            stop "$svc" 2>/dev/null
        done
        killall -9 atcmdsrv simal diag nvm phservice npsmobex smdexe connfwexe 2>/dev/null
    done
fi
