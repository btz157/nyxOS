local req = ...
local U = req("src/core/util")
local E = req("src/core/effects")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Tab = {}
Tab.__index = Tab

local function mouse()
	return UIS:GetMouseLocation()
end

function Tab.new(lib, name)
	local T = lib.Theme
	local label = "  " .. name
	local btn = U.make("TextButton", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = label,
	}, lib._side)

	local page = U.make("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
	}, lib._main)
	U.make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	U.pad(page, 10, 10, 8, 8)

	local self = setmetatable({ lib = lib, T = T, page = page, btn = btn, label = label, active = false }, Tab)

	btn.MouseEnter:Connect(function()
		if not self.active then
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.85 }):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if not self.active then
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
		end
	end)
	btn.MouseButton1Click:Connect(function()
		lib:_select(self)
	end)
	return self
end

-- Linha clicável com borda que acende no hover
local function row(self, text)
	local T = self.T
	local r = U.make("TextButton", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = text,
	}, self.page)
	U.pad(r, 10)
	local edge = U.stroke(r, T.Dim)
	r.MouseEnter:Connect(function()
		TweenService:Create(r, TweenInfo.new(0.15), { BackgroundColor3 = T.Hover }):Play()
		TweenService:Create(edge, TweenInfo.new(0.15), { Color = T.Accent }):Play()
	end)
	r.MouseLeave:Connect(function()
		TweenService:Create(r, TweenInfo.new(0.15), { BackgroundColor3 = T.Panel }):Play()
		TweenService:Create(edge, TweenInfo.new(0.15), { Color = T.Dim }):Play()
	end)
	return r
end

function Tab:Section(name)
	local text = "── " .. name .. " ──"
	local lbl = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Font = self.T.Font,
		TextSize = 14,
		TextColor3 = self.T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, self.page)
	E.decode(lbl, text, 0.4)
end

-- [>] Nome
function Tab:Button(name, cb)
	local T = self.T
	local text = "[>] " .. name
	local r = row(self, text)
	r.MouseButton1Click:Connect(function()
		local m = mouse()
		self.lib.Screen:burst(m.X, m.Y, T.Accent, 12)
		E.decode(r, text, 0.3); self.lib.Screen:boost(2.5)
		TweenService:Create(r, TweenInfo.new(0.08), { BackgroundColor3 = Color3.new(1, 1, 1) }):Play()
		task.delay(0.08, function()
			if r.Parent then
				TweenService:Create(r, TweenInfo.new(0.35), { BackgroundColor3 = T.Accent }):Play()
				task.delay(0.35, function()
					if r.Parent then
						TweenService:Create(r, TweenInfo.new(0.2), { BackgroundColor3 = T.Panel }):Play()
					end
				end)
			end
		end)
		if cb then
			cb()
		end
	end)
	return r
end

-- [>] Godmode        [_on_]
function Tab:Toggle(name, default, cb)
	local T = self.T
	local state = default == true
	local r = row(self, "[>] " .. name)
	local right = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 1, 0),
		Font = T.Font,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = T.Accent,
		Text = "",
	}, r)
	local function render(animate)
		local txt = state and "[ ON ]" or "[ OFF ]"
		local col = state and T.Accent or T.Dim
		if animate then
			E.decode(right, txt, 0.2)
		else
			right.Text = txt
		end
		right.TextColor3 = col
	end
	render(false)
	r.MouseButton1Click:Connect(function()
		state = not state
		local m = mouse()
		self.lib.Screen:burst(m.X, m.Y, state and T.Accent or T.Dim, 8)
		render(true)
		if cb then
			cb(state)
		end
	end)
	return function()
		return state
	end
end

-- [>] Velocidade: 5  + barra animada
function Tab:Slider(name, min, max, default, cb)
	local T = self.T
	local value = default or min
	local holder = U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
	}, self.page)
	U.stroke(holder, T.Dim)

	local lbl = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 4),
		Size = UDim2.new(1, -20, 0, 18),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, holder)

	local bar = U.make("Frame", {
		Position = UDim2.fromOffset(10, 28),
		Size = UDim2.new(1, -20, 0, 6),
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
	}, holder)
	U.stroke(bar, T.Dim)
	local fill = U.make("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = T.Accent,
		BorderSizePixel = 0,
	}, bar)

	local function render(smooth)
		local rel = (value - min) / (max - min)
		if smooth then
			TweenService:Create(fill, TweenInfo.new(0.12), { Size = UDim2.fromScale(rel, 1) }):Play()
		else
			fill.Size = UDim2.fromScale(rel, 1)
		end
		lbl.Text = string.format("[>] %s: %g", name, value)
	end
	render(false)

	local sliding = false
	local function set(input)
		local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local nv = math.floor(min + (max - min) * rel + 0.5)
		if nv ~= value then
			value = nv
			render(true)
			if cb then
				cb(value)
			end
		end
	end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			set(i)
		end
	end)
	table.insert(self.lib._conns, UIS.InputChanged:Connect(function(i)
		if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			set(i)
		end
	end))
	table.insert(self.lib._conns, UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			if sliding then
				local m = mouse()
				self.lib.Screen:burst(m.X, m.Y, T.Accent, 6)
			end
			sliding = false
		end
	end))
	return function()
		return value
	end
end

return Tab
