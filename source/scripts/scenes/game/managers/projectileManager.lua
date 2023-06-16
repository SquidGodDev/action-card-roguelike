local pd <const> = playdate
local gfx <const> = pd.graphics

ProjectileManager = {}

local enemyX
local enemyY
local enemyWidth
local enemyHeight
local getEnemyIndexes
local damageEnemy

local player
local damagePlayer
local playerWidthOffset, playerHeightOffset
local playerWidth, playerHeight
local playerTLX, playerTLY, playerBRX, playerBRY


local minX, maxX, minY, maxY

local function overlapsEnemy(pTLX, pTLY, pBRX, pBRY, enemyIndex)
    local eTLX = enemyX[enemyIndex]
    local eTLY = enemyY[enemyIndex]
    local eBRX = eTLX + enemyWidth[enemyIndex]
    local eBRY = eTLY + enemyHeight[enemyIndex]
    if pTLX > eBRX or eTLX > pBRX then
        -- One rect is to the right of the other
        return false
    elseif pBRY < eTLY or eBRY < pTLY then
        -- One rect is above the other
        return false
    else
        -- Overlap!
        return true
    end
end

local function overlapsPlayer(pTLX, pTLY, pBRX, pBRY)
    if pTLX > playerBRX or playerTLX > pBRX then
        -- One rect is to the right of the other
        return false
    elseif pBRY < playerTLY or playerBRY < pTLY then
        -- One rect is above the other
        return false
    else
        -- Overlap!
        return true
    end
end

-- Projectile List
local maxProjectileCount <const> = 100
local queue <const> = Queue
local availableIndexes = nil
local activeIndexes = nil
local projectileX <const> = table.create(maxProjectileCount, 0)
local projectileY <const> = table.create(maxProjectileCount, 0)
local projectileSpeedX <const> = table.create(maxProjectileCount, 0)
local projectileSpeedY <const> = table.create(maxProjectileCount, 0)
local projectileDiameter <const> = table.create(maxProjectileCount, 0)
local projectileDamage <const> = table.create(maxProjectileCount, 0)
local projectileIsPlayer <const> = table.create(maxProjectileCount, 0)

function ProjectileManager.init(_player)
    player = _player
    damagePlayer = player.damage
    playerWidthOffset, playerHeightOffset = player.widthOffset, player.heightOffset
    playerWidth, playerHeight = player.width, player.height

    availableIndexes = queue.new(maxProjectileCount)
    for i=1, maxProjectileCount do
        queue.push(availableIndexes, i)
    end
    activeIndexes = table.create(maxProjectileCount, 0)

    enemyX = EnemyManager.enemyX
    enemyY = EnemyManager.enemyY
    enemyWidth = EnemyManager.enemyWidth
    enemyHeight = EnemyManager.enemyHeight
    getEnemyIndexes = EnemyManager.getActiveIndexes
    damageEnemy = EnemyManager.damageEnemy

    local gameScene = GameScene
    minX, maxX = gameScene.minX, gameScene.maxX
    minY, maxY = gameScene.minY, gameScene.maxY
end

function ProjectileManager.update(dt, onlyDraw)
    if onlyDraw then
        for i=1, #activeIndexes do
            local projectileIndex <const> = activeIndexes[i]
            local x = projectileX[projectileIndex]
            local y = projectileY[projectileIndex]
            local diameter = projectileDiameter[projectileIndex]
            if projectileIsPlayer[projectileIndex] then
                gfx.setColor(gfx.kColorBlack)
                gfx.fillCircleInRect(x, y, diameter, diameter)
                gfx.setColor(gfx.kColorWhite)
                gfx.fillCircleInRect(x + 2, y + 2, diameter - 4, diameter - 4)
            else

            end
        end
    else
        local enemyIndexes = getEnemyIndexes()
        local playerX, playerY = player.x, player.y
        playerTLX = playerX - playerWidthOffset
        playerTLY = playerY - playerHeightOffset
        playerBRX = playerTLX + playerWidth
        playerBRY = playerTLY + playerHeight
        for i=#activeIndexes, 1, -1 do
            local projectileIndex <const> = activeIndexes[i]
            local x = projectileX[projectileIndex] + projectileSpeedX[projectileIndex] * dt
            local y = projectileY[projectileIndex] + projectileSpeedY[projectileIndex] * dt
            projectileX[projectileIndex] = x
            projectileY[projectileIndex] = y
            local diameter = projectileDiameter[projectileIndex]

            if x <= minX or x >= maxX or y <= minY or y >= maxY then
                table.remove(activeIndexes, i)
                queue.push(availableIndexes, projectileIndex)
            else
                local pTLX = x
                local pTLY = y
                local pBRX = x + projectileDiameter[projectileIndex]
                local pBRY = y + projectileDiameter[projectileIndex]
                local damage = projectileDamage[projectileIndex]
                local collided = false
                if projectileIsPlayer[projectileIndex] then
                    for j=#enemyIndexes, 1, -1 do
                        local enemyIndex = enemyIndexes[j]
                        if overlapsEnemy(pTLX, pTLY, pBRX, pBRY, enemyIndex) then
                            damageEnemy(enemyIndex, damage)
                            collided = true
                        end
                    end
                    gfx.setColor(gfx.kColorWhite)
                    gfx.fillCircleInRect(x, y, diameter, diameter)
                    gfx.setColor(gfx.kColorBlack)
                    gfx.fillCircleInRect(x + 2, y + 2, diameter - 4, diameter - 4)
                else
                    -- Handle collision with player
                    if overlapsPlayer(pTLX, pTLY, pBRX, pBRY) then
                        damagePlayer(damage)
                        collided = true
                    end
                    gfx.setColor(gfx.kColorBlack)
                    gfx.fillCircleInRect(x, y, diameter, diameter)
                    gfx.setColor(gfx.kColorWhite)
                    gfx.fillCircleInRect(x + 2, y + 2, diameter - 4, diameter - 4)
                end
                if collided then
                    table.remove(activeIndexes, i)
                    queue.push(availableIndexes, projectileIndex)
                end
            end
        end
    end
end

function ProjectileManager.createProjectile(x, y, xSpeed, ySpeed, diameter, damage, isPlayer)
    if #activeIndexes >= maxProjectileCount then
        return
    end
    local projectileIndex <const> = queue.pop(availableIndexes)
    table.insert(activeIndexes, projectileIndex)
    projectileX[projectileIndex] = x + xSpeed / 15 - diameter / 2
    projectileY[projectileIndex] = y + ySpeed / 15 - diameter / 2
    projectileSpeedX[projectileIndex] = xSpeed
    projectileSpeedY[projectileIndex] = ySpeed
    projectileDiameter[projectileIndex] = diameter
    projectileDamage[projectileIndex] = damage
    projectileIsPlayer[projectileIndex] = isPlayer
end