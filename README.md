# nyxOS (BETA 2.6.0)

Biblioteca de interface para Roblox (executores), com estilo hacker/terminal e tema Matrix.

> **Versão BETA:** ainda em testes. Pode ter erros e mudar sem aviso.
> Se encontrar algo errado, abra uma issue no GitHub ou me avise.

## Como usar (um script só)

```lua
local NyxOS = loadstring(game:HttpGet("https://raw.githubusercontent.com/btz157/nyxOS/main/dist/nyxOS-beta.lua"))()

local nyx = NyxOS.new({ Title = "Meu script", Size = Vector2.new(720, 440) })

local main = nyx:Tab("Início", "exemplo", "🏠")
main:Section("Ações")
main:Button("Olá", function()
	nyx:Notify("olá!", 3, "success")
end)
```

Comece pelo modelo `examples/starter.lua`. Referência completa de todos os métodos e opções em [docs/API.md](docs/API.md).

Outros exemplos: `examples/test.lua` (teste visual) e `examples/universal_test.lua` (teste com diagnóstico de erros).

## Opções principais

| Opção | Padrão | Descrição |
|---|---|---|
| `Title` | `"nyxOS"` | Título da janela |
| `Size` | `720x440` | Tamanho do painel |
| `Keybind` | `RightShift` | Tecla que minimiza/restaura |
| `Matrix` | `true` | Liga/desliga a chuva de fundo |
| `Boot` | `true` | Mostra a animação de inicialização |
| `Home` | padrão | Dados da aba Início (jogo, personagem, skins) |

Preferências salvas automaticamente: `nyx:Get(chave, padrão)` e `nyx:Set(chave, valor)`. Use `nyx:SettingsTab()` para uma aba de configurações pronta.

## Componentes

Section, Label, Divider, Button, Buttons, Toggle, Checklist, Radio, Dropdown, Search, Textbox, Keybind, Slider, Range, Stepper, Progress, Palette, Table, Sparkline, Badge, Spinner, Card, Stats/KeyValue, Stat, Image, Console, Terminal, History, Collapsible, Tooltip.

## Desenvolvimento

O código fonte está em `src/`. Para gerar o arquivo único:

    node tools/build.js .

Verificações: `node tools/check-syntax.js .` e `node tools/check-globals.js .`

## Licença

Uso livre para testes e scripts pessoais.
