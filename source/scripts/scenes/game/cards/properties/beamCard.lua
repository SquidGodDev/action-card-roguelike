local pd <const> = playdate
local gfx <const> = pd.graphics

local rad = math.rad
local cos = math.cos
local sin = math.sin

local drawManager = DrawManager
local addDraw = drawManager.addDraw

BeamCard = {}

--- Requires: damage, length
function BeamCard.cast(x, y, angle, data, player)
    local stats = data.stats
    local length = stats.length
    local damage = stats.damage
    local angleInRad = rad(angle)
    local xOffset = cos(angleInRad) * length
    local yOffset = sin(angleInRad) * length
    EnemyManager.damageEnemyAlongLine(damage, x, y, x + xOffset, y + yOffset)
    local drawTime = 0.5
    local lineMaxWidth = 5
    addDraw(drawTime, function(time)
        gfx.setColor(gfx.kColorWhite)
        gfx.setLineWidth(lineMaxWidth * (time/drawTime))
        local x1, y1 = player.x, player.y
        local x2 = x + xOffset
        local y2 = y + yOffset
        gfx.drawLine(x1, y1, x2, y2)
    end)
end