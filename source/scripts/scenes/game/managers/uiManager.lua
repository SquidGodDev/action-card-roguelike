local pd <const> = playdate
local gfx <const> = pd.graphics

local newImage <const> = gfx.image.new

UIManager = {}
local uiManager = UIManager

local health = nil
local maxHealth = nil

local heartLeftHalf = newImage('assets/images/ui/leftHalfHeart')
local heartLeftHalfTransparent = newImage('assets/images/ui/leftHalfHeartTransparent')
local heartRightHalf = newImage('assets/images/ui/rightHalfHeart')
local heartRightHalfTransparent = newImage('assets/images/ui/rightHalfHeartTransparent')
local heartBaseX <const>, heartBaseY <const> = 2, 2
local halfHeartGap <const> = heartLeftHalf:getSize()
local heartGap <const> = halfHeartGap + 2

function UIManager.init(_player)
    health = _player.getHealth()
    maxHealth = _player.getMaxHealth()
end

function UIManager.updateHealth(_health)
    health = _health
end

function UIManager.update()
    local heartX = heartBaseX
    for i=1, maxHealth do
        local isLeft = (i % 2 == 1)
        local drawHeart = isLeft and heartLeftHalfTransparent or heartRightHalfTransparent
        if i <= health then
            drawHeart = isLeft and heartLeftHalf or heartRightHalf
        end
        drawHeart:drawIgnoringOffset(heartX, heartBaseY)
        heartX += isLeft and halfHeartGap or heartGap
    end
end
