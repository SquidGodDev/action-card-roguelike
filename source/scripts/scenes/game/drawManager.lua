local pd <const> = playdate
local gfx <const> = pd.graphics

DrawManager = {}

local maxDrawCount <const> = 50
local queue <const> = Queue
local availableIndexes = nil
local activeIndexes = nil

local drawFunction <const> = table.create(maxDrawCount, 0)
local drawTime <const> = table.create(maxDrawCount, 0)

function DrawManager.init()
    availableIndexes = queue.new(maxDrawCount)
    for i=1, maxDrawCount do
        queue.push(availableIndexes, i)
    end
    activeIndexes = table.create(maxDrawCount, 0)
end

function DrawManager.update(dt)
    for i=#activeIndexes, 1, -1 do
        local drawIndex <const> = activeIndexes[i]
        local time = drawTime[drawIndex]
        time -= dt
        if time <= 0 then
            table.remove(activeIndexes, i)
            queue.push(availableIndexes, drawIndex)
        end
        drawTime[drawIndex] = time
        drawFunction[drawIndex](time)
    end
end

function DrawManager.addDraw(_drawTime, _drawFunction)
    if #activeIndexes >= maxDrawCount then
        return
    end

    local drawIndex <const> = queue.pop(availableIndexes)
    table.insert(activeIndexes, drawIndex)

    drawFunction[drawIndex] = _drawFunction
    drawTime[drawIndex] = _drawTime
end