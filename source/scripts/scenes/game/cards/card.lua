local pd <const> = playdate
local gfx <const> = pd.graphics

class('Card').extends()

function Card:init(x, y, data)
    -- Data
    self.aimable = data.stats.aimable
    self.castFunction = data.cast
    self.cooldown = data.stats.cooldown
    self.curCooldown = 0
    self.data = data

    -- Drawing
    self.imagetable = data.imagetable
    self.x, self.y = x, y
    local cardWidth, cardHeight = self.imagetable[1]:getSize()
    self.timerYOffset = 15
    self.timerXOffset = 1
    self.timerWidth = cardWidth
    self.timerHeight = 10

    -- Animation
    self.index = math.random(1, #self.imagetable)
    self.frameTime = 6
    self.frameCounter = math.random(0, self.frameTime)
end

function Card:update(dt, draw)
    if draw then
        self.frameCounter += 1
        if self.frameCounter > self.frameTime then
            self.frameCounter = 0
            self.index = math.ringInt(self.index + 1, 1, #self.imagetable)
        end
        self.imagetable[self.index]:drawIgnoringOffset(self.x, self.y)
    end
    if self.curCooldown > 0 then
        self.curCooldown -= dt
        if self.curCooldown < 0 then
            self.curCooldown = 0
        end
    end
    gfx.pushContext()
        local drawRadius = 4
        local offsetX, offsetY = gfx.getDrawOffset()
        local timerX, timerY = self.x - self.timerXOffset - offsetX, self.y - self.timerYOffset - offsetY
        if self.curCooldown <= 0 then
            gfx.setColor(gfx.kColorWhite)
        else
            gfx.setColor(gfx.kColorBlack)
        end
        gfx.fillRoundRect(timerX, timerY, self.timerWidth, self.timerHeight, drawRadius)
        gfx.setColor(gfx.kColorWhite)
        local innerPadding = 2
        local fillWidth = (self.timerWidth - innerPadding * 2) * (1 - self.curCooldown / self.cooldown)
        local fillHeight = self.timerHeight - innerPadding * 2
        gfx.fillRoundRect(timerX + innerPadding, timerY + innerPadding, fillWidth, fillHeight, drawRadius)
    gfx.popContext()
end

function Card:cast(x, y, angle, player)
    if self.curCooldown > 0 then
        return
    end
    self.curCooldown = self.cooldown
    self.castFunction(x, y, angle, self.data, player)
end

function Card:isOnCooldown()
    return self.curCooldown > 0
end

function Card:resetCooldown()
    self.curCooldown = 0
end

function Card:isAimable()
    return self.aimable
end

function Card:moveTo(x, y)
    self.x, self.y = x, y
end
