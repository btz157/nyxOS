local req = ...
local U = req("src/core/util")
local E = req("src/core/effects")
local Screen = req("src/core/screen")
local Tab = req("src/components/tab")

local TweenService = game:GetService("TweenService")
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

local TOP, FOOT, SIDE_W, HEAD_H = 30, 22, 140, 44

local function loadTheme(name)
	local ok, T = pcall(req, "src/themes/" .. (name or "neon"))
	if ok and T then
		return T
	end
	return req("src/themes/neon")
end

function Window.new(opts)
	opts = opts or {}
	local T = loadTheme(opts.Theme)
	local self = setmetatable({}, Window)
	self.Theme = T
	self.Screen = Screen.new(T)
	self.Gui = self.Screen.Main
	self._conns = {}
	self._refresh = {}
	self._tabs = {}
	self._active = nil
	self._toastN = 0
	self.Visible = true

	local size = opts.Size or Vector2.new(620, 410)
	local W, H = size.X, size.Y
	self.Size = UDim2.fromOffset(W, H)
	local cam = workspace.CurrentCamera or workspace:WaitForChild("CurrentCamera")
	self.Center = UDim2.fromOffset(math.floor(cam.ViewportSize.X / 2 - W / 2), math.floor(cam.ViewportSize.Y / 2 - H / 2))

	-- Painel preto com borda neon e moldura interna
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
	U.paint(U.stroke(U.make("Frame", {
		Size = UDim2.new(1, -8, 1, -8),
		Position = UDim2.fromOffset(4, 4),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, win), T.Dim, 1), "Color", "Dim")
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
			Position = UDim2.fromOffset(10 + (i - 1) * 13, 11),
			BackgroundColor3 = T[key],
			BorderSizePixel = 0,
			ZIndex = 6,
		}, bar), "BackgroundColor3", key)
		U.make("UICorner", { CornerRadius = UDim.new(1, 0) }, d)
	end
	self._titleText = "> " .. (opts.Title or "nyxOS") .. " v" .. (Window.Version or "")
	self._titleLbl = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(56, 0),
		Size = UDim2.new(1, -110, 1, 0),
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
		self:Close()
	end)
	tbtn("_", 2, function()
		self:Minimize()
	end)
	U.draggable(bar, win, nil, self._conns)

	-- Corpo: abas à esquerda, cabeçalho e painel à direita
	local bodyTop = TOP + 6
	local bottomGap = FOOT + 6
	self._side = U.paint(U.make("Frame", {
		Position = UDim2.fromOffset(6, bodyTop),
		Size = UDim2.new(0, SIDE_W, 1, -(bodyTop + bottomGap)),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
	}, win), "BackgroundColor3", "Panel")
	U.paint(U.stroke(self._side, T.Dim), "Color", "Dim")
	U.make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, self._side)
	U.pad(self._side, 4, 4, 6, 6)

	local mainX = 6 + SIDE_W + 6
	local head = U.make("Frame", {
		Position = UDim2.fromOffset(mainX, bodyTop),
		Size = UDim2.new(1, -(mainX + 6), 0, HEAD_H),
		BackgroundTransparency = 1,
	}, win)
	self._pageTitle = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.new(1, -4, 0, 22),
		Font = T.Font,
		TextSize = 18,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, head), "TextColor3", "Accent")
	self._pageDesc = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(2, 24),
		Size = UDim2.new(1, -4, 0, 14),
		Font = T.Font,
		TextSize = 12,
		TextColor3 = T.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, head), "TextColor3", "Dim")
	U.paint(U.make("Frame", {
		Position = UDim2.new(0, 0, 1, -2),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = T.Dim,
		BorderSizePixel = 0,
	}, head), "BackgroundColor3", "Dim")

	self._main = U.paint(U.make("Frame", {
		Position = UDim2.fromOffset(mainX, bodyTop + HEAD_H + 6),
		Size = UDim2.new(1, -(mainX + 6), 1, -(bodyTop + HEAD_H + 6 + bottomGap)),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, win), "BackgroundColor3", "Panel")
	U.paint(U.stroke(self._main, T.Dim), "Color", "Dim")

	-- Rodapé com status e relógio
	local foot = U.paint(U.make("Frame", {
		Position = UDim2.new(0, 0, 1, -FOOT),
		Size = UDim2.new(1, 0, 0, FOOT),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, win), "BackgroundColor3", "Panel")
	U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = T.Dim,
		BorderSizePixel = 0,
	}, foot), "BackgroundColor3", "Dim")
	local footL = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -120, 1, 0),
		Font = T.Font,
		TextSize = 13,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ZIndex = 6,
	}, foot), "TextColor3", "Accent")
	local footR = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -116, 0, 0),
		Size = UDim2.fromOffset(108, FOOT),
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
				footR.Text = os.date("%H:%M:%S")
			end)
			task.wait(1)
		end
	end)

	-- Bolinha (minimizado) no canto superior esquerdo com o nome nyx
	self.Bubble = U.paint(U.make("Frame", {
		Size = UDim2.fromOffset(50, 50),
		Position = UDim2.fromOffset(12, 12),
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

	-- "nyx" da bolinha revela letra por letra de tempos em tempos
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

	-- Boot em tela cheia, por cima da janela
	self.Screen:boot(BOOT_LINES, "ACESSO LIBERADO", function()
		self.Screen:flash()
		self.Screen:boost(4)
	end)

	return self
end

function Window:_select(t)
	local T = self.Theme
	for _, o in ipairs(self._tabs) do
		local on = o == t
		o.active = on
		o.page.Visible = on
		o.btn.BackgroundTransparency = on and 0 or 1
		o.btn.BackgroundColor3 = T.Accent
		o.btn.TextColor3 = on and T.Black or T.Accent
		o.btn.Text = (on and "> " or "  ") .. o.name
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

-- Cria uma aba (lateral esquerda)
function Window:Tab(name, desc)
	local t = Tab.new(self, name, desc)
	table.insert(self._tabs, t)
	if not self._active then
		self:_select(t)
	end
	return t
end

-- Troca o tema ao vivo: pinta tudo de novo
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
-- title: opcional
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
		local cam = workspace.CurrentCamera
		if cam then
			self.Screen:burst(cam.ViewportSize.X - 200, 40, col, 16)
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

function Window:Minimize()
	if not self.Visible then
		return
	end
	self.Visible = false
	self.Screen:flash()
	self.Center = self.Window.Position
	local t = TweenService:Create(self.Window, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Size = UDim2.fromOffset(0, 0),
		Position = UDim2.fromOffset(37, 37),
	})
	t:Play()
	t.Completed:Connect(function()
		if self.Visible then
			return
		end
		self.Window.Visible = false
		self.Screen:setVisible(false) -- desliga chuva e scanline
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
	self.Screen:burst(37, 37, self.Theme.Accent, 14)
	self.Screen:boost(3)
	self.Screen:flash()
	TweenService:Create(self.Window, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = self.Size,
		Position = self.Center,
	}):Play()
end

-- Fechar com animação de tela inteira
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

return Window
