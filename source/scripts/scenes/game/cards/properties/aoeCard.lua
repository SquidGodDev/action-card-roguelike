local pd <const> = playdate
local gfx <const> = pd.graphics

local drawManager = DrawManager
local addDraw = drawManager.addDraw

local function easeOutCubic(t)
    return 1 - (1 - t) ^ 2
end

AOECard = {}

--- Requires: damage, radius
function AOECard.cast(x, y, _, data, player)
    local stats = data.stats
    local damage = stats.damage
    local radius = stats.radius
    EnemyManager.damageEnemyInRect(damage, x - radius, y - radius, radius * 2, radius * 2)
    local drawTime = 0.4
    addDraw(drawTime, function(time)
        gfx.setColor(gfx.kColorWhite)
        local drawRadius = radius * easeOutCubic(time/drawTime)
        gfx.fillCircleAtPoint(player.x, player.y, drawRadius)
    end)
end