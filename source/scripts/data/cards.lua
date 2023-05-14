local pd <const> = playdate
local gfx <const> = pd.graphics

CARDS = {
    fireball = {
        imagePath = "assets/images/cards/fireball",
        sfx = "",
        stats = {
            aimable = true,
            cost = 1,
            damage = 3
        }
    },
    stoneWall = {
        imagePath = "assets/images/cards/stoneWall",
        sfx = "",
        stats = {
            aimable = false,
            cost = 1,
            shield = 3
        }
    },
    zap = {
        imagePath = "assets/images/cards/zap",
        sfx = "",
        stats = {
            aimable = true,
            cost = 0,
            damage = 1
        }
    },
    lightningStrike = {
        imagePath = "assets/images/cards/lightningStrike",
        sfx = "",
        stats = {
            aimable = true,
            cost = 2,
            damage = 2
        }
    },
    investigate = {
        imagePath = "assets/images/cards/investigate",
        sfx = "",
        stats = {
            aimable = false,
            cost = 1,
            drawCount = 2
        }
    }
}

for spell, spellData in pairs(CARDS) do
    local imagePath = spellData.imagePath
    spellData.imagetable = gfx.imagetable.new(imagePath)

    spellData.name = spell
end