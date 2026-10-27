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
		Size = self.Size,
		Position = self.Center,
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, self.Gui)
	U.stroke(win, T.Accent)
	self.Window = win

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
	local titleText = "> " .. (opts.Title or "nyxOS") .. " v" .. (Window.Version or "")
	local title = U.make("TextLabel", {
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
	task.spawn(U.type, title, titleText, 0.03)

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
		self:Destroy()
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
	U.make("TextLabel", {
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

	-- Linha de varredura
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
		o.page.Visible = on
		o.btn.BackgroundTransparency = on and 0 or 1
		o.btn.TextColor3 = on and self.Theme.Black or self.Theme.Accent
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

-- Notificação digitada estilo terminal
function Window:Notify(text, duration)
	local T = self.Theme
	if not self._toasts then
		self._toasts = U.make("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -10, 1, -10),
			Size = UDim2.fromOffset(330, 150),
			BackgroundTransparency = 1,
			ZIndex = 40,
		}, self.Window)
		U.make("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}, self._toasts)
	end
	self._toastN += 1

	local toast = U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
		LayoutOrder = self._toastN,
		ZIndex = 41,
	}, self._toasts)
	local st = U.stroke(toast, T.Accent)
	local lbl = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 1, 0),
		Position = UDim2.fromOffset(5, 0),
		Font = T.Font,
		TextSize = 14,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ZIndex = 42,
	}, toast)

	task.spawn(function()
		U.type(lbl, text, 0.015, "nyx@terminal:~$ ")
		task.wait(duration or 3)
		if toast.Parent then
			TweenService:Create(toast, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(st, TweenInfo.new(0.4), { Transparency = 1 }):Play()
			TweenService:Create(lbl, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
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
	TweenService:Create(self.Window, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = self.Size,
		Position = self.Center,
	}):Play()
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
