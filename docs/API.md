# NyxOS API

NyxOS is a modular Roblox Luau UI library focused on animated, themeable interfaces.

## Status

The project is being built incrementally. The theme palette is available in `src/Themes.lua`. API examples below describe the intended public interface; only use methods that exist in the version of the library you have installed.

## Planned API

```lua
local NyxOS = require(path.to.NyxOS)

local window = NyxOS:CreateWindow({
    Title = "NyxOS",
    Theme = "Matrix",
    Size = UDim2.fromOffset(640, 420),
})

local tab = window:CreateTab({
    Name = "Main",
    Icon = "house",
})

tab:AddButton({
    Name = "Example",
    Callback = function()
        print("Button clicked")
    end,
})

tab:AddToggle({
    Name = "Enabled",
    Default = false,
    Callback = function(value)
        print("Enabled:", value)
    end,
})

tab:AddSlider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("Speed:", value)
    end,
})

tab:AddDropdown({
    Name = "Mode",
    Options = {"A", "B", "C"},
    Default = "A",
    Callback = function(value)
        print("Mode:", value)
    end,
})

tab:AddTextbox({
    Name = "Player name",
    Placeholder = "Enter a name",
    Callback = function(value)
        print(value)
    end,
})

tab:AddLabel({
    Name = "Ready",
})
```

## Theme names

- `Matrix` — green terminal-inspired palette.
- `Neon` — violet and cyan accents.
- `Dark` — dark neutral palette with blue accents.
- `Light` — light neutral palette.

## Compatibility

NyxOS targets Roblox Luau. Test the library in a controlled Roblox Studio place before using it in a live experience. Do not assume that planned API methods are implemented until their source modules are present.
