# Action Card Roguelike
Source code for my unfinished Playdate game that's a mix between a deck builder and action roguelike. Features simple combat and card selection mechanic.

<img src="https://github.com/user-attachments/assets/c4e642d8-c393-4b9b-a649-40151756b603" width="400" height="240"/>

## Project Structure
- `mockups/` - Art mockups
- `source/`
  - `scripts/`
    - `assets/` - Font/image assets
    - `data/`
      - `cards.lua` - Card properties data file 
      - `constants.lua` - Global constants
      - `gameData.lua` - Global game state data
    - `libraries/`
      - `SceneManager.lua` - Handles scene transitions
      - `Utilities.lua` - Utility functions
    - `scenes/`
      - `game/`
        - `cards/`
          - `properties/` - Component system to construct cards from individual properties
            - `aoeCard.lua`
            - `beamCard.lua`
            - `damageZoneCard.lua`
            - `followZoneCard.lua`
            - `projectileCard.lua`
            - `randomStrikeCard.lua`
            - `repeatedProjectileCard.lua`
            - `rowExplosionCard.lua`
          - `card.lua` - Handles individual card animation and data 
          - `hand.lua` - Handles card selection and data of cards in hand
        - `enemies/` - Enemy data and movement/attack functions
          - `blight.lua`
          - `cerberus.lua`
          - `gargoyle.lua`
          - `kraken.lua`
          - `phoenix.lua`
          - `slime.lua`
        - `managers/`
          - `aimManager.lua` - Draws aiming line
          - `drawManager.lua` - Handles miscellaneous draw calls
          - `enemyManager.lua` - Manages enemies
          - `levelManager.lua` - Manages room management
          - `particleManager.lua` - Draws particles
          - `projectileManager.lua` - Draw projectiles
          - `timerManager.lua` - Updates timers
          - `uiManager.lua` - Draws health
        - `deck.lua` - Simple card deck management
        - `gameScene.lua` - Composes managers
        - `player.lua` - Player character controller
      - `level/`
        - `campfire/`
          - `campfireScene.lua` - Empty
        - `chest/`
          - `chestScene.lua` - Empty
        - `market/`
          - `marketScene.lua` - Empty
        - `cardSelection.lua` - Unimplemented
        - `levelScene.lua` - Level selection UI
      - `title/`
        - `titleScene.lua` - Title screen UI
  - `main.lua` - All imports

## License
All code is licensed under the terms of the MIT license.
