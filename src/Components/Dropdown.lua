--!strict
local TweenService = game:GetService("TweenService")
local Dropdown = {}
function Dropdown.Create(parent,theme,options)
    options=options or {}
    local items=options.Options or {}
    local selected=options.Default
    if selected==nil then selected=items[1] end
    local opened=false
    local root=Instance.new("Frame"); root.Name="NyxDropdown"; root.Size=UDim2.new(1,0,0,42); root.BackgroundTransparency=1; root.ClipsDescendants=true; root.Parent=parent
    local main=Instance.new("TextButton"); main.Size=UDim2.new(1,0,0,38); main.BackgroundColor3=theme.Surface; main.Text=""; main.AutoButtonColor=false; main.Parent=root
    local mc=Instance.new("UICorner"); mc.CornerRadius=UDim.new(0,8); mc.Parent=main
    local title=Instance.new("TextLabel"); title.BackgroundTransparency=1; title.Position=UDim2.fromOffset(12,0); title.Size=UDim2.new(0.55,0,1,0); title.Font=Enum.Font.Gotham; title.TextSize=12; title.TextXAlignment=Enum.TextXAlignment.Left; title.TextColor3=theme.Text; title.Text=tostring(options.Name or "Dropdown"); title.Parent=main
    local value=Instance.new("TextLabel"); value.BackgroundTransparency=1; value.AnchorPoint=Vector2.new(1,0); value.Position=UDim2.new(1,-30,0,0); value.Size=UDim2.new(0.4,0,1,0); value.Font=Enum.Font.Gotham; value.TextSize=12; value.TextXAlignment=Enum.TextXAlignment.Right; value.TextColor3=theme.Primary; value.Text=tostring(selected or "Select"); value.Parent=main
    local arrow=Instance.new("TextLabel"); arrow.BackgroundTransparency=1; arrow.AnchorPoint=Vector2.new(1,0.5); arrow.Position=UDim2.new(1,-10,0,19); arrow.Size=UDim2.fromOffset(14,18); arrow.Font=Enum.Font.GothamBold; arrow.TextSize=13; arrow.TextColor3=theme.MutedText; arrow.Text="⌄"; arrow.Parent=main
    local list=Instance.new("Frame"); list.Position=UDim2.fromOffset(0,42); list.Size=UDim2.new(1,0,0,0); list.BackgroundColor3=theme.Surface; list.ClipsDescendants=true; list.Parent=root
    local lc=Instance.new("UICorner"); lc.CornerRadius=UDim.new(0,8); lc.Parent=list
    local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,3); layout.Parent=list
    local pad=Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,4); pad.PaddingBottom=UDim.new(0,4); pad.PaddingLeft=UDim.new(0,4); pad.PaddingRight=UDim.new(0,4); pad.Parent=list
    local buttons={}
    local function choose(item)
        selected=item; value.Text=tostring(item); opened=false
        TweenService:Create(root,TweenInfo.new(0.18),{Size=UDim2.new(1,0,0,42)}):Play()
        TweenService:Create(list,TweenInfo.new(0.18),{Size=UDim2.new(1,0,0,0)}):Play()
        arrow.Text="⌄"
        for _,b in ipairs(buttons) do b.BackgroundColor3=(b.Text==tostring(item)) and theme.SurfaceHover or theme.Surface end
        if type(options.Callback)=="function" then local ok,err=pcall(options.Callback,item); if not ok then warn("[NyxOS] Dropdown callback failed:",err) end end
    end
    for i,item in ipairs(items) do
        local b=Instance.new("TextButton"); b.Name="Option"..i; b.Size=UDim2.new(1,0,0,30); b.BackgroundColor3=(item==selected) and theme.SurfaceHover or theme.Surface; b.Text=tostring(item); b.TextColor3=theme.Text; b.TextSize=12; b.Font=Enum.Font.Gotham; b.AutoButtonColor=false; b.LayoutOrder=i; b.Parent=list
        local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,6); c.Parent=b
        b.Activated:Connect(function() choose(item) end)
        table.insert(buttons,b)
    end
    main.Activated:Connect(function()
        opened=not opened
        local height=opened and (42+math.min(#items,5)*33+8) or 42
        TweenService:Create(root,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,height)}):Play()
        TweenService:Create(list,TweenInfo.new(0.2),{Size=UDim2.new(1,0,0,opened and (math.min(#items,5)*33+8) or 0)}):Play()
        arrow.Text=opened and "⌃" or "⌄"
    end)
    return {Instance=root,Get=function() return selected end,Set=function(_,item) choose(item) end}
end
return Dropdown
