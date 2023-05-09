
import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'

import 'scripts/libraries/SceneManager'
import 'scripts/libraries/Utilities'

import 'scripts/scenes/game/gameScene'
import 'scripts/scenes/title/titleScene'

local pd <const> = playdate
local gfx <const> = playdate.graphics

SceneManager.startingScene(TitleScene)
