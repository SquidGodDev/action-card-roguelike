local pd <const> = playdate
local gfx <const> = pd.graphics

local newImage <const> = gfx.image.new

local outlinedFont <const> = gfx.font.new('assets/fonts/WhackyJoeMonospaced-12-Outlined')

UIManager = {}
local uiManager = UIManager

local health = nil
local maxHealth = nil
local hand = nil

local drawTime
local drawTimeCounter
local manaTime
local manaTimeCounter

local heartLeftHalf = newImage('assets/images/ui/leftHalfHeart')
local heartLeftHalfTransparent = newImage('assets/images/ui/leftHalfHeartTransparent')
local heartRightHalf = newImage('assets/images/ui/rightHalfHeart')
local heartRightHalfTransparent = newImage('assets/images/ui/rightHalfHeartTransparent')
local heartBaseX <const>, heartBaseY <const> = 2, 2
local halfHeartGap <const> = heartLeftHalf:getSize()
local heartGap <const> = halfHeartGap + 2

local manaIcon = newImage('assets/images/ui/manaIcon')
local manaIconTransparent = newImage('assets/images/ui/manaIconTransparent')
local manaIconMask = newImage('assets/images/ui/manaIconMask')
local manaX <const>, manaY <const> = 12, 35
local manaWidth <const>, manaHeight <const> = manaIcon:getSize()
local manaTextX <const>, manaTextY <const> = 44, 32

local cardsIcon = newImage('assets/images/ui/cardsIcon')
local cardsIconTransparent = newImage('assets/images/ui/cardsIconTransparent')
local cardsIconMask = newImage('assets/images/ui/cardsIconMask')
local cardsX <const>, cardsY <const> = 3, 64
local cardsWidth <const>, cardsHeight <const> = cardsIcon:getSize()
local cardsTextX <const>, cardsTextY <const> = 44, 61

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
            -- drawTimeCounter -= dt
            -- if drawTimeCounter <= 0 then
            --     hand:drawCard()
            --     drawTimeCounter = drawTime
            -- end
        else
            drawTimeCounter = drawTime
        end
        if not manaIsFull then
            manaTimeCounter -= dt
            if manaTimeCounter <= 0 then
                hand:addMana(1)
                manaTimeCounter = manaTime
            end
        else
            manaTimeCounter = manaTime
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

    manaIconTransparent:drawIgnoringOffset(manaX, manaY)
    local manaMask = manaIconMask:copy()
    gfx.setColor(gfx.kColorBlack)
    if manaTimeCounter ~= manaTime then
        gfx.pushContext(manaMask)
            gfx.fillRect(0, 0, manaWidth, (manaTimeCounter / manaTime) * manaHeight)
        gfx.popContext()
    end
    manaIcon:setMaskImage(manaMask)
    manaIcon:drawIgnoringOffset(manaX, manaY)

    -- cardsIconTransparent:drawIgnoringOffset(cardsX, cardsY)
    -- local cardsMask = cardsIconMask:copy()
    -- if drawTimeCounter ~= drawTime then
    --     gfx.pushContext(cardsMask)
    --         gfx.fillRect(0, 0, cardsWidth, (drawTimeCounter / drawTime) * cardsHeight)
    --     gfx.popContext()
    -- end
    -- cardsIcon:setMaskImage(cardsMask)
    -- cardsIcon:drawIgnoringOffset(cardsX, cardsY)

    gfx.unlockFocus()
    gfx.setColor(gfx.kColorWhite)

    local drawOffsetX, drawOffsetY = gfx.getDrawOffset()
    local mana = hand:getMana()
    local maxMana = hand:getMaxMana()
    outlinedFont:drawText(mana .. '/' .. maxMana, manaTextX - drawOffsetX, manaTextY - drawOffsetY)

    -- local handSize = hand:getHandSize()
    -- local maxHandSize = hand:getMaxHandSize()
    -- outlinedFont:drawText(handSize .. '/' .. maxHandSize, cardsTextX - drawOffsetX, cardsTextY - drawOffsetY)
end
