local pd <const> = playdate
local gfx <const> = pd.graphics

local sceneManager = SceneManager

GameScene = {}

function GameScene.init()
    gfx.setBackgroundColor(gfx.kColorBlack)
end

function GameScene.update()
    if pd.buttonJustPressed(pd.kButtonA) then
        sceneManager.switchScene(TitleScene)
    end
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 400, 240)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextAligned("GameScene", 200, 120, kTextAlignment.center)
end