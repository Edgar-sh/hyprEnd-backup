#!/bin/bash

# Script de instalação das configurações Hyprland personalizadas
# Baseado em hyprEnd-backup

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== hyprEnd-backup Installer ===${NC}\n"

# Verificar se Hyprland está instalado
if ! command -v hyprctl &> /dev/null; then
    echo -e "${RED}Erro: Hyprland não está instalado!${NC}"
    echo "Instale com: sudo pacman -S hyprland (Arch) ou yay -S hyprland"
    exit 1
fi

# Definir variáveis de caminho
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HYPR_CONFIG="$HOME/.config/hypr"
BACKUP_DIR="$HYPR_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"

echo -e "${YELLOW}Caminhos:${NC}"
echo "Script Dir: $SCRIPT_DIR"
echo "Hyprland Config: $HYPR_CONFIG"
echo "Backup Dir: $BACKUP_DIR\n"

# Criar backup da configuração atual
echo -e "${YELLOW}📦 Criando backup da configuração atual...${NC}"
if [ -d "$HYPR_CONFIG" ]; then
    cp -r "$HYPR_CONFIG" "$BACKUP_DIR"
    echo -e "${GREEN}✓ Backup criado em: $BACKUP_DIR${NC}\n"
else
    echo -e "${YELLOW}⚠ Diretório $HYPR_CONFIG não existe, criando...${NC}"
    mkdir -p "$HYPR_CONFIG"/{custom,hyprland}
fi

# Função para copiar arquivo com confirmação
copy_config() {
    local src=$1
    local dest=$2
    local name=$3
    
    if [ -f "$src" ]; then
        cp "$src" "$dest"
        echo -e "${GREEN}✓${NC} Copiado: $name"
    else
        echo -e "${YELLOW}⚠${NC} Não encontrado: $src"
    fi
}

# Copiar configurações principais
echo -e "${YELLOW}📝 Copiando configurações...${NC}"

# Monitores
copy_config "$SCRIPT_DIR/config/hypr/monitors.conf" \
            "$HYPR_CONFIG/monitors.conf" \
            "Configuração de Monitores"

# General Hyprland
copy_config "$SCRIPT_DIR/config/hypr/general.conf" \
            "$HYPR_CONFIG/hyprland/general.conf" \
            "Configuração Geral (Blur, Shadow, Transparência)"

# Keybinds Custom
copy_config "$SCRIPT_DIR/config/hypr/custom-keybinds.conf" \
            "$HYPR_CONFIG/custom/keybinds.conf" \
            "Atalhos Customizados"

# General Custom
copy_config "$SCRIPT_DIR/config/hypr/custom-general.conf" \
            "$HYPR_CONFIG/custom/general.conf" \
            "Configurações Customizadas"

# Hypridle (se existir)
copy_config "$SCRIPT_DIR/config/hypr/hypridle.conf" \
            "$HYPR_CONFIG/hypridle.conf" \
            "Configuração do Hypridle"

echo ""

# Verificar se estamos dentro de uma sessão Hyprland
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    echo -e "${YELLOW}🔄 Recarregando configuração do Hyprland...${NC}"
    hyprctl reload 2>/dev/null && echo -e "${GREEN}✓ Configuração recarregada!${NC}\n" || {
        echo -e "${RED}✗ Erro ao recarregar. Tente manualmente: hyprctl reload${NC}\n"
    }
else
    echo -e "${YELLOW}⚠ Não estamos em uma sessão Hyprland ativa.${NC}"
    echo -e "${YELLOW}  Próxima vez que logar, as configurações serão carregadas.${NC}\n"
fi

# Mostrar atalhos importantes
echo -e "${GREEN}=== ✓ Instalação Completa! ===${NC}\n"
echo -e "${YELLOW}Configurações Instaladas:${NC}"
echo "  • Monitores: 2 telas (Notebook + Monitor Externo)"
echo "  • Transparência: Blur habilitado (tamanho 10, 3 passes)"
echo "  • Shadow: Habilitado (range 50px)"
echo "  • Atalho de Teclado: Super (Win) + Espaço = US ↔ BR"
echo ""

echo -e "${YELLOW}Atalhos Rápidos:${NC}"
echo "  • Pressione: Win + Espaço  →  Alterna entre Inglês (US) e Português (BR)"
echo "  • Editar Keybinds: Ctrl + Super + /  (Se em Quickshell)"
echo ""

echo -e "${YELLOW}Próximas Ações:${NC}"
echo "  1. Verifique os monitores: hyprctl monitors"
echo "  2. Edite monitores.conf se necessário: ~/.config/hypr/monitors.conf"
echo "  3. Personalize blur/shadow em: ~/.config/hypr/hyprland/general.conf"
echo "  4. Recarregue: hyprctl reload"
echo ""

echo -e "${YELLOW}Backup de Segurança:${NC}"
echo "  Se algo der errado, restaure com:"
echo "  rm -rf ~/.config/hypr && mv $BACKUP_DIR ~/.config/hypr"
echo "  hyprctl reload"
echo ""

echo -e "${GREEN}Pronto! 🎉${NC}"
