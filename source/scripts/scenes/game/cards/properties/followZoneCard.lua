local pd <const> = playdate
local gfx <const> = pd.graphics

local drawManager = DrawManager
local addDraw = drawManager.addDraw

local timerManager = TimerManager
local addTimer = timerManager.addTimer

FollowZoneCard = {}

--- Requires: damage, radius, time, interval
function FollowZoneCard.cast(x, y, _, data, player)
    local stats = data.stats
    local damage = stats.damage
    local radius = stats.radius
    local diameter = radius * 2
    local time = stats.time
    local interval = stats.interval
    local count = math.ceil(time/interval)
    for i=0, count do
        addTimer(i * interval, function()
            EnemyManager.damageEnemyInRect(damage, player.x - radius, player.y - radius, diameter, diameter)
        end)
    end
    addDraw(time, function()
        gfx.setColor(gfx.kColorWhite)
        gfx.setLineWidth(2)
        gfx.drawCircleAtPoint(player.x, player.y, radius)
    end)
end