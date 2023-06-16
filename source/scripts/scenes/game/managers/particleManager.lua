local pd <const> = playdate
local gfx <const> = pd.graphics

local floor <const> = math.floor
local drawAnchored = gfx.image.drawAnchored

ParticleManager = {}

local maxParticleCount <const> = 50
local queue <const> = Queue
local availableIndexes = nil
local activeIndexes = nil

local particleX <const> = table.create(maxParticleCount, 0)
local particleY <const> = table.create(maxParticleCount, 0)
local particleImagetable <const> = table.create(maxParticleCount, 0)
local particleFrameTime <const> = table.create(maxParticleCount, 0)
local particleFrameTimeCounter <const> = table.create(maxParticleCount, 0)

function ParticleManager.init()
    availableIndexes = queue.new(maxParticleCount)
    for i=1, maxParticleCount do
        queue.push(availableIndexes, i)
    end
    activeIndexes = table.create(maxParticleCount, 0)
end

function ParticleManager.update(dt)
    for i=#activeIndexes, 1, -1 do
        local particleIndex <const> = activeIndexes[i]

        local frameTimeCounter = particleFrameTimeCounter[particleIndex]
        frameTimeCounter += dt
        local frameTime = particleFrameTime[particleIndex]
        local frame = floor(frameTimeCounter / frameTime) + 1
        local imagetable = particleImagetable[particleIndex]
        if frame > #imagetable then
            table.remove(activeIndexes, i)
            queue.push(availableIndexes, particleIndex)
        else
            particleFrameTimeCounter[particleIndex] = frameTimeCounter
            local x, y = particleX[particleIndex], particleY[particleIndex]
            local particleImage = imagetable[frame]
            drawAnchored(particleImage, x, y, 0.5, 0.5)
        end
    end
end

function ParticleManager.addParticle(x, y, imagetable, frameTime)
    if #activeIndexes >= maxParticleCount then
        return
    end

    local particleIndex <const> = queue.pop(availableIndexes)
    table.insert(activeIndexes, particleIndex)

    particleX[particleIndex] = x
    particleY[particleIndex] = y
    particleImagetable[particleIndex] = imagetable
    particleFrameTime[particleIndex] = frameTime
    particleFrameTimeCounter[particleIndex] = 0
end