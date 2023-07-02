local pd <const> = playdate
local gfx <const> = pd.graphics

pd.display.setRefreshRate(30)
math.randomseed(pd.getSecondsSinceEpoch())

local mainFont = gfx.font.new('assets/fonts/WhackyJoeMonospaced-12')
gfx.setFont(mainFont)


-- Core Libraries
import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'
import 'CoreLibs/crank'
import 'CoreLibs/animation'

-- Libraries
import 'scripts/libraries/SceneManager'
import 'scripts/libraries/Utilities'

-- Globals
import 'scripts/data/constants'
import 'scripts/data/gameData'

-- Cards
import 'scripts/scenes/game/managers/timerManager'
import 'scripts/scenes/game/managers/drawManager'
import 'scripts/scenes/game/managers/particleManager'
import 'scripts/scenes/game/managers/uiManager'
import 'scripts/scenes/game/managers/projectileManager'
import 'scripts/scenes/game/managers/aimManager'

-- Card properties
import 'scripts/scenes/game/cards/properties/projectileCard'
import 'scripts/scenes/game/cards/properties/repeatedProjectileCard'
import 'scripts/scenes/game/cards/properties/beamCard'
import 'scripts/scenes/game/cards/properties/aoeCard'
import 'scripts/scenes/game/cards/properties/damageZoneCard'
import 'scripts/scenes/game/cards/properties/followZoneCard'
import 'scripts/scenes/game/cards/properties/randomStrikeCard'
import 'scripts/scenes/game/cards/properties/rowExplosionCard'

import 'scripts/data/cards'

import 'scripts/scenes/game/cards/card'
import 'scripts/scenes/game/cards/hand'
import 'scripts/scenes/game/cards/deck'

-- Game
import 'scripts/scenes/game/player'
import 'scripts/scenes/game/managers/enemyManager'
import 'scripts/scenes/game/enemies/slime'
import 'scripts/scenes/game/enemies/blight'
import 'scripts/scenes/game/enemies/gargoyle'
import 'scripts/scenes/game/enemies/cerberus'
import 'scripts/scenes/game/enemies/phoenix'
import 'scripts/scenes/game/enemies/kraken'
import 'scripts/scenes/game/gameScene'
import 'scripts/scenes/game/managers/levelManager'
import 'scripts/scenes/title/titleScene'

-- Level
import 'scripts/scenes/level/cardSelection'
import 'scripts/scenes/level/levelScene'
import 'scripts/scenes/level/campfire/campfireScene'
import 'scripts/scenes/level/chest/chestScene'
import 'scripts/scenes/level/market/marketScene'

DRAW_FPS = true

SceneManager.startingScene(TitleScene)
