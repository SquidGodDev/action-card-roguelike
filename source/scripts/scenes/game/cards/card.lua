local pd <const> = playdate
local gfx <const> = pd.graphics

local cardBase <const> = gfx.imagetable.new('assets/images/cards/cardBase')

class('Card').extends()

function Card:init(x, y, data)
    -- Data
    self.aimable = data.stats.aimable

    -- Drawing
    self.baseImagetable = self:createCardImagetable(data)
    self.imagetable = self:getCardImagetableWithCost(data.stats.cost)
    self.x, self.y = x, y

    -- Animation
    self.index = math.random(1, #self.imagetable)
    self.frameTime = 6
    self.frameCounter = math.random(0, self.frameTime)
end

function Card:update()
    self.frameCounter += 1
    if self.frameCounter > self.frameTime then
        self.frameCounter = 0
        self.index = math.ringInt(self.index + 1, 1, #self.imagetable)
    end
    self.imagetable[self.index]:drawIgnoringOffset(self.x, self.y)
end

function Card:isAimable()
    return self.aimable
end

function Card:moveTo(x, y)
    self.x, self.y = x, y
end

function Card:getCardImagetableWithCost(cost)
    local cardImagetable = gfx.imagetable.new(#self.baseImagetable)
    for i=1,#cardImagetable do
        local cardImage = self.baseImagetable[i]:copy()
        gfx.pushContext(cardImage)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.drawText(cost, 31, 4)
        gfx.popContext()
        cardImagetable:setImage(i, cardImage)
    end
    return cardImagetable
end

function Card:createCardImagetable(data)
    local spellImagetable = data.imagetable
    local imagetableCount = #spellImagetable
    local cardImagetable = gfx.imagetable.new(imagetableCount)
    for i=1,#spellImagetable do
        local cardImage = cardBase[i]:copy()
        gfx.pushContext(cardImage)
            spellImagetable[i]:draw(15, 24)
        gfx.popContext()
        cardImagetable:setImage(i, cardImage)
    end
    return cardImagetable
end
