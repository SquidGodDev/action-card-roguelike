local pd <const> = playdate
local gfx <const> = pd.graphics

UIManager = {}
local uiManager = UIManager

local health = nil
local maxHealth = nil
local hand = nil

local drawTime
local drawTimeCounter
local manaTime
local manaTimeCounter

local heartLeftHalf = gfx.image.new('assets/images/ui/leftHalfHeart')
local heartLeftHalfTransparent = gfx.image.new('assets/images/ui/leftHalfHeartTransparent')
local heartRightHalf = gfx.image.new('assets/images/ui/rightHalfHeart')
local heartRightHalfTransparent = gfx.image.new('assets/images/ui/rightHalfHeartTransparent')
local heartBaseX, heartBaseY = 2, 2
local halfHeartGap = heartLeftHalf:getSize()
local heartGap = halfHeartGap + 2

function UIManager.init(_player, _hand, _drawTime, _manaTime)
    health = _player.getHealth()
    maxHealth = _player.getMaxHealth()
    hand = _hand
    drawTime = _drawTime
    drawTimeCounter = _drawTime
    manaTime = _manaTime
    manaTimeCounter = _manaTime
end

function UIManager.updateHealth(_health)
    health = _health
end

function UIManager.update(dt, update)
    local handIsFull = hand:isFull()
    local manaIsFull = hand:manaIsFull()
    if update then
        if not handIsFull then
            drawTimeCounter -= dt
            if drawTimeCounter <= 0 then
                hand:drawCard()
                drawTimeCounter = drawTime
            end
        end
        if not manaIsFull then
            manaTimeCounter -= dt
            if manaTimeCounter <= 0 then
                hand:addMana(1)
                manaTimeCounter = manaTime
            end
        end
    end

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
