--!strict
local TweenService = game:GetService("TweenService")
local Button = {}

function Button.Create(parent, theme, options)
    options = options or {}
    local button = Instance.new("TextButton")
    button.Name = "NyxButton"
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundColor3 = theme.Surface
    button.AutoButtonColor = false
    button.Text = ""
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 13
    button.TextColor3 = theme.Text
    button.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.2
    stroke.Parent = button
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(12, 0)
    title.Size = UDim2.new(1, -24, 1, 0)
    title.Font = Enum.Font.GothamMedium
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = theme.Text
    title.Text = tostring(options.Name or "Button")
    title.Parent = button
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.14), {BackgroundColor3 = theme.SurfaceHover}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.14), {Color = theme.Primary, Transparency = 0}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.14), {BackgroundColor3 = theme.Surface}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.14), {Color = theme.Border, Transparency = 0.2}):Play()
    end)
    button.Activated:Connect(function()
        if type(options.Callback) == "function" then
            local ok, err = pcall(options.Callback)
            if not ok then warn("[NyxOS] Button callback failed:", err) end
        end
    end)
    return button
end

return Button
