local pd <const> = playdate
local gfx <const> = pd.graphics

local refreshRate <const> = pd.display.getRefreshRate()

CARDS = {
    fireball = {
        imagePath = 'assets/images/cards/fireball',
        sfx = '',
        cast = ProjectileCard.cast,
        stats = {
            aimable = true,
            cooldown = 1,
            speed = 5 * refreshRate,
            diameter = 12,
            damage = 2
        }
    },
    flamethrower = {
        imagePath = 'assets/images/cards/fireball',
        sfx = '',
        cast = RepeatedProjectileCard.cast,
        stats = {
            aimable = true,
            cooldown = 3,
            speed = 5 * refreshRate,
            diameter = 12,
            damage = 2,
            count = 7,
            interval = 0.05,
            spread = 30
        }
    },
    stoneWall = {
        imagePath = 'assets/images/cards/stoneWall',
        sfx = '',
        stats = {
            aimable = false,
            cooldown = 1,
            shield = 3
        }
    },
    zap = {
        imagePath = 'assets/images/cards/zap',
        sfx = '',
        cast = BeamCard.cast,
        stats = {
            aimable = true,
            cooldown = 4,
            damage = 4,
            length = 235
        }
    },
    lightningStrike = {
        imagePath = 'assets/images/cards/lightningStrike',
        sfx = '',
        cast = AOECard.cast,
        stats = {
            aimable = false,
            cooldown = 12,
            damage = 4,
            radius = 60
        }
    },
    investigate = {
        imagePath = 'assets/images/cards/investigate',
        sfx = '',
        stats = {
            aimable = false,
            cooldown = 1,
            drawCount = 2
        }
    }
}

for spell, spellData in pairs(CARDS) do
    local imagePath = spellData.imagePath
    spellData.imagetable = gfx.imagetable.new(imagePath)

    spellData.name = spell
end