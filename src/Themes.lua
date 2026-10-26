--!strict
-- NyxOS theme palette definitions.
-- Supported themes: Matrix, Neon, Dark and Light.

local Themes = {}

Themes.Matrix = {
    Name = "Matrix",
    Background = Color3.fromRGB(8, 12, 10),
    Surface = Color3.fromRGB(14, 22, 17),
    SurfaceHover = Color3.fromRGB(22, 36, 26),
    Primary = Color3.fromRGB(0, 255, 110),
    Secondary = Color3.fromRGB(0, 190, 85),
    Text = Color3.fromRGB(220, 255, 230),
    MutedText = Color3.fromRGB(115, 160, 128),
    Border = Color3.fromRGB(0, 110, 55),
    Danger = Color3.fromRGB(255, 75, 95),
    Success = Color3.fromRGB(0, 255, 140),
}

Themes.Neon = {
    Name = "Neon",
    Background = Color3.fromRGB(13, 10, 24),
    Surface = Color3.fromRGB(25, 19, 42),
    SurfaceHover = Color3.fromRGB(39, 29, 62),
    Primary = Color3.fromRGB(180, 90, 255),
    Secondary = Color3.fromRGB(60, 220, 255),
    Text = Color3.fromRGB(245, 239, 255),
    MutedText = Color3.fromRGB(166, 151, 194),
    Border = Color3.fromRGB(91, 54, 140),
    Danger = Color3.fromRGB(255, 75, 120),
    Success = Color3.fromRGB(80, 255, 190),
}

Themes.Dark = {
    Name = "Dark",
    Background = Color3.fromRGB(17, 18, 22),
    Surface = Color3.fromRGB(27, 29, 35),
    SurfaceHover = Color3.fromRGB(38, 41, 49),
    Primary = Color3.fromRGB(100, 145, 255),
    Secondary = Color3.fromRGB(125, 135, 160),
    Text = Color3.fromRGB(240, 242, 248),
    MutedText = Color3.fromRGB(155, 160, 175),
    Border = Color3.fromRGB(60, 64, 76),
    Danger = Color3.fromRGB(255, 85, 95),
    Success = Color3.fromRGB(65, 210, 135),
}

Themes.Light = {
    Name = "Light",
    Background = Color3.fromRGB(242, 244, 248),
    Surface = Color3.fromRGB(255, 255, 255),
    SurfaceHover = Color3.fromRGB(230, 234, 242),
    Primary = Color3.fromRGB(55, 105, 230),
    Secondary = Color3.fromRGB(90, 105, 135),
    Text = Color3.fromRGB(28, 32, 43),
    MutedText = Color3.fromRGB(105, 112, 130),
    Border = Color3.fromRGB(210, 215, 226),
    Danger = Color3.fromRGB(215, 55, 70),
    Success = Color3.fromRGB(25, 155, 95),
}

function Themes.Get(themeName: string?)
    local key = themeName or "Matrix"
    return Themes[key] or Themes.Matrix
end

return Themes
