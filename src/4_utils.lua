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

-- Send Key (PC + Mobile fallback)
function Utils.sendKey(k, hold)
    local VIM = S.Services.VIM
    local delay = hold or 0.02

    -- Metode 1: VIM (PC)
    pcall(function()
        VIM:SendKeyEvent(true, k, false, game)
    end)

    -- Metode 2: keypress (Mobile)
    pcall(function()
        if keypress then keypress(k) end
    end)

    task.wait(delay)

    -- Release
    pcall(function()
        VIM:SendKeyEvent(false, k, false, game)
    end)

    pcall(function()
        if keyrelease then keyrelease(k) end
    end)
end

S.Utils = Utils
