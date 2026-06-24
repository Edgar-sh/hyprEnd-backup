# Guia de Customização - hyprEnd-backup

Detalhes aprofundados sobre as três configurações principais: **Monitores**, **Transparência** e **Atalho de Teclado**.

---

## 1️⃣ Configuração de Monitores

### 📍 Arquivo: `config/hypr/monitors.conf`

#### Setup Atual (Dois Monitores)
```conf
# Notebook (Esquerda) - Começa em 0x0
monitor = eDP-1, 1920x1080@60, 0x0, 1

# Monitor Arzopa (Centro/Direita) - Começa em 1920x0 (logo após o notebook)
monitor = DP-1, 1920x1080@144, 1920x0, 1

# Fallback para outros monitores
monitor = , preferred, auto, 1
```

### 🔍 Compreender a sintaxe

```
monitor = <name>, <resolution>@<refresh>, <position>, <scale>
```

| Campo | Exemplo | Descrição |
|-------|---------|-----------|
| `name` | `eDP-1`, `DP-1` | Nome da saída de vídeo |
| `resolution` | `1920x1080` | Resolução (largura x altura) |
| `refresh` | `@60`, `@144` | Frequência de atualização (Hz) |
| `position` | `0x0`, `1920x0` | Posição X e Y (pixels) |
| `scale` | `1`, `2` | Escala (1 = 100%, 2 = 200%) |

### 🖥️ Descobrir seus monitores

```bash
# Listar monitores conectados
hyprctl monitors

# Exemplo de output:
# Monitor eDP-1 (ID: 0):
#     Resolution: 1920x1080
#     Refresh Rate: 60.000000 Hz
#     Scale: 1.000000
#
# Monitor DP-1 (ID: 1):
#     Resolution: 1920x1080
#     Refresh Rate: 144.000000 Hz
#     Scale: 1.000000
```

### 🎯 Exemplos de Configurações

#### Um Monitor (Notebook apenas)
```conf
monitor = eDP-1, preferred, auto, 1
```

#### Dois Monitores Lado a Lado
```conf
monitor = eDP-1, 1920x1080@60, 0x0, 1
monitor = DP-1, 1920x1080@144, 1920x0, 1
```

#### Dois Monitores Verticais (Stacked)
```conf
monitor = eDP-1, 1920x1080@60, 0x0, 1
monitor = DP-1, 1920x1080@60, 0x1080, 1
```

#### Monitor Externo Apenas (Fechar Notebook)
```conf
monitor = HDMI-1, preferred, auto, 1
monitor = eDP-1, disable
```

#### Com Resolução Nativa Automática
```conf
monitor = , preferred, auto, 1
```

### 🔧 Teste suas Alterações

```bash
# Editar configuração
nano ~/.config/hypr/monitors.conf

# Testar sem recarregar (se em Hyprland)
hyprctl reload

# Se der erro, reverta
hyprctl keyword monitor default
```

---

## 2️⃣ Transparência e Janelas

### 📍 Arquivo: `config/hypr/general.conf` (seção `decoration`)

#### Configuração Atual
```conf
decoration {
    # Arredondamento das bordas
    rounding_power = 2
    rounding = 18

    blur {
        enabled = true
        xray = true                    # Permite xray do blur
        special = false
        new_optimizations = true
        size = 10                      # Tamanho do blur kernel
        passes = 3                     # Número de passes (mais = mais intenso)
        brightness = 1                 # Brilho do blur (0.0-1.0)
        noise = 0.05                   # Ruído adicionado
        contrast = 0.89                # Contraste
        vibrancy = 0.5                 # Vibração das cores
        vibrancy_darkness = 0.5        # Escurecimento da vibração
        popups = false                 # Aplicar blur em popups
        popups_ignorealpha = 0.6
        input_methods = true
        input_methods_ignorealpha = 0.8
    }

    shadow {
        enabled = true
        ignore_window = true
        range = 50                     # Tamanho da sombra
        offset = 0 4                   # Offset X, Y da sombra
        render_power = 10              # Força de renderização
        color = rgba(00000027)         # Cor RGBA (preto com alfa 27)
    }

    # Escurecer janelas inativas
    dim_inactive = true
    dim_strength = 0.05                # 0.0 = sem dim, 1.0 = totalmente escuro
}
```

### 🎨 Customizar Blur

| Parâmetro | Mínimo | Máximo | Recomendado | Efeito |
|-----------|--------|--------|------------|--------|
| `size` | 1 | 20 | 5-15 | Tamanho do blur (maior = mais desfocado) |
| `passes` | 1 | 5 | 2-4 | Intensidade (mais = mais intenso, menos performance) |
| `brightness` | 0.0 | 1.0 | 0.8-1.0 | Claridade do blur |
| `vibrancy` | 0.0 | 1.0 | 0.3-0.7 | Saturação das cores no blur |

#### Exemplos de Presets

**Blur Sutil (Mais Performance)**
```conf
blur {
    enabled = true
    size = 5
    passes = 1
    brightness = 1
}
```

**Blur Normal (Recomendado)**
```conf
blur {
    enabled = true
    size = 10
    passes = 3
    brightness = 1
    vibrancy = 0.5
}
```

**Blur Intenso (Menos Performance)**
```conf
blur {
    enabled = true
    size = 15
    passes = 5
    brightness = 0.9
    vibrancy = 0.7
}
```

**Sem Blur (Máxima Performance)**
```conf
blur {
    enabled = false
}
```

### 🌑 Customizar Shadow

```conf
shadow {
    enabled = true          # Ativar/desativar
    range = 50             # Aumentar = sombra maior
    offset = 0 4           # Deslocar sombra (X Y)
    render_power = 10      # Força da sombra (1-20)
    color = rgba(00000027) # Cor (hex + alpha: 00-FF)
}
```

**Cores de Sombra Comuns:**
- `rgba(00000027)` - Preto bem transparente (padrão)
- `rgba(000000FF)` - Preto opaco (mais forte)
- `rgba(0000004D)` - Preto médio
- `rgba(FF0000FF)` - Vermelha (para debug)

### 👁️ Customizar Dim (Escurecimento)

```conf
dim_inactive = true      # Ativar/desativar dim
dim_strength = 0.05      # 0.00 = nenhum, 1.00 = preto completo
dim_special = 0.2        # Dim especial (special workspace)
```

**Exemplos:**
- `dim_strength = 0.0` - Sem escurecimento
- `dim_strength = 0.05` - Muito sutil (padrão)
- `dim_strength = 0.15` - Moderado
- `dim_strength = 0.30` - Forte

### ✨ Teste suas Alterações

```bash
# Editar configuração
nano ~/.config/hypr/hyprland/general.conf

# Recarregar sem sair
hyprctl reload

# Visualizar configuração ativa
hyprctl getoption decoration:blur:size
hyprctl getoption decoration:dim_strength
```

---

## 3️⃣ Atalho para Alternar Teclado

### 📍 Arquivo: `config/hypr/general.conf` (seção `input`)

#### Configuração Atual
```conf
input {
    kb_layout = us, br                    # Layouts: US (Inglês) e BR (Português)
    kb_options = grp:win_space_toggle     # Win + Espaço = alternar
    numlock_by_default = true
    repeat_delay = 250
    repeat_rate = 35
    # ... outras configurações ...
}
```

### ⌨️ Atalhos Disponíveis

| Atalho | Opção | Descrição |
|--------|-------|-----------|
| `Win + Espaço` | `grp:win_space_toggle` | **Padrão (recomendado)** |
| `Alt + Espaço` | `grp:alt_space_toggle` | Pode conflitar com apps |
| `Ctrl + Alt + T` | `grp:ctrl_alt_t` | Alternância por tecla T |
| `Caps Lock` | `grp:caps_toggle` | Usar Caps Lock para alternar |
| `Scroll Lock` | `grp:sclk_toggle` | Usar Scroll Lock |
| `Both Shift` | `grp:shifts_toggle` | Pressionar Shift 2x |
| `Alt + Shift` | `grp:alt_shift_toggle` | Alt + Shift |

### 🇺🇸 / 🇧🇷 Adicionar/Remover Idiomas

```conf
# Apenas US (Inglês)
kb_layout = us
kb_options = 

# US + BR (padrão)
kb_layout = us, br
kb_options = grp:win_space_toggle

# US + BR + ES (Espanhol)
kb_layout = us, br, es
kb_options = grp:win_space_toggle

# Múltiplas opções (use vírgula)
kb_options = grp:win_space_toggle,caps:swapescape
```

### 🔄 Como Usar

1. **Alternar idioma**: Pressione `Win + Espaço`
2. **Verificar idioma ativo**: Procure no painel do seu desktop
3. **Velocidade de repetição**: Configure `repeat_delay` (ms) e `repeat_rate` (Hz)

### 🧪 Testar Teclado

```bash
# Listar layouts disponíveis
localectl list-x11-keymap-layouts | grep -E "us|br"

# Testar no Hyprland
hyprctl keyword input:kb_layout "us,br"
hyprctl keyword input:kb_options "grp:win_space_toggle"

# Verificar configuração atual
hyprctl getoption input:kb_layout
hyprctl getoption input:kb_options
```

### 📋 Lista Completa de Layouts

Layouts comuns:
- `us` - United States (English)
- `br` - Brazil (Português)
- `es` - Spain (Español)
- `fr` - France (Français)
- `de` - Germany (Deutsch)
- `it` - Italy (Italiano)
- `pt` - Portugal (Português)
- `gb` - United Kingdom
- `jp` - Japan (日本語)
- `ru` - Russia (Русский)

```bash
# Ver lista completa
localectl list-x11-keymap-layouts
```

---

## 🔗 Referências Completas

### Variáveis Hyprland
- [Hyprland Wiki - Variables](https://wiki.hyprland.org/Configuring/Variables/)
- [Monitors Documentation](https://wiki.hyprland.org/Configuring/Monitors/)
- [Decoration (Blur, Shadow, etc)](https://wiki.hyprland.org/Configuring/Variables/#decoration)

### XKB Keyboard
- [ArchWiki - Keyboard Layout](https://wiki.archlinux.org/title/Xorg/Keyboard_layout)
- [FreeDesktop.org - Keyboard](https://www.freedesktop.org/wiki/Software/systemd/man/localectl/)

### illogical-impulse
- [GitHub Repository](https://github.com/illogical-impulse/hyprland-dotfiles)
- [Wiki Documentation](https://github.com/illogical-impulse/hyprland-dotfiles/wiki)

---

## 💡 Dicas Rápidas

**Performance vs. Visual:**
- Menos blur/shadow = mais performance
- Mais passes de blur = melhor visual mas menos performance
- Dim inativo = pouco impacto, muito útil

**Debugging:**
```bash
# Ver todas as variáveis relacionadas a decoração
hyprctl getoption decoration

# Ver todas as variáveis de input (teclado)
hyprctl getoption input

# Recarregar com debug
hyprctl reload > /tmp/hyprland-debug.log 2>&1
cat /tmp/hyprland-debug.log
```

**Revert Rápido:**
```bash
# Se errou algo
hyprctl reload

# Se quebrou tudo
killall Hyprland  # Sai da sessão
# Faça login novamente
```

---

Divirta-se customizando! 🎉
