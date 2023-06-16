-- Gargoyle: Wait, then rush at player

local enemyX <const> = EnemyManager.enemyX
local enemyY <const> = EnemyManager.enemyY
local enemySpeedX <const> = EnemyManager.enemySpeedX
local enemySpeedY <const> = EnemyManager.enemySpeedY
local enemyMoveTime <const> = EnemyManager.enemyMoveTime
local enemyMoveState <const> = EnemyManager.enemyMoveState

local sqrt = math.sqrt
local random = math.random

local pd <const> = playdate
local gfx <const> = pd.graphics

local refreshRate <const> = pd.display.getRefreshRate()

local waitTime <const> = 2
local moveTime <const> = 3
local moveSpeed <const> = 3 * refreshRate

Gargoyle = {
    health = 4,
    imagetable = gfx.imagetable.new('assets/images/enemies/gargoyle'),
    frameTime = .033, -- 150ms
    collisionDamage = 1
}

function Gargoyle.moveFunction(index, playerX, playerY)
    local moveState = enemyMoveState[index]
    if moveState == 0 then
        enemySpeedX[index] = 0
        enemySpeedY[index] = 0
        enemyMoveTime[index] = waitTime + random(-50, 50) / 100
        enemyMoveState[index] = 1
    else
        local x = enemyX[index]
        local y = enemyY[index]
        local xDiff = playerX - x
        local yDiff = playerY - y
        local magnitude = sqrt(xDiff * xDiff + yDiff * yDiff)
        enemySpeedX[index] = (xDiff / magnitude) * (moveSpeed + random(-10, 10))
        enemySpeedY[index] = (yDiff / magnitude) * (moveSpeed + random(-10, 10))
        enemyMoveTime[index] = moveTime + random(-50, 50) / 100
        enemyMoveState[index] = 0
    end
end
