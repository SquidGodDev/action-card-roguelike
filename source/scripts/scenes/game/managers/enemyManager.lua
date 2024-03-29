local pd <const> = playdate
local gfx <const> = pd.graphics

local ringInt = math.ringInt
local floor = math.floor

local function easeOutCubic(t)
    return 1 - (1 - t) ^ 2
end

local function easeInCubic(t)
    return t * t * t;
end

local drawImagetable = gfx.imagetable.drawImage

EnemyManager = {}
local enemyManager = EnemyManager

local particleManager = ParticleManager
local addParticle = particleManager.addParticle
local deathParticlesImageTable = gfx.imagetable.new('assets/images/particles/enemyDeathParticles')
local deathParticlesFrameTime = .02

local drawManager = DrawManager
local addDraw = drawManager.addDraw

local timerManager = TimerManager
local addTimer = timerManager.addTimer

local maxFlashTime <const> = .15
local maxCollisionTime <const> = 1

-- Enemy List
local maxEnemyCount <const> = 150
local queue <const> = Queue
local availableIndexes = nil
local activeIndexes = nil
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
local enemyImagetable <const> = table.create(maxEnemyCount, 0)
local enemyFrameTime <const> = table.create(maxEnemyCount, 0)
local enemyFrameTimeCounter <const> = table.create(maxEnemyCount, 0)
local enemyWidth <const> = table.create(maxEnemyCount, 0)
local enemyHeight <const> = table.create(maxEnemyCount, 0)
local enemyCollisionDamage <const> = table.create(maxEnemyCount, 0)
local enemyCollisionTimer <const> = table.create(maxEnemyCount, 0)
local flashTimer <const> = table.create(maxEnemyCount, 0)

enemyManager.enemyX = enemyX
enemyManager.enemyY = enemyY
enemyManager.enemySpeedX = enemySpeedX
enemyManager.enemySpeedY = enemySpeedY
enemyManager.enemyMoveTime = enemyMoveTime
enemyManager.enemyAttackTime = enemyAttackTime
enemyManager.enemyMoveState = enemyMoveState
enemyManager.enemyWidth = enemyWidth
enemyManager.enemyHeight = enemyHeight
enemyManager.collisionDamage = enemyCollisionDamage

local player
local playerWidthOffset, playerHeightOffset
local playerWidth, playerHeight

local levelManager

local minX, maxX, minY, maxY

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

function EnemyManager.init(_player)
    player = _player
    playerWidthOffset, playerHeightOffset = player.widthOffset, player.heightOffset
    playerWidth, playerHeight = player.width, player.height

    local gameScene = GameScene
    minX, maxX = gameScene.minX, gameScene.maxX
    minY, maxY = gameScene.minY, gameScene.maxY

    availableIndexes = queue.new(maxEnemyCount)
    for i=1, maxEnemyCount do
        queue.push(availableIndexes, i)
    end
    activeIndexes = table.create(maxEnemyCount, 0)
end

function EnemyManager.setLevelManager(_levelManager)
    levelManager = _levelManager
end

function EnemyManager.update(dt)
    local playerX, playerY = player.x, player.y
    local playerTopLeftX = playerX - playerWidthOffset
    local playerTopLeftY = playerY - playerHeightOffset
    local playerBottomRightX = playerTopLeftX + playerWidth
    local playerBottomRightY = playerTopLeftY + playerHeight
    for i=1, #activeIndexes do
        local enemyIndex <const> = activeIndexes[i]

        -- Call enemy movement function
        local moveTime = enemyMoveTime[enemyIndex]
        moveTime -= dt
        if moveTime <= 0 then
            enemyMovementFunction[enemyIndex](enemyIndex, playerX, playerY)
        else
            enemyMoveTime[enemyIndex] = moveTime
        end

        -- Call enemy attack function
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

        -- Check wall collision
        local width, height = enemyWidth[enemyIndex], enemyHeight[enemyIndex]
        local x = enemyX[enemyIndex] + enemySpeedX[enemyIndex] * dt
        local y = enemyY[enemyIndex] + enemySpeedY[enemyIndex] * dt

        if x < minX then
            x = minX
        elseif x > maxX - width then
            x = maxX - width
        end

        if y < minY then
            y = minY
        elseif y > maxY - height then
            y = maxY - height
        end

        enemyX[enemyIndex] = x
        enemyY[enemyIndex] = y

        -- Check player collision
        local collisionTime = enemyCollisionTimer[enemyIndex]
        if collisionTime > 0 then
            collisionTime -= dt
            enemyCollisionTimer[enemyIndex] = collisionTime
        else
            if overlapsPlayer(enemyIndex, playerTopLeftX, playerTopLeftY, playerBottomRightX, playerBottomRightY, x, y) then
                local playerDamaged = player.damage(enemyCollisionDamage[enemyIndex])
                if playerDamaged then
                    enemyCollisionTimer[enemyIndex] = maxCollisionTime
                end
            end
        end

        -- Draw enemy image
        local imagetable = enemyImagetable[enemyIndex]
        local frameTimeCounter = enemyFrameTimeCounter[enemyIndex]
        frameTimeCounter += dt
        enemyFrameTimeCounter[enemyIndex] = frameTimeCounter
        local frameTime = enemyFrameTime[enemyIndex]
        local frameIndex = ringInt(1 + floor(frameTimeCounter / frameTime), 1, #imagetable)

        local flashTime = flashTimer[enemyIndex]
        if flashTime > 0 then
            flashTime -= dt
            flashTimer[enemyIndex] = flashTime
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            drawImagetable(imagetable, frameIndex, x, y)
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        else
            drawImagetable(imagetable, frameIndex, x, y)
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
    queue.push(availableIndexes, enemyIndex)
end

function EnemyManager.damageEnemy(enemyIndex, damage)
    local health = enemyHealth[enemyIndex]
    health -= damage
    if health <= 0 then
        enemyManager.removeEnemy(enemyIndex)
        local x, y = enemyX[enemyIndex] + enemyWidth[enemyIndex]/2, enemyY[enemyIndex] + enemyHeight[enemyIndex]/2
        addParticle(x, y, deathParticlesImageTable, deathParticlesFrameTime)
        if levelManager then
            levelManager:enemyDied()
        end
        return true
    end
    flashTimer[enemyIndex] = maxFlashTime
    enemyHealth[enemyIndex] = health
    return true
end

local damageEnemy = enemyManager.damageEnemy

local function ccw(x1, y1, x2, y2, x3, y3)
    return (y3 - y1) * (x2 - x1) > (y2 - y1) * (x3 - x1)
end

local function intersect(x1, y1, x2, y2, x3, y3, x4, y4)
    return ccw(x1, y1, x3, y3, x4, y4) ~= ccw(x2, y2, x3, y3, x4, y4) and ccw(x1, y1, x2, y2, x3, y3) ~= ccw(x1, y1, x2, y2, x4, y4)
end

-- Initially written by ChatGPT and adapted. I find these common operations are where ChatGPT shines. Prompt:
-- Rectangles are represented by a point indicating their top left corner, a width, and a height. 
-- Write a function in Lua that takes a line segment and a rectangle and returns whether or not the line segment intersects the rectangle.
local function lineIntersectsEnemy(enemyIndex, segmentStartX, segmentStartY, segmentEndX, segmentEndY)
    local rectX, rectY = enemyX[enemyIndex], enemyY[enemyIndex]
    local rectRight = rectX + enemyWidth[enemyIndex]
    local rectBottom = rectY + enemyHeight[enemyIndex]

    -- Check if segment is completely outside the rectangle's bounds
    if (segmentEndX < rectX and segmentStartX < rectX) or
       (segmentEndX > rectRight and segmentStartX > rectRight) or
       (segmentEndY < rectY and segmentStartY < rectY) or
       (segmentEndY > rectBottom and segmentStartY > rectBottom) then
        return false
    end

    -- Check if segment intersects any of the rectangle's edges
    if intersect(segmentStartX, segmentStartY, segmentEndX, segmentEndY, rectX, rectY, rectX, rectBottom) or
        intersect(segmentStartX, segmentStartY, segmentEndX, segmentEndY, rectX, rectBottom, rectRight, rectBottom) or
        intersect(segmentStartX, segmentStartY, segmentEndX, segmentEndY, rectRight, rectBottom, rectRight, rectY) or
        intersect(segmentStartX, segmentStartY, segmentEndX, segmentEndY, rectRight, rectY, rectX, rectY) then
        return true
    end

    return false
end

function EnemyManager.damageEnemyAlongLine(damage, segStartX, segStartY, segEndX, segEndY)
    for i=#activeIndexes, 1, -1 do
        local enemyIndex <const> = activeIndexes[i]
        if lineIntersectsEnemy(enemyIndex, segStartX, segStartY, segEndX, segEndY) then
            damageEnemy(enemyIndex, damage)
        end
    end
end

-- Initially written by ChatGPT and adapted. Prompt:
-- Rectangles are represented by a point indicating their top left corner, a width, and a height. 
-- Write a function in Lua that takes in a single rectangle and returns if it overlaps with another existing rectangle.
-- Instead of taking in a rectangle object, rewrite the function to take in each individual element as separate arguments.
local function rectIntersectsEnemy(index, x1, y1, width1, height1)
    local rect1_right = x1 + width1
    local rect1_bottom = y1 + height1

    local x2, y2 = enemyX[index], enemyY[index]
    local width2, height2 = enemyHeight[index], enemyWidth[index]

    local rect2_right = x2 + width2
    local rect2_bottom = y2 + height2

    if x1 < rect2_right and
       rect1_right > x2 and
       y1 < rect2_bottom and
       rect1_bottom > y2 then
      return true -- The rectangles overlap
    else
      return false -- The rectangles do not overlap
    end
end

function EnemyManager.damageEnemyInRect(damage, x, y, width, height)
    for i=#activeIndexes, 1, -1 do
        local enemyIndex <const> = activeIndexes[i]
        if rectIntersectsEnemy(enemyIndex, x, y, width, height) then
            damageEnemy(enemyIndex, damage)
        end
    end
end

local damageEnemyInRect = enemyManager.damageEnemyInRect
function EnemyManager.damageEnemyInRectCentered(damage, x, y, width, height)
    local halfWidth, halfHeight = width/2, height/2
    damageEnemyInRect(damage, x - halfWidth, y - halfHeight, width, height)
end

-- Enemy Object:
--  health
--  image
--  attackFunction(index, playerX, playerY, isInit) [optional]
--  moveFunction(dt, index, playerX, playerY)
function EnemyManager.spawnEnemy(enemy, x, y)
    if #activeIndexes >= maxEnemyCount then
        return
    end

    local drawTime = 1.0
    local halfTime = drawTime / 2
    local width, height = enemy.imagetable[1]:getSize()
    local centerX, centerY = x + width/2, y + height/2
    addDraw(drawTime, function(time)
        local radius = width * 1.5
        if time <= halfTime then
            local drawRadius = radius * easeOutCubic(time / halfTime)
            if drawRadius >= 2 then
                gfx.setColor(gfx.kColorBlack)
                gfx.fillCircleAtPoint(centerX, centerY, drawRadius)
                gfx.setColor(gfx.kColorWhite)
                gfx.fillCircleAtPoint(centerX, centerY, drawRadius - 2)
            end
        else
            local drawRadius = radius - radius * easeInCubic((time - halfTime) / halfTime)
            if drawRadius >= 2 then
                gfx.setColor(gfx.kColorBlack)
                gfx.fillCircleAtPoint(centerX, centerY, drawRadius)
                gfx.setColor(gfx.kColorWhite)
                gfx.fillCircleAtPoint(centerX, centerY, drawRadius - 2)
            end
        end
    end)
    addTimer(halfTime, function()
        enemyManager.initializeEnemy(enemy, x, y)
    end)
end

function EnemyManager.initializeEnemy(enemy, x, y)
    local enemyIndex <const> = queue.pop(availableIndexes)
    table.insert(activeIndexes, enemyIndex)

    enemyHealth[enemyIndex] = enemy.health
    enemyX[enemyIndex] = x
    enemyY[enemyIndex] = y
    enemyAttackFunction[enemyIndex] = enemy.attackFunction
    enemyMoveState[enemyIndex] = 0
    enemyMovementFunction[enemyIndex] = enemy.moveFunction

    local imagetable = enemy.imagetable
    enemyImagetable[enemyIndex] = imagetable
    local frameTime = enemy.frameTime
    enemyFrameTime[enemyIndex] = frameTime
    enemyFrameTimeCounter[enemyIndex] = math.random()
    local image = imagetable[1]
    enemyWidth[enemyIndex], enemyHeight[enemyIndex] = image:getSize()

    enemyCollisionDamage[enemyIndex] = enemy.collisionDamage
    enemyCollisionTimer[enemyIndex] = maxCollisionTime

    flashTimer[enemyIndex] = 0

    enemy.moveFunction(enemyIndex, player.x, player.y)
    if enemy.attackFunction then
        enemy.attackFunction(enemyIndex, player.x, player.y, true)
    end
end