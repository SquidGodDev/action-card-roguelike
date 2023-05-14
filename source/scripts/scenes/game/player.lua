local pd <const> = playdate
local gfx <const> = pd.graphics

local buttonIsPressed <const> = pd.buttonIsPressed
local leftButton <const> = pd.kButtonLeft
local rightButton <const> = pd.kButtonRight
local upButton <const> = pd.kButtonUp
local downButton <const> = pd.kButtonDown

Player = {}
local player = Player

local moveSpeed = 3 * 30
local prevDiagonal = false
local cameraXOffset, cameraYOffset = 0, 0
local playerImage = gfx.image.new('assets/images/player/player')

local health

player.width, player.height = 14, 24
player.widthOffset, player.heightOffset = player.width/2, 4

function Player.init()
    player.x, player.y = 200, 120
    player.type = TYPES.player

    health = 10000
end

function Player.update(dt, onlyDraw)
    local x, y = player.x, player.y
    if not onlyDraw then
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
        x += xVelocity
        y += yVelocity

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