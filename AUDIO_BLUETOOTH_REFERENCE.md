# Referência de Configuração - Áudio e Bluetooth

Documento de referência com as configurações de áudio e Bluetooth desta instalação.
Use este documento ao sincronizar para outra máquina.

---

## 📋 Configuração de Referência

Data: 2026-06-24
Hostname: anishoeffects
Sistema: Arch Linux + Hyprland + illogical-impulse

### Hardware Detectado

**WiFi/Wireless:**
```
00:14.3 Network controller: Intel Corporation Alder Lake-P PCH CNVi WiFi (rev 01)
```
Driver: `iwlwifi` (Intel WiFi)

**Bluetooth:**
```
Bus 001 Device 004: ID 8087:0aaa Intel Corp. Bluetooth 9460/9560 Jefferson Peak (JfP)
```
Driver: `btintel` + `btusb`

**Sound Card:**
```
Intel PCH Audio (HDA - High Definition Audio)
Codec: Realtek ALC269
```

---

## 📦 Pacotes Instalados

### ÁUDIO (PipeWire)

```
alsa-card-profiles 1:1.6.2-1
alsa-lib 1.2.15.3-2
alsa-plugins 1:1.2.12-5
alsa-topology-conf 1.2.5.1-4
alsa-ucm-conf 1.2.15.3-1
gst-plugin-pipewire 1:1.6.2-1
kpipewire 6.6.3-1
lib32-alsa-lib 1.2.15.3-1
lib32-alsa-plugins 1.2.12-1
lib32-libpipewire 1:1.6.2-1
lib32-pipewire 1:1.6.2-1
libpipewire 1:1.6.2-1
libpulse 17.0+r98+gb096704c0-1
pipewire 1:1.6.2-1
pipewire-alsa 1:1.6.2-1
pipewire-audio 1:1.6.2-1
pipewire-jack 1:1.6.2-1
pipewire-pulse 1:1.6.2-1
pulseaudio-alsa 1:1.2.12-5
vlc-plugin-alsa 3.0.22-3
```

**Stack**: PipeWire + ALSA
**Compatibilidade**: PulseAudio (via pipewire-pulse) + JACK (via pipewire-jack)

### BLUETOOTH (BlueZ)

```
bluez 5.86-4
bluez-deprecated-tools 5.86-4
bluez-libs 5.86-4
bluez-obex 5.86-4
bluez-qt 6.24.0-2
bluez-utils 5.86-4
gnome-bluetooth-3.0 47.1-3
```

**Stack**: BlueZ 5.86

### NETWORK

```
iwd 3.12-1
networkmanager 1.56.0-1
networkmanager-qt 6.24.0-2
wpa_supplicant 2:2.11-5
```

**Gerenciador**: NetworkManager
**WiFi**: iwd + wpa_supplicant

---

## 🔧 Kernel Modules Carregados

### ÁUDIO

```
snd_seq_dummy          12288  0
snd_hrtimer            12288  1
snd_seq               135168  7 snd_seq_dummy
snd_seq_device         16384  1 snd_seq
snd_ctl_led            28672  0
snd_soc_skl_hda_dsp    16384  4
snd_soc_intel_sof_board_helpers    32768  1 snd_soc_skl_hda_dsp
snd_soc_intel_hda_dsp_common    16384  1 snd_soc_intel_sof_board_helpers
snd_sof_probes         36864  0
snd_hda_codec_intelhdmi    28672  1
snd_hda_codec_alc269   155648  1
snd_hda_scodec_component    20480  1 snd_hda_codec_alc269
snd_hda_codec_realtek_lib    65536  1 snd_hda_codec_alc269
snd_hda_codec_generic   114688  2 snd_hda_codec_realtek_lib,snd_hda_codec_alc269
snd_soc_dmic           12288  1
snd_hda_intel          73728  0
snd_sof_pci_intel_tgl    16384  0
snd_sof_pci_intel_cnl    24576  1 snd_sof_pci_intel_tgl
snd_sof_intel_hda_generic    45056  2 snd_sof_pci_intel_tgl,snd_sof_pci_intel_cnl
snd_sof_intel_hda_sdw_bpt    24576  1 soundwire_intel
```

**Technology**: Intel SOF (Sound Open Firmware)

### BLUETOOTH

```
rfcomm                110592  4
btusb                  81920  0
btrtl                  36864  1 btusb
btintel                73728  1 btusb
bluetooth            1200128  34 btrtl,btmtk,btintel,btbcm,bnep,btusb,rfcomm
```

### NETWORK

```
iwlmvm                724992  0
mac80211             1728512  1 iwlmvm
ptp                    53248  1 iwlmvm
iwlwifi               618496  1 iwlmvm
btrtl                  36864  1 btusb
cfg80211             1470464  3 iwlmvm,iwlwifi,mac80211
bluetooth            1200128  34 btrtl,btmtk,btintel,btbcm,bnep,btusb,rfcomm
rfkill                 45056  7 iwlmvm,bluetooth,cfg80211
```

**WiFi Driver**: Intel iwlwifi

---

## ⚙️ Services Habilitadas

```
bluetooth.service                          enabled
NetworkManager-dispatcher.service          enabled
NetworkManager-wait-online.service         enabled
NetworkManager.service                     enabled
```

### Status Atual

```
bluetooth.service              ✓ active (running)
NetworkManager.service         ✓ active (running)
pipewire.service              ✓ active (running)
pipewire-pulse.service        ✓ active (running)
```

---

## 🖥️ Configuração de Áudio (PipeWire)

### Sinks (Saídas de Áudio)

Para verificar:
```bash
pw-dump Node/0 | grep '"name"'
pactl list short sinks
```

### Sources (Entradas de Áudio)

Para verificar:
```bash
pw-dump Node/0 | grep '"name"'
pactl list short sources
```

---

## 🔵 Bluetooth Padrão

**Adaptador**: C8:8A:9A:C6:2F:E5
**Nome**: anishoeffects

### Dispositivos Pareados

```
Device E8:47:3A:24:3B:51 DualSense Wireless Controller
Device 84:AC:60:A5:E3:E9 QCY-T13 ANC
Device 0E:0A:84:01:0D:59 HAYLOU S30
Device D8:37:3B:A5:F9:04 JBL Go 3
```

---

## 🌐 WiFi

**Interface**: wlan0 (192.168.x.x ou 10.0.0.x)
**Gerenciador**: NetworkManager

---

## 🔄 Como Sincronizar para Outra Máquina

1. **Usar o script automático:**
   ```bash
   sudo bash scripts/sync_audio_bluetooth.sh
   ```

2. **Ou manualmente:**
   ```bash
   # Instalar pacotes (ver lista acima)
   sudo pacman -S pipewire pipewire-alsa pipewire-pulse bluez networkmanager

   # Ativar services
   sudo systemctl enable --now bluetooth.service
   sudo systemctl enable --now NetworkManager.service

   # Rebootar
   sudo reboot
   ```

3. **Verificar instalação:**
   ```bash
   bash scripts/audit_audio_bluetooth.sh
   ```

---

## ⚠️ Problemas Conhecidos e Soluções

### WiFi não funciona
- Verificar: `nmcli radio wifi on`
- Reiniciar: `sudo systemctl restart NetworkManager`
- Ver logs: `journalctl -u NetworkManager -n 50`

### Bluetooth não funciona
- Verificar: `systemctl status bluetooth`
- Reiniciar: `sudo systemctl restart bluetooth`
- Ver logs: `journalctl -u bluetooth -n 50`

### Sem som
- Verificar: `systemctl status pipewire`
- Reiniciar: `systemctl restart pipewire pipewire-pulse`
- Testar: `speaker-test -t sine -f 1000 -l 1`

---

## 📞 Suporte

Para mais detalhes, veja: `AUDIO_BLUETOOTH.md`

Execute o script de auditoria: `bash scripts/audit_audio_bluetooth.sh`
