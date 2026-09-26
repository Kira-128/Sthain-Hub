--[[
============================================================
  [5] GUI
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
floatBtn.Size = UDim2.new(0, 48, 0, 48)
floatBtn.Position = UDim2.new(0, 30, 0.5, -24)
floatBtn.Text = ""
floatBtn.BackgroundColor3 = C.bg2
floatBtn.BorderSizePixel = 0
floatBtn.AutoButtonColor = false
floatBtn.Parent = gui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

local fStroke = Instance.new("UIStroke")
fStroke.Color = C.accent
fStroke.Thickness = 2
fStroke.Parent = floatBtn

local fIcon = Instance.new("ImageLabel")
fIcon.Size = UDim2.new(0, 24, 0, 24)
fIcon.Position = UDim2.new(0.5, -12, 0.5, -12)
fIcon.BackgroundTransparency = 1
fIcon.Image = I.logo
fIcon.ImageColor3 = C.accent
fIcon.Parent = floatBtn

-- DRAG
local dragging, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    floatBtn.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end
floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = floatBtn.Position
    end
end)
S.Services.UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)
S.Services.UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- MAIN FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 360)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -180)
mainFrame.BackgroundColor3 = C.panel
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local mStroke = Instance.new("UIStroke")
mStroke.Color = C.stroke
mStroke.Thickness = 1
mStroke.Parent = mainFrame

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = C.bg2
header.BorderSizePixel = 0
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local hFix = Instance.new("Frame")
hFix.Size = UDim2.new(1, 0, 0, 15)
hFix.Position = UDim2.new(0, 0, 1, -15)
hFix.BackgroundColor3 = C.bg2
hFix.BorderSizePixel = 0
hFix.Parent = header

local lIcon = Instance.new("ImageLabel")
lIcon.Size = UDim2.new(0, 18, 0, 18)
lIcon.Position = UDim2.new(0, 14, 0.5, -9)
lIcon.BackgroundTransparency = 1
lIcon.Image = I.logo
lIcon.ImageColor3 = C.accent
lIcon.Parent = header

local lText = Instance.new("TextLabel")
lText.Size = UDim2.new(0, 100, 1, 0)
lText.Position = UDim2.new(0, 38, 0, 0)
lText.Text = "STHAIN"
lText.TextColor3 = C.accent
lText.TextSize = 15
lText.Font = F.bold
lText.TextXAlignment = Enum.TextXAlignment.Left
lText.BackgroundTransparency = 1
lText.Parent = header

local sep = Instance.new("Frame")
sep.Size = UDim2.new(0, 1, 0, 20)
sep.Position = UDim2.new(0, 100, 0.5, -10)
sep.BackgroundColor3 = C.stroke
sep.BorderSizePixel = 0
sep.Parent = header

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(0, 250, 1, 0)
sub.Position = UDim2.new(0, 112, 0, 0)
sub.Text = "Command An Army"
sub.TextColor3 = C.textDim
sub.TextSize = 11
sub.Font = F.norm
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.BackgroundTransparency = 1
sub.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -56, 0.5, -12)
minBtn.Text = "−"
minBtn.TextColor3 = C.textDim
minBtn.TextSize = 16
minBtn.Font = F.bold
minBtn.BackgroundColor3 = C.bg3
minBtn.BorderSizePixel = 0
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 5)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0.5, -12)
closeBtn.Text = "×"
closeBtn.TextColor3 = C.textDim
closeBtn.TextSize = 16
closeBtn.Font = F.bold
closeBtn.BackgroundColor3 = C.bg3
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

-- SEARCH
local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(0, 180, 0, 28)
searchFrame.Position = UDim2.new(0, 12, 0, 50)
searchFrame.BackgroundColor3 = C.bg2
searchFrame.BorderSizePixel = 0
searchFrame.Parent = mainFrame
Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 6)

local sIcon = Instance.new("ImageLabel")
sIcon.Size = UDim2.new(0, 12, 0, 12)
sIcon.Position = UDim2.new(0, 10, 0.5, -6)
sIcon.BackgroundTransparency = 1
sIcon.Image = I.search
sIcon.ImageColor3 = C.textDim
sIcon.Parent = searchFrame

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -34, 1, 0)
searchBox.Position = UDim2.new(0, 30, 0, 0)
searchBox.PlaceholderText = "Search..."
searchBox.PlaceholderColor3 = C.textDim2
searchBox.TextColor3 = C.text
searchBox.TextSize = 11
searchBox.Font = F.norm
searchBox.BackgroundTransparency = 1
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchFrame

-- SIDEBAR
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -100)
sidebar.Position = UDim2.new(0, 12, 0, 86)
sidebar.BackgroundColor3 = C.bg2
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local sLayout = Instance.new("UIListLayout")
sLayout.Padding = UDim.new(0, 3)
sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sLayout.Parent = sidebar

local sPad = Instance.new("UIPadding")
sPad.PaddingTop = UDim.new(0, 8)
sPad.PaddingBottom = UDim.new(0, 8)
sPad.Parent = sidebar

-- CONTENT
local contentPanel = Instance.new("Frame")
contentPanel.Size = UDim2.new(1, -160, 1, -100)
contentPanel.Position = UDim2.new(0, 148, 0, 86)
contentPanel.BackgroundColor3 = C.bg2
contentPanel.BorderSizePixel = 0
contentPanel.Parent = mainFrame
Instance.new("UICorner", contentPanel).CornerRadius = UDim.new(0, 8)

local cTitle = Instance.new("TextLabel")
cTitle.Size = UDim2.new(1, -20, 0, 24)
cTitle.Position = UDim2.new(0, 12, 0, 6)
cTitle.Text = "Combat"
cTitle.TextColor3 = C.text
cTitle.TextSize = 13
cTitle.Font = F.bold
cTitle.TextXAlignment = Enum.TextXAlignment.Left
cTitle.BackgroundTransparency = 1
cTitle.Parent = contentPanel

local tLine = Instance.new("Frame")
tLine.Size = UDim2.new(0, 30, 0, 2)
tLine.Position = UDim2.new(0, 12, 0, 30)
tLine.BackgroundColor3 = C.accent
tLine.BorderSizePixel = 0
tLine.Parent = contentPanel
Instance.new("UICorner", tLine).CornerRadius = UDim.new(1, 0)

-- SIMPAN REFERENSI
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
