--[[
============================================================
  [7] PAGES (Collapsible Sections)
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local I = S.Theme.Icons
local F = S.Theme.Font

local pages = {}
local tabs = {}

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
createPage("Visual")
createPage("Settings")

makeTab(I.combat, "Combat")
makeTab(I.visual, "Visual")
makeTab(I.settings, "Settings")

-- ===== TAB COMBAT =====
local CC = S.Config.Combat
S.Comp.makeToggle(pages["Combat"], "Auto Attack (V)", CC.AutoAttack, function(v) CC.AutoAttack = v end)
S.Comp.makeToggle(pages["Combat"], "Auto Rush (B)", CC.AutoRush, function(v) CC.AutoRush = v end)
S.Comp.makeToggle(pages["Combat"], "Inf Ammo", CC.InfAmmo, function(v) CC.InfAmmo = v end)
S.Comp.makeToggle(pages["Combat"], "Kill Aura", CC.KillAura, function(v) CC.KillAura = v end)
S.Comp.makeToggle(pages["Combat"], "Target Lock", CC.TargetLock, function(v) CC.TargetLock = v end)
S.Comp.makeToggle(pages["Combat"], "Auto Heal", CC.AutoHeal, function(v) CC.AutoHeal = v end)
S.Comp.makeInput(pages["Combat"], "Attack Delay", CC.AttackDelay, function(v) CC.AttackDelay = v end)
S.Comp.makeInput(pages["Combat"], "Rush Delay", CC.RushDelay, function(v) CC.RushDelay = v end)
S.Comp.makeInput(pages["Combat"], "Kill Aura Range", CC.KillAuraRange, function(v) CC.KillAuraRange = v end)
S.Comp.makeInput(pages["Combat"], "Heal Threshold", CC.HealThreshold, function(v) CC.HealThreshold = v end)

-- ===== TAB VISUAL =====
local VV = S.Config.Visual
S.Comp.makeToggle(pages["Visual"], "ESP Box", VV.ESPBox, function(v) VV.ESPBox = v end)
S.Comp.makeToggle(pages["Visual"], "ESP Tracer", VV.ESPTracer, function(v) VV.ESPTracer = v end)
S.Comp.makeToggle(pages["Visual"], "ESP Health", VV.ESPHealth, function(v) VV.ESPHealth = v end)
S.Comp.makeToggle(pages["Visual"], "ESP Name", VV.ESPName, function(v) VV.ESPName = v end)
S.Comp.makeToggle(pages["Visual"], "Chams", VV.Chams, function(v) VV.Chams = v end)
S.Comp.makeToggle(pages["Visual"], "Fullbright", VV.Fullbright, function(v) VV.Fullbright = v end)
S.Comp.makeToggle(pages["Visual"], "No Fog", VV.NoFog, function(v) VV.NoFog = v end)
S.Comp.makeToggle(pages["Visual"], "Invisible", VV.Invisible, function(v) VV.Invisible = v end)
S.Comp.makeToggle(pages["Visual"], "Self Hitbox", VV.SelfHitbox, function(v) VV.SelfHitbox = v end)
S.Comp.makeToggle(pages["Visual"], "Enemy Hitbox", VV.EnemyHitbox, function(v) VV.EnemyHitbox = v end)
S.Comp.makeInput(pages["Visual"], "Self HB Size", VV.SelfHitboxSize, function(v) VV.SelfHitboxSize = v end)
S.Comp.makeInput(pages["Visual"], "Enemy HB Size", VV.EnemyHitboxSize, function(v) VV.EnemyHitboxSize = v end)

-- ===== TAB SETTINGS (COLLAPSIBLE) =====
local MM = S.Config.Movement
local XX = S.Config.Misc
local TT = S.Config.Teleport

-- Section 1
local utilityContent, updateUtility = S.Comp.makeSection(pages["Settings"], "Player Utility", true)
S.Comp.makeInput(utilityContent, "Speed Value", MM.WalkSpeed, function(v) MM.WalkSpeed = v end)
S.Comp.makeToggle(utilityContent, "No Clip", MM.Noclip, function(v) MM.Noclip = v end)
S.Comp.makeToggle(utilityContent, "Fly", MM.Fly, function(v) MM.Fly = v end)
S.Comp.makeToggle(utilityContent, "Infinite Jump", MM.InfJump, function(v) MM.InfJump = v end)
S.Comp.makeInput(utilityContent, "Fly Speed", MM.FlySpeed, function(v) MM.FlySpeed = v end)
S.Comp.makeInput(utilityContent, "Hip Height", MM.HipHeight, function(v) MM.HipHeight = v end)
S.Comp.makeInput(utilityContent, "Jump Power", MM.JumpPower, function(v) MM.JumpPower = v end)
task.spawn(function() task.wait(0.1) updateUtility() end)

-- Section 2
local miscContent, updateMisc = S.Comp.makeSection(pages["Settings"], "Misc", false)
S.Comp.makeToggle(miscContent, "Weapon Range", XX.WeaponRange, function(v) XX.WeaponRange = v end)
S.Comp.makeToggle(miscContent, "Auto Teleport", XX.AutoTP, function(v) XX.AutoTP = v end)
S.Comp.makeToggle(miscContent, "Anti-AFK", XX.AntiAFK, function(v) XX.AntiAFK = v end)
S.Comp.makeInput(miscContent, "Range Multi", XX.RangeMultiplier, function(v) XX.RangeMultiplier = v end)
S.Comp.makeInput(miscContent, "TP Range", XX.AutoTPRange, function(v) XX.AutoTPRange = v end)
task.spawn(function() task.wait(0.1) updateMisc() end)

-- Section 3
local tpContent, updateTP = S.Comp.makeSection(pages["Settings"], "Teleport", false)
S.Comp.makeToggle(tpContent, "Enable Teleport", TT.Enabled, function(v) TT.Enabled = v end)
S.Comp.makeInput(tpContent, "Smooth Steps", TT.SmoothSteps, function(v) TT.SmoothSteps = v end)
S.Comp.makeInput(tpContent, "Offset Y", TT.OffsetY, function(v) TT.OffsetY = v end)
S.Comp.makeButton(tpContent, "Scan Locations", function()
    local results = _G.STHAIN.TeleportScan()
    print("=== TELEPORT SCAN ===")
    for i, r in ipairs(results) do
        print(i .. ". " .. r.name .. " @ " .. tostring(r.position))
    end
    print("Total:", #results)
end)
S.Comp.makeButton(tpContent, "TP to First Capture", function()
    local results = _G.STHAIN.TeleportScan()
    for _, r in ipairs(results) do
        local n = string.lower(r.name)
        if n:find("capture") or n:find("base") then
            _G.STHAIN.TeleportTo(r.instance)
            print("TP to:", r.name)
            return
        end
    end
    warn("Ga ada capture point")
end)
S.Comp.makeButton(tpContent, "TP to Supply Camp", function()
    local results = _G.STHAIN.TeleportScan()
    for _, r in ipairs(results) do
        local n = string.lower(r.name)
        if n:find("supply") or n:find("camp") then
            _G.STHAIN.TeleportTo(r.instance)
            print("TP to:", r.name)
            return
        end
    end
    warn("Ga ada supply camp")
end)
task.spawn(function() task.wait(0.1) updateTP() end)

-- Drag Main Frame
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
