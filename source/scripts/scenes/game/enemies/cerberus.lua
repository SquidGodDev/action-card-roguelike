-- Cerberus: Follow player

local pd <const> = playdate
local gfx <const> = pd.graphics
local sqrt = math.sqrt

local enemyX <const> = EnemyManager.enemyX
local enemyY <const> = EnemyManager.enemyY
local enemySpeedX <const> = EnemyManager.enemySpeedX
local enemySpeedY <const> = EnemyManager.enemySpeedY
local enemyMoveTime <const> = EnemyManager.enemyMoveTime

local refreshRate = pd.display.getRefreshRate()

local moveSpeed <const> = 1 * refreshRate

Cerberus = {
    health = 4,
    imagetable = gfx.imagetable.new('assets/images/enemies/cerberus'),
    frameTime = .033, -- 150ms
    collisionDamage = 1
}

function Cerberus.moveFunction(index, playerX, playerY)
    local x = enemyX[index]
    local y = enemyY[index]
    local xDiff = playerX - x
    local yDiff = playerY - y
    local magnitude = sqrt(xDiff * xDiff + yDiff * yDiff)
    enemySpeedX[index] = (xDiff / magnitude) * moveSpeed
    enemySpeedY[index] = (yDiff / magnitude) * moveSpeed
    enemyMoveTime[index] = 0
end