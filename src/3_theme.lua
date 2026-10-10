--[[
============================================================
  [3] THEME — Dark Grey Modern Style
============================================================
]]

local Theme = {
    Colors = {
        -- Background hierarchy (makin ke atas makin terang)
        bg       = Color3.fromRGB(18, 18, 21),    -- background utama (paling gelap)
        bg2      = Color3.fromRGB(26, 26, 30),    -- sidebar / panel
        bg3      = Color3.fromRGB(32, 32, 36),    -- card / section
        bg4      = Color3.fromRGB(38, 38, 43),    -- card dalam / item
        panel    = Color3.fromRGB(22, 22, 26),    -- main panel background

        -- Accent (STHAIN orange)
        accent   = Color3.fromRGB(255, 140, 60),

        -- Text hierarchy
        text     = Color3.fromRGB(240, 240, 245), -- text primary (putih soft)
        textDim  = Color3.fromRGB(160, 160, 170), -- text secondary (abu terang)
        textDim2 = Color3.fromRGB(110, 110, 120), -- text tertiary (abu gelap)

        -- Status colors
        green    = Color3.fromRGB(80, 220, 130),
        red      = Color3.fromRGB(230, 70, 70),
        yellow   = Color3.fromRGB(255, 200, 80),
        blue     = Color3.fromRGB(80, 160, 240),

        -- Border / stroke
        stroke   = Color3.fromRGB(45, 45, 52),    -- garis tipis
        stroke2  = Color3.fromRGB(58, 58, 66),    -- garis medium
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

    -- Radius standar
    Radius = {
        small = UDim.new(0, 4),
        medium = UDim.new(0, 6),
        large = UDim.new(0, 10),
        round = UDim.new(1, 0),
    },
}

_G.STHAIN.Theme = Theme

print("[STHAIN] Theme loaded (Dark Grey Modern)")
