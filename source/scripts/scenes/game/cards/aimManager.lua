local pd <const> = playdate
local gfx <const> = pd.graphics

local lerp <const> = function(a, b, t)
    return a * (1-t) + b * t
end

class('AimManager').extends()

function AimManager:init(player)
    self.player = player
    self.angle = 0

    self.moveAcceleration = 0.5
    self.maxMoveVelocity = 10
    self.moveVelocity = 0

    self.lerpSpeed = 0.4
end

function AimManager:activate()
    self.angle = pd.getCrankPosition()
end

function AimManager:update()
    local crankChange = pd.getCrankChange()
    if math.abs(crankChange) > 0 then
        self.angle += crankChange
        self.moveVelocity = 0
    else
        if pd.buttonIsPressed(pd.kButtonLeft) or pd.buttonIsPressed(pd.kButtonUp) then
            self:moveAngleLeft()
        elseif pd.buttonIsPressed(pd.kButtonRight) or pd.buttonIsPressed(pd.kButtonDown) then
            self:moveAngleRight()
        else
            self.moveVelocity = 0
        end
    end

    self.drawAngle = self.angle

    local angleInRad = math.rad(self.drawAngle - 90)
    local lineLength = 100
    local x1, y1 = self.player.x, self.player.y
    local x2 = x1 + math.cos(angleInRad) * lineLength
    local y2 = y1 + math.sin(angleInRad) * lineLength
    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(5)
    gfx.setLineCapStyle(gfx.kLineCapStyleRound)
    gfx.drawLine(x1, y1, x2, y2)
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(2)
    gfx.drawLine(x1, y1, x2, y2)
end

function AimManager:moveAngleLeft()
    self.moveVelocity = math.clamp(self.moveVelocity - self.moveAcceleration, -self.maxMoveVelocity, 0)
    self.angle = self.angle + self.moveVelocity
end

function AimManager:moveAngleRight()
    self.moveVelocity = math.clamp(self.moveVelocity + self.moveAcceleration, 0, self.maxMoveVelocity)
    self.angle = self.angle + self.moveVelocity
end

function AimManager:getAngle()
    return self.angle
end