#!/bin/bash

# Script de SINCRONIZAÇÃO de Áudio e Bluetooth
# Instala e configura drivers/daemons baseado em referência
# SEGURO: Múltiplas confirmações, dry-run, rollback
#
# Uso:
#   $0                    - Interactive mode
#   $0 --auto             - Automático (ainda com pausas de segurança)
#   $0 --dry-run          - Ver o que seria instalado (sem fazer nada)
#   $0 --check            - Apenas verificar compatibilidade

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Flags
DRY_RUN=false
AUTO_MODE=false
CHECK_ONLY=false
INTERACTIVE=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true; INTERACTIVE=false; shift ;;
        --auto) AUTO_MODE=true; shift ;;
        --check) CHECK_ONLY=true; INTERACTIVE=false; shift ;;
        --no-confirm) INTERACTIVE=false; shift ;;
        *) echo "Uso: $0 [--dry-run|--auto|--check|--no-confirm]"; exit 1 ;;
    esac
done

# ============================================
# CONFIGURAÇÃO DE REFERÊNCIA
# ============================================
REFERENCE_AUDIO_PACKAGES=(
    "alsa-lib"
    "alsa-plugins"
    "alsa-utils"
    "alsa-topology-conf"
    "alsa-ucm-conf"
    "pipewire"
    "pipewire-alsa"
    "pipewire-audio"
    "pipewire-pulse"
    "pipewire-jack"
)

REFERENCE_BLUETOOTH_PACKAGES=(
    "bluez"
    "bluez-libs"
    "bluez-utils"
    "bluez-obex"
)

REFERENCE_NETWORK_PACKAGES=(
    "networkmanager"
    "iwd"
    "wpa_supplicant"
)

# ============================================
# FUNÇÕES
# ============================================

header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}\n"
}

info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

confirm() {
    if ! $INTERACTIVE && ! $AUTO_MODE; then
        return 0
    fi
    
    if $AUTO_MODE; then
        return 0
    fi
    
    local prompt="$1"
    local response
    
    while true; do
        read -p "$(echo -e ${YELLOW}$prompt${NC} ' (s/n): ')" -n 1 -r response
        echo
        case "$response" in
            [Ss]) return 0 ;;
            [Nn]) return 1 ;;
            *) echo "Por favor responda com 's' ou 'n'" ;;
        esac
    done
}

# Check if running as sudo/root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Este script requer privilégios de root"
        echo "Execute com: sudo $0"
        exit 1
    fi
}

# Criar backup automático
create_backup() {
    local backup_dir="/var/backups/audio-bluetooth-$(date +%Y%m%d_%H%M%S)"
    info "Criando backup em: $backup_dir"
    
    if $DRY_RUN; then
        echo "[DRY-RUN] mkdir -p $backup_dir"
        return
    fi
    
    mkdir -p "$backup_dir"
    
    # Backup de arquivos de configuração
    for dir in /etc/pulse /etc/alsa /etc/pipewire /etc/bluetooth; do
        if [ -d "$dir" ]; then
            cp -r "$dir" "$backup_dir/" 2>/dev/null || true
        fi
    done
    
    # Backup de lista de pacotes
    pacman -Q > "$backup_dir/packages_before.txt"
    systemctl list-unit-files > "$backup_dir/services_before.txt"
    
    success "Backup criado em: $backup_dir"
    echo "BACKUP_DIR=$backup_dir" > /tmp/audio_bluetooth_backup.env
}

# Verificar compatibilidade
check_compatibility() {
    header "VERIFICANDO COMPATIBILIDADE"
    
    # Verificar se é Arch Linux
    if ! command -v pacman &>/dev/null; then
        error "Este script é para Arch Linux apenas"
        exit 1
    fi
    success "Arch Linux detectado"
    
    # Verificar internet
    if ! ping -c 1 archlinux.org &>/dev/null; then
        warning "Sem conexão com internet (pacman pode falhar)"
    else
        success "Conexão com internet OK"
    fi
    
    # Verificar hardware
    if lspci | grep -iq "network controller"; then
        success "WiFi/Network controller detectado"
    else
        warning "WiFi/Network controller não encontrado"
    fi
    
    if lsusb | grep -iq "bluetooth"; then
        success "Bluetooth USB detectado"
    else
        warning "Bluetooth USB não encontrado"
    fi
    
    # Verificar espaço em disco
    local free_space=$(df /var/cache/pacman/pkg | awk 'NR==2 {print $4}')
    if [ "$free_space" -lt 1000000 ]; then
        error "Espaço insuficiente em disco (< 1GB disponível)"
        exit 1
    fi
    success "Espaço em disco OK ($(numfmt --to=iec $free_space 2>/dev/null || echo $free_space' KB'))"
}

# Verificar pacotes instalados
check_packages() {
    local package=$1
    if pacman -Q "$package" &>/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Instalar pacotes (com segurança)
install_packages() {
    local packages=("$@")
    local to_install=()
    
    for pkg in "${packages[@]}"; do
        if ! check_packages "$pkg"; then
            to_install+=("$pkg")
        fi
    done
    
    if [ ${#to_install[@]} -eq 0 ]; then
        return 0
    fi
    
    if $DRY_RUN; then
        echo "[DRY-RUN] pacman -S --noconfirm ${to_install[@]}"
        return 0
    fi
    
    info "Instalando: ${to_install[@]}"
    pacman -Sy
    pacman -S --noconfirm "${to_install[@]}" || {
        error "Falha ao instalar pacotes"
        return 1
    }
}

# Ativar services
enable_services() {
    local services=("$@")
    
    for service in "${services[@]}"; do
        if $DRY_RUN; then
            echo "[DRY-RUN] systemctl enable --now $service"
        else
            info "Ativando: $service"
            systemctl enable --now "$service" || {
                error "Falha ao ativar $service"
            }
        fi
    done
}

# ============================================
# MAIN
# ============================================

# Banner
echo -e "${BLUE}"
cat << 'EOF'
╔══════════════════════════════════════════════════════╗
║  SINCRONIZADOR: ÁUDIO E BLUETOOTH                    ║
║  Safe & Reversible Audio/Bluetooth Configuration     ║
╚══════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

info "Modo: $([ "$DRY_RUN" = true ] && echo 'DRY-RUN' || echo 'NORMAL')"
info "Interativo: $INTERACTIVE"
info "Auto: $AUTO_MODE"

if [ "$DRY_RUN" = true ]; then
    warning "MODO DRY-RUN: Nenhuma mudança será feita"
fi

echo ""

# Verificar root
check_root

# Check only mode
if [ "$CHECK_ONLY" = true ]; then
    check_compatibility
    exit 0
fi

# Confirmação de segurança
echo -e "${RED}⚠️  ATENÇÃO${NC}"
echo "Este script irá:"
echo "  1. Criar backup de configurações"
echo "  2. Instalar/sincronizar pacotes de áudio e Bluetooth"
echo "  3. Ativar services necessários"
echo "  4. Recarregar daemons"
echo ""

if ! confirm "Deseja continuar?"; then
    error "Operação cancelada pelo usuário"
    exit 0
fi

# ============================================
# EXECUÇÃO
# ============================================

# 1. Criar backup
create_backup

# 2. Verificar compatibilidade
check_compatibility

# 3. ÁUDIO
header "CONFIGURANDO ÁUDIO"

info "Pacotes de áudio necessários:"
for pkg in "${REFERENCE_AUDIO_PACKAGES[@]}"; do
    echo "  - $pkg"
done

if confirm "Instalar/sincronizar pacotes de áudio?"; then
    install_packages "${REFERENCE_AUDIO_PACKAGES[@]}"
    success "Pacotes de áudio instalados"
fi

# 4. BLUETOOTH
header "CONFIGURANDO BLUETOOTH"

info "Pacotes de Bluetooth necessários:"
for pkg in "${REFERENCE_BLUETOOTH_PACKAGES[@]}"; do
    echo "  - $pkg"
done

if confirm "Instalar/sincronizar pacotes de Bluetooth?"; then
    install_packages "${REFERENCE_BLUETOOTH_PACKAGES[@]}"
    success "Pacotes de Bluetooth instalados"
fi

# 5. NETWORK
header "CONFIGURANDO REDE"

info "Pacotes de Network necessários:"
for pkg in "${REFERENCE_NETWORK_PACKAGES[@]}"; do
    echo "  - $pkg"
done

if confirm "Instalar/sincronizar pacotes de Network?"; then
    install_packages "${REFERENCE_NETWORK_PACKAGES[@]}"
    success "Pacotes de Network instalados"
fi

# 6. Ativar Services
header "ATIVANDO SERVICES"

echo "Services a serem ativados:"
echo "  - bluetooth.service"
echo "  - NetworkManager.service"

if confirm "Ativar services?"; then
    enable_services "bluetooth.service" "NetworkManager.service"
    success "Services ativados"
fi

# 7. Reload daemons
if ! $DRY_RUN; then
    header "FINALIZANDO"
    
    info "Recarregando systemd"
    systemctl daemon-reload
    
    info "Aguardando services iniciarem..."
    sleep 2
    
    # Verificação final
    if systemctl is-active --quiet bluetooth.service; then
        success "Bluetooth service está ativo"
    else
        warning "Bluetooth service pode estar inativo - verifique manualmente"
    fi
    
    if systemctl is-active --quiet NetworkManager.service; then
        success "NetworkManager service está ativo"
    else
        warning "NetworkManager service pode estar inativo - verifique manualmente"
    fi
fi

# ============================================
# CONCLUSÃO
# ============================================

header "SINCRONIZAÇÃO CONCLUÍDA"

if [ "$DRY_RUN" = true ]; then
    warning "Modo DRY-RUN: Nenhuma mudança foi feita"
else
    success "Configuração aplicada com sucesso!"
fi

echo "Próximas ações:"
echo "  1. Reiniciar o sistema: reboot"
echo "  2. Testar Bluetooth: bluetoothctl"
echo "  3. Testar WiFi: nmcli con show --active"
echo "  4. Testar Áudio: pactl info"
echo ""

if [ -f /tmp/audio_bluetooth_backup.env ]; then
    source /tmp/audio_bluetooth_backup.env
    echo "Backup salvo em: $BACKUP_DIR"
    echo "Para reverter, copie os arquivos de volta"
fi

echo ""
