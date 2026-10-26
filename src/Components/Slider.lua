--!strict
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Slider = {}
function Slider.Create(parent, theme, options)
    options = options or {}
    local min = tonumber(options.Min) or 0
    local max = tonumber(options.Max) or 100
    if max <= min then max = min + 1 end
    local value = math.clamp(tonumber(options.Default) or min, min, max)
    local row = Instance.new("Frame"); row.Name = "NyxSlider"; row.Size = UDim2.new(1,0,0,56); row.BackgroundTransparency = 1; row.Parent = parent
    local title = Instance.new("TextLabel"); title.BackgroundTransparency = 1; title.Size = UDim2.new(1,-60,0,22); title.Font = Enum.Font.Gotham; title.TextSize = 13; title.TextXAlignment = Enum.TextXAlignment.Left; title.TextColor3 = theme.Text; title.Text = tostring(options.Name or "Slider"); title.Parent = row
    local valueLabel = Instance.new("TextLabel"); valueLabel.BackgroundTransparency = 1; valueLabel.AnchorPoint = Vector2.new(1,0); valueLabel.Position = UDim2.new(1,0,0,0); valueLabel.Size = UDim2.fromOffset(58,22); valueLabel.Font = Enum.Font.GothamMedium; valueLabel.TextSize = 12; valueLabel.TextXAlignment = Enum.TextXAlignment.Right; valueLabel.TextColor3 = theme.Primary; valueLabel.Parent = row
    local bar = Instance.new("TextButton"); bar.Text = ""; bar.AutoButtonColor = false; bar.Position = UDim2.new(0,0,0,31); bar.Size = UDim2.new(1,0,0,8); bar.BackgroundColor3 = theme.Border; bar.Parent = row
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1,0); bc.Parent = bar
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((value-min)/(max-min),0,1,0); fill.BackgroundColor3 = theme.Primary; fill.Parent = bar
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill
    local function set(v, fire)
        value = math.clamp(v,min,max)
        local decimals = options.Decimals or 0
        local scale = 10 ^ decimals
        value = math.floor(value * scale + 0.5) / scale
        valueLabel.Text = tostring(value)
        TweenService:Create(fill,TweenInfo.new(0.08),{Size=UDim2.new((value-min)/(max-min),0,1,0)}):Play()
        if fire and type(options.Callback) == "function" then local ok,err=pcall(options.Callback,value); if not ok then warn("[NyxOS] Slider callback failed:",err) end end
    end
    local dragging = false
    local function update(input)
        local width = math.max(bar.AbsoluteSize.X,1)
        set(min + math.clamp((input.Position.X - bar.AbsolutePosition.X)/width,0,1)*(max-min),true)
    end
    bar.Activated:Connect(function() end)
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging=true; update(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging=false end end)
    set(value,false)
    return {Instance=row,Get=function() return value end,Set=set}
end
return Slider
