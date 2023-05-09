local pd <const> = playdate
local gfx <const> = pd.graphics

local sceneManager = SceneManager

GameScene = {}

function GameScene.init()
    gfx.sprite.setBackgroundDrawingCallback(function()
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0, 0, 400, 240)
    end)
end

function GameScene.update()
    if pd.buttonJustPressed(pd.kButtonA) then
        sceneManager.switchScene(TitleScene)
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextAligned("GameScene", 200, 120, kTextAlignment.center)
end