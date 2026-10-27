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

-- Chuva Matrix cobrindo a tela inteira
function E.rain(parent, w, h, theme)
	local cols = {}
	for i = 0, math.ceil(w / COL) do
		local lbl = U.make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(COL, h * 2),
			Font = theme.Font,
			TextSize = 14,
			TextColor3 = theme.Accent,
			TextTransparency = 0.55,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Text = "",
		}, parent)
		local c = { lbl = lbl, x = i * COL, y = -math.random(0, h), spd = math.random(60, 180), len = math.random(8, 22) }
		E.scramble(c)
		cols[#cols + 1] = c
	end
	return cols
end

-- mul acelera a chuva (ex.: ao clicar)
function E.step(cols, h, dt, mul)
	mul = mul or 1
	for _, c in ipairs(cols) do
		c.y += c.spd * mul * dt
		if c.y > h then
			c.y = -c.len * COL - math.random(0, 200)
			c.spd = math.random(60, 180)
			c.len = math.random(8, 22)
			E.scramble(c)
		end
		if math.random() < 0.03 then
			E.scramble(c)
		end
		c.lbl.Position = UDim2.fromOffset(c.x, c.y)
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

-- Boot em tela cheia: tela escurece e um console centralizado digita as linhas
function E.boot(parent, theme, lines, finalText, onDone)
	local overlay = U.make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.Black,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		ZIndex = 50,
	}, parent)
	local box = U.make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(560, 300),
		BackgroundColor3 = theme.Black,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 51,
	}, overlay)
	local edge = U.stroke(box, theme.Accent, 2)
	local log = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 14),
		Size = UDim2.new(1, -32, 1, -28),
		Font = theme.Font,
		TextSize = 15,
		TextColor3 = theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Text = "",
		ZIndex = 52,
	}, box)

	task.spawn(function()
		local acc = ""
		for _, line in ipairs(lines) do
			U.type(log, "[ OK ] " .. line, 0.025, acc)
			acc ..= "[ OK ] " .. line .. "\n"
			task.wait(0.12)
		end
		for p = 0, 100, 2 do
			if not log.Parent then
				return
			end
			local n = math.floor(p / 5)
			log.Text = acc .. string.format("[%s%s] %3d%%", string.rep("#", n), string.rep(" ", 20 - n), p)
			task.wait(0.03)
		end
		log.Text = acc .. "[ OK ] " .. finalText
		task.wait(0.4)
		TweenService:Create(overlay, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(box, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(edge, TweenInfo.new(0.5), { Transparency = 1 }):Play()
		TweenService:Create(log, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		task.wait(0.55)
		overlay:Destroy()
		if onDone then
			onDone()
		end
	end)
end

return E
