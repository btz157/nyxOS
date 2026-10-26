# NyxOS API — build experimental

A distribuição dist/NyxOS.lua é um arquivo único e não depende de Rojo. Rojo é opcional e serve apenas para sincronizar o código modular com Roblox Studio.

> A compatibilidade com executores específicos não foi validada. As assinaturas abaixo refletem a API pretendida do bundle experimental; alguns componentes podem precisar de correções após teste.

## Carregar o bundle
~~~lua
local NyxOS = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/btz157/nyxOS/main/dist/NyxOS.lua"
))()
~~~

Esse método exige que o ambiente permita game:HttpGet e loadstring. Se não permitir, use a instalação modular no Studio ou abra o arquivo single-file e execute-o apenas em um ambiente permitido.

## Criar janela
~~~lua
local window = NyxOS:CreateWindow({
    Title = "NYXOS // TEST",
    Theme = "Matrix", -- Matrix | Neon | Dark | Light
    Size = UDim2.fromOffset(680, 440),
    ToggleKey = Enum.KeyCode.RightControl
})
~~~

## Abas e componentes
~~~lua
local tab = window:CreateTab({Name = "Principal", Icon = "◆"})

tab:AddSection({Name = "TESTES"})
tab:AddLabel({Name = "Interface carregada"})
tab:AddDivider()

tab:AddButton({
    Name = "Notificação",
    Callback = function()
        window:Notify({
            Title = "NyxOS",
            Description = "O callback funcionou!"
        })
    end
})

local toggle = tab:AddToggle({
    Name = "Ativar opção",
    Default = true,
    Callback = function(value) print(value) end
})

local slider = tab:AddSlider({
    Name = "Intensidade",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value) print(value) end
})

local dropdown = tab:AddDropdown({
    Name = "Modo",
    Options = {"Matrix", "Neon", "Dark", "Light"},
    Default = "Matrix",
    Callback = function(value) print(value) end
})

local textbox = tab:AddTextbox({
    Name = "Texto",
    Placeholder = "Digite aqui",
    Callback = function(value, enterPressed)
        print(value, enterPressed)
    end
})

local progress = tab:AddProgressBar({
    Name = "Progresso",
    Min = 0,
    Max = 100,
    Default = 35
})
progress:Set(70)
~~~

## Métodos da janela

- window:CreateTab({Name, Icon})
- window:Notify({Title, Description, Content, Duration})
- window:Destroy()
- window:Close() — alias de Destroy()

## Temas

NyxOS:GetTheme(name) retorna a paleta do tema. Os temas disponíveis são Matrix, Neon, Dark e Light. A troca de tema durante a execução não está implementada no bundle atual; selecione o tema ao criar a janela.

## Rojo é opcional

O fluxo Rojo serve para desenvolvimento da versão modular no Studio. Para testar o bundle single-file, pule a instalação do Rojo e use o trecho de carregamento no início deste documento.

## Limitações conhecidas

- Build experimental; não validado em execução real no Delta.
- Ainda pode haver diferenças entre a API modular e o bundle.
- Redimensionamento e persistência não estão implementados.
- Algumas conexões de input e controles precisam de revisão de ciclo de vida.
