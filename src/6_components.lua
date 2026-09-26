--[[
============================================================
  [6] COMPONENTS
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local F = S.Theme.Font

local Comp = {}

function Comp.makeToggle(parent, name, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -4, 0, 30)
    f.BackgroundColor3 = C.bg3
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.7, 0, 1, 0)
    l.Position = UDim2.new(0, 8, 0, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 10
    l.Font = F.norm
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 28, 0, 16)
    b.Position = UDim2.new(1, -36, 0.5, -8)
    b.Text = ""
    b.BackgroundColor3 = default and C.accent or C.bg4
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = default and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 3, 0.5, -5)
    knob.BackgroundColor3 = C.text
    knob.BorderSizePixel = 0
    knob.Parent = b
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    b.MouseButton1Click:Connect(function()
        state = not state
        S.Services.TS:Create(b, TweenInfo.new(0.2), {
            BackgroundColor3 = state and C.accent or C.bg4
        }):Play()
        S.Services.TS:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 3, 0.5, -5)
        }):Play()
        pcall(callback, state)
    end)
end

function Comp.makeInput(parent, name, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -4, 0, 30)
    f.BackgroundColor3 = C.bg3
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.55, 0, 1, 0)
    l.Position = UDim2.new(0, 8, 0, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 10
    l.Font = F.norm
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("TextBox")
    b.Size = UDim2.new(0, 50, 0, 20)
    b.Position = UDim2.new(1, -58, 0.5, -10)
    b.Text = tostring(default)
    b.TextColor3 = C.text
    b.TextSize = 10
    b.Font = F.norm
    b.BackgroundColor3 = C.bg4
    b.BorderSizePixel = 0
    b.ClearTextOnFocus = false
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

    b.FocusLost:Connect(function()
        local v = tonumber(b.Text)
        if v then pcall(callback, v) else b.Text = tostring(default) end
    end)
end

function Comp.makeLabel(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -4, 0, 20)
    l.Text = text
    l.TextColor3 = C.accent
    l.TextSize = 10
    l.Font = F.bold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = parent

    local pad = Instance.new("UIPadding", l)
    pad.PaddingLeft = UDim.new(0, 4)
end

S.Comp = Comp
