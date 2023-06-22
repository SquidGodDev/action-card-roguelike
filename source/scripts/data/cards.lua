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

local cardBase <const> = gfx.imagetable.new('assets/images/cards/cardBase')
local function createCardImagetable(imagetablePath)
    local spellImagetable = gfx.imagetable.new(imagetablePath)
    local imagetableCount = #spellImagetable
    local cardImagetable = gfx.imagetable.new(imagetableCount)
    for i=1,#spellImagetable do
        local cardImage = cardBase[i]:copy()
        gfx.pushContext(cardImage)
            spellImagetable[i]:draw(15, 24)
        gfx.popContext()
        cardImagetable:setImage(i, cardImage)
    end
    return cardImagetable
end

for spell, spellData in pairs(CARDS) do
    local imagePath = spellData.imagePath
    spellData.imagetable = createCardImagetable(imagePath)
    spellData.name = spell
end