-- Constants
local pd <const> = playdate
local gfx <const> = pd.graphics
local getCurTimeMil = pd.getCurrentTimeMilliseconds
local previous_time = nil

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

GameScene = {}
local gameScene = GameScene

function GameScene.init()
    -- Environment
    gfx.sprite.setBackgroundDrawingCallback(function()
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0, 0, 400, 240)
    end)

    for _, wall in ipairs(walls) do
        wall:add()
    end

    -- Game state
    player.init()
    state = STATES.moving
    projectileManager.init()
    aimManager = AimManager(player)

    -- Enemies
    local minSpawnX, maxSpawnX = -300, 600
    local minSpawnY, maxSpawnY = -200, 400
    enemyManager.init(player)

    -- Spawn all at once
    for _=1, 30 do
        enemyManager.spawnEnemy(Slime, math.random(minSpawnX, maxSpawnX), math.random(minSpawnY, maxSpawnY))
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
    cardList[1] = CARDS.fireball
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
    hand = Hand(deck, gameScene, player)
    hand:drawStartingHand()
end

function GameScene.update()
    -- Calculate delta time
    local dt = 0.033
	local current_time <const> = getCurTimeMil()
	if previous_time ~= nil then
		dt = (current_time - previous_time) / 1000.0
	end
	previous_time = current_time

    if state == STATES.moving then
        deltaTimeMultiplier = lerp(deltaTimeMultiplier, 1, timeLerpRate)
        local deltaTime = dt * deltaTimeMultiplier

        -- Update enemies
        enemyUpdate(deltaTime)

        -- Update player
        playerUpdate(deltaTime)

        -- Update projectiles
        projectileUpdate(deltaTime)

        if pd.buttonJustPressed(pd.kButtonA) then
            gameScene.revealHand()
        end
    elseif state == STATES.selecting then
        deltaTimeMultiplier = lerp(deltaTimeMultiplier, slowedTimeMultiplier, timeLerpRate)
        local deltaTime = dt * deltaTimeMultiplier

        -- Update enemies
        enemyUpdate(deltaTime)

        -- Draw player
        playerUpdate(deltaTime, true)

        -- Update projectiles
        projectileUpdate(deltaTime)

        local crankTicks = pd.getCrankTicks(8)
        if      pd.buttonJustPressed(pd.kButtonLeft) or crankTicks == -1 then hand:selectCardLeft()
        elseif  pd.buttonJustPressed(pd.kButtonRight) or crankTicks == 1 then hand:selectCardRight()
        elseif  pd.buttonJustPressed(pd.kButtonB) or pd.buttonJustPressed(pd.kButtonDown) then hand:dismissHand()
        elseif  pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonUp) then hand:selectCard() end

        -- Update hand
        hand:update()
    elseif state == STATES.aiming then
        deltaTimeMultiplier = lerp(deltaTimeMultiplier, slowedTimeMultiplier, timeLerpRate)
        local deltaTime = dt * deltaTimeMultiplier

        -- Update enemies
        enemyUpdate(deltaTime)

        -- Handle aiming
        aimManager:update()

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