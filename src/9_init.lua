--[[
============================================================
  [9] INIT
============================================================
]]

-- Semua module udah jalan sendiri lewat _G.STHAIN
-- File ini cuma buat finalisasi

local S = _G.STHAIN

if S and S.GUI then
    print("[STHAIN HUB] Initialized successfully!")
else
    warn("[STHAIN] Init failed - check modules")
end
