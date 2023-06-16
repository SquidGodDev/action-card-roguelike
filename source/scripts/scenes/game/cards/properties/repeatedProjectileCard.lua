local rad = math.rad
local cos = math.cos
local sin = math.sin

local random = math.random

local projectileManager = ProjectileManager
local createProjectile = projectileManager.createProjectile

local timerManager = TimerManager
local addTimer = timerManager.addTimer

RepeatedProjectileCard = {}

--- Requires: speed, diameter, damage, count, interval, spread
function RepeatedProjectileCard.cast(x, y, angle, data, player)
    local stats = data.stats
    local speed = stats.speed
    local diameter = stats.diameter
    local damage = stats.damage
    local count = stats.count
    local interval = stats.interval
    local spread = stats.spread

    local isPlayer = true
    local angleInRad = rad(angle)
    local xSpeed = cos(angleInRad) * speed
    local ySpeed = sin(angleInRad) * speed

    count -= 1
    createProjectile(x, y, xSpeed, ySpeed, diameter, damage, isPlayer)

    for i=1, count do
        local time = i * interval
        addTimer(time, function()
            angleInRad = rad(random(math.floor(angle - spread + 0.5), math.floor(angle + spread + 0.5)))
            xSpeed = cos(angleInRad) * speed
            ySpeed = sin(angleInRad) * speed
            createProjectile(player.x, player.y, xSpeed, ySpeed, diameter, damage, isPlayer)
        end)
    end
end