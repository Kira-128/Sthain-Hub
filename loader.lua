--[[
============================================================
  STHAIN HUB - LOADER (FIXED)
  Author  : Cabu
  Version : 1.3.1-debug
============================================================
]]

local BASE = "https://raw.githubusercontent.com/Kira-128/Sthain-Hub/main/src/"

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

_G.STHAIN = _G.STHAIN or {}
_G.STHAIN.Modules = _G.STHAIN.Modules or {}

local function fetch(name)
    local ok, src = pcall(game.HttpGet, game, BASE .. name .. ".lua")
    if ok and src and #src > 0 then
        print(("[STHAIN][OK] %s (%d bytes)"):format(name, #src))
        return src
    end
    print(("[STHAIN][FAIL] fetch %s"):format(name))
    return nil
end

print("[STHAIN HUB] === LOAD START ===")

for _, mod in ipairs(Modules) do
    local src = fetch(mod)
    if src then
        local fn, cerr = loadstring(src, "@" .. mod .. ".lua")
        if not fn then
            print(("[STHAIN][COMPILE-ERR] %s -> %s"):format(mod, tostring(cerr)))
        else
            local ok, rerr = pcall(fn)
            if not ok then
                print(("[STHAIN][RUNTIME-ERR] %s -> %s"):format(mod, tostring(rerr)))
            else
                _G.STHAIN.Modules[mod] = true
                print(("[STHAIN][EXEC-OK] %s"):format(mod))
            end
        end
    end
    task.wait()
end

print("[STHAIN HUB] === LOAD END ===")
print("[STHAIN] _G.STHAIN keys:")
if _G.STHAIN then
    for k, v in pairs(_G.STHAIN) do
        print(("  %s = %s"):format(k, typeof(v)))
    end
else
    print("  _G.STHAIN = NIL  <-- ROOT CAUSE")
end
