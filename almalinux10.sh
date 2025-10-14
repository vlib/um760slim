#!/bin/bash
# ============================================================
# AlmaLinux 9/10 - KDE Plasma 6 Wayland Minimal Install
# Matteo Edition 🇮🇹 - AMD + Realtek RTL8125 + applicazioni
# ============================================================

echo ">>> Aggiornamento sistema..."
dnf update -y

# ------------------------------------------------------------
# EPEL
# ------------------------------------------------------------
echo ">>> Installazione EPEL..."
dnf install -y epel-release
dnf update -y

# ------------------------------------------------------------
# RPM Fusion per FFmpeg completo
# ------------------------------------------------------------
echo ">>> Abilitazione RPM Fusion Free e NonFree..."
dnf install -y https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm \
               https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-9.noarch.rpm
dnf update -y

# ------------------------------------------------------------
# KDE Plasma + Wayland
# ------------------------------------------------------------
echo ">>> Installazione KDE Plasma 6 Wayland..."
dnf groupinstall -y "KDE Plasma Workspaces"
dnf install -y plasma-workspace-wayland kwin-wayland

# ------------------------------------------------------------
# Servizi essenziali
# ------------------------------------------------------------
echo ">>> Installazione servizi essenziali..."
dnf install -y sddm NetworkManager \
pipewire pipewire-alsa wireplumber \
bluedevil konsole xdg-desktop-portal xdg-desktop-portal-kde \
pavucontrol alsa-utils

systemctl enable sddm
systemctl set-default graphical.target

# ------------------------------------------------------------
# Applicazioni KDE / utilità
# ------------------------------------------------------------
dnf install -y dolphin discover cups system-config-printer \
kdeconnect firefox libreoffice okular kwrite ark \
ffmpeg ffmpeg-devel  # FFmpeg completo da RPM Fusion

# ------------------------------------------------------------
# Applicazioni extra
# ------------------------------------------------------------
dnf install -y thunderbird thunderbird-locale-it \
filezilla putty keepassxc ktorrent

# ------------------------------------------------------------
# Calibre installazione ufficiale
# ------------------------------------------------------------
echo ">>> Installazione Calibre tramite script ufficiale..."
wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

# ------------------------------------------------------------
# Kiwix via flatpak se non disponibile nei repo
# ------------------------------------------------------------
dnf install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.kiwix.kiwix-desktop

# ------------------------------------------------------------
# Master PDF Editor 5
# ------------------------------------------------------------
rpm --import http://repo.code-industry.net/rpm/pubmpekey.asc
echo -e "[master-pdf-editor]\nname=Master PDF Editor\nbaseurl=http://repo.code-industry.net/rpm/\$basearch\nenabled=1\ngpgcheck=1\ngpgkey=http://repo.code-industry.net/rpm/pubmpekey.asc" | tee /etc/yum.repos.d/master-pdf-editor.repo
dnf install -y master-pdf-editor-5

# ------------------------------------------------------------
# Localizzazione italiana
# ------------------------------------------------------------
dnf install -y langpacks-it libreoffice-langpack-it hunspell-it

# ------------------------------------------------------------
# Driver AMD / Mesa / Vulkan
# ------------------------------------------------------------
dnf install -y mesa-dri-drivers mesa-vulkan-drivers mesa-vulkan-filesystem

# ------------------------------------------------------------
# Realtek RTL8125 2.5GbE
# ------------------------------------------------------------
# Driver r8169 incluso, opzionale r8168 via ELRepo se necessario
# dnf install -y kmod-r8168

# ------------------------------------------------------------
# Directory utente standard
# ------------------------------------------------------------
dnf install -y xdg-user-dirs
xdg-user-dirs-update

# ------------------------------------------------------------
# Abilita avvio grafico
# ------------------------------------------------------------
systemctl enable sddm
systemctl set-default graphical.target

echo "============================================================"
echo " AlmaLinux KDE Plasma 6 Wayland - Matteo Edition 🇮🇹"
echo " Tutte le applicazioni installate (KTorrent, Master PDF Editor, Kiwix, FFmpeg completo da RPM Fusion, Calibre aggiornato)."
echo " GPU AMD e Realtek RTL8125 già supportate."
echo " Plasma Wayland pronto all’uso."
echo " Riavvia per entrare in Plasma Wayland."
echo "============================================================"
