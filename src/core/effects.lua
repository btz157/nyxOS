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

-- Chuva Matrix em duas camadas: fundo (pequena, lenta, esmaecida) e frente (maior, rápida, viva)
local LAYERS = {
	{ col = 12, lh = 11, size = 10, spd = { 35, 95 }, alpha = 0.7, len = { 8, 22 }, density = 0.9 },
	{ col = 18, lh = 16, size = 15, spd = { 110, 240 }, alpha = 0.3, len = { 6, 14 }, density = 0.45 },
}
local HEAD = Color3.fromRGB(235, 255, 235)

local function glyphs(n)
	local t = {}
	for i = 1, n do
		t[i] = U.glyph()
	end
	return table.concat(t, "\n")
end

local function newStream(parent, x, h, theme, L, anywhere)
	local len = math.random(L.len[1], L.len[2])
	local s = {
		x = x,
		len = len,
		col = L.col,
		lh = L.lh,
		L = L,
		y = anywhere and math.random(0, math.floor(h)) or -math.random(0, math.floor(h / 3)),
		spd = math.random(L.spd[1], L.spd[2]),
	}
	s.trail = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(L.col, len * L.lh),
		Font = theme.Font,
		TextSize = L.size,
		TextColor3 = theme.Accent,
		TextTransparency = L.alpha,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = glyphs(len),
	}, parent)
	s.head = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(L.col, L.lh),
		Font = theme.Font,
		TextSize = L.size,
		TextColor3 = HEAD,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = U.glyph(),
	}, parent)
	return s
end

function E.rain(parent, w, h, theme)
	local streams = {}
	for _, L in ipairs(LAYERS) do
		for x = 0, math.ceil(w / L.col) do
			if math.random() < L.density then
				streams[#streams + 1] = newStream(parent, x * L.col, h, theme, L, true)
			end
		end
	end
	return streams
end

function E.step(streams, h, dt, mul)
	mul = mul or 1
	for _, s in ipairs(streams) do
		s.y += s.spd * mul * dt
		if s.y - s.len * s.lh > h then
			s.y = -math.random(0, math.floor(h / 3))
			s.len = math.random(s.L.len[1], s.L.len[2])
			s.spd = math.random(s.L.spd[1], s.L.spd[2])
			s.trail.Size = UDim2.fromOffset(s.col, s.len * s.lh)
			s.trail.Text = glyphs(s.len)
		end
		if math.random() < 0.03 then
			s.trail.Text = glyphs(s.len)
		end
		if math.random() < 0.3 then
			s.head.Text = U.glyph()
		end
		s.trail.Position = UDim2.fromOffset(s.x, s.y - s.len * s.lh)
		s.head.Position = UDim2.fromOffset(s.x, s.y)
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
