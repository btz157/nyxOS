--!nocheck
-- NyxOS single-file runtime
-- Client-side Luau UI library. Intended for environments that permit loading this file.
-- Version 0.2.0-dev. This bundle is self-contained and does not require ModuleScripts.

local NyxOS = {Version = "0.2.0-dev"}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

NyxOS.Themes = {
 Matrix = {Background=Color3.fromRGB(7,12,9),Surface=Color3.fromRGB(14,22,17),SurfaceHover=Color3.fromRGB(22,36,26),Primary=Color3.fromRGB(0,255,110),Secondary=Color3.fromRGB(0,190,85),Text=Color3.fromRGB(225,255,232),MutedText=Color3.fromRGB(125,165,135),Border=Color3.fromRGB(0,110,55),Danger=Color3.fromRGB(255,75,95),Success=Color3.fromRGB(0,255,140)},
 Neon = {Background=Color3.fromRGB(13,10,24),Surface=Color3.fromRGB(25,19,42),SurfaceHover=Color3.fromRGB(39,29,62),Primary=Color3.fromRGB(180,90,255),Secondary=Color3.fromRGB(60,220,255),Text=Color3.fromRGB(245,239,255),MutedText=Color3.fromRGB(166,151,194),Border=Color3.fromRGB(91,54,140),Danger=Color3.fromRGB(255,75,120),Success=Color3.fromRGB(80,255,190)},
 Dark = {Background=Color3.fromRGB(17,18,22),Surface=Color3.fromRGB(27,29,35),SurfaceHover=Color3.fromRGB(38,41,49),Primary=Color3.fromRGB(100,145,255),Secondary=Color3.fromRGB(125,135,160),Text=Color3.fromRGB(240,242,248),MutedText=Color3.fromRGB(155,160,175),Border=Color3.fromRGB(60,64,76),Danger=Color3.fromRGB(255,85,95),Success=Color3.fromRGB(65,210,135)},
 Light = {Background=Color3.fromRGB(242,244,248),Surface=Color3.fromRGB(255,255,255),SurfaceHover=Color3.fromRGB(230,234,242),Primary=Color3.fromRGB(55,105,230),Secondary=Color3.fromRGB(90,105,135),Text=Color3.fromRGB(28,32,43),MutedText=Color3.fromRGB(105,112,130),Border=Color3.fromRGB(210,215,226),Danger=Color3.fromRGB(215,55,70),Success=Color3.fromRGB(25,155,95)}
}
local function create(class, props, parent)
 local o=Instance.new(class)
 for k,v in pairs(props or {}) do o[k]=v end
 o.Parent=parent
 return o
end
local function round(o,r) create("UICorner",{CornerRadius=UDim.new(0,r or 8)},o) end
local function outline(o,color,trans) create("UIStroke",{Color=color,Transparency=trans or 0,Thickness=1},o) end
local function tween(o,t,p,style)
 local x=TweenService:Create(o,TweenInfo.new(t,style or Enum.EasingStyle.Quart,Enum.EasingDirection.Out),p); x:Play(); return x
end
local function safeCallback(fn,...)
 if type(fn)=="function" then local ok,err=pcall(fn,...); if not ok then warn("[NyxOS] callback error: "..tostring(err)) end end
end
function NyxOS:GetTheme(name) return self.Themes[name or "Matrix"] or self.Themes.Matrix end

function NyxOS:CreateWindow(options)
 options=options or {}
 local theme=self:GetTheme(options.Theme)
 local player=Players.LocalPlayer
 local pg=player and player:FindFirstChildOfClass("PlayerGui")
 local parent=options.Parent or pg
 assert(parent,"[NyxOS] PlayerGui unavailable; run this on the client.")
 local gui=create("ScreenGui",{Name="NyxOS_"..tostring(math.random(1000,9999)),ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999},parent)
 local win=create("Frame",{Name="Window",AnchorPoint=Vector2.new(.5,.5),Position=options.Position or UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(0,0),BackgroundColor3=theme.Background,BorderSizePixel=0,ClipsDescendants=true},gui); round(win,13); outline(win,theme.Border,.1)
 local top=create("Frame",{Name="Topbar",Size=UDim2.new(1,0,0,48),BackgroundColor3=theme.Surface,BorderSizePixel=0},win); round(top,13)
 create("Frame",{Position=UDim2.new(0,0,1,-12),Size=UDim2.new(1,0,0,12),BackgroundColor3=theme.Surface,BorderSizePixel=0},top)
 create("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=theme.Primary,BorderSizePixel=0},top)
 create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(15,0),Size=UDim2.new(1,-110,1,0),Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=theme.Text,Text=tostring(options.Title or "NyxOS"),},top)
 local min=create("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-45,.5,0),Size=UDim2.fromOffset(27,27),BackgroundColor3=theme.SurfaceHover,Text="—",TextColor3=theme.Primary,Font=Enum.Font.GothamBold,TextSize=17,AutoButtonColor=false},top); round(min,8)
 local close=create("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-11,.5,0),Size=UDim2.fromOffset(27,27),BackgroundColor3=theme.SurfaceHover,Text="×",TextColor3=theme.Danger,Font=Enum.Font.GothamBold,TextSize=18,AutoButtonColor=false},top); round(close,8)
 local side=create("ScrollingFrame",{Position=UDim2.fromOffset(9,57),Size=UDim2.new(0,142,1,-66),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=theme.Primary,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},win)
 create("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},side)
 local pages=create("Frame",{Position=UDim2.new(0,161,0,57),Size=UDim2.new(1,-170,1,-66),BackgroundTransparency=1,ClipsDescendants=true},win)
 local toastHolder=create("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,14),Size=UDim2.fromOffset(290,300),BackgroundTransparency=1},gui)
 create("UIListLayout",{Padding=UDim.new(0,7),HorizontalAlignment=Enum.HorizontalAlignment.Right},toastHolder)
 local self=setmetatable({Gui=gui,Root=win,Theme=theme,_tabs={},_dead=false}, {__index=NyxOS.WindowMethods})
 tween(win,.4,{Size=options.Size or UDim2.fromOffset(680,440)},Enum.EasingStyle.Back)
 local drag,dragStart,startPos=false,nil,nil
 top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true;dragStart=i.Position;startPos=win.Position;i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end) end end)
 UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) and dragStart then local d=i.Position-dragStart;win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
 local orb
 min.Activated:Connect(function()
  if not win.Visible then return end
  tween(win,.18,{Size=UDim2.fromOffset(0,0)})
  task.delay(.19,function()
   if self._dead then return end;win.Visible=false
   orb=create("TextButton",{Name="NyxRestoreOrb",AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-20,1,-90),Size=UDim2.fromOffset(54,54),BackgroundColor3=theme.Surface,Text="N",TextColor3=theme.Primary,Font=Enum.Font.GothamBlack,TextSize=22,AutoButtonColor=false},gui);round(orb,100);outline(orb,theme.Primary,0)
   local sc=create("UIScale",{Scale=.35},orb);tween(sc,.28,{Scale=1},Enum.EasingStyle.Back)
   orb.Activated:Connect(function() if orb then orb:Destroy();orb=nil end;win.Visible=true;tween(win,.3,{Size=options.Size or UDim2.fromOffset(680,440)},Enum.EasingStyle.Back) end)
  end)
 end)
 close.Activated:Connect(function() self:Destroy() end)
 if options.ToggleKey then UserInputService.InputBegan:Connect(function(i,processed) if not processed and i.KeyCode==options.ToggleKey and not self._dead then win.Visible=not win.Visible end end) end
 self._toastHolder=toastHolder
 return self
end

NyxOS.WindowMethods={}
function NyxOS.WindowMethods:Notify(options)
 options=options or {}
 local t=self.Theme
 local card=create("Frame",{Size=UDim2.new(1,0,0,75),BackgroundColor3=t.Surface,BorderSizePixel=0},self._toastHolder);round(card,9);outline(card,t.Primary,.25)
 create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(11,7),Size=UDim2.new(1,-22,0,22),Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=t.Primary,Text=tostring(options.Title or "NyxOS")},card)
 create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(11,29),Size=UDim2.new(1,-22,0,38),Font=Enum.Font.Gotham,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextColor3=t.Text,Text=tostring(options.Description or options.Content or "")},card)
 card.Position=UDim2.fromOffset(300,0);tween(card,.2,{Position=UDim2.fromOffset(0,0)})
 task.delay(tonumber(options.Duration) or 3,function() if card.Parent then tween(card,.18,{BackgroundTransparency=1,Position=UDim2.fromOffset(300,0)});task.delay(.2,function() if card.Parent then card:Destroy() end end) end end)
 return card
end
function NyxOS.WindowMethods:Destroy() if self._dead then return end;self._dead=true;if self.Gui then self.Gui:Destroy() end end
NyxOS.WindowMethods.Close=NyxOS.WindowMethods.Destroy

function NyxOS.WindowMethods:CreateTab(options)
 options=options or {};local t=self.Theme;local name=tostring(options.Name or ("Tab "..(#self._tabs+1)))
 local b=create("TextButton",{Size=UDim2.new(1,-4,0,35),BackgroundColor3=t.Surface,Text=(options.Icon and (tostring(options.Icon).."  ") or "")..name,TextColor3=t.MutedText,TextSize=12,Font=Enum.Font.GothamMedium,AutoButtonColor=false},self.Root:FindFirstChild("Tabs") or self.Root)
 -- Reparent into actual sidebar reference found from gui hierarchy.
 local side=self.Root:FindFirstChildWhichIsA("ScrollingFrame")
 if side then b.Parent=side end
 round(b,8)
 local page=create("ScrollingFrame",{Name="Page_"..name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=t.Primary,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},self.Root:FindFirstChild("Content") or self.Root)
 local content=self.Root:FindFirstChild("Content")
 if not content then
  content=create("Frame",{Name="Content",Position=UDim2.new(0,161,0,57),Size=UDim2.new(1,-170,1,-66),BackgroundTransparency=1,ClipsDescendants=true},self.Root)
  page.Parent=content
 end
 create("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},page)
 create("UIPadding",{PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,6),PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,5)},page)
 local tab={Name=name,Button=b,Page=page}
 local function select()
  for _,v in ipairs(self._tabs) do v.Page.Visible=false;tween(v.Button,.12,{BackgroundColor3=t.Surface,TextColor3=t.MutedText}) end
  page.Visible=true;tween(b,.15,{BackgroundColor3=t.SurfaceHover,TextColor3=t.Primary})
 end
 b.Activated:Connect(select);table.insert(self._tabs,tab)
 local function label(opts)
  opts=opts or {};return create("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,opts.Height or 26),Font=Enum.Font.Gotham,TextSize=opts.TextSize or 12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=opts.Color or t.MutedText,Text=tostring(opts.Name or opts.Text or "Label")},page)
 end
 function tab:AddLabel(o) return label(o) end
 function tab:AddSection(o) o=o or {};local f=create("Frame",{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1},page);create("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,-6),Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=o.Color or t.Primary,Text=string.upper(tostring(o.Name or "SECTION"))},f);create("Frame",{Position=UDim2.new(0,0,1,-4),Size=UDim2.new(1,0,0,1),BackgroundColor3=t.Border,BorderSizePixel=0},f);return f end
 function tab:AddDivider(o) o=o or {};return create("Frame",{Size=UDim2.new(1,0,0,o.Height or 1),BackgroundColor3=o.Color or t.Border,BackgroundTransparency=o.Transparency or 0,BorderSizePixel=0},page) end
 function tab:AddButton(o)
  o=o or {};local x=create("TextButton",{Size=UDim2.new(1,0,0,38),BackgroundColor3=t.Surface,Text="",AutoButtonColor=false},page);round(x,8);outline(x,t.Border,.2)
  create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-24,1,0),Font=Enum.Font.GothamMedium,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=t.Text,Text=tostring(o.Name or "Button")},x)
  x.MouseEnter:Connect(function() tween(x,.13,{BackgroundColor3=t.SurfaceHover}) end);x.MouseLeave:Connect(function() tween(x,.13,{BackgroundColor3=t.Surface}) end);x.Activated:Connect(function() safeCallback(o.Callback) end);return x
 end
 function tab:AddToggle(o)
  o=o or {};local val=o.Default==true;local x=create("TextButton",{Size=UDim2.new(1,0,0,40),BackgroundColor3=t.Surface,Text="",AutoButtonColor=false},page);round(x,8)
  create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-70,1,0),Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=t.Text,Text=tostring(o.Name or "Toggle")},x)
  local track=create("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-11,.5,0),Size=UDim2.fromOffset(36,20),BackgroundColor3=val and t.Primary or t.Border},x);round(track,20)
  local knob=create("Frame",{Size=UDim2.fromOffset(14,14),Position=val and UDim2.new(1,-17,.5,-7) or UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1)},track);round(knob,20)
  local function set(v,fire) val=v==true;tween(track,.15,{BackgroundColor3=val and t.Primary or t.Border});tween(knob,.15,{Position=val and UDim2.new(1,-17,.5,-7) or UDim2.fromOffset(3,3)});x:SetAttribute("Value",val);if fire then safeCallback(o.Callback,val) end end
  x.Activated:Connect(function() set(not val,true) end);x:SetAttribute("Value",val);return {Instance=x,Get=function() return val end,Set=function(_,v) set(v,true) end}
 end
 function tab:AddSlider(o)
  o=o or {};local mn=tonumber(o.Min) or 0;local mx=tonumber(o.Max) or 100;if mx<=mn then mx=mn+1 end;local val=math.clamp(tonumber(o.Default) or mn,mn,mx)
  local f=create("Frame",{Size=UDim2.new(1,0,0,55),BackgroundTransparency=1},page)
  create("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-60,0,22),Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=t.Text,Text=tostring(o.Name or "Slider")},f)
  local vt=create("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(55,22),Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,TextColor3=t.Primary,Text=tostring(val)},f)
  local bar=create("TextButton",{Position=UDim2.new(0,0,0,30),Size=UDim2.new(1,0,0,8),BackgroundColor3=t.Border,Text="",AutoButtonColor=false},f);round(bar,8)
  local fill=create("Frame",{Size=UDim2.new((val-mn)/(mx-mn),0,1,0),BackgroundColor3=t.Primary},bar);round(fill,8)
  local function set(v,fire) val=math.clamp(tonumber(v) or mn,mn,mx);local p=10^(o.Decimals or 0);val=math.floor(val*p+.5)/p;vt.Text=tostring(val);tween(fill,.07,{Size=UDim2.new((val-mn)/(mx-mn),0,1,0)});if fire then safeCallback(o.Callback,val) end end
  local dragging=false
  local function update(i) set(mn+math.clamp((i.Position.X-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)*(mx-mn),true) end
  bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;update(i) end end)
  local move=UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then update(i) end end)
  UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
  f.AncestryChanged:Connect(function(_,p) if not p then move:Disconnect() end end)
  return {Instance=f,Get=function() return val end,Set=set}
 end
 function tab:AddDropdown(o)
  o=o or {};local opts=o.Options or {};local val=o.Default or opts[1];local opened=false
  local root=create("Frame",{Size=UDim2.new(1,0,0,42),BackgroundTransparency=1,ClipsDescendants=true},page)
  local main=create("TextButton",{Size=UDim2.new(1,0,0,38),BackgroundColor3=t.Surface,Text="",AutoButtonColor=false},root);round(main,8)
  create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(10,0),Size=UDim2.new(.52,0,1,0),Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=t.Text,Text=tostring(o.Name or "Dropdown")},main)
  local value=create("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-25,0,0),Size=UDim2.new(.4,0,1,0),Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,TextColor3=t.Primary,Text=tostring(val or "Select")},main)
  local list=create("ScrollingFrame",{Position=UDim2.fromOffset(0,41),Size=UDim2.new(1,0,0,0),BackgroundColor3=t.Surface,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=t.Primary,CanvasSize=UDim2.new(0,0,0,#opts*31),AutomaticCanvasSize=Enum.AutomaticSize.None},root);round(list,8);create("UIListLayout",{Padding=UDim.new(0,2)},list)
  local function choose(v) val=v;value.Text=tostring(v);opened=false;tween(root,.16,{Size=UDim2.new(1,0,0,42)});tween(list,.16,{Size=UDim2.new(1,0,0,0)});safeCallback(o.Callback,v) end
  for i,v in ipairs(opts) do local b=create("TextButton",{Size=UDim2.new(1,-4,0,29),BackgroundColor3=t.Surface,Text=tostring(v),TextColor3=t.Text,Font=Enum.Font.Gotham,TextSize=12,AutoButtonColor=false,LayoutOrder=i},list);b.Activated:Connect(function() choose(v) end) end
  main.Activated:Connect(function() opened=not opened;local h=opened and math.min(#opts,5)*31 or 0;list.CanvasSize=UDim2.new(0,0,0,#opts*31);tween(root,.18,{Size=UDim2.new(1,0,0,42+h)});tween(list,.18,{Size=UDim2.new(1,0,0,h)}) end)
  return {Instance=root,Get=function() return val end,Set=function(_,v) choose(v) end}
 end
 function tab:AddTextbox(o)
  o=o or {};local f=create("Frame",{Size=UDim2.new(1,0,0,64),BackgroundTransparency=1},page)
  create("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=t.MutedText,Text=tostring(o.Name or "Textbox")},f)
  local box=create("TextBox",{Position=UDim2.fromOffset(0,24),Size=UDim2.new(1,0,0,36),BackgroundColor3=t.Surface,TextColor3=t.Text,PlaceholderColor3=t.MutedText,PlaceholderText=tostring(o.Placeholder or "Type here"),Text=tostring(o.Default or ""),ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=12},f);round(box,8);outline(box,t.Border,.2)
  box.Focused:Connect(function() local s=box:FindFirstChildOfClass("UIStroke");if s then s.Color=t.Primary end end)
  box.FocusLost:Connect(function(enter) local s=box:FindFirstChildOfClass("UIStroke");if s then s.Color=t.Border end;safeCallback(o.Callback,box.Text,enter) end)
  return {Instance=f,Input=box,Get=function() return box.Text end,Set=function(_,v) box.Text=tostring(v) end}
 end
 function tab:AddProgressBar(o)
  o=o or {};local mn=tonumber(o.Min) or 0;local mx=tonumber(o.Max) or 100;if mx<=mn then mx=mn+1 end;local val=math.clamp(tonumber(o.Default) or mn,mn,mx)
  local f=create("Frame",{Size=UDim2.new(1,0,0,42),BackgroundTransparency=1},page)
  create("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-50,0,20),Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=t.Text,Text=tostring(o.Name or "Progress")},f)
  local tx=create("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(48,20),Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,TextColor3=t.Primary,Text=""},f)
  local bar=create("Frame",{Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,7),BackgroundColor3=t.Border},f);round(bar,8);local fill=create("Frame",{Size=UDim2.new((val-mn)/(mx-mn),0,1,0),BackgroundColor3=o.Color or t.Primary},bar);round(fill,8)
  local function set(_,v) val=math.clamp(tonumber(v) or mn,mn,mx);local r=(val-mn)/(mx-mn);tx.Text=tostring(math.floor(r*100+.5)).."%";tween(fill,.2,{Size=UDim2.new(r,0,1,0)});safeCallback(o.Callback,val) end
  set(nil,val);return {Instance=f,Get=function() return val end,Set=set}
 end
 if #self._tabs==1 then select() end
 return tab
end

return NyxOS
