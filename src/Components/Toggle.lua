--!strict
local TweenService = game:GetService("TweenService")
local Toggle = {}
function Toggle.Create(parent, theme, options)
    options = options or {}
    local value = options.Default == true
    local row = Instance.new("TextButton")
    row.Name = "NyxToggle"
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = theme.Surface
    row.AutoButtonColor = false
    row.Text = ""
    row.Parent = parent
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 8); corner.Parent = row
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1; title.Position = UDim2.fromOffset(12, 0)
    title.Size = UDim2.new(1, -70, 1, 0); title.Font = Enum.Font.Gotham
    title.TextSize = 13; title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = theme.Text; title.Text = tostring(options.Name or "Toggle"); title.Parent = row
    local track = Instance.new("Frame")
    track.AnchorPoint = Vector2.new(1, 0.5); track.Position = UDim2.new(1, -12, 0.5, 0)
    track.Size = UDim2.fromOffset(36, 20); track.BackgroundColor3 = value and theme.Primary or theme.Border; track.Parent = row
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1, 0); tc.Parent = track
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14); knob.Position = value and UDim2.new(1, -17, 0.5, -7) or UDim2.fromOffset(3, 3)
    knob.BackgroundColor3 = Color3.new(1,1,1); knob.Parent = track
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob
    local function set(nextValue, fire)
        value = nextValue == true
        TweenService:Create(track, TweenInfo.new(0.16), {BackgroundColor3 = value and theme.Primary or theme.Border}):Play()
        TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = value and UDim2.new(1, -17, 0.5, -7) or UDim2.fromOffset(3, 3)
        }):Play()
        if fire and type(options.Callback) == "function" then
            local ok, err = pcall(options.Callback, value); if not ok then warn("[NyxOS] Toggle callback failed:", err) end
        end
    end
    row.Activated:Connect(function() set(not value, true) end)
    row.MouseEnter:Connect(function() TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = theme.SurfaceHover}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = theme.Surface}):Play() end)
    row:SetAttribute("Value", value)
    return {Instance = row, Get = function() return value end, Set = set}
end
return Toggle
