local pd <const> = playdate
local gfx <const> = pd.graphics

local random = math.random

local function easeOutCubic(t)
    return 1 - (1 - t) ^ 2
end

local setColor = gfx.setColor
local kColorWhite <const> = gfx.kColorWhite
local fillCircleAtPoint = gfx.fillCircleAtPoint

local drawManager = DrawManager
local addDraw = drawManager.addDraw

local timerManager = TimerManager
local addTimer = timerManager.addTimer

RandomStrikeCard = {}

--- Requires: damage, radius, count, maxDistance, interval
---
--- Optional: minDistance
function RandomStrikeCard.cast(_, _, _, data, player)
    local stats = data.stats
    local damage = stats.damage
    local radius = stats.radius
    local diameter = radius * 2
    local count = stats.count
    local minDistance = stats.minDistance or 30
    local maxDistance = stats.maxDistance
    local interval = stats.interval

    local drawTime = 0.5
    local damageEnemyInRect = EnemyManager.damageEnemyInRect
    for i=0, count-1 do
        addTimer(i*interval, function()
            local randomSignX = random(2) == 1 and 1 or -1
            local randomSignY = random(2) == 1 and 1 or -1
            local strikeX = player.x + randomSignX * random(minDistance, maxDistance)
            local strikeY = player.y + randomSignY * random(minDistance, maxDistance)
            damageEnemyInRect(damage, strikeX - radius, strikeY - radius, diameter, diameter)
            addDraw(drawTime, function(time)
                setColor(kColorWhite)
                local drawRadius = radius * easeOutCubic(time/drawTime)
                fillCircleAtPoint(strikeX, strikeY, drawRadius)
            end)
        end)
    end
end