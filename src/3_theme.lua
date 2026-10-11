--[[
============================================================
  [3] THEME — Dark Grey Monochrome
============================================================
]]

local Theme = {
    Colors = {
        -- Background hierarchy
        bg       = Color3.fromRGB(18, 18, 21),
        bg2      = Color3.fromRGB(26, 26, 30),
        bg3      = Color3.fromRGB(32, 32, 36),
        bg4      = Color3.fromRGB(38, 38, 43),
        panel    = Color3.fromRGB(22, 22, 26),

        -- Accent (putih keabuan)
        accent   = Color3.fromRGB(224, 224, 230),

        -- Text hierarchy
        text     = Color3.fromRGB(240, 240, 245),
        textDim  = Color3.fromRGB(160, 160, 170),
        textDim2 = Color3.fromRGB(110, 110, 120),

        -- Status colors
        green    = Color3.fromRGB(80, 220, 130),
        red      = Color3.fromRGB(230, 70, 70),
        yellow   = Color3.fromRGB(255, 200, 80),
        blue     = Color3.fromRGB(80, 160, 240),

        -- Border / stroke
        stroke   = Color3.fromRGB(45, 45, 52),
        stroke2  = Color3.fromRGB(58, 58, 66),
    },

    Icons = {
        combat   = "rbxassetid://99199363807265",
        visual   = "rbxassetid://127234874352422",
        settings = "rbxassetid://106205298246017",
        config   = "rbxassetid://112330254035751",
        teleport = "rbxassetid://90293255250749",
        search   = "rbxassetid://72296609649861",
        logo     = "rbxassetid://140310198502249",
    },

    Font = {
        bold = Enum.Font.GothamBold,
        norm = Enum.Font.Gotham,
        medium = Enum.Font.GothamMedium,
    },

    Radius = {
        small = UDim.new(0, 4),
        medium = UDim.new(0, 6),
        large = UDim.new(0, 10),
        round = UDim.new(1, 0),
    },
}

_G.STHAIN.Theme = Theme

print("[STHAIN] Theme loaded (Dark Grey Monochrome)")
