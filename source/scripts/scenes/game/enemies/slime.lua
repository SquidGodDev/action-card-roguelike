local enemyX <const> = EnemyManager.enemyX
local enemyY <const> = EnemyManager.enemyY
local enemySpeedX <const> = EnemyManager.enemySpeedX
local enemySpeedY <const> = EnemyManager.enemySpeedY
local enemyMoveTime <const> = EnemyManager.enemyMoveTime
local enemyAttackTime <const> = EnemyManager.enemyAttackTime
local enemyMoveState <const> = EnemyManager.enemyMoveState

local sqrt = math.sqrt
local random = math.random

local waitTime <const> = 2
local moveTime <const> = 1
local moveSpeed <const> = 2 * 30

Slime = {
    health = 10,
    image = playdate.graphics.image.new('assets/images/enemies/slime')
}

function Slime.moveFunction(dt, index, playerX, playerY)
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
        enemySpeedX[index] = (xDiff / magnitude) * (moveSpeed + random(-10, 10)) * dt
        enemySpeedY[index] = (yDiff / magnitude) * (moveSpeed + random(-10, 10)) * dt
        enemyMoveTime[index] = moveTime + random(-50, 50) / 100
        enemyMoveState[index] = 0
    end
end

-- Follow AI
-- function Slime.moveFunction(index, playerX, playerY)
--     local x = enemyX[index]
--     local y = enemyY[index]
--     local xDiff = playerX - x
--     local yDiff = playerY - y
--     local magnitude = sqrt(xDiff * xDiff + yDiff * yDiff)
--     enemySpeedX[index] = (xDiff / magnitude) * 1 * dt
--     enemySpeedY[index] = (yDiff / magnitude) * 1 * dt
--     enemyMoveTime[index] = 0
-- end