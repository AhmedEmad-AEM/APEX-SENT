# APEX-SENT
# 📡 APEX‑SENT – Wireless Security Audit Framework

**APEX‑SENT** is a professional, menu‑driven wireless security auditing tool built as a Bash script. It simplifies network scanning, handshake capture, and deauthentication attacks – all from a clean, colourful terminal interface.

---

## ✨ Features

- **Interactive menu** – easy network selection and attack execution.
- **Network scanning** – discovers access points with signal strength, channel, band, and encryption.
- **Handshake capture** – captures WPA/WPA2 handshakes with automatic deauthentication.
- **Deauthentication attacks** – supports both 2.4GHz and 5GHz bands (using `aireplay-ng` or `mdk4`).
- **5GHz support** – automatically detects and adapts for 5GHz networks.
- **Smart band detection** – identifies 2.4GHz vs 5GHz bands.
- **Visual signal indicators** – signal strength bars for easy target selection.
- **Session management** – captures are saved to `~/home/owl/<ESSID>/hs-01.cap`.
- **Automatic hash conversion** – converts captured handshakes to Hashcat `.hc22000` format.
- **Dependency checking** – verifies all required tools are installed.
- **Professional banner** – clean and attractive interface.

---

## 📋 Requirements

- **Bash** 4.0 or later.
- **Root privileges** – required for monitor mode and packet injection.
- **Tools:** `aircrack-ng`, `airodump-ng`, `aireplay-ng`, `airmon-ng`, `xterm`, `iw`, `hcxpcapngtool`, `ethtool`.
- **Optional:** `mdk4` for better 5GHz deauthentication.

The installer will check for these tools and warn if any are missing.

---

## 🚀 One‑Line Installation

Copy and paste this command into your terminal:

```bash
git clone https://github.com/AhmedEmad-AEM/APEX-SENT.git && cd APEX-SENT && bash install.sh
