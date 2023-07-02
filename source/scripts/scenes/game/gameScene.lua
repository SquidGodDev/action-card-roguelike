-- Constants
local pd <const> = playdate
local gfx <const> = pd.graphics
local getCurTimeMil = pd.getCurrentTimeMilliseconds
local previous_time = nil

local floor = math.floor
local random = math.random
local cos = math.cos
local sin = math.sin

local buttonJustPressed <const> = pd.buttonJustPressed
local bButton <const> = pd.kButtonB
local aButton <const> = pd.kButtonA

local lerp <const> = function(a, b, t)
    if a == b then
        return a
    end
    return a * (1-t) + b * t
end

-- Libraries
local sceneManager = SceneManager

local gameData = GameData

local player = Player
local playerUpdate = player.update
local enemyManager = EnemyManager
local enemyUpdate = enemyManager.update
local projectileManager = ProjectileManager
local projectileUpdate = projectileManager.update
local aimManager
local particleManager = ParticleManager
local particleUpdate = particleManager.update
local uiManager = UIManager
local uiUpdate = uiManager.update
local drawManager = DrawManager
local drawUpdate = drawManager.update
local timerManager = TimerManager
local timerManagerUpdate = timerManager.update
local levelManager

local hand
local STATES <const> = {
    moving = 1,
    selecting = 2,
    aiming = 3,
    transitioning = 4
}
local state = STATES.moving
local deltaTimeMultiplier = 1
local slowedTimeMultiplier <const> = 0 -- 0.05
local timeLerpRate = 0.2

local leftWallImage = gfx.image.new('assets/images/environment/leftWall')
local rightWallImage = gfx.image.new('assets/images/environment/rightWall')
local topWallImage = gfx.image.new('assets/images/environment/topWall')
local bottomWallImage = gfx.image.new('assets/images/environment/bottomWall')
local leftWallSprite = gfx.sprite.new(leftWallImage)
local rightWallSprite = gfx.sprite.new(rightWallImage)
local topWallSprite = gfx.sprite.new(topWallImage)
local bottomWallSprite = gfx.sprite.new(bottomWallImage)
leftWallSprite:setCenter(0, 0)
rightWallSprite:setCenter(0, 0)
topWallSprite:setCenter(0, 0)
bottomWallSprite:setCenter(0, 0)
leftWallSprite:moveTo(-400, -224)
rightWallSprite:moveTo(784, -224)
topWallSprite:moveTo(-400, -240)
bottomWallSprite:moveTo(-400, 464)
local walls = {
    leftWallSprite,
    rightWallSprite,
    topWallSprite,
    bottomWallSprite
}

local minX, maxX = -100, 500
local minY, maxY = -60, 300
local setLineWidth = gfx.setLineWidth
local drawLine = gfx.drawLine

local background = gfx.image.new(400, 240, gfx.kColorBlack)

local setDisplayOffset = pd.display.setOffset
local shakeTimer

GameScene = {}
local gameScene = GameScene

function GameScene.init()
    -- Environment
    background:draw(0, 0)
    gfx.setBackgroundColor(gfx.kColorBlack)

    gameScene.minX, gameScene.maxX = minX, maxX
    gameScene.minY, gameScene.maxY = minY, maxY

    -- for _, wall in ipairs(walls) do
    --     wall:add()
    -- end

    -- Screen Shake
    shakeTimer = pd.timer.new(500, 5, 0)
    shakeTimer:pause()
    shakeTimer.timerEndedCallback = function(timer)
        setDisplayOffset(0, 0)
        timer:reset()
        timer:pause()
    end
    shakeTimer.updateCallback = function(timer)
        local shakeAmount = timer.value
        local shakeAngle = random()*3.14*2;
        shakeX = floor(cos(shakeAngle)*shakeAmount);
        shakeY = floor(sin(shakeAngle)*shakeAmount);
        setDisplayOffset(shakeX, shakeY)
    end
    shakeTimer.discardOnCompletion = false

    -- Game state
    player.init(gameData.playerHealth, gameData.playerMaxHealth)
    state = STATES.moving
    projectileManager.init(player)
    aimManager = AimManager(player)
    particleManager.init()
    drawManager.init()
    timerManager.init()

    -- Enemies
    enemyManager.init(player)

    -- Level
    levelManager = LevelManager(gameScene, enemyManager)

    -- Spawn all at once
    levelManager:spawnRoomEnemies()

    -- Deck
    -- ===== Temp values =====
    -- =======================
    local deck = {CARDS.detonate}
    local maxMana = 5
    hand = Hand(deck, gameScene, player, maxMana)

    -- UI
    uiManager.init(player)
end

function GameScene.update()
    -- Calculate delta time
    local dt = 0.033
	local current_time <const> = getCurTimeMil()
	if previous_time ~= nil then
		dt = (current_time - previous_time) / 1000.0
	end
	previous_time = current_time

    -- Draw walls
    gfx.pushContext()
        setLineWidth(4)
        gfx.setColor(gfx.kColorWhite)
        drawLine(minX, minY, minX, maxY) -- Left wall
        drawLine(maxX, minY, maxX, maxY) -- Right wall
        drawLine(minX, minY, maxX, minY) -- Top wall
        drawLine(minX, maxY, maxX, maxY) -- Bottom wall
    gfx.popContext()

    if state == STATES.moving then
        deltaTimeMultiplier = lerp(deltaTimeMultiplier, 1, timeLerpRate)
        local deltaTime <const> = dt * deltaTimeMultiplier

        -- Update timers
        timerManagerUpdate(deltaTime)

        -- Update enemies
        enemyUpdate(deltaTime)

        -- Update draw
        drawUpdate(deltaTime)

        -- Update particles
        particleUpdate(deltaTime)

        -- Update player
        playerUpdate(deltaTime)

        -- Update projectiles
        projectileUpdate(deltaTime)

        -- Update UI
        uiUpdate()

        -- Update hand
        hand:update(deltaTime, true)

        if buttonJustPressed(aButton) then
            gameScene.revealHand()
        end

        if buttonJustPressed(bButton) then
            player.dash()
        end
    elseif state == STATES.selecting then
        deltaTimeMultiplier = lerp(deltaTimeMultiplier, slowedTimeMultiplier, timeLerpRate)
        local deltaTime <const> = dt * deltaTimeMultiplier

        -- Update timers
        timerManagerUpdate(deltaTime)

        -- Update enemies
        enemyUpdate(deltaTime)

        -- Update particles
        particleUpdate(deltaTime)

        -- Update draw
        drawUpdate(deltaTime)

        -- Draw player
        playerUpdate(deltaTime, true)

        -- Update projectiles
        projectileUpdate(deltaTime)

        -- Update UI
        uiUpdate()

        local crankTicks = pd.getCrankTicks(8)
        if      pd.buttonJustPressed(pd.kButtonLeft) or crankTicks == -1 then hand:selectCardLeft()
        elseif  pd.buttonJustPressed(pd.kButtonRight) or crankTicks == 1 then hand:selectCardRight()
        elseif  pd.buttonJustPressed(pd.kButtonB) or pd.buttonJustPressed(pd.kButtonDown) then hand:dismissHand()
        elseif  pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonUp) then hand:selectCard() end

        -- Update hand
        hand:update(deltaTime, true)
    elseif state == STATES.aiming then
        deltaTimeMultiplier = lerp(deltaTimeMultiplier, slowedTimeMultiplier, timeLerpRate)
        local deltaTime <const> = dt * deltaTimeMultiplier

        -- Update timers
        timerManagerUpdate(deltaTime)

        -- Update enemies
        enemyUpdate(deltaTime)

        -- Handle aiming
        aimManager:update()

        -- Update draw
        drawUpdate(deltaTime)

        -- Update particles
        particleUpdate(deltaTime)

        -- Draw player
        playerUpdate(deltaTime, true)

        -- Update projectiles
        projectileUpdate(deltaTime)

        -- Update hand
        hand:update(deltaTime, true)

        if pd.buttonJustPressed(pd.kButtonA) then
            hand:playCard(aimManager:getAngle())
            gameScene.switchToMoving()
        elseif pd.buttonJustPressed(pd.kButtonB) then
            gameScene.revealHand()
        end
    elseif state == STATES.transitioning then
        deltaTimeMultiplier = lerp(deltaTimeMultiplier, 1, timeLerpRate)
        local deltaTime <const> = dt * deltaTimeMultiplier

        -- Update timers
        timerManagerUpdate(deltaTime)

        -- Update enemies
        enemyUpdate(deltaTime)

        -- Update draw
        drawUpdate(deltaTime)

        -- Update particles
        particleUpdate(deltaTime)

        -- Update player
        playerUpdate(deltaTime)

        -- Update projectiles
        projectileUpdate(deltaTime)

        -- Update UI
        uiUpdate()

        -- Update hand
        hand:update(deltaTime, false)
    end
end

-- Room transition
function GameScene.loadNewRoom()
    state = STATES.transitioning
    timerManager.init()

    local roomTransitionImagetable = gfx.imagetable.new('assets/images/ui/roomTransition')
    local roomTransitionAnimation = gfx.animation.loop.new(200, roomTransitionImagetable, true)
    local _, roomTransitionHeight = roomTransitionImagetable[1]:getSize()

    local levelRoomText = levelManager.level .. ' - ' .. levelManager.room
    local levelRoomTextImage = gfx.imageWithText(levelRoomText, 400, 240):invertedImage()

    local transitionImageX, transitionImageY = 200, 120 - roomTransitionHeight
    local transitionImageEndY = 120 + roomTransitionHeight + 40
    local textImageX, textImageY = 200, -50
    local textImageEndY = 290

    local delayTime = 1000
    local entranceTime, exitTime = 1000, 700
    local textEntranceTime, textExitTime = 700, 500
    local totalTime = 500 + delayTime + entranceTime + exitTime + textEntranceTime + textExitTime
    local drawTimer = pd.timer.new(totalTime)
    drawTimer.updateCallback = function()
        local offsetX, offsetY = gfx.getDrawOffset()
        local transitionImage = roomTransitionAnimation:image()
        transitionImage:drawAnchored(transitionImageX - offsetX, transitionImageY - offsetY, 0.5, 0.5)
        levelRoomTextImage:drawAnchored(textImageX - offsetX, textImageY - offsetY, 0.5, 0.5)
    end

    pd.timer.performAfterDelay(delayTime, function()
        local entranceTimer = pd.timer.new(entranceTime, transitionImageY, 120, pd.easingFunctions.outCubic)
        entranceTimer.updateCallback = function(timer)
            transitionImageY = timer.value
        end
        entranceTimer.timerEndedCallback = function()
            player.moveToEntrance()
            local textEntranceTimer = pd.timer.new(textEntranceTime, textImageY, 120, pd.easingFunctions.outCubic)
            textEntranceTimer.updateCallback = function(timer)
                textImageY = timer.value
            end
            textEntranceTimer.timerEndedCallback = function()
                local textExitTimer = pd.timer.new(textExitTime, textImageY, textImageEndY, pd.easingFunctions.inCubic)
                textExitTimer.updateCallback = function(timer)
                    textImageY = timer.value
                end
                textExitTimer.timerEndedCallback = function()
                    -- Reset spell cooldowns
                    hand:resetCooldowns()
                    local exitTimer = pd.timer.new(exitTime, transitionImageY, transitionImageEndY, pd.easingFunctions.inCubic)
                    exitTimer.updateCallback = function(timer)
                        transitionImageY = timer.value
                    end
                    exitTimer.timerEndedCallback = function(timer)
                        state = STATES.moving
                        transitionImageY = timer.value
                        levelManager:spawnRoomEnemies()
                    end
                end
            end
        end
    end)
end

function GameScene.exitLevel()
    if player.died then
        return
    end
    state = STATES.transitioning
    player.storeHealth()
    SceneManager.switchScene(LevelScene)
end

function GameScene.playedDied()
    state = STATES.transitioning
    SceneManager.switchScene(TitleScene)
end

-- Game state transitions
function GameScene.switchToAiming()
   state = STATES.aiming
   aimManager:activate()
end

function GameScene.switchToMoving()
    state = STATES.moving
end

function GameScene.revealHand()
    state = STATES.selecting
    hand:activateHand()
end

function GameScene.screenShake()
    shakeTimer:reset()
    shakeTimer:start()
end

function pd.debugDraw()
    local playerHitboxX = player.x - player.widthOffset
    local playerHitboxY = player.y - player.heightOffset
    gfx.drawRect(playerHitboxX, playerHitboxY, player.width, player.height)
    local em = enemyManager
    local activeEnemyIndexes = em.getActiveIndexes()
    if activeEnemyIndexes then
        for _, index in ipairs(activeEnemyIndexes) do
            local x, y = em.enemyX[index], em.enemyY[index]
            local w, h = em.enemyWidth[index], em.enemyHeight[index]
            gfx.drawRect(x, y, w, h)
        end
    end
end