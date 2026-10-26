# NyxOS — distribuição single-file

NyxOS.lua é a build experimental em arquivo único para ambientes que permitam executar Luau e carregar o arquivo. Ela não exige Rojo.

## Teste rápido

~~~lua
local NyxOS = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/btz157/nyxOS/main/dist/NyxOS.lua"
))()

local window = NyxOS:CreateWindow({
    Title = "NYXOS // TEST",
    Theme = "Matrix",
    ToggleKey = Enum.KeyCode.RightControl
})

local tab = window:CreateTab({Name = "Principal"})
tab:AddButton({
    Name = "Testar",
    Callback = function()
        window:Notify({Title = "NyxOS", Description = "Funcionou!"})
    end
})
~~~

O carregamento remoto requer suporte a game:HttpGet e loadstring. O bundle ainda não foi validado ao vivo em executores específicos. Rojo é apenas para desenvolvimento opcional da versão modular no Studio.
