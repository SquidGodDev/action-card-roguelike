local pd <const> = playdate
local gfx <const> = pd.graphics

local refreshRate <const> = pd.display.getRefreshRate()
local ringInt <const> = math.ringInt
local clamp <const> = math.clamp
local floor <const> = math.floor
local sqrt <const> = math.sqrt

local drawModeCopy <const> = gfx.kDrawModeCopy
local drawModeFillWhite <const> = gfx.kDrawModeFillWhite
local setDrawMode <const> = gfx.setImageDrawMode

-- Input Constants
local buttonIsPressed <const> = pd.buttonIsPressed
local leftButton <const> = pd.kButtonLeft
local rightButton <const> = pd.kButtonRight
local upButton <const> = pd.kButtonUp
local downButton <const> = pd.kButtonDown

local basicAttackImage = {
    [-1] = {
        [-1] = gfx.imagetable.new('assets/images/player/sword/swingUpLeft'),
        [0] = gfx.imagetable.new('assets/images/player/sword/swingLeft'),
        [1] = gfx.imagetable.new('assets/images/player/sword/swingDownLeft')
    },
    [0] = {
        [-1] = gfx.imagetable.new('assets/images/player/sword/swingUp'),
        [1] = gfx.imagetable.new('assets/images/player/sword/swingDown')
    },
    [1] = {
        [-1] = gfx.imagetable.new('assets/images/player/sword/swingUpRight'),
        [0] = gfx.imagetable.new('assets/images/player/sword/swingRight'),
        [1] = gfx.imagetable.new('assets/images/player/sword/swingDownRight')
    },
}

Player = {}
local player = Player

local moveSpeed <const> = 3 * refreshRate
local prevDiagonal = false
local cameraXOffset, cameraYOffset = 0, 0
local idleImagetable <const> = gfx.imagetable.new('assets/images/player/fireHeadIdle')
local idleFrameTime <const> = 0.033
local runImagetable <const> = gfx.imagetable.new('assets/images/player/fireHeadRun')
local runFrameTime <const> = 0.033
local playerImagetable
local frameStart, frameEnd
local frameTime
local frameTimeCounter

local particleManager <const> = ParticleManager
local addParticle = particleManager.addParticle
local dashFadeImagetable = gfx.imagetable.new('assets/images/player/playerFade')
local dashFadeImagetableFlipped = gfx.imagetable.new('assets/images/player/playerFadeFlipped')
local dashFadeFrameTime = 0.05

local uiManager <const> = UIManager

local drawManager = DrawManager
local addDraw = drawManager.addDraw

local animationStates <const> = {
    idle = 1,
    run = 2,
    dash = 3
}
local animationState = animationStates.idle
local flippedX <const> = gfx.kImageFlippedX
local unflipped <const> = gfx.kImageUnflipped
local flip = unflipped

local maxFlashTime <const> = .15
local flashTime = 0

local dashCooldownTimer = 0
local dashTimer = 0
local dashTime <const> = .3
local dashCooldown <const> = .1
local dashSpeed <const> = 16 * refreshRate
local dashSpeedDeceleration <const> = 3 * refreshRate
local dashXVelocity = 0
local dashYVelocity = 0

local lastDirX, lastDirY = 1, 0

local health
local maxHealth

local enemyManager
local gameScene
local minX, minY, maxX, maxY

player.width, player.height = 14, 24
player.widthOffset, player.heightOffset = player.width/2, 4

local function setActiveImagetable(imagetable, _frameTime)
    playerImagetable = imagetable
    frameStart, frameEnd = 1, #imagetable
    frameTime = _frameTime
    frameTimeCounter = 0
    playerImage = imagetable[frameStart]
end

local function switchToIdle()
    animationState = animationStates.idle
    setActiveImagetable(idleImagetable, idleFrameTime)
end

local function switchToRun()
    animationState = animationStates.run
    setActiveImagetable(runImagetable, runFrameTime)
end

local function switchToDash()
    animationState = animationStates.dash
    setActiveImagetable(runImagetable, runFrameTime)
end

function Player.init(_health, _maxHealth)
    player.x, player.y = 200, 120
    player.type = TYPES.player

    health = _health
    maxHealth = _maxHealth
    switchToIdle()

    dashTimer = 0
    dashCooldownTimer = 0

    flashTime = 0

    enemyManager = EnemyManager

    gameScene = GameScene
    minX, maxX = gameScene.minX, gameScene.maxX
    minY, maxY = gameScene.minY, gameScene.maxY
end

function Player.getHealth()
    return health
end

function Player.getMaxHealth()
    return maxHealth
end

function Player.damage(amount)
    if dashTimer > 0 then
        return false
    end

    health -= amount
    if health <= 0 then
        health = 0
        player.die()
    end
    flashTime = maxFlashTime
    gameScene.screenShake()
    uiManager.updateHealth(health)
    return true
end

function Player.die()
    -- Die
end

function Player.basicAttack()
    local damage = 1
    local distance = 40
    local size = 90
    local magnitude = sqrt(lastDirX^2 + lastDirY^2)
    local xDist = distance * lastDirX / magnitude
    local yDist = distance * lastDirY / magnitude
    enemyManager.damageEnemyInRectCentered(damage, player.x + xDist, player.y + yDist, size, size)

    local attackImage = basicAttackImage[lastDirX][lastDirY]
    if attackImage then
        local maxFrame = #attackImage
        local animationTime = 0.5
        addDraw(animationTime, function(time)
            local frame = floor((maxFrame - 1) * (1 - time / animationTime) + 1)
            if frame <= maxFrame then
                attackImage[frame]:drawAnchored(player.x + xDist, player.y + yDist, 0.5, 0.5)
            end
        end)
        -- addParticle(x, y, attackImage, 0.0167)
    end
end

function Player.dash()
    local xDir, yDir = 0, 0
    if buttonIsPressed(leftButton) then
        xDir -= 1
        flip = flippedX
    end
    if buttonIsPressed(rightButton) then
        xDir += 1
        flip = unflipped
    end
    if buttonIsPressed(upButton) then
        yDir -= 1
    end
    if buttonIsPressed(downButton) then
        yDir += 1
    end
    local isIdle = (xDir == 0) and (yDir == 0)
    if dashCooldownTimer > 0 or isIdle then
        return
    end

    local diagonal = (xDir ~= 0) and (yDir ~= 0)
    local normalizedXDir = diagonal and (xDir * 0.7) or xDir
    local normalizedYDir = diagonal and (yDir * 0.7) or yDir

    switchToDash()
    dashCooldownTimer = dashCooldown
    dashTimer = dashTime

    dashXVelocity = normalizedXDir * dashSpeed
    dashYVelocity = normalizedYDir * dashSpeed
end

function Player.update(dt, onlyDraw)
    local x, y = player.x, player.y
    frameTimeCounter += dt
    frameIndex = ringInt(frameStart + floor(frameTimeCounter / frameTime), frameStart, frameEnd)
    playerImage = playerImagetable[frameIndex]
    if flashTime > 0 then
        flashTime -= dt
    end
    if not onlyDraw then
        if dashTimer > 0 then
            dashTimer -= dt
            if dashTimer > 0 then
                if flip == flippedX then
                    addParticle(x, y, dashFadeImagetableFlipped, dashFadeFrameTime)
                else
                    addParticle(x, y, dashFadeImagetable, dashFadeFrameTime)
                end
            end
            x += dashXVelocity * dt
            y += dashYVelocity * dt

            if dashXVelocity > moveSpeed then
                dashXVelocity -= dashSpeedDeceleration
            elseif dashXVelocity < -moveSpeed then
                dashXVelocity += dashSpeedDeceleration
            end

            if dashYVelocity > moveSpeed then
                dashYVelocity -= dashSpeedDeceleration
            elseif dashYVelocity < -moveSpeed then
                dashYVelocity += dashSpeedDeceleration
            end
        else
            local xDir, yDir = 0, 0
            if buttonIsPressed(leftButton) then
                xDir -= 1
                flip = flippedX
            end
            if buttonIsPressed(rightButton) then
                xDir += 1
                flip = unflipped
            end
            if buttonIsPressed(upButton) then
                yDir -= 1
            end
            if buttonIsPressed(downButton) then
                yDir += 1
            end
            if (xDir ~= 0) or (yDir ~= 0) then
                lastDirX, lastDirY = xDir, yDir
            end
            local diagonal = (xDir ~= 0) and (yDir ~= 0)
            if not prevDiagonal and diagonal then
                x = math.floor(x) + .5
                y = math.floor(y) + .5
            end
            prevDiagonal = diagonal
            local normalizedXDir = diagonal and (xDir * 0.7) or xDir
            local normalizedYDir = diagonal and (yDir * 0.7) or yDir
            local xVelocity = normalizedXDir * moveSpeed * dt
            local yVelocity = normalizedYDir * moveSpeed * dt
            if dashCooldownTimer > 0 then
                dashCooldownTimer -= dt
            end

            -- Handle animation state
            local isIdle = (xDir == 0) and (yDir == 0)
            if isIdle and animationState ~= animationStates.idle then
                switchToIdle()
            elseif not isIdle and animationState ~= animationStates.run then
                switchToRun()
            end

            x += xVelocity
            y += yVelocity
        end

        x = clamp(x, minX, maxX)
        y = clamp(y, minY, maxY)

        local lerp = 0.1
        cameraXOffset += (x - cameraXOffset - 200) * lerp
        cameraYOffset += (y - cameraYOffset - 120) * lerp
        gfx.setDrawOffset(-cameraXOffset,-cameraYOffset)
        player.x, player.y = x, y
    end
    if flashTime > 0 then
        setDrawMode(drawModeFillWhite)
        playerImage:drawAnchored(x, y, 0.5, 0.5, flip)
        setDrawMode(drawModeCopy)
    else
        playerImage:drawAnchored(x, y, 0.5, 0.5, flip)
    end
end
