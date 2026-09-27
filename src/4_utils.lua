--[[
============================================================
  [4] UTILS (PC + Mobile)
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
    local VIM = S.Services.VIM
    local delay = hold or 0.02

    pcall(function() VIM:SendKeyEvent(true, k, false, game) end)
    pcall(function() if keypress then keypress(k) end end)

    task.wait(delay)

    pcall(function() VIM:SendKeyEvent(false, k, false, game) end)
    pcall(function() if keyrelease then keyrelease(k) end end)
end

-- WORLD TO SCREEN (buat ESP Box / Tracer)
function Utils.worldToScreen(worldPos)
    local cam = workspace.CurrentCamera
    local screenPos, onScreen = cam:WorldToViewportPoint(worldPos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

S.Utils = Utils
