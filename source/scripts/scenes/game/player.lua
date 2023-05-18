local pd <const> = playdate
local gfx <const> = pd.graphics

local refreshRate <const> = pd.display.getRefreshRate()
local ringInt <const> = math.ringInt

-- Input Constants
local buttonIsPressed <const> = pd.buttonIsPressed
local buttonJustPressed <const> = pd.buttonJustPressed
local leftButton <const> = pd.kButtonLeft
local rightButton <const> = pd.kButtonRight
local upButton <const> = pd.kButtonUp
local downButton <const> = pd.kButtonDown
local bButton <const> = pd.kButtonB

Player = {}
local player = Player

local moveSpeed <const> = 3 * refreshRate
local prevDiagonal = false
local cameraXOffset, cameraYOffset = 0, 0
local playerImagetable <const> = gfx.imagetable.new('assets/images/player/player')
local playerImage = playerImagetable[1]
local frameStart, frameEnd
local frameIndex
local frameTime
local frameTimeCounter
local idleFrameStart <const>, idleFrameEnd <const> = 1, 2
local idleFrameTime <const> = .3 -- 300ms
local runFrameStart <const>, runFrameEnd <const> = 3, 7
local runFrameTime <const> = .15 -- 150ms

local particleManager <const> = ParticleManager
local dashFadeImagetable = gfx.imagetable.new('assets/images/player/playerFade')
local dashFadeImagetableFlipped = gfx.imagetable.new('assets/images/player/playerFadeFlipped')
local dashFadeFrameTime = 0.05
local dashFadeImageCount = 5

local animationStates <const> = {
    idle = 1,
    run = 2,
    dash = 3
}
local animationState = animationStates.idle
local flippedX <const> = gfx.kImageFlippedX
local unflipped <const> = gfx.kImageUnflipped
local flip = unflipped

local dashCooldownTimer = 0
local dashTimer = 0
local dashTime <const> = .3
local dashCooldown <const> = .1
local dashSpeed <const> = 16 * refreshRate
local dashSpeedDeceleration <const> = 3 * refreshRate
local dashXVelocity = 0
local dashYVelocity = 0

local health

player.width, player.height = 14, 24
player.widthOffset, player.heightOffset = player.width/2, 4

local function switchToIdle()
    animationState = animationStates.idle
    frameStart, frameEnd = idleFrameStart, idleFrameEnd
    frameIndex = frameStart
    frameTime = idleFrameTime
    frameTimeCounter = frameTime
    playerImage = playerImagetable[frameIndex]
end

local function switchToRun()
    animationState = animationStates.run
    frameStart, frameEnd = runFrameStart, runFrameEnd
    frameIndex = frameStart
    frameTime = runFrameTime
    frameTimeCounter = frameTime
    playerImage = playerImagetable[frameIndex]
end

local function switchToDash()
    animationState = animationStates.dash
    frameStart, frameEnd = runFrameStart, runFrameEnd
    frameIndex = frameStart
    frameTime = runFrameTime
    frameTimeCounter = frameTime
    playerImage = playerImagetable[frameIndex]
end

function Player.init()
    player.x, player.y = 200, 120
    player.type = TYPES.player

    health = 10000
    switchToIdle()

    dashTimer = 0
    dashCooldownTimer = 0
end

function Player.update(dt, onlyDraw)
    local x, y = player.x, player.y
    frameTimeCounter -= dt
    if frameTimeCounter <= 0 then
        frameIndex = ringInt(frameIndex + 1, frameStart, frameEnd)
        frameTimeCounter = frameTime
        playerImage = playerImagetable[frameIndex]
    end
    if not onlyDraw then
        if dashTimer > 0 then
            dashTimer -= dt
            if dashTimer > 0 then
                if flip == flippedX then
                    particleManager.addParticle(x, y, dashFadeImagetableFlipped, dashFadeFrameTime)
                else
                    particleManager.addParticle(x, y, dashFadeImagetable, dashFadeFrameTime)
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
            if buttonIsPressed(leftButton)  then
                xDir -= 1
                flip = flippedX
            end
            if buttonIsPressed(rightButton) then
                xDir += 1
                flip = unflipped
            end
            if buttonIsPressed(upButton)    then yDir -= 1 end
            if buttonIsPressed(downButton)  then yDir += 1 end
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

            -- Handle dash
            if buttonJustPressed(bButton) and dashCooldownTimer <= 0 and not isIdle then
                switchToDash()
                dashCooldownTimer = dashCooldown
                dashTimer = dashTime

                dashXVelocity = normalizedXDir * dashSpeed
                dashYVelocity = normalizedYDir * dashSpeed
                xVelocity = dashXVelocity * dt
                yVelocity = dashYVelocity * dt
            end
            x += xVelocity
            y += yVelocity
        end

        local lerp = 0.1
        cameraXOffset += (x - cameraXOffset - 200) * lerp
        cameraYOffset += (y - cameraYOffset - 120) * lerp
        gfx.setDrawOffset(-cameraXOffset,-cameraYOffset)
        player.x, player.y = x, y
    end
    playerImage:drawAnchored(x, y, 0.5, 0.5, flip)
end

function player.damage(amount)
    health -= amount
end