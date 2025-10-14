#!/bin/bash
# ============================================================
# Debian 13 (Trixie) - KDE Plasma 6 Wayland Minimal Install
# Matteo Edition 🇮🇹
# Variante con scelta opzionale Google Drive
# ============================================================

echo ">>> Aggiornamento sistema..."
apt update && apt full-upgrade -y

# ------------------------------------------------------------
# Sources.list ufficiale Debian 13 Trixie con contrib, non-free e non-free-firmware
# ------------------------------------------------------------
echo ">>> Configurazione sources.list ufficiale..."
cat <<EOF > /etc/apt/sources.list
#deb cdrom:[Debian GNU/Linux 13.1.0 _Trixie_ - Official amd64 NETINST with firmware 20250906-10:22]/ trixie contrib main non-free-firmware

deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
EOF

apt update

# ------------------------------------------------------------
# KDE Plasma (Wayland) Core
# ------------------------------------------------------------
apt install --no-install-recommends -y \
plasma-desktop \
plasma-workspace \
plasma-workspace-wayland \
plasma-framework \
kwin-wayland \
khotkeys \
systemsettings \
kde-cli-tools \
kmenuedit \
kglobalaccel \
kio \
kinit \
kscreen \
xwayland

# ------------------------------------------------------------
# Servizi di sistema essenziali
# ------------------------------------------------------------
apt install --no-install-recommends -y \
sddm \
network-manager \
plasma-nm \
pipewire \
wireplumber \
xdg-desktop-portal \
xdg-desktop-portal-kde \
pavucontrol \
alsa-utils \
bluedevil \
konsole \
kde-config-gtk-style \
kde-config-systemd

# ------------------------------------------------------------
# Applicazioni KDE / utilità
# ------------------------------------------------------------
apt install --no-install-recommends -y \
firefox-esr \
libreoffice \
okular \
kwrite \
ark \
dolphin \
discover \
cups \
system-config-printer \
kdeconnect

# ------------------------------------------------------------
# FFmpeg completo non-free
# ------------------------------------------------------------
apt install -y ffmpeg libavcodec-extra ffmpegthumbs

# ------------------------------------------------------------
# Applicazioni extra
# ------------------------------------------------------------
apt install --no-install-recommends -y \
thunderbird \
thunderbird-l10n-it \
filezilla \
putty \
keepassxc \
ktorrent

# ------------------------------------------------------------
# Calibre installazione ufficiale
# ------------------------------------------------------------
wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

# ------------------------------------------------------------
# Kiwix via flatpak
# ------------------------------------------------------------
apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.kiwix.kiwix-desktop

# ------------------------------------------------------------
# Master PDF Editor 5 - repository ufficiale
# ------------------------------------------------------------
wget --quiet -O - http://repo.code-industry.net/deb/pubmpekey.asc | tee /etc/apt/keyrings/pubmpekey.asc
echo "deb [signed-by=/etc/apt/keyrings/pubmpekey.asc arch=$(dpkg --print-architecture)] http://repo.code-industry.net/deb stable main" | tee /etc/apt/sources.list.d/master-pdf-editor.list
apt update
apt install -y master-pdf-editor-5

# ------------------------------------------------------------
# Localizzazione italiana
# ------------------------------------------------------------
apt install --no-install-recommends -y \
locales \
task-italian \
language-pack-kde-it \
language-pack-it \
hunspell-it \
mythes-it \
libreoffice-l10n-it \
firefox-esr-l10n-it

sed -i 's/^# *it_IT.UTF-8 UTF-8/it_IT.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
update-locale LANG=it_IT.UTF-8

# ------------------------------------------------------------
# Directory utente standard
# ------------------------------------------------------------
apt install -y xdg-user-dirs
if [ -n "$SUDO_USER" ]; then
    runuser -l "$SUDO_USER" -c 'xdg-user-dirs-update'
else
    xdg-user-dirs-update
fi

# ------------------------------------------------------------
# Ottimizzazioni estetiche
# ------------------------------------------------------------
apt install --no-install-recommends -y breeze-cursor-theme breeze-gtk-theme fonts-noto

# Disattiva indicizzazione Baloo
mkdir -p /etc/xdg/kdeglobals.d
cat <<EOF > /etc/xdg/kdeglobals.d/disable_baloo.conf
[Basic Settings]
Indexing-Enabled=false
EOF

# Tema e font di default
mkdir -p /etc/skel/.config
cat <<EOF > /etc/skel/.config/kdeglobals
[General]
ColorScheme=BreezeLight
Font=Noto Sans,10,-1,5,50,0,0,0,0,0
Fixed=Noto Sans Mono,10,-1,5,50,0,0,0,0,0
MenuFont=Noto Sans,10,-1,5,50,0,0,0,0,0
SmallestReadableFont=Noto Sans,8,-1,5,50,0,0,0,0,0
ToolBarFont=Noto Sans,9,-1,5,50,0,0,0,0,0

[Icons]
Theme=breeze

[KScreen]
ScaleFactor=1.25
EOF

# ------------------------------------------------------------
# ZRAM ottimizzata
# ------------------------------------------------------------
apt install -y systemd-zram-generator
cat <<EOF > /etc/systemd/zram-generator.conf
[zram0]
zram-size = 4096
compression-algorithm = zstd
swap-priority = 100
EOF
systemctl daemon-reexec
systemctl daemon-reload

# ------------------------------------------------------------
# AMD GPU / Mesa / Vulkan
# ------------------------------------------------------------
apt install -y mesa-vulkan-drivers firmware-amd-graphics mesa-utils

# ------------------------------------------------------------
# Imposta Plasma (Wayland) come sessione predefinita in SDDM
# ------------------------------------------------------------
SDDM_CONF="/etc/sddm.conf.d/wayland.conf"
mkdir -p "$(dirname "$SDDM_CONF")"
cat <<EOF > "$SDDM_CONF"
[Autologin]
#User=$SUDO_USER
#Session=plasmawayland.desktop

[General]
Session=plasmawayland.desktop
EOF

# ------------------------------------------------------------
# Scelta opzionale: Google Drive in KDE/Dolphin
# ------------------------------------------------------------
read -p "Vuoi installare le librerie opzionali per Google Drive in KDE? [s/N] " INSTALL_GDRIVE
INSTALL_GDRIVE=${INSTALL_GDRIVE,,}  # converti in minuscolo
if [[ "$INSTALL_GDRIVE" == "s" || "$INSTALL_GDRIVE" == "si" ]]; then
    echo ">>> Installazione librerie Google Drive..."
    apt install -y kaccounts-providers kio-gdrive kaccounts-integration
    echo ">>> Dopo l'installazione, aggiungi il tuo account Google tramite:"
    echo ">>> Impostazioni di Sistema → Account Online → Google"
else
    echo ">>> Saltata installazione Google Drive."
fi

# ------------------------------------------------------------
# Abilita avvio grafico e pulizia
# ------------------------------------------------------------
systemctl enable sddm
systemctl set-default graphical.target

apt autoremove --purge -y
apt clean

echo "============================================================"
echo " Debian 13 KDE Plasma 6 Wayland - Matteo Edition 🇮🇹"
echo " Tutte le applicazioni principali installate (KTorrent, Master PDF Editor, Kiwix, Calibre aggiornato, FFmpeg completo non-free)."
echo " GPU AMD e Realtek RTL8125 già supportate."
echo " Plasma Wayland pronto all’uso."
echo " Riavvia per entrare in Plasma Wayland."
echo "============================================================"
