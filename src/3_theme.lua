--[[
============================================================
  [3] THEME
============================================================
]]

local Theme = {
    Colors = {
        bg       = Color3.fromRGB(10, 10, 12),
        bg2      = Color3.fromRGB(20, 20, 24),
        bg3      = Color3.fromRGB(28, 28, 34),
        bg4      = Color3.fromRGB(38, 38, 46),
        panel    = Color3.fromRGB(14, 14, 18),
        accent   = Color3.fromRGB(255, 140, 60),
        text     = Color3.fromRGB(240, 240, 245),
        textDim  = Color3.fromRGB(130, 130, 145),
        textDim2 = Color3.fromRGB(80, 80, 95),
        green    = Color3.fromRGB(80, 220, 130),
        red      = Color3.fromRGB(230, 70, 70),
        stroke   = Color3.fromRGB(45, 45, 55),
    },
    Icons = {
        combat   = "rbxassetid://99199363807265",
        visual   = "rbxassetid://127234874352422",
        settings = "rbxassetid://106205298246017",
        config   = "rbxassetid://112330254035751",
        teleport = "rbxassetid://90293255250749",
        search   = "rbxassetid://72296609649861",
        logo     = "rbxassetid://136526785382643",
    },
    Font = {
        bold = Enum.Font.GothamBold,
        norm = Enum.Font.Gotham,
    },
}

_G.STHAIN.Theme = Theme
