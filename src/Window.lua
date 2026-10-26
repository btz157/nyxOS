--!strict
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Components = require(script.Parent.Components)

local Window = {}
Window.__index = Window

local function corner(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = instance
    return c
end

local function stroke(instance, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency or 0
    s.Thickness = 1
    s.Parent = instance
    return s
end

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

function Window.new(options)
    local self = setmetatable({}, Window)
    self.Theme = options.Theme
    self._connections = {}
    self._tabs = {}
    self._destroyed = false
    self._minimized = false

    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    local parent = options.Parent or playerGui
    if not parent then error("[NyxOS] PlayerGui not found. Create the window from a LocalScript.") end

    local gui = make("ScreenGui", {
        Name = "NyxOS",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 50,
    }, parent)
    self.Gui = gui

    local root = make("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = options.Position or UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(0, 0),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, gui)
    self.Root = root
    corner(root, 12)
    stroke(root, self.Theme.Border, 0.15)

    local top = make("Frame", {
        Name = "Topbar", Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = self.Theme.Surface, BorderSizePixel = 0,
    }, root)
    self.Topbar = top
    corner(top, 12)
    local cover = make("Frame", {Position=UDim2.new(0,0,1,-12), Size=UDim2.new(1,0,0,12), BackgroundColor3=self.Theme.Surface, BorderSizePixel=0}, top)
    local accent = make("Frame", {Name="Accent", Size=UDim2.new(1,0,0,2), BackgroundColor3=self.Theme.Primary, BorderSizePixel=0}, top)
    local title = make("TextLabel", {
        Name="Title", BackgroundTransparency=1, Position=UDim2.fromOffset(16,0),
        Size=UDim2.new(1,-120,1,0), Font=Enum.Font.GothamBold, TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left, TextColor3=self.Theme.Text,
        Text=options.Title or "NyxOS",
    }, top)
    self.TitleLabel = title

    local minimize = make("TextButton", {
        Name="Minimize", AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-46,0.5,0),
        Size=UDim2.fromOffset(28,28), BackgroundColor3=self.Theme.SurfaceHover,
        Text="—", TextColor3=self.Theme.Primary, Font=Enum.Font.GothamBold,
        TextSize=17, AutoButtonColor=false,
    }, top)
    corner(minimize, 8)
    local close = make("TextButton", {
        Name="Close", AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.fromOffset(28,28), BackgroundColor3=self.Theme.SurfaceHover,
        Text="×", TextColor3=self.Theme.Danger, Font=Enum.Font.GothamBold,
        TextSize=19, AutoButtonColor=false,
    }, top)
    corner(close, 8)

    local sidebar = make("ScrollingFrame", {
        Name="Tabs", Position=UDim2.fromOffset(10,58), Size=UDim2.new(0,145,1,-68),
        BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3,
        ScrollBarImageColor3=self.Theme.Primary, CanvasSize=UDim2.new(),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
    }, root)
    local sideLayout = make("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder}, sidebar)
    self.Sidebar = sidebar

    local content = make("Frame", {
        Name="Content", Position=UDim2.new(0,165,0,58), Size=UDim2.new(1,-175,1,-68),
        BackgroundTransparency=1, ClipsDescendants=true,
    }, root)
    self.Content = content

    local function tween(obj, duration, props, style)
        local t = TweenService:Create(obj, TweenInfo.new(duration, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
        t:Play()
        return t
    end
    self._tween = tween

    local targetSize = options.Size or UDim2.fromOffset(680,450)
    tween(root, 0.42, {Size=targetSize}, Enum.EasingStyle.Back)

    -- Dragging is limited to the topbar; touch and mouse are supported.
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = root.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    top.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) and dragStart and startPos then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end))

    local orb
    local function minimizeWindow()
        if self._destroyed or self._minimized then return end
        self._minimized = true
        tween(root,0.22,{Size=UDim2.fromOffset(0,0)})
        task.delay(0.23,function()
            if self._destroyed then return end
            root.Visible=false
            orb=make("TextButton", {
                Name="NyxRestoreOrb", AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,-22,1,-90),
                Size=UDim2.fromOffset(54,54), BackgroundColor3=self.Theme.Surface,
                Text="N", TextColor3=self.Theme.Primary, TextSize=22,
                Font=Enum.Font.GothamBlack, AutoButtonColor=false,
            },gui)
            corner(orb,100); stroke(orb,self.Theme.Primary,0)
            local scale=make("UIScale",{Scale=0.4},orb)
            tween(scale,0.3,{Scale=1},Enum.EasingStyle.Back)
            orb.Activated:Connect(function()
                if orb then orb:Destroy(); orb=nil end
                root.Visible=true
                self._minimized=false
                tween(root,0.3,{Size=targetSize},Enum.EasingStyle.Back)
            end)
        end)
    end
    minimize.Activated:Connect(minimizeWindow)
    close.Activated:Connect(function() self:Destroy() end)

    if options.ToggleKey then
        table.insert(self._connections,UserInputService.InputBegan:Connect(function(input,processed)
            if not processed and input.KeyCode==options.ToggleKey and not self._destroyed then root.Visible=not root.Visible end
        end))
    end

    self._notifyHolder = make("Frame", {
        Name="Notifications", AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-16,0,16),
        Size=UDim2.fromOffset(300,300), BackgroundTransparency=1,
    },gui)
    make("UIListLayout",{Padding=UDim.new(0,8),HorizontalAlignment=Enum.HorizontalAlignment.Right,SortOrder=Enum.SortOrder.LayoutOrder},self._notifyHolder)
    self._orbGetter = function() return orb end
    return self
end

function Window:CreateTab(options)
    assert(not self._destroyed,"[NyxOS] Cannot create a tab on a destroyed window.")
    options = options or {}
    local name = tostring(options.Name or ("Tab "..tostring(#self._tabs+1)))
    local tabButton = make("TextButton", {
        Name="Tab_"..name, Size=UDim2.new(1,-4,0,36), BackgroundColor3=self.Theme.Surface,
        Text=(options.Icon and (tostring(options.Icon).."  ") or "")..name,
        TextColor3=self.Theme.MutedText, TextSize=12, Font=Enum.Font.GothamMedium,
        AutoButtonColor=false,
    },self.Sidebar)
    corner(tabButton,8)
    local page = make("ScrollingFrame", {
        Name="Page_"..name, Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
        BorderSizePixel=0, ScrollBarThickness=3, ScrollBarImageColor3=self.Theme.Primary,
        CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y, Visible=false,
    },self.Content)
    make("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},page)
    make("UIPadding",{PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,6),PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,6)},page)
    local tab = {Name=name,Button=tabButton,Page=page,Window=self}
    local function select()
        for _,other in ipairs(self._tabs) do
            other.Page.Visible=false
            self._tween(other.Button,0.12,{BackgroundColor3=self.Theme.Surface,TextColor3=self.Theme.MutedText})
        end
        page.Visible=true
        self._tween(tabButton,0.15,{BackgroundColor3=self.Theme.SurfaceHover,TextColor3=self.Theme.Primary})
    end
    tabButton.Activated:Connect(select)
    tab.AddButton = function(_,opts) return Components.Button.Create(page,self.Theme,opts) end
    tab.AddLabel = function(_,opts) return Components.Label.Create(page,self.Theme,opts) end
    tab.AddToggle = function(_,opts) return Components.Toggle.Create(page,self.Theme,opts) end
    tab.AddSlider = function(_,opts) return Components.Slider.Create(page,self.Theme,opts) end
    tab.AddTextbox = function(_,opts) return Components.Textbox.Create(page,self.Theme,opts) end
    tab.AddDropdown = function(_,opts) return Components.Dropdown.Create(page,self.Theme,opts) end
    tab.AddSection = function(_,opts) return Components.Section.Create(page,self.Theme,opts) end
    tab.AddDivider = function(_,opts) return Components.Divider.Create(page,self.Theme,opts) end
    tab.AddProgressBar = function(_,opts) return Components.ProgressBar.Create(page,self.Theme,opts) end
    table.insert(self._tabs,tab)
    if #self._tabs==1 then select() end
    return tab
end

function Window:Notify(options)
    if self._destroyed then return end
    options=options or {}
    local holder=self._notifyHolder
    local card=make("Frame",{Size=UDim2.new(1,0,0,76),BackgroundColor3=self.Theme.Surface,BackgroundTransparency=0.04,BorderSizePixel=0},holder)
    corner(card,10); stroke(card,self.Theme.Primary,0.35)
    local title=make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-24,0,22),Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=self.Theme.Primary,Text=tostring(options.Title or "NyxOS")},card)
    local desc=make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,30),Size=UDim2.new(1,-24,0,36),Font=Enum.Font.Gotham,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextColor3=self.Theme.Text,Text=tostring(options.Description or options.Content or "")},card)
    card.Position=UDim2.fromOffset(320,0)
    self._tween(card,0.22,{Position=UDim2.fromOffset(0,0)})
    task.delay(tonumber(options.Duration) or 3.5,function()
        if card.Parent then
            self._tween(card,0.2,{BackgroundTransparency=1,Position=UDim2.fromOffset(320,0)})
            task.delay(0.22,function() if card.Parent then card:Destroy() end end)
        end
    end)
    return card
end

function Window:Destroy()
    if self._destroyed then return end
    self._destroyed=true
    for _,connection in ipairs(self._connections) do pcall(function() connection:Disconnect() end) end
    if self.Gui then self.Gui:Destroy() end
end

Window.Close = Window.Destroy
return Window
