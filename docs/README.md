# nyxOS

Biblioteca de UI em Luau, tema Matrix/neon.

## Carregar

local NyxOS = loadstring(game:HttpGet("https://raw.githubusercontent.com/btz157/nyxOS/main/loader.lua"))()

## API

- NyxOS.new({ Title, Size, Theme = "neon" | "amber", Keybind, Boot })
- nyx:Tab(nome): aba na lateral esquerda
- tab:Section(nome), tab:Button(nome, cb), tab:Toggle(nome, padrão, cb), tab:Slider(nome, min, max, padrão, cb)
- nyx:Notify(texto, segundos)
- nyx:Minimize() / nyx:Restore() / nyx:Destroy()

## Estrutura

- loader.lua: ponto de entrada (uma linha para carregar tudo)
- src/init.lua: junta os módulos
- src/core/: util, effects (Matrix, boot), window (janela, bolinha, notificações)
- src/components/: tab (abas, botões, toggles, sliders)
- src/themes/: neon, amber
- examples/: exemplos de uso
