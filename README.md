# 🛡️ APEX-SENT – Wireless Security Audit Framework

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash 4.0+](https://img.shields.io/badge/Bash-4.0%2B-brightgreen.svg)](https://www.gnu.org/software/bash/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-blue.svg)](https://github.com/AhmedEmad-AEM/APEX-SENT)
[![Stars](https://img.shields.io/github/stars/AhmedEmad-AEM/APEX-SENT?style=social)](https://github.com/AhmedEmad-AEM/APEX-SENT)

A powerful, intuitive, and professional Bash-based wireless security auditing toolkit designed for penetration testers and security professionals.

[Quick Start](#-quick-start) • [Features](#-features) • [Requirements](#-requirements) • [Usage](#-usage) • [Documentation](#-documentation)

</div>

---

## 📖 Overview

**APEX-SENT** is an advanced wireless security auditing framework that streamlines network reconnaissance, WPA/WPA2 handshake capture, and penetration testing operations. Built entirely in Bash with a user-friendly interactive menu system, it combines powerful aircrack-ng suite utilities with intelligent automation to deliver professional-grade security assessments.

Whether you're conducting authorized penetration tests or learning wireless security concepts, APEX-SENT provides the tools and simplicity you need.

---

## ✨ Key Features

### 🔍 Network Intelligence
- **Smart Network Discovery** – Automated scanning with real-time signal visualization
- **Signal Strength Indicators** – Visual bars displaying RSSI for easy target identification
- **Band Detection** – Automatic identification of 2.4GHz and 5GHz networks
- **Encryption Recognition** – Displays WPA/WPA2/WEP security protocols
- **Channel & Frequency Mapping** – Complete frequency spectrum analysis

### 🎯 Attack Capabilities
- **Handshake Capture** – Professional WPA/WPA2 handshake acquisition with automatic deauth
- **Dual-Band Deauthentication** – Supports 2.4GHz (aireplay-ng) and 5GHz (mdk4) attacks
- **Automatic Hash Conversion** – Seamless Hashcat `.hc22000` format conversion
- **Session Management** – Organized capture storage in `~/home/owl/<ESSID>/hs-01.cap`

### 🎨 User Experience
- **Interactive Menu System** – Intuitive navigation for all operations
- **Dependency Verification** – Automatic tool availability checking at startup
- **Professional UI** – Clean, attractive ASCII banners and formatted output
- **Error Handling** – Graceful error messages and recovery options

### 🔧 Technical Excellence
- **Bash 4.0+ Compatible** – Modern Bash features for reliability
- **Modular Architecture** – Clean code structure for maintenance
- **Root Privilege Management** – Secure privilege escalation handling
- **Cross-Platform Support** – Tested on Kali Linux, Ubuntu, Debian, and derivatives

---

## 📋 Requirements

### Mandatory
| Requirement | Purpose |
|---|---|
| **Bash 4.0+** | Script execution engine |
| **Root/Sudo** | Monitor mode & packet injection |
| **aircrack-ng suite** | Core wireless utilities |
| **airodump-ng** | Network scanning & monitoring |
| **aireplay-ng** | Packet injection & deauth (2.4GHz) |
| **airmon-ng** | Wireless adapter management |
| **xterm** | Terminal multiplexing |
| **iw** | Wireless configuration |
| **hcxpcapngtool** | Handshake conversion |
| **ethtool** | Adapter information |

### Optional
| Tool | Purpose | Benefit |
|---|---|---|
| **mdk4** | 5GHz deauthentication | Improved 5GHz attack success |

### System Prerequisites
- Linux-based OS (Kali, Ubuntu, Debian recommended)
- Compatible wireless adapter with monitor mode support
- Internet connection for installation

The installer performs automatic dependency checks and provides installation guidance.

---

## 🚀 Quick Start

### One-Line Installation

```bash
git clone https://github.com/AhmedEmad-AEM/APEX-SENT.git && cd APEX-SENT && bash install.sh
```

### Basic Usage

```bash
# Run the application
sudo apex-sent

# Or directly:
sudo bash apex-sent.sh
```

### First Steps
1. Launch the interactive menu
2. Select your wireless adapter
3. Choose between **Scan**, **Capture**, or **Attack** operations
4. Follow the guided prompts for each operation
5. Retrieved data is automatically saved and organized

---

## 📚 Usage Guide

### Main Menu Operations

#### 🔍 Network Scanning
- **What it does:** Discovers all nearby wireless networks with detailed metrics
- **Information gathered:** ESSID, BSSID, Signal Strength, Channel, Frequency, Security Type
- **Output format:** Clean, sortable table with visual indicators
- **Use case:** Initial reconnaissance and target identification

#### 📡 Handshake Capture
- **What it does:** Captures WPA/WPA2 four-way handshakes for offline analysis
- **Automation:** Automatic deauthentication of connected clients
- **Conversion:** Automatic `.hc22000` format generation for Hashcat
- **Storage:** `~/home/owl/<ESSID>/hs-01.cap`
- **Use case:** Preparation for dictionary/brute-force attacks

#### ⚔️ Deauthentication Attacks
- **2.4GHz Mode:** Uses aireplay-ng for maximum compatibility
- **5GHz Mode:** Uses mdk4 for modern networks
- **Smart Detection:** Automatically selects appropriate tool
- **Client Targeting:** Optional single-client deauth capability
- **Use case:** Force clients to reconnect, triggering handshake capture

---

## 🛠️ Installation Details

### Automated Installation
```bash
bash install.sh
```
The installer will:
- ✅ Check system dependencies
- ✅ Verify Bash version
- ✅ Install required packages (with sudo prompt)
- ✅ Create symbolic links for easy access
- ✅ Set proper permissions
- ✅ Display setup confirmation

### Manual Installation
```bash
# Clone repository
git clone https://github.com/AhmedEmad-AEM/APEX-SENT.git
cd APEX-SENT

# Make executable
chmod +x apex-sent.sh

# Create symlink (optional)
sudo ln -s $(pwd)/apex-sent.sh /usr/local/bin/apex-sent

# Run with sudo
sudo ./apex-sent.sh
```

---

## 📁 Project Structure

```
APEX-SENT/
├── apex-sent.sh           # Main application script
├── install.sh             # Installation script
├── README.md              # This file
├── LICENSE                # MIT License
├── docs/                  # Additional documentation
│   ├── USAGE.md          # Detailed usage guide
│   ├── TROUBLESHOOTING.md # Common issues & fixes
│   └── EXAMPLES.md       # Real-world usage examples
└── captures/             # Default capture output directory
```

---

## ⚠️ Important Notes

### Legal & Ethical
- **Authorization Required** – Only audit networks you own or have explicit permission to test
- **Compliance** – Ensure compliance with local laws and regulations
- **Educational Purpose** – Use for learning and authorized testing only
- **Responsibility** – Users are responsible for their actions

### Security Best Practices
- Always run with appropriate privileges
- Use in isolated/controlled environments when possible
- Keep dependencies updated regularly
- Review captured data carefully

---

## 🔧 Troubleshooting

### Common Issues

**Issue:** "Permission denied" error
```bash
Solution: Run with sudo
sudo apex-sent
```

**Issue:** "Tool not found" errors
```bash
Solution: Run installer to install missing dependencies
sudo bash install.sh
```

**Issue:** Wireless adapter not detected
```bash
Solution: Check adapter status and monitor mode support
iwconfig
airmon-ng check
```

**Issue:** Handshake capture fails
```bash
Solution: 
1. Ensure clients are connected to target network
2. Increase deauth duration
3. Try manually triggering deauth
4. Check channel compatibility
```

### Getting Help
- Check [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- Review [Usage Examples](docs/EXAMPLES.md)
- Open an [Issue](https://github.com/AhmedEmad-AEM/APEX-SENT/issues)
- Consult aircrack-ng documentation

---

## 📊 Performance Tips

### For Better Results
- Position wireless adapter closer to target
- Use high-gain antenna if available
- Operate in less congested channels
- Test with multiple target networks
- Keep monitor mode session active during operations

### Optimization
- Close unnecessary applications
- Use 5GHz networks for faster speeds
- Enable mdk4 for 5GHz deauth efficiency
- Monitor system resources during long captures

---

## 🔄 Workflow Examples

### Scenario 1: Complete Security Assessment
```
1. Launch APEX-SENT with sudo
2. Scan network (60-90 seconds)
3. Identify target SSID & BSSID
4. Select for handshake capture
5. Wait for handshake completion (~2-5 minutes)
6. Export to Hashcat format
7. Conduct offline password analysis
```

### Scenario 2: Quick Network Reconnaissance
```
1. Run network scan
2. Export results to CSV
3. Analyze encryption & client activity
4. Generate security report
```

---

## 📝 License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

You are free to:
- ✅ Use commercially and privately
- ✅ Modify and distribute
- ✅ Use for commercial purposes

With the condition:
- ⚖️ Include license and copyright notice

---

## 🤝 Contributing

We welcome contributions from the community!

### How to Contribute
1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Areas for Contribution
- 🐛 Bug fixes and improvements
- 📚 Documentation enhancements
- 🎨 UI/UX improvements
- 🌍 Localization support
- ✨ New features and utilities

---

## 🙏 Acknowledgments

- **aircrack-ng team** – For the powerful wireless toolkit
- **Kali Linux community** – For the penetration testing environment
- **Security researchers** – For ethical hacking insights
- **Contributors** – For code improvements and feedback

---

## 📞 Support & Contact

- **Issues & Bug Reports:** [GitHub Issues](https://github.com/AhmedEmad-AEM/APEX-SENT/issues)
- **Discussions:** [GitHub Discussions](https://github.com/AhmedEmad-AEM/APEX-SENT/discussions)
- **Email:** ahmed@example.com
- **Documentation:** [Full Docs](docs/)

---

## 📈 Roadmap

### Planned Features
- [ ] GUI interface using zenity/kdialog
- [ ] Cloud capture storage integration
- [ ] Advanced filtering and analysis tools
- [ ] Real-time threat detection
- [ ] Multi-language support
- [ ] Docker containerization
- [ ] JSON export for reports
- [ ] Wireless spectrum analysis

---

## 🎯 Version History

### v2.0.0 (Current)
- ✨ Enhanced UI with professional formatting
- 🔧 Improved 5GHz support
- 📊 Better error handling
- 📚 Comprehensive documentation

### v1.0.0
- 🚀 Initial release
- 🔍 Core scanning & capture features
- ⚔️ Deauthentication attacks

---

## ⭐ Show Your Support

If APEX-SENT helped you, please consider:
- 🌟 Starring the repository
- 🔖 Sharing with the community
- 💬 Providing feedback
- 🐛 Reporting issues
- 📝 Contributing improvements

---

<div align="center">

**Made with ❤️ by [Ahmed Emad](https://github.com/AhmedEmad-AEM)**

[⬆ Back to top](#-apex-sent--wireless-security-audit-framework)

</div>
