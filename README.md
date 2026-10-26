# NyxOS

**A modular, animated Roblox Luau UI library** with a Matrix-inspired default theme, alternate palettes, reusable controls, draggable windows, tabs, notifications and a minimize/restore orb.

> Current version: **0.1.0 — early development**. The modular source is being assembled incrementally. It has not yet been fully validated in Roblox Studio, and the single-file distribution is not available yet.

## Features

- Matrix, Neon, Dark and Light color palettes.
- Animated window entrance and hover states.
- Draggable top bar (mouse and touch input).
- Tabs with separate scrollable pages.
- Minimize button that creates a floating restore orb.
- Toast notifications with timed dismissal.
- Button, toggle, slider, dropdown, textbox, label, section, divider and progress controls.
- Callback error handling for most component callbacks.
- Modular Luau source and a Rojo project configuration.

## Project layout

```text
src/
  init.lua
  Themes.lua
  Window.lua
  Components/
    init.lua
    Button.lua
    Toggle.lua
    Slider.lua
    Dropdown.lua
    Textbox.lua
    Label.lua
    Section.lua
    Divider.lua
    ProgressBar.lua
examples/
  basic.client.lua
docs/
  API.md
dist/
  README.md
default.project.json
LICENSE
```

## Installation with Rojo

1. Install [Rojo](https://rojo.space/) on your development computer.
2. Clone or download this repository.
3. Open the folder in a terminal and run `rojo build -o NyxOS.rbxm`.
4. Import `NyxOS.rbxm` into Roblox Studio, or connect Rojo to a Studio test place.
5. Place the NyxOS ModuleScript somewhere accessible to a LocalScript.
6. Adapt `examples/basic.client.lua` to your place and test in **Play** mode.

The included project mapping is a starting point; check the resulting Roblox instance hierarchy before requiring the module.

## Quick start

```lua
local NyxOS = require(path.to.NyxOS)

local window = NyxOS:CreateWindow({
    Title = "NYXOS // CONTROL CENTER",
    Theme = "Matrix",
    Size = UDim2.fromOffset(700, 460),
    ToggleKey = Enum.KeyCode.RightControl,
})

local tab = window:CreateTab({Name = "Dashboard", Icon = "◆"})
tab:AddButton({
    Name = "Run",
    Callback = function()
        window:Notify({
            Title = "NyxOS",
            Description = "Callback executed.",
            Duration = 3,
        })
    end,
})
tab:AddToggle({Name = "Enabled", Default = true, Callback = function(value)
    print(value)
end})
tab:AddSlider({Name = "Intensity", Min = 0, Max = 100, Default = 50, Callback = function(value)
    print(value)
end})
tab:AddDropdown({Name = "Mode", Options = {"A", "B", "C"}, Default = "A", Callback = function(value)
    print(value)
end})
tab:AddTextbox({Name = "Name", Placeholder = "Type here", Callback = function(value)
    print(value)
end})
tab:AddLabel({Name = "Ready"})
```

## API and callbacks

Read [docs/API.md](docs/API.md) for the current API notes and planned behavior. Component methods generally accept an options table with `Name`, optional initial values and `Callback`.

## Important notes

- This library is intended for Roblox experiences you own or are authorized to develop. Use Roblox Studio and the official Luau runtime.
- It is not a guarantee of exploit-executor compatibility.
- Test touch behavior, resize behavior, callbacks and cleanup in Studio before production use.
- Version 0.1.0 is an early implementation. See the repository issues for bugs and planned work.
- Do not put passwords, API keys or other secrets in the source code.

## License

MIT. See [LICENSE](LICENSE).
