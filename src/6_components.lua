--[[
============================================================
  [6] COMPONENTS (Collapsible Section)
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

function Comp.makeButton(parent, name, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -4, 0, 30)
    b.Text = name
    b.TextColor3 = C.text
    b.TextSize = 10
    b.Font = F.norm
    b.BackgroundColor3 = C.bg3
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)

    b.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    b.MouseEnter:Connect(function()
        S.Services.TS:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = C.bg4}):Play()
    end)
    b.MouseLeave:Connect(function()
        S.Services.TS:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = C.bg3}):Play()
    end)
end

-- COLLAPSIBLE SECTION
function Comp.makeSection(parent, title, defaultOpen)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -4, 0, 28)
    section.BackgroundTransparency = 1
    section.Parent = parent

    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.Padding = UDim.new(0, 3)
    sectionLayout.Parent = section

    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 28)
    header.Text = ""
    header.BackgroundColor3 = C.bg2
    header.BorderSizePixel = 0
    header.AutoButtonColor = false
    header.Parent = section
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 5)

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 16, 1, 0)
    arrow.Position = UDim2.new(0, 6, 0, 0)
    arrow.Text = defaultOpen and "▼" or "▶"
    arrow.TextColor3 = C.accent
    arrow.TextSize = 10
    arrow.Font = F.bold
    arrow.BackgroundTransparency = 1
    arrow.Parent = header

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -30, 1, 0)
    titleLbl.Position = UDim2.new(0, 24, 0, 0)
    titleLbl.Text = title
    titleLbl.TextColor3 = C.text
    titleLbl.TextSize = 11
    titleLbl.Font = F.bold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.BackgroundTransparency = 1
    titleLbl.Parent = header

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.Visible = defaultOpen
    content.Parent = section

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 3)
    contentLayout.Parent = content

    local isOpen = defaultOpen

    local function updateHeight()
        if isOpen then
            local totalH = 0
            for _, child in pairs(content:GetChildren()) do
                if child:IsA("Frame") then
                    totalH = totalH + child.Size.Y.Offset + 3
                end
            end
            content.Size = UDim2.new(1, 0, 0, totalH)
            section.Size = UDim2.new(1, -4, 0, 28 + totalH + 3)
        else
            content.Size = UDim2.new(1, 0, 0, 0)
            section.Size = UDim2.new(1, -4, 0, 28)
        end
    end

    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        arrow.Text = isOpen and "▼" or "▶"
        content.Visible = isOpen
        updateHeight()
    end)

    return content, updateHeight
end

S.Comp = Comp
