local NyxOS = loadstring(game:HttpGet("https://raw.githubusercontent.com/btz157/nyxOS/main/dist/nyxOS-beta.lua"))()

local nyx = NyxOS.new({
	Title = "nyxOS TESTE",
	Size = Vector2.new(560, 380),
	Theme = "neon",
	Keybind = Enum.KeyCode.RightShift,
})

local acoes = nyx:Tab("Ações")
acoes:Section("Teste rápido")
acoes:Button("Executar", function()
	nyx:Notify("comando executado com sucesso")
end)
acoes:Button("Dizer olá", function()
	nyx:Notify("olá, bem-vindo ao nyxOS", 3)
end)
acoes:Button("Aviso", function()
	nyx:Notify("cuidado: ação pesada", 4, "warn")
end)
acoes:Button("Erro simulado", function()
	nyx:Notify("módulo não encontrado", 4, "error")
end)

local opcoes = nyx:Tab("Opções")
opcoes:Section("Jogador")
opcoes:Toggle("Godmode", false, function(on)
	nyx:Notify("godmode " .. (on and "ativado" or "desativado"))
end)
opcoes:Toggle("Voo", false, function(on)
	nyx:Notify("voo " .. (on and "ligado" or "desligado"), 2)
end)
opcoes:Toggle("ESP", true, function(on)
	nyx:Notify("ESP " .. (on and "ligado" or "desligado"), 2)
end)

local config = nyx:Tab("Config")
config:Section("Ajustes")
config:Slider("Velocidade", 1, 10, 5, function(v)
	print("velocidade:", v)
end)
config:Slider("Volume", 0, 100, 50, function(v)
	print("volume:", v)
end)
config:Slider("Raio", 1, 50, 10, function(v)
	print("raio:", v)
end)
