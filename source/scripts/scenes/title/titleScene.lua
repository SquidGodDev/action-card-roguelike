local pd <const> = playdate
local gfx <const> = pd.graphics

local sceneManager = SceneManager

TitleScene = {}

local allCards = {}
for _, card in pairs(CARDS) do
    table.insert(allCards, card)
end

function TitleScene.init()
    gfx.setBackgroundColor(gfx.kColorBlack)
    local blackImage = gfx.image.new(400, 240, gfx.kColorBlack)
    blackImage:draw(0, 0)
    Deck:reset()
    for _=1,2 do
        Deck:add(allCards[math.random(#allCards)])
    end
end

function TitleScene.update()
    if pd.buttonJustPressed(pd.kButtonA) then
        GameData.reset()
        sceneManager.switchScene(LevelScene)
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextAligned('Title Scene', 200, 120, kTextAlignment.center)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end