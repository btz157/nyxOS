-- Place this LocalScript next to the NyxOS ModuleScript in a Roblox Studio test place.
local NyxOS = require(script.Parent:WaitForChild("NyxOS"))

local window = NyxOS:CreateWindow({
    Title = "NYXOS // CONTROL CENTER",
    Theme = "Matrix",
    Size = UDim2.fromOffset(700, 460),
    ToggleKey = Enum.KeyCode.RightControl,
})

local main = window:CreateTab({Name = "Dashboard", Icon = "◆"})
main:AddLabel({Name = "SYSTEM ONLINE  •  NyxOS " .. NyxOS.Version, Color = Color3.fromRGB(0,255,120)})
main:AddSection({Name = "Quick controls"})
main:AddButton({
    Name = "Run diagnostic",
    Callback = function()
        window:Notify({Title = "Diagnostics", Description = "Interface callback executed.", Duration = 3})
    end,
})
main:AddToggle({Name = "Animated effects", Default = true, Callback = function(value)
    print("Animated effects:", value)
end})
main:AddSlider({Name = "Intensity", Min = 0, Max = 100, Default = 65, Callback = function(value)
    print("Intensity:", value)
end})
main:AddDropdown({Name = "Profile", Options = {"Balanced", "Performance", "Visual"}, Default = "Balanced", Callback = function(value)
    print("Profile:", value)
end})
main:AddTextbox({Name = "Session label", Placeholder = "Enter a label", Callback = function(value)
    print("Session label:", value)
end})

local progress = main:AddProgressBar({Name = "Example progress", Min = 0, Max = 100, Default = 35})
main:AddButton({Name = "Advance progress", Callback = function() progress:Set(math.min(progress:Get() + 10, 100)) end})
main:AddDivider()

local about = window:CreateTab({Name = "About", Icon = "ⓘ"})
about:AddLabel({Name = "NyxOS is a modular Luau UI library."})
about:AddLabel({Name = "Test in Roblox Studio before using in a live experience."})
