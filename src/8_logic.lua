--[[
============================================================
  [8] LOGIC LOOPS (PC + Mobile)
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

-- MOVEMENT
Run.RenderStepped:Connect(function()
    local hum = Utils.getHum()
    if hum then
        hum.WalkSpeed = Config.Movement.WalkSpeed
        hum.HipHeight = Config.Movement.HipHeight
        hum.JumpPower = Config.Movement.JumpPower
    end
end)

-- NOCLIP
Run.Stepped:Connect(function()
    if not Config.Movement.Noclip then return end
    local char = Utils.getChar()
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end) end
end)

-- INFINITE JUMP
UIS.JumpRequest:Connect(function()
    if not Config.Movement.InfJump then return end
    local hum = Utils.getHum()
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
end)

-- AUTO ATTACK / RUSH
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

-- KILL AURA
task.spawn(function()
    while task.wait(0.15) do
        if not Config.Combat.KillAura then continue end
        local hrp = Utils.getHRP()
        if not hrp then continue end
        for _, model in pairs(workspace:GetDescendants()) do
            if Utils.isEnemy(model) then
                local thrp = model:FindFirstChild("HumanoidRootPart")
                if thrp then
                    local dist = (thrp.Position - hrp.Position).Magnitude
                    if dist <= Config.Combat.KillAuraRange then
                        hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(thrp.Position.X, hrp.Position.Y, thrp.Position.Z))
                        Utils.sendKey(Enum.KeyCode.V, 0.02)
                        task.wait(0.1)
                        break
                    end
                end
            end
        end
    end
end)

-- TARGET LOCK
local origCamType = Cam.CameraType
task.spawn(function()
    while task.wait(0.05) do
        if Config.Combat.TargetLock then
            local hrp = Utils.getHRP()
            if hrp then
                local nearest, nearestDist = nil, 100
                for _, model in pairs(workspace:GetDescendants()) do
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

-- AUTO HEAL
task.spawn(function()
    while task.wait(0.5) do
        if not Config.Combat.AutoHeal then continue end
        local hum = Utils.getHum()
        if hum and hum.Health > 0 then
            local pct = (hum.Health / hum.MaxHealth) * 100
            if pct <= Config.Combat.HealThreshold then
                Utils.sendKey(Enum.KeyCode.H, 0.05)
            end
        end
    end
end)

-- INF AMMO
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
                    if string.find(n, "ammo") or string.find(n, "bullet") then
                        pcall(function() obj.Value = 999 end)
                    end
                end
            end
        end
    end
end)

-- ESP
local espCache = {}
task.spawn(function()
    while task.wait(0.3) do
        local active = Config.Visual.ESPBox or Config.Visual.ESPTracer or Config.Visual.ESPHealth or Config.Visual.ESPName or Config.Visual.Chams
        if not active then
            for model, objs in pairs(espCache) do
                for _, obj in pairs(objs) do pcall(function() obj:Destroy() end) end
            end
            espCache = {}
        else
            for _, model in pairs(workspace:GetDescendants()) do
                if Utils.isEnemy(model) and not espCache[model] then
                    local hrp = model:FindFirstChild("HumanoidRootPart")
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hrp and hum then
                        local objs = {}
                        if Config.Visual.Chams then
                            local hl = Instance.new("Highlight")
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.Adornee = model
                            hl.Parent = S.GUI.Screen
                            table.insert(objs, hl)
                        end
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
            for model, objs in pairs(espCache) do
                if not model.Parent then
                    for _, obj in pairs(objs) do pcall(function() obj:Destroy() end) end
                    espCache[model] = nil
                else
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum then
                        for _, obj in pairs(objs) do
                            if obj:IsA("BillboardGui") and obj.Name == "" then
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

-- FLY
local flyBV, flyBG, flyConn
local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    local hrp = Utils.getHRP()
    if hrp then hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero end
    local hum = Utils.getHum()
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Freefall) end) end
end

local function startFly()
    stopFly()
    local hrp = Utils.getHRP()
    if not hrp then return end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.P = 5000
    flyBG.D = 500
    flyBG.Parent = hrp
    flyConn = Run.RenderStepped:Connect(function()
        if not Config.Movement.Fly then return end
        local hum = Utils.getHum()
        if not (hum and flyBV and flyBG) then return end
        flyBG.CFrame = Cam.CFrame
        flyBV.Velocity = hum.MoveDirection * Config.Movement.FlySpeed
    end)
end

task.spawn(function()
    while task.wait(0.5) do
        if Config.Movement.Fly then
            local hrp = Utils.getHRP()
            if hrp and not flyBV then startFly() end
        elseif flyBV then
            stopFly()
        end
    end
end)

-- FULLBRIGHT / NO FOG
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

-- INVISIBLE
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

-- HITBOX
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
            for _, model in pairs(workspace:GetDescendants()) do
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
            for _, model in pairs(workspace:GetDescendants()) do
                local box = model:FindFirstChild("CA_EnemyHB")
                if box then box:Destroy() end
            end
        end
    end
end)

-- ANTI-AFK
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

-- AUTO TP
task.spawn(function()
    while task.wait(0.3) do
        if not Config.Misc.AutoTP then continue end
        local hrp = Utils.getHRP()
        if not hrp then continue end
        local nearest, nearestDist = nil, Config.Misc.AutoTPRange
        for _, model in pairs(workspace:GetDescendants()) do
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

-- RESPAWN
LP.CharacterAdded:Connect(function()
    task.wait(1)
    origHRPSize = nil
end)

print("[STHAIN] Logic loops started")
