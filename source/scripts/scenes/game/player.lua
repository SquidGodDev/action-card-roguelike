local pd <const> = playdate
local gfx <const> = pd.graphics

local refreshRate <const> = pd.display.getRefreshRate()

local performAfterDelay <const> = pd.timer.performAfterDelay
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
local playerImage = gfx.image.new('assets/images/player/player')

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

function Player.init()
    player.x, player.y = 200, 120
    player.type = TYPES.player

    health = 10000

    dashTimer = 0
    dashCooldownTimer = 0
end

function Player.update(dt, onlyDraw)
    local x, y = player.x, player.y
    if not onlyDraw then
        if dashTimer > 0 then
            dashTimer -= dt
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
            if buttonIsPressed(leftButton)  then xDir -= 1 end
            if buttonIsPressed(rightButton) then xDir += 1 end
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
            if buttonJustPressed(bButton) and dashCooldownTimer <= 0 then
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
    playerImage:drawAnchored(x, y, 0.5, 0.5)
end

function player.damage(amount)
    health -= amount
end