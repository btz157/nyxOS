--!strict
local Section = {}
function Section.Create(parent, theme, options)
    options = options or {}
    local root = Instance.new("Frame")
    root.Name = "NyxSection"
    root.Size = UDim2.new(1, 0, 0, options.Height or 34)
    root.BackgroundTransparency = 1
    root.Parent = parent
    local label = Instance.new("TextLabel")
    label.Name = "Title"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, -7)
    label.Font = Enum.Font.GothamBold
    label.TextSize = options.TextSize or 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = options.Color or theme.Primary
    label.Text = string.upper(tostring(options.Name or options.Text or "SECTION"))
    label.Parent = root
    local line = Instance.new("Frame")
    line.Name = "Rule"
    line.Position = UDim2.new(0, 0, 1, -5)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.BackgroundColor3 = theme.Border
    line.BorderSizePixel = 0
    line.Parent = root
    return root
end
return Section
