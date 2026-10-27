local NyxOS = loadstring(game:HttpGet("https://raw.githubusercontent.com/btz157/nyxOS/main/loader.lua"))()

local nyx = NyxOS.new({ Title = "nyxOS", Size = Vector2.new(560, 380), Theme = "neon" })

local main = nyx:Tab("Principal")
main:Section("Sistema")
main:Button("Executar", function()
	nyx:Notify("acesso concedido")
end)
main:Toggle("Godmode", false, function(on)
	print("godmode:", on)
end)

local config = nyx:Tab("Config")
config:Slider("Velocidade", 1, 10, 5, function(v)
	print("velocidade:", v)
end)
