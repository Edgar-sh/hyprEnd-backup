# Guia de Áudio e Bluetooth - hyprEnd-backup

Documentação completa sobre configuração de áudio e Bluetooth no Arch Linux com Hyprland.

---

## 📋 Índice

1. [Diagnóstico](#-diagnóstico)
2. [Áudio](#-áudio)
3. [Bluetooth](#-bluetooth)
4. [WiFi/Network](#-wifinetwork)
5. [Troubleshooting](#-troubleshooting)
6. [Scripts](#-scripts)

---

## 🔍 Diagnóstico

### Executar Auditoria

```bash
bash scripts/audit_audio_bluetooth.sh
```

Isso coleta informações sobre:
- ✓ Pacotes instalados
- ✓ Kernel modules carregados
- ✓ Hardware detectado
- ✓ Daemons rodando
- ✓ Services habilitados
- ✓ Conectividade

### Interpretar Resultados

**Verde (✓)**: Tudo OK
**Amarelo (⚠)**: Aviso (pode precisar atenção)
**Vermelho (✗)**: Erro (precisa ser resolvido)

---

## 🔊 Áudio

### Arquitetura Recomendada

```
Application (Brave, VLC, Spotify, etc)
    ↓
PipeWire API (compatível com PulseAudio + JACK)
    ↓
PipeWire Daemon (/usr/bin/pipewire)
    ↓
ALSA (drivers kernel)
    ↓
Hardware (Sound Card)
```

### Pacotes Necessários

| Pacote | Versão | Propósito |
|--------|--------|----------|
| `pipewire` | 1.6.2+ | Servidor de áudio moderno |
| `pipewire-alsa` | 1.6.2+ | Plugin ALSA para PipeWire |
| `pipewire-audio` | 1.6.2+ | Suporte a áudio |
| `pipewire-pulse` | 1.6.2+ | Compatibilidade PulseAudio |
| `pipewire-jack` | 1.6.2+ | Compatibilidade JACK |
| `alsa-lib` | 1.2.15+ | Biblioteca ALSA |
| `alsa-plugins` | 1.2.12+ | Plugins ALSA |
| `alsa-utils` | - | Utilitários (alsamixer, aplay) |

### Verificar Instalação

```bash
# Verificar pacotes
pacman -Q pipewire pipewire-pulse
# Output esperado:
# pipewire 1:1.6.2-1
# pipewire-pulse 1:1.6.2-1

# Verificar daemon rodando
ps aux | grep pipewire | grep -v grep
# Output esperado:
# /usr/bin/pipewire
# /usr/bin/pipewire-pulse

# Verificar dispositivos de áudio
aplay -l
# Output esperado:
# **** Listar PLAYBACK Devices ****
# card 0: PCH [HDA Intel PCH], device 0: ALC269 Analog [ALC269 Analog]
# card 0: PCH [HDA Intel PCH], device 1: ALC269 Digital [ALC269 Digital]
```

### Troubleshooting Áudio

**Problema**: Sem som
```bash
# 1. Verificar se PipeWire está rodando
systemctl status pipewire
systemctl status pipewire-pulse

# 2. Reiniciar
systemctl restart pipewire
systemctl restart pipewire-pulse

# 3. Verificar volume
pactl get-sink-mute 0
pactl get-sink-volume 0

# 4. Aumentar volume (se muted)
pactl set-sink-mute 0 false
pactl set-sink-volume 0 100%
```

**Problema**: Áudio entrecortado
```bash
# Aumentar buffer
pactl set-default-sink 0

# Ver latência
pw-delay

# Verificar se há problema de CPU
top -p $(pgrep pipewire)
```

### Mudando para PulseAudio (alternativa)

Se PipeWire não funcionar bem:

```bash
# Remover PipeWire
sudo pacman -R pipewire pipewire-pulse pipewire-alsa

# Instalar PulseAudio
sudo pacman -S pulseaudio pulseaudio-alsa

# Ativar
systemctl --user start pulseaudio
systemctl --user enable pulseaudio
```

---

## 🔵 Bluetooth

### Arquitetura

```
Application (Pavucontrol, Blueman, etc)
    ↓
BlueZ Stack (bluetoothd daemon)
    ↓
Linux Kernel (bluetooth module)
    ↓
Bluetooth Adapter (Intel/Realtek/Broadcom)
    ↓
Bluetooth Device (Headphone, Mouse, etc)
```

### Pacotes Necessários

| Pacote | Versão | Propósito |
|--------|--------|----------|
| `bluez` | 5.86+ | Stack Bluetooth (daemon bluetoothd) |
| `bluez-libs` | 5.86+ | Bibliotecas BlueZ |
| `bluez-utils` | 5.86+ | Utilitários (bluetoothctl) |
| `bluez-obex` | 5.86+ | OBEX daemon (transferência de arquivos) |

### Verificar Instalação

```bash
# Verificar pacotes
pacman -Q bluez
# Output esperado:
# bluez 5.86-4

# Verificar daemon rodando
systemctl status bluetooth
# Output esperado:
# ● bluetooth.service - Bluetooth service
#     Active: active (running)

# Verificar adaptador
bluetoothctl show
# Output esperado:
# Controller C8:8A:9A:C6:2F:E5 (nome do adaptador)
#     Powered: yes
#     Discoverable: yes
```

### Usar Bluetooth

```bash
# Entrar no bluetoothctl
bluetoothctl

# Comandos úteis:
power on                      # Ativar
power off                     # Desativar
scan on                       # Procurar dispositivos
devices                       # Listar pareados
pair <MAC>                    # Parear novo
connect <MAC>                 # Conectar
disconnect <MAC>             # Desconectar
remove <MAC>                  # Remover pareado
info <MAC>                    # Informações
quit                          # Sair
```

### Exemplo Prático

```bash
# 1. Ativar Bluetooth
bluetoothctl power on

# 2. Procurar dispositivos
bluetoothctl scan on
# Aguarde 5-10 segundos

# 3. Parear
bluetoothctl pair EC:FC:B3:6C:1A:8F

# 4. Conectar
bluetoothctl connect EC:FC:B3:6C:1A:8F

# 5. Usar com áudio
# - Abrir pavucontrol (se instalado)
# - Selecionar dispositivo Bluetooth como sink

# Sair do scan
bluetoothctl scan off
```

### Troubleshooting Bluetooth

**Problema**: Bluetooth não inicia
```bash
# Verificar service
systemctl status bluetooth

# Reiniciar
sudo systemctl restart bluetooth

# Verificar logs
journalctl -u bluetooth -n 50
```

**Problema**: Não encontra dispositivos
```bash
# Verificar se está em modo discoverable
bluetoothctl show
# Procurar por "Discoverable: yes"

# Se não, ativar
bluetoothctl power on
bluetoothctl discoverable on

# Verificar adaptador
bluetoothctl list
```

**Problema**: Dispositivo não conecta
```bash
# 1. Remover e reparear
bluetoothctl remove <MAC>
bluetoothctl pair <MAC>
bluetoothctl connect <MAC>

# 2. Verificar power
bluetoothctl power on

# 3. Verificar se está trusted
bluetoothctl info <MAC> | grep "Trusted"
bluetoothctl trust <MAC>  # Se necessário
```

**Problema**: Bluetooth intermitente
```bash
# Pode ser conflito com WiFi (mesma frequência 2.4GHz)
# Solução 1: Usar WiFi 5GHz se disponível
# Solução 2: Aumentar potência

# Verificar RSSI (signal strength)
bluetoothctl info <MAC> | grep RSSI

# Se fraco, aproxime o dispositivo ou remova obstáculos
```

---

## 🌐 WiFi/Network

### Arquitetura (NetworkManager)

```
Application (Firefox, etc)
    ↓
NetworkManager daemon
    ↓
wpa_supplicant / iwd
    ↓
Linux Kernel (iwlwifi, cfg80211)
    ↓
WiFi Adapter (Intel, Realtek, etc)
    ↓
WiFi Network (Router)
```

### Pacotes Necessários

| Pacote | Versão | Propósito |
|--------|--------|----------|
| `networkmanager` | 1.56+ | Gerenciador de rede (daemon) |
| `iwd` | 3.12+ | Daemon WiFi moderno (alternativa) |
| `wpa_supplicant` | 2.11+ | Suporte WPA/WPA2 |

### Verificar Instalação

```bash
# Verificar NetworkManager
systemctl status NetworkManager
# Output esperado:
# ● NetworkManager.service - Network Manager
#     Active: active (running)

# Verificar WiFi
nmcli radio wifi
# Output esperado:
# enabled

# Listar redes disponíveis
nmcli dev wifi list

# Listar conexões ativas
nmcli con show --active
```

### Conectar a WiFi

```bash
# Via nmcli (CLI)
nmcli dev wifi connect "SSID" password "senha"

# Listar conexões salvas
nmcli con

# Desconectar
nmcli con down "SSID"

# Remover conexão
nmcli con delete "SSID"
```

### Troubleshooting WiFi

**Problema**: WiFi não conecta
```bash
# 1. Verificar se WiFi está ligado
nmcli radio wifi on

# 2. Escanear redes
nmcli dev wifi rescan

# 3. Tentar conectar novamente
nmcli dev wifi connect "SSID" password "senha"

# 4. Ver logs
journalctl -u NetworkManager -n 50
```

**Problema**: Conexão intermitente
```bash
# Pode ser problema de driver WiFi

# Verificar qual driver está sendo usado
lspci | grep -i "network\|wireless"

# Verificar módulos carregados
lsmod | grep iwl

# Se Intel WiFi (iwlwifi):
# Aumentar debug
echo "module iwlwifi +p" > /sys/kernel/debug/dynamic_debug/control

# Ver logs detalhados
dmesg | grep iwlwifi | tail -20
```

**Problema**: Conecta mas sem internet
```bash
# 1. Verificar DHCP
nmcli con show "SSID"
# Procurar por "ipv4.addresses"

# 2. Renovar DHCP
sudo dhclient -r && sudo dhclient

# 3. Verificar DNS
cat /etc/resolv.conf

# 4. Testar conectividade
ping 8.8.8.8    # Google DNS
```

---

## 🛠️ Scripts

### audit_audio_bluetooth.sh

Audita todo o sistema de áudio e Bluetooth sem fazer mudanças.

```bash
bash scripts/audit_audio_bluetooth.sh

# Salvar para arquivo
bash scripts/audit_audio_bluetooth.sh > audit_$(date +%Y%m%d_%H%M%S).txt
```

**Saída inclui:**
- Pacotes instalados
- Kernel modules carregados
- Hardware detectado
- Daemons rodando
- Services habilitadas
- Status de conectividade
- Relatório de problemas

### sync_audio_bluetooth.sh

Sincroniza áudio e Bluetooth com a configuração de referência.

```bash
# Modo interativo (recomendado)
sudo bash scripts/sync_audio_bluetooth.sh

# Modo dry-run (ver o que faria)
sudo bash scripts/sync_audio_bluetooth.sh --dry-run

# Modo automático (com menos confirmações)
sudo bash scripts/sync_audio_bluetooth.sh --auto

# Apenas verificar compatibilidade
sudo bash scripts/sync_audio_bluetooth.sh --check
```

**O script faz:**
1. ✓ Verifica compatibilidade
2. ✓ Cria backup automático
3. ✓ Instala pacotes necessários
4. ✓ Ativa services
5. ✓ Recarrega daemons
6. ✓ Verifica tudo funciona

**Segurança:**
- Múltiplas confirmações
- Backup automático
- Modo dry-run disponível
- Logs salvos em `/var/backups/audio-bluetooth-*/`

---

## 📞 Alternativas

### Áudio

| Sistema | Pros | Contras |
|---------|------|---------|
| **PipeWire** | Moderno, flexível, melhor latência | Mais novo, menos estável |
| **PulseAudio** | Estável, amplamente suportado | Mais velho, pior latência |
| **ALSA** | Direto, sem daemon | Difícil de configurar, sem mixer |
| **JACK** | Pro audio, baixa latência | Complexo, não é padrão |

### Bluetooth

| Stack | Pros | Contras |
|-------|------|---------|
| **BlueZ (padrão)** | Padrão Linux, bem mantido | Pode ser lento |
| **Bluez + Blueman** | Interface gráfica | Dependência extra |

### WiFi

| Daemon | Pros | Contras |
|--------|------|---------|
| **NetworkManager** | Fácil, automático | Pesado, muita dependência |
| **iwd** | Leve, rápido | Mais simples, menos features |
| **dhcpcd** | Minimalista | Manual, complexo |

---

## 🔗 Referências

- [Arch Wiki - PipeWire](https://wiki.archlinux.org/title/PipeWire)
- [Arch Wiki - Bluetooth](https://wiki.archlinux.org/title/Bluetooth)
- [Arch Wiki - NetworkManager](https://wiki.archlinux.org/title/NetworkManager)
- [PipeWire Documentation](https://docs.pipewire.org/)
- [BlueZ Documentation](https://www.bluez.org/)

---

**Última atualização**: 2026-06-24
**Testado em**: Arch Linux + Hyprland + illogical-impulse
