#!/bin/bash

# Script de AUDITORIA de Áudio e Bluetooth
# Coleta informações sobre drivers, daemons e hardware
# SEGURO: Apenas leitura, sem modificações no sistema

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        AUDITORIA: ÁUDIO E BLUETOOTH                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}\n"

# ============================================
# 1. PACOTES INSTALADOS
# ============================================
echo -e "${YELLOW}=== 📦 PACOTES INSTALADOS ===${NC}\n"

echo -e "${YELLOW}📻 ÁUDIO (PipeWire, PulseAudio, ALSA, Jack):${NC}"
pacman -Q 2>/dev/null | grep -E "^(pipewire|pulseaudio|alsa|jack|sndio)" | sort || echo "Nenhum encontrado"

echo -e "\n${YELLOW}🔵 BLUETOOTH (BlueZ, utils):${NC}"
pacman -Q 2>/dev/null | grep -E "^(bluez|pulseaudio-bluetooth)" | sort || echo "Nenhum encontrado"

echo -e "\n${YELLOW}🌐 NETWORK (NetworkManager, iwd, wpa_supplicant):${NC}"
pacman -Q 2>/dev/null | grep -E "^(networkmanager|iwd|wpa_supplicant)" | sort || echo "Nenhum encontrado"

# ============================================
# 2. KERNEL MODULES
# ============================================
echo -e "\n${YELLOW}=== 🔧 KERNEL MODULES ===${NC}\n"

echo -e "${YELLOW}🔊 ÁUDIO (snd, sof, hda):${NC}"
lsmod | grep -E "^(snd|sof|hda)" | head -30 || echo "Nenhum carregado"

echo -e "\n${YELLOW}🔵 BLUETOOTH (bluetooth, btusb, btrtl, btintel):${NC}"
lsmod | grep -E "^(bluetooth|btusb|btrtl|btintel|rfcomm)" | head -15 || echo "Nenhum carregado"

echo -e "\n${YELLOW}🌐 NETWORK (iwlwifi, cfg80211, mac80211):${NC}"
lsmod | grep -E "^(iwl|cfg80211|mac80211|ath|b43)" | head -15 || echo "Nenhum carregado"

# ============================================
# 3. HARDWARE DETECTADO
# ============================================
echo -e "\n${YELLOW}=== 🖥️ HARDWARE DETECTADO ===${NC}\n"

echo -e "${YELLOW}📡 WiFi/Wireless:${NC}"
lspci | grep -i "network controller" || echo "Não encontrado"

echo -e "\n${YELLOW}🔵 Bluetooth (PCI):${NC}"
lspci | grep -i "bluetooth" || echo "Não encontrado via PCI"

echo -e "\n${YELLOW}🔵 Bluetooth (USB):${NC}"
lsusb | grep -iE "(bluetooth|intel.*jfp|realtek.*8761|broadcom)" || echo "Não encontrado via USB"

# ============================================
# 4. DAEMONS RODANDO
# ============================================
echo -e "\n${YELLOW}=== ⚙️ DAEMONS RODANDO ===${NC}\n"

echo -e "${YELLOW}🔊 ÁUDIO:${NC}"
ps aux | grep -E "pipewire|pulseaudio|jackd" | grep -v grep || echo "Nenhum rodando"

echo -e "\n${YELLOW}🔵 BLUETOOTH:${NC}"
ps aux | grep -E "bluetoothd|dbus" | grep -v grep | head -5 || echo "Nenhum rodando"

echo -e "\n${YELLOW}🌐 NETWORK:${NC}"
ps aux | grep -E "NetworkManager|iwd|dhclient" | grep -v grep | head -5 || echo "Nenhum rodando"

# ============================================
# 5. SYSTEMD SERVICES
# ============================================
echo -e "\n${YELLOW}=== 🔄 SYSTEMD SERVICES ===${NC}\n"

echo -e "${YELLOW}Status dos Services:${NC}"
for service in bluetooth.service pulseaudio.service pipewire.service pipewire-pulse.service NetworkManager.service; do
    if systemctl is-enabled "$service" &>/dev/null 2>&1; then
        status=$(systemctl is-active "$service" 2>/dev/null || echo "error")
        if [ "$status" = "active" ]; then
            echo -e "  ${GREEN}✓${NC} $service (${GREEN}enabled + active${NC})"
        else
            echo -e "  ${YELLOW}⚠${NC} $service (${YELLOW}enabled but $status${NC})"
        fi
    else
        status=$(systemctl is-active "$service" 2>/dev/null || echo "inactive")
        echo -e "  ✗ $service (disabled, $status)"
    fi
done

# ============================================
# 6. CONECTIVIDADE
# ============================================
echo -e "\n${YELLOW}=== 🔗 CONECTIVIDADE ===${NC}\n"

echo -e "${YELLOW}📡 WiFi Status:${NC}"
nmcli radio wifi 2>/dev/null || echo "N/A"

echo -e "\n${YELLOW}🌐 Conexões WiFi Ativas:${NC}"
nmcli con show --active 2>/dev/null | grep -E "^NAME|^DEVICE" || echo "Nenhuma"

echo -e "\n${YELLOW}🔵 Bluetooth Adapter:${NC}"
bluetoothctl show 2>/dev/null | head -10 || echo "Não disponível"

echo -e "\n${YELLOW}🔵 Dispositivos Pareados:${NC}"
bluetoothctl devices 2>/dev/null | wc -l
bluetoothctl devices 2>/dev/null | head -10 || echo "Nenhum"

# ============================================
# 7. ÁUDIO DEVICES
# ============================================
echo -e "\n${YELLOW}=== 🔊 ÁUDIO DEVICES ===${NC}\n"

echo -e "${YELLOW}Card Listing:${NC}"
aplay -l 2>/dev/null | head -20 || echo "aplay não disponível"

echo -e "\n${YELLOW}PipeWire Info:${NC}"
if command -v pw-dump &>/dev/null; then
    pw-dump Node/0 2>/dev/null | grep -E '"name"|"device.name"' | head -10 || echo "Sem informações"
else
    echo "pw-dump não instalado"
fi

# ============================================
# 8. RELATÓRIO FINAL
# ============================================
echo -e "\n${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              RESUMO DA AUDITORIA                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}\n"

issues=0

if ! pacman -Q pipewire &>/dev/null 2>&1; then
    echo -e "${RED}✗ PipeWire não instalado (recomendado)${NC}"
    ((issues++))
else
    echo -e "${GREEN}✓ PipeWire instalado${NC}"
fi

if ! pacman -Q bluez &>/dev/null 2>&1; then
    echo -e "${RED}✗ BlueZ não instalado${NC}"
    ((issues++))
else
    echo -e "${GREEN}✓ BlueZ instalado${NC}"
fi

if ! systemctl is-active --quiet bluetooth.service; then
    echo -e "${RED}✗ Bluetooth service não está ativo${NC}"
    ((issues++))
else
    echo -e "${GREEN}✓ Bluetooth service ativo${NC}"
fi

if ! systemctl is-active --quiet NetworkManager.service; then
    echo -e "${RED}✗ NetworkManager service não está ativo${NC}"
    ((issues++))
else
    echo -e "${GREEN}✓ NetworkManager service ativo${NC}"
fi

if [ $issues -eq 0 ]; then
    echo -e "\n${GREEN}✓ TUDO OK - Nenhum problema detectado${NC}\n"
else
    echo -e "\n${YELLOW}⚠ $issues issue(s) detectado(s)${NC}\n"
fi

echo -e "${YELLOW}Exportar este relatório:${NC}"
echo "  $0 > audit_$(date +%Y%m%d_%H%M%S).txt"
echo ""
