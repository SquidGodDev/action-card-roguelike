local pd <const> = playdate
local gfx <const> = pd.graphics

EnemyManager = {}
local enemyManager = EnemyManager

-- Enemy List
local maxEnemyCount <const> = 50
local queue <const> = Queue
local availableIndexes = nil
local activeIndexes = nil
local enemyCount = 0
local enemyHealth <const> = table.create(maxEnemyCount, 0)
local enemyX <const> = table.create(maxEnemyCount, 0)
local enemyY <const> = table.create(maxEnemyCount, 0)
local enemySpeedX <const> = table.create(maxEnemyCount, 0)
local enemySpeedY <const> = table.create(maxEnemyCount, 0)
local enemyMovementFunction <const> = table.create(maxEnemyCount, 0)
local enemyMoveTime <const> = table.create(maxEnemyCount, 0)
local enemyAttackFunction <const> = table.create(maxEnemyCount, 0)
local enemyAttackTime <const> = table.create(maxEnemyCount, 0)
local enemyMoveState <const> = table.create(maxEnemyCount, 0)
local enemyImage <const> = table.create(maxEnemyCount, 0)
local enemyWidth <const> = table.create(maxEnemyCount, 0)
local enemyHeight <const> = table.create(maxEnemyCount, 0)

enemyManager.enemyX = enemyX
enemyManager.enemyY = enemyY
enemyManager.enemySpeedX = enemySpeedX
enemyManager.enemySpeedY = enemySpeedY
enemyManager.enemyMoveTime = enemyMoveTime
enemyManager.enemyAttackTime = enemyAttackTime
enemyManager.enemyMoveState = enemyMoveState
enemyManager.enemyWidth = enemyWidth
enemyManager.enemyHeight = enemyHeight

local player
local playerWidthOffset, playerHeightOffset
local playerWidth, playerHeight

local function overlapsPlayer(index, pTLX, pTLY, pBRX, pBRY, topLeftX, topLeftY)
    local bottomRightX = topLeftX + enemyWidth[index]
    local bottomRightY = topLeftY + enemyHeight[index]
    if pTLX > bottomRightX or topLeftX > pBRX then
        -- One rect is to the right of the other
        return false
    elseif pBRY < topLeftY or bottomRightY < pTLY then
        -- One rect is above the other
        return false
    else
        -- Overlap!
        return true
    end
end

function EnemyManager.init(playerObject)
    player = playerObject
    playerWidthOffset, playerHeightOffset = player.widthOffset, player.heightOffset
    playerWidth, playerHeight = player.width, player.height

    enemyCount = 0
    availableIndexes = queue.new(maxEnemyCount)
    for i=1, maxEnemyCount do
        queue.push(availableIndexes, i)
    end
    activeIndexes = table.create(maxEnemyCount, 0)
end

function EnemyManager.update(dt, onlyDraw)
    if onlyDraw then
        for i=1, #activeIndexes do
            local enemyIndex <const> = activeIndexes[i]
            local x = enemyX[enemyIndex]
            local y = enemyY[enemyIndex]
            enemyImage[enemyIndex]:draw(x, y)
        end
    else
        local playerX, playerY = player.x, player.y
        local playerTopLeftX = playerX - playerWidthOffset
        local playerTopLeftY = playerY - playerHeightOffset
        local playerBottomRightX = playerTopLeftX + playerWidth
        local playerBottomRightY = playerTopLeftY + playerHeight
        for i=1, #activeIndexes do
            local enemyIndex <const> = activeIndexes[i]
            local moveTime = enemyMoveTime[enemyIndex]
            moveTime -= dt
            if moveTime <= 0 then
                enemyMovementFunction[enemyIndex](dt, enemyIndex, playerX, playerY)
            else
                enemyMoveTime[enemyIndex] = moveTime
            end

            local attackFunction = enemyAttackFunction[enemyIndex]
            if attackFunction then
                local attackTime = enemyAttackTime[enemyIndex]
                attackTime -= dt
                if attackTime <= 0 then
                    attackFunction(enemyIndex, playerX, playerY)
                else
                    enemyAttackTime[enemyIndex] = attackTime
                end
            end

            local x = enemyX[enemyIndex] + enemySpeedX[enemyIndex]
            local y = enemyY[enemyIndex] + enemySpeedY[enemyIndex]
            enemyX[enemyIndex] = x
            enemyY[enemyIndex] = y

            if overlapsPlayer(enemyIndex, playerTopLeftX, playerTopLeftY, playerBottomRightX, playerBottomRightY, x, y) then
                player.damage(1)
            end

            enemyImage[enemyIndex]:draw(x, y)
        end
    end
end

function EnemyManager.getActiveIndexes()
    return activeIndexes
end

function EnemyManager.removeEnemy(enemyIndex)
    local activeTableIndex = table.indexOfElement(activeIndexes, enemyIndex)
    if activeTableIndex then
        table.remove(activeIndexes, activeTableIndex)
    end
    availableIndexes.push(enemyIndex)
    enemyCount -= 1
end

function EnemyManager.damageEnemy(enemyIndex, damage)
    local health = enemyHealth[enemyIndex]
    health -= damage
    if health <= 0 then
        enemyManager.removeEnemy(enemyIndex)
        return
    end
    -- TODO: Add hit flash here
    enemyHealth[enemyIndex] = health
end

-- Enemy Object:
--  health
--  image
--  attackFunction(index, playerX, playerY, isInit) [optional]
--  moveFunction(dt, index, playerX, playerY)
function EnemyManager.spawnEnemy(enemy, x, y)
    if enemyCount >= maxEnemyCount then
        return
    end

    local enemyIndex <const> = queue.pop(availableIndexes)
    table.insert(activeIndexes, enemyIndex)

    enemyHealth[enemyIndex] = enemy.health
    enemyX[enemyIndex] = x
    enemyY[enemyIndex] = y
    enemyAttackFunction[enemyIndex] = enemy.attackFunction
    if enemy.attackFunction then
        enemy.attackFunction(enemyIndex, player.x, player.y, true)
    end
    enemyMoveState[enemyIndex] = 0
    enemyMovementFunction[enemyIndex] = enemy.moveFunction
    enemy.moveFunction(0.033, enemyIndex, player.x, player.y)

    enemyImage[enemyIndex] = enemy.image

    enemyWidth[enemyIndex], enemyHeight[enemyIndex] = enemy.image:getSize()

    enemyCount += 1
end
