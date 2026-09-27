--[[
============================================================
  [8] LOGIC LOOPS (FULL FIX - PC + Mobile)
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
-- MOVEMENT
-- ============================================================
Run.RenderStepped:Connect(function()
    local hum = Utils.getHum()
    if hum then
        hum.WalkSpeed = Config.Movement.WalkSpeed
        hum.HipHeight = Config.Movement.HipHeight
        hum.JumpPower = Config.Movement.JumpPower
    end
end)

-- ============================================================
-- NOCLIP (FIX - anti jatuh ke tanah)
-- ============================================================
local lastSafePos = nil

Run.Stepped:Connect(function()
    if not Config.Movement.Noclip then return end
    local char = Utils.getChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end

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
end)

-- Anti fall
task.spawn(function()
    while task.wait(0.5) do
        if not Config.Movement.Noclip then continue end
        local hrp = Utils.getHRP()
        if hrp and hrp.Position.Y < -50 and lastSafePos then
            hrp.CFrame = CFrame.new(lastSafePos + Vector3.new(0, 5, 0))
            hrp.Velocity = Vector3.zero
            print("[Noclip] Restored from fall")
        end
    end
end)

-- ============================================================
-- INFINITE JUMP (FIX - mobile support)
-- ============================================================
task.spawn(function()
    while task.wait(0.1) do
        if not Config.Movement.InfJump then continue end
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
end)

-- ============================================================
-- ANTI-STUN (BARU)
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        if not Config.Combat.AntiStun then continue end
        local hum = Utils.getHum()
        if hum then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            end)
        end
    end
end)

-- ============================================================
-- AUTO ATTACK / RUSH
-- ============================================================
local atkTimer, rushTimer = 0, 0
task.spawn(function()
    while task.wait(0.05) do
        local now = tick()
        if Config.Combat.AutoAttack and now - atkTimer >= Config.Combat.AttackDelay then
            atkTimer = now
            Utils.sendKey(Enum.KeyCode.V, 0.02)
        end
        if Config.Combat.AutoRush and now - rushTimer >= Config.Combat.RushDelay then
            rushTimer = now
            Utils.sendKey(Enum.KeyCode.B, 0.02)
        end
    end
end)

-- ============================================================
-- KILL AURA (FIX)
-- ============================================================
local killAuraCD = 0
task.spawn(function()
    while task.wait(0.05) do
        if not Config.Combat.KillAura then continue end
        local hrp = Utils.getHRP()
        local hum = Utils.getHum()
        if not (hrp and hum) then continue end

        local nearest, nearestDist, nearestModel = nil, Config.Combat.KillAuraRange, nil
        for _, model in pairs(workspace:GetChildren()) do
            if Utils.isEnemy(model) then
                local thrp = model:FindFirstChild("HumanoidRootPart")
                if thrp then
                    local dist = (thrp.Position - hrp.Position).Magnitude
                    if dist < nearestDist then
                        nearest = thrp
                        nearestModel = model
                        nearestDist = dist
                    end
                end
            end
        end

        if nearest and nearestModel then
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {LP.Character}
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
                if tick() - killAuraCD >= 0.15 then
                    killAuraCD = tick()
                    Utils.sendKey(Enum.KeyCode.V, 0.03)
                end
            end
        end
    end
end)

-- ============================================================
-- TARGET LOCK
-- ============================================================
local origCamType = Cam.CameraType
task.spawn(function()
    while task.wait(0.05) do
        if Config.Combat.TargetLock then
            local hrp = Utils.getHRP()
            if hrp then
                local nearest, nearestDist = nil, 100
                for _, model in pairs(workspace:GetChildren()) do
                    if Utils.isEnemy(model) then
                        local thrp = model:FindFirstChild("HumanoidRootPart")
                        if thrp then
                            local dist = (thrp.Position - hrp.Position).Magnitude
                            if dist < nearestDist then
                                nearest = thrp
                                nearestDist = dist
                            end
                        end
                    end
                end
                if nearest then
                    Cam.CameraType = Enum.CameraType.Scriptable
                    Cam.CFrame = CFrame.new(Cam.CFrame.Position, nearest.Position)
                end
            end
        else
            if Cam.CameraType == Enum.CameraType.Scriptable then
                Cam.CameraType = origCamType
            end
        end
    end
end)

-- ============================================================
-- AUTO HEAL
-- ============================================================
local healCD = 0
task.spawn(function()
    while task.wait(0.5) do
        if not Config.Combat.AutoHeal then continue end
        local hum = Utils.getHum()
        if hum and hum.Health > 0 then
            local pct = (hum.Health / hum.MaxHealth) * 100
            if pct <= Config.Combat.HealThreshold and tick() - healCD >= 1 then
                healCD = tick()
                Utils.sendKey(Enum.KeyCode.H, 0.05)
            end
        end
    end
end)

-- ============================================================
-- INF AMMO
-- ============================================================
task.spawn(function()
    while task.wait(0.1) do
        if not Config.Combat.InfAmmo then continue end
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
end)

-- ============================================================
-- WEAPON RANGE (BARU)
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        if not Config.Misc.WeaponRange then continue end
        local char = Utils.getChar()
        if not char then continue end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
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
        end
    end
end)

-- ============================================================
-- ESP (FULL - Box + Tracer + Health + Name + Chams)
-- ============================================================
local espCache = {}
local espDrawing = {}

-- Cleanup Drawing
local function cleanupDrawing()
    for _, d in pairs(espDrawing) do
        pcall(function() d:Remove() end)
    end
    espDrawing = {}
end

task.spawn(function()
    while task.wait(0.3) do
        local active = Config.Visual.ESPBox or Config.Visual.ESPTracer or Config.Visual.ESPHealth or Config.Visual.ESPName or Config.Visual.Chams
        if not active then
            for model, objs in pairs(espCache) do
                for _, obj in pairs(objs) do pcall(function() obj:Destroy() end) end
            end
            espCache = {}
            cleanupDrawing()
        else
            for _, model in pairs(workspace:GetChildren()) do
                if Utils.isEnemy(model) and not espCache[model] then
                    local hrp = model:FindFirstChild("HumanoidRootPart")
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hrp and hum then
                        local objs = {}

                        -- Chams (Highlight)
                        if Config.Visual.Chams then
                            local hl = Instance.new("Highlight")
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.Adornee = model
                            hl.Parent = S.GUI.Screen
                            table.insert(objs, hl)
                        end

                        -- ESP Name
                        if Config.Visual.ESPName then
                            local bb = Instance.new("BillboardGui")
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

                        -- ESP Health
                        if Config.Visual.ESPHealth then
                            local hb = Instance.new("BillboardGui")
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

-- ESP Box + Tracer (pake Drawing kalau support, kalau enggak skip)
task.spawn(function()
    if not Drawing then return end
    while task.wait(0.05) do
        local active = Config.Visual.ESPBox or Config.Visual.ESPTracer
        if not active then
            cleanupDrawing()
        else
            cleanupDrawing()
            local cam = workspace.CurrentCamera
            for _, model in pairs(workspace:GetChildren()) do
                if Utils.isEnemy(model) then
                    local hrp = model:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local pos, onScreen = Utils.worldToScreen(hrp.Position)
                        if onScreen then
                            if Config.Visual.ESPBox then
                                local box = Drawing.new("Square")
                                box.Thickness = 1
                                box.Color = Color3.fromRGB(255, 0, 0)
                                box.Filled = false
                                box.Size = Vector2.new(50, 50)
                                box.Position = Vector2.new(pos.X - 25, pos.Y - 25)
                                box.Visible = true
                                table.insert(espDrawing, box)
                            end
                            if Config.Visual.ESPTracer then
                                local tracer = Drawing.new("Line")
                                tracer.Thickness = 1
                                tracer.Color = Color3.fromRGB(255, 0, 0)
                                tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                                tracer.To = pos
                                tracer.Visible = true
                                table.insert(espDrawing, tracer)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- FLY (FIX - pake LinearVelocity, ringan)
-- ============================================================
local flyLV, flyAO, flyConn
local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyLV then flyLV:Destroy() flyLV = nil end
    if flyAO then flyAO:Destroy() flyAO = nil end
    local hrp = Utils.getHRP()
    if hrp then hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero end
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
    while task.wait(0.5) do
        if Config.Movement.Fly then
            local hrp = Utils.getHRP()
            if hrp and not flyLV then startFly() end
        elseif flyLV then
            stopFly()
        end
    end
end)

-- ============================================================
-- FULLBRIGHT / NO FOG
-- ============================================================
local origBright = Lighting.Brightness
local origAmbient = Lighting.Ambient
local origOutdoor = Lighting.OutdoorAmbient
local origFog = Lighting.FogEnd
task.spawn(function()
    while task.wait(1) do
        if Config.Visual.Fullbright then
            Lighting.Brightness = 3
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        else
            Lighting.Brightness = origBright
            Lighting.Ambient = origAmbient
            Lighting.OutdoorAmbient = origOutdoor
        end
        Lighting.FogEnd = Config.Visual.NoFog and 100000 or origFog
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
        else
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part:GetAttribute("CA_Invis") then
                    part.Transparency = part:GetAttribute("CA_OrigTrans") or 0
                    part:SetAttribute("CA_Invis", nil)
                    part:SetAttribute("CA_OrigTrans", nil)
                end
            end
        end
    end
end)

-- ============================================================
-- HITBOX
-- ============================================================
local origHRPSize = nil
task.spawn(function()
    while task.wait(0.2) do
        local char = Utils.getChar()
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
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
        else
            if origHRPSize then
                pcall(function() hrp.Size = origHRPSize end)
                origHRPSize = nil
            end
            local box = char:FindFirstChild("CA_SelfHB")
            if box then box:Destroy() end
        end
        if Config.Visual.EnemyHitbox then
            for _, model in pairs(workspace:GetChildren()) do
                if Utils.isEnemy(model) and not model:FindFirstChild("CA_EnemyHB") then
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
        else
            for _, model in pairs(workspace:GetChildren()) do
                local box = model:FindFirstChild("CA_EnemyHB")
                if box then box:Destroy() end
            end
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
    while task.wait(0.3) do
        if not Config.Misc.AutoTP then continue end
        local hrp = Utils.getHRP()
        if not hrp then continue end
        local nearest, nearestDist = nil, Config.Misc.AutoTPRange
        for _, model in pairs(workspace:GetChildren()) do
            if Utils.isEnemy(model) then
                local thrp = model:FindFirstChild("HumanoidRootPart")
                if thrp then
                    local dist = (thrp.Position - hrp.Position).Magnitude
                    if dist < nearestDist then
                        nearest = thrp
                        nearestDist = dist
                    end
                end
            end
        end
        if nearest then
            hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 3, 0))
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

function _G.STHAIN.TeleportInstant(part)
    local char = Utils.getChar()
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    pcall(function()
        hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, Config.Teleport.OffsetY, 0))
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
local function onCharacterAdded(char)
    task.wait(1)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    if not (hrp and hum) then return end
    print("[STHAIN] New character detected, re-applying features...")
    origHRPSize = nil
    lastSafePos = nil
    print("[STHAIN] Features re-applied!")
end

LP.CharacterAdded:Connect(onCharacterAdded)

print("[STHAIN] Logic loops started - FULL FIX")
