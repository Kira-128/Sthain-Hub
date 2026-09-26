--[[
============================================================
  [9] INIT
============================================================
]]

local S = _G.STHAIN

if S and S.GUI then
    print("[STHAIN HUB] Initialized successfully!")
    print("[STHAIN HUB] Platform: " .. (S.IsMobile and "Mobile" or "PC"))
else
    warn("[STHAIN] Init failed - check modules")
end
