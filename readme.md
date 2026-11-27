<div align="center">

# 🌐 Fix-ICS (Windows 10 Internet Connection Sharing Reset)

**Automate fixing Windows 10's broken Wi-Fi $\rightarrow$ Ethernet Internet Connection Sharing after a reboot.**

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%2F%2011-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://learn.microsoft.com/en-us/powershell/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](#license)

</div>

---

## 📖 Overview

When configuring a router like a **Nokia Beacon** (or any bridge/AP mode router) to receive internet from a **Windows 10 PC** via **Ethernet**, Windows **Internet Connection Sharing (ICS)** has a notorious bug:

> **The Bug:** You enable *"Allow other network users to connect through this computer's Internet connection"* on your Wi-Fi adapter, and everything works great—**until you reboot**. After restarting, Windows still shows the checkbox as ticked, yet internet traffic refuses to route to the Ethernet port until you manually uncheck it, click OK, and re-check it again.

**`Fix-ICS.ps1`** solves this Windows 10 quirk automatically at startup. While built with a Nokia Beacon setup in mind, it works for **any** Windows 10/11 setup sharing a Wi-Fi connection over Ethernet.

---

## ✨ Features

- 🔄 **Full ICS State Reset:** Programmatically toggles sharing off and back on using the native Windows `HNetCfg.HNetShare` COM interface.
- 🔌 **Adapter Cycling:** Cleanly disables and re-enables the Ethernet adapter to flush stale network states.
- 🛡️ **Fail-Safe Recovery:** Built-in `try/catch` ensures your Ethernet adapter is never accidentally left disabled if an error occurs.
- 📝 **Timestamped Logging:** Logs every run and error to `C:\Scripts\Fix-ICS.log` for easy troubleshooting.
- ⚡ **Zero Third-Party Dependencies:** Uses built-in Windows PowerShell cmdlets and COM objects—no extra installers required.

---

## ⚙️ How It Works

When executed, `Fix-ICS.ps1` performs the following sequence:

```mermaid
graph LR
    A[Start Script] --> B[Disable Ethernet]
    B --> C[Wait 3s & Disable ICS on Wi-Fi]
    C --> D[Enable Ethernet]
    D --> E[Wait 5s & Re-enable ICS<br/>Wi-Fi ➔ Ethernet]
    E --> F[Log Completion]
```

1. **Disables Ethernet:** Runs `Disable-NetAdapter` on the downstream Ethernet adapter and waits `3 seconds`.
2. **Clears Wi-Fi Sharing:** Queries `HNetCfg.HNetShare` and calls `.DisableSharing()` on your Wi-Fi adapter.
3. **Re-enables Ethernet:** Runs `Enable-NetAdapter` and waits `5 seconds` for the link to initialize.
4. **Re-applies ICS:** Assigns Wi-Fi as the **Public/Source** adapter (`EnableSharing(0)`) and Ethernet as the **Private/Target** adapter (`EnableSharing(1)`).

---

## 🚀 Getting Started

### 1. Prerequisites
- **Windows 10** (or Windows 11)
- **Administrator privileges** (required to toggle network adapters and ICS settings)
- Internet Connection Sharing already configured once in your adapter properties (`ncpa.cpl`)

### 2. Installation
1. Create a folder on your `C:` drive named `Scripts` (or clone this repo there):
   ```powershell
   New-Item -ItemType Directory -Force -Path "C:\Scripts"
   ```
2. Place `Fix-ICS.ps1` inside `C:\Scripts\`.

### 3. Configuration
Open `Fix-ICS.ps1` and verify that the adapter names at the top match your system:

```powershell
$WifiName     = "Wi-Fi"      # Adapter receiving internet
$EthernetName = "Ethernet"   # Adapter sharing internet out (e.g., to Nokia Beacon)
$LogFile      = "C:\Scripts\Fix-ICS.log"
```

> [!TIP]
> Not sure what your network adapters are named? Open PowerShell and run:
> ```powershell
> Get-NetAdapter | Select-Object Name, InterfaceDescription, Status
> ```
> Update `$WifiName` and `$EthernetName` to match the exact **Name** column values.

---

## 🕒 Automate at Boot (Task Scheduler)

To run this script automatically every time Windows starts:

1. Press `Win + R`, type `taskschd.msc`, and hit **Enter**.
2. Click **Create Task...** in the right-hand Actions pane.
3. **General Tab:**
   - **Name:** `Fix Internet Connection Sharing`
   - Select **Run whether user is logged on or not**
   - Check **Run with highest privileges** ✅
4. **Triggers Tab:**
   - Click **New...** $\rightarrow$ Begin the task: **At startup** (or **At log on**).
   - *(Optional)* Check **Delay task for:** `15 seconds` to give Wi-Fi time to connect first.
5. **Actions Tab:**
   - Click **New...**
   - **Action:** `Start a program`
   - **Program/script:** `powershell.exe`
   - **Add arguments:**
     ```text
     -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\Fix-ICS.ps1"
     ```
6. Click **OK** and enter your Windows password if prompted.

---

## 📋 Troubleshooting & Logs

Check `C:\Scripts\Fix-ICS.log` to verify the script ran cleanly:

```text
2026-11-26 08:15:10  ---- Starting ICS reset ----
2026-11-26 08:15:10  Ethernet disabled
2026-11-26 08:15:13  Sharing turned off on Wi-Fi
2026-11-26 08:15:14  Ethernet enabled
2026-11-26 08:15:19  Sharing turned back on (Wi-Fi -> Ethernet)
2026-11-26 08:15:19  Done
```

> [!IMPORTANT]
> If you see `ERROR: Adapter '...' not found` in the log, double-check your adapter names in `ncpa.cpl` (for example, `"Ethernet 2"` or `"Wi-Fi 2"`).

---

## 🤝 Contributing

Pull requests and improvements are welcome! If you find a cleaner way to handle delayed Wi-Fi connections at boot or want to add parameter support, feel free to open an issue or PR.

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
