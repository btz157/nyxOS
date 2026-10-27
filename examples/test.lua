local NyxOS = loadstring(game:HttpGet("https://raw.githubusercontent.com/btz157/nyxOS/main/loader.lua"))()

local nyx = NyxOS.new({
	Title = "nyxOS",
	Size = Vector2.new(620, 410),
	Keybind = Enum.KeyCode.RightShift,
	Home = {
		Game = { Name = "Meu Jogo", Version = "1.0.0", Desc = "Descrição do seu jogo aqui." },
		Character = { Name = "Seu personagem", Class = "Guerreiro", Level = 12, Power = 340 },
		Skins = {
			{ Name = "Padrão", Rarity = "Comum", Desc = "Skin inicial." },
			{ Name = "Neon", Rarity = "Rara", Desc = "Brilho verde neon nas bordas." },
			{ Name = "Sombra", Rarity = "Épica", Desc = "Silhueta escura com rastro de dados." },
		},
	},
})

local acoes = nyx:Tab("Ações", "botões, notificações e console")
acoes:Section("Notificações")
acoes:Button("Sucesso", function()
	nyx:Notify("operação concluída com sucesso", 3, "success")
end)
acoes:Button("Info", function()
	nyx:Notify("esta é uma informação do sistema", 3, "info")
end)
acoes:Button("Aviso", function()
	nyx:Notify("cuidado: ação pesada em andamento", 4, "warn")
end)
acoes:Button("Erro", function()
	nyx:Notify("módulo não encontrado", 4, "error")
end)
acoes:Button("nyxOS", function()
	nyx:Notify("bem-vindo ao núcleo nyxOS", 4, "nyx")
end)
acoes:Section("Console")
local log = acoes:Console(140)
log("sistema iniciado")
log("carregando módulos... ok")
acoes:Button("Registrar evento", function()
	log("evento disparado em " .. os.date("%H:%M:%S"))
end)

local opcoes = nyx:Tab("Opções", "ligue e desligue recursos")
opcoes:Section("Jogador")
opcoes:Toggle("Godmode", false, function(on)
	nyx:Notify("godmode " .. (on and "ativado" or "desativado"), 2, on and "success" or "info")
end)
opcoes:Toggle("Voo", false, function(on)
	nyx:Notify("voo " .. (on and "ligado" or "desligado"), 2, "info")
end)
opcoes:Keybind("Atalho", Enum.KeyCode.F, function()
	nyx:Notify("tecla F pressionada", 2, "nyx")
end)
opcoes:Section("Perfil")
opcoes:Textbox("Apelido", "digite e aperte Enter", function(txt, enter)
	if enter then
		nyx:Notify("apelido definido: " .. txt, 3, "nyx", "PERFIL")
	end
end)
opcoes:Dropdown("Modo", { "Normal", "Rápido", "Silencioso" }, "Normal", function(v)
	nyx:Notify("modo: " .. v, 2, "info")
end)

local config = nyx:Tab("Config", "ajustes e status")
config:Section("Status ao vivo")
config:Stat("FPS", function()
	return nyx:GetFPS()
end)
config:Section("Ajustes")
config:Slider("Velocidade", 1, 10, 5, function(v)
	print("velocidade:", v)
end)
local progSet = config:Progress("Carregamento", 0.2)
local cur = 0.2
config:Button("Avançar 10%", function()
	cur = math.min(1, cur + 0.1)
	progSet(cur, true)
end)
