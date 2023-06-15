-- Constants
local pd <const> = playdate
local gfx <const> = pd.graphics
local getCurTimeMil = pd.getCurrentTimeMilliseconds
local previous_time = nil

local floor = math.floor
local random = math.random
local cos = math.cos
local sin = math.sin
local abs = math.abs

local getCrankChange = pd.getCrankChange

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
local gameTimer = GameTimer
local gameTimerUpdate = gameTimer.update

local hand
local STATES <const> = {
    moving = 1,
    selecting = 2,
    aiming = 3
}
local state = STATES.moving
local deltaTimeMultiplier = 1
local slowedTimeMultiplier = 0.05
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

local minX, maxX = -200, 600
local minY, maxY = -120, 360
local setLineWidth = gfx.setLineWidth
local drawLine = gfx.drawLine

local background = gfx.image.new(400, 240, gfx.kColorBlack)

local setDisplayOffset = pd.display.setOffset
local shakeTimer

local crankAccelerationThreshold = 5

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
    local maxHealth = 9
    local health = maxHealth
    player.init(health, maxHealth)
    state = STATES.moving
    projectileManager.init()
    aimManager = AimManager(player)
    particleManager.init()
    drawManager.init()
    gameTimer.init()

    -- Enemies
    enemyManager.init(player)

    -- Spawn all at once
    local enemyList = {Slime, Blight}
    local enemyCount = 30
    for _=1, enemyCount do
        enemyManager.spawnEnemy(enemyList[math.random(#enemyList)], math.random(minX + 10, maxX - 10), math.random(minY + 10, maxY - 10))
    end
    -- Spawn Timer
    -- local enemyCount = 0
    -- local spawnTimer = pd.timer.new(500, function(timer)
    --     enemyManager.spawnEnemy(Slime, math.random(minSpawnX, maxSpawnX), math.random(minSpawnY, maxSpawnY))
    --     enemyCount += 1
    --     if enemyCount >= 30 then
    --         timer:remove()
    --     end
    -- end)
    -- spawnTimer.repeats = true

    -- Deck
    -- ===== Temp values =====
    local cardList = {}
    table.insert(cardList, CARDS.lightningStrike)
    table.insert(cardList, CARDS.zap)
    table.insert(cardList, CARDS.flamethrower)
    -- for _, card in pairs(CARDS) do
    --     table.insert(cardList, card)
    -- end
    deckData = {}
    for i=1,20 do
        local card = cardList[math.random(#cardList)]
        deckData[i] = card
    end
    -- =======================
    local deck = Deck(deckData)
    local maxMana = 5
    hand = Hand(deck, gameScene, player, maxMana)
    hand:drawStartingHand()

    -- UI
    local drawTime = 6
    local manaTime = 1
    uiManager.init(player, hand, drawTime, manaTime)
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
    setLineWidth(4)
    drawLine(minX, minY, minX, maxY) -- Left wall
    drawLine(maxX, minY, maxX, maxY) -- Right wall
    drawLine(minX, minY, maxX, minY) -- Top wall
    drawLine(minX, maxY, maxX, maxY) -- Bottom wall

    if state == STATES.moving then
        deltaTimeMultiplier = lerp(deltaTimeMultiplier, 1, timeLerpRate)
        local deltaTime <const> = dt * deltaTimeMultiplier

        -- Update timers
        gameTimerUpdate(deltaTime)

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
        uiUpdate(deltaTime, true)

        local _, acceleratedChange = getCrankChange()

        if abs(acceleratedChange) > crankAccelerationThreshold and not hand:isEmpty() then
            gameScene.revealHand()
        else
            if buttonJustPressed(aButton) then
                player.basicAttack()
            end

            if buttonJustPressed(bButton) then
                player.dash()
            end
        end
    elseif state == STATES.selecting then
        deltaTimeMultiplier = lerp(deltaTimeMultiplier, slowedTimeMultiplier, timeLerpRate)
        local deltaTime <const> = dt * deltaTimeMultiplier

        -- Update timers
        gameTimerUpdate(deltaTime)

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
        uiUpdate(deltaTime, false)

        local crankTicks = pd.getCrankTicks(8)
        if      pd.buttonJustPressed(pd.kButtonLeft) or crankTicks == -1 then hand:selectCardLeft()
        elseif  pd.buttonJustPressed(pd.kButtonRight) or crankTicks == 1 then hand:selectCardRight()
        elseif  pd.buttonJustPressed(pd.kButtonB) or pd.buttonJustPressed(pd.kButtonDown) then hand:dismissHand()
        elseif  pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonUp) then hand:selectCard() end

        -- Update hand
        hand:update()
    elseif state == STATES.aiming then
        deltaTimeMultiplier = lerp(deltaTimeMultiplier, slowedTimeMultiplier, timeLerpRate)
        local deltaTime <const> = dt * deltaTimeMultiplier

        -- Update timers
        gameTimerUpdate(deltaTime)

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

        if pd.buttonJustPressed(pd.kButtonA) then
            hand:playCard(aimManager:getAngle())
            gameScene.switchToMoving()
        elseif pd.buttonJustPressed(pd.kButtonB) then
            gameScene.revealHand()
        end
    end
end

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