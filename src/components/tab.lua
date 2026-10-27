local req = ...
local U = req("src/core/util")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Tab = {}
Tab.__index = Tab

function Tab.new(lib, name)
	local T = lib.Theme
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
		Text = "  " .. name,
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

	local self = setmetatable({ lib = lib, T = T, page = page, btn = btn }, Tab)
	btn.MouseButton1Click:Connect(function()
		lib:_select(self)
	end)
	return self
end

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
	U.stroke(r, T.Dim)
	r.MouseEnter:Connect(function()
		r.BackgroundColor3 = T.Hover
	end)
	r.MouseLeave:Connect(function()
		r.BackgroundColor3 = T.Panel
	end)
	return r
end

function Tab:Section(name)
	U.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Font = self.T.Font,
		TextSize = 14,
		TextColor3 = self.T.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "── " .. name .. " ──",
	}, self.page)
end

-- [>] Nome
function Tab:Button(name, cb)
	local r = row(self, "[>] " .. name)
	r.MouseButton1Click:Connect(function()
		r.BackgroundColor3 = Color3.new(1, 1, 1)
		TweenService:Create(r, TweenInfo.new(0.3), { BackgroundColor3 = self.T.Accent }):Play()
		task.delay(0.3, function()
			if r.Parent then
				r.BackgroundColor3 = self.T.Panel
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
	local function render()
		right.Text = state and "[_on_]" or "[_off_]"
		right.TextColor3 = state and T.Accent or T.Dim
	end
	render()
	r.MouseButton1Click:Connect(function()
		state = not state
		render()
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

	local function render()
		fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
		lbl.Text = string.format("[>] %s: %g", name, value)
	end
	render()

	local sliding = false
	local function set(input)
		local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		value = math.floor(min + (max - min) * rel + 0.5)
		render()
		if cb then
			cb(value)
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
			sliding = false
		end
	end))
	return function()
		return value
	end
end

return Tab
