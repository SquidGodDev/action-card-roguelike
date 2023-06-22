local gameData = GameData

class('LevelManager').extends()

function LevelManager:init(gameScene, enemyManager)
    self.gameScene = gameScene
    self.enemyManager = enemyManager
    enemyManager.setLevelManager(self)
    self.room = 1
    self.level = gameData.level
    self.maxRoom = 5
end

function LevelManager:enemyDied()
    local remainingEnemies = #self.enemyManager.getActiveIndexes()
    if remainingEnemies <= 0 then
        self:enterNewRoom()
    end
end

function LevelManager:enterNewRoom()
    self.room += 1
    if self.room > self.maxRoom then
        self.gameScene.exitLevel()
    else
        self.gameScene.loadNewRoom()
    end
end

function LevelManager:spawnRoomEnemies()
    local enemyList = {Gargoyle, Cerberus, Phoenix}
    local enemyCount = 3 + (self.room - 1) * 2
    local minX, maxX = self.gameScene.minX, self.gameScene.maxX
    local minY, maxY = self.gameScene.minY, self.gameScene.maxY
    for _=1, enemyCount do
        self.enemyManager.spawnEnemy(enemyList[math.random(#enemyList)], math.random(minX + 10, maxX - 10), math.random(minY + 10, maxY - 10))
    end
end