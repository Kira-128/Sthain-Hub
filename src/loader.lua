--[[
============================================================
  STHAIN HUB - LOADER
  Author  : CABU
  Version : 1.3
============================================================
]]

local BASE = "https://sthain-hub.dzulfadhil33333.workers.dev/src/"

local Modules = {
    "1_services",
    "2_config",
    "3_theme",
    "4_utils",
    "5_gui",
    "6_components",
    "7_pages",
    "8_logic",
    "9_init",
}

local function fetch(name)
    local ok, src = pcall(function()
        return game:HttpGet(BASE .. name .. ".lua")
    end)
    if ok and src and #src > 0 then
        return src
    else
        warn("[STHAIN] Failed: " .. name)
        return ""
    end
end

print("[STHAIN HUB] Loading modules...")

local fullSource = "local _G = _G\n"
for _, mod in ipairs(Modules) do
    fullSource = fullSource .. "\n--[[" .. mod .. "]]\n" .. fetch(mod)
end

local fn, err = loadstring(fullSource)
if fn then
    local ok, e = pcall(fn)
    if not ok then
        warn("[STHAIN] Runtime error: " .. tostring(e))
    else
        print("[STHAIN HUB] Loaded successfully!")
    end
else
    warn("[STHAIN] Compile error: " .. tostring(err))
end
