--!strict
local Textbox = {}
function Textbox.Create(parent, theme, options)
    options = options or {}
    local frame = Instance.new("Frame"); frame.Name="NyxTextbox"; frame.Size=UDim2.new(1,0,0,64); frame.BackgroundTransparency=1; frame.Parent=parent
    local label=Instance.new("TextLabel"); label.BackgroundTransparency=1; label.Size=UDim2.new(1,0,0,20); label.Font=Enum.Font.Gotham; label.TextSize=12; label.TextXAlignment=Enum.TextXAlignment.Left; label.TextColor3=theme.MutedText; label.Text=tostring(options.Name or "Text"); label.Parent=frame
    local box=Instance.new("TextBox"); box.Size=UDim2.new(1,0,0,36); box.Position=UDim2.fromOffset(0,24); box.BackgroundColor3=theme.Surface; box.TextColor3=theme.Text; box.PlaceholderColor3=theme.MutedText; box.PlaceholderText=tostring(options.Placeholder or "Type here..."); box.Text=tostring(options.Default or ""); box.ClearTextOnFocus=false; box.Font=Enum.Font.Gotham; box.TextSize=13; box.Parent=frame
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,8); c.Parent=box
    local s=Instance.new("UIStroke"); s.Color=theme.Border; s.Transparency=0.15; s.Parent=box
    box.Focused:Connect(function() s.Color=theme.Primary end)
    box.FocusLost:Connect(function(enterPressed)
        s.Color=theme.Border
        if type(options.Callback)=="function" then local ok,err=pcall(options.Callback,box.Text,enterPressed); if not ok then warn("[NyxOS] Textbox callback failed:",err) end end
    end)
    return {Instance=frame,Input=box,Get=function() return box.Text end,Set=function(_,v) box.Text=tostring(v) end}
end
return Textbox
