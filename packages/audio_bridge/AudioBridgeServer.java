import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.media.MediaPlayer;
import android.os.Looper;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.File;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;

/**
 * Hermes Tablet Sunucu - Android Native Ses Köprüsü (Dalvik AudioTrack / MediaPlayer)
 * 
 * 127.0.0.1:4711 -> Canlı PCM Ses Akışı (44.1kHz, 16-bit, Stereo) - mpv, radyo, yt-dlp
 * 127.0.0.1:4712 -> Anlık Medya Dosyası Komutları (PLAY /yol/dosya.mp3, STOP, VOL <0-100>)
 */
public class AudioBridgeServer {

    private static final int PCM_PORT = 4711;
    private static final int CMD_PORT = 4712;
    private static final int SAMPLE_RATE = 44100;
    private static MediaPlayer currentPlayer = null;

    public static void main(String[] args) {
        System.out.println("[AudioBridge] Hermes Android Ses Köprüsü Başlatılıyor...");

        // Android Paranoid Network (EACCES fix):
        // su/root ve bağımsız süreçlerde AID_INET (GID 3003) bulunmadığında çekirdek soket açılmasına izin vermez.
        // GID'yi 3003 (AID_INET) yaparak 4711 ve 4712 portlarının sorunsuz açılmasını sağla.
        applyNetworkGroup();

        // Samsung Android 4.4: AudioTrack kurucusu ActivityThread.currentPackageName()
        // sonucunu .equals() ile karşılaştırır; app_process'te bu null olduğundan NPE oluşur.
        initFakeActivityThread();

        // Komut dinleyicisini ayrı bir thread'de başlat
        Thread cmdThread = new Thread(new CommandListener());
        cmdThread.setDaemon(true);
        cmdThread.start();

        // Ana thread'de Canlı PCM akışını dinle
        runPcmServer();
    }

    private static void applyNetworkGroup() {
        try {
            Class<?> libcoreClass = Class.forName("libcore.io.Libcore");
            java.lang.reflect.Field osField = libcoreClass.getField("os");
            Object os = osField.get(null);

            try {
                java.lang.reflect.Method setgidMethod = os.getClass().getMethod("setgid", int.class);
                setgidMethod.invoke(os, 3003); // AID_INET
            } catch (Throwable t) {}

            try {
                java.lang.reflect.Method setegidMethod = os.getClass().getMethod("setegid", int.class);
                setegidMethod.invoke(os, 3003); // AID_INET
            } catch (Throwable t) {}

            System.out.println("[AudioBridge] AID_INET (GID 3003) başarıyla uygulandı.");
        } catch (Throwable t) {
            System.err.println("[AudioBridge] AID_INET (GID 3003) ayarlanamadı: " + t.getMessage());
        }
    }

    private static void initFakeActivityThread() {
        try {
            // ActivityThread kurucusu Handler oluşturur; bu da bir Looper gerektirir
            if (Looper.myLooper() == null) {
                Looper.prepareMainLooper();
            }
            Class<?> atClass = Class.forName("android.app.ActivityThread");
            java.lang.reflect.Constructor<?> atCtor = atClass.getDeclaredConstructor();
            atCtor.setAccessible(true);
            Object thread = atCtor.newInstance();

            java.lang.reflect.Field cur = atClass.getDeclaredField("sCurrentActivityThread");
            cur.setAccessible(true);
            cur.set(null, thread);

            Class<?> bindClass = Class.forName("android.app.ActivityThread$AppBindData");
            java.lang.reflect.Constructor<?> bindCtor = bindClass.getDeclaredConstructor();
            bindCtor.setAccessible(true);
            Object bind = bindCtor.newInstance();

            java.lang.reflect.Field pn = bindClass.getDeclaredField("processName");
            pn.setAccessible(true);
            pn.set(bind, "audiobridge");

            android.content.pm.ApplicationInfo ai = new android.content.pm.ApplicationInfo();
            ai.packageName = "audiobridge";
            java.lang.reflect.Field aif = bindClass.getDeclaredField("appInfo");
            aif.setAccessible(true);
            aif.set(bind, ai);

            java.lang.reflect.Field bound = atClass.getDeclaredField("mBoundApplication");
            bound.setAccessible(true);
            bound.set(thread, bind);
        } catch (Throwable t) {
            System.err.println("[AudioBridge] ActivityThread yaması uygulanamadı: " + t);
            if (t.getCause() != null) t.getCause().printStackTrace();
        }
    }

    private static AudioTrack newTrack(int bufferSize) {
        return new AudioTrack(
            AudioManager.STREAM_MUSIC,
            SAMPLE_RATE,
            AudioFormat.CHANNEL_OUT_STEREO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize,
            AudioTrack.MODE_STREAM
        );
    }

    private static void runPcmServer() {
        try (ServerSocket server = new ServerSocket(PCM_PORT, 5, InetAddress.getByName("127.0.0.1"))) {
            System.out.println("[AudioBridge] PCM Akış Sunucusu Hazır: 127.0.0.1:" + PCM_PORT);

            int minBuf = AudioTrack.getMinBufferSize(
                SAMPLE_RATE,
                AudioFormat.CHANNEL_OUT_STEREO,
                AudioFormat.ENCODING_PCM_16BIT
            );
            int bufferSize = Math.max(minBuf, 16384);

            while (true) {
                try (Socket client = server.accept();
                     InputStream in = client.getInputStream()) {
                    
                    System.out.println("[AudioBridge] Yeni PCM akış bağlantısı kabul edildi.");
                    AudioTrack track = newTrack(bufferSize);
                    track.play();
                    long total = 0, restarts = 0, t0 = System.currentTimeMillis();
                    byte[] buffer = new byte[4096];
                    int read;

                    while ((read = in.read(buffer)) != -1) {
                        int written = 0;
                        long stallStart = 0;
                        while (written < read) {
                            int w = track.write(buffer, written, read - written);
                            if (w < 0) break;
                            if (w == 0) {
                                // Samsung Android 4.4: tampon doluysa write() bloklamaz, 0 döner.
                                // Veriyi atmadan kısa süre bekleyip tekrar dene (akışı hızlandırma).
                                long now = System.currentTimeMillis();
                                if (stallStart == 0) stallStart = now;
                                if (now - stallStart > 2000) {
                                    // Ses çıkışı takıldı (iz AudioFlinger'da pasife düştü): izi yeniden oluştur
                                    track.stop();
                                    track.release();
                                    track = newTrack(bufferSize);
                                    track.play();
                                    restarts++;
                                    stallStart = 0;
                                    continue;
                                }
                                try { Thread.sleep(10); } catch (InterruptedException ie) { break; }
                                continue;
                            }
                            stallStart = 0;
                            written += w; total += w;
                        }
                    }

                    System.out.println("[AudioBridge] bytes=" + total + " restarts=" + restarts + " ms=" + (System.currentTimeMillis() - t0));
                    track.stop();
                    track.release();
                    System.out.println("[AudioBridge] PCM akışı tamamlandı.");
                } catch (Exception e) {
                    System.err.println("[AudioBridge] PCM Akış Hatası: " + e); e.printStackTrace();
                }
            }
        } catch (Exception e) {
            System.err.println("[AudioBridge] PCM Sunucu Açılamadı: " + e.getMessage());
        }
    }

    private static class CommandListener implements Runnable {
        @Override
        public void run() {
            try (ServerSocket cmdServer = new ServerSocket(CMD_PORT, 5, InetAddress.getByName("127.0.0.1"))) {
                System.out.println("[AudioBridge] Komut Sunucusu Hazır: 127.0.0.1:" + CMD_PORT);

                while (true) {
                    try (Socket socket = cmdServer.accept();
                         BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                         OutputStream out = socket.getOutputStream()) {

                        String line = reader.readLine();
                        if (line == null) continue;
                        line = line.trim();

                        if (line.startsWith("PLAY ")) {
                            String filePath = line.substring(5).trim();
                            handlePlayFile(filePath, out);
                        } else if (line.equals("STOP")) {
                            handleStop(out);
                        } else if (line.equals("PING")) {
                            out.write("PONG\n".getBytes());
                            out.flush();
                        } else {
                            out.write("UNKNOWN_COMMAND\n".getBytes());
                            out.flush();
                        }
                    } catch (Exception e) {
                        System.err.println("[AudioBridge] Komut İşleme Hatası: " + e.getMessage());
                    }
                }
            } catch (Exception e) {
                System.err.println("[AudioBridge] Komut Sunucu Açılamadı: " + e.getMessage());
            }
        }

        private void handlePlayFile(String path, OutputStream out) {
            try {
                File file = new File(path);
                if (!file.exists()) {
                    out.write(("ERROR: File not found: " + path + "\n").getBytes());
                    out.flush();
                    return;
                }

                if (currentPlayer != null) {
                    try {
                        currentPlayer.stop();
                        currentPlayer.release();
                    } catch (Exception ignored) {}
                }

                currentPlayer = new MediaPlayer();
                currentPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
                currentPlayer.setDataSource(path);
                currentPlayer.prepare();
                currentPlayer.start();

                out.write("OK\n".getBytes());
                out.flush();
                System.out.println("[AudioBridge] Medya çalınıyor: " + path);
            } catch (Exception e) {
                try {
                    out.write(("ERROR: " + e.getMessage() + "\n").getBytes());
                    out.flush();
                } catch (Exception ignored) {}
            }
        }

        private void handleStop(OutputStream out) {
            try {
                if (currentPlayer != null) {
                    currentPlayer.stop();
                    currentPlayer.release();
                    currentPlayer = null;
                }
                out.write("OK\n".getBytes());
                out.flush();
                System.out.println("[AudioBridge] Medya durduruldu.");
            } catch (Exception e) {
                try {
                    out.write(("ERROR: " + e.getMessage() + "\n").getBytes());
                    out.flush();
                } catch (Exception ignored) {}
            }
        }
    }
}
