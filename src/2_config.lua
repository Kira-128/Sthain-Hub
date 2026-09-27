--[[
============================================================
  [2] CONFIG
============================================================
]]

local Config = {
    Combat = {
        AutoAttack     = true,
        AutoRush       = true,
        InfAmmo        = true,
        KillAura       = false,
        TargetLock     = false,
        AutoHeal       = false,
        AntiStun       = false,   -- BARU
        AttackDelay    = 0.15,
        RushDelay      = 0.30,
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
