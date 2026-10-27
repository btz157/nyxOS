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

return U
