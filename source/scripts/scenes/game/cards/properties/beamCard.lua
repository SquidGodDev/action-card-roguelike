local pd <const> = playdate
local gfx <const> = pd.graphics

local rad = math.rad
local cos = math.cos
local sin = math.sin

local drawManager = DrawManager
local addDraw = drawManager.addDraw

BeamCard = {}

--- Requires: damage, length
function BeamCard.cast(x, y, angle, data)
    local stats = data.stats
    local length = stats.length
    local damage = stats.damage
    local angleInRad = rad(angle)
    local x2 = x + cos(angleInRad) * length
    local y2 = y + sin(angleInRad) * length
    EnemyManager.damageEnemyAlongLine(damage, x, y, x2, y2)
    local drawTime = 0.5
    local lineMaxWidth = 5
    addDraw(drawTime, function(time)
        gfx.setColor(gfx.kColorWhite)
        gfx.setLineWidth(lineMaxWidth * (time/drawTime))
        gfx.drawLine(x, y, x2, y2)
    end)
end