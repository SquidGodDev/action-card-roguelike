
local pd <const> = playdate
local gfx <const> = playdate.graphics

local transitionTime = 500
local transitionMidFrame = 20

local transitionImagetable = gfx.imagetable.new('assets/images/ui/quickTransition')
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

-- takes in a scene object that has an 'update' property set
-- to an update function and switches out the entire playdate
-- update function. Sprites get updated first, so it doesn't
-- clear other drawn elements, then the transition image gets
-- drawn to make sure it gets drawn over everything else. Timers
-- get updated here too, and since all those elements need to
-- get updated, just do it here so it doesn't need to be repeated
-- in every scene update
function setSceneUpdate(scene)
    local sceneUpdate = scene.update
    local drawFps = DRAW_FPS
    pd.update = function()
        spriteUpdate()
        sceneUpdate()
        timerUpdate()
        if drawFps then
            pd.drawFPS(0, 228)
        end
        if transitionImage then
            transitionImage:drawIgnoringOffset(0, 0)
        end
    end
end

-- scene cleanup involves removing all sprites, resetting the draw offset, and removing all timers
function cleanupScene()
    gfx.sprite.removeAll()
    gfx.setDrawOffset(0, 0)
    local allTimers = pd.timer.allTimers()
    for _, timer in ipairs(allTimers) do
        timer:remove()
    end
end

-- a couple helper functions to help with handling the transition drawing
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
