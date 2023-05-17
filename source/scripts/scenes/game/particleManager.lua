local pd <const> = playdate
local gfx <const> = pd.graphics

ParticleManager = {}

local maxParticleCount <const> = 50
local queue <const> = Queue
local availableIndexes = nil
local activeIndexes = nil

local particleX <const> = table.create(maxParticleCount, 0)
local particleY <const> = table.create(maxParticleCount, 0)
local particleImage <const> = table.create(maxParticleCount, 0)
local particleImagetable <const> = table.create(maxParticleCount, 0)
local particleDrawIndex <const> = table.create(maxParticleCount, 0)
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
        frameTimeCounter -= dt
        if frameTimeCounter <= 0 then
            local imagetable = particleImagetable[particleIndex]
            local drawIndex = particleDrawIndex[particleIndex]
            drawIndex = drawIndex + 1
            if drawIndex >= #imagetable then
                table.remove(activeIndexes, i)
                queue.push(availableIndexes, particleIndex)
            else
                particleDrawIndex[particleIndex] = drawIndex
                particleImage[particleIndex] = imagetable[drawIndex]
                particleFrameTimeCounter[particleIndex] = particleFrameTime[particleIndex]
            end
        else
            particleFrameTimeCounter[particleIndex] = frameTimeCounter
        end

        local x, y = particleX[particleIndex], particleY[particleIndex]
        particleImage[particleIndex]:drawAnchored(x, y, 0.5, 0.5)
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
    particleImage[particleIndex] = imagetable[1]
    particleDrawIndex[particleIndex] = 1
    particleFrameTime[particleIndex] = frameTime
    particleFrameTimeCounter[particleIndex] = frameTime
end