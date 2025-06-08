# Zalo for Linux (Unofficial Port) 
**This app was ported directly from ZaloPC for MacOS**

Version: **25.5.3** | Year: **2025** | Base on previous version of **realdtn2** and **huanhoahongso3-collab**

![phone login](https://raw.githubusercontent.com/cobaohieu/zalo-linux-unofficial/refs/heads/main/images/picture3.jpg)
![light theme](https://raw.githubusercontent.com/cobaohieu/zalo-linux-unofficial/refs/heads/main/images/picture2.png)
![dark theme](https://raw.githubusercontent.com/cobaohieu/zalo-linux-unofficial/refs/heads/main/images/picture1.png)

## Features support
- **Theme**
    - Dark
    - Light
- **Languages**
    - Vietnamese
    - English
- **Chat / Text**

## Features unsupport
- Call
- Sync data with mobile

## Information

This project is an unofficial port of the MacOS version of Zalo to Linux. The porting process involved extracting the `.dmg` file from the MacOS version and locating the `app.asar` file in the directory, which is typically found in `/Applications/Zalo.app/Contents/Resources`. 

The following steps were taken:
1. Extracted `app.asar` with the command from macOS:
    ```zsh on macOS
    cd Desktop/
    npm install -g @electron/asar
    
    cd /Applications/Zalo/Contents/Resources
    npx @electron/asar extract app.asar app
    ```
    Save it and reboot
2. Go to the Linux OS as Ubuntu then navigated to the extracted directory and run Zalo using Electron version 22.3.27.

**P.S: Do not use newer versions of Electron, if use the result will errors.**

3. Command to run Zalo is:
    ```bash
    electron .
    ```

Additionally, `install.sh` is used to add a tray icon using Python.


## OS working
- Nobara 39 KDE Plasma
- Ubuntu 22.04
- XFCE4


## Installation

### Requirement software before install ZaloPC

```bash
sudo apt install wget git  unzip python3 python3-pip python3-setuptools python3-dev -y
sudo apt install libjpeg8-dev zlib1g-dev libtiff-dev libfreetype6 libfreetype6-dev libwebp-dev libopenjp2-7-dev libopenjp2-7-dev libgtk-3-0 libnotify4 libjpeg8-dev zlib1g-dev libtiff-dev libfreetype6 libfreetype6-dev libwebp-dev libopenjp2-7-dev -y
sudo apt install python3-pil -y
sudo apt install gir1.2-appindicator3-0.1 -y
```

Python is required to run the tray icon script.

To install Zalo for Linux, you can choose one of these two:

**1. Installation with curl**

```bash
sh -c "$(curl -sSL https://raw.githubusercontent.com/cobaohieu/zalo-linux-unofficial/refs/heads/main/install_curl.sh)"
```

**2. Installation by cloning source**

```bash
git clone https://github.com/cobaohieu/zalo-linux-unofficial
cd zalo-linux-unofficial
chmod +x install.sh
./install.sh
```
Zalo will be installed to ~/.local/share/Zalo


## Fix permission with location and Desktop shortcut

***[855265:0809/185712.193181:FATAL:setuid_sandbox_host.cc(157)] The SUID sandbox helper binary was found, but is not configured correctly. Rather than run without sandboxing I'm aborting now. You need to make sure that /home/ubuntu/.local/share/Zalo/electron-v22.3.27-linux-x64/chrome-sandbox is owned by root and has mode 4755.***
```bash
sudo chown root $HOME/.local/share/Zalo/electron-v22.3.27-linux-x64/chrome-sandbox
sudo chmod 4755 $HOME/.local/share/Zalo/electron-v22.3.27-linux-x64/chrome-sandbox
sudo chown root $HOME/Desktop/Zalo.desktop
sudo chmod 4755 $HOME/Desktop/Zalo.desktop
```

## Errors, Bugs

There will be some bugs, as I don't have an understanding of how electron work, I won't be able to fix any bugs.

## No Security or Hack, Cheat, Virus, Vulnerable, etc.

I'm not sure about this security. This app is just quick support to text and do not have many function as the official app from Zalo VNG. I hope you could understand for this inconvenience.

## License

MIT License was chosen due to license of Electron

## Many thanks to

- realdtn2 https://github.com/realdtn2/zalo-linux-unofficial-2024
- huanhoahongso3-collab https://github.com/huanhoahongso3-collab/zalo-linux-unofficial/tree/main
- https://gist.github.com/muratgozel/fdb854885d6a300004430239dd1f5cfb
- Zalo VNG https://zalo.me/pc
- Stack Overflow https://stackoverflow.com/questions/38523617/how-to-unpack-an-asar-file
