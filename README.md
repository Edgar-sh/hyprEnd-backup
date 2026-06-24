# hyprEnd Backup - Configurações Hyprland

Backup de configurações personalizadas do Hyprland baseado no dotfiles [illogical-impulse](https://github.com/illogical-impulse/hyprland-dotfiles).

## 📋 Conteúdo

- **Configuração de Monitores**: Setup com dois monitores (Notebook eDP-1 + Monitor Externo DP-1)
- **Transparência e Animações**: Blur, shadow, dim_inactive configurado
- **Atalho para alternar Teclado**: Inglês ↔ Português (Super + Espaço)
- **Áudio e Bluetooth**: Scripts de diagnóstico e sincronização de drivers/daemons
- **Rede/WiFi**: Configuração de NetworkManager e conectividade

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

### 2. Audio e Bluetooth (Novo!)

Para sincronizar drivers de áudio e Bluetooth com esta instalação:

```bash
# Auditar sistema
bash scripts/audit_audio_bluetooth.sh

# Sincronizar (com múltiplas confirmações de segurança)
sudo bash scripts/sync_audio_bluetooth.sh

# Apenas verificar compatibilidade
sudo bash scripts/sync_audio_bluetooth.sh --check

# Simular mudanças (sem fazer nada)
sudo bash scripts/sync_audio_bluetooth.sh --dry-run
```

Veja `AUDIO_BLUETOOTH.md` para detalhes completos.

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

## 📋 Estrutura

```
hyprEnd-backup/
├── README.md                            (Este arquivo - guia principal)
├── CUSTOMIZATION.md                     (Detalhes: monitores, transparência, teclado)
├── AUDIO_BLUETOOTH.md                   (Guia completo de áudio e Bluetooth) ⭐ NOVO
├── AUDIO_BLUETOOTH_REFERENCE.md         (Referência desta instalação) ⭐ NOVO
├── .gitignore
├── config/hypr/
│   ├── monitors.conf                    (Configuração de monitores)
│   ├── general.conf                     (Configurações gerais: blur, shadow, transparência)
│   ├── hypridle.conf                    (Configuração de idle/screen lock)
│   ├── custom-keybinds.conf             (Atalhos customizados)
│   └── custom-general.conf              (Configurações customizadas)
└── scripts/
    ├── install.sh                       (Instalar configurações Hyprland)
    ├── update.sh                        (Atualizar backup Hyprland)
    ├── audit_audio_bluetooth.sh         (Auditar áudio e Bluetooth) ⭐ NOVO
    └── sync_audio_bluetooth.sh          (Sincronizar áudio e Bluetooth) ⭐ NOVO
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

## 🔊 Áudio e Bluetooth

Se estiver tendo problemas com **áudio** ou **Bluetooth** após instalar em outro PC:

```bash
# 1. Auditar o sistema
bash scripts/audit_audio_bluetooth.sh

# 2. Sincronizar drivers com esta instalação
sudo bash scripts/sync_audio_bluetooth.sh

# 3. Rebootar
sudo reboot

# 4. Verificar se funciona
bluetoothctl list
nmcli radio wifi
```

Para detalhes técnicos completos, veja:
- 📖 `AUDIO_BLUETOOTH.md` - Guia completo
- 📋 `AUDIO_BLUETOOTH_REFERENCE.md` - Configuração desta máquina

## 📚 Referências

### Hyprland
- [Hyprland Wiki - Configuração](https://wiki.hyprland.org/Configuring/Configuring-Hyprland/)
- [illogical-impulse Dotfiles](https://github.com/illogical-impulse/hyprland-dotfiles)
- [XKB Keyboard Layouts](https://wiki.archlinux.org/title/Xorg/Keyboard_layout)

### Áudio e Bluetooth
- [Arch Wiki - PipeWire](https://wiki.archlinux.org/title/PipeWire)
- [Arch Wiki - Bluetooth](https://wiki.archlinux.org/title/Bluetooth)
- [Arch Wiki - NetworkManager](https://wiki.archlinux.org/title/NetworkManager)

---

**Criado e mantido por**: @Edgar-sh
**Baseado em**: illogical-impulse Hyprland Dotfiles
