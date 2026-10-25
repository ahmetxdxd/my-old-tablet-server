#!/usr/bin/env python3
"""
My Old Tablet Server - Modern Desktop Web Dashboard & Multi-Device API Server
Lightweight, zero-dependency Python backend serving the web control center.
"""

import os
import sys
import json
import subprocess
import urllib.parse
from http.server import HTTPServer, SimpleHTTPRequestHandler

PORT = 5055
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
UI_DIR = os.path.dirname(__file__)
BIN_DIR = os.path.join(BASE_DIR, "bin")
CONFIG_DIR = os.path.expanduser("~/.config/my-tablet-server")
os.makedirs(CONFIG_DIR, exist_ok=True)

class TabletServerHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=UI_DIR, **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def send_json(self, data, status=200):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode("utf-8"))

    def run_cmd(self, cmd_args):
        try:
            res = subprocess.run(cmd_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=15)
            return res.returncode == 0, res.stdout.strip()
        except subprocess.TimeoutExpired:
            return False, "Command timed out after 15 seconds"
        except Exception as e:
            return False, str(e)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        if path == "/api/devices":
            dev_script = os.path.join(BIN_DIR, "tablet-devices")
            success, out = self.run_cmd([dev_script, "json"])
            try:
                devices = json.loads(out)
            except Exception:
                devices = []
            self.send_json({"devices": devices})
            return

        elif path == "/api/doctor":
            doc_script = os.path.join(BIN_DIR, "tablet-doctor")
            success, out = self.run_cmd([doc_script, "--json"])
            try:
                doc_data = json.loads(out)
            except Exception:
                doc_data = {"total": 0, "passed": 0, "warned": 0, "failed": 0, "checks": []}
            self.send_json(doc_data)
            return

        elif path == "/api/battery_status":
            bg_script = os.path.join(BIN_DIR, "battery-guard")
            success, out = self.run_cmd([bg_script, "status"])
            self.send_json({"status": out})
            return

        elif path == "/api/status":
            target = parsed.query
            cmd = [os.path.join(BIN_DIR, "tablet"), "status"]
            success, out = self.run_cmd(cmd)
            self.send_json({"success": success, "output": out})
            return

        return super().do_GET()

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        content_length = int(self.headers.get("Content-Length", 0))
        post_data = self.rfile.read(content_length).decode("utf-8") if content_length > 0 else "{}"
        try:
            body = json.loads(post_data)
        except Exception:
            body = {}

        if path == "/api/set_active":
            device_id = body.get("device_id", "")
            if device_id:
                dev_script = os.path.join(BIN_DIR, "tablet-devices")
                success, out = self.run_cmd([dev_script, "set-active", device_id])
                self.send_json({"success": success, "message": out})
            else:
                self.send_json({"success": False, "message": "No device_id provided"}, status=400)
            return

        elif path == "/api/connect_wifi":
            ip = body.get("ip", "").strip()
            port = body.get("port", "5555")
            if ip:
                dev_script = os.path.join(BIN_DIR, "tablet-devices")
                success, out = self.run_cmd([dev_script, "connect", ip, str(port)])
                self.send_json({"success": success, "message": out})
            else:
                self.send_json({"success": False, "message": "IP address is required"}, status=400)
            return

        elif path == "/api/scan_network":
            dev_script = os.path.join(BIN_DIR, "tablet-devices")
            success, out = self.run_cmd([dev_script, "scan"])
            self.send_json({"success": success, "message": "Network scan completed"})
            return

        elif path == "/api/action":
            action = body.get("action", "")
            target_device = body.get("device_id", "")
            env_vars = os.environ.copy()
            if target_device:
                env_vars["TABLET_DEVICE"] = target_device

            cmd = []
            if action == "second_screen_usb":
                pos = body.get("position", "right")
                cmd = [os.path.join(BIN_DIR, "second-screen"), "usb", pos]
            elif action == "second_screen_wifi":
                pos = body.get("position", "right")
                cmd = [os.path.join(BIN_DIR, "second-screen"), "wifi", pos]
            elif action == "second_screen_stop":
                cmd = [os.path.join(BIN_DIR, "second-screen"), "stop"]
            elif action == "stereo_start":
                cmd = [os.path.join(BIN_DIR, "stereo-speakers"), "start"]
            elif action == "stereo_cava":
                cmd = [os.path.join(BIN_DIR, "stereo-speakers"), "cava"]
            elif action == "stereo_stop":
                cmd = [os.path.join(BIN_DIR, "stereo-speakers"), "stop"]
            elif action == "screensaver":
                kind = body.get("kind", "art")
                cmd = [os.path.join(BIN_DIR, "tablet"), "screensaver", kind]
            elif action == "screensaver_stop":
                cmd = [os.path.join(BIN_DIR, "tablet"), "screensaver", "stop"]
            elif action == "mode_linux":
                cmd = [os.path.join(BIN_DIR, "tablet"), "server-mode", "linux"]
            elif action == "mode_android":
                cmd = [os.path.join(BIN_DIR, "tablet"), "server-mode", "android"]
            elif action == "mode_hybrid":
                cmd = [os.path.join(BIN_DIR, "tablet"), "server-mode", "hybrid"]
            elif action == "screen_on":
                cmd = [os.path.join(BIN_DIR, "tablet"), "screen", "on"]
            elif action == "screen_off":
                cmd = [os.path.join(BIN_DIR, "tablet"), "screen", "off"]
            elif action == "volume":
                vol = str(body.get("level", 80))
                cmd = [os.path.join(BIN_DIR, "tablet"), "volume", vol]
            elif action == "debloat":
                cmd = [os.path.join(BIN_DIR, "tablet"), "debloat"]
            elif action == "doctor_fix":
                cmd = [os.path.join(BIN_DIR, "tablet-doctor"), "--fix"]
            elif action == "battery_guard_check":
                cmd = [os.path.join(BIN_DIR, "battery-guard"), "check"]
            elif action == "reboot":
                cmd = [os.path.join(BIN_DIR, "tablet"), "run", "reboot"]
            else:
                self.send_json({"success": False, "message": f"Unknown action: {action}"}, status=400)
                return

            try:
                proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, env=env_vars)
                out, _ = proc.communicate(timeout=25)
                self.send_json({"success": proc.returncode == 0, "output": out.strip()})
            except subprocess.TimeoutExpired:
                self.send_json({"success": True, "output": "Command started in background."})
            except Exception as e:
                self.send_json({"success": False, "output": str(e)}, status=500)
            return

        self.send_json({"error": "Not Found"}, status=404)

def run():
    print(f"================================================================")
    print(f"  📱 MY TABLET SERVER - Graphical Dashboard Server")
    print(f"  URL: http://127.0.0.1:{PORT}")
    print(f"================================================================")
    server_address = ("127.0.0.1", PORT)
    httpd = HTTPServer(server_address, TabletServerHandler)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server...")
        httpd.server_close()

if __name__ == "__main__":
    run()
