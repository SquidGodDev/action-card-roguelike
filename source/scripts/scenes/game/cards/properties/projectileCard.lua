local rad = math.rad
local cos = math.cos
local sin = math.sin

local projectileManager = ProjectileManager
local createProjectile = projectileManager.createProjectile

ProjectileCard = {}

--- Requires: speed, diameter, damage
function ProjectileCard.cast(x, y, angle, data, _)
    local stats = data.stats
    local speed = stats.speed
    local diameter = stats.diameter
    local damage = stats.damage
    local isPlayer = true
    local angleInRad = rad(angle)
    local xSpeed = cos(angleInRad) * speed
    local ySpeed = sin(angleInRad) * speed
    createProjectile(x, y, xSpeed, ySpeed, diameter, damage, isPlayer)
end