local pd <const> = playdate
local gfx <const> = pd.graphics

class('Hand').extends()

local MAX_HAND_SIZE <const> = 10

local lerp <const> = function(a, b, t)
    return a * (1-t) + b * t
end

local cardPlacements <const> = {}
for i=1, MAX_HAND_SIZE do
    local baseX = 200 - 27
    local gap = 60

    local gapDecreaseIndex = 6
    local gapDecreaseSize = 6
    if i >= 6 then
        gap -= (i - gapDecreaseIndex + 1) * gapDecreaseSize
    end

    if i%2 == 0 then
        baseX = baseX - (gap/2) - gap * (i/2 - 1)
    else
        baseX = baseX - gap * math.floor(i/2)
    end
    local placements = {}
    for j=1, i do
        table.insert(placements, baseX + (j-1) * gap)
    end
    table.insert(cardPlacements, placements)
end


function Hand:init(deck, game)
    self.deck = deck
    self.game = game
    -- self.player = game.player

    self.active = true
    self.startingDrawCount = 5

    self.cards = {}
    self.cardBaseY = 190
    self.cardSelectY = 170
    self.cardSelectIndex = 1

    self.cardAnimationLerpSpeed = 0.2

    self.handSize = 1
end

function Hand:update()
    local handCount = #self.cards
    local cardPlacement = cardPlacements[handCount]
    for i=1, handCount do
        local card = self.cards[i]
        local cardTargetX = cardPlacement[i]
        local cardX = lerp(card.x, cardTargetX, self.cardAnimationLerpSpeed)
        local cardTargetY = self.cardBaseY
        if i == self.cardSelectIndex and self.active then
            cardTargetY = self.cardSelectY
        end
        local cardY = lerp(card.y, cardTargetY, self.cardAnimationLerpSpeed)
        card:moveTo(cardX, cardY)
        card:update()
    end
end

function Hand:selectCardLeft()
    if #self.cards <= 0 or self.cardSelectIndex <= 1 then
        return
    end
    self.cardSelectIndex -= 1
end

function Hand:selectCardRight()
    if #self.cards <= 0 or self.cardSelectIndex >= #self.cards then
        return
    end
    self.cardSelectIndex += 1
end

function Hand:drawCard(count)
    if #self.cards >= MAX_HAND_SIZE then
        return
    end
    count = count or 1
    for _=1,count do
        self:addCard(self.deck:draw())
    end
end

function Hand:addCard(card)
    if #self.cards >= MAX_HAND_SIZE or not card then
        return
    end
    card:moveTo(-50, self.cardBaseY)
    table.insert(self.cards, 1, card)
    self.cardSelectIndex = 1
end
