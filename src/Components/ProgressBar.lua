--!strict
local TweenService = game:GetService("TweenService")
local ProgressBar = {}
function ProgressBar.Create(parent, theme, options)
    options = options or {}
    local min = tonumber(options.Min) or 0
    local max = tonumber(options.Max) or 100
    if max <= min then max = min + 1 end
    local value = math.clamp(tonumber(options.Default) or min, min, max)
    local root = Instance.new("Frame")
    root.Name = "NyxProgressBar"
    root.Size = UDim2.new(1, 0, 0, options.Height or 42)
    root.BackgroundTransparency = 1
    root.Parent = parent
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -60, 0, 18)
    title.Font = Enum.Font.Gotham
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = theme.Text
    title.Text = tostring(options.Name or "Progress")
    title.Parent = root
    local valueText = Instance.new("TextLabel")
    valueText.BackgroundTransparency = 1
    valueText.AnchorPoint = Vector2.new(1, 0)
    valueText.Position = UDim2.new(1, 0, 0, 0)
    valueText.Size = UDim2.fromOffset(58, 18)
    valueText.Font = Enum.Font.GothamMedium
    valueText.TextSize = 11
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.TextColor3 = theme.Primary
    valueText.Parent = root
    local track = Instance.new("Frame")
    track.Position = UDim2.new(0, 0, 0, 25)
    track.Size = UDim2.new(1, 0, 0, 7)
    track.BackgroundColor3 = theme.Border
    track.BorderSizePixel = 0
    track.Parent = root
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1, 0); tc.Parent = track
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = options.Color or theme.Primary
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1, 0); fc.Parent = fill
    local function set(_, nextValue)
        value = math.clamp(tonumber(nextValue) or min, min, max)
        local ratio = (value - min) / (max - min)
        valueText.Text = tostring(math.floor(ratio * 100 + 0.5)) .. "%"
        TweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(ratio, 0, 1, 0)}):Play()
        if type(options.Callback) == "function" then
            local ok, err = pcall(options.Callback, value)
            if not ok then warn("[NyxOS] ProgressBar callback failed:", err) end
        end
    end
    valueText.Text = tostring(math.floor((value-min)/(max-min)*100+0.5)) .. "%"
    fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
    return {Instance=root, Get=function() return value end, Set=set}
end
return ProgressBar
