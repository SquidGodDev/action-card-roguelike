local pd <const> = playdate
local gfx <const> = pd.graphics

local previous_time = nil
local sceneManager = SceneManager
local player = Player

GameScene = {}

function GameScene.init()
    gfx.sprite.setBackgroundDrawingCallback(function()
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0, 0, 400, 240)
    end)

    local background = gfx.image.new('assets/images/randomBackground')
    local backgroundSprite = gfx.sprite.new(background)
    backgroundSprite:add()
    backgroundSprite:moveTo(200, 120)

    player.init()
end

function GameScene.update()
    -- Calculate delta time
    local dt = 0.033
	local current_time <const> = playdate.getCurrentTimeMilliseconds()
	if previous_time ~= nil then
		dt = (current_time - previous_time) / 1000.0
	end
	previous_time = current_time

    -- Update player
    player.update(dt)
end