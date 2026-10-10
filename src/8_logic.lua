--[[
============================================================
  [8] LOGIC LOOPS (FINAL FIX v5)
  - Auto Redeem Code (Radio Times)
  - Auto Claim Quest (Harian + Mingguan)
  - Optimasi ESP loop (0.25s)
  - Hapus Tracer
  - AutoSave bind-to-close + interval 30s
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
local Lighting = S.Services.Lighting
local Cam = S.Cam
local LP = S.LP

print("[STHAIN] Logic starting...")

local State = {
    Fly = false, Noclip = false, Invisible = false,
    Fullbright = false, NoFog = false,
    SelfHitbox = false, EnemyHitbox = false,
    ESP = false, TargetLock = false,
}

task.spawn(function()
    repeat task.wait(0.1) until LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    print("[STHAIN] Character loaded!")
end)

-- ============================================================
-- MOVEMENT
-- ============================================================
Run.RenderStepped:Connect(function()
    local hum = Utils.getHum()
    if not hum then return end
    local mv = Config.Movement
    pcall(function()
        if mv.WalkSpeed and mv.WalkSpeed > 0 then
            hum.WalkSpeed = mv.WalkSpeed
        end
        if mv.HipHeight and mv.HipHeight >= 0 then
            hum.HipHeight = mv.HipHeight
        end
        if mv.JumpPower and mv.JumpPower > 0 then
            hum.UseJumpPower = true
            hum.JumpPower = mv.JumpPower
        end
    end)
end)

-- ============================================================
-- NOCLIP
-- ============================================================
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
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if noclipOriginal[part] == nil then
                    noclipOriginal[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
        State.Noclip = true
    elseif State.Noclip then
        cleanupNoclip()
        if hrp then hrp.CanCollide = true end
        State.Noclip = false
    end
end)

-- ============================================================
-- FLY
-- ============================================================
local flyConn, flyBV, flyBG = nil, nil, nil

local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    local hrp = Utils.getHRP()
    if hrp then
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
        hrp.CanCollide = true
    end
    local hum = Utils.getHum()
    if hum then
        pcall(function() hum.PlatformStand = false end)
    end
end

local function startFly()
    stopFly()
    local hrp = Utils.getHRP()
    local hum = Utils.getHum()
    if not (hrp and hum) then return end
    hum.PlatformStand = true

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBG.P = 10000
    flyBG.D = 100
    flyBG.Parent = hrp

    flyConn = Run.RenderStepped:Connect(function()
        if not Config.Movement.Fly then return end
        local hrp2 = Utils.getHRP()
        local hum2 = Utils.getHum()
        if not (hrp2 and hum2 and flyBV and flyBG) then return end
        flyBG.CFrame = Cam.CFrame
        local camCF = Cam.CFrame
        local moveDir = hum2.MoveDirection
        local finalDir = Vector3.zero
        if moveDir.Magnitude > 0.1 then
            finalDir = camCF.LookVector * moveDir.Z + camCF.RightVector * moveDir.X
        end
        flyBV.Velocity = finalDir * Config.Movement.FlySpeed
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
-- INFINITE JUMP
-- ============================================================
task.spawn(function()
    while task.wait(0.1) do
        if Config.Movement.InfJump then
            local hum = Utils.getHum()
            if hum then
                local st = hum:GetState()
                if st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping then
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
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
    while task.wait(0.1) do
        if Config.Combat.KillAura then
            local char = Utils.getChar()
            local hrp = Utils.getHRP()
            if not (char and hrp) then continue end
            local nearest, nearestDist = nil, Config.Combat.KillAuraRange
            for _, model in pairs(workspace:GetChildren()) do
                if model == char or not model:IsA("Model") then continue end
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
task.spawn(function()
    while task.wait(0.1) do
        if Config.Combat.TargetLock then
            local char = Utils.getChar()
            local hrp = Utils.getHRP()
            if not (char and hrp) then continue end
            local nearest, nearestDist = nil, 150
            for _, model in pairs(workspace:GetChildren()) do
                if model == char or not model:IsA("Model") then continue end
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
-- ESP (Box + Name + Health + Chams, NO Tracer)
-- 1 loop, update 0.25s
-- ============================================================
local espCache = {}
local espGuiParent = (gethui and gethui()) or game:GetService("CoreGui")

local function cleanupESP()
    for _, objs in pairs(espCache) do
        for _, obj in pairs(objs) do
            if obj then pcall(function() obj:Destroy() end) end
        end
    end
    espCache = {}
end

task.spawn(function()
    while task.wait(0.25) do
        local cfg = Config.Visual
        local active = cfg.ESPBox or cfg.ESPHealth or cfg.ESPName or cfg.Chams

        if not active then
            if State.ESP then
                cleanupESP()
                State.ESP = false
            end
        else
            State.ESP = true
            local myChar = Utils.getChar()

            for _, model in pairs(workspace:GetChildren()) do
                if model == myChar or not model:IsA("Model") then continue end
                local hum = model:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end

                if not espCache[model] then
                    espCache[model] = {}

                    if cfg.Chams then
                        local hl = Instance.new("Highlight")
                        hl.Name = "CA_ESP_HL"
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.Adornee = model
                        hl.Parent = espGuiParent
                        espCache[model].hl = hl
                    end

                    if cfg.ESPBox then
                        local boxBB = Instance.new("BillboardGui")
                        boxBB.Name = "CA_ESP_Box"
                        boxBB.Size = UDim2.new(0, 50, 0, 70)
                        boxBB.StudsOffset = Vector3.new(0, 2, 0)
                        boxBB.AlwaysOnTop = true
                        boxBB.Adornee = hrp
                        boxBB.Parent = espGuiParent
                        local boxFrame = Instance.new("Frame")
                        boxFrame.Size = UDim2.new(1, 0, 1, 0)
                        boxFrame.BackgroundTransparency = 1
                        boxFrame.BorderSizePixel = 0
                        boxFrame.Parent = boxBB
                        local stroke = Instance.new("UIStroke")
                        stroke.Color = Color3.fromRGB(255, 60, 60)
                        stroke.Thickness = 2
                        stroke.Parent = boxFrame
                        espCache[model].boxBB = boxBB
                    end

                    if cfg.ESPName then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "CA_ESP_Name"
                        bb.Size = UDim2.new(0, 120, 0, 24)
                        bb.StudsOffset = Vector3.new(0, 4.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Adornee = hrp
                        bb.Parent = espGuiParent
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.Text = model.Name
                        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                        lbl.TextStrokeTransparency = 0
                        lbl.TextSize = 14
                        lbl.Font = Enum.Font.GothamBold
                        lbl.BackgroundTransparency = 1
                        lbl.Parent = bb
                        espCache[model].nameBB = bb
                    end

                    if cfg.ESPHealth then
                        local hb = Instance.new("BillboardGui")
                        hb.Name = "CA_ESP_HP"
                        hb.Size = UDim2.new(0, 60, 0, 6)
                        hb.StudsOffset = Vector3.new(0, 3.5, 0)
                        hb.AlwaysOnTop = true
                        hb.Adornee = hrp
                        hb.Parent = espGuiParent
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
                        espCache[model].healthBB = hb
                    end
                end
            end

            for model, objs in pairs(espCache) do
                if not model.Parent then
                    for _, obj in pairs(objs) do
                        if obj then pcall(function() obj:Destroy() end) end
                    end
                    espCache[model] = nil
                else
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum and objs.healthBB then
                        local fill = objs.healthBB:FindFirstChild("Fill", true)
                        if fill then
                            fill.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- FULLBRIGHT / NO FOG
-- ============================================================
local savedLighting = { Brightness=nil, Ambient=nil, OutdoorAmbient=nil, FogEnd=nil, FogStart=nil }

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
            if savedLighting.Brightness then
                Lighting.Brightness = savedLighting.Brightness
                Lighting.Ambient = savedLighting.Ambient
                Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
                savedLighting.Brightness = nil
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
            if savedLighting.FogEnd then
                Lighting.FogEnd = savedLighting.FogEnd
                Lighting.FogStart = savedLighting.FogStart
                savedLighting.FogEnd = nil
            end
            State.NoFog = false
        end
    end
end)

-- ============================================================
-- INVISIBLE
-- ============================================================
task.spawn(function()
    while task.wait(1) do
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
-- ANTI-AFK
-- ============================================================
task.spawn(function()
    while task.wait(120) do
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
    while task.wait(1) do
        if Config.Misc.AutoTP then
            local char = Utils.getChar()
            local hrp = Utils.getHRP()
            if not (char and hrp) then continue end
            local nearest, nearestDist = nil, Config.Misc.AutoTPRange
            for _, model in pairs(workspace:GetChildren()) do
                if model == char or not model:IsA("Model") then continue end
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
-- AUTO REDEEM CODE (Radio Times auto-update)
-- ============================================================
local CODES_URL = "https://www.radiotimes.com/technology/gaming/command-an-army-codes/"

local function ambilCode()
    local ok, html = pcall(game.HttpGet, game, CODES_URL)
    if not ok or not html or #html < 500 then
        warn("[Code] Gagal ambil code")
        return {}
    end

    local codes = {}
    local seen = {}

    local mulai = html:find("Active codes")
    local selesai = html:find("expired codes")
    if not mulai then return {} end

    local bagian = html:sub(mulai, selesai or #html)

    for li in bagian:gmatch("<li>(.-)</li>") do
        local code = li:match("^%s*%-%s*([A-Z][A-Z0-9]+)")
            or li:match("^%s*([A-Z][A-Z0-9]+)%s*%(")
            or li:match("^%s*([A-Z][A-Z0-9]+)%s*%-")
            or li:match("^%s*([A-Z][A-Z0-9]+)")
        if code and #code >= 3 and #code <= 20 and not seen[code] then
            seen[code] = true
            table.insert(codes, code)
        end
    end

    print(("[Code] Dapet %d code"):format(#codes))
    return codes
end

local function cariCodeUI()
    local PG = LP:WaitForChild("PlayerGui")
    local interactable = PG:FindFirstChild("Interactable")
    if not interactable then return nil, nil end
    local codeUI = interactable:FindFirstChild("CodeUI")
    if not codeUI then return nil, nil end
    local textBox = codeUI:FindFirstChild("TextBox")
    if not textBox then return nil, nil end

    local tombolKlaim = nil
    for _, c in pairs(codeUI:GetDescendants()) do
        if (c:IsA("TextButton") or c:IsA("ImageButton")) and c.Visible then
            local txt = string.lower(c.Text or "")
            local nm = string.lower(c.Name)
            if txt:find("claim") or txt:find("redeem") or txt:find("klaim")
            or nm:find("claim") or nm:find("redeem") or nm:find("klaim") then
                tombolKlaim = c
                break
            end
        end
    end

    return textBox, tombolKlaim
end

function _G.STHAIN.RedeemAllCodes()
    local codes = ambilCode()
    if #codes == 0 then warn("[Code] Ga ada code") return 0 end

    local tb, btn = cariCodeUI()
    if not tb then warn("[Code] TextBox ga ketemu") return 0 end

    print(("[Code] Redeem %d code..."):format(#codes))

    local sukses = 0
    for i, code in ipairs(codes) do
        pcall(function()
            tb:CaptureFocus()
            task.wait(0.1)
            tb.Text = code
            task.wait(0.1)
            tb:ReleaseFocus()
        end)
        task.wait(0.2)

        if btn then
            pcall(function() btn.MouseButton1Click:Fire() end)
        else
            pcall(function() tb.FocusLost:Fire(true) end)
        end
        sukses = sukses + 1
        print(("[Code] [%d/%d] ✓ %s"):format(i, #codes, code))
        task.wait(1.2)
    end

    print(("[Code] Selesai — Sukses: %d"):format(sukses))
    return sukses
end

-- ============================================================
-- AUTO CLAIM QUEST (Harian + Mingguan)
-- ============================================================
function _G.STHAIN.ClaimQuests()
    local PG = LP:WaitForChild("PlayerGui")
    local interactable = PG:FindFirstChild("Interactable")
    if not interactable then
        warn("[Misi] Interactable ga ketemu")
        return 0
    end

    local claimed = 0

    local function scanTombolKlaim(root, depth)
        if depth > 8 then return end
        for _, c in pairs(root:GetChildren()) do
            if c:IsA("TextButton") or c:IsA("ImageButton") then
                local txt = (c.Text or ""):upper()
                local nm = c.Name:lower()
                if txt:find("KLAIM") or txt:find("CLAIM")
                or nm:find("claim") or nm:find("klaim") then
                    if c.Visible and c.Active then
                        pcall(function()
                            if c:IsA("TextButton") then
                                c.MouseButton1Click:Fire()
                            end
                        end)
                        claimed = claimed + 1
                        print(("[Misi] Klaim: %s | %s"):format(c.Name, c.Text))
                        task.wait(0.3)
                    end
                end
            end
            if c:IsA("Frame") or c:IsA("ScrollingFrame") or c:IsA("CanvasGroup") then
                scanTombolKlaim(c, depth + 1)
            end
        end
    end

    scanTombolKlaim(interactable, 1)

    print(("[Misi] Selesai — Total klaim: %d"):format(claimed))
    return claimed
end

task.spawn(function()
    while task.wait(60) do
        if Config.Misc.AutoClaimQuest then
            pcall(function() _G.STHAIN.ClaimQuests() end)
        end
    end
end)

task.spawn(function()
    while task.wait(60) do
        if Config.Misc.AutoRedeemCode then
            pcall(function() _G.STHAIN.RedeemAllCodes() end)
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
    return "unknown"
end

function _G.STHAIN.TeleportTo(part)
    local char = Utils.getChar()
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not (hrp and part) then return false end
    local targetPos
    if typeof(part) == "Vector3" then
        targetPos = part
    else
        if not part.Parent then return false end
        targetPos = part.Position
    end
    local offY = (Config.Teleport and Config.Teleport.OffsetY) or 5
    pcall(function() hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, offY, 0)) end)
    return true
end

function _G.STHAIN.TeleportToEnemySupply()
    local myTeam = _G.STHAIN.GetMyTeam()
    if myTeam == "unknown" then warn("[TP] Team unknown") return false end
    local results = _G.STHAIN.TeleportScan()
    if #results.supplies == 0 then warn("[TP] No supplies") return false end
    local enemyTeam = (myTeam == "attacker") and "defender" or "attacker"

    local enemySupplies = {}
    for _, sup in ipairs(results.supplies) do
        if sup.team == enemyTeam then
            table.insert(enemySupplies, sup)
        end
    end
    if #enemySupplies == 0 then warn("[TP] No enemy supply") return false end

    if not _G.STHAIN._tpSupplyIndex then _G.STHAIN._tpSupplyIndex = 0 end
    _G.STHAIN._tpSupplyIndex = _G.STHAIN._tpSupplyIndex + 1
    if _G.STHAIN._tpSupplyIndex > #enemySupplies then _G.STHAIN._tpSupplyIndex = 1 end

    local target = enemySupplies[_G.STHAIN._tpSupplyIndex]
    _G.STHAIN.TeleportTo(target.capturePart or target.instance)
    print(("[TP] TP enemy supply #%d/%d: %s"):format(_G.STHAIN._tpSupplyIndex, #enemySupplies, target.name))
    return true
end

function _G.STHAIN.TeleportToOwnSupply()
    local myTeam = _G.STHAIN.GetMyTeam()
    if myTeam == "unknown" then return false end
    local results = _G.STHAIN.TeleportScan()
    for _, sup in ipairs(results.supplies) do
        if sup.team == myTeam then
            _G.STHAIN.TeleportTo(sup.capturePart or sup.instance)
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
    if #results.captures == 0 then warn("[TP] No captures") return false end
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
        print("[TP] TP capture:", nearest.name)
        return true
    end
    return false
end

local function tpToNamed(targetName)
    local results = _G.STHAIN.TeleportScan()
    for _, cap in ipairs(results.captures) do
        if string.lower(cap.name) == string.lower(targetName) then
            _G.STHAIN.TeleportTo(cap.instance)
            return true
        end
    end
    return false
end

function _G.STHAIN.TeleportToBase()
    if tpToNamed("base") then return true end
    if tpToNamed("pointa") then return true end
    if tpToNamed("pointb") then return true end
    warn("[TP] Base not found")
    return false
end

function _G.STHAIN.TeleportToPointA() return tpToNamed("pointa") end
function _G.STHAIN.TeleportToPointB() return tpToNamed("pointb") end

function _G.STHAIN.TeleportToNearestEnemy()
    local char = Utils.getChar()
    local hrp = Utils.getHRP()
    if not (char and hrp) then return false end
    local nearest, nearestDist = nil, math.huge
    for _, model in pairs(workspace:GetChildren()) do
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
    if nearest then _G.STHAIN.TeleportTo(nearest) return true end
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
    if nearest then _G.STHAIN.TeleportTo(nearest) return true end
    return false
end

-- ============================================================
-- CONFIG SAVE / LOAD (FINAL)
-- ============================================================
local CONFIG_FILE = "sthain_config.json"
local configLoaded = false

function _G.STHAIN.SaveConfig()
    if not writefile then return false end
    local ok = pcall(function()
        writefile(CONFIG_FILE, game:GetService("HttpService"):JSONEncode(_G.STHAIN.Config))
    end)
    if ok then print("[Config] Saved") end
    return ok
end

function _G.STHAIN.LoadConfig()
    if not readfile then return false end
    local ok, data = pcall(readfile, CONFIG_FILE)
    if ok and data and #data > 0 then
        local ok2, dec = pcall(function()
            return game:GetService("HttpService"):JSONDecode(data)
        end)
        if ok2 and type(dec) == "table" then
            for k, v in pairs(dec) do
                _G.STHAIN.Config[k] = v
            end
            configLoaded = true
            print("[Config] Loaded")
            return true
        end
    end
    return false
end

function _G.STHAIN.DeleteConfig()
    if not delfile then return false end
    pcall(function() delfile(CONFIG_FILE) end)
    configLoaded = false
    print("[Config] Deleted")
    return true
end

task.spawn(function()
    while task.wait(30) do
        if _G.STHAIN.Config and _G.STHAIN.Config.Config and _G.STHAIN.Config.Config.AutoSave then
            _G.STHAIN.SaveConfig()
        end
    end
end)

task.spawn(function()
    pcall(function()
        game:BindToClose(function()
            if _G.STHAIN.Config and _G.STHAIN.Config.Config and _G.STHAIN.Config.Config.AutoSave then
                _G.STHAIN.SaveConfig()
            end
        end)
    end)
end)

task.spawn(function()
    task.wait(2)
    if not configLoaded then
        _G.STHAIN.LoadConfig()
    end
end)

-- ============================================================
-- RESPAWN HANDLER
-- ============================================================
LP.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    State.Invisible = false
    State.Noclip = false
    State.Fly = false
    if flyConn then stopFly() end
    cleanupESP()
    cleanupNoclip()
    print("[STHAIN] Respawned, features reset")
end)

print("[STHAIN] Logic loaded - FINAL FIX v5")
