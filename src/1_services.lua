--[[
============================================================
  [1] SERVICES
============================================================
]]

local Services = {
    Players  = game:GetService("Players"),
    Run      = game:GetService("RunService"),
    VIM      = game:GetService("VirtualInputManager"),
    UIS      = game:GetService("UserInputService"),
    TS       = game:GetService("TweenService"),
    Lighting = game:GetService("Lighting"),
    VU       = game:GetService("VirtualUser"),
}

local LP  = Services.Players.LocalPlayer
local Cam = workspace.CurrentCamera

-- Deteksi platform
local IsMobile = Services.UIS.TouchEnabled and not Services.UIS.KeyboardEnabled
local IsPC = Services.UIS.KeyboardEnabled and not Services.UIS.TouchEnabled

_G.STHAIN = _G.STHAIN or {}
_G.STHAIN.Services = Services
_G.STHAIN.LP = LP
_G.STHAIN.Cam = Cam
_G.STHAIN.IsMobile = IsMobile
_G.STHAIN.IsPC = IsPC

print("[STHAIN] Platform: " .. (IsMobile and "Mobile" or IsPC and "PC" or "Unknown"))
