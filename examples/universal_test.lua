-- nyxOS: teste universal
-- Cole no executor. Cada parte roda protegida: se algo falhar, o teste continua
-- e mostra no console (F9) exatamente o que quebrou.

local compile = loadstring or load
local URL = "https://raw.githubusercontent.com/btz157/nyxOS/main/dist/nyxOS-beta.lua"

local function log(...)
	print("[nyxOS teste]", ...)
end

-- 1) Baixar a lib (com o cache do GitHub ignorado)
local okHttp, src = pcall(function()
	return game:HttpGet(URL .. "?t=" .. tostring(os.time()))
end)
if not okHttp or type(src) ~= "string" or #src == 0 then
	warn("[nyxOS teste] não consegui baixar a lib: " .. tostring(src))
	return
end

-- 2) Compilar e carregar
local fn, errC = compile(src)
if not fn then
	warn("[nyxOS teste] erro ao compilar a lib: " .. tostring(errC))
	return
end
local okLib, NyxOS = pcall(fn)
if not okLib or type(NyxOS) ~= "table" then
	warn("[nyxOS teste] erro ao iniciar a lib: " .. tostring(NyxOS))
	return
end
log("lib carregada, versão", tostring(NyxOS.Version or "?"))

-- 3) Criar a janela
local okNew, nyx = pcall(NyxOS.new, {
	Title = "nyxOS TESTE",
	Size = Vector2.new(720, 440),
	Keybind = Enum.KeyCode.RightShift,
	Home = {
		Game = { Name = "Meu Jogo", Version = "1.0.0", Desc = "Teste universal da lib." },
		Character = { Name = "Teste", Class = "Guerreiro", Level = 1, Power = 100 },
		Skins = {
			{ Real = true, Name = "Meu avatar", Desc = "Seu avatar real do Roblox." },
			{ Emoji = "🔥", Name = "Neon", Desc = "Brilho verde neon." },
		},
	},
})
if not okNew or not nyx then
	warn("[nyxOS teste] não consegui criar a janela: " .. tostring(nyx))
	return
end

-- 4) Executar cada parte protegida e guardar as falhas
local fails = {}
local function try(label, f, ...)
	local ok, res = pcall(f, ...)
	if not ok then
		table.insert(fails, label .. " -> " .. tostring(res))
		log("FALHA em", label, res)
		return nil
	end
	return res
end

-- Ações
local acoes = try("aba Ações", nyx.Tab, nyx, "Ações", "botões, notificações, terminal", "⚡")
if acoes then
	try("seção Botões", acoes.Section, acoes, "Botões")
	try("Buttons", acoes.Buttons, acoes, {
		{ "Sucesso", function() nyx:Notify("operação concluída", 3, "success") end },
		{ "Aviso", function() nyx:Notify("cuidado", 4, "warn") end },
		{ "Erro", function() nyx:Notify("erro de teste", 4, "error") end },
	})
	local sair = try("Button", acoes.Button, acoes, "Sair do jogo", function()
		nyx:Dialog("Tem certeza?", function() nyx:Notify("confirmado", 2, "success") end,
			function() nyx:Notify("cancelado", 2, "info") end)
	end)
	if sair then
		try("Tooltip", acoes.Tooltip, acoes, sair, "abre uma caixa de confirmação")
	end
	try("seção Terminal", acoes.Section, acoes, "Terminal")
	try("Terminal", acoes.Terminal, acoes, "nyx$", 130, function(txt, logf)
		if txt == "status" then
			logf("sistema ok | fps " .. tostring(nyx:GetFPS()))
		else
			logf("comando desconhecido: " .. txt)
		end
	end)
end

-- Componentes
local comp = try("aba Componentes", nyx.Tab, nyx, "Componentes", "seleção, cores e busca", "🧩")
if comp then
	try("Checklist", comp.Checklist, comp, "Habilidades", { "Velocidade", "Força", "Visão" }, { "Velocidade" },
		function(sel) nyx:Notify("ativas: " .. table.concat(sel, ", "), 2, "info") end)
	try("Palette", comp.Palette, comp, "Cor do brilho", {
		Color3.fromRGB(57, 255, 20), Color3.fromRGB(0, 234, 255), Color3.fromRGB(255, 190, 0),
		Color3.fromRGB(255, 70, 70), Color3.fromRGB(190, 120, 255), Color3.fromRGB(255, 255, 255),
	}, nil, function(_, hex) nyx:Notify("cor " .. tostring(hex), 2, "info") end)
	try("Stepper", comp.Stepper, comp, "Nível", 1, 99, 10, 1, function(v) log("nível", v) end)
	try("Range", comp.Range, comp, "Faixa de dano", 0, 100, 20, 60, function(lo, hi) log("dano", lo, hi) end)
	try("Search", comp.Search, comp, "Buscar item", { "Espada", "Escudo", "Poção", "Mapa", "Chave" },
		function(it) nyx:Notify("item: " .. it, 2, "info") end)
	try("Radio", comp.Radio, comp, "Dificuldade", { "Fácil", "Normal", "Difícil" }, "Normal",
		function(v) nyx:Notify("dificuldade: " .. v, 2, "info") end)
	try("Keybind", comp.Keybind, comp, "Atalho", Enum.KeyCode.F, function() nyx:Notify("tecla F", 2, "nyx") end)
	try("Textbox", comp.Textbox, comp, "Apelido", "digite e aperte Enter", function(txt, enter)
		if enter then nyx:Notify("apelido: " .. txt, 3, "nyx", "PERFIL") end
	end)
	try("Toggle", comp.Toggle, comp, "Modo teste", true, function(on) nyx:Notify("modo " .. tostring(on), 2, "info") end)
	try("Dropdown", comp.Dropdown, comp, "Modo", { "Normal", "Rápido" }, "Normal", function(v) log("modo", v) end)
	try("Slider", comp.Slider, comp, "Velocidade", 1, 10, 5, function(v) log("velocidade", v) end)
	try("Progress", comp.Progress, comp, "Carregamento", 0.2)
end

-- Dados
local dados = try("aba Dados", nyx.Tab, nyx, "Dados", "tabela, gráfico e status", "📊")
if dados then
	try("Table", dados.Table, dados, { "Item", "Qtd", "Preço" }, { { "Espada", "1", "120" }, { "Poção", "5", "15" } })
	local push = try("Sparkline", dados.Sparkline, dados, "Pacotes", 30)
	try("Badge", dados.Badge, dados, "ONLINE", Color3.fromRGB(57, 255, 20))
	try("Spinner", dados.Spinner, dados, "sincronizando...")
	try("History", dados.History, dados, 120)
	if push then
		task.spawn(function()
			while nyx.Gui and nyx.Gui.Parent do
				push(math.random(0, 100))
				task.wait(0.5)
			end
		end)
	end
	local av = try("Collapsible", dados.Collapsible, dados, "Avançado", false)
	if av then
		try("Toggle dentro de Collapsible", av.Toggle, av, "Modo debug", false, function() end)
	end
end

-- Config
local config = try("aba Config", nyx.Tab, nyx, "Config", "ajustes e status", "⚙️")
if config then
	try("Stat", config.Stat, config, "FPS", function() return nyx:GetFPS() end)
	try("KeyValue", config.KeyValue, config, { { "Ping", "--" }, { "Região", "BR" } })
	try("Card", config.Card, config, "Sobre", "Teste universal do nyxOS.")
	try("Image emoji", config.Image, config, "🎮", 120)
	try("Image id", config.Image, config, 0, 80)
end

-- Sistema (preferências salvas)
try("SettingsTab", nyx.SettingsTab, nyx)

-- Resultado
local total = #fails
local msg = total == 0 and "teste universal: tudo funcionou" or ("teste: " .. total .. " falha(s), veja o console")
try("notificação final", nyx.Notify, nyx, msg, 6, total == 0 and "success" or "error")
log("concluído. falhas:", total)
for _, f in ipairs(fails) do
	log(" - " .. f)
end
