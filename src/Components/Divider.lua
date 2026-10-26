--!strict
local Divider = {}
function Divider.Create(parent, theme, options)
    options = options or {}
    local line = Instance.new("Frame")
    line.Name = "NyxDivider"
    line.Size = UDim2.new(1, 0, 0, options.Height or 1)
    line.BackgroundColor3 = options.Color or theme.Border
    line.BackgroundTransparency = options.Transparency or 0
    line.BorderSizePixel = 0
    line.Parent = parent
    return line
end
return Divider
