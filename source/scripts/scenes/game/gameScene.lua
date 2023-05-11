-- Constants
local pd <const> = playdate
local gfx <const> = pd.graphics
local getCurTimeMil = pd.getCurrentTimeMilliseconds
local previous_time = nil

TYPES = {
    wall = 1,
    player = 2,
    enemy = 3
}

-- Libraries
local sceneManager = SceneManager
local bump = bump

local player = Player
local enemyManager = EnemyManager
local playerUpdate = player.update
local world = nil

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
end

function pd.debugDraw()
    if world then
        local rects = world:getRects()
        for _, rect in pairs(rects) do
            gfx.drawRect(rect.x, rect.y, rect.w, rect.h)
        end
    end
end