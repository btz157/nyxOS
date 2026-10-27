# nyxOS: referência da API (BETA 2.6.0)

Todos os exemplos assumem que a biblioteca foi carregada assim:

```lua
local NyxOS = loadstring(game:HttpGet("https://raw.githubusercontent.com/btz157/nyxOS/main/dist/nyxOS-beta.lua"))()
```

---

## NyxOS.new(opts)

Cria a janela. Todas as opções são opcionais.

| Opção | Tipo | Padrão | Descrição |
|---|---|---|---|
| `Title` | string | `"nyxOS"` | Texto da barra de título |
| `Size` | Vector2 | `720x440` | Tamanho do painel |
| `Theme` | string | `"neon"` | Tema (`neon`, `amber`, `cyber`, `ice`, `blood`) |
| `Keybind` | KeyCode | `RightShift` | Tecla que minimiza e restaura |
| `Matrix` | boolean | `true` | Liga ou desliga a chuva de fundo |
| `Boot` | boolean | `true` | Mostra a animação de inicialização |
| `Home` | table ou `false` | padrão | Aba Início (jogo, personagem, skins). `false` remove a aba |

Exemplo de `Home`:

```lua
Home = {
	Game = { Name = "Meu Jogo", Version = "1.0.0", Desc = "Descrição curta." },
	Character = { Name = "Meu personagem", Class = "Guerreiro", Level = 1, Power = 100 },
	Skins = {
		{ Real = true, Name = "Meu avatar", Desc = "Seu avatar real do Roblox." },
		{ Emoji = "🔥", Name = "Neon", Desc = "Brilho verde." },
	},
},
```

Skins aceitam `Real = true` (avatar real do jogador), `Emoji = "🔥"` ou `Image = id`.

---

## Janela (objeto retornado por NyxOS.new)

| Método | Descrição |
|---|---|
| `nyx:Tab(nome, descricao?, icone?)` | Cria uma aba. `icone` pode ser emoji ou id de imagem |
| `nyx:Notify(texto, segundos?, tipo?, titulo?)` | Notificação no canto superior direito. `tipo`: `"info"`, `"success"`, `"warn"`, `"error"`, `"nyx"` |
| `nyx:Dialog(mensagem, onSim?, onNao?)` | Caixa de confirmação |
| `nyx:Minimize()` / `nyx:Restore()` | Minimiza para a bolinha e volta |
| `nyx:Close()` | Fecha a janela (pede confirmação ao clicar no X) |
| `nyx:Destroy()` | Remove a interface na hora, sem animação |
| `nyx:SetTheme(nome)` | Troca o tema ao vivo |
| `nyx:SetAvatar(src)` | Troca a foto do cartão. Aceita emoji ou id |
| `nyx:GetFPS()` | Retorna o FPS atual |
| `nyx:Get(chave, padrao)` | Lê uma preferência salva |
| `nyx:Set(chave, valor)` | Salva uma preferência (automático, em `nyxOS_config.json`) |
| `nyx:ResetSettings()` | Apaga as preferências salvas |
| `nyx:SettingsTab()` | Cria uma aba Sistema pronta com as preferências |

---

## Componentes de aba

Cada aba (`nyx:Tab(...)`) aceita estes componentes. Os que retornam algo permitem ler ou atualizar o valor depois.

### Organização

| Componente | Retorno | Descrição |
|---|---|---|
| `tab:Section(nome)` | label | Título de seção |
| `tab:Label(texto)` | label | Texto que quebra linha |
| `tab:Divider()` | frame | Linha separadora |
| `tab:Card(titulo, texto)` | cartão, label | Bloco com título e texto. O label do texto pode ser atualizado |
| `tab:Collapsible(nome, abertoInicial?)` | sub-aba | Seção que abre e fecha. Use os mesmos componentes dentro dela |

### Ações

| Componente | Retorno | Descrição |
|---|---|---|
| `tab:Button(nome, cb)` | botão | Botão |
| `tab:Buttons({ {nome, cb}, ... })` | frame | Vários botões lado a lado |
| `tab:Tooltip(objeto, texto)` | tip | Dica que aparece ao passar o mouse |

### Entrada

| Componente | Retorno | Descrição |
|---|---|---|
| `tab:Toggle(nome, padrao, cb(on))` | `get()` | Liga e desliga |
| `tab:Slider(nome, min, max, padrao, cb(valor))` | `get()` | Barra em quadradinhos (arraste ou clique) |
| `tab:Stepper(nome, min, max, padrao, passo, cb(valor))` | `get()` | Botões `[-]` e `[+]` |
| `tab:Range(nome, min, max, lo, hi, cb(lo, hi))` | `get()` | Intervalo com início e fim |
| `tab:Dropdown(nome, opcoes, padrao, cb(valor))` | `get()` | Lista suspensa |
| `tab:Radio(nome, opcoes, padrao, cb(valor))` | `get()` | Escolha única |
| `tab:Checklist(nome, opcoes, padroes, cb(lista))` | `get()` | Múltipla escolha |
| `tab:Textbox(nome, dica, cb(texto, enter))` | `get()` | Caixa de texto |
| `tab:Keybind(nome, teclaPadrao, onPress)` | `get()` | Troca de tecla (Esc cancela) |
| `tab:Palette(nome, cores, padrao, cb(cor, hex))` | `get()` | Paleta de cores |
| `tab:Search(nome, itens, onPick(item))` | textbox | Busca que filtra a lista |

### Dados e status

| Componente | Retorno | Descrição |
|---|---|---|
| `tab:Progress(nome, inicial)` | `set(0..1)` | Barra de progresso |
| `tab:Stat(nome, fn)` | label | Valor ao vivo (atualiza a cada 0,5 s) |
| `tab:KeyValue(lista)` | `set(chave, valor)` | Ficha de chave e valor |
| `tab:Table(cabecalhos, linhas)` | `set(linhas)` | Tabela |
| `tab:Sparkline(nome, maxN?)` | `push(valor)` | Gráfico de barrinhas |
| `tab:Badge(texto, cor?)` | label | Etiqueta colorida |
| `tab:Spinner(texto)` | label | Indicador girando |
| `tab:Image(src, altura?)` | imagem | Emoji ou id de imagem |
| `tab:History(altura?)` | label | Histórico das notificações |

### Terminal

| Componente | Retorno | Descrição |
|---|---|---|
| `tab:Console(altura?)` | `log(texto)` | Linhas que digitam sozinhas |
| `tab:Terminal(prompt, altura?, cb(texto, log))` | `log` | Caixa de comando com saída |

---

## Dicas

- **Erros nos callbacks** não travam a interface: aparecem como notificação vermelha.
- **Preferências** usam `nyx:Get` e `nyx:Set`. Exemplo:

```lua
main:Toggle("Modo debug", nyx:Get("debug", false), function(on)
	nyx:Set("debug", on)
end)
```

- **Teste** a lib com `examples/universal_test.lua` antes de publicar seu script.
