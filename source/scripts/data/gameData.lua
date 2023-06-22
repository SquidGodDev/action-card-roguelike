GameData = {
    level = 0,
    levelSelections = {},
    world = 1,
    playerMaxHealth = 10,
    playerHealth = 10
}

function GameData.reset()
    GameData.level = 0
    GameData.levelSelections = {}
    GameData.world = 1
    GameData.playerMaxHealth = 10
    GameData.playerHealth = GameData.playerMaxHealth
end