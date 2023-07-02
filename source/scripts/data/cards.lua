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
            cooldown = 2,
            speed = 5 * refreshRate,
            diameter = 24,
            damage = 5
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
    blast = {
        imagePath = 'assets/images/cards/blast',
        sfx = '',
        cast = RepeatedProjectileCard.cast,
        stats = {
            aimable = true,
            cooldown = 3,
            speed = 5 * refreshRate,
            diameter = 12,
            damage = 2,
            count = 7,
            interval = 0,
            spread = 40
        }
    },
    multi = {
        imagePath = 'assets/images/cards/multi',
        sfx = '',
        cast = RepeatedProjectileCard.cast,
        stats = {
            aimable = true,
            cooldown = 2,
            speed = 5 * refreshRate,
            diameter = 12,
            damage = 2,
            count = 7,
            interval = 0.2,
            spread = 0
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
    hurricane = {
        imagePath = 'assets/images/cards/hurricane',
        sfx = '',
        cast = DamageZoneCard.cast,
        stats = {
            aimable = false,
            cooldown = 7,
            damage = 0.5,
            radius = 60,
            time = 4,
            interval = 0.3
        }
    },
    poison = {
        imagePath = 'assets/images/cards/poison',
        sfx = '',
        cast = FollowZoneCard.cast,
        stats = {
            aimable = false,
            cooldown = 7,
            damage = 0.5,
            radius = 60,
            time = 4,
            interval = 0.3
        }
    },
    storm = {
        imagePath = 'assets/images/cards/storm',
        sfx = '',
        cast = RandomStrikeCard.cast,
        stats = {
            aimable = false,
            cooldown = 5,
            damage = 2,
            radius = 10,
            count = 30,
            maxDistance = 100,
            interval = 0.1
        }
    },
    detonate = {
        imagePath = 'assets/images/cards/detonate',
        sfx = '',
        cast = RowExplosionCard.cast,
        stats = {
            aimable = true,
            cooldown = 5,
            damage = 2,
            radius = 20,
            count = 8,
            interval = 0.5,
            distance = 20
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