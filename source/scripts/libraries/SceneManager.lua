
local pd <const> = playdate
local gfx <const> = playdate.graphics

local transitionTime = 500
local transitionMidFrame = 20

local transitionImagetable = gfx.imagetable.new("assets/images/ui/quickTransition")
local transitionImage = nil

local newScene = nil

SceneManager = {}

local timerUpdate = pd.timer.updateTimers
local spriteUpdate = gfx.sprite.update

function SceneManager.switchScene(scene)
    if transitionImage then
        return
    end

    newScene = scene

    startTransition()
end

function SceneManager.startingScene(scene)
    scene.init()
    setSceneUpdate(scene)
end

function loadNewScene()
    cleanupScene()
    newScene.init()
    setSceneUpdate(newScene)
end

function setSceneUpdate(scene)
    local sceneUpdate = scene.update
    pd.update = function()
        spriteUpdate()
        sceneUpdate()
        if transitionImage then
            transitionImage:draw(0, 0)
        end
        timerUpdate()
    end
end

function cleanupScene()
    gfx.sprite.removeAll()
    gfx.setDrawOffset(0, 0)
    local allTimers = pd.timer.allTimers()
    for _, timer in ipairs(allTimers) do
        timer:remove()
    end
end

function startTransition()
    local transitionTimer = createTransitionTimer(1, transitionMidFrame)

    transitionTimer.timerEndedCallback = function()
        loadNewScene()
        transitionTimer = createTransitionTimer(transitionMidFrame, #transitionImagetable)
        transitionTimer.timerEndedCallback = function()
            transitionImage = nil
        end
    end
end

function createTransitionTimer(startValue, endValue)
    local transitionTimer = pd.timer.new(transitionTime, startValue, endValue)
    transitionTimer.updateCallback = function(timer)
        local transitionFrame = math.min(math.ceil(timer.value), #transitionImagetable)
        transitionImage = transitionImagetable[transitionFrame]
    end
    return transitionTimer
end
