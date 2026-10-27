local req = ...
local U = req("src/core/util")
local E = req("src/core/effects")
local Screen = req("src/core/screen")
local Tab = req("src/components/tab")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Window = {}
Window.__index = Window

local BOOT_LINES = {
	"kernel nyxOS iniciado",
	"montando interface",
	"carregando módulos",
	"sincronizando matriz",
	"sistema pronto",
}

local KINDS = {
	info = { tag = "INFO", title = "INFO" },
	success = { tag = "OK", title = "SUCESSO", color = Color3.fromRGB(57, 255, 20) },
	warn = { tag = "!", title = "ATENÇÃO", color = Color3.fromRGB(255, 190, 0) },
	error = { tag = "X", title = "ERRO", color = Color3.fromRGB(255, 70, 70) },
	nyx = { tag = "NYX", title = "NYXOS", color = Color3.fromRGB(0, 234, 255) },
}

local DEFAULT_HOME = {
	Game = { Name = "Nome do jogo", Version = "1.0.0", Desc = "Descrição curta do seu jogo. Edite em opts.Home." },
	Character = { Name = "Seu personagem", Class = "Classe", Level = 1, Power = 100 },
	Skins = {
		{ Real = true, Name = "Meu avatar", Desc = "Seu avatar real do Roblox." },
		{ Emoji = "🟢", Name = "Padrão", Desc = "Skin inicial do personagem." },
		{ Emoji = "🔥", Name = "Neon", Desc = "Brilho verde neon nas bordas." },
		{ Emoji = "🌑", Name = "Sombra", Desc = "Silhueta escura com rastro de dados." },
	},
}

local TOP, FOOT, SIDE_W, HEAD_H = 30, 22, 184, 46
local BUBBLE_POS = UDim2.fromOffset(12, 64)
local BUBBLE_CENTER = { 37, 89 }

local function loadTheme(name)
	local ok, T = pcall(req, "src/themes/" .. (name or "neon"))
	if ok and T then
		return T
	end
	return req("src/themes/neon")
end

-- Cantoneiras nos quatro cantos do painel (estilo terminal)
local function corners(parent, T)
	for _, c in ipairs({ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } }) do
		local ax, ay = c[1], c[2]
		local px = ax == 0 and 3 or -3
		local py = ay == 0 and 3 or -3
		U.paint(U.make("Frame", {
			AnchorPoint = Vector2.new(ax, ay),
			Position = UDim2.new(ax, px, ay, py),
			Size = UDim2.fromOffset(14, 2),
			BorderSizePixel = 0,
			ZIndex = 7,
		}, parent), "BackgroundColor3", "Accent")
		U.paint(U.make("Frame", {
			AnchorPoint = Vector2.new(ax, ay),
			Position = UDim2.new(ax, px, ay, py),
			Size = UDim2.fromOffset(2, 14),
			BorderSizePixel = 0,
			ZIndex = 7,
		}, parent), "BackgroundColor3", "Accent")
	end
end

function Window.new(opts)
	-- Remove instâncias antigas (evita chuva "fantasma" de execuções anteriores)
	local env = (getgenv and getgenv()) or _G
	if env.__nyxos_active then
		pcall(function()
			env.__nyxos_active:Destroy()
		end)
		env.__nyxos_active = nil
	end
	do
		local okP, pg = pcall(function()
			return (gethui and gethui()) or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		end)
		if okP and pg then
			for _, g in ipairs(pg:GetChildren()) do
				if g:IsA("ScreenGui") and string.sub(g.Name, 1, 5) == "nyxOS" then
					g:Destroy()
				end
			end
		end
	end
	opts = opts or {}
	local T = loadTheme(opts.Theme)
	local self = setmetatable({}, Window)
	self.Theme = T
	self.Screen = Screen.new(T, Window._matrixOpt(opts, self))
	self.Gui = self.Screen.Main
	self._conns = {}
	self._refresh = {}
	self._tabs = {}
	self._active = nil
	self._toastN = 0
	self.Visible = true

	-- contador de FPS
	do
		local frames, last = 0, os.clock()
		table.insert(self._conns, RunService.Heartbeat:Connect(function()
			frames += 1
			local now = os.clock()
			if now - last >= 1 then
				self._fps = frames / (now - last)
				frames = 0
				last = now
			end
		end))
	end

	local size = opts.Size or Vector2.new(720, 440)
	local W, H = size.X, size.Y
	self.Size = UDim2.fromOffset(W, H)
	local cam = workspace.CurrentCamera or workspace:WaitForChild("CurrentCamera")
	self.Center = UDim2.fromOffset(math.floor(cam.ViewportSize.X / 2 - W / 2), math.floor(cam.ViewportSize.Y / 2 - H / 2))

	-- Painel: preto, borda neon, moldura interna e cantoneiras
	local win = U.paint(U.make("Frame", {
		Name = "Window",
		Size = UDim2.fromOffset(W, 2),
		Position = self.Center,
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, self.Gui), "BackgroundColor3", "Black")
	self._winStroke = U.paint(U.stroke(win, T.Accent, 1.5), "Color", "Accent")
	self.Window = win
local bgf = U.make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }, win); U.make("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(0, 26, 10), Color3.fromRGB(0, 0, 0)), Rotation = 90 }, bgf)
	U.paint(U.stroke(U.make("Frame", {
		Size = UDim2.new(1, -8, 1, -8),
		Position = UDim2.fromOffset(4, 4),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, win), T.Dim, 1), "Color", "Dim")
	corners(win, T)
	TweenService:Create(win, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = self.Size,
	}):Play()

	-- Barra de título
	local bar = U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, TOP),
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, win), "BackgroundColor3", "Black")
	U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = T.Accent,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, bar), "BackgroundColor3", "Accent")
	for i, key in ipairs({ "Accent", "Dim", "Dim" }) do
		local d = U.paint(U.make("Frame", {
			Size = UDim2.fromOffset(8, 8),
			Position = UDim2.fromOffset(12 + (i - 1) * 13, 11),
			BackgroundColor3 = T[key],
			BorderSizePixel = 0,
			ZIndex = 6,
		}, bar), "BackgroundColor3", key)
		U.make("UICorner", { CornerRadius = UDim.new(1, 0) }, d)
	end
	self._titleText = "[ " .. (opts.Title or "nyxOS") .. " ]  v" .. (Window.Version or "")
	self._titleLbl = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(62, 0),
		Size = UDim2.new(1, -120, 1, 0),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ZIndex = 5,
	}, bar), "TextColor3", "Accent")
	task.spawn(U.type, self._titleLbl, self._titleText, 0.03)

	local function tbtn(txt, idx, cb)
		local b = U.make("TextButton", {
			Size = UDim2.fromOffset(24, 20),
			Position = UDim2.new(1, -28 * idx - 4, 0, 5),
			BackgroundTransparency = 1,
			Text = txt,
			Font = T.Font,
			TextSize = 16,
			TextColor3 = T.Accent,
			AutoButtonColor = false,
			ZIndex = 6,
		}, bar)
		b.MouseEnter:Connect(function()
			b.BackgroundTransparency = 0
			b.BackgroundColor3 = self.Theme.Accent
			b.TextColor3 = self.Theme.Black
		end)
		b.MouseLeave:Connect(function()
			b.BackgroundTransparency = 1
			b.TextColor3 = self.Theme.Accent
		end)
		b.MouseButton1Click:Connect(cb)
	end
	tbtn("X", 1, function()
		self:Confirm("Fechar o nyxOS?", function()
			self:_askClose()
		end)
	end)
	tbtn("_", 2, function()
		self:Minimize()
	end)
	U.draggable(bar, win, nil, self._conns)

	-- Corpo: menu lateral, cabeçalho da página e painel
	local bodyTop = TOP + 8
	local bottomGap = FOOT + 8
	self._side = U.paint(U.make("ScrollingFrame", {
		Position = UDim2.fromOffset(8, bodyTop),
		Size = UDim2.new(0, SIDE_W, 1, -(bodyTop + bottomGap)),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = T.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, win), "BackgroundColor3", "Panel")
	U.paint(U.stroke(self._side, T.Dim), "Color", "Dim")
	U.make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, self._side)
	U.pad(self._side, 4, 4, 8, 6)

	local mainX = 8 + SIDE_W + 8
	local head = U.make("Frame", {
		Position = UDim2.fromOffset(mainX, bodyTop),
		Size = UDim2.new(1, -(mainX + 8), 0, HEAD_H),
		BackgroundTransparency = 1,
	}, win)
	self._pageTitle = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.new(1, -8, 0, 22),
		Font = T.Font,
		TextSize = 18,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, head), "TextColor3", "Accent")
	self._pageDesc = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(4, 26),
		Size = UDim2.new(1, -8, 0, 14),
		Font = T.Font,
		TextSize = 12,
		TextColor3 = T.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, head), "TextColor3", "Dim")
	U.paint(U.make("Frame", {
		Position = UDim2.new(0, 0, 1, -3),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = T.Dim,
		BorderSizePixel = 0,
	}, head), "BackgroundColor3", "Dim")

	self._main = U.paint(U.make("Frame", {
		Position = UDim2.fromOffset(mainX, bodyTop + HEAD_H + 6),
		Size = UDim2.new(1, -(mainX + 8), 1, -(bodyTop + HEAD_H + 6 + bottomGap)),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, win), "BackgroundColor3", "Panel")
	U.paint(U.stroke(self._main, T.Dim), "Color", "Dim")

	-- Rodapé: status, FPS e relógio
	local foot = U.paint(U.make("Frame", {
		Position = UDim2.new(0, 0, 1, -FOOT),
		Size = UDim2.new(1, 0, 0, FOOT),
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, win), "BackgroundColor3", "Black")
	U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = T.Dim,
		BorderSizePixel = 0,
	}, foot), "BackgroundColor3", "Dim")
	local footL = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -200, 1, 0),
		Font = T.Font,
		TextSize = 13,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ZIndex = 6,
	}, foot), "TextColor3", "Accent")
	local footR = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -196, 0, 0),
		Size = UDim2.fromOffset(188, FOOT),
		Font = T.Font,
		TextSize = 13,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = "",
		ZIndex = 6,
	}, foot), "TextColor3", "Accent")
	task.spawn(U.type, footL, "* ONLINE | RShift: alternar | v" .. (Window.Version or ""), 0.015)
	task.spawn(function()
		while self.Gui.Parent do
			pcall(function()
				footR.Text = string.format("%s  %dfps", os.date("%H:%M:%S"), math.floor(self._fps or 0))
			end)
			task.wait(0.5)
		end
	end)

	-- Bolinha (minimizado), mais abaixo no canto superior esquerdo
	self.Bubble = U.paint(U.make("Frame", {
		Size = UDim2.fromOffset(50, 50),
		Position = BUBBLE_POS,
		BackgroundColor3 = T.Black,
		Visible = false,
		ZIndex = 30,
	}, self.Gui), "BackgroundColor3", "Black")
	U.make("UICorner", { CornerRadius = UDim.new(1, 0) }, self.Bubble)
	local bubbleStroke = U.paint(U.stroke(self.Bubble, T.Accent, 2), "Color", "Accent")
	self._bubbleLbl = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = T.Font,
		Text = "nyx",
		TextSize = 14,
		TextColor3 = T.Accent,
		ZIndex = 31,
	}, self.Bubble), "TextColor3", "Accent")
	TweenService:Create(bubbleStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		Transparency = 0.8,
	}):Play()
	U.draggable(self.Bubble, self.Bubble, function()
		self:Restore()
	end, self._conns)

	-- Efeitos aleatórios de tela (só com a janela aberta)
	task.spawn(function()
		while self.Gui.Parent do
			task.wait(math.random(15, 35) / 10)
			if self.Visible and self.Window.Parent then
				local r = math.random()
				if r < 0.3 then
					E.glitch(self._titleLbl, self._titleText, 3)
				elseif r < 0.55 then
					self.Screen:sweep()
				elseif r < 0.7 then
					self.Screen:flash()
					self.Screen:boost(3)
				else
					TweenService:Create(self._winStroke, TweenInfo.new(0.1), { Transparency = 0.6 }):Play()
					task.wait(0.12)
					TweenService:Create(self._winStroke, TweenInfo.new(0.3), { Transparency = 0 }):Play()
				end
			end
		end
	end)

	-- Revelação do "nyx" na bolinha, de tempos em tempos
	task.spawn(function()
		while self.Gui.Parent do
			task.wait(5)
			if not self.Visible and self.Bubble.Parent then
				E.lock(self._bubbleLbl, "nyx")
			end
		end
	end)

	-- Tecla para alternar
	table.insert(self._conns, UIS.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end
		if input.KeyCode == (opts.Keybind or Enum.KeyCode.RightShift) then
			if self.Visible then
				self:Minimize()
			else
				self:Restore()
			end
		end
	end))

	-- Aba Início (jogo, personagem e skin)
	if opts.Home ~= false then
		self:_home(opts.Home or DEFAULT_HOME)
	end

	-- Boot em tela cheia, por cima da janela (com SKIP)
	self.Screen.SkipBoot = self:Get("skipBoot", false)
	self.Screen:boot(BOOT_LINES, "ACESSO LIBERADO", function()
		self.Screen:flash()
		self.Screen:boost(4)
	end)

	if self:Get("startMinimized", false) then
		task.delay(0.8, function()
			self:Minimize()
		end)
	end
	env.__nyxos_active = self
	return self
end

-- Pede confirmação antes de fechar a janela
function Window:_askClose()
	if self._asking or self._closing then
		return
	end
	self._asking = true
	local T = self.Theme
	local dim = U.make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = T.Black,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		ZIndex = 60,
	}, self.Window)
	local box = U.paint(U.make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(360, 140),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
		ZIndex = 61,
	}, dim), "BackgroundColor3", "Panel")
	U.paint(U.stroke(box, T.Accent, 1.5), "Color", "Accent")
	local msg = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 14),
		Size = UDim2.new(1, -32, 0, 60),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = "",
		ZIndex = 62,
	}, box), "TextColor3", "Accent")
	E.decode(msg, "[ ! ] Fechar o nyxOS? Tudo será encerrado.", 0.4)

	local function btn(text, px, col, cb)
		local b = U.make("TextButton", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(px, 0, 1, -16),
			Size = UDim2.new(0.4, 0, 0, 34),
			BackgroundColor3 = T.Black,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = T.Font,
			TextSize = 15,
			TextColor3 = col,
			Text = text,
			ZIndex = 62,
		}, box)
		U.stroke(b, col)
		b.MouseEnter:Connect(function()
			b.BackgroundColor3 = col
			b.TextColor3 = T.Black
		end)
		b.MouseLeave:Connect(function()
			b.BackgroundColor3 = T.Black
			b.TextColor3 = col
		end)
		b.MouseButton1Click:Connect(cb)
	end
	btn("[ SIM ]", 0.07, Color3.fromRGB(255, 70, 70), function()
		self:Close()
	end)
	btn("[ NÃO ]", 0.53, T.Accent, function()
		dim:Destroy()
		self._asking = false
	end)
end

function Window:GetFPS()
	return math.floor(self._fps or 0)
end

-- Aba Início: informações do jogo, do personagem e escolha de skin
-- Cartão da skin no canto inferior esquerdo do menu
function Window:_buildCard()
	local T = self.Theme
	self._side.Size = UDim2.new(0, SIDE_W, 1, -(TOP + 8 + FOOT + 8 + 108))
	local card = U.paint(U.make("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 8, 1, -(FOOT + 8)),
		Size = UDim2.fromOffset(SIDE_W, 100),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
		ZIndex = 6,
	}, self.Window), "BackgroundColor3", "Panel")
	U.paint(U.stroke(card, T.Dim), "Color", "Dim")
	self._skinImg = U.paint(U.make("ImageLabel", {
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.fromOffset(60, 60),
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 7,
	}, card), "BackgroundColor3", "Black")
	U.paint(U.stroke(self._skinImg, T.Dim), "Color", "Dim")
	self._skinName = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(72, 8),
		Size = UDim2.new(1, -78, 0, 18),
		Font = T.Font,
		TextSize = 14,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ZIndex = 7,
	}, card), "TextColor3", "Accent")
	self._skinInfo = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(72, 28),
		Size = UDim2.new(1, -78, 0, 56),
		Font = T.Font,
		TextSize = 12,
		TextColor3 = T.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Text = "",
		ZIndex = 7,
	}, card), "TextColor3", "Dim")
	self._skinCard = card
end

function Window:_setSkin(s)
	if not self._skinCard or not s then
		return
	end
	self._skinImg.Image = s.Image and Tab.asset(s.Image) or ""
	self._skinName.Text = s.Name
	self._skinInfo.Text = tostring(s.Desc)
end

-- Aba Início: jogo, personagem, skin (e cartão da skin no menu)
function Window:_home(home)
	local g = home.Game or DEFAULT_HOME.Game
	local c = home.Character or DEFAULT_HOME.Character
	local skins = home.Skins or DEFAULT_HOME.Skins
	local tab = self:Tab("Início", "jogo, personagem e skin", home.Icon)

	tab:Section("Jogo")
	tab:Card(g.Name .. "  v" .. tostring(g.Version), g.Desc)

	tab:Section("Personagem")
	tab:Stats("Ficha", {
		{ "Nome", c.Name },
		{ "Classe", c.Class },
		{ "Nível", c.Level },
		{ "Poder", c.Power },
	})

	tab:Section("Skin")
	local names = {}
	for i, s in ipairs(skins) do
		names[i] = s.Name
	end
	local function find(name)
		for _, s in ipairs(skins) do
			if s.Name == name then
				return s
			end
		end
		return skins[1]
	end
	local _, info = tab:Card("Skin equipada", "")
	tab:Dropdown("Escolher skin", names, names[1], function(v)
		local s = find(v)
		self:_setSkin(s)
		info.Text = tostring(s.Desc)
		self:Notify("skin equipada: " .. v, 2, "nyx")
	end)

	self:_buildCard()
	local first = skins[1]
	self:_setSkin(first)
	info.Text = tostring(first.Desc)
	return tab
end

function Window:_select(t)
	local T = self.Theme
	for _, o in ipairs(self._tabs) do
		local on = o == t
		o.active = on
		o.page.Visible = on
		o.marker.Visible = on
		o.btn.BackgroundTransparency = on and 0 or 1
		o.btn.BackgroundColor3 = T.Hover
		o.btn.TextColor3 = on and T.Accent or T.Dim
	end
	if t then
		t.page.Position = UDim2.fromOffset(24, 0)
		TweenService:Create(t.page, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.fromOffset(0, 0),
		}):Play()
		E.decode(self._pageTitle, "// " .. t.name, 0.25)
		self._pageDesc.Text = t.desc or ""
	end
	self._active = t
end

-- Cria uma aba (menu lateral esquerdo)
function Window:Tab(name, desc, icon)
	local t = Tab.new(self, name, desc, icon)
	t.marker = U.paint(U.make("Frame", {
		Position = UDim2.fromOffset(0, 4),
		Size = UDim2.new(0, 3, 1, -8),
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 3,
	}, t.btn), "BackgroundColor3", "Accent")
	table.insert(self._tabs, t)
	if not self._active then
		self:_select(t)
	end
	return t
end

-- Troca o tema ao vivo
function Window:SetTheme(name)
	local T = loadTheme(name)
	self.Theme = T
	U.repaint(T)
	self.Screen:setTheme(T)
	for _, fn in ipairs(self._refresh) do
		fn()
	end
	self:_select(self._active)
	self:Notify("tema " .. tostring(T.Name) .. " aplicado", 2, "success")
end

-- Notificação no canto superior direito
-- kind: "info" (padrão) | "success" | "warn" | "error" | "nyx"
function Window:Notify(text, duration, kind, title)
	local T = self.Theme
	local k = KINDS[kind or "info"] or KINDS.info
	local col = k.color or T.Accent
	duration = duration or 3
	local headText = "[" .. k.tag .. "] " .. (title or k.title)

	if not self._toasts then
		self._toasts = U.make("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -16, 0, 16),
			Size = UDim2.fromOffset(400, 600),
			BackgroundTransparency = 1,
			ZIndex = 40,
		}, self.Gui)
		U.make("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		}, self._toasts)
	end
	self._toastN += 1

	local toast = U.make("Frame", {
		Size = UDim2.fromOffset(390, 66),
		BackgroundColor3 = T.Black,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		LayoutOrder = self._toastN,
		ClipsDescendants = true,
		ZIndex = 41,
	}, self._toasts)
	local edge = U.stroke(toast, col, 1)
	local side = U.make("Frame", {
		Size = UDim2.new(0, 4, 1, 0),
		BackgroundColor3 = col,
		BorderSizePixel = 0,
		ZIndex = 42,
	}, toast)
	local head = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 6),
		Size = UDim2.new(1, -24, 0, 18),
		Font = T.Font,
		TextSize = 14,
		TextColor3 = col,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ZIndex = 42,
	}, toast)
	local body = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 26),
		Size = UDim2.new(1, -24, 0, 34),
		Font = T.Font,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(215, 255, 215),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Text = "",
		ZIndex = 42,
	}, toast)
	local bar = U.make("Frame", {
		Position = UDim2.new(0, 0, 1, -3),
		Size = UDim2.new(1, 0, 0, 3),
		BackgroundColor3 = col,
		BorderSizePixel = 0,
		ZIndex = 42,
	}, toast)

	if kind == "nyx" or kind == "error" then
		local cam2 = workspace.CurrentCamera
		if cam2 then
			self.Screen:burst(cam2.ViewportSize.X - 200, 40, col, 16)
		end
		self.Screen:flash()
	end

	task.spawn(function()
		E.decode(head, headText, 0.25)
		task.wait(0.3)
		if not toast.Parent then
			return
		end
		if kind == "nyx" or kind == "error" then
			E.glitch(head, headText, 2)
		end
		if kind == "nyx" then
			task.spawn(function()
				while toast.Parent do
					TweenService:Create(edge, TweenInfo.new(0.5), { Transparency = 0.6 }):Play()
					task.wait(0.5)
					if not toast.Parent then
						break
					end
					TweenService:Create(edge, TweenInfo.new(0.5), { Transparency = 0 }):Play()
					task.wait(0.5)
				end
			end)
		end
		U.type(body, text, 0.012, "> ")
		if not toast.Parent then
			return
		end
		TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 0, 3),
		}):Play()
		task.wait(duration)
		if toast.Parent then
			local f = TweenInfo.new(0.4)
			TweenService:Create(toast, f, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(edge, f, { Transparency = 1 }):Play()
			TweenService:Create(side, f, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(head, f, { TextTransparency = 1 }):Play()
			TweenService:Create(body, f, { TextTransparency = 1 }):Play()
			TweenService:Create(bar, f, { BackgroundTransparency = 1 }):Play()
			task.wait(0.45)
			toast:Destroy()
		end
	end)
end

-- Caixa de confirmação (SIM / NÃO) antes de uma ação destrutiva
function Window:Confirm(question, onYes)
	if self._confirmBox then
		return
	end
	local T = self.Theme
	local dim = U.make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		ZIndex = 70,
	}, self.Gui)
	self._confirmBox = dim
	local box = U.make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(380, 140),
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
		ZIndex = 71,
	}, dim)
	U.stroke(box, T.Accent, 1.5)
	local q = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 16),
		Size = UDim2.new(1, -32, 0, 56),
		Font = T.Font,
		TextSize = 16,
		TextColor3 = T.Accent,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = "",
		ZIndex = 72,
	}, box)
	task.spawn(U.type, q, "[ CONFIRMAR ] " .. question, 0.02)

	local function close()
		self._confirmBox = nil
		dim:Destroy()
	end
	local function btn(text, x, cb)
		local b = U.make("TextButton", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(x, 0, 1, -16),
			Size = UDim2.fromOffset(136, 34),
			BackgroundColor3 = T.Black,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = T.Font,
			TextSize = 15,
			TextColor3 = T.Accent,
			Text = text,
			ZIndex = 72,
		}, box)
		U.stroke(b, T.Accent)
		b.MouseEnter:Connect(function()
			b.BackgroundColor3 = T.Accent
			b.TextColor3 = T.Black
		end)
		b.MouseLeave:Connect(function()
			b.BackgroundColor3 = T.Black
			b.TextColor3 = T.Accent
		end)
		b.MouseButton1Click:Connect(cb)
	end
	btn("[ SIM ]", 0.12, function()
		close()
		onYes()
	end)
	btn("[ NÃO ]", 0.52, close)
end

function Window:Minimize()
	if not self.Visible then
		return
	end
	self.Visible = false
	self.Screen:flash()
	self.Center = self.Window.Position
	local t = TweenService:Create(self.Window, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Size = UDim2.fromOffset(0, 0),
		Position = UDim2.fromOffset(BUBBLE_CENTER[1], BUBBLE_CENTER[2]),
	})
	t:Play()
	-- Desliga a chuva logo após o encolhimento (não depende só do Completed)
	task.delay(0.4, function()
		if not self.Visible then
			self.Screen:setVisible(false)
		end
	end)
	t.Completed:Connect(function()
		if self.Visible then
			return
		end
		self.Window.Visible = false
		self.Screen:setVisible(false)
		self.Bubble.Visible = true
		self.Bubble.Size = UDim2.fromOffset(0, 0)
		TweenService:Create(self.Bubble, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(50, 50),
		}):Play()
		E.lock(self._bubbleLbl, "nyx")
	end)
end

function Window:Restore()
	if self.Visible then
		return
	end
	self.Visible = true
	self.Screen:setVisible(true)
	self.Bubble.Visible = false
	self.Window.Visible = true
	self.Window.Size = UDim2.fromOffset(0, 0)
	self.Screen:burst(BUBBLE_CENTER[1], BUBBLE_CENTER[2], self.Theme.Accent, 14)
	self.Screen:boost(3)
	self.Screen:flash()
	TweenService:Create(self.Window, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = self.Size,
		Position = self.Center,
	}):Play()
end

function Window:Close()
	if self._closing then
		return
	end
	self._closing = true
	E.glitch(self._titleLbl, self._titleText, 4)
	self.Screen:boost(5)
	self.Screen:flash()
	self.Screen:sweep()
	task.delay(0.35, function()
		local t = TweenService:Create(self.Window, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, 0, 2),
		})
		t:Play()
		t.Completed:Connect(function()
			self:Destroy()
		end)
	end)
end

function Window:Destroy()
	for _, c in ipairs(self._conns) do
		c:Disconnect()
	end
	self._conns = {}
	if self.Screen then
		self.Screen:destroy()
	end
end

req("src/components/extra")(Tab, Window)

return Window
