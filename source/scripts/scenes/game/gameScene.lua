-- Constants
local pd <const> = playdate
local gfx <const> = pd.graphics
local getCurTimeMil = pd.getCurrentTimeMilliseconds
local previous_time = nil

-- Libraries
local sceneManager = SceneManager
local bump = bump

local player = Player
local playerUpdate = player.update
local enemyManager = EnemyManager
local enemyUpdate = enemyManager.update
local world

local hand

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

function GameScene.init()
    gfx.sprite.setBackgroundDrawingCallback(function()
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0, 0, 400, 240)
    end)

    world = bump.newWorld(32)
    player.init(world)
    for _, wall in ipairs(walls) do
        local wallObject = {type = TYPES.wall}
        world:add(wallObject, wall.x, wall.y, wall:getSize())
        wall:add()
    end

    local minSpawnX, maxSpawnX = -300, 600
    local minSpawnY, maxSpawnY = -200, 400
    enemyManager.init(world, player)

    -- Spawn all at once
    for _=1, 10 do
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
    for _, card in pairs(CARDS) do
        table.insert(cardList, card)
    end
    deckData = {}
    for i=1,20 do
        local card = cardList[math.random(#cardList)]
        deckData[i] = card
    end
    local deck = Deck(deckData)
    hand = Hand(deck, nil)
end

function GameScene.update()
    -- Calculate delta time
    local dt = 0.033
	local current_time <const> = getCurTimeMil()
	if previous_time ~= nil then
		dt = (current_time - previous_time) / 1000.0
	end
	previous_time = current_time

    -- Update player
    playerUpdate(dt)

    -- Update enemies
    enemyUpdate(dt)

    --Update hand
    hand:update()

    if pd.buttonJustPressed(pd.kButtonA) then
        hand:drawCard()
    end

    if pd.buttonJustPressed(pd.kButtonLeft) then
        hand:selectCardLeft()
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        hand:selectCardRight()
    end
end

function pd.debugDraw()
    if world then
        local rects = world:getRects()
        for _, rect in pairs(rects) do
            gfx.drawRect(rect.x, rect.y, rect.w, rect.h)
        end
    end
end