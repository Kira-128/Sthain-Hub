--[[
============================================================
  [5] GUI (Compact + PC + Mobile)
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local I = S.Theme.Icons
local F = S.Theme.Font

local gui = Instance.new("ScreenGui")
gui.Name = "SthainHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- FLOAT BUTTON
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 42, 0, 42)
floatBtn.Position = UDim2.new(0, 30, 0.5, -21)
floatBtn.Text = ""
floatBtn.BackgroundColor3 = C.bg2
floatBtn.BorderSizePixel = 0
floatBtn.AutoButtonColor = false
floatBtn.Parent = gui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

local fStroke = Instance.new("UIStroke")
fStroke.Color = C.accent
fStroke.Thickness = 1.5
fStroke.Parent = floatBtn

local fIcon = Instance.new("ImageLabel")
fIcon.Size = UDim2.new(0, 20, 0, 20)
fIcon.Position = UDim2.new(0.5, -10, 0.5, -10)
fIcon.BackgroundTransparency = 1
fIcon.Image = I.logo
fIcon.ImageColor3 = C.accent
fIcon.Parent = floatBtn

-- DRAG
local dragging, dragStart, startPos
floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = floatBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
floatBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            floatBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)

-- MAIN FRAME (460x320)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 460, 0, 320)
mainFrame.Position = UDim2.new(0.5, -230, 0.5, -160)
mainFrame.BackgroundColor3 = C.panel
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = false
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local mStroke = Instance.new("UIStroke")
mStroke.Color = C.stroke
mStroke.Thickness = 1
mStroke.Parent = mainFrame

-- DRAG MAIN
local mainDrag, mainStart, mainPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        mainDrag = true
        mainStart = input.Position
        mainPos = mainFrame.Position
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and mainDrag then
        local delta = input.Position - mainStart
        mainFrame.Position = UDim2.new(
            mainPos.X.Scale, mainPos.X.Offset + delta.X,
            mainPos.Y.Scale, mainPos.Y.Offset + delta.Y
        )
    end
end)
mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        mainDrag = false
    end
end)

-- HEADER (36px)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = C.bg2
header.BorderSizePixel = 0
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

local hFix = Instance.new("Frame")
hFix.Size = UDim2.new(1, 0, 0, 15)
hFix.Position = UDim2.new(0, 0, 1, -15)
hFix.BackgroundColor3 = C.bg2
hFix.BorderSizePixel = 0
hFix.Parent = header

local lIcon = Instance.new("ImageLabel")
lIcon.Size = UDim2.new(0, 16, 0, 16)
lIcon.Position = UDim2.new(0, 12, 0.5, -8)
lIcon.BackgroundTransparency = 1
lIcon.Image = I.logo
lIcon.ImageColor3 = C.accent
lIcon.Parent = header

local lText = Instance.new("TextLabel")
lText.Size = UDim2.new(0, 80, 1, 0)
lText.Position = UDim2.new(0, 34, 0, 0)
lText.Text = "STHAIN"
lText.TextColor3 = C.accent
lText.TextSize = 13
lText.Font = F.bold
lText.TextXAlignment = Enum.TextXAlignment.Left
lText.BackgroundTransparency = 1
lText.Parent = header

local sep = Instance.new("Frame")
sep.Size = UDim2.new(0, 1, 0, 18)
sep.Position = UDim2.new(0, 90, 0.5, -9)
sep.BackgroundColor3 = C.stroke
sep.BorderSizePixel = 0
sep.Parent = header

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(0, 200, 1, 0)
sub.Position = UDim2.new(0, 100, 0, 0)
sub.Text = "Command An Army"
sub.TextColor3 = C.textDim
sub.TextSize = 10
sub.Font = F.norm
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.BackgroundTransparency = 1
sub.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(1, -52, 0.5, -11)
minBtn.Text = "−"
minBtn.TextColor3 = C.textDim
minBtn.TextSize = 14
minBtn.Font = F.bold
minBtn.BackgroundColor3 = C.bg3
minBtn.BorderSizePixel = 0
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -26, 0.5, -11)
closeBtn.Text = "×"
closeBtn.TextColor3 = C.textDim
closeBtn.TextSize = 14
closeBtn.Font = F.bold
closeBtn.BackgroundColor3 = C.bg3
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

-- SEARCH
local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(0, 160, 0, 26)
searchFrame.Position = UDim2.new(0, 10, 0, 44)
searchFrame.BackgroundColor3 = C.bg2
searchFrame.BorderSizePixel = 0
searchFrame.Parent = mainFrame
Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 5)

local sIcon = Instance.new("ImageLabel")
sIcon.Size = UDim2.new(0, 10, 0, 10)
sIcon.Position = UDim2.new(0, 9, 0.5, -5)
sIcon.BackgroundTransparency = 1
sIcon.Image = I.search
sIcon.ImageColor3 = C.textDim
sIcon.Parent = searchFrame

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -30, 1, 0)
searchBox.Position = UDim2.new(0, 26, 0, 0)
searchBox.Text = ""
searchBox.PlaceholderText = "Search..."
searchBox.PlaceholderColor3 = C.textDim2
searchBox.TextColor3 = C.text
searchBox.TextSize = 10
searchBox.Font = F.norm
searchBox.BackgroundTransparency = 1
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchFrame

-- SIDEBAR
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 120, 1, -90)
sidebar.Position = UDim2.new(0, 10, 0, 78)
sidebar.BackgroundColor3 = C.bg2
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 6)

local sLayout = Instance.new("UIListLayout")
sLayout.Padding = UDim.new(0, 2)
sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sLayout.Parent = sidebar

local sPad = Instance.new("UIPadding")
sPad.PaddingTop = UDim.new(0, 6)
sPad.PaddingBottom = UDim.new(0, 6)
sPad.Parent = sidebar

-- CONTENT
local contentPanel = Instance.new("Frame")
contentPanel.Size = UDim2.new(1, -140, 1, -90)
contentPanel.Position = UDim2.new(0, 130, 0, 78)
contentPanel.BackgroundColor3 = C.bg2
contentPanel.BorderSizePixel = 0
contentPanel.Parent = mainFrame
Instance.new("UICorner", contentPanel).CornerRadius = UDim.new(0, 6)

local cTitle = Instance.new("TextLabel")
cTitle.Size = UDim2.new(1, -20, 0, 22)
cTitle.Position = UDim2.new(0, 10, 0, 5)
cTitle.Text = "Combat"
cTitle.TextColor3 = C.text
cTitle.TextSize = 12
cTitle.Font = F.bold
cTitle.TextXAlignment = Enum.TextXAlignment.Left
cTitle.BackgroundTransparency = 1
cTitle.Parent = contentPanel

local tLine = Instance.new("Frame")
tLine.Size = UDim2.new(0, 25, 0, 2)
tLine.Position = UDim2.new(0, 10, 0, 27)
tLine.BackgroundColor3 = C.accent
tLine.BorderSizePixel = 0
tLine.Parent = contentPanel
Instance.new("UICorner", tLine).CornerRadius = UDim.new(1, 0)

S.GUI = {
    Screen = gui,
    FloatBtn = floatBtn,
    MainFrame = mainFrame,
    Sidebar = sidebar,
    Content = contentPanel,
    ContentTitle = cTitle,
    TitleLine = tLine,
    MinBtn = minBtn,
    CloseBtn = closeBtn,
}
