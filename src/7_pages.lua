--[[
============================================================
  [7] PAGES (FINAL FIX v5)
  - Load Config Now dihapus
  - Esp Tracer toggle dihapus
  - Section Auto Claim di tab Settings
  - AutoSave callback fix
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local I = S.Theme.Icons
local F = S.Theme.Font

local pages = {}
local tabs = {}

local function save()
    if _G.STHAIN.SaveConfig then
        task.spawn(_G.STHAIN.SaveConfig)
    end
end

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. name
    page.Size = UDim2.new(1, -18, 1, -38)
    page.Position = UDim2.new(0, 9, 0, 34)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = S.GUI.Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = page

    pages[name] = page
    return page
end

local function switchPage(name)
    for n, p in pairs(pages) do
        p.Visible = (n == name)
    end
    S.GUI.ContentTitle.Text = name
    S.GUI.TitleLine.Size = UDim2.new(0, 0, 0, 2)
    S.Services.TS:Create(S.GUI.TitleLine, TweenInfo.new(0.25), {
        Size = UDim2.new(0, 25, 0, 2)
    }):Play()
end

local function makeTab(iconId, name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Text = ""
    btn.BackgroundColor3 = C.bg2
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = S.GUI.Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local acc = Instance.new("Frame")
    acc.Size = UDim2.new(0, 2, 0, 0)
    acc.Position = UDim2.new(0, 0, 0.5, 0)
    acc.BackgroundColor3 = C.accent
    acc.BorderSizePixel = 0
    acc.Visible = false
    acc.Parent = btn
    Instance.new("UICorner", acc).CornerRadius = UDim.new(1, 0)

    local ic = Instance.new("ImageLabel")
    ic.Size = UDim2.new(0, 13, 0, 13)
    ic.Position = UDim2.new(0, 9, 0.5, -6)
    ic.BackgroundTransparency = 1
    ic.Image = iconId
    ic.ImageColor3 = C.textDim
    ic.Parent = btn

    local tx = Instance.new("TextLabel")
    tx.Size = UDim2.new(1, -30, 1, 0)
    tx.Position = UDim2.new(0, 28, 0, 0)
    tx.Text = name
    tx.TextColor3 = C.textDim
    tx.TextSize = 10
    tx.Font = F.norm
    tx.TextXAlignment = Enum.TextXAlignment.Left
    tx.BackgroundTransparency = 1
    tx.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.btn.BackgroundColor3 = C.bg2
            t.icon.ImageColor3 = C.textDim
            t.text.TextColor3 = C.textDim
            t.bar.Visible = false
        end
        btn.BackgroundColor3 = C.bg3
        ic.ImageColor3 = C.accent
        tx.TextColor3 = C.text
        acc.Visible = true
        acc.Size = UDim2.new(0, 2, 0, 0)
        S.Services.TS:Create(acc, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 2, 0, 16)
        }):Play()
        switchPage(name)
    end)

    table.insert(tabs, {btn = btn, icon = ic, text = tx, bar = acc, name = name})
end

createPage("Combat")
createPage("Esp")
createPage("Teleport")
createPage("Settings")
createPage("Config")

makeTab(I.combat, "Combat")
makeTab(I.visual, "Esp")
makeTab(I.teleport, "Teleport")
makeTab(I.settings, "Settings")
makeTab(I.config, "Config")

-- ============================================================
-- TAB COMBAT
-- ============================================================
local CC = S.Config.Combat

local autoCombat = S.Comp.makeSection(pages["Combat"], "Auto Combat", true)
S.Comp.makeToggle(autoCombat, "Auto Attack (V)", CC.AutoAttack, function(v) CC.AutoAttack = v save() end)
S.Comp.makeToggle(autoCombat, "Auto Rush (B)", CC.AutoRush, function(v) CC.AutoRush = v save() end)
S.Comp.makeToggle(autoCombat, "Inf Ammo", CC.InfAmmo, function(v) CC.InfAmmo = v save() end)

local pvpSection = S.Comp.makeSection(pages["Combat"], "PvP", true)
S.Comp.makeToggle(pvpSection, "Kill Aura", CC.KillAura, function(v) CC.KillAura = v save() end)
S.Comp.makeToggle(pvpSection, "Target Lock", CC.TargetLock, function(v) CC.TargetLock = v save() end)
S.Comp.makeToggle(pvpSection, "Auto Heal", CC.AutoHeal, function(v) CC.AutoHeal = v save() end)
S.Comp.makeToggle(pvpSection, "Anti-Stun", CC.AntiStun, function(v) CC.AntiStun = v save() end)

local combatDelay = S.Comp.makeSection(pages["Combat"], "Delay Settings", false)
S.Comp.makeInput(combatDelay, "Attack Delay", CC.AttackDelay, function(v) CC.AttackDelay = v save() end)
S.Comp.makeInput(combatDelay, "Rush Delay", CC.RushDelay, function(v) CC.RushDelay = v save() end)
S.Comp.makeInput(combatDelay, "Kill Aura Range", CC.KillAuraRange, function(v) CC.KillAuraRange = v save() end)
S.Comp.makeInput(combatDelay, "Heal Threshold", CC.HealThreshold, function(v) CC.HealThreshold = v save() end)

-- ============================================================
-- TAB ESP
-- ============================================================
local VV = S.Config.Visual

local enableEsp = S.Comp.makeSection(pages["Esp"], "Enable Esp", true)
S.Comp.makeToggle(enableEsp, "Enable Esp", VV.Chams, function(v) VV.Chams = v save() end)

local espSetting = S.Comp.makeSection(pages["Esp"], "Esp Setting", true)
S.Comp.makeToggle(espSetting, "Esp Box", VV.ESPBox, function(v) VV.ESPBox = v save() end)
S.Comp.makeToggle(espSetting, "Esp Health", VV.ESPHealth, function(v) VV.ESPHealth = v save() end)
S.Comp.makeToggle(espSetting, "Esp Name", VV.ESPName, function(v) VV.ESPName = v save() end)

-- ============================================================
-- TAB TELEPORT
-- ============================================================
local TT = S.Config.Teleport

local tpSetting = S.Comp.makeSection(pages["Teleport"], "Teleport Setting", true)
S.Comp.makeToggle(tpSetting, "Enable Teleport", TT.Enabled, function(v) TT.Enabled = v save() end)
S.Comp.makeInput(tpSetting, "Smooth Steps", TT.SmoothSteps, function(v) TT.SmoothSteps = v save() end)
S.Comp.makeInput(tpSetting, "Offset Y", TT.OffsetY, function(v) TT.OffsetY = v save() end)

local tpCapture = S.Comp.makeSection(pages["Teleport"], "Capture Point", true)
S.Comp.makeButton(tpCapture, "TP to Nearest Capture", function()
    if _G.STHAIN.TeleportToNearestCapture then _G.STHAIN.TeleportToNearestCapture() end
end)
S.Comp.makeButton(tpCapture, "TP to Base", function()
    if _G.STHAIN.TeleportToBase then _G.STHAIN.TeleportToBase() end
end)
S.Comp.makeButton(tpCapture, "TP to Point A", function()
    if _G.STHAIN.TeleportToPointA then _G.STHAIN.TeleportToPointA() end
end)
S.Comp.makeButton(tpCapture, "TP to Point B", function()
    if _G.STHAIN.TeleportToPointB then _G.STHAIN.TeleportToPointB() end
end)

local tpSupply = S.Comp.makeSection(pages["Teleport"], "Supply", true)
S.Comp.makeButton(tpSupply, "TP to Enemy Supply", function()
    if _G.STHAIN.TeleportToEnemySupply then _G.STHAIN.TeleportToEnemySupply() end
end)
S.Comp.makeButton(tpSupply, "TP to Own Supply", function()
    if _G.STHAIN.TeleportToOwnSupply then _G.STHAIN.TeleportToOwnSupply() end
end)

local tpPlayer = S.Comp.makeSection(pages["Teleport"], "Player", false)
S.Comp.makeButton(tpPlayer, "TP to Nearest Enemy", function()
    if _G.STHAIN.TeleportToNearestEnemy then _G.STHAIN.TeleportToNearestEnemy() end
end)
S.Comp.makeButton(tpPlayer, "TP to Teammate", function()
    if _G.STHAIN.TeleportToTeammate then _G.STHAIN.TeleportToTeammate() end
end)

local tpMisc = S.Comp.makeSection(pages["Teleport"], "Misc", false)
S.Comp.makeButton(tpMisc, "Scan Locations", function()
    if _G.STHAIN.TeleportScan then
        local r = _G.STHAIN.TeleportScan()
        print("[SCAN] Captures:", #r.captures, "Supplies:", #r.supplies)
    end
end)

-- ============================================================
-- TAB SETTINGS
-- ============================================================
local MM = S.Config.Movement
local XX = S.Config.Misc

local utilityContent = S.Comp.makeSection(pages["Settings"], "Player Utility", true)
S.Comp.makeInput(utilityContent, "Speed Value", MM.WalkSpeed, function(v) MM.WalkSpeed = v save() end)
S.Comp.makeToggle(utilityContent, "No Clip", MM.Noclip, function(v) MM.Noclip = v save() end)
S.Comp.makeToggle(utilityContent, "Fly", MM.Fly, function(v) MM.Fly = v save() end)
S.Comp.makeToggle(utilityContent, "Infinite Jump", MM.InfJump, function(v) MM.InfJump = v save() end)
S.Comp.makeInput(utilityContent, "Fly Speed", MM.FlySpeed, function(v) MM.FlySpeed = v save() end)
S.Comp.makeInput(utilityContent, "Hip Height", MM.HipHeight, function(v) MM.HipHeight = v save() end)
S.Comp.makeInput(utilityContent, "Jump Power", MM.JumpPower, function(v) MM.JumpPower = v save() end)

local miscContent = S.Comp.makeSection(pages["Settings"], "Misc", false)
S.Comp.makeToggle(miscContent, "Weapon Range", XX.WeaponRange, function(v) XX.WeaponRange = v save() end)
S.Comp.makeToggle(miscContent, "Auto Teleport", XX.AutoTP, function(v) XX.AutoTP = v save() end)
S.Comp.makeToggle(miscContent, "Anti-AFK", XX.AntiAFK, function(v) XX.AntiAFK = v save() end)
S.Comp.makeInput(miscContent, "Range Multi", XX.RangeMultiplier, function(v) XX.RangeMultiplier = v save() end)
S.Comp.makeInput(miscContent, "TP Range", XX.AutoTPRange, function(v) XX.AutoTPRange = v save() end)

local visualContent = S.Comp.makeSection(pages["Settings"], "Visuals", false)
S.Comp.makeToggle(visualContent, "Full Bright", VV.Fullbright, function(v) VV.Fullbright = v save() end)
S.Comp.makeToggle(visualContent, "No Fog", VV.NoFog, function(v) VV.NoFog = v save() end)

local serverContent = S.Comp.makeSection(pages["Settings"], "Server", false)
S.Comp.makeButton(serverContent, "Rejoin Server", function()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, S.LP)
    end)
end)
S.Comp.makeButton(serverContent, "Server Hop (Find Small Server)", function()
    pcall(function()
        local Http = game:GetService("HttpService")
        local TS = game:GetService("TeleportService")
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
        local data = Http:JSONDecode(game:HttpGet(url))
        local best = nil
        for _, server in pairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                if not best or server.playing < best.playing then
                    best = server
                end
            end
        end
        if best then TS:TeleportToPlaceInstance(game.PlaceId, best.id, S.LP) end
    end)
end)

local autoClaimContent = S.Comp.makeSection(pages["Settings"], "Auto Claim", true)
S.Comp.makeToggle(autoClaimContent, "Auto Claim Quest", XX.AutoClaimQuest or false, function(v)
    XX.AutoClaimQuest = v
    save()
end)
S.Comp.makeButton(autoClaimContent, "Klaim Misi Sekarang", function()
    if _G.STHAIN.ClaimQuests then
        _G.STHAIN.ClaimQuests()
    end
end)
S.Comp.makeToggle(autoClaimContent, "Auto Redeem Code", XX.AutoRedeemCode or false, function(v)
    XX.AutoRedeemCode = v
    save()
end)
S.Comp.makeButton(autoClaimContent, "Redeem Semua Code Sekarang", function()
    if _G.STHAIN.RedeemAllCodes then
        _G.STHAIN.RedeemAllCodes()
    end
end)

-- ============================================================
-- TAB CONFIG
-- ============================================================
local cfg = S.Config.Config

local autoSaveSection = S.Comp.makeSection(pages["Config"], "Auto Save", true)
S.Comp.makeToggle(autoSaveSection, "Auto Save Config", cfg.AutoSave, function(v)
    cfg.AutoSave = v
    if _G.STHAIN.SaveConfig then
        task.spawn(_G.STHAIN.SaveConfig)
    end
end)

local configMgmt = S.Comp.makeSection(pages["Config"], "Config Management", true)
S.Comp.makeButton(configMgmt, "Save Config Now", function()
    if _G.STHAIN.SaveConfig then
        _G.STHAIN.SaveConfig()
    end
end)
S.Comp.makeButton(configMgmt, "Delete Config", function()
    if _G.STHAIN.DeleteConfig then
        _G.STHAIN.DeleteConfig()
    end
end)

-- ============================================================
-- DRAG MAIN FRAME
-- ============================================================
local mainDrag, mainStart, mainPos
S.GUI.MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        mainDrag = true
        mainStart = input.Position
        mainPos = S.GUI.MainFrame.Position
    end
end)
S.GUI.MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and mainDrag then
        local delta = input.Position - mainStart
        S.GUI.MainFrame.Position = UDim2.new(
            mainPos.X.Scale, mainPos.X.Offset + delta.X,
            mainPos.Y.Scale, mainPos.Y.Offset + delta.Y
        )
    end
end)
S.GUI.MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        mainDrag = false
    end
end)

-- ============================================================
-- MINIMIZE / CLOSE / OPEN
-- ============================================================
switchPage("Combat")

S.GUI.MinBtn.MouseButton1Click:Connect(function()
    S.GUI.MainFrame.Visible = false
    S.GUI.FloatBtn.Visible = true
end)
S.GUI.CloseBtn.MouseButton1Click:Connect(function() S.GUI.Screen:Destroy() end)
S.GUI.FloatBtn.MouseButton1Click:Connect(function()
    S.GUI.FloatBtn.Visible = false
    S.GUI.MainFrame.Visible = true
end)

S.GUI.FloatBtn.Visible = true
S.GUI.MainFrame.Visible = false

print("[STHAIN] Pages loaded - FINAL v5")
