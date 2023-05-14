local pd <const> = playdate
local gfx <const> = pd.graphics

math.randomseed(pd.getSecondsSinceEpoch())

local mainFont = gfx.font.new('assets/fonts/WhackyJoeMonospaced-12')
gfx.setFont(mainFont)

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

-- Data
import 'scripts/data/cards'

import 'scripts/scenes/game/cards/card'
import 'scripts/scenes/game/cards/hand'
import 'scripts/scenes/game/cards/deck'
import 'scripts/scenes/game/player'
import 'scripts/scenes/game/enemyManager'
import 'scripts/scenes/game/enemies/slime'
import 'scripts/scenes/game/gameScene'
import 'scripts/scenes/title/titleScene'

DRAW_FPS = true

pd.display.setRefreshRate(30)

SceneManager.startingScene(GameScene)
