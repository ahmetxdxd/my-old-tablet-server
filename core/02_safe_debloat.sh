#!/system/bin/sh
# ==============================================================================
# My Tablet Server - Watchdog-Safe Debloat Script (Android 4.4.2 KitKat)
# ==============================================================================
# Critical Safety Rule:
# On Samsung KitKat, disabling:
#   - com.android.systemui
#   - com.android.providers.downloads
#   - com.android.providers.media
#   - com.android.settings
# causes system_server's Watchdog thread to trigger a kernel reboot every 60s.
#
# These 4 critical packages + keyboard + launcher are KEPT ACTIVE.
# All other Samsung bloatware, background auto-installers (Samsung Apps),
# weather daemons, and Google services are disabled.
# ==============================================================================

echo "[Safe-Debloat] 1/3 - Configuring Power Locks, Display Settings, and Wi-Fi..."

# Acquire wake lock so the CPU stays awake even when screen is off
echo "tablet_server_lock" > /sys/power/wake_lock 2>/dev/null

# Turn off dynamic auto-brightness polling loop
settings put system screen_brightness_mode 0 2>/dev/null
settings put global stay_on_while_plugged_in 0 2>/dev/null

# Keep Wi-Fi active indefinitely (2 = WIFI_SLEEP_POLICY_NEVER)
settings put global wifi_sleep_policy 2 2>/dev/null
settings put system screen_off_timeout 600000 2>/dev/null
svc power stayon true 2>/dev/null
svc wifi enable 2>/dev/null

echo "[Safe-Debloat] 2/3 - Disabling Bloatware, Rogue Background Updaters & Weather..."

SAFE_DEBLOAT_PACKAGES="
com.google.android.gms
com.google.android.gsf
com.google.android.gsf.login
com.android.vending
com.google.android.apps.maps
com.google.android.apps.plus
com.google.android.apps.magazines
com.google.android.music
com.google.android.gm
com.google.android.play.games
com.google.android.marvin.talkback
com.google.android.setupwizard
com.google.android.backuptransport
com.google.android.onetimeinitializer
com.google.android.configupdater
com.google.android.syncadapters.contacts
com.google.android.partnersetup
com.google.android.feedback
com.google.android.youtube
com.google.android.videos
com.google.android.talk
com.google.android.apps.docs
com.google.android.googlequicksearchbox
com.google.android.keep
com.google.android.calendar
com.google.android.tag
com.tikle.turkcellGollerCepte
com.turkcell.gncplay
tr.com.turkcell.akillidepo
com.ttech.android.onlineislem
com.solidict.tatlidukkanim
com.gazetekeyfi
tr.com.fitwell.app
com.facebook.katana
cn.wps.moffice_eng
com.vestel.smartcenter
com.softwinner.videotest
com.softwinner.dragonfire
com.softwinner.update
com.softwinner.baseservice
com.softwinner.explore
com.towelapps.zigroo
com.jiuzhangtech.sudoku
com.android.noisefield
com.android.magicsmoke
com.android.galaxy4
com.android.phasebeam
com.android.wallpaper.holospiral
com.android.browser.provider
com.android.providers.partnerbookmarks
com.sec.android.app.FlashBarService
com.sec.android.pagebuddynotisvc
com.samsung.android.app.gestureservice
com.sec.android.app.wallpaperchooser
com.android.wallpapercropper
com.android.wallpaper.livepicker
com.android.dreams.basic
com.android.dreams.phototable
com.android.phone
com.sec.phone
com.sec.dsm.phone
com.sec.phone.fake
com.android.calendar
com.android.providers.calendar
com.android.email
com.android.exchange
com.android.browser
com.sec.android.app.sbrowser
com.sec.android.daemonapp.ap.accuweather
com.sec.android.widgetapp.at.hero.accuweather
com.sec.android.widgetapp.at.hero.accuweather.widget
com.sec.android.widgetapp.digitalclock
com.sec.android.widgetapp.SPlannerAppWidget
com.sec.android.daemonapp.ap.yahoonews
com.sec.android.daemonapp.ap.yahoostock.stockclock
com.sec.android.widgetapp.at.yahoostock.stockclock
flipboard.app
com.deezer.android.partner
deezer.android.app
com.samsung.android.scloud.quota
com.samsung.android.scloud.sync
com.samsung.android.scloud.proxy.contacts
com.samsung.android.scloud.backup
com.samsung.android.scloud.proxy.snote
com.samsung.android.scloud.proxy.calendar
com.samsung.android.scloud.auth
com.samsung.android.scloud.proxy.browser
com.sec.android.cloudagent.dropboxoobe
com.sec.spp.push
com.sec.pcw.device
com.samsung.helphub
com.sec.android.Kies
com.wssnps
com.wssyncmldm
com.sec.android.fotaclient
com.LocalFota
com.fmm.dm
com.fmm.ds
com.smlds
com.sec.android.allshare.service.fileshare
com.sec.android.allshare.service.controlshare
com.sec.android.allshare.service.mediashare
com.sec.android.nearby.mediaserver
com.sec.android.app.FileShareClient
com.sec.android.app.FileShareServer
com.sec.android.app.mediasync
com.samsung.shareshot
com.sec.android.gallery3d
com.sec.android.app.videoplayer
com.samsung.everglades.video
com.google.android.apps.books
com.sec.android.app.gamehub
com.sec.android.app.samsungapps.widget
com.infraware.polarisoffice5
com.infraware.polarisoffice5tablet
com.sec.android.app.SamsungContentsAgent
com.sec.pcw
com.sec.android.app.memo
com.sec.android.widgetapp.memo
com.sec.android.widgetapp.programmonitorwidget
com.sec.android.widgetapp.dualclockdigital
android.googleSearch.googleSearchWidget
com.sec.android.widgetapp.webmanual
com.setk.widget
com.sec.android.widgetapp.ap.yahoonews
com.sec.android.app.clockpackage
com.sec.msc.learninghub
com.samsung.SMT
com.samsung.android.app.divx
com.sec.android.SamsungDrmProvider
com.sec.android.drmpopup
com.epson.mobilephone.samsungprintservice
com.siso.app.genericprintservice
com.android.printspooler
com.sec.android.app.mobileprint
com.siso.app.generic
com.android.bluetooth
com.sec.android.app.bluetoothtest
org.simalliance.openmobileapi.service
com.sec.smartcard.manager
com.sec.factory
com.marvell.powergadget
com.marvell.logtools
com.marvell.adt
com.marvell.mrvlaudiotools
com.samsung.clipboardsaveservice
com.sec.android.providers.tasks
com.sec.android.app.controlpanel
com.sec.chaton
com.sec.chaton.provider
com.samsung.android.app.assistantmenu
com.sec.android.app.SecSetupWizard
com.sec.android.app.popupcalculator
com.sec.android.app.dictionary
com.samsung.groupcast
com.sec.android.app.sns3
com.samsung.android.snote
com.sec.android.widgetapp.atag
com.sec.android.app.videomaker
com.sec.android.app.storyalbumwidget
com.samsung.app.playreadyui
com.infraware.polarisviewer5
com.sec.android.app.translator
com.sec.android.app.voicerecorder
com.sec.android.app.samsungapps
com.sec.android.app.billing
com.sec.android.app.worldclock
com.sec.android.app.SamsungContentsAgent
com.sec.pcw
com.infraware.polarisoffice5tablet
com.vlingo.midas
com.samsung.voiceserviceplatform
com.dropbox.android
com.sec.android.cloudagent.dropboxoobe
com.sec.android.app.music
com.sec.android.app.samsungapps.una2
com.google.android.apps.photos
com.google.android.tts
com.osp.app.signin
com.samsung.klmsagent
com.sec.esdk.elm
com.sec.android.service.cm
com.android.chrome
"

COUNT=0
for pkg in $SAFE_DEBLOAT_PACKAGES; do
    am force-stop "$pkg" >/dev/null 2>&1
    pm disable "$pkg" >/dev/null 2>&1
    pm block "$pkg" >/dev/null 2>&1
    COUNT=$((COUNT + 1))
done

echo "[Safe-Debloat] 3/3 - Disabled and blocked $COUNT unused packages and background installers."

# Ensure Samsung Camera & File Manager (MyFiles) are explicitly enabled
echo "[Safe-Debloat] Ensuring Camera and File Manager are active and available..."
pm enable com.sec.android.app.camera 2>/dev/null || true
pm unblock com.sec.android.app.camera 2>/dev/null || true
pm enable com.sec.android.app.myfiles 2>/dev/null || true
pm unblock com.sec.android.app.myfiles 2>/dev/null || true

# Prevent android.process.acore crashes
pm enable com.sec.android.provider.logsprovider 2>/dev/null || true
pm unblock com.sec.android.provider.logsprovider 2>/dev/null || true
pm enable com.android.providers.contacts 2>/dev/null || true
pm unblock com.android.providers.contacts 2>/dev/null || true

# Refresh launcher to clean up empty folders (Samsung Gifts, etc.)
pm clear com.sec.android.app.launcher >/dev/null 2>&1 || true

echo "[Safe-Debloat] Watchdog-critical services preserved: systemui, media, downloads, settings, camera."
sync
echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
echo "[Safe-Debloat] Completed successfully."
