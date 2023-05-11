
import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'

import 'scripts/libraries/SceneManager'
import 'scripts/libraries/Utilities'
import 'scripts/libraries/bump-niji'

import 'scripts/scenes/game/player'
import 'scripts/scenes/game/enemyManager'
import 'scripts/scenes/game/gameScene'
import 'scripts/scenes/title/titleScene'

local pd <const> = playdate
local gfx <const> = playdate.graphics

DRAW_FPS = true

SceneManager.startingScene(GameScene)
