local BASE = "https://raw.githubusercontent.com/btz157/nyxOS/main/"
local cache = {}
local function req(path)
	if cache[path] == nil then
		local src = game:HttpGet(BASE .. path .. ".lua")
		local fn, err = loadstring(src, "=" .. path)
		assert(fn, err)
		cache[path] = fn(req)
	end
	return cache[path]
end
return req("src/init")
