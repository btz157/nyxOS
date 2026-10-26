-- NYXOS // QUICK TEST
-- Teste visual do bundle single-file. Requer ambiente com game:HttpGet e loadstring.
-- Use apenas em experiências/ambientes nos quais você tem autorização.

local URL = "https://raw.githubusercontent.com/btz157/nyxOS/main/dist/NyxOS.lua"

local loaded, NyxOS = pcall(function()
    local source = game:HttpGet(URL)
    assert(type(source) == "string" and #source > 1000, "Não foi possível baixar dist/NyxOS.lua")

    local compiler = loadstring
    assert(type(compiler) == "function", "Este ambiente não oferece loadstring")

    local chunk, compileError = compiler(source)
    assert(chunk, tostring(compileError or "Erro ao compilar NyxOS"))
    return chunk()
end)

if not loaded then
    warn("[NYXOS TEST] FALHA AO CARREGAR: " .. tostring(NyxOS))
    return
end

if type(NyxOS) ~= "table" or type(NyxOS.CreateWindow) ~= "function" then
    warn("[NYXOS TEST] O bundle não retornou a API esperada.")
    return
end

local created, window = pcall(function()
    return NyxOS:CreateWindow({
        Title = "NYXOS // QUICK TEST",
        Theme = "Matrix",
        Size = UDim2.fromOffset(680, 450),
        ToggleKey = Enum.KeyCode.RightControl,
    })
end)

if not created or not window then
    warn("[NYXOS TEST] FALHA AO CRIAR JANELA: " .. tostring(window))
    return
end

local ok, err = pcall(function()
    local home = window:CreateTab({Name = "HOME", Icon = ">"})
    local ui = window:CreateTab({Name = "UI TEST", Icon = "#"})

    home:AddSection({Name = "STATUS"})
    home:AddLabel({Name = "NyxOS carregada. Teste os controles abaixo."})
    home:AddButton({
        Name = "[>] TESTAR NOTIFICAÇÃO",
        Callback = function()
            window:Notify({
                Title = "TESTE OK",
                Description = "A janela e o callback do botão estão funcionando.",
                Duration = 3,
            })
        end,
    })
    home:AddButton({
        Name = "[x] LIMPAR / FECHAR",
        Callback = function()
            window:Destroy()
        end,
    })
    home:AddToggle({
        Name = "Toggle de diagnóstico",
        Default = true,
        Callback = function(value)
            print("[NYXOS TEST] Toggle:", value)
        end,
    })

    ui:AddSection({Name = "COMPONENTES"})
    ui:AddDropdown({
        Name = "Escolher opção",
        Options = {"Matrix", "Neon", "Dark", "Light"},
        Default = "Matrix",
        Callback = function(value)
            print("[NYXOS TEST] Dropdown:", value)
            window:Notify({
                Title = "OPÇÃO SELECIONADA",
                Description = tostring(value),
            })
        end,
    })
    ui:AddSlider({
        Name = "Slider (0–100)",
        Min = 0,
        Max = 100,
        Default = 50,
        Callback = function(value)
            print("[NYXOS TEST] Slider:", value)
        end,
    })
    ui:AddTextbox({
        Name = "Caixa de texto",
        Placeholder = "Digite e pressione Enter",
        Callback = function(value, enterPressed)
            print("[NYXOS TEST] Texto:", value, "Enter:", enterPressed)
        end,
    })
    ui:AddProgressBar({
        Name = "Barra demonstrativa",
        Min = 0,
        Max = 100,
        Default = 65,
    })
    ui:AddDivider()
    ui:AddLabel({Name = "Use RightControl para alternar a janela."})
end)

if not ok then
    warn("[NYXOS TEST] ERRO AO MONTAR OS COMPONENTES: " .. tostring(err))
    pcall(function() window:Destroy() end)
    return
end

pcall(function()
    window:Notify({
        Title = "NYXOS // QUICK TEST",
        Description = "Carregamento concluído. Abra a aba UI TEST.",
        Duration = 4,
    })
end)

print("[NYXOS TEST] Inicialização concluída. Teste abas, botão, toggle, dropdown, slider e textbox.")
