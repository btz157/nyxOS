local req = ...
local U = req("src/core/util")
local E = req("src/core/effects")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Camadas de tela inteira:
-- Back: chuva Matrix (atrás de tudo)
-- Main: janela, bolinha e notificações
-- Top: scanline, varredura, flash, partículas e boot (por cima de tudo)
local S = {}
S.__index = S

local function guiParent()
	local okH, hui = pcall(function()
		return gethui and gethui()
	end)
	return (okH and hui) or Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function screenGui(parent, name, order)
	local g = U.make("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = order,
	}, parent)
	if syn and syn.protect_gui then
		pcall(syn.protect_gui, g)
	end
	return g
end

function S.new(theme)
	local self = setmetatable({}, S)
	self.Theme = theme
	self.Boost = 1
	self._conns = {}

	local parent = guiParent()
	self.Back = screenGui(parent, "nyxOS_FX", 900)
	self.Main = screenGui(parent, "nyxOS", 999)
	self.Top = screenGui(parent, "nyxOS_TOP", 1000)

	local cam = workspace.CurrentCamera or workspace:WaitForChild("CurrentCamera")
	self._vw, self._vh = cam.ViewportSize.X, cam.ViewportSize.Y

	U.make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
	}, self.Back)
	self.Streams = E.rain(self.Back, self._vw, self._vh, theme)

	table.insert(self._conns, RunService.RenderStepped:Connect(function(dt)
		self.Boost = math.max(1, self.Boost - dt * 1.2)
		E.step(self.Streams, self._vh, dt, self.Boost)
	end))

	self._scan = U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, self.Top)
	TweenService:Create(self._scan, TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), {
		Position = UDim2.fromScale(0, 1),
	}):Play()

	return self
end

-- Liga/desliga chuva e scanline: desliga a camada e também cada coluna
function S:setVisible(v)
	self.Back.Enabled = v
	self.Top.Enabled = v
	for _, s in ipairs(self.Streams) do
		s.label.Visible = v
	end
end

function S:setTheme(T)
	self.Theme = T
	E.recolor(self.Streams, T.Accent)
	self._scan.BackgroundColor3 = T.Accent
end

function S:boost(m)
	self.Boost = math.max(self.Boost, m or 3)
end

function S:burst(x, y, color, count)
	E.burst(self.Top, x, y, color or self.Theme.Accent, count)
end

function S:sweep()
	E.sweep(self.Top, self.Theme.Accent)
end

function S:flash()
	local f = U.make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = self.Theme.Accent,
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, self.Top)
	TweenService:Create(f, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
	task.delay(0.3, function()
		f:Destroy()
	end)
end

function S:boot(lines, finalText, onDone)
	E.powerOn(self.Top, self.Theme, function()
		E.boot(self.Top, self.Theme, lines, finalText, onDone)
	end)
end

function S:destroy()
	for _, c in ipairs(self._conns) do
		c:Disconnect()
	end
	self._conns = {}
	for _, g in ipairs({ self.Back, self.Main, self.Top }) do
		if g then
			g:Destroy()
		end
	end
end

return S
