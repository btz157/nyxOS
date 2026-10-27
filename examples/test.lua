local NyxOS = loadstring(game:HttpGet("https://raw.githubusercontent.com/btz157/nyxOS/main/dist/nyxOS-beta.lua"))()

local nyx = NyxOS.new({
	Title = "nyxOS",
	Size = Vector2.new(720, 440),
	Keybind = Enum.KeyCode.RightShift,
	Home = {
		Game = { Name = "Meu Jogo", Version = "1.0.0", Desc = "Descrição do seu jogo aqui." },
		Character = { Name = "Seu personagem", Class = "Guerreiro", Level = 12, Power = 340 },
		Skins = {
			{ Real = true, Name = "Meu avatar", Desc = "Seu avatar real do Roblox." },
			{ Emoji = "🟢", Name = "Padrão", Desc = "Skin inicial." },
			{ Emoji = "🔥", Name = "Neon", Desc = "Brilho verde neon nas bordas." },
			{ Emoji = "🌑", Name = "Sombra", Desc = "Silhueta escura com rastro de dados." },
		},
	},
})

local acoes = nyx:Tab("Ações", "botões, notificações, terminal", "⚡")
acoes:Section("Botões")
acoes:Buttons({
	{ "Sucesso", function() nyx:Notify("operação concluída", 3, "success") end },
	{ "Aviso", function() nyx:Notify("cuidado: ação pesada", 4, "warn") end },
	{ "Erro", function() nyx:Notify("módulo não encontrado", 4, "error") end },
})
local sair = acoes:Button("Sair do jogo", function()
	nyx:Dialog("Tem certeza que quer continuar?", function()
		nyx:Notify("confirmado", 2, "success")
	end, function()
		nyx:Notify("cancelado", 2, "info")
	end)
end)
acoes:Tooltip(sair, "abre uma caixa de confirmação")

acoes:Section("Terminal")
acoes:Terminal("nyx$", 130, function(txt, log)
	if txt == "ajuda" then
		log("comandos: ajuda, status")
	elseif txt == "status" then
		log("sistema ok | fps " .. nyx:GetFPS())
	else
		log("comando desconhecido: " .. txt)
	end
end)

local comp = nyx:Tab("Componentes", "seleção, cores e busca", "🧩")
comp:Checklist("Habilidades", { "Velocidade", "Força", "Visão" }, { "Velocidade" }, function(sel)
	nyx:Notify("ativas: " .. table.concat(sel, ", "), 2, "info")
end)
comp:Palette("Cor do brilho", {
	Color3.fromRGB(57, 255, 20),
	Color3.fromRGB(0, 234, 255),
	Color3.fromRGB(255, 190, 0),
	Color3.fromRGB(255, 70, 70),
	Color3.fromRGB(190, 120, 255),
	Color3.fromRGB(255, 255, 255),
}, nil, function(col, hex)
	nyx:Notify("cor " .. hex, 2, "info")
end)
comp:Stepper("Nível", 1, 99, 10, 1, function(v) print("nível:", v) end)
comp:Range("Faixa de dano", 0, 100, 20, 60, function(lo, hi) print("dano:", lo, hi) end)
comp:Search("Buscar item", { "Espada", "Escudo", "Poção", "Mapa", "Chave" }, function(it)
	nyx:Notify("item: " .. it, 2, "info")
end)
comp:Radio("Dificuldade", { "Fácil", "Normal", "Difícil" }, "Normal", function(v)
	nyx:Notify("dificuldade: " .. v, 2, "info")
end)
comp:Keybind("Atalho", Enum.KeyCode.F, function()
	nyx:Notify("tecla F pressionada", 2, "nyx")
end)
comp:Textbox("Apelido", "digite e aperte Enter", function(txt, enter)
	if enter then
		nyx:Notify("apelido: " .. txt, 3, "nyx", "PERFIL")
	end
end)

local dados = nyx:Tab("Dados", "tabela, gráfico e status", "📊")
dados:Table({ "Item", "Qtd", "Preço" }, {
	{ "Espada", "1", "120" },
	{ "Poção", "5", "15" },
	{ "Chave", "2", "0" },
})
dados:Section("Tempo real")
local push = dados:Sparkline("Pacotes", 30)
dados:Badge("ONLINE", Color3.fromRGB(57, 255, 20))
dados:Spinner("sincronizando...")
dados:History(120)
task.spawn(function()
	while nyx.Gui.Parent do
		push(math.random(0, 100))
		task.wait(0.5)
	end
end)
local avancado = dados:Collapsible("Avançado", false)
avancado:Toggle("Modo debug", false, function(on)
	nyx:Notify("debug " .. (on and "ligado" or "desligado"), 2, "info")
end)
avancado:Stepper("Limite", 0, 10, 3, 1)

local config = nyx:Tab("Config", "ajustes e status", "⚙️")
config:Stat("FPS", function() return nyx:GetFPS() end)
config:KeyValue({
	{ "Ping", "--" },
	{ "Jogadores", 0 },
	{ "Região", "BR" },
})
config:Card("Sobre", "nyxOS é uma biblioteca de interface com tema Matrix.")
config:Image("🎮", 120)
config:Slider("Velocidade", 1, 10, 5, function(v) print("velocidade:", v) end)
local progSet = config:Progress("Carregamento", 0.2)
local cur = 0.2
config:Button("Avançar 10%", function()
	cur = math.min(1, cur + 0.1)
	progSet(cur, true)
end)
nyx:SettingsTab()
