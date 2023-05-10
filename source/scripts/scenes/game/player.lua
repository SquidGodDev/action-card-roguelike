local pd <const> = playdate
local gfx <const> = pd.graphics

local x, y = 200, 120
local moveSpeed = 3 * 30
local xDir, yDir = 0, 0
local prevDiagonal = false
local cameraXOffset, cameraYOffset = 0, 0
local playerImage = gfx.image.new('assets/images/player/player')

Player = {}

function Player.init()
    x, y = 200, 120

    local playerInputHandlers = {
        leftButtonDown = function() xDir -= 1 end,
        leftButtonUp = function() xDir += 1 end,
        rightButtonDown = function() xDir += 1 end,
        rightButtonUp = function() xDir -= 1 end,
        upButtonDown = function() yDir -= 1 end,
        upButtonUp = function() yDir += 1 end,
        downButtonDown = function() yDir += 1 end,
        downButtonUp = function() yDir -= 1 end,
    }
    pd.inputHandlers.push(playerInputHandlers)
end

function Player.update(dt)
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
    x += xVelocity
    y += yVelocity

    local lerp = 0.1
    cameraXOffset += (x - cameraXOffset - 200) * lerp
    cameraYOffset += (y - cameraYOffset - 120) * lerp
    gfx.setDrawOffset(-cameraXOffset,-cameraYOffset)

    playerImage:drawAnchored(x, y, 0.5, 0.5)
end
