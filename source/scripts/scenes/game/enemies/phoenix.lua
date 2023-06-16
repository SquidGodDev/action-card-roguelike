-- Phoenix: Standing turret

local enemyX <const> = EnemyManager.enemyX
local enemyY <const> = EnemyManager.enemyY
local enemySpeedX <const> = EnemyManager.enemySpeedX
local enemySpeedY <const> = EnemyManager.enemySpeedY
local enemyMoveTime <const> = EnemyManager.enemyMoveTime
local enemyAttackTime <const> = EnemyManager.enemyAttackTime
local enemyMoveState <const> = EnemyManager.enemyMoveState

local projectileManager <const> = ProjectileManager
local createProjectile <const> = projectileManager.createProjectile

local sqrt = math.sqrt
local random = math.random
local ringInt = math.ringInt

local pd <const> = playdate
local gfx <const> = pd.graphics

local refreshRate <const> = pd.display.getRefreshRate()

local waitTime <const> = 5
local projectileGapTime <const> = 0.3
local projectileSpeed <const> = refreshRate * 5
local projectileDiameter <const> = 12
local projectileDamage <const> = 1

Phoenix = {
    health = 4,
    imagetable = gfx.imagetable.new('assets/images/enemies/phoenix'),
    frameTime = .033, -- 150ms
    collisionDamage = 1
}

function Phoenix.moveFunction(index, playerX, playerY)
    enemySpeedX[index] = 0
    enemySpeedY[index] = 0
    local moveState = enemyMoveState[index]
    if moveState == 0 then
        enemyMoveTime[index] = waitTime + random(-50, 50) / 100
        enemyMoveState[index] = 1
    else
        local x = enemyX[index]
        local y = enemyY[index]
        local xDiff = playerX - x
        local yDiff = playerY - y
        local magnitude = sqrt(xDiff * xDiff + yDiff * yDiff)
        local xSpeed = xDiff / magnitude * projectileSpeed
        local ySpeed = yDiff / magnitude * projectileSpeed
        createProjectile(x, y, xSpeed, ySpeed, projectileDiameter, projectileDamage, false)
        enemyMoveTime[index] = projectileGapTime
        enemyMoveState[index] = ringInt(moveState + 1, 0, 3)
    end
end