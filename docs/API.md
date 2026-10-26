# NyxOS API

NyxOS is a modular Roblox Luau UI library. Current source modules include the window, tabs, notifications, themes and six basic controls. This is an early development snapshot and has not yet been validated in Roblox Studio.

## Create a window

```lua
local NyxOS = require(path.to.NyxOS)

local window = NyxOS:CreateWindow({
    Title = "NYXOS // CONTROL CENTER",
    Theme = "Matrix", -- Matrix | Neon | Dark | Light
    Size = UDim2.fromOffset(700, 460),
    Position = UDim2.fromScale(0.5, 0.5), -- optional
    ToggleKey = Enum.KeyCode.RightControl, -- optional
    Parent = player.PlayerGui, -- optional; defaults to LocalPlayer.PlayerGui
})
```

The module must be required from a client context (normally a LocalScript) because it uses PlayerGui and input services.

## Tabs and controls

```lua
local tab = window:CreateTab({Name = "Dashboard", Icon = "◆"}) -- Icon is optional display text

tab:AddButton({
    Name = "Run",
    Callback = function()
        window:Notify({Title = "NyxOS", Description = "Finished", Duration = 3})
    end,
})

tab:AddToggle({
    Name = "Enabled",
    Default = false,
    Callback = function(value) print(value) end,
})

tab:AddSlider({
    Name = "Intensity",
    Min = 0,
    Max = 100,
    Default = 50,
    Decimals = 0, -- optional
    Callback = function(value) print(value) end,
})

tab:AddDropdown({
    Name = "Mode",
    Options = {"A", "B", "C"},
    Default = "A",
    Callback = function(value) print(value) end,
})

tab:AddTextbox({
    Name = "Label",
    Placeholder = "Type here",
    Default = "",
    Callback = function(text, enterPressed) print(text, enterPressed) end,
})

tab:AddLabel({Name = "Status ready", Color = Color3.new(1, 1, 1)})
```

Controls return their Roblox instance or a small controller table depending on the control. Toggle, slider, dropdown and textbox controller tables expose a current value getter; check the source module for the exact return shape.

## Window methods

- `window:CreateTab(options)` creates and returns a tab.
- `window:Notify({Title, Description, Content, Duration})` displays a toast.
- `window:Destroy()` destroys the ScreenGui and registered window-level input connections.
- `window:Close()` is an alias for `Destroy()`.

## Themes

`NyxOS:GetTheme(name)` returns the named theme palette, defaulting to Matrix for unknown names. `NyxOS.Themes` exposes the theme module.

## Limitations

- No runtime theme-switching method yet.
- No window resizing or persistence yet.
- Long dropdown lists need additional scrolling support.
- Component-level event connections and slider input connections need lifecycle review.
- The single-file distribution has not been generated.
- API and behavior are not yet Studio-validated; treat as early development.
