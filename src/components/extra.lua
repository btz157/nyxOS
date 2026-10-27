local req = ...
local U = req("src/core/util")
local E = req("src/core/effects")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- Componentes extras. Recebe a classe Tab e a classe Window.
return function(Tab, Window)
	local function mouse()
		return UIS:GetMouseLocation()
	end

	local function box(self, parent)
		local f = U.make("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, parent or self.page)
		U.make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, f)
		return f
	end

	local function heading(self, text, parent)
		local T = self.lib.Theme
		return U.paint(U.make("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Font = T.Font,
			TextSize = 14,
			TextColor3 = T.Accent,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "[ " .. text .. " ]",
		}, parent or self.page), "TextColor3", "Accent")
	end

	local function label(self, text, parent, h)
		local T = self.lib.Theme
		return U.paint(U.make("TextLabel", {
			Size = UDim2.new(1, 0, 0, h or 18),
			BackgroundTransparency = 1,
			Font = T.Font,
			TextSize = 14,
			TextColor3 = T.Accent,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Text = text or "",
		}, parent or self.page), "TextColor3", "Accent")
	end

	-- Linha clicável com borda que acende no hover
	local function item(self, text, parent, h)
		local T = self.lib.Theme
		local r = U.paint(U.make("TextButton", {
			Size = UDim2.new(1, 0, 0, h or 28),
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

	-- Caixa de texto estilizada
	local function inputBox(self, placeholder, parent)
		local T = self.lib.Theme
		local tb = U.paint(U.make("TextBox", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = T.Black,
			BorderSizePixel = 0,
			Font = T.Font,
			TextSize = 15,
			TextColor3 = T.Accent,
			PlaceholderText = placeholder or "...",
			PlaceholderColor3 = T.Dim,
			Text = "",
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, parent or self.page), "BackgroundColor3", "Black")
		U.paint(tb, "TextColor3", "Accent")
		U.paint(tb, "PlaceholderColor3", "Dim")
		U.pad(tb, 8, 8, 0, 0)
		U.paint(U.stroke(tb, T.Dim), "Color", "Dim")
		return tb
	end

	local RW = 24
	local SPARK = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }

	-- ===== Seleção e entrada =====

	-- [x] múltipla escolha. Retorna função que devolve a lista escolhida
	function Tab:Checklist(name, options, defaults, cb)
		local sel = {}
		for _, v in ipairs(defaults or {}) do
			sel[v] = true
		end
		local function selected()
			local out = {}
			for _, o in ipairs(options) do
				if sel[o] then
					out[#out + 1] = o
				end
			end
			return out
		end
		local c = box(self)
		heading(self, name, c)
		local items = {}
		local function render()
			local t = self.lib.Theme
			for _, it in ipairs(items) do
				local on = sel[it.opt] == true
				it.btn.Text = (on and "  [x] " or "  [ ] ") .. tostring(it.opt)
				it.btn.TextColor3 = on and t.Accent or t.Dim
			end
		end
		for _, opt in ipairs(options) do
			local b = item(self, "", c, 26)
			b.MouseButton1Click:Connect(function()
				sel[opt] = not sel[opt]
				render()
				if cb then
					cb(selected())
				end
			end)
			items[#items + 1] = { btn = b, opt = opt }
		end
		render()
		table.insert(self.lib._refresh, render)
		return selected
	end

	-- Paleta de cores. Retorna função que devolve a cor atual
	function Tab:Palette(name, colors, default, cb)
		local cur = default or colors[1]
		local c = box(self)
		heading(self, name, c)
		local grid = U.make("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, c)
		U.make("UIGridLayout", {
			CellSize = UDim2.fromOffset(36, 26),
			CellPadding = UDim2.fromOffset(6, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, grid)
		local hexL = label(self, "", c)
		local strokes = {}
		local function hex(col)
			return string.format("#%02X%02X%02X", math.floor(col.R * 255 + 0.5), math.floor(col.G * 255 + 0.5), math.floor(col.B * 255 + 0.5))
		end
		local function render()
			for i, s in ipairs(strokes) do
				s.Transparency = colors[i] == cur and 0 or 1
			end
			hexL.Text = "cor: " .. hex(cur)
		end
		for i, col in ipairs(colors) do
			local s = U.make("TextButton", {
				BackgroundColor3 = col,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
				LayoutOrder = i,
			}, grid)
			local st = U.stroke(s, Color3.new(1, 1, 1), 2)
			table.insert(strokes, st)
			s.MouseButton1Click:Connect(function()
				cur = col
				render()
				if cb then
					cb(col, hex(col))
				end
			end)
		end
		render()
		return function()
			return cur
		end
	end

	-- [>] Nome   [-]  5  [+]   (botões separados: cada um faz a sua ação)
	function Tab:Stepper(name, min, max, default, step, cb)
		step = step or 1
		local T = self.lib.Theme
		local v = default or min
		local row = U.paint(U.make("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = T.Panel,
			BorderSizePixel = 0,
		}, self.page), "BackgroundColor3", "Panel")
		U.paint(U.stroke(row, T.Dim), "Color", "Dim")
		local lbl = U.paint(U.make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(10, 0),
			Size = UDim2.new(1, -150, 1, 0),
			Font = T.Font,
			TextSize = 15,
			TextColor3 = T.Accent,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "",
		}, row), "TextColor3", "Accent")
		local valL = U.paint(U.make("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -50, 0.5, 0),
			Size = UDim2.fromOffset(40, 22),
			Font = T.Font,
			TextSize = 15,
			TextColor3 = T.Accent,
			Text = "",
		}, row), "TextColor3", "Accent")
		local function mkBtn(text, xOff)
			local b = U.paint(U.make("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, xOff, 0.5, 0),
				Size = UDim2.fromOffset(34, 22),
				BackgroundColor3 = T.Black,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Font = T.Font,
				TextSize = 15,
				TextColor3 = T.Accent,
				Text = text,
			}, row), "TextColor3", "Accent")
			U.paint(U.stroke(b, T.Dim), "Color", "Dim")
			b.MouseEnter:Connect(function()
				b.BackgroundColor3 = self.lib.Theme.Accent
				b.TextColor3 = self.lib.Theme.Black
			end)
			b.MouseLeave:Connect(function()
				b.BackgroundColor3 = self.lib.Theme.Black
				b.TextColor3 = self.lib.Theme.Accent
			end)
			return b
		end
		local minus = mkBtn("[-]", -96)
		local plus = mkBtn("[+]", -8)
		local function render()
			lbl.Text = string.format("[>] %s", name)
			valL.Text = string.format("%g", v)
		end
		local function change(dir)
			local nv = math.clamp(v + dir * step, min, max)
			if nv ~= v then
				v = nv
				render()
				if cb then
					cb(v)
				end
			end
		end
		minus.MouseButton1Click:Connect(function()
			change(-1)
		end)
		plus.MouseButton1Click:Connect(function()
			change(1)
		end)
		render()
		return function()
			return v
		end
	end

	-- Barra de intervalo: arraste para mover o início ou o fim
	local function rbar(lo, hi, min, max)
		local out = {}
		for i = 1, RW do
			local v = min + (max - min) * (i - 1) / (RW - 1)
			out[i] = (v >= lo and v <= hi) and "█" or "░"
		end
		return table.concat(out)
	end

	function Tab:Range(name, min, max, lo, hi, cb)
		lo, hi = lo or min, hi or max
		local T = self.lib.Theme
		local holder = U.paint(U.make("Frame", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = T.Panel,
			BorderSizePixel = 0,
			Active = true,
		}, self.page), "BackgroundColor3", "Panel")
		U.paint(U.stroke(holder, T.Dim), "Color", "Dim")
		local lbl = label(self, "", holder, 36)
		lbl.Position = UDim2.fromOffset(10, 0)
		lbl.Size = UDim2.new(1, -20, 1, 0)
		lbl.TextYAlignment = Enum.TextYAlignment.Center
		local function render()
			lbl.Text = string.format("[>] %s  %s %g-%g", name, rbar(lo, hi, min, max), lo, hi)
		end
		render()
		local dragging, target = false, "lo"
		local function valueAt(input)
			local rel = math.clamp((input.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1)
			return math.floor(min + (max - min) * rel + 0.5)
		end
		local function set(input)
			local v = valueAt(input)
			if target == "lo" then
				lo = math.min(v, hi)
			else
				hi = math.max(v, lo)
			end
			render()
			if cb then
				cb(lo, hi)
			end
		end
		holder.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				local v = valueAt(i)
				target = math.abs(v - lo) <= math.abs(v - hi) and "lo" or "hi"
				set(i)
			end
		end)
		table.insert(self.lib._conns, UIS.InputChanged:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				set(i)
			end
		end))
		table.insert(self.lib._conns, UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end))
		return function()
			return lo, hi
		end
	end

	-- Busca: filtra a lista enquanto você digita. onPick(item) ao clicar
	function Tab:Search(name, items, onPick)
		local c = box(self)
		heading(self, name, c)
		local tb = inputBox(self, "buscar...", c)
		local list = box(self, c)
		local rows = {}
		for _, it in ipairs(items) do
			local r = item(self, "  " .. tostring(it), list, 26)
			r.MouseButton1Click:Connect(function()
				if onPick then
					onPick(it)
				end
			end)
			rows[#rows + 1] = { r = r, t = string.lower(tostring(it)) }
		end
		tb:GetPropertyChangedSignal("Text"):Connect(function()
			local q = string.lower(tb.Text)
			for _, x in ipairs(rows) do
				x.r.Visible = q == "" or string.find(x.t, q, 1, true) ~= nil
			end
		end)
		return tb
	end

	-- Terminal: caixa de comando + console. cb(texto, log) ao apertar Enter
	function Tab:Terminal(prompt, height, cb)
		local log = self:Console(height or 160)
		local tb = inputBox(self, "digite um comando e aperte Enter", self.page)
		tb.FocusLost:Connect(function(enter)
			if not enter or tb.Text == "" then
				return
			end
			local txt = tb.Text
			tb.Text = ""
			log((prompt or "$") .. " " .. txt)
			if cb then
				cb(txt, log)
			end
		end)
		return log
	end

	-- ===== Exibição e dados =====

	-- Tabela com cabeçalho. Retorna set(linhas) para atualizar
	function Tab:Table(headers, rows)
		local c = box(self)
		local function fmt(cells)
			local parts = {}
			for i, h in ipairs(cells) do
				parts[i] = string.format("%-14s", tostring(h))
			end
			return table.concat(parts)
		end
		label(self, fmt(headers), c)
		label(self, string.rep("─", #fmt(headers)), c)
		local body = label(self, "", c, 0)
		body.AutomaticSize = Enum.AutomaticSize.Y
		local function set(data)
			local lines = {}
			for _, r in ipairs(data or {}) do
				lines[#lines + 1] = fmt(r)
			end
			body.Text = table.concat(lines, "\n")
		end
		set(rows)
		return set
	end

	-- Gráfico de barrinhas ▁▂▃▄▅▆▇█. Retorna push(valor)
	function Tab:Sparkline(name, maxN)
		maxN = maxN or 30
		local data = {}
		local c = box(self)
		heading(self, name, c)
		local lbl = label(self, "", c)
		local function render()
			if #data == 0 then
				return
			end
			local lo, hi = data[1], data[1]
			for _, v in ipairs(data) do
				lo = math.min(lo, v)
				hi = math.max(hi, v)
			end
			local out = {}
			for i, v in ipairs(data) do
				local r = hi == lo and 0.5 or (v - lo) / (hi - lo)
				out[i] = SPARK[math.clamp(math.floor(r * 7 + 1.5), 1, 8)]
			end
			lbl.Text = table.concat(out)
		end
		return function(v)
			table.insert(data, v)
			while #data > maxN do
				table.remove(data, 1)
			end
			render()
		end
	end

	-- Etiqueta colorida: [ ONLINE ]
	function Tab:Badge(text, color)
		local T = self.lib.Theme
		local b = U.make("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Font = T.Font,
			TextSize = 14,
			TextColor3 = color or T.Accent,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "[ " .. tostring(text) .. " ]",
		}, self.page)
		if not color then
			U.paint(b, "TextColor3", "Accent")
		end
		return b
	end

	-- Indicador girando: | / - \ ao lado do texto
	function Tab:Spinner(text)
		local lbl = label(self, "", nil, 20)
		local frames = { "|", "/", "-", "\\" }
		task.spawn(function()
			local i = 1
			while lbl.Parent do
				lbl.Text = frames[i] .. " " .. tostring(text or "")
				i = i % #frames + 1
				task.wait(0.1)
			end
		end)
		return lbl
	end

	-- Linhas de histórico de notificações
	function Tab:History(height)
		local c = box(self)
		heading(self, "Histórico", c)
		local frame = U.make("Frame", {
			Size = UDim2.new(1, 0, 0, height or 140),
			BackgroundColor3 = self.lib.Theme.Black,
			BorderSizePixel = 0,
			ClipsDescendants = true,
		}, c)
		U.paint(U.stroke(frame, self.lib.Theme.Dim), "Color", "Dim")
		local out = label(self, "", frame, 0)
		out.Size = UDim2.new(1, -16, 1, -12)
		out.Position = UDim2.fromOffset(8, 6)
		out.TextYAlignment = Enum.TextYAlignment.Bottom
		out.TextSize = 13
		out.TextWrapped = true
		local function render()
			local lines = {}
			for i = 1, math.min(#(self.lib._hist or {}), 12) do
				lines[i] = "> " .. self.lib._hist[i]
			end
			out.Text = table.concat(lines, "\n")
		end
		render()
		self.lib._histRefresh = self.lib._histRefresh or {}
		table.insert(self.lib._histRefresh, render)
		return out
	end

	-- Botões lado a lado: { {"Nome", cb}, ... }
	function Tab:Buttons(list)
		local T = self.lib.Theme
		local f = U.make("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, self.page)
		U.make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, f)
		for i, p in ipairs(list) do
			local b = U.paint(U.make("TextButton", {
				Size = UDim2.new(1 / #list, -6, 1, 0),
				BackgroundColor3 = T.Panel,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Font = T.Font,
				TextSize = 14,
				TextColor3 = T.Accent,
				Text = "[ " .. p[1] .. " ]",
				LayoutOrder = i,
			}, f), "BackgroundColor3", "Panel")
			U.paint(b, "TextColor3", "Accent")
			U.paint(U.stroke(b, T.Dim), "Color", "Dim")
			b.MouseEnter:Connect(function()
				b.BackgroundColor3 = self.lib.Theme.Accent
				b.TextColor3 = self.lib.Theme.Black
			end)
			b.MouseLeave:Connect(function()
				b.BackgroundColor3 = self.lib.Theme.Panel
				b.TextColor3 = self.lib.Theme.Accent
			end)
			b.MouseButton1Click:Connect(function()
				if p[2] then
					p[2]()
				end
			end)
		end
		return f
	end

	-- Seção recolhível. Retorna um "sub-painel": use os mesmos componentes dentro dela
	function Tab:Collapsible(name, open)
		local c = box(self)
		local header = item(self, "", c, 28)
		local content = U.make("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = open == true,
		}, c)
		U.make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, content)
		U.pad(content, 10, 0, 4, 4)
		local isOpen = open == true
		local function render()
			header.Text = (isOpen and "[-] " or "[+] ") .. name
			content.Visible = isOpen
		end
		render()
		header.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			render()
		end)
		return setmetatable({ lib = self.lib, page = content, name = name }, Tab)
	end

	-- Dica que aparece ao passar o mouse sobre um objeto
	function Tab:Tooltip(obj, text)
		local T = self.lib.Theme
		local tip = U.make("TextLabel", {
			Size = UDim2.fromOffset(260, 22),
			BackgroundColor3 = T.Black,
			BorderSizePixel = 0,
			Visible = false,
			Font = T.Font,
			TextSize = 13,
			TextColor3 = T.Accent,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = " " .. tostring(text),
			ZIndex = 100,
		}, self.lib.Gui)
		U.paint(tip, "TextColor3", "Accent")
		U.paint(U.stroke(tip, T.Accent), "Color", "Accent")
		obj.MouseEnter:Connect(function()
			tip.Visible = true
		end)
		obj.MouseLeave:Connect(function()
			tip.Visible = false
		end)
		table.insert(self.lib._conns, UIS.InputChanged:Connect(function(i)
			if tip.Visible and i.UserInputType == Enum.UserInputType.MouseMovement then
				local m = mouse()
				tip.Position = UDim2.fromOffset(m.X + 14, m.Y + 12)
			end
		end))
		return tip
	end

	-- Ficha chave: valor com uma linha por item, em formato de terminal
	function Tab:KeyValue(list)
		return self:Stats("Dados", list)
	end

	-- ===== Janela =====

	-- Caixa de confirmação genérica
	function Window:Dialog(message, onYes, onNo)
		local T = self.Theme
		local dim = U.make("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = T.Black,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			ZIndex = 60,
		}, self.Window)
		local dlg = U.paint(U.make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(380, 140),
			BackgroundColor3 = T.Panel,
			BorderSizePixel = 0,
			ZIndex = 61,
		}, dim), "BackgroundColor3", "Panel")
		U.paint(U.stroke(dlg, T.Accent, 1.5), "Color", "Accent")
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
		}, dlg), "TextColor3", "Accent")
		E.decode(msg, "[ ? ] " .. tostring(message), 0.4)
		local function btn(text, px, cb)
			local b = U.make("TextButton", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(px, 0, 1, -16),
				Size = UDim2.new(0.4, 0, 0, 34),
				BackgroundColor3 = T.Black,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Font = T.Font,
				TextSize = 15,
				TextColor3 = T.Accent,
				Text = text,
				ZIndex = 62,
			}, dlg)
			U.stroke(b, T.Accent)
			b.MouseEnter:Connect(function()
				b.BackgroundColor3 = self.Theme.Accent
				b.TextColor3 = self.Theme.Black
			end)
			b.MouseLeave:Connect(function()
				b.BackgroundColor3 = self.Theme.Black
				b.TextColor3 = self.Theme.Accent
			end)
			b.MouseButton1Click:Connect(cb)
		end
		btn("[ SIM ]", 0.07, function()
			dim:Destroy()
			if onYes then
				onYes()
			end
		end)
		btn("[ NÃO ]", 0.53, function()
			dim:Destroy()
			if onNo then
				onNo()
			end
		end)
	end

	-- Guarda o histórico de notificações (para o componente History)
	local origNotify = Window.Notify
	function Window:Notify(text, duration, kind, title)
		self._hist = self._hist or {}
		table.insert(self._hist, 1, os.date("%H:%M:%S") .. "  " .. tostring(text))
		while #self._hist > 50 do
			table.remove(self._hist)
		end
		for _, fn in ipairs(self._histRefresh or {}) do
			fn()
		end
		return origNotify(self, text, duration, kind, title)
	end

	-- Foto do personagem em círculo (no cartão do menu)
	function Window:SetAvatar(id)
		if self._skinImg then
			self._skinImg.Image = Tab.asset(id)
		end
	end

	local origCard = Window._buildCard
	function Window:_buildCard()
		origCard(self)
		local T = self.Theme
		U.make("UICorner", { CornerRadius = UDim.new(1, 0) }, self._skinImg)
		U.paint(U.stroke(self._skinImg, T.Accent, 1.5), "Color", "Accent")
	end

	-- Emoji como foto (sem id): skin e avatar
	local function isEmoji(s)
		return type(s) == "string" and s ~= "" and not string.find(s, "rbx", 1, true) and not tonumber(s)
	end

	local origCard2 = Window._buildCard
	function Window:_buildCard()
		origCard2(self)
		self._skinEmoji = U.paint(U.make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(6, 6),
			Size = UDim2.fromOffset(60, 60),
			Font = self.Theme.Font,
			TextSize = 40,
			TextColor3 = self.Theme.Accent,
			Text = "",
			ZIndex = 8,
		}, self._skinCard), "TextColor3", "Accent")
	end

	local origSet = Window._setSkin
	function Window:_setSkin(s)
		origSet(self, s)
		if s and s.Real then
			self._skinImg.Image = "rbxthumb://type=AvatarBust&id=" .. tostring(game:GetService("Players").LocalPlayer.UserId) .. "&w=420&h=420"
			self._skinImg.Visible = true
			self._skinEmoji.Visible = false
		end
		if not self._skinEmoji or not s then
			return
		end
		local useEmoji = s.Emoji ~= nil
		self._skinEmoji.Visible = useEmoji
		self._skinImg.Visible = not useEmoji
		if useEmoji then
			self._skinEmoji.Text = tostring(s.Emoji)
		end
	end

	-- Avatar: aceita emoji ou id de imagem
	function Window:SetAvatar(src)
		if not self._skinEmoji then
			return
		end
		if isEmoji(src) then
			self._skinEmoji.Text = src
			self._skinEmoji.Visible = true
			self._skinImg.Visible = false
		else
			self._skinImg.Image = Tab.asset(src)
			self._skinImg.Visible = true
			self._skinEmoji.Visible = false
		end
	end
end
