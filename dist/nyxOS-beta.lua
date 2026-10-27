--[[ nyxOS 2.6.0-beta | BETA: versão de testes, pode mudar ]]
local __M, __C = {}, {}
local function __req(p)
	if __C[p] == nil then
		local f = __M[p]
		assert(f, "nyxOS: módulo não encontrado: " .. tostring(p))
		__C[p] = f(__req)
	end
	return __C[p]
end

__M["src/components/extra"] = function(...)
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
				tip.Position = UDim2.fromOffset(math.min(m.X + 14, workspace.CurrentCamera.ViewportSize.X - 270), math.min(m.Y + 12, workspace.CurrentCamera.ViewportSize.Y - 30))
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

	-- Erros dentro das suas funções viram notificação (a interface continua funcionando)
	local GUARDED = {
		Button = 2, Toggle = 3, Slider = 5, Dropdown = 4, Radio = 4, Textbox = 3,
		Stepper = 6, Range = 6, Checklist = 4, Keybind = 3, Palette = 4, Search = 3, Terminal = 3,
	}
	for name, idx in pairs(GUARDED) do
		local orig = Tab[name]
		if orig then
			Tab[name] = function(self, ...)
				local args = table.pack(...)
				local f = args[idx]
				if type(f) == "function" then
					local lib = self.lib
					args[idx] = function(...)
						local ok, err = pcall(f, ...)
						if not ok and lib and lib.Notify then
							lib:Notify(tostring(err), 5, "error", "ERRO NO SCRIPT")
						end
					end
				end
				return orig(self, table.unpack(args, 1, args.n))
			end
		end
	end

	-- No máximo 5 notificações na tela: as mais antigas saem
	local origNotify2 = Window.Notify
	function Window:Notify(text, duration, kind, title)
		local r = origNotify2(self, text, duration, kind, title)
		if self._toasts then
			local toasts = {}
			for _, c in ipairs(self._toasts:GetChildren()) do
				if c:IsA("Frame") then
					table.insert(toasts, c)
				end
			end
			table.sort(toasts, function(a, b)
				return a.LayoutOrder < b.LayoutOrder
			end)
			while #toasts > 5 do
				table.remove(toasts, 1):Destroy()
			end
		end
		return r
	end

	-- ===== Configurações salvas automaticamente (arquivo nyxOS_config.json) =====
	local HttpService = game:GetService("HttpService")
	local FILE = "nyxOS_config.json"
	local store = {}
	local loaded = false

	local function loadStore()
		if loaded then
			return
		end
		loaded = true
		local ok, raw = pcall(function()
			if isfile and isfile(FILE) then
				return readfile(FILE)
			end
		end)
		if ok and raw then
			local ok2, data = pcall(function()
				return HttpService:JSONDecode(raw)
			end)
			if ok2 and type(data) == "table" then
				store = data
			end
		end
	end

	local function saveStore()
		pcall(function()
			if writefile then
				writefile(FILE, HttpService:JSONEncode(store))
			end
		end)
	end

	-- Lê uma configuração salva (ou o padrão)
	function Window:Get(key, default)
		loadStore()
		local v = store[key]
		if v == nil then
			return default
		end
		return v
	end

	-- Salva uma configuração (automático)
	function Window:Set(key, value)
		loadStore()
		store[key] = value
		saveStore()
	end

	function Window:ResetSettings()
		store = {}
		saveStore()
	end

	-- Matrix: opts.Matrix tem prioridade; senão usa a preferência salva
	function Window._matrixOpt(opts, self)
		if opts.Matrix ~= nil then
			return opts.Matrix
		end
		return self:Get("matrix", true)
	end

	-- Aba pronta com as preferências (opcional)
	function Window:SettingsTab()
		local t = self:Tab("Sistema", "preferências salvas automaticamente", "🛠️")
		t:Section("Inicialização")
		t:Toggle("Pular animação inicial", self:Get("skipBoot", false), function(on)
			self:Set("skipBoot", on)
		end)
		t:Toggle("Iniciar minimizado", self:Get("startMinimized", false), function(on)
			self:Set("startMinimized", on)
		end)
		t:Section("Visual")
		t:Toggle("Chuva Matrix", self:Get("matrix", true), function(on)
			self:Set("matrix", on)
			self:Notify("aplicado na próxima execução", 2, "info")
		end)
		t:Section("Arquivo")
		t:Stat("Salvo em", function()
			return FILE
		end)
		t:Button("Restaurar padrões", function()
			self:Dialog("Apagar todas as preferências salvas?", function()
				self:ResetSettings()
				self:Notify("preferências restauradas", 2, "success")
			end)
		end)
		return t
	end
end

end

__M["src/components/tab"] = function(...)
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

-- [>] Velocidade      ████████░░░░░░░░░░░░   5   (arraste ou clique na barra)
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
	U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -270, 1, 0),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "[>] " .. name,
	}, holder), "TextColor3", "Accent")
	local bar = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -66, 0.5, 0),
		Size = UDim2.fromOffset(BAR_W * 9, 22),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, holder), "TextColor3", "Accent")
	local val = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(46, 22),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = "",
	}, holder), "TextColor3", "Accent")

	local function render()
		bar.Text = tbar((value - min) / (max - min))
		val.Text = string.format("%g", value)
	end
	render()

	local sliding = false
	local function set(input)
		local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
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

-- Progresso em quadradinhos: [>] Carregamento   ████░░░░  40%
function Tab:Progress(name, initial)
	local T = self.lib.Theme
	local holder = U.paint(U.make("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = T.Panel,
		BorderSizePixel = 0,
	}, self.page), "BackgroundColor3", "Panel")
	U.paint(U.stroke(holder, T.Dim), "Color", "Dim")
	U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -270, 1, 0),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "[>] " .. name,
	}, holder), "TextColor3", "Accent")
	local bar = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -66, 0.5, 0),
		Size = UDim2.fromOffset(BAR_W * 9, 22),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, holder), "TextColor3", "Accent")
	local pct = U.paint(U.make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(46, 22),
		Font = T.Font,
		TextSize = 15,
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = "",
	}, holder), "TextColor3", "Accent")

	local value = 0
	local function set(v)
		value = math.clamp(v, 0, 1)
		bar.Text = tbar(value)
		pct.Text = string.format("%d%%", math.floor(value * 100 + 0.5))
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
if listening and input.KeyCode == Enum.KeyCode.Escape then listening = false; val.Text = "[ " .. key.Name .. " ]"; refresh(); return end
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
			lines[#lines + 1] = string.format("%-10s %s", k, tostring(data[k]))
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

end

__M["src/core/effects"] = function(...)
local req = ...
local U = req("src/core/util")
local TweenService = game:GetService("TweenService")
local E = {}
local COL = 14

function E.scramble(c)
	local rows = {}
	for i = 1, c.len do
		rows[i] = U.glyph()
	end
	c.lbl.Text = table.concat(rows, "\n")
end

-- Chuva Matrix: cada coluna é um texto com gradiente de brilho (RichText).
-- Topo escuro, meio verde neon, cabeça branca. Duas camadas: fundo (fraco) e frente (forte).
local LAYERS = {
	{ size = 10, lh = 12, col = 12, spd = { 35, 95 }, len = { 8, 22 }, density = 0.9, transp = 0.45 },
	{ size = 15, lh = 17, col = 18, spd = { 110, 240 }, len = { 6, 14 }, density = 0.45, transp = 0.05 },
}

local function esc(s)
	return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function hex(c)
	return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

-- Cor de cada linha: u vai de 0 (topo) a 1 (cabeça)
local function shade(accent, u)
	if u > 0.9 then
		return "#EBFFEB"
	end
	local k = 0.1 + 0.9 * u * u
	return hex(Color3.new(accent.R * k, accent.G * k, accent.B * k))
end

local function paintColors(s, accent)
	for i = 1, s.len do
		s.colors[i] = shade(accent, i / s.len)
	end
end

local function makeText(s)
	local rows = {}
	for i = 1, s.len do
		rows[i] = string.format('<font color="%s">%s</font>', s.colors[i], esc(s.glyphs[i]))
	end
	return table.concat(rows, "\n")
end

local function regen(s)
	s.len = math.random(s.L.len[1], s.L.len[2])
	s.glyphs = {}
	for i = 1, s.len do
		s.glyphs[i] = U.glyph()
	end
	s.colors = {}
	paintColors(s, s.accent)
	s.label.Size = UDim2.fromOffset(s.L.col, s.len * s.L.lh)
	s.label.Text = makeText(s)
end

local function newStream(parent, x, h, theme, L)
	local s = {
		x = x,
		L = L,
		accent = theme.Accent,
		y = math.random(0, math.floor(h)),
		spd = math.random(L.spd[1], L.spd[2]),
	}
	s.label = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(L.col, L.len[1] * L.lh),
		Font = theme.Font,
		TextSize = L.size,
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = L.transp,
		RichText = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = "",
	}, parent)
	regen(s)
	return s
end

function E.rain(parent, w, h, theme)
	local streams = {}
	for _, L in ipairs(LAYERS) do
		for x = 0, math.ceil(w / L.col) do
			if math.random() < L.density then
				streams[#streams + 1] = newStream(parent, x * L.col, h, theme, L)
			end
		end
	end
	return streams
end

function E.step(streams, h, dt, mul)
	mul = mul or 1
	for _, s in ipairs(streams) do
		s.y += s.spd * mul * dt
		if s.y - s.len * s.L.lh > h then
			s.y = -math.random(0, math.floor(h / 3))
			s.spd = math.random(s.L.spd[1], s.L.spd[2])
			regen(s)
		end
		if math.random() < 0.08 then
			s.glyphs[math.random(s.len)] = U.glyph()
			s.label.Text = makeText(s)
		end
		s.label.Position = UDim2.fromOffset(s.x, s.y - s.len * s.L.lh)
	end
end

-- Troca a cor da chuva (usado pelo SetTheme)
function E.recolor(streams, accent)
	for _, s in ipairs(streams) do
		s.accent = accent
		s.colors = {}
		paintColors(s, accent)
		s.label.Text = makeText(s)
	end
end

-- Texto com ruído (glifos trocando)
function E.noisy(final, rate)
	local out = {}
	for i, ch in ipairs(U.chars(final)) do
		out[i] = (ch ~= " " and math.random() < rate) and U.glyph() or ch
	end
	return table.concat(out)
end

-- Decodificação: glifos aleatórios se resolvem no texto final
function E.decode(label, final, duration)
	local target = U.chars(final)
	local n = #target
	task.spawn(function()
		local steps = 12
		for s = 1, steps do
			if not label.Parent then
				return
			end
			local out = {}
			for i = 1, n do
				local ch = target[i]
				if ch == " " or i <= (n * s / steps) then
					out[i] = ch
				else
					out[i] = U.glyph()
				end
			end
			label.Text = table.concat(out)
			task.wait((duration or 0.35) / steps)
		end
		if label.Parent then
			label.Text = final
		end
	end)
end

-- Glitch: pisca ruído no texto e volta ao normal
function E.glitch(label, final, times)
	local base = label.TextColor3
	task.spawn(function()
		for _ = 1, times or 3 do
			if not label.Parent then
				return
			end
			label.Text = E.noisy(final, 0.35)
			label.TextColor3 = Color3.new(1, 1, 1)
			task.wait(0.05)
			label.TextColor3 = base
			task.wait(0.04)
		end
		if label.Parent then
			label.Text = final
		end
	end)
end

-- Partículas de caractere que saem do ponto
function E.burst(parent, x, y, color, count)
	for _ = 1, count or 10 do
		local p = U.make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(14, 14),
			Position = UDim2.fromOffset(x, y),
			Font = Enum.Font.Code,
			TextSize = 14,
			TextColor3 = color,
			Text = U.glyph(),
			ZIndex = 60,
		}, parent)
		local ang = math.random() * math.pi * 2
		local dist = math.random(30, 90)
		TweenService:Create(p, TweenInfo.new(0.5 + math.random() * 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.fromOffset(x + math.cos(ang) * dist, y + math.sin(ang) * dist),
			TextTransparency = 1,
		}):Play()
		task.delay(1, function()
			p:Destroy()
		end)
	end
end

-- Faixa de varredura que atravessa a tela inteira
function E.sweep(parent, color)
	local y = math.random()
	local line = U.make("Frame", {
		Size = UDim2.new(0.35, 0, 0, math.random(1, 3)),
		Position = UDim2.new(-0.35, 0, y, 0),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		ZIndex = 25,
	}, parent)
	local t = TweenService:Create(line, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
		Position = UDim2.new(1, 0, y, 0),
	})
	t:Play()
	t.Completed:Connect(function()
		line:Destroy()
	end)
end

-- Boot em tela cheia com botão SKIP
local LOGO = [==[
 _   _ __   ____  ___  ____
| \ | |\ \ / /\ \/ / _ \/ ___|
|  \| | \ V /  \  / | | \___ \
| |\  |  | |   /  \ |_| |___) |
|_| \_|  |_|  /_/\_\___/|____/
]==]

function E.boot(parent, theme, lines, finalText, onDone)
	local overlay = U.make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.Black,
		BorderSizePixel = 0,
		ZIndex = 50,
	}, parent)
	local logo = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(40, 28),
		Size = UDim2.new(1, -80, 0, 110),
		Font = theme.Font,
		TextSize = 16,
		TextColor3 = theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = LOGO,
		ZIndex = 51,
	}, overlay)
	local log = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(40, 165),
		Size = UDim2.new(1, -80, 1, -260),
		Font = theme.Font,
		TextSize = 18,
		TextColor3 = theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Text = "",
		ZIndex = 51,
	}, overlay)
	local pct = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 40, 1, -96),
		Size = UDim2.new(1, -80, 0, 22),
		Font = theme.Font,
		TextSize = 16,
		TextColor3 = theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = "0%",
		ZIndex = 51,
	}, overlay)
	local barBg = U.make("Frame", {
		Position = UDim2.new(0, 40, 1, -70),
		Size = UDim2.new(1, -80, 0, 16),
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		ZIndex = 51,
	}, overlay)
	local barEdge = U.stroke(barBg, theme.Dim)
	local fill = U.make("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 52,
	}, barBg)
	local final = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = theme.Font,
		TextSize = 40,
		TextColor3 = theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTransparency = 1,
		Text = finalText,
		ZIndex = 53,
	}, overlay)

	-- Botão SKIP: pula direto para o fim
	local skipped = false
	local skip = U.make("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -24, 1, -24),
		Size = UDim2.fromOffset(120, 32),
		BackgroundColor3 = theme.Black,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = theme.Font,
		TextSize = 15,
		TextColor3 = theme.Accent,
		Text = "[ SKIP ]",
		ZIndex = 54,
	}, overlay)
	U.stroke(skip, theme.Accent)
	skip.MouseEnter:Connect(function()
		skip.BackgroundColor3 = theme.Accent
		skip.TextColor3 = theme.Black
	end)
	skip.MouseLeave:Connect(function()
		skip.BackgroundColor3 = theme.Black
		skip.TextColor3 = theme.Accent
	end)
	skip.MouseButton1Click:Connect(function()
		if skipped then
			return
		end
		skipped = true
		log.Parent = nil -- corta a digitação em andamento
	end)

	task.spawn(function()
		local acc = ""
		local n = #lines
		for idx, line in ipairs(lines) do
			if skipped then
				break
			end
			U.type(log, "[ OK ] " .. line, 0.03, acc)
			if skipped then
				break
			end
			acc ..= "[ OK ] " .. line .. "\n"
			TweenService:Create(fill, TweenInfo.new(0.3), { Size = UDim2.fromScale(idx / (n + 1), 1) }):Play()
			pct.Text = string.format("%d%%", math.floor(idx / (n + 1) * 100))
			task.wait(0.15)
		end

		-- Fim (normal ou por SKIP)
		local all = ""
		for _, l in ipairs(lines) do
			all ..= "[ OK ] " .. l .. "\n"
		end
		log.Parent = overlay
		log.Text = all
		skip.Visible = false
		TweenService:Create(fill, TweenInfo.new(skipped and 0.1 or 0.4), { Size = UDim2.fromScale(1, 1) }):Play()
		pct.Text = "100%"
		task.wait(skipped and 0.05 or 0.4)
		E.glitch(final, finalText, 3)
		TweenService:Create(final, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
		task.wait(skipped and 0.5 or 1)
		local fade = TweenInfo.new(0.6)
		TweenService:Create(overlay, fade, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(logo, fade, { TextTransparency = 1 }):Play()
		TweenService:Create(log, fade, { TextTransparency = 1 }):Play()
		TweenService:Create(pct, fade, { TextTransparency = 1 }):Play()
		TweenService:Create(final, fade, { TextTransparency = 1 }):Play()
		TweenService:Create(barBg, fade, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(barEdge, fade, { Transparency = 1 }):Play()
		TweenService:Create(fill, fade, { BackgroundTransparency = 1 }):Play()
		task.wait(0.7)
		overlay:Destroy()
		if onDone then
			onDone()
		end
	end)
end

-- Revela o texto letra por letra: cada caractere passa por letras aleatórias até fixar o certo
function E.lock(label, final, speed)
	local target = U.chars(final)
	local n = #target
	local id = (label:GetAttribute("lock") or 0) + 1
	label:SetAttribute("lock", id)
	task.spawn(function()
		local out = {}
		for i = 1, n do
			out[i] = U.glyph()
		end
		for i = 1, n do
			for _ = 1, 6 + i * 2 do
				if not label.Parent or label:GetAttribute("lock") ~= id then
					return
				end
				out[i] = U.glyph()
				label.Text = table.concat(out)
				task.wait(speed or 0.035)
			end
			out[i] = target[i]
			label.Text = table.concat(out)
		end
		if label.Parent and label:GetAttribute("lock") == id then
			label.Text = final
		end
	end)
end

-- Efeito de TV ligando: as metades pretas recolhem para o centro e a linha some
function E.powerOn(parent, theme, onDone)
	local top = U.make("Frame", {
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ZIndex = 60,
	}, parent)
	local bot = U.make("Frame", {
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ZIndex = 60,
	}, parent)
	local line = U.make("Frame", {
		Position = UDim2.new(0, 0, 0.5, -2),
		Size = UDim2.new(1, 0, 0, 4),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 61,
	}, parent)
	task.spawn(function()
		task.wait(0.2)
		local q = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		TweenService:Create(top, q, { Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 0) }):Play()
		TweenService:Create(bot, q, { Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 0) }):Play()
		task.wait(0.4)
		TweenService:Create(line, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
		task.wait(0.3)
		top:Destroy()
		bot:Destroy()
		line:Destroy()
		if onDone then
			onDone()
		end
	end)
end

return E

end

__M["src/core/screen"] = function(...)
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

function S.new(theme, matrix)
	local self = setmetatable({}, S)
	self.Theme = theme
	self.Boost = 1
	self._conns = {}
	self._visible = true

	local parent = guiParent()
	self.Back = screenGui(parent, "nyxOS_FX", 900)
	self.Main = screenGui(parent, "nyxOS", 999)
	self.Top = screenGui(parent, "nyxOS_TOP", 1000)

	local cam = workspace.CurrentCamera or workspace:WaitForChild("CurrentCamera")
	self._vw, self._vh = cam.ViewportSize.X, cam.ViewportSize.Y

	self._dim = U.make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
	}, self.Back)
	self.Streams = {}
	self._matrix = matrix ~= false
	if self._matrix then
		self:_buildRain()
	end

	table.insert(self._conns, RunService.RenderStepped:Connect(function(dt)
		self.Boost = math.max(1, self.Boost - dt * 1.2)
		if self._visible then
			E.step(self.Streams, self._vh, dt, self.Boost)
		end
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

function S:_buildRain()
	for _, s in ipairs(self.Streams) do
		if s.label then
			s.label:Destroy()
		end
	end
	self.Streams = E.rain(self.Back, self._vw, self._vh, self.Theme)
end

-- Minimizado: a chuva é removida da tela. Restaurado: é criada de novo.
function S:setVisible(v)
	self._visible = v
	self.Back.Enabled = v
	self.Top.Enabled = v
	if v then
		if self._matrix and #self.Streams == 0 then
			self:_buildRain()
		end
	else
		for _, s in ipairs(self.Streams) do
			if s.label then
				s.label:Destroy()
			end
		end
		self.Streams = {}
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
	if self.SkipBoot then
		if onDone then
			onDone()
		end
		return
	end
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

end

__M["src/core/util"] = function(...)
local req = ...
local UIS = game:GetService("UserInputService")
local U = {}

local GLYPHS = {}
for c in ("01ABCDEFGHIJKLMNOPQRSTUVWXYZ<>/\\|$#@%&*+=~"):gmatch(".") do
	GLYPHS[#GLYPHS + 1] = c
end
function U.glyph()
	return GLYPHS[math.random(#GLYPHS)]
end

function U.make(class, props, parent)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	if parent then
		obj.Parent = parent
	end
	return obj
end

function U.stroke(parent, color, thickness)
	return U.make("UIStroke", { Color = color, Thickness = thickness or 1 }, parent)
end

function U.pad(parent, l, r, t, b)
	return U.make("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingBottom = UDim.new(0, b or 0),
	}, parent)
end

-- Digitação caractere por caractere (UTF-8 seguro). Use com task.spawn
function U.type(label, text, speed, prefix)
	prefix = prefix or ""
	local out = ""
	for ch in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
		if not label.Parent then
			return
		end
		out ..= ch
		label.Text = prefix .. out .. "_"
		task.wait(speed or 0.02)
	end
	if label.Parent then
		label.Text = prefix .. out
	end
end

-- Arrastar (mouse/touch). Se não arrastou, dispara onClick
function U.draggable(handle, target, onClick, conns)
	local dragging, startIn, startPos, moved = false, nil, nil, false
	table.insert(conns, handle.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging, startIn, startPos, moved = true, i.Position, target.Position, false
		local ec
		ec = i.Changed:Connect(function()
			if i.UserInputState == Enum.UserInputState.End then
				dragging = false
				ec:Disconnect()
				if not moved and onClick then
					onClick()
				end
			end
		end)
	end))
	table.insert(conns, UIS.InputChanged:Connect(function(i)
		if not dragging then
			return
		end
		if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local d = i.Position - startIn
		if d.Magnitude > 4 then
			moved = true
		end
		target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end))
end

-- Quebra texto em caracteres (UTF-8 seguro)
function U.chars(text)
	local t = {}
	for ch in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
		t[#t + 1] = ch
	end
	return t
end

-- Registro de cores ligadas ao tema (para trocar o tema ao vivo)
local painted = {}
function U.paint(obj, prop, key)
	painted[#painted + 1] = { obj = obj, prop = prop, key = key }
	return obj
end
function U.repaint(T)
	for i = #painted, 1, -1 do
		local p = painted[i]
		if p.obj.Parent == nil then
			table.remove(painted, i)
		elseif T[p.key] ~= nil then
			p.obj[p.prop] = T[p.key]
		end
	end
end

return U

end

__M["src/core/window"] = function(...)
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

end

__M["src/init"] = function(...)
local req = ...
local Window = req("src/core/window")
Window.Version = "2.6.0-beta"
return Window

end

__M["src/themes/amber"] = function(...)
return {
	Name = "amber",
	Accent = Color3.fromRGB(255, 176, 0),
	Dim = Color3.fromRGB(120, 80, 0),
	Black = Color3.fromRGB(0, 0, 0),
	Panel = Color3.fromRGB(10, 7, 2),
	Hover = Color3.fromRGB(30, 20, 4),
	Font = Enum.Font.Code,
}

end

__M["src/themes/blood"] = function(...)
return {
	Name = "blood",
	Accent = Color3.fromRGB(255, 50, 50),
	Dim = Color3.fromRGB(110, 15, 15),
	Black = Color3.fromRGB(8, 0, 0),
	Panel = Color3.fromRGB(18, 4, 4),
	Hover = Color3.fromRGB(40, 8, 8),
	Font = Enum.Font.Code,
}

end

__M["src/themes/cyber"] = function(...)
return {
	Name = "cyber",
	Accent = Color3.fromRGB(255, 0, 200),
	Dim = Color3.fromRGB(110, 0, 85),
	Black = Color3.fromRGB(4, 0, 8),
	Panel = Color3.fromRGB(14, 4, 18),
	Hover = Color3.fromRGB(40, 8, 50),
	Font = Enum.Font.Code,
}

end

__M["src/themes/ice"] = function(...)
return {
	Name = "ice",
	Accent = Color3.fromRGB(0, 234, 255),
	Dim = Color3.fromRGB(0, 90, 110),
	Black = Color3.fromRGB(0, 4, 8),
	Panel = Color3.fromRGB(4, 12, 16),
	Hover = Color3.fromRGB(8, 36, 46),
	Font = Enum.Font.Code,
}

end

__M["src/themes/neon"] = function(...)
return {
	Name = "neon",
	Accent = Color3.fromRGB(57, 255, 20),
	Dim = Color3.fromRGB(0, 120, 35),
	Black = Color3.fromRGB(0, 0, 0),
	Panel = Color3.fromRGB(6, 10, 6),
	Hover = Color3.fromRGB(12, 30, 12),
	Font = Enum.Font.Code,
}

end

return __req("src/init")
