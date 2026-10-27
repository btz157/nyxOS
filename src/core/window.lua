local req = ...
local U = req("src/core/util")
local E = req("src/core/effects")
local Tab = req("src/components/tab")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Window = {}
Window.__index = Window

local BOOT_LINES = {
	"kernel nyxOS iniciado",
	"montando interface",
	"carregando módulos",
	"sincronizando matriz",
	"sistema pronto",
}

local ERROR_RED = Color3.fromRGB(255, 70, 70)
local WARN_AMBER = Color3.fromRGB(255, 190, 0)

function Window.new(opts)
	opts = opts or {}
	local T = req("src/themes/" .. (opts.Theme or "neon"))
	local self = setmetatable({}, Window)
	self.Theme = T
	self._conns = {}
	self._tabs = {}
	self._active = nil
	self._toastN = 0
	self.Visible = true

	local size = opts.Size or Vector2.new(560, 380)
	local W, H = size.X, size.Y
	self.Size = UDim2.fromOffset(W, H)

	local cam = workspace.CurrentCamera or workspace:WaitForChild("CurrentCamera")
	self.Center = UDim2.fromOffset(math.floor(cam.ViewportSize.X / 2 - W / 2), math.floor(cam.ViewportSize.Y / 2 - H / 2))

	local okH, hui = pcall(function()
		return gethui and gethui()
	end)
	local parent = (okH and hui) or Players.LocalPlayer:WaitForChild("PlayerGui")

	self.Gui = U.make("ScreenGui", {
		Name = "nyxOS",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
	}, parent)
	if syn and syn.protect_gui then
		pcall(syn.protect_gui, self.Gui)
	end

	local win = U.make("Frame", {
		Name = "Window",
		Size = UDim2.fromOffset(W, 2),
		Position = self.Center,
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, self.Gui)
	self._winStroke = U.stroke(win, T.Accent)
	self.Window = win

	-- Abertura: a janela cresce a partir de uma linha
	TweenService:Create(win, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = self.Size,
	}):Play()

	-- Matrix só no fundo
	local bg = U.make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 1 }, win)
	self._cols = E.rain(bg, W, H, T)
	table.insert(self._conns, RunService.RenderStepped:Connect(function(dt)
		E.step(self._cols, H, dt)
	end))

	-- Barra de título
	local TOP = 28
	local bar = U.make("Frame", {
		Size = UDim2.new(1, 0, 0, TOP),
		BackgroundColor3 = T.Black,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, win)
	U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = T.Accent,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, bar)
	self._titleText = "> " .. (opts.Title or "nyxOS") .. " v" .. (Window.Version or "")
	self._titleLbl = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -70, 1, 0),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ZIndex = 5,
	}, bar)
	task.spawn(U.type, self._titleLbl, self._titleText, 0.03)

	local function tbtn(txt, idx, cb)
		local b = U.make("TextButton", {
			Size = UDim2.fromOffset(24, 20),
			Position = UDim2.new(1, -28 * idx - 4, 0, 4),
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
			b.BackgroundColor3 = T.Accent
			b.TextColor3 = T.Black
		end)
		b.MouseLeave:Connect(function()
			b.BackgroundTransparency = 1
			b.TextColor3 = T.Accent
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

	-- Corpo: abas à esquerda, painel à direita
	local bodyTop = TOP + 6
	self._side = U.make("Frame", {
		Position = UDim2.fromOffset(6, bodyTop),
		Size = UDim2.new(0, 128, 1, -bodyTop - 6),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
	}, win)
	U.stroke(self._side, T.Dim)
	U.make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, self._side)
	U.pad(self._side, 4, 4, 6, 6)

	self._main = U.make("Frame", {
		Position = UDim2.fromOffset(140, bodyTop),
		Size = UDim2.new(1, -146, 1, -bodyTop - 6),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, win)
	U.stroke(self._main, T.Dim)

	-- Bolinha (minimizado) no canto superior esquerdo
	self.Bubble = U.make("Frame", {
		Size = UDim2.fromOffset(50, 50),
		Position = UDim2.fromOffset(12, 12),
		BackgroundColor3 = T.Black,
		Visible = false,
		ZIndex = 30,
	}, self.Gui)
	U.make("UICorner", { CornerRadius = UDim.new(1, 0) }, self.Bubble)
	local bubbleStroke = U.stroke(self.Bubble, T.Accent, 2)
	self._bubbleLbl = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = T.Font,
		Text = "nyx",
		TextSize = 14,
		TextColor3 = T.Accent,
	}, self.Bubble)
	TweenService:Create(bubbleStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		Transparency = 0.8,
	}):Play()
	U.draggable(self.Bubble, self.Bubble, function()
		self:Restore()
	end, self._conns)

	-- Linha de varredura contínua
	local scan = U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		ZIndex = 20,
	}, win)
	TweenService:Create(scan, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), {
		Position = UDim2.fromScale(0, 1),
	}):Play()

	-- Efeitos aleatórios: glitch no título, varredura e pulso na borda; bolinha decodifica
	task.spawn(function()
		while self.Gui.Parent do
			task.wait(math.random(20, 50) / 10)
			if self.Visible and self.Window.Parent then
				local r = math.random()
				if r < 0.35 then
					E.glitch(self._titleLbl, self._titleText, 3)
				elseif r < 0.7 then
					E.sweep(self.Window, T.Accent)
				else
					TweenService:Create(self._winStroke, TweenInfo.new(0.1), { Transparency = 0.6 }):Play()
					task.wait(0.12)
					TweenService:Create(self._winStroke, TweenInfo.new(0.3), { Transparency = 0 }):Play()
				end
			elseif not self.Visible and self.Bubble.Parent then
				E.decode(self._bubbleLbl, "nyx", 0.4)
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

	if opts.Boot ~= false then
		E.boot(win, T, BOOT_LINES, "acesso liberado")
	end

	return self
end

function Window:_select(t)
	for _, o in ipairs(self._tabs) do
		local on = o == t
		o.active = on
		o.page.Visible = on
		o.btn.BackgroundTransparency = on and 0 or 1
		o.btn.TextColor3 = on and self.Theme.Black or self.Theme.Accent
	end
	if t and t.page then
		t.page.Position = UDim2.fromOffset(30, 0)
		TweenService:Create(t.page, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.fromOffset(0, 0),
		}):Play()
		E.decode(t.btn, t.label, 0.25)
	end
	self._active = t
end

-- Cria uma aba (lateral esquerda)
function Window:Tab(name)
	local t = Tab.new(self, name)
	table.insert(self._tabs, t)
	if not self._active then
		self:_select(t)
	end
	return t
end

-- Notificação em tela cheia (canto inferior direito da tela)
-- kind: "info" (padrão), "warn", "error"
function Window:Notify(text, duration, kind)
	local T = self.Theme
	local col = kind == "error" and ERROR_RED or kind == "warn" and WARN_AMBER or T.Accent
	if not self._toasts then
		self._toasts = U.make("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -16, 1, -16),
			Size = UDim2.fromOffset(360, 420),
			BackgroundTransparency = 1,
			ZIndex = 40,
		}, self.Gui)
		U.make("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		}, self._toasts)
	end
	self._toastN += 1

	local toast = U.make("Frame", {
		Size = UDim2.fromOffset(340, 34),
		BackgroundColor3 = T.Black,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		LayoutOrder = self._toastN,
		ClipsDescendants = true,
		ZIndex = 41,
	}, self._toasts)
	local edge = U.stroke(toast, col)
	local lbl = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -14, 0, 20),
		Position = UDim2.fromOffset(7, 4),
		Font = T.Font,
		TextSize = 14,
		TextColor3 = col,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ZIndex = 42,
	}, toast)
	local progress = U.make("Frame", {
		Position = UDim2.new(0, 0, 1, -3),
		Size = UDim2.new(1, 0, 0, 3),
		BackgroundColor3 = col,
		BorderSizePixel = 0,
		ZIndex = 42,
	}, toast)

	task.spawn(function()
		local prefix = kind == "error" and "err@nyx:~$ " or "nyx@terminal:~$ "
		U.type(lbl, text, 0.012, prefix)
		if not toast.Parent then
			return
		end
		TweenService:Create(progress, TweenInfo.new(duration or 3, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 0, 3),
		}):Play()
		task.wait(duration or 3)
		if toast.Parent then
			TweenService:Create(toast, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(edge, TweenInfo.new(0.4), { Transparency = 1 }):Play()
			TweenService:Create(lbl, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
			TweenService:Create(progress, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
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
		self.Bubble.Visible = true
		self.Bubble.Size = UDim2.fromOffset(0, 0)
		TweenService:Create(self.Bubble, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(50, 50),
		}):Play()
		E.decode(self._bubbleLbl, "nyx", 0.4)
	end)
end

function Window:Restore()
	if self.Visible then
		return
	end
	self.Visible = true
	self.Bubble.Visible = false
	self.Window.Visible = true
	self.Window.Size = UDim2.fromOffset(0, 0)
	E.burst(self.Gui, 37, 37, self.Theme.Accent, 14)
	TweenService:Create(self.Window, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = self.Size,
		Position = self.Center,
	}):Play()
end

-- Fechar com animação: glitch no título e a janela colapsa numa linha
function Window:Close()
	if self._closing then
		return
	end
	self._closing = true
	E.glitch(self._titleLbl, self._titleText, 4)
	task.delay(0.25, function()
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
	if self.Gui then
		self.Gui:Destroy()
	end
end

return Window
