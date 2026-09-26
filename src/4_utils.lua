--[[
============================================================
  [4] UTILS
============================================================
]]

local S = _G.STHAIN
local LP = S.LP

local Utils = {}

function Utils.getChar()
    return LP.Character
end

function Utils.getHRP()
    local char = Utils.getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Utils.getHum()
    local char = Utils.getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Utils.isEnemy(model)
    if not model or model == LP.Character then return false end
    if not model:IsA("Model") then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return true
end

function Utils.sendKey(k, hold)
    pcall(function() S.Services.VIM:SendKeyEvent(true, k, false, game) end)
    task.wait(hold or 0.02)
    pcall(function() S.Services.VIM:SendKeyEvent(false, k, false, game) end)
end

S.Utils = Utils
