TimerManager = {}

local maxTimerCount <const> = 50
local queue <const> = Queue
local availableIndexes = nil
local activeIndexes = nil

local timer <const> = table.create(maxTimerCount, 0)
local callback <const> = table.create(maxTimerCount, 0)

function TimerManager.init()
    availableIndexes = queue.new(maxTimerCount)
    for i=1, maxTimerCount do
        queue.push(availableIndexes, i)
    end
    activeIndexes = table.create(maxTimerCount, 0)
end


function TimerManager.update(dt)
    for i=#activeIndexes, 1, -1 do
        local timerIndex <const> = activeIndexes[i]

        local time = timer[timerIndex]
        time -= dt
        if time <= 0 then
            local callbackFunction = callback[timerIndex]
            if callbackFunction then
                callbackFunction()
            end
            table.remove(activeIndexes, i)
            queue.push(availableIndexes, timerIndex)
        else
            timer[timerIndex] = time
        end
    end
end

function TimerManager.addTimer(time, callbackFunction)
    if #activeIndexes >= maxTimerCount then
        return
    end

    local timerIndex <const> = queue.pop(availableIndexes)
    table.insert(activeIndexes, timerIndex)

    timer[timerIndex] = time
    callback[timerIndex] = callbackFunction
end