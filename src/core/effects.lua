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

-- Boot em tela cheia: logo, log digitando, barra de progresso e "acesso liberado" no centro
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

	task.spawn(function()
		local acc = ""
		local n = #lines
		for idx, line in ipairs(lines) do
			U.type(log, "[ OK ] " .. line, 0.03, acc)
			acc ..= "[ OK ] " .. line .. "\n"
			local frac = idx / (n + 1)
			TweenService:Create(fill, TweenInfo.new(0.3), { Size = UDim2.fromScale(frac, 1) }):Play()
			pct.Text = string.format("%d%%", math.floor(frac * 100))
			task.wait(0.15)
		end
		TweenService:Create(fill, TweenInfo.new(0.4), { Size = UDim2.fromScale(1, 1) }):Play()
		pct.Text = "100%"
		task.wait(0.4)
		E.glitch(final, finalText, 3)
		TweenService:Create(final, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
		task.wait(1)
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

return E
