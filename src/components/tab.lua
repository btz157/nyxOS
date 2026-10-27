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

function Tab.new(lib, name, desc)
	local T = lib.Theme
	local btn = U.make("TextButton", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "  " .. name,
	}, lib._side)
	local page = U.paint(U.make("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
	}, lib._main), "ScrollBarImageColor3", "Accent")
	U.make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	U.pad(page, 12, 12, 10, 10)

	local self = setmetatable({
		lib = lib,
		page = page,
		btn = btn,
		name = name,
		desc = desc or "",
		active = false,
	}, Tab)
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
local function row(self, text, parent)
	local T = self.lib.Theme
	local r = U.paint(U.make("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = text,
	}, parent or self.page), "BackgroundColor3", "Panel")
	U.paint(r, "TextColor3", "Accent")
	U.pad(r, 10, 10, 0, 0)
	local edge = U.paint(U.stroke(r, T.Dim), "Color", "Dim")
	r.MouseEnter:Connect(function()
		local t = self.lib.Theme
		TweenService:Create(r, TweenInfo.new(0.15), { BackgroundColor3 = t.Hover }):Play()
		TweenService:Create(edge, TweenInfo.new(0.15), { Color = t.Accent }):Play()
	end)
	r.MouseLeave:Connect(function()
		local t = self.lib.Theme
		TweenService:Create(r, TweenInfo.new(0.15), { BackgroundColor3 = t.Panel }):Play()
		TweenService:Create(edge, TweenInfo.new(0.15), { Color = t.Dim }):Play()
	end)
	return r, edge
end

function Tab:Section(name)
	local T = self.lib.Theme
	local lbl = U.paint(U.make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Font = T.Font,
		TextSize = 14,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, self.page), "TextColor3", "Accent")
	E.decode(lbl, "── " .. name .. " ──", 0.4)
	return lbl
end

function Tab:Label(text)
	local T = self.lib.Theme
	return U.paint(U.make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = T.Font,
		TextSize = 14,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Text = text,
	}, self.page), "TextColor3", "Accent")
end

function Tab:Divider()
	local T = self.lib.Theme
	return U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = T.Dim,
		BorderSizePixel = 0,
	}, self.page), "BackgroundColor3", "Dim")
end

-- [>] Nome
function Tab:Button(name, cb)
	local text = "[>] " .. name
	local r = row(self, text)
	r.MouseButton1Click:Connect(function()
		local t = self.lib.Theme
		local m = mouse()
		self.lib.Screen:burst(m.X, m.Y, t.Accent, 12)
		self.lib.Screen:boost(2.5)
		E.decode(r, text, 0.3)
		TweenService:Create(r, TweenInfo.new(0.08), { BackgroundColor3 = Color3.new(1, 1, 1) }):Play()
		task.delay(0.1, function()
			if r.Parent then
				TweenService:Create(r, TweenInfo.new(0.3), { BackgroundColor3 = self.lib.Theme.Panel }):Play()
			end
		end)
		if cb then
			cb()
		end
	end)
	return r
end

-- [>] Nome   [ ON ]
function Tab:Toggle(name, default, cb)
	local state = default == true
	local r = row(self, "[>] " .. name)
	local T = self.lib.Theme
	local val = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -40, 1, 0),
		Font = T.Font,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = T.Accent,
		Text = "",
	}, r)
	local dot = U.make("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(10, 10),
		BorderSizePixel = 0,
		BackgroundColor3 = T.Dim,
	}, r)
	local function render(animate)
		local t = self.lib.Theme
		local txt = state and "[ ON ]" or "[ OFF ]"
		if animate then
			E.decode(val, txt, 0.2)
		else
			val.Text = txt
		end
		val.TextColor3 = state and t.Accent or t.Dim
		TweenService:Create(dot, TweenInfo.new(0.2), { BackgroundColor3 = state and t.Accent or t.Dim }):Play()
	end
	render(false)
	table.insert(self.lib._refresh, function()
		render(false)
	end)
	r.MouseButton1Click:Connect(function()
		state = not state
		local m = mouse()
		local t = self.lib.Theme
		self.lib.Screen:burst(m.X, m.Y, state and t.Accent or t.Dim, 8)
		render(true)
		if cb then
			cb(state)
		end
	end)
	return function()
		return state
	end
end

-- [>] Velocidade: 5  + barra
function Tab:Slider(name, min, max, default, cb)
	local T = self.lib.Theme
	local value = default or min
	local holder = U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
	}, self.page), "BackgroundColor3", "Panel")
	U.paint(U.stroke(holder, T.Dim), "Color", "Dim")
	local lbl = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 4),
		Size = UDim2.new(1, -20, 0, 18),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, holder), "TextColor3", "Accent")
	local bar = U.paint(U.make("Frame", {
		Position = UDim2.fromOffset(10, 28),
		Size = UDim2.new(1, -20, 0, 6),
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
	}, holder), "BackgroundColor3", "Black")
	U.paint(U.stroke(bar, T.Dim), "Color", "Dim")
	local fill = U.paint(U.make("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = T.Accent,
		BorderSizePixel = 0,
	}, bar), "BackgroundColor3", "Accent")

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
				self.lib.Screen:burst(m.X, m.Y, self.lib.Theme.Accent, 6)
			end
			sliding = false
		end
	end))
	return function()
		return value
	end
end

-- [+] Modo: Normal  (clique para abrir a lista)
function Tab:Dropdown(name, options, default, cb)
	local current = default or options[1]
	local box = U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, self.page)
	U.make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, box)

	local header = row(self, "", box)
	local function headText(open)
		return (open and "[-] " or "[+] ") .. name .. ": " .. tostring(current)
	end
	header.Text = headText(false)

	local T = self.lib.Theme
	local list = U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
		Visible = false,
	}, box), "BackgroundColor3", "Black")
	U.paint(U.stroke(list, T.Dim), "Color", "Dim")
	U.make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, list)
	U.pad(list, 4, 4, 4, 4)

	local open = false
	local function setOpen(v)
		open = v
		list.Visible = v
		header.Text = headText(v)
	end
	header.MouseButton1Click:Connect(function()
		setOpen(not open)
	end)
	for _, opt in ipairs(options) do
		local item = row(self, "   " .. tostring(opt), list)
		item.Size = UDim2.new(1, 0, 0, 26)
		item.MouseButton1Click:Connect(function()
			current = opt
			setOpen(false)
			E.decode(header, headText(false), 0.2)
			if cb then
				cb(opt)
			end
		end)
	end
	return function()
		return current
	end
end

-- Caixa de texto: cb(texto, enterPressionado)
function Tab:Textbox(name, placeholder, cb)
	local T = self.lib.Theme
	local holder = U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
	}, self.page), "BackgroundColor3", "Panel")
	local edge = U.paint(U.stroke(holder, T.Dim), "Color", "Dim")
	local lbl = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(0.45, -10, 1, 0),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, holder), "TextColor3", "Accent")
	E.decode(lbl, "[>] " .. name, 0.3)
	local input = U.paint(U.make("TextBox", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0.45, 0, 0, 0),
		Size = UDim2.new(0.55, -10, 1, 0),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		PlaceholderText = placeholder or "...",
		PlaceholderColor3 = T.Dim,
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, holder), "TextColor3", "Accent")
	U.paint(input, "PlaceholderColor3", "Dim")
	input.Focused:Connect(function()
		TweenService:Create(edge, TweenInfo.new(0.15), { Color = self.lib.Theme.Accent }):Play()
	end)
	input.FocusLost:Connect(function(enter)
		TweenService:Create(edge, TweenInfo.new(0.15), { Color = self.lib.Theme.Dim }):Play()
		if cb then
			cb(input.Text, enter)
		end
	end)
	return function()
		return input.Text
	end
end

-- Barra de progresso: retorna set(valor 0..1, animar?)
function Tab:Progress(name, initial)
	local T = self.lib.Theme
	local holder = U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
	}, self.page), "BackgroundColor3", "Panel")
	U.paint(U.stroke(holder, T.Dim), "Color", "Dim")
	local lbl = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 4),
		Size = UDim2.new(1, -20, 0, 18),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, holder), "TextColor3", "Accent")
	local bar = U.paint(U.make("Frame", {
		Position = UDim2.fromOffset(10, 28),
		Size = UDim2.new(1, -20, 0, 6),
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
	}, holder), "BackgroundColor3", "Black")
	U.paint(U.stroke(bar, T.Dim), "Color", "Dim")
	local fill = U.paint(U.make("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = T.Accent,
		BorderSizePixel = 0,
	}, bar), "BackgroundColor3", "Accent")

	local value = 0
	local function set(v, animate)
		value = math.clamp(v, 0, 1)
		TweenService:Create(fill, TweenInfo.new(animate and 0.35 or 0), { Size = UDim2.fromScale(value, 1) }):Play()
		lbl.Text = string.format("%s: %d%%", name, math.floor(value * 100 + 0.5))
	end
	set(initial or 0, false)
	return set
end

return Tab
