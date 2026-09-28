--[[
============================================================
  [8] LOGIC LOOPS (FULL DEBUGGED)
============================================================
]]

local S = _G.STHAIN
local Config = S.Config
local Utils = S.Utils
local Run = S.Services.Run
local UIS = S.Services.UIS
local Lighting = S.Services.Lighting
local Cam = S.Cam
local LP = S.LP

-- ============================================================
-- STATE TRACKERS
-- ============================================================
local State = {
    Fly = false,
    Noclip = false,
    Invisible = false,
    Fullbright = false,
    NoFog = false,
    SelfHitbox = false,
    EnemyHitbox = false,
    ESP = false,
    KillAura = false,
    TargetLock = false,
    AutoHeal = false,
    AutoTP = false,
}

-- ============================================================
-- MOVEMENT
-- ============================================================
task.wait(2)

Run.RenderStepped:Connect(function()
    local hum = Utils.getHum()
    if hum then
        if hum.WalkSpeed ~= Config.Movement.WalkSpeed then
            hum.WalkSpeed = Config.Movement.WalkSpeed
        end
        if hum.HipHeight ~= Config.Movement.HipHeight then
            hum.HipHeight = Config.Movement.HipHeight
        end
        if hum.JumpPower ~= Config.Movement.JumpPower then
            hum.JumpPower = Config.Movement.JumpPower
        end
    end
end)

-- ============================================================
-- NOCLIP (FIX)
-- ============================================================
local lastSafePos = nil

Run.Stepped:Connect(function()
    local char = Utils.getChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end

    if Config.Movement.Noclip then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)

        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end

        if not Config.Movement.Fly then
            if hrp.Velocity.Y < -10 then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
            end
        end

        if hrp.Position.Y > -50 then
            lastSafePos = hrp.Position
        end

        State.Noclip = true
    elseif State.Noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        State.Noclip = false
    end
end)

-- Anti fall
task.spawn(function()
    while task.wait(0.5) do
        if Config.Movement.Noclip and lastSafePos then
            local hrp = Utils.getHRP()
            if hrp and hrp.Position.Y < -50 then
                hrp.CFrame = CFrame.new(lastSafePos + Vector3.new(0, 5, 0))
                hrp.Velocity = Vector3.zero
                print("[Noclip] Restored from fall")
            end
        end
    end
end)

-- ============================================================
-- INFINITE JUMP
-- ============================================================
task.spawn(function()
    while task.wait(0.1) do
        if Config.Movement.InfJump then
            local hum = Utils.getHum()
            if hum then
                local state = hum:GetState()
                if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
                    pcall(function()
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end)
                end
            end
        end
    end
end)

-- ============================================================
-- ANTI-STUN
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        if Config.Combat.AntiStun then
            local hum = Utils.getHum()
            if hum then
                pcall(function()
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                end)
            end
        end
    end
end)

-- ============================================================
-- AUTO ATTACK / RUSH (cuma pas diam)
-- ============================================================
local atkTimer, rushTimer = 0, 0
task.spawn(function()
    while task.wait(0.1) do
        local now = tick()
        local hum = Utils.getHum()
        if not hum then continue end

        local moving = hum.MoveDirection.Magnitude > 0.1

        if Config.Combat.AutoAttack and not moving and now - atkTimer >= Config.Combat.AttackDelay then
            atkTimer = now
            Utils.sendKey(Enum.KeyCode.V, 0.05)
        end
        if Config.Combat.AutoRush and not moving and now - rushTimer >= Config.Combat.RushDelay then
            rushTimer = now
            Utils.sendKey(Enum.KeyCode.B, 0.05)
        end
    end
end)

-- ============================================================
-- KILL AURA (FIX)
-- ============================================================
local killAuraCD = 0
task.spawn(function()
    while task.wait(0.05) do
        if Config.Combat.KillAura then
            local char = Utils.getChar()
            local hrp = Utils.getHRP()
            local hum = Utils.getHum()
            if not (char and hrp and hum) then continue end

            local nearest, nearestDist, nearestModel = nil, Config.Combat.KillAuraRange, nil
            for _, model in pairs(workspace:GetChildren()) do
                if model == char then continue end
                if not model:IsA("Model") then continue end
                local mhum = model:FindFirstChildOfClass("Humanoid")
                if not mhum or mhum.Health <= 0 then continue end
                local thrp = model:FindFirstChild("HumanoidRootPart")
                if not thrp then continue end

                local dist = (thrp.Position - hrp.Position).Magnitude
                if dist < 5 then continue end
                if dist < nearestDist then
                    nearest = thrp
                    nearestModel = model
                    nearestDist = dist
                end
            end

            if nearest and nearestModel then
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {char}
                local ray = workspace:Raycast(hrp.Position, (nearest.Position - hrp.Position), rayParams)
                local hasLOS = true
                if ray and ray.Instance then
                    local hitModel = ray.Instance:FindFirstAncestorOfClass("Model")
                    if hitModel ~= nearestModel then hasLOS = false end
                end

                if hasLOS then
                    local myLook = hrp.CFrame.LookVector
                    local toEnemy = (nearest.Position - hrp.Position).Unit
                    if myLook:Dot(toEnemy) < 0.7 then
                        local targetCF = CFrame.new(hrp.Position, Vector3.new(nearest.Position.X, hrp.Position.Y, nearest.Position.Z))
                        hrp.CFrame = hrp.CFrame:Lerp(targetCF, 0.5)
                    end
                    if tick() - killAuraCD >= 0.3 then
                        killAuraCD = tick()
                        Utils.sendKey(Enum.KeyCode.V, 0.05)
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- TARGET LOCK (FIX - jangan lock diri sendiri)
-- ============================================================
local origCamType = Cam.CameraType
task.spawn(function()
    while task.wait(0.05) do
        if Config.Combat.TargetLock then
            local char = Utils.getChar()
            local hrp = Utils.getHRP()
            if not (char and hrp) then continue end

            local nearest, nearestDist = nil, 150

            for _, model in pairs(workspace:GetChildren()) do
                if model == char then continue end
                if not model:IsA("Model") then continue end
                local hum = model:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local thrp = model:FindFirstChild("HumanoidRootPart")
                if not thrp then continue end

                local dist = (thrp.Position - hrp.Position).Magnitude
                if dist < 5 then continue end

                if dist < nearestDist then
                    nearest = thrp
                    nearestDist = dist
                end
            end

            if nearest then
                Cam.CameraType = Enum.CameraType.Scriptable
                Cam.CFrame = CFrame.new(Cam.CFrame.Position, nearest.Position)
            end
            State.TargetLock = true
        elseif State.TargetLock then
            if Cam.CameraType == Enum.CameraType.Scriptable then
                Cam.CameraType = origCamType
            end
            State.TargetLock = false
        end
    end
end)

-- ============================================================
-- AUTO HEAL
-- ============================================================
local healCD = 0
task.spawn(function()
    while task.wait(0.5) do
        if Config.Combat.AutoHeal then
            local hum = Utils.getHum()
            if hum and hum.Health > 0 then
                local pct = (hum.Health / hum.MaxHealth) * 100
                if pct <= Config.Combat.HealThreshold and tick() - healCD >= 1.5 then
                    healCD = tick()
                    Utils.sendKey(Enum.KeyCode.H, 0.05)
                end
            end
        end
    end
end)

-- ============================================================
-- INF AMMO
-- ============================================================
task.spawn(function()
    while task.wait(0.2) do
        if Config.Combat.InfAmmo then
            local char = Utils.getChar()
            if not char then continue end
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                for _, obj in pairs(tool:GetDescendants()) do
                    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        local n = string.lower(obj.Name)
                        if n:find("ammo") or n:find("bullet") or n:find("mag") or n:find("clip") or n:find("round") then
                            pcall(function() obj.Value = 999 end)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- WEAPON RANGE
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        local char = Utils.getChar()
        if not char then continue end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            if Config.Misc.WeaponRange then
                for _, obj in pairs(tool:GetDescendants()) do
                    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        local n = string.lower(obj.Name)
                        if n:find("range") or n:find("distance") or n:find("reach") then
                            if not obj:GetAttribute("CA_Orig") then
                                obj:SetAttribute("CA_Orig", obj.Value)
                            end
                            local orig = obj:GetAttribute("CA_Orig")
                            pcall(function() obj.Value = orig * Config.Misc.RangeMultiplier end)
                        end
                    end
                end
            else
                for _, obj in pairs(tool:GetDescendants()) do
                    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        if obj:GetAttribute("CA_Orig") then
                            pcall(function() obj.Value = obj:GetAttribute("CA_Orig") end)
                            obj:SetAttribute("CA_Orig", nil)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- ESP (FULL)
-- ============================================================
local espCache = {}

local function cleanupESP()
    for _, objs in pairs(espCache) do
        for _, obj in pairs(objs) do
            pcall(function() obj:Destroy() end)
        end
    end
    espCache = {}
end

task.spawn(function()
    while task.wait(0.3) do
        local active = Config.Visual.ESPBox or Config.Visual.ESPTracer or Config.Visual.ESPHealth or Config.Visual.ESPName or Config.Visual.Chams

        if not active then
            if State.ESP then
                cleanupESP()
                State.ESP = false
            end
        else
            State.ESP = true
            local char = Utils.getChar()
            for _, model in pairs(workspace:GetChildren()) do
                if model == char then continue end
                if not model:IsA("Model") then continue end
                local hum = model:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end

                if not espCache[model] then
                    local objs = {}

                    if Config.Visual.Chams then
                        local hl = Instance.new("Highlight")
                        hl.Name = "CA_ESP"
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Adornee = model
                        hl.Parent = S.GUI.Screen
                        table.insert(objs, hl)
                    end

                    if Config.Visual.ESPName then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "CA_ESP_Name"
                        bb.Size = UDim2.new(0, 120, 0, 24)
                        bb.StudsOffset = Vector3.new(0, 3, 0)
                        bb.AlwaysOnTop = true
                        bb.Adornee = hrp
                        bb.Parent = S.GUI.Screen
                        local nameLbl = Instance.new("TextLabel")
                        nameLbl.Size = UDim2.new(1, 0, 1, 0)
                        nameLbl.Text = model.Name
                        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                        nameLbl.TextStrokeTransparency = 0
                        nameLbl.TextSize = 14
                        nameLbl.Font = Enum.Font.GothamBold
                        nameLbl.BackgroundTransparency = 1
                        nameLbl.Parent = bb
                        table.insert(objs, bb)
                    end

                    if Config.Visual.ESPHealth then
                        local hb = Instance.new("BillboardGui")
                        hb.Name = "CA_ESP_Health"
                        hb.Size = UDim2.new(0, 60, 0, 6)
                        hb.StudsOffset = Vector3.new(0, 2.3, 0)
                        hb.AlwaysOnTop = true
                        hb.Adornee = hrp
                        hb.Parent = S.GUI.Screen
                        local bg = Instance.new("Frame")
                        bg.Size = UDim2.new(1, 0, 1, 0)
                        bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        bg.BorderSizePixel = 0
                        bg.Parent = hb
                        local fill = Instance.new("Frame")
                        fill.Name = "Fill"
                        fill.Size = UDim2.new(1, 0, 1, 0)
                        fill.BackgroundColor3 = Color3.fromRGB(80, 220, 130)
                        fill.BorderSizePixel = 0
                        fill.Parent = bg
                        table.insert(objs, hb)
                    end

                    espCache[model] = objs
                end
            end

            -- Update health
            for model, objs in pairs(espCache) do
                if not model.Parent then
                    for _, obj in pairs(objs) do pcall(function() obj:Destroy() end) end
                    espCache[model] = nil
                else
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum then
                        for _, obj in pairs(objs) do
                            if obj:IsA("BillboardGui") then
                                local fill = obj:FindFirstChild("Fill", true)
                                if fill then
                                    local pct = hum.Health / hum.MaxHealth
                                    fill.Size = UDim2.new(pct, 0, 1, 0)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- FLY (LinearVelocity)
-- ============================================================
local flyLV, flyAO, flyConn
local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyLV then flyLV:Destroy() flyLV = nil end
    if flyAO then flyAO:Destroy() flyAO = nil end
    local hrp = Utils.getHRP()
    if hrp then
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end
    local hum = Utils.getHum()
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Freefall) end) end
end

local function startFly()
    stopFly()
    local hrp = Utils.getHRP()
    if not hrp then return end

    flyLV = Instance.new("LinearVelocity")
    flyLV.MaxForce = math.huge
    flyLV.VectorVelocity = Vector3.zero
    flyLV.Parent = hrp

    flyAO = Instance.new("AlignOrientation")
    flyAO.Mode = Enum.OrientationAlignmentMode.OneAttachment
    flyAO.MaxTorque = math.huge
    flyAO.Responsiveness = 200
    flyAO.Parent = hrp

    flyConn = Run.Heartbeat:Connect(function()
        if not Config.Movement.Fly then return end
        local hum = Utils.getHum()
        if not (hum and flyLV and flyAO) then return end
        flyAO.CFrame = Cam.CFrame
        flyLV.VectorVelocity = hum.MoveDirection * Config.Movement.FlySpeed
    end)
end

task.spawn(function()
    while task.wait(0.3) do
        if Config.Movement.Fly and not State.Fly then
            startFly()
            State.Fly = true
        elseif not Config.Movement.Fly and State.Fly then
            stopFly()
            State.Fly = false
        end
    end
end)

-- ============================================================
-- FULLBRIGHT / NO FOG
-- ============================================================
local origBright = Lighting.Brightness
local origAmbient = Lighting.Ambient
local origOutdoor = Lighting.OutdoorAmbient
local origFogEnd = Lighting.FogEnd
local origFogStart = Lighting.FogStart

task.spawn(function()
    while task.wait(0.5) do
        if Config.Visual.Fullbright then
            Lighting.Brightness = 3
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
            State.Fullbright = true
        elseif State.Fullbright then
            Lighting.Brightness = origBright
            Lighting.Ambient = origAmbient
            Lighting.OutdoorAmbient = origOutdoor
            State.Fullbright = false
        end

        if Config.Visual.NoFog then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 100000
            State.NoFog = true
        elseif State.NoFog then
            Lighting.FogEnd = origFogEnd
            Lighting.FogStart = origFogStart
            State.NoFog = false
        end
    end
end)

-- ============================================================
-- INVISIBLE
-- ============================================================
task.spawn(function()
    while task.wait(0.3) do
        local char = Utils.getChar()
        if not char then continue end

        if Config.Visual.Invisible then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and not part:GetAttribute("CA_Invis") then
                    part:SetAttribute("CA_Invis", true)
                    part:SetAttribute("CA_OrigTrans", part.Transparency)
                    part.Transparency = 1
                end
            end
            State.Invisible = true
        elseif State.Invisible then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part:GetAttribute("CA_Invis") then
                    part.Transparency = part:GetAttribute("CA_OrigTrans") or 0
                    part:SetAttribute("CA_Invis", nil)
                    part:SetAttribute("CA_OrigTrans", nil)
                end
            end
            State.Invisible = false
        end
    end
end)

-- ============================================================
-- HITBOX
-- ============================================================
local origHRPSize = nil
task.spawn(function()
    while task.wait(0.3) do
        local char = Utils.getChar()
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        -- SELF
        if Config.Visual.SelfHitbox then
            if not origHRPSize then origHRPSize = hrp.Size end
            pcall(function() hrp.Size = Vector3.new(Config.Visual.SelfHitboxSize, Config.Visual.SelfHitboxSize, Config.Visual.SelfHitboxSize) end)
            local box = char:FindFirstChild("CA_SelfHB")
            if not box then
                box = Instance.new("Part")
                box.Name = "CA_SelfHB"
                box.Size = Vector3.new(Config.Visual.SelfHitboxSize, Config.Visual.SelfHitboxSize, Config.Visual.SelfHitboxSize)
                box.Transparency = 0.7
                box.CanCollide = false
                box.CanQuery = true
                box.CanTouch = true
                box.Massless = true
                box.CFrame = hrp.CFrame
                box.Parent = char
                local w = Instance.new("WeldConstraint")
                w.Part0 = hrp
                w.Part1 = box
                w.Parent = box
            end
            State.SelfHitbox = true
        elseif State.SelfHitbox then
            if origHRPSize then
                pcall(function() hrp.Size = origHRPSize end)
                origHRPSize = nil
            end
            local box = char:FindFirstChild("CA_SelfHB")
            if box then box:Destroy() end
            State.SelfHitbox = false
        end

        -- ENEMY
        if Config.Visual.EnemyHitbox then
            for _, model in pairs(workspace:GetChildren()) do
                if model == char then continue end
                if not model:IsA("Model") then continue end
                local hum = model:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                if not model:FindFirstChild("CA_EnemyHB") then
                    local thrp = model:FindFirstChild("HumanoidRootPart")
                    if thrp then
                        local box = Instance.new("Part")
                        box.Name = "CA_EnemyHB"
                        box.Size = Vector3.new(Config.Visual.EnemyHitboxSize, Config.Visual.EnemyHitboxSize, Config.Visual.EnemyHitboxSize)
                        box.Transparency = 0.8
                        box.CanCollide = false
                        box.CanQuery = true
                        box.CanTouch = true
                        box.Massless = true
                        box.CFrame = thrp.CFrame
                        box.Parent = model
                        local w = Instance.new("WeldConstraint")
                        w.Part0 = thrp
                        w.Part1 = box
                        w.Parent = box
                    end
                end
            end
            State.EnemyHitbox = true
        elseif State.EnemyHitbox then
            for _, model in pairs(workspace:GetChildren()) do
                local box = model:FindFirstChild("CA_EnemyHB")
                if box then box:Destroy() end
            end
            State.EnemyHitbox = false
        end
    end
end)

-- ============================================================
-- ANTI-AFK
-- ============================================================
task.spawn(function()
    while task.wait(60) do
        if Config.Misc.AntiAFK then
            pcall(function()
                S.Services.VU:CaptureController()
                S.Services.VU:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- ============================================================
-- AUTO TP
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        if Config.Misc.AutoTP then
            local char = Utils.getChar()
            local hrp = Utils.getHRP()
            if not (char and hrp) then continue end
            local nearest, nearestDist = nil, Config.Misc.AutoTPRange
            for _, model in pairs(workspace:GetChildren()) do
                if model == char then continue end
                if not model:IsA("Model") then continue end
                local hum = model:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local thrp = model:FindFirstChild("HumanoidRootPart")
                if thrp then
                    local dist = (thrp.Position - hrp.Position).Magnitude
                    if dist > 5 and dist < nearestDist then
                        nearest = thrp
                        nearestDist = dist
                    end
                end
            end
            if nearest then
                hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- ============================================================
-- TELEPORT SYSTEM
-- ============================================================
function _G.STHAIN.TeleportScan()
    local results = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        local n = string.lower(obj.Name)
        if n:find("capture") or n:find("base") or n:find("supply") or n:find("camp") or n:find("point") then
            if obj:IsA("BasePart") then
                table.insert(results, {
                    name = obj.Name,
                    position = obj.Position,
                    instance = obj
                })
            end
        end
    end
    return results
end

function _G.STHAIN.TeleportTo(part)
    local char = Utils.getChar()
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local targetPos = part.Position + Vector3.new(0, Config.Teleport.OffsetY, 0)
    local startPos = hrp.Position
    local steps = Config.Teleport.SmoothSteps or 10

    task.spawn(function()
        for i = 1, steps do
            local alpha = i / steps
            pcall(function()
                hrp.CFrame = CFrame.new(startPos:Lerp(targetPos, alpha))
            end)
            task.wait(0.03)
        end
    end)
    return true
end

task.spawn(function()
    while task.wait(0.5) do
        if Config.Teleport.Enabled and Config.Teleport.SelectedPoint then
            local point = Config.Teleport.SelectedPoint
            if point and point.Parent then
                _G.STHAIN.TeleportTo(point)
            end
        end
    end
end)

-- ============================================================
-- RESPAWN HANDLER
-- ============================================================
LP.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    origHRPSize = nil
    lastSafePos = nil
    State.Invisible = false
    State.Noclip = false
    State.SelfHitbox = false
    State.EnemyHitbox = false
    State.Fly = false
    if flyLV then stopFly() end
    cleanupESP()
    print("[STHAIN] Character respawned, features reset")
end)

print("[STHAIN] Logic loops loaded - FULL DEBUGGED")
