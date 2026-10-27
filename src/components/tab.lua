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

-- Id de imagem: aceita número (123456) ou texto ("rbxassetid://123456")
local function assetUrl(id)
	if id == nil then
		return ""
	end
	if type(id) == "number" then
		return "rbxassetid://" .. id
	end
	return tostring(id)
end
Tab.asset = assetUrl
local function isEmoji(s) return type(s) == "string" and s ~= "" and not string.find(s, "rbx", 1, true) and not tonumber(s) end

-- icon (opcional): id de imagem mostrado ao lado do nome da aba
function Tab.new(lib, name, desc, icon)
	local T = lib.Theme
	local prefix = icon and "      " or "  "
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
		Text = prefix .. name,
	}, lib._side)
	if icon then
		if isEmoji(icon) then
			U.make("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(6, 3),
				Size = UDim2.fromOffset(22, 24),
				Font = T.Font,
				TextSize = 16,
				TextColor3 = T.Accent,
				Text = tostring(icon),
				ZIndex = 2,
			}, btn)
		else
			U.paint(U.make("ImageLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(8, 6),
				Size = UDim2.fromOffset(18, 18),
				Image = assetUrl(icon),
				ImageColor3 = T.Accent,
				ZIndex = 2,
			}, btn), "ImageColor3", "Accent")
		end
	end
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
		prefix = prefix,
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

-- Barra em quadradinhos estilo terminal: █ preenchido, ░ vazio
local BAR_W = 20
local function tbar(rel)
	local n = math.floor(math.clamp(rel, 0, 1) * BAR_W + 0.5)
	return string.rep("█", n) .. string.rep("░", BAR_W - n)
end

-- [>] Velocidade  ██████░░░░  5   (arraste ou clique)
function Tab:Slider(name, min, max, default, cb)
	local T = self.lib.Theme
	local value = default or min
	local holder = U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
		Active = true,
	}, self.page), "BackgroundColor3", "Panel")
	U.paint(U.stroke(holder, T.Dim), "Color", "Dim")
	local lbl = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -20, 1, 0),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, holder), "TextColor3", "Accent")

	local function render()
		lbl.Text = string.format("[>] %s  %s %g", name, tbar((value - min) / (max - min)), value)
	end
	render()

	local sliding = false
	local function set(input)
		local rel = math.clamp((input.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1)
		local nv = math.floor(min + (max - min) * rel + 0.5)
		if nv ~= value then
			value = nv
			render()
			if cb then
				cb(value)
			end
		end
	end
	holder.InputBegan:Connect(function(i)
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

-- Progresso em quadradinhos: [>] Carregamento  ████░░░░  40%
function Tab:Progress(name, initial)
	local T = self.lib.Theme
	local holder = U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
	}, self.page), "BackgroundColor3", "Panel")
	U.paint(U.stroke(holder, T.Dim), "Color", "Dim")
	local lbl = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -20, 1, 0),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, holder), "TextColor3", "Accent")

	local value = 0
	local function set(v)
		value = math.clamp(v, 0, 1)
		lbl.Text = string.format("[>] %s  %s %d%%", name, tbar(value), math.floor(value * 100 + 0.5))
	end
	set(initial or 0)
	return set
end

-- Console estilo terminal: retorna log(texto), que digita cada linha
function Tab:Console(height)
	local T = self.lib.Theme
	local frame = U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, height or 150),
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, self.page), "BackgroundColor3", "Black")
	U.paint(U.stroke(frame, T.Dim), "Color", "Dim")
	local out = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 1, -12),
		Position = UDim2.fromOffset(8, 6),
		Font = T.Font,
		TextSize = 13,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Bottom,
		TextWrapped = true,
		Text = "",
	}, frame), "TextColor3", "Accent")
	local buf, queue, busy = {}, {}, false
	local function pump()
		if busy then
			return
		end
		busy = true
		task.spawn(function()
			while #queue > 0 do
				local text = table.remove(queue, 1)
				local idx = #buf + 1
				buf[idx] = "> "
				for _, ch in ipairs(U.chars(text)) do
					if not out.Parent then
						return
					end
					buf[idx] = buf[idx] .. ch
					out.Text = table.concat(buf, "\n") .. "_"
					task.wait(0.012)
				end
				buf[idx] = "> " .. text
				while #buf > 14 do
					table.remove(buf, 1)
				end
				out.Text = table.concat(buf, "\n")
			end
			busy = false
		end)
	end
	return function(text)
		queue[#queue + 1] = tostring(text)
		pump()
	end
end

-- [>] Nome   [ F ]  (clique e pressione a tecla; onPress roda ao apertar)
function Tab:Keybind(name, default, onPress)
	local T = self.lib.Theme
	local key = default or Enum.KeyCode.F
	local listening = false
	local r = row(self, "[>] " .. name)
	local val = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 1, 0),
		Font = T.Font,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = T.Accent,
		Text = "[ " .. key.Name .. " ]",
	}, r)
	local function refresh()
		local t = self.lib.Theme
		val.TextColor3 = listening and t.Dim or t.Accent
	end
	table.insert(self.lib._refresh, refresh)
	r.MouseButton1Click:Connect(function()
		listening = true
		val.Text = "[ ... ]"
		refresh()
	end)
	table.insert(self.lib._conns, UIS.InputBegan:Connect(function(input, gp)
		if listening and input.UserInputType == Enum.UserInputType.Keyboard then
			listening = false
			key = input.KeyCode
			val.Text = "[ " .. key.Name .. " ]"
			refresh()
			return
		end
		if not gp and input.KeyCode == key and onPress then
			onPress()
		end
	end))
	return function()
		return key
	end
end

-- Estatística ao vivo: atualiza a cada 0.5s chamando fn()
function Tab:Stat(name, fn)
	local T = self.lib.Theme
	local lbl = U.paint(U.make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, self.page), "TextColor3", "Accent")
	task.spawn(function()
		while lbl.Parent do
			local ok, v = pcall(fn)
			lbl.Text = string.format("[>] %s: %s", name, ok and tostring(v) or "?")
			task.wait(0.5)
		end
	end)
	return lbl
end

-- Cartão com título e texto. Retorna o cartão e o rótulo do texto
function Tab:Card(title, body)
	local T = self.lib.Theme
	local card = U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
	}, self.page), "BackgroundColor3", "Panel")
	U.paint(U.stroke(card, T.Dim), "Color", "Dim")
	U.make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, card)
	U.pad(card, 10, 10, 8, 8)
	U.paint(U.make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "[ " .. title .. " ]",
		LayoutOrder = 1,
	}, card), "TextColor3", "Accent")
	local text = U.paint(U.make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = T.Font,
		TextSize = 14,
		TextColor3 = T.Accent,
		TextTransparency = 0.2,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = body or "",
		LayoutOrder = 2,
	}, card), "TextColor3", "Accent")
	return card, text
end

-- Ficha chave: valor. Retorna set(chave, valor) para atualizar
function Tab:Stats(title, list)
	local _, body = self:Card(title, "")
	local data, order = {}, {}
	for _, p in ipairs(list) do
		data[p[1]] = p[2]
		order[#order + 1] = p[1]
	end
	local function render()
		local lines = {}
		for _, k in ipairs(order) do
			lines[#lines + 1] = string.format("%-12s %s", k, tostring(data[k]))
		end
		body.Text = table.concat(lines, "\n")
	end
	render()
	return function(k, v)
		if data[k] == nil then
			order[#order + 1] = k
		end
		data[k] = v
		render()
	end
end

-- Escolha única em lista: (*) selecionado, ( ) outros
function Tab:Radio(name, options, default, cb)
	local T = self.lib.Theme
	local current = default or options[1]
	local box = U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, self.page)
	U.make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, box)
	U.paint(U.make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Font = T.Font,
		TextSize = 14,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "[ " .. name .. " ]",
		LayoutOrder = 0,
	}, box), "TextColor3", "Accent")

	local items = {}
	local function render()
		local t = self.lib.Theme
		for _, it in ipairs(items) do
			local on = it.opt == current
			it.btn.Text = (on and "  (*) " or "  ( ) ") .. tostring(it.opt)
			it.btn.TextColor3 = on and t.Accent or t.Dim
		end
	end
	for i, opt in ipairs(options) do
		local b = row(self, "", box)
		b.LayoutOrder = i
		b.Size = UDim2.new(1, 0, 0, 26)
		b.MouseButton1Click:Connect(function()
			current = opt
			render()
			if cb then
				cb(opt)
			end
		end)
		items[#items + 1] = { btn = b, opt = opt }
	end
	render()
	table.insert(self.lib._refresh, render)
	return function()
		return current
	end
end

-- Imagem: emoji (ex.: "🎮") ou id do Roblox. height em pixels
function Tab:Image(src, height)
	local T = self.lib.Theme
	local h = height or 120
	local frame = U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, h),
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
	}, self.page), "BackgroundColor3", "Black")
	U.paint(U.stroke(frame, T.Dim), "Color", "Dim")
	if isEmoji(src) then
		U.paint(U.make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Font = T.Font,
			TextSize = math.floor(h * 0.6),
			TextColor3 = T.Accent,
			Text = tostring(src),
		}, frame), "TextColor3", "Accent")
		return frame
	end
	return U.make("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Image = assetUrl(src),
		ScaleType = Enum.ScaleType.Fit,
	}, frame)
end

return Tab
