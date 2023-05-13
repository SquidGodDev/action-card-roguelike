local pd <const> = playdate
local gfx <const> = pd.graphics

math.randomseed(pd.getSecondsSinceEpoch())

-- Core Libraries
import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'

-- Libraries
import 'scripts/libraries/SceneManager'
import 'scripts/libraries/Utilities'
import 'scripts/libraries/bump'

-- Globals
import 'scripts/constants'

import 'scripts/scenes/game/player'
import 'scripts/scenes/game/enemyManager'
import 'scripts/scenes/game/enemies/slime'
import 'scripts/scenes/game/gameScene'
import 'scripts/scenes/title/titleScene'

DRAW_FPS = true

pd.display.setRefreshRate(30)

SceneManager.startingScene(GameScene)
