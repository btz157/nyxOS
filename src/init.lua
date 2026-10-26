--!strict
-- NyxOS UI Library
-- Roblox Luau. Use from a ModuleScript in an experience you own or are authorized to develop.

local Themes = require(script.Parent.Themes)
local Window = require(script.Parent.Window)

local NyxOS = {}
NyxOS.__index = NyxOS
NyxOS.Version = "0.1.0"

export type WindowOptions = {
    Title: string?,
    Theme: string?,
    Size: UDim2?,
    Position: UDim2?,
    ToggleKey: Enum.KeyCode?,
    Parent: Instance?,
}

function NyxOS:GetTheme(name: string?)
    return Themes.Get(name)
end

function NyxOS:CreateWindow(options)
    options = options or {}
    local theme = Themes.Get(options.Theme)
    return Window.new({
        Title = options.Title or "NyxOS",
        Theme = theme,
        Size = options.Size or UDim2.fromOffset(680, 450),
        Position = options.Position,
        ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl,
        Parent = options.Parent,
    })
end

function NyxOS:Notify(options)
    if type(options) ~= "table" then
        options = {Title = "NyxOS", Description = tostring(options)}
    end
    local parent = options.Parent
    if not parent then
        warn("[NyxOS] Notify requires Parent = window or ScreenGui.")
        return
    end
    local notify = parent.Notify
    if type(notify) == "function" then
        notify(parent, options)
    else
        warn("[NyxOS] Parent does not support notifications.")
    end
end

NyxOS.Themes = Themes
return setmetatable({}, NyxOS)
