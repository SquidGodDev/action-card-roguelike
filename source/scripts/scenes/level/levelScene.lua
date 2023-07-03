local pd <const> = playdate
local gfx <const> = pd.graphics

local sceneManager = SceneManager
local gameData = GameData

class('LevelSprite').extends(gfx.sprite)

LevelScene = {}
LevelScene.init = function()
    LevelSprite()
end
LevelScene.update = function()
    -- Nothing
end

function LevelSprite:init()
    self.maxLevel = 5
    self.level = gameData.level
    self.world = gameData.world
    self.levelSelections = gameData.levelSelections
    self:createHealthUI()
    self:createLevelIcons()

    if self.level == self.maxLevel - 1 then
        self.choiceSelection = ChoiceSelection(200, 120, {SELECTION_CHOICES.campfire, SELECTION_CHOICES.market, SELECTION_CHOICES.chest}, true)
        self.choiceSelection:animateIn()
    elseif self.level == self.maxLevel then
        self:endLevel()
    else
        if self.level == 0 then
            self:selected(SELECTION_CHOICES.enemy)
        else
            local animateDelay = 500
            pd.timer.performAfterDelay(animateDelay, function()
                self:selected(SELECTION_CHOICES.enemy)
            end)
        end
    end

    self:add()
end

function LevelSprite:update()
    if self.choiceSelection then
        if pd.buttonJustPressed(pd.kButtonA) then
            self:selected(self.choiceSelection:select())
            self.choiceSelection:animateOut()
            self.choiceSelection = nil
        elseif pd.buttonJustPressed(pd.kButtonLeft) then
            self.choiceSelection:selectLeft()
        elseif pd.buttonJustPressed(pd.kButtonRight) then
            self.choiceSelection:selectRight()
        end
    end
end

function LevelSprite:selected(choice)
    local nextLevelIndex = self.level + 1
    self:animateCursor(nextLevelIndex, function()
        self:screenShake()
        local curIcon = self.levelIcons[nextLevelIndex]
        local newIcon = self:getSpriteFromChoice(choice)
        newIcon:moveTo(curIcon.x, curIcon.y)
        newIcon:add()
        Utilities.particle(curIcon.x, curIcon.y, 'assets/images/ui/level/levelEnterParticles', 15, false)
        curIcon:remove()
        table.insert(self.levelSelections, choice)
        gameData.level += 1

        local transitionDelay = 1000
        pd.timer.performAfterDelay(transitionDelay, function()
            if choice == SELECTION_CHOICES.campfire then
                sceneManager.switchScene(CampfireScene)
            elseif choice == SELECTION_CHOICES.chest then
                sceneManager.switchScene(ChestScene)
            elseif choice == SELECTION_CHOICES.enemy then
                sceneManager.switchScene(GameScene)
            elseif choice == SELECTION_CHOICES.market then
                sceneManager.switchScene(MarketScene)
            end
        end)
    end)
end

function LevelSprite:endLevel()
    self:animateCursor(self.maxLevel + 1, function()
        gameData.level = 0
        gameData.levelSelections = {}
        gameData.world += 1
        local transitionDelay = 1000
        pd.timer.performAfterDelay(transitionDelay, function()
            sceneManager.switchScene(LevelSprite)
        end)
    end)
end

function LevelSprite:animateCursor(index, callback)
    local targetX = self.levelIcons[index].x
    local animateTimer = pd.timer.new(1000, self.cursor.x, targetX, pd.easingFunctions.inOutCubic)
    animateTimer.updateCallback = function(timer)
        self.cursor:moveTo(timer.value, self.cursor.y)
    end
    animateTimer.timerEndedCallback = function()
        if callback then
            callback()
        end
    end
end

function LevelSprite:createHealthUI()
    local playerMaxHealth = gameData.playerMaxHealth
    local playerHealth = gameData.playerHealth
    local UIBaseX, UIBaseY = 18, 18
    local textBaseX = UIBaseX + 24
    local heartImageTable = gfx.imagetable.new('assets/images/ui/heart')
    self.heartSprite = Utilities.createAnimatedSprite(heartImageTable)
    self.heartSprite:moveTo(UIBaseX, UIBaseY)
    self.heartSprite:add()
    self.healthText = gfx.sprite.new()
    self.healthText:setCenter(0, 0.5)
    self.healthText:moveTo(textBaseX, UIBaseY)
    self.healthText:add()
    local healthTextImage = gfx.imageWithText(playerHealth .. '/' .. playerMaxHealth, 100)
    self.healthText:setImage(healthTextImage)
    self.healthText:setImageDrawMode(gfx.kDrawModeFillWhite)
end

function LevelSprite:createLevelIcons()
    local baseX, baseY = 80, 120
    local iconGap = 48
    self.levelIcons = {}
    for i=1, self.maxLevel + 1 do
        local iconSprite
        if i > self.maxLevel then
            iconSprite = Utilities.createAnimatedSprite('assets/images/ui/level/arrow')
        elseif i > self.level then
            iconSprite = Utilities.createAnimatedSprite('assets/images/ui/level/question')
        else
            local choice = self.levelSelections[i]
            iconSprite = self:getSpriteFromChoice(choice)
        end
        iconSprite:moveTo(baseX + (i-1)*iconGap, baseY)
        iconSprite:add()
        self.levelIcons[i] = iconSprite
    end

    self.cursor = Utilities.createAnimatedSprite('assets/images/ui/level/cursor')
    local cursorX = math.max(baseX + (self.level-1)*iconGap, baseX)
    self.cursor:moveTo(cursorX, baseY)
    self.cursor:add()
end

function LevelSprite:getSpriteFromChoice(choice)
    if choice == SELECTION_CHOICES.campfire then
        return Utilities.createAnimatedSprite('assets/images/ui/level/campfire')
    elseif choice == SELECTION_CHOICES.chest then
        return Utilities.createAnimatedSprite('assets/images/ui/level/chest')
    elseif choice == SELECTION_CHOICES.enemy then
        return Utilities.createAnimatedSprite('assets/images/ui/level/skull')
    elseif choice == SELECTION_CHOICES.market then
        return Utilities.createAnimatedSprite('assets/images/ui/level/market')
    end
end

function LevelSprite:screenShake()
    if self.screenShakeTimer then
        self.screenShakeTimer:remove()
    end
    local shakeTime = 400
    local shakeIntensity = 5
    self.screenShakeTimer = pd.timer.new(shakeTime, shakeIntensity, 0)
    self.screenShakeTimer.timerEndedCallback = function()
        pd.display.setOffset(0, 0)
    end
    self.screenShakeTimer.updateCallback = function(timer)
        local shakeAmount = timer.value
        local shakeAngle = math.random()*math.pi*2;
        shakeX = math.floor(math.cos(shakeAngle)*shakeAmount);
        shakeY = math.floor(math.sin(shakeAngle)*shakeAmount);
        pd.display.setOffset(shakeX, shakeY)
    end
end
