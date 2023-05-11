local pd <const> = playdate
local gfx <const> = pd.graphics

local queue <const> = Queue

local maxEnemyCount <const> = 50

local activeList = nil
local inactiveList = nil

local enemyHealth = table.create(maxEnemyCount, 0)
local enemyX = table.create(maxEnemyCount, 0)
local enemyY = table.create(maxEnemyCount, 0)
local enemySpeed = table.create(maxEnemyCount, 0)

EnemyManager = {}

function EnemyManager.init(world)
    activeList = queue.new(maxEnemyCount)
    inactiveList = queue.new(maxEnemyCount)
    for i=1, maxEnemyCount do
        queue.push(activeList, i)
    end
end

function EnemyManager.update()
    
end