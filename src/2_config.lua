--[[
============================================================
  [2] CONFIG (FIXED - Anti Freeze Analog)
============================================================
]]

local Config = {
    Combat = {
        AutoAttack     = false,   -- OFF default (biar analog normal pas start)
        AutoRush       = false,   -- OFF default
        InfAmmo        = false,   -- OFF default
        KillAura       = false,
        TargetLock     = false,
        AutoHeal       = false,
        AntiStun       = false,
        AttackDelay    = 0.35,    -- dari 0.15 (biar ga freeze)
        RushDelay      = 0.5,     -- dari 0.30
        KillAuraRange  = 20,
        HealThreshold  = 30,
    },
    Movement = {
        Fly       = false,
        Noclip    = false,
        InfJump   = false,
        WalkSpeed = 16,
        HipHeight = 2,
        FlySpeed  = 60,
        JumpPower = 50,
    },
    Visual = {
        ESPBox          = false,
        ESPTracer       = false,
        ESPHealth       = false,
        ESPName         = false,
        Chams           = false,
        Fullbright      = false,
        NoFog           = false,
        Invisible       = false,
        SelfHitbox      = false,
        EnemyHitbox     = false,
        SelfHitboxSize  = 15,
        EnemyHitboxSize = 20,
    },
    Misc = {
        WeaponRange     = false,
        AutoTP          = false,
        AntiAFK         = true,
        RangeMultiplier = 3,
        AutoTPRange     = 100,
    },
    Teleport = {
        Enabled       = false,
        SelectedPoint = nil,
        SmoothSteps   = 10,
        OffsetY       = 5,
    },
}

_G.STHAIN.Config = Config
