--!strict
local Label = {}
function Label.Create(parent, theme, options)
    options = options or {}
    local label = Instance.new("TextLabel")
    label.Name = "NyxLabel"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, options.Height or 26)
    label.Font = Enum.Font.Gotham
    label.TextSize = options.TextSize or 12
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextColor3 = options.Color or theme.MutedText
    label.Text = tostring(options.Name or options.Text or "Label")
    label.Parent = parent
    return label
end
return Label
