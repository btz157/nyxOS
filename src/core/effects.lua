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

-- Chuva Matrix para o fundo
function E.rain(parent, w, h, theme)
	local cols = {}
	for i = 0, math.ceil(w / COL) do
		local lbl = U.make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(COL, h * 2),
			Font = theme.Font,
			TextSize = 14,
			TextColor3 = theme.Accent,
			TextTransparency = 0.7,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Text = "",
		}, parent)
		local c = { lbl = lbl, x = i * COL, y = -math.random(0, h), spd = math.random(60, 160), len = math.random(8, 22) }
		E.scramble(c)
		cols[#cols + 1] = c
	end
	return cols
end

function E.step(cols, h, dt)
	for _, c in ipairs(cols) do
		c.y += c.spd * dt
		if c.y > h then
			c.y = -c.len * COL - math.random(0, 200)
			c.spd = math.random(60, 160)
			c.len = math.random(8, 22)
			E.scramble(c)
		end
		if math.random() < 0.03 then
			E.scramble(c)
		end
		c.lbl.Position = UDim2.fromOffset(c.x, c.y)
	end
end

-- Boot: linhas digitando + barra de progresso
function E.boot(win, theme, lines, finalText)
	local overlay = U.make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.Black,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ZIndex = 50,
	}, win)
	local log = U.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 12),
		Size = UDim2.new(1, -28, 1, -24),
		Font = theme.Font,
		TextSize = 14,
		TextColor3 = theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Text = "",
		ZIndex = 51,
	}, overlay)

	task.spawn(function()
		local acc = ""
		for _, line in ipairs(lines) do
			U.type(log, "[ OK ] " .. line, 0.02, acc)
			acc ..= "[ OK ] " .. line .. "\n"
			task.wait(0.15)
		end
		for p = 0, 100, 4 do
			if not log.Parent then
				return
			end
			local n = math.floor(p / 5)
			log.Text = acc .. string.format("[%s%s] %3d%%", string.rep("#", n), string.rep(" ", 20 - n), p)
			task.wait(0.04)
		end
		log.Text = acc .. "[ OK ] " .. finalText
		task.wait(0.4)
		TweenService:Create(overlay, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(log, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		task.wait(0.55)
		overlay:Destroy()
	end)
end

return E
