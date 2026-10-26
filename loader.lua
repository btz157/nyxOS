-- NyxOS loader (executor environments with loadstring + HttpGet support)
-- Raw URL points to the single-file runtime in this repository.
local URL = "https://raw.githubusercontent.com/btz157/nyxOS/main/dist/NyxOS.lua"

local ok, source = pcall(function()
    return game:HttpGet(URL)
end)
if not ok or type(source) ~= "string" or #source < 1000 then
    error("[NyxOS] Could not download the library. Check network access and repository URL.")
end

local compile = loadstring
if type(compile) ~= "function" then
    error("[NyxOS] This environment does not provide loadstring; execute dist/NyxOS.lua directly instead.")
end

local chunk, compileError = compile(source)
if not chunk then
    error("[NyxOS] Compilation failed: " .. tostring(compileError))
end

local success, library = pcall(chunk)
if not success then
    error("[NyxOS] Startup failed: " .. tostring(library))
end

return library
