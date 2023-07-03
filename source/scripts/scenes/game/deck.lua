Deck = {}
Deck.cards = {}

function Deck:reset()
    self.cards = {}
end

function Deck:add(card)
    table.insert(self.cards, card)
end

function Deck:replace(oldCard, newCard)
    local deckIndex = table.indexOfElement(self.cards, oldCard)
    if deckIndex then
        table.remove(self.cards, deckIndex)
    end
    table.insert(self.cards, newCard)
end
