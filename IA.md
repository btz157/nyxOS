# CONTEXTO DO PROJETO — NyxOS

Manual de contexto para IA. Este arquivo descreve o repositório **real** `btz157/nyxOS` na versão registrada abaixo. Inspecione o código antes de alterar qualquer coisa.

## 1. Regra zero

1. **Não recrie a NyxOS do zero.** Preserve o projeto e suas funcionalidades existentes.
2. Não invente métodos, módulos, propriedades ou componentes. Confirme-os nos arquivos antes de usar.
3. Faça mudanças cirúrgicas. Não reescreva a biblioteca nem mude sua arquitetura sem autorização explícita.
4. Não presuma que a documentação anterior descreve a implementação atual. O código é a fonte de verdade.
5. Não use `wait()`; use `task.wait()` quando for realmente necessário.
6. Antes de alterar um arquivo, leia a versão atual e entenda seus chamadores. Depois, revise os efeitos colaterais.
7. Não declare que algo foi testado no Studio, no Delta ou em outro executor sem ter sido executado de fato nesse ambiente.
8. Preserve APIs antigas quando possível. Se uma alteração incompatível for inevitável, explique antes e proponha alias compatível.
9. Não abra, publique ou solicite tokens, senhas ou segredos.
10. Não adicione dependências, ferramentas de build ou novas pastas sem necessidade comprovada.

## 2. Estado real do repositório

Repositório: https://github.com/btz157/nyxOS

Estrutura confirmada:
```
nyxOS/
├── src/
│   ├── init.lua
│   ├── Themes.lua
│   ├── Window.lua
│   └── Components/
│       ├── init.lua
│       ├── Button.lua
│       ├── Toggle.lua
│       ├── Slider.lua
│       ├── Dropdown.lua
│       ├── Textbox.lua
│       ├── Label.lua
│       ├── Section.lua
│       ├── Divider.lua
│       └── ProgressBar.lua
├── dist/
│   ├── NyxOS.lua
│   └── README.md
├── loader.lua
├── examples/
│   ├── basic.client.lua
│   └── executor-test.lua
├── docs/
│   └── API.md
├── README.md
├── LICENSE
└── IA.md
```

Não substitua essa estrutura pela estrutura hipotética `nyx.lua / Theme.lua / Util.lua / Anim.lua`. Esses arquivos de raiz **não existem** na revisão descrita por este manual. Se precisar criar uma nova pasta, justifique primeiro e mantenha a compatibilidade com a estrutura existente.

## 3. Implementação e versões

Há duas distribuições que não devem ser confundidas:

- **Código modular:** `src/init.lua`, `src/Window.lua`, `src/Themes.lua` e `src/Components/`. O módulo principal exporta `NyxOS.Version = "0.1.0"`.
- **Bundle independente:** `dist/NyxOS.lua`, autodeclarado como `0.2.0-dev`. É um arquivo separado e pode divergir do código modular.
- **Loader:** `loader.lua` baixa `dist/NyxOS.lua`, compila e executa o código em ambientes que forneçam `game:HttpGet` e `loadstring`.

Não afirme que o bundle foi gerado automaticamente a partir de `src/`: não há garantia documentada de que exista um processo determinístico de build. Ao corrigir um bug, determine se a correção precisa ser aplicada ao módulo, ao bundle ou a ambos.

## 4. API modular confirmada

### Módulo principal — `src/init.lua`

O módulo exporta:
- `NyxOS.Version`
- `NyxOS:GetTheme(name)`
- `NyxOS:CreateWindow(options)`
- `NyxOS:Notify(options)` — exige `options.Parent` apontando para um objeto que suporte `Notify`; normalmente prefira `window:Notify(...)`.
- `NyxOS.Themes`

Opções aceitas por `CreateWindow`:
```lua
local NyxOS = require(path.to.src)
local window = NyxOS:CreateWindow({
    Title = "NYXOS // TEST",
    Theme = "Matrix",
    Size = UDim2.fromOffset(680, 450),
    Position = UDim2.fromScale(0.5, 0.5),
    ToggleKey = Enum.KeyCode.RightControl,
    Parent = playerGui,
})
```

`Parent` é opcional; por padrão a janela usa o `PlayerGui` do jogador local. A biblioteca é client-side e a criação da janela deve ocorrer em um contexto de cliente, como um LocalScript em uma experiência autorizada.

### Métodos de janela — `src/Window.lua`

Confirmados:
- `window:CreateTab({Name = "...", Icon = "..."})`
- `window:Notify({Title = "...", Description = "...", Content = "...", Duration = 3})`
- `window:Destroy()`
- `window:Close()` — alias de `Destroy()`

Propriedades públicas usadas no código:
- `window.Gui`
- `window.Root`
- `window.Theme`

A notificação usa `Description` ou `Content`; o padrão de duração é 3,5 segundos. Não presuma que `Type`, `Icon`, `Message` ou duração zero tenham o comportamento do manual antigo sem conferir a implementação.

### Abas e componentes

`window:CreateTab` recebe uma tabela de opções. Os métodos de componentes recebem **tabelas de opções**, não os argumentos posicionais descritos no manual original.

```lua
local tab = window:CreateTab({Name = "Principal", Icon = ">"})

tab:AddSection({Name = "DIAGNOSTICO"})
tab:AddLabel({Name = "SYSTEM ONLINE"})
tab:AddDivider()

tab:AddButton({
    Name = "Executar teste",
    Callback = function()
        window:Notify({
            Title = "NYXOS",
            Description = "Callback executado.",
            Duration = 3,
        })
    end,
})

local toggle = tab:AddToggle({
    Name = "teste",
    Default = false,
    Callback = function(value)
        print("toggle =", value)
    end,
})

local slider = tab:AddSlider({
    Name = "speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("speed =", value)
    end,
})

local dropdown = tab:AddDropdown({
    Name = "mode",
    Options = {"a", "b", "c"},
    Default = "a",
    Callback = function(value)
        print("mode =", value)
    end,
})

local textbox = tab:AddTextbox({
    Name = "input",
    Placeholder = "digite aqui",
    Callback = function(value, enterPressed)
        print(value, enterPressed)
    end,
})

local progress = tab:AddProgressBar({
    Name = "progress",
    Min = 0,
    Max = 100,
    Default = 35,
})
```

Métodos registrados pela implementação atual:
- `AddButton(options)`
- `AddLabel(options)`
- `AddToggle(options)`
- `AddSlider(options)`
- `AddTextbox(options)`
- `AddDropdown(options)`
- `AddSection(options)`
- `AddDivider(options)`
- `AddProgressBar(options)`

Os retornos variam por componente. Inspecione o módulo correspondente antes de usar um handle programaticamente. O toggle e o slider retornam handles com métodos, mas as assinaturas de `Set` não são uniformes; confirme a assinatura real e não prometa que setters são intercambiáveis. O ProgressBar retorna `Get` e `Set`, mas seu `Set` é definido para chamada com self, por exemplo `progress:Set(70)`.

**Não existem, na API modular confirmada:**
- `app:AddTab(name)` com argumento de texto simples.
- `app:SetStatus(text)` ou `app:SetStatusTyped(text)`.
- `app:ShowAuthorMessages()`.
- `tab:AddInput(...)` — o nome real é `tab:AddTextbox(options)`.
- `tab:AddConsole()` ou um handle `Log/Clear`.
- `Nyx.new({...})` como método da API modular atual.
- módulos de raiz `Util.lua` e `Anim.lua`.

Não use nenhum desses nomes a menos que sejam implementados explicitamente e documentados em uma mudança autorizada.

## 5. Temas reais

Arquivo: `src/Themes.lua`.

Temas registrados: `Matrix`, `Neon`, `Dark`, `Light`. Cada paleta atualmente contém:
- `Name`
- `Background`
- `Surface`
- `SurfaceHover`
- `Primary`
- `Secondary`
- `Text`
- `MutedText`
- `Border`
- `Danger`
- `Success`

Acesso: `NyxOS:GetTheme("Matrix")` ou `NyxOS.Themes.Get("Matrix")`.

Não invente chaves como `Accent`, `AccentDim`, `Font`, `CornerRadius` ou `Padding`: elas não fazem parte da paleta modular confirmada. Não adicione cores hardcoded a um componente novo; use a paleta recebida pelo componente. Se uma chave de tema realmente faltar, proponha a mudança em `src/Themes.lua` e ajuste os consumidores.

## 6. Util e Anim — divergência documentada

O manual original descrevia `Util.create`, `Util.corner`, `Util.stroke`, `Util.draggable`, `Anim.tween`, `Anim.enterWindow`, `Anim.fadeIn` e outros helpers. **Esses módulos não existem na estrutura atual confirmada.**

A implementação atual usa chamadas diretas a `Instance.new` em `src/Window.lua` e nos componentes, e alguns componentes chamam `TweenService:Create` diretamente. Isso é um fato sobre o código existente, não uma autorização para replicar o padrão indefinidamente.

Ao criar um componente:
1. Primeiro procure helpers reutilizáveis que realmente existam.
2. Não escreva `require(...Util)` ou `require(...Anim)` enquanto esses arquivos não existirem.
3. Para uma mudança pequena, siga o padrão real do componente vizinho e mantenha o escopo limitado.
4. Para introduzir uma camada comum de criação/animação, apresente a proposta antes; ela precisa ser integrada e testada no código modular e, se aplicável, no bundle.
5. Não declare que o componente cumpre uma camada `Anim` inexistente.

## 7. Estilo visual e animação

A direção desejada para a evolução da NyxOS é **terminal/hacker**, com:
- fonte monoespaçada, preferencialmente `Enum.Font.Code` em novos componentes quando consistente com o layout;
- verde Matrix como cor principal quando o tema Matrix estiver selecionado;
- bordas retas ou discretas;
- prefixos de terminal como `> `, `[x]`, `[ ]`, `//` e `┌─`;
- microanimações rápidas e funcionais, sem bounce exagerado;
- feedback visível para ações, como notificação, alteração de estado ou callback.

A UI atual ainda usa fontes Gotham, cantos arredondados e estilos diferentes em alguns componentes. Não finja que o estilo terminal já está implementado por completo. Ao modernizar, faça alterações graduais e preserve os temas existentes, a menos que o usuário peça uma mudança maior.

Não use emoji na UI nova; prefira símbolos técnicos. Não altere globalmente a aparência nem remova temas sem autorização.

## 8. Regras de implementação

- Não usar `wait()`; usar `task.wait()` quando necessário.
- Não criar outra janela/ScreenGui para contornar a API. Use a janela e a aba fornecidas pela NyxOS.
- Não adicionar loops infinitos sem yield e sem motivo.
- Tratar callbacks de forma segura com `pcall`, mantendo o estilo dos componentes existentes.
- Evitar conexões globais sem desconexão. Ao adicionar eventos, considerar o ciclo de vida e destruição da janela/componente.
- Respeitar as chaves e os tipos de opções já usados.
- Não misturar alteração da API, redesenho visual e refatoração ampla numa única mudança sem necessidade.
- Não copie um componente inteiro para criar uma variante duplicada; extraia lógica comum apenas com escopo e compatibilidade bem definidos.
- Não altere arquivos gerados/independentes como se fossem automaticamente sincronizados com `src/`.

## 9. Teste e validação

Exemplos disponíveis:
- `examples/basic.client.lua`: exemplo modular para uso com ModuleScript em uma experiência de teste no Roblox Studio.
- `examples/executor-test.lua`: smoke test do bundle independente em ambiente que permita `game:HttpGet` e `loadstring`.
- `dist/NyxOS.lua`: runtime single-file experimental.
- `loader.lua`: loader remoto do bundle.

Ao concluir uma tarefa:
1. Faça uma leitura estática do diff e confirme nomes/assinaturas com os módulos existentes.
2. Verifique se a documentação e os exemplos continuam coerentes.
3. Identifique qual artefato foi alterado: modular, bundle ou ambos.
4. Registre explicitamente testes executados e não executados.
5. Nunca alegue compatibilidade real com Delta ou outro executor sem teste observado.
6. Se o usuário reportar um erro, peça ou use o erro exato e corrija a causa; não reconstrua tudo.

O caminho single-file não exige Rojo, mas requer suporte do ambiente a `game:HttpGet` e `loadstring`. A versão modular é para desenvolvimento em uma experiência Roblox autorizada. Não contorne proteções da plataforma.

## 10. Formato de resposta para tarefas de código

Para uma mudança de código, responda de forma curta e objetiva:
1. Arquivo(s) alterado(s).
2. Código completo quando o usuário pedir código para copiar; nunca use comentários como "resto aqui" no lugar de partes necessárias.
3. Como testar, usando APIs confirmadas.
4. O que mudou.
5. Estado real da validação: estático, Studio, executor ou não testado.

Não crie arquivos ou componentes adicionais apenas para preencher um formato. Se a tarefa for alterar diretamente o repositório, faça a alteração solicitada e forneça o link do commit/arquivo.

## 11. CHANGELOG

### 0.2.0-dev — contexto documental
- Criado este manual adaptado à estrutura real do repositório.
- Documentada a diferença entre implementação modular 0.1.0 e bundle single-file 0.2.0-dev.
- Documentadas as APIs confirmadas e as diferenças em relação ao manual original.
- Validação: leitura dos arquivos no GitHub; nenhuma execução ao vivo no Roblox Studio ou Delta foi realizada como parte desta documentação.

### Estado conhecido
- O bundle e a API modular podem divergir.
- Os módulos `Util.lua` e `Anim.lua` não existem na estrutura atual descrita.
- A compatibilidade com executores específicos não foi verificada.
