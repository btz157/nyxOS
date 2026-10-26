-- NYXOS // EXECUTOR TEST
-- Build experimental: this file is a smoke test, not a stable release.
-- Uses the single-file runtime; no Rojo or Roblox Studio project setup required.
-- Requires an environment that permits game:HttpGet and loadstring.

local ok, NyxOS = pcall(function()
    local source = game:HttpGet(
        "https://raw.githubusercontent.com/btz157/nyxOS/main/dist/NyxOS.lua"
    )
    assert(type(source) == "string" and #source > 1000, "Bundle vazio ou indisponível")
    local compile = loadstring
    assert(type(compile) == "function", "loadstring não está disponível neste ambiente")
    local chunk, compileError = compile(source)
    assert(chunk, compileError or "Falha ao compilar o bundle")
    return chunk()
end)

if not ok or type(NyxOS) ~= "table" then
    warn("[NyxOS TEST] Não foi possível carregar a biblioteca:", NyxOS)
    return
end

local created, window = pcall(function()
    return NyxOS:CreateWindow({
        Title = "NYXOS // TEST LAB",
        Theme = "Matrix",
        Size = UDim2.fromOffset(680, 460),
        ToggleKey = Enum.KeyCode.RightControl
    })
end)

if not created or not window then
    warn("[NyxOS TEST] Falha ao criar a janela:", window)
    return
end

local main = window:CreateTab({Name = "Principal", Icon = "◆"})
local visuals = window:CreateTab({Name = "Visuais", Icon = "✦"})
local controls = window:CreateTab({Name = "Controles", Icon = "⚙"})

main:AddSection({Name = "DIAGNÓSTICO"})
main:AddLabel({Name = "NYXOS // Teste da interface"})
main:AddButton({
    Name = "Testar notificação",
    Callback = function()
        window:Notify({
            Title = "NYXOS // OK",
            Description = "O callback da notificação foi chamado."
        })
    end
})
main:AddButton({
    Name = "Testar callback",
    Callback = function()
        print("[NyxOS TEST] Callback de botão OK")
    end
})
main:AddToggle({
    Name = "Toggle de teste",
    Default = true,
    Callback = function(value)
        print("[NyxOS TEST] Toggle:", value)
    end
})

visuals:AddSection({Name = "CONTROLES VISUAIS"})
visuals:AddDropdown({
    Name = "Selecionar tema",
    Options = {"Matrix", "Neon", "Dark", "Light"},
    Default = "Matrix",
    Callback = function(value)
        print("[NyxOS TEST] Tema escolhido:", value)
        window:Notify({
            Title = "Seleção",
            Description = "Escolhido: " .. tostring(value)
        })
    end
})
visuals:AddSlider({
    Name = "Slider de teste",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("[NyxOS TEST] Slider:", value)
    end
})
visuals:AddProgressBar({
    Name = "Barra de progresso",
    Min = 0,
    Max = 100,
    Default = 35
})
visuals:AddDivider()
visuals:AddButton({
    Name = "Notificação de alerta",
    Callback = function()
        window:Notify({
            Title = "NYXOS // ALERTA",
            Description = "Teste de notificação concluído."
        })
    end
})

controls:AddSection({Name = "ENTRADAS"})
controls:AddTextbox({
    Name = "Caixa de texto",
    Placeholder = "Digite e pressione Enter",
    Callback = function(value, enterPressed)
        print("[NyxOS TEST] Texto:", value, "Enter:", enterPressed)
    end
})
controls:AddButton({
    Name = "Executar diagnóstico",
    Callback = function()
        for _, name in ipairs({
            "Inicialização",
            "Abas",
            "Callbacks",
            "Componentes"
        }) do
            print("[NyxOS TEST] " .. name .. " — verificação manual")
        end
        window:Notify({
            Title = "DIAGNÓSTICO",
            Description = "Confira os componentes e o console."
        })
    end
})
controls:AddLabel({Name = "RightControl: alternar janela"})

window:Notify({
    Title = "NYXOS // TEST LAB",
    Description = "Bundle carregado. Teste cada aba."
})
print("[NyxOS TEST] Inicialização concluída.")
