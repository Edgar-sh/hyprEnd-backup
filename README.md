# hyprEnd Backup - Configurações Hyprland

Backup de configurações personalizadas do Hyprland baseado no dotfiles [illogical-impulse](https://github.com/illogical-impulse/hyprland-dotfiles).

## 📋 Conteúdo

- **Configuração de Monitores**: Setup com dois monitores (Notebook eDP-1 + Monitor Externo DP-1)
- **Transparência e Animações**: Blur, shadow, dim_inactive configurado
- **Atalho para alternar Teclado**: Inglês ↔ Português (Super + Espaço)

## 🖥️ Configurações Principais

### Monitores (`monitors.conf`)
```
- eDP-1 (Notebook): 1920x1080@60Hz - Posição: 0x0
- DP-1 (Monitor Externo): 1920x1080@144Hz - Posição: 1920x0
```

**Como customizar:**
1. Edite `config/hypr/monitors.conf`
2. Use `hyprctl monitors` para descobrir nomes dos monitores
3. Formatos suportados:
   - `monitor = NAME, resolution@refresh, position, scale`
   - `monitor = NAME, preferred, auto, 1` (automático)

### Transparência e Janelas (`general.conf`)

As configurações de transparência e blur estão em:
- **Rounding**: 18px (suavidade das bordas)
- **Blur**: Habilitado com tamanho 10 e 3 passes
- **Shadow**: Habilitado com range 50px
- **Dim inativo**: Ativado com força 0.05 (as abas inativas ficam levemente mais escuras)
- **Vibrancy**: 0.5 (brilho do blur)

```conf
decoration {
    rounding = 18
    blur { enabled = true; size = 10; passes = 3; }
    shadow { enabled = true; range = 50; }
    dim_inactive = true
    dim_strength = 0.05
}
```

### Atalho para Alternar Teclado

**Combinação**: `Super (Win) + Espaço`

Configurado via XKB (X Keyboard extension):
```conf
input {
    kb_layout = us, br
    kb_options = grp:win_space_toggle
}
```

Pressione `Win + Espaço` para alternar entre US (Inglês) e BR (Português).

## 🚀 Instalação

### 1. Via Script Automático (Recomendado)

```bash
bash scripts/install.sh
```

O script irá:
- Backup das configurações antigas
- Copiar nova configuração
- Recarregar Hyprland

### 2. Manual

```bash
# Backup das configurações atuais
cp -r ~/.config/hypr ~/.config/hypr.backup.$(date +%Y%m%d_%H%M%S)

# Copiar configurações
cp config/hypr/monitors.conf ~/.config/hypr/
cp config/hypr/general.conf ~/.config/hypr/hyprland/
cp config/hypr/custom-keybinds.conf ~/.config/hypr/custom/keybinds.conf
cp config/hypr/custom-general.conf ~/.config/hypr/custom/general.conf

# Recarregar Hyprland (não sai da sessão)
hyprctl reload
```

## 🔄 Atualizando Configurações

Para atualizar este backup com novas configurações:

```bash
bash scripts/update.sh
```

Ou manualmente:
```bash
cp ~/.config/hypr/monitors.conf config/hypr/
cp ~/.config/hypr/hyprland/general.conf config/hypr/
git add -A
git commit -m "Update: Hyprland configurations"
git push
```

## 📝 Customização Avançada

### Alterar Atalho de Teclado

Edite `config/hypr/general.conf` e mude:
```conf
kb_options = grp:win_space_toggle
```

Outras opções disponíveis:
- `grp:alt_space_toggle` - Alt + Espaço
- `grp:ctrl_alt_t` - Ctrl + Alt + T
- `grp:caps_toggle` - Caps Lock
- [Mais opções aqui](https://wiki.archlinux.org/title/Xorg/Keyboard_layout)

### Aumentar/Diminuir Blur

```conf
blur {
    size = 10  # Aumentar para mais blur (ex: 15, 20)
    passes = 3 # Mais passes = mais intenso (ex: 4, 5)
}
```

### Aumentar/Diminuir Transparência

```conf
decoration {
    dim_strength = 0.05  # Aumentar para mais escuro (ex: 0.10, 0.15)
}
```

## 🗂️ Estrutura

```
hyprEnd-backup/
├── config/hypr/
│   ├── monitors.conf              # Configuração de monitores
│   ├── general.conf               # Configurações gerais (blur, shadow, etc)
│   ├── custom-keybinds.conf       # Atalhos customizados
│   ├── custom-general.conf        # Configurações customizadas
│   └── hypridle.conf              # Configuração do idle (screen lock)
├── scripts/
│   ├── install.sh                 # Script de instalação automática
│   └── update.sh                  # Script para atualizar backup
└── README.md                       # Este arquivo
```

## 🔧 Troubleshooting

### Atalho de teclado não funciona
```bash
# Verifique as configurações de teclado ativas
hyprctl getoption input:kb_layout
hyprctl getoption input:kb_options

# Recarregue Hyprland
hyprctl reload
```

### Monitores não aparecem
```bash
# Liste monitores conectados
hyprctl monitors

# Atualize monitors.conf com os nomes corretos
# Recarregue: hyprctl reload
```

### Blur muito intenso ou fraco
Ajuste `size` (5-20) e `passes` (1-5) em `general.conf` → `decoration` → `blur`

## 📚 Referências

- [Hyprland Wiki - Configuração](https://wiki.hyprland.org/Configuring/Configuring-Hyprland/)
- [illogical-impulse Dotfiles](https://github.com/illogical-impulse/hyprland-dotfiles)
- [XKB Keyboard Layouts](https://wiki.archlinux.org/title/Xorg/Keyboard_layout)

---

**Criado e mantido por**: @Edgar-sh
**Baseado em**: illogical-impulse Hyprland Dotfiles
