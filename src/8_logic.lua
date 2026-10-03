--[[
============================================================
  [8] LOGIC LOOPS (FULL FIX)
============================================================
]]

local S = _G.STHAIN
if not S then
    warn("[STHAIN] _G.STHAIN nil! Stop logic.")
    return
end

local Config = S.Config
local Utils = S.Utils
local Run = S.Services.Run
local UIS = S.Services.UIS
local Lighting = S.Services.Lighting
local Cam = S.Cam
local LP = S.LP

print("[STHAIN] Modules OK, starting logic...")

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
    TargetLock = false,
}

-- ============================================================
-- WAIT CHARACTER
-- ============================================================
task.spawn(function()
    repeat task.wait(0.1) until LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    print("[STHAIN] Character loaded!")
end)

-- ============================================================
-- MOVEMENT (REWRITE)
-- ============================================================
Run.RenderStepped:Connect(function()
    local hum = Utils.getHum()
    if not hum then return end
    
    if hum.WalkSpeed ~= Config.Movement.WalkSpeed then
        hum.WalkSpeed = Config.Movement.WalkSpeed
    end
    if hum.HipHeight ~= Config.Movement.HipHeight then
        hum.HipHeight = Config.Movement.HipHeight
    end
    if hum.JumpPower ~= Config.Movement.JumpPower then
        hum.JumpPower = Config.Movement.JumpPower
    end
end)

print("[STHAIN] Movement loop started")

-- ============================================================
-- NOCLIP (REWRITE)
-- ============================================================
local lastSafePos = nil
local noclipOriginal = {}

local function cleanupNoclip()
    for part, origVal in pairs(noclipOriginal) do
        if part and part.Parent then
            pcall(function() part.CanCollide = origVal end)
        end
    end
    noclipOriginal = {}
end

Run.Heartbeat:Connect(function()
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
            if part:IsA("BasePart") then
                if noclipOriginal[part] == nil then
                    noclipOriginal[part] = part.CanCollide
                end
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
        cleanupNoclip()
        State.Noclip = false
    end
end)

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

print("[STHAIN] Noclip loop started")

-- ============================================================
-- INFINITE JUMP
-- ============================================================
task.spawn(function()
    while task.wait(0.1) do
        if Config.Movement.InfJump then
            local hum = Utils.getHum()
            if hum then
                local st = hum:GetState()
                if st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping then
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
-- AUTO ATTACK / RUSH
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
-- KILL AURA
-- ============================================================
local killAuraCD = 0
task.spawn(function()
    while task.wait(0.05) do
        if Config.Combat.KillAura then
            local char = Utils.getChar()
            local hrp = Utils.getHRP()
            if not (char and hrp) then continue end

            local nearest, nearestDist = nil, Config.Combat.KillAuraRange
            for _, model in pairs(workspace:GetDescendants()) do
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
                    nearestDist = dist
                end
            end

            if nearest then
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
end)

-- ============================================================
-- TARGET LOCK
-- ============================================================
local origCamType = Cam.CameraType
task.spawn(function()
    while task.wait(0.05) do
        if Config.Combat.TargetLock then
            local char = Utils.getChar()
            local hrp = Utils.getHRP()
            if not (char and hrp) then continue end

            local nearest, nearestDist = nil, 150
            for _, model in pairs(workspace:GetDescendants()) do
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
                Cam.CameraType = Enum.CameraType.Custom
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
                if pct <= Config.Combat.HealThreshold and tick() - healCD >= 2 then
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
-- ESP (REWRITE - PASTI MUNCUL)
-- ============================================================
local espCache = {}
local espFolder = nil

-- Bikin folder ESP
task.spawn(function()
    task.wait(1)
    if S.GUI and S.GUI.Screen then
        espFolder = Instance.new("Folder")
        espFolder.Name = "ESP_Folder"
        espFolder.Parent = S.GUI.Screen
    end
end)

local function cleanupESP()
    for _, objs in pairs(espCache) do
        for _, obj in pairs(objs) do
            pcall(function() obj:Destroy() end)
        end
    end
    espCache = {}
end

local function createESP(model)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return nil end

    local objs = {}
    local parent = espFolder or S.GUI.Screen

    if Config.Visual.Chams then
        local hl = Instance.new("Highlight")
        hl.Name = "ESP_HL"
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.Adornee = model
        hl.Parent = parent
        table.insert(objs, hl)
    end

    if Config.Visual.ESPName then
        local bb = Instance.new("BillboardGui")
        bb.Name = "ESP_Name"
        bb.Size = UDim2.new(0, 150, 0, 25)
        bb.StudsOffset = Vector3.new(0, 3.5, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = hrp
        bb.Parent = parent

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, 0, 1, 0)
        nameLbl.Text = model.Name
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.TextStrokeTransparency = 0
        nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLbl.TextSize = 14
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.BackgroundTransparency = 1
        nameLbl.Parent = bb
        table.insert(objs, bb)
    end

    if Config.Visual.ESPHealth then
        local hb = Instance.new("BillboardGui")
        hb.Name = "ESP_Health"
        hb.Size = UDim2.new(0, 80, 0, 8)
        hb.StudsOffset = Vector3.new(0, 2.5, 0)
        hb.AlwaysOnTop = true
        hb.Adornee = hrp
        hb.Parent = parent

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        bg.BorderSizePixel = 0
        bg.Parent = hb
        Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.new(1, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(80, 220, 130)
        fill.BorderSizePixel = 0
        fill.Parent = bg
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        table.insert(objs, hb)
    end

    return objs
end

task.spawn(function()
    while task.wait(0.5) do
        local active = Config.Visual.ESPBox or Config.Visual.ESPTracer or Config.Visual.ESPHealth or Config.Visual.ESPName or Config.Visual.Chams

        if not active then
            if State.ESP then
                cleanupESP()
                State.ESP = false
            end
        else
            State.ESP = true
            local char = Utils.getChar()
            if not char then continue end

            -- Cleanup yang ilang
            for model, objs in pairs(espCache) do
                if not model.Parent then
                    for _, obj in pairs(objs) do
                        pcall(function() obj:Destroy() end)
                    end
                    espCache[model] = nil
                end
            end

            -- Scan enemy
            for _, model in pairs(workspace:GetDescendants()) do
                if model == char then continue end
                if not model:IsA("Model") then continue end
                
                local hum = model:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end

                if espCache[model] then continue end

                -- Skip folder sampah
                local parentName = model.Parent and model.Parent.Name or ""
                if parentName == "Mounts" then continue end
                if parentName == "LocalGlobalLeaderboardDisplays" then continue end

                local objs = createESP(model)
                if objs then
                    espCache[model] = objs
                end
            end

            -- Update Health
            for model, objs in pairs(espCache) do
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum then
                    for _, obj in pairs(objs) do
                        if obj:IsA("BillboardGui") and obj.Name == "ESP_Health" then
                            local fill = obj:FindFirstChild("Fill", true)
                            if fill then
                                local pct = hum.Health / hum.MaxHealth
                                fill.Size = UDim2.new(pct, 0, 1, 0)
                                if pct > 0.5 then
                                    fill.BackgroundColor3 = Color3.fromRGB(80, 220, 130)
                                elseif pct > 0.25 then
                                    fill.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
                                else
                                    fill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

print("[STHAIN] ESP loop started")

-- ============================================================
-- FLY (REWRITE)
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
        
        local camCF = Cam.CFrame
        local moveDir = hum.MoveDirection
        local finalDir = Vector3.zero
        
        if moveDir.Magnitude > 0.1 then
            finalDir = camCF.LookVector * moveDir.Z + camCF.RightVector * moveDir.X
        end
        
        flyLV.VectorVelocity = finalDir * Config.Movement.FlySpeed
    end)
end

task.spawn(function()
    while task.wait(0.3) do
        if Config.Movement.Fly and not State.Fly then
            startFly()
            State.Fly = true
            print("[STHAIN] Fly ON")
        elseif not Config.Movement.Fly and State.Fly then
            stopFly()
            State.Fly = false
            print("[STHAIN] Fly OFF")
        end
    end
end)

print("[STHAIN] Fly loop started")

-- ============================================================
-- FULLBRIGHT / NO FOG
-- ============================================================
local savedLighting = {
    Brightness = nil,
    Ambient = nil,
    OutdoorAmbient = nil,
    FogEnd = nil,
    FogStart = nil,
}

task.spawn(function()
    while task.wait(0.5) do
        if Config.Visual.Fullbright then
            if savedLighting.Brightness == nil then
                savedLighting.Brightness = Lighting.Brightness
                savedLighting.Ambient = Lighting.Ambient
                savedLighting.OutdoorAmbient = Lighting.OutdoorAmbient
            end
            Lighting.Brightness = 3
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
            State.Fullbright = true
        elseif State.Fullbright then
            if savedLighting.Brightness ~= nil then
                Lighting.Brightness = savedLighting.Brightness
                Lighting.Ambient = savedLighting.Ambient
                Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
                savedLighting.Brightness = nil
                savedLighting.Ambient = nil
                savedLighting.OutdoorAmbient = nil
            end
            State.Fullbright = false
        end

        if Config.Visual.NoFog then
            if savedLighting.FogEnd == nil then
                savedLighting.FogEnd = Lighting.FogEnd
                savedLighting.FogStart = Lighting.FogStart
            end
            Lighting.FogEnd = 100000
            Lighting.FogStart = 100000
            State.NoFog = true
        elseif State.NoFog then
            if savedLighting.FogEnd ~= nil then
                Lighting.FogEnd = savedLighting.FogEnd
                Lighting.FogStart = savedLighting.FogStart
                savedLighting.FogEnd = nil
                savedLighting.FogStart = nil
            end
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
                box.CanQuery = false
                box.CanTouch = false
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

        if Config.Visual.EnemyHitbox then
            for _, model in pairs(workspace:GetDescendants()) do
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
                        box.CanQuery = false
                        box.CanTouch = false
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
            for _, model in pairs(workspace:GetDescendants()) do
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
            for _, model in pairs(workspace:GetDescendants()) do
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

local function getMapFolder()
    local activeMap = workspace:FindFirstChild("ActiveMap")
    if not activeMap then return nil end
    
    for _, child in pairs(activeMap:GetChildren()) do
        if child:IsA("Folder") or child:IsA("Model") then
            if child:FindFirstChild("Interactable") then
                return child
            end
        end
    end
    return nil
end

function _G.STHAIN.TeleportScan()
    local results = { supplies = {}, captures = {} }
    
    local mapFolder = getMapFolder()
    if not mapFolder then return results end
    
    local interactable = mapFolder:FindFirstChild("Interactable")
    if not interactable then return results end
    
    local suppliesFolder = interactable:FindFirstChild("Supplies")
    if suppliesFolder then
        for _, obj in pairs(suppliesFolder:GetChildren()) do
            if obj:IsA("Model") then
                local n = string.lower(obj.Name)
                local teamType = "unknown"
                if n:find("attacker") then teamType = "attacker"
                elseif n:find("defender") then teamType = "defender" end
                
                table.insert(results.supplies, {
                    name = obj.Name,
                    instance = obj,
                    capturePart = obj:FindFirstChild("CapturePoint"),
                    team = teamType,
                    attributes = obj:GetAttributes(),
                })
            end
        end
    end
    
    local pointsFolder = interactable:FindFirstChild("Points")
    if pointsFolder then
        for _, obj in pairs(pointsFolder:GetChildren()) do
            if obj:IsA("Model") then
                local capturePart = obj:FindFirstChild("CapturePoint")
                if capturePart then
                    table.insert(results.captures, {
                        name = obj.Name,
                        instance = capturePart,
                        model = obj,
                    })
                end
            end
        end
    end
    
    return results
end

function _G.STHAIN.GetMyTeam()
    local Plr = game.Players.LocalPlayer
    
    local selectedTeam = Plr:GetAttribute("SelectedTeam")
    if selectedTeam then
        local n = string.lower(tostring(selectedTeam))
        if n:find("attacker") then return "attacker" end
        if n:find("defender") then return "defender" end
    end
    
    if Plr.Team then
        local n = string.lower(Plr.Team.Name)
        if n:find("attacker") then return "attacker" end
        if n:find("defender") then return "defender" end
    end
    
    for k, v in pairs(Plr:GetAttributes()) do
        local val = string.lower(tostring(v))
        if val == "attackers" or val == "attacker" then return "attacker" end
        if val == "defenders" or val == "defender" then return "defender" end
    end
    
    return "unknown"
end

function _G.STHAIN.TeleportTo(part)
    local char = Utils.getChar()
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    if not part then return false end
    
    local targetPos
    if typeof(part) == "Vector3" then
        targetPos = part
    else
        if not part.Parent then return false end
        targetPos = part.Position
    end
    
    -- Raycast buat cari permukaan tanah (anti tembus)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {char}
    
    local ray = workspace:Raycast(targetPos + Vector3.new(0, 50, 0), Vector3.new(0, -100, 0), rayParams)
    local finalPos
    
    if ray then
        finalPos = ray.Position + Vector3.new(0, 5, 0)
    else
        finalPos = targetPos + Vector3.new(0, 10, 0)
    end
    
    pcall(function() hrp.CFrame = CFrame.new(finalPos) end)
    return true
end

function _G.STHAIN.TeleportToEnemySupply()
    local myTeam = _G.STHAIN.GetMyTeam()
    if myTeam == "unknown" then
        warn("[TP] Team ga kedeteksi.")
        return false
    end
    
    local results = _G.STHAIN.TeleportScan()
    if #results.supplies == 0 then
        warn("[TP] Ga ada supply di map.")
        return false
    end
    
    local enemyTeam = (myTeam == "attacker") and "defender" or "attacker"
    
    for _, supply in ipairs(results.supplies) do
        if supply.team == enemyTeam then
            -- Cek apakah supply udah di-capture
            local captured = false
            for k, v in pairs(supply.attributes or {}) do
                local key = string.lower(k)
                local val = string.lower(tostring(v))
                if key:find("owner") or key:find("team") then
                    if val:find(myTeam) then
                        captured = true
                        break
                    end
                end
            end
            
            if not captured then
                local targetPart = supply.capturePart or supply.instance
                _G.STHAIN.TeleportTo(targetPart)
                print("[TP] TP to:", supply.name)
                return true
            else
                print("[TP] Skip (udah di-capture):", supply.name)
            end
        end
    end
    
    warn("[TP] Supply musuh ga ketemu.")
    return false
end

function _G.STHAIN.TeleportToOwnSupply()
    local myTeam = _G.STHAIN.GetMyTeam()
    if myTeam == "unknown" then return false end
    
    local results = _G.STHAIN.TeleportScan()
    for _, supply in ipairs(results.supplies) do
        if supply.team == myTeam then
            local targetPart = supply.capturePart or supply.instance
            _G.STHAIN.TeleportTo(targetPart)
            print("[TP] TP to own supply:", supply.name)
            return true
        end
    end
    return false
end

function _G.STHAIN.TeleportToNearestCapture()
    local char = Utils.getChar()
    local hrp = Utils.getHRP()
    if not (char and hrp) then return false end
    
    local results = _G.STHAIN.TeleportScan()
    if #results.captures == 0 then
        warn("[TP] Ga ada capture point.")
        return false
    end
    
    local nearest, nearestDist = nil, math.huge
    for _, cap in ipairs(results.captures) do
        if cap.instance and cap.instance.Parent then
            local dist = (cap.instance.Position - hrp.Position).Magnitude
            if dist < nearestDist then
                nearest = cap
                nearestDist = dist
            end
        end
    end
    
    if nearest then
        _G.STHAIN.TeleportTo(nearest.instance)
        print("[TP] TP to nearest Capture:", nearest.name)
        return true
    end
    return false
end

function _G.STHAIN.TeleportToBase()
    local results = _G.STHAIN.TeleportScan()
    
    for _, cap in ipairs(results.captures) do
        if string.lower(cap.name) == "base" then
            _G.STHAIN.TeleportTo(cap.instance)
            print("[TP] TP to Base")
            return true
        end
    end
    
    for _, cap in ipairs(results.captures) do
        if string.lower(cap.name) == "pointa" then
            _G.STHAIN.TeleportTo(cap.instance)
            print("[TP] Base ga ada, TP ke Point A")
            return true
        end
    end
    
    for _, cap in ipairs(results.captures) do
        if string.lower(cap.name) == "pointb" then
            _G.STHAIN.TeleportTo(cap.instance)
            print("[TP] Base ga ada, TP ke Point B")
            return true
        end
    end
    
    warn("[TP] Base / Point ga ketemu.")
    return false
end

function _G.STHAIN.TeleportToPointA()
    local results = _G.STHAIN.TeleportScan()
    for _, cap in ipairs(results.captures) do
        if string.lower(cap.name) == "pointa" then
            _G.STHAIN.TeleportTo(cap.instance)
            print("[TP] TP to Point A")
            return true
        end
    end
    warn("[TP] Point A ga ketemu.")
    return false
end

function _G.STHAIN.TeleportToPointB()
    local results = _G.STHAIN.TeleportScan()
    for _, cap in ipairs(results.captures) do
        if string.lower(cap.name) == "pointb" then
            _G.STHAIN.TeleportTo(cap.instance)
            print("[TP] TP to Point B")
            return true
        end
    end
    warn("[TP] Point B ga ketemu.")
    return false
end

function _G.STHAIN.TeleportToNearestEnemy()
    local char = Utils.getChar()
    local hrp = Utils.getHRP()
    if not (char and hrp) then return false end
    
    local nearest, nearestDist = nil, math.huge
    for _, model in pairs(workspace:GetDescendants()) do
        if model ~= char and model:IsA("Model") then
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local thrp = model:FindFirstChild("HumanoidRootPart")
                if thrp then
                    local dist = (thrp.Position - hrp.Position).Magnitude
                    if dist > 5 and dist < nearestDist then
                        nearest = thrp
                        nearestDist = dist
                    end
                end
            end
        end
    end
    
    if nearest then
        _G.STHAIN.TeleportTo(nearest)
        return true
    end
    return false
end

function _G.STHAIN.TeleportToTeammate()
    local char = Utils.getChar()
    local hrp = Utils.getHRP()
    if not (char and hrp) then return false end
    
    local Plr = game.Players.LocalPlayer
    local myTeam = _G.STHAIN.GetMyTeam()
    if myTeam == "unknown" then return false end
    
    local nearest, nearestDist = nil, math.huge
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Plr and player.Character then
            local playerTeam = ""
            if player:GetAttribute("SelectedTeam") then
                playerTeam = string.lower(tostring(player:GetAttribute("SelectedTeam")))
            elseif player.Team then
                playerTeam = string.lower(player.Team.Name)
            end
            
            if playerTeam:find(myTeam) then
                local thrp = player.Character:FindFirstChild("HumanoidRootPart")
                if thrp then
                    local dist = (thrp.Position - hrp.Position).Magnitude
                    if dist < nearestDist then
                        nearest = thrp
                        nearestDist = dist
                    end
                end
            end
        end
    end
    
    if nearest then
        _G.STHAIN.TeleportTo(nearest)
        return true
    end
    return false
end

-- ============================================================
-- CONFIG SAVE / LOAD
-- ============================================================

function _G.STHAIN.SaveConfig()
    if not writefile then
        warn("[Config] writefile ga support")
        return false
    end
    local ok, err = pcall(function()
        local data = game:GetService("HttpService"):JSONEncode(_G.STHAIN.Config)
        writefile("sthain_config.json", data)
    end)
    if ok then
        return true
    else
        return false
    end
end

function _G.STHAIN.LoadConfig()
    if not readfile then return false end
    local ok, data = pcall(function()
        return readfile("sthain_config.json")
    end)
    if ok and data then
        local ok2, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(data)
        end)
        if ok2 then
            for k, v in pairs(decoded) do
                _G.STHAIN.Config[k] = v
            end
            return true
        end
    end
    return false
end

function _G.STHAIN.DeleteConfig()
    if not delfile then return false end
    pcall(function()
        delfile("sthain_config.json")
    end)
    return true
end

task.spawn(function()
    while task.wait(60) do
        if _G.STHAIN.Config and _G.STHAIN.Config.Config and _G.STHAIN.Config.Config.AutoSave then
            _G.STHAIN.SaveConfig()
        end
    end
end)

task.spawn(function()
    task.wait(3)
    _G.STHAIN.LoadConfig()
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
    cleanupNoclip()
    print("[STHAIN] Character respawned, features reset")
end)

print("[STHAIN] Logic loops loaded - FULL FIX")
