#!/bin/bash

# Script para atualizar o backup com as configurações atuais
# Use este script quando mudar suas configurações no Hyprland

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== hyprEnd-backup Update ===${NC}\n"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HYPR_CONFIG="$HOME/.config/hypr"

if [ ! -d "$HYPR_CONFIG" ]; then
    echo -e "${RED}Erro: Hyprland não está configurado em $HYPR_CONFIG${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Atualizando configurações do backup...${NC}\n"

# Função para copiar e relatar
update_config() {
    local src=$1
    local dest=$2
    local name=$3
    
    if [ -f "$src" ]; then
        cp "$src" "$dest"
        echo -e "${GREEN}✓${NC} Atualizado: $name"
    else
        echo -e "${YELLOW}⚠${NC} Não encontrado: $src (saltando)"
    fi
}

# Atualizar configurações
update_config "$HYPR_CONFIG/monitors.conf" \
              "$SCRIPT_DIR/config/hypr/monitors.conf" \
              "Monitores"

update_config "$HYPR_CONFIG/hyprland/general.conf" \
              "$SCRIPT_DIR/config/hypr/general.conf" \
              "Configuração Geral"

update_config "$HYPR_CONFIG/custom/keybinds.conf" \
              "$SCRIPT_DIR/config/hypr/custom-keybinds.conf" \
              "Keybinds Customizados"

update_config "$HYPR_CONFIG/custom/general.conf" \
              "$SCRIPT_DIR/config/hypr/custom-general.conf" \
              "Geral Customizado"

update_config "$HYPR_CONFIG/hypridle.conf" \
              "$SCRIPT_DIR/config/hypr/hypridle.conf" \
              "Hypridle"

echo ""
echo -e "${GREEN}✓ Backup atualizado com sucesso!${NC}\n"

# Sugerir git commit
if cd "$SCRIPT_DIR" && git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}Próximo passo (Git):${NC}"
    echo "  cd $SCRIPT_DIR"
    echo "  git add -A"
    echo "  git commit -m \"Update: Hyprland configurations\""
    echo "  git push"
    echo ""
fi

echo -e "${GREEN}Pronto! 🎉${NC}"
