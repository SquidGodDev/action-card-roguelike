local pd <const> = playdate
local gfx <const> = pd.graphics

local sceneManager = SceneManager

TitleScene = {}

function TitleScene.init()
    gfx.setBackgroundColor(gfx.kColorWhite)
end

function TitleScene.update()
    if pd.buttonJustPressed(pd.kButtonA) then
        sceneManager.switchScene(GameScene)
    end
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 400, 240)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextAligned("Title Scene", 200, 120, kTextAlignment.center)
end