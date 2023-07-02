local pd <const> = playdate
local gfx <const> = pd.graphics

local rad = math.rad
local cos = math.cos
local sin = math.sin

local drawManager = DrawManager
local addDraw = drawManager.addDraw

local timerManager = TimerManager
local addTimer = timerManager.addTimer

local function easeOutCubic(t)
    return 1 - (1 - t) ^ 2
end

RowExplosionCard = {}

--- Requires: damage, radius, count, interval, distance
---
--- Optional: baseDistance
function RowExplosionCard.cast(x, y, angle, data, _)
    local stats = data.stats
    local damage = stats.damage
    local radius = stats.radius
    local diameter = radius * 2
    local count = stats.count
    local interval = stats.interval
    local distance = stats.distance
    local baseDistance = stats.baseDistance or 30

    local angleInRad = rad(angle)
    local xBase = x + cos(angleInRad) * baseDistance
    local yBase = y + sin(angleInRad) * baseDistance
    local xOffset = cos(angleInRad) * distance
    local yOffset = sin(angleInRad) * distance

    local drawTime = 0.4

    for i=0, count-1 do
        local damageX, damageY = xBase + i * xOffset, yBase + i * yOffset
        addTimer(i * interval, function()
            EnemyManager.damageEnemyInRect(damage, damageX - radius, damageY - radius, diameter, diameter)
            addDraw(drawTime, function(time)
                gfx.setColor(gfx.kColorWhite)
                local drawRadius = radius * easeOutCubic(time/drawTime)
                gfx.fillCircleAtPoint(damageX, damageY, drawRadius)
            end)
        end)
    end
end