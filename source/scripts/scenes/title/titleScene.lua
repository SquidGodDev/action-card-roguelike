local pd <const> = playdate
local gfx <const> = pd.graphics

local sceneManager = SceneManager

TitleScene = {}

function TitleScene.init()
    gfx.sprite.setBackgroundDrawingCallback(function()
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0, 0, 400, 240)
    end)
end

function TitleScene.update()
    if pd.buttonJustPressed(pd.kButtonA) then
        sceneManager.switchScene(GameScene)
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextAligned('Title Scene', 200, 120, kTextAlignment.center)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end