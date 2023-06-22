local pd <const> = playdate
local gfx <const> = pd.graphics

local mathMin = math.min
local mathMax = math.max

function math.clamp(value, min, max)
	if (min > max) then
		min, max = max, min
	end
	return mathMax(min, mathMin(max, value))
end

function math.ring(value, min, max)
	if (min > max) then
		min, max = max, min
	end
	return min + (value - min) % (max - min)
end

local ring = math.ring
function math.ringInt(value, min, max)
	return ring(value, min, max + 1)
end

function math.sign(value)
	return (value >= 0 and 1) or -1
end

-- https://www.lua.org/pil/11.4.html
Queue = {}
function Queue.new(size)
	local queue = table.create(size + 2, 0)
	queue.first = 0
	queue.last = -1
	return queue
end

---@param queue table
---@param value any
function Queue.push(queue, value)
	local last = queue.last + 1
	queue.last = last
	queue[last] = value
end

---@param queue table
---@return any
function Queue.pop(queue)
	local first = queue.first
	if first > queue.last then
		return nil
	end
	local value = queue[first]
	queue[first] = nil -- to allow garbage collection
	queue.first = first + 1
	return value
end

Utilities = {}

function Utilities.createAnimatedSprite(imagetable)
    if type(imagetable) == 'string' then
        imagetable = gfx.imagetable.new(imagetable)
    end
    local sprite = gfx.sprite.new()
    local loopDuration = 6
    sprite.drawLoopCounter = math.random(0, loopDuration - 1)
    sprite.drawLoopDuration = loopDuration
    sprite.drawLoopIndex = math.random(1, #imagetable)
    sprite.imagetable = imagetable
    sprite:setImage(imagetable[sprite.drawLoopIndex])
    sprite.update = function(self)
        self.drawLoopCounter += 1
        if self.drawLoopCounter >= self.drawLoopDuration then
            self.drawLoopCounter = 1
            self.drawLoopIndex = (self.drawLoopIndex % #self.imagetable) + 1
            self:setImage(self.imagetable[self.drawLoopIndex])
        end
    end
    return sprite
end

function Utilities.animateSprite(sprite, imagetable)
    if type(imagetable) == 'string' then
        imagetable = gfx.imagetable.new(imagetable)
    end
    sprite:setImage(imagetable[1])
    local loopDuration = 5
    local animateTimer = pd.frameTimer.new(loopDuration)
    animateTimer.repeats = true
    local repeatFrame = math.random(0, loopDuration)
    local imagetableIndex = math.random(1, #imagetable)
    animateTimer.updateCallback = function(timer)
        if timer.frame == repeatFrame then
            imagetableIndex = (imagetableIndex % #imagetable) + 1
            sprite:setImage(imagetable[imagetableIndex])
        end
    end
end

local particleCache = {}

function Utilities.particle(x, y, imagetablePath, frameTime, repeats, noRemove)
    local imagetable = particleCache[imagetablePath]
    if not imagetable then
        imagetable = gfx.imagetable.new(imagetablePath)
        particleCache[imagetablePath] = imagetable
    end
    assert(imagetable)
    local particle = gfx.sprite.new()
    particle:setImage(imagetable[1])
    particle:moveTo(x, y)
    particle:add()
    particle.animationLoop = gfx.animation.loop.new(frameTime, imagetable, repeats)
    particle.update = function(self)
        self:setImage(self.animationLoop:image())
        if not self.animationLoop:isValid() and not noRemove then
            self:remove()
        end
    end
    return particle
end