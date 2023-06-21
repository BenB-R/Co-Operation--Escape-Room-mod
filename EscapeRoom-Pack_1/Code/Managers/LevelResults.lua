-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
LoadFacility('Game')

print('LevelResults lua script started')

local playersStartX = 11

-- Get saved values from the level that was just played
local playersEscaped = game.saveData.getNumber('playersEscaped')
local coinsCollected = game.saveData.getNumber('coinsCollected')

-- Display some text in the UI letting players know their 'score' (number of players escaped and coins collected)
game.bus.send({
    displayText = ' ' .. playersEscaped .. ' players escaped!\n\n' ..
            'Coins collected: ' .. coinsCollected .. '\n\nMove your characters to choose what to do next.',
    displayType = 'messageDisplayUI.left'
}, nil, false)

-- Also show some info on the 'ticker' that displays scrolling text
game.bus.send({displayText = '- Move to make your choice. Majority wins! -', displayType = 'ticker'}, nil, false)

local function onGamePhaseChanged(message)
    local phase = message.data.gamePhase;
    if phase ~= 'planning' then
        return
    end

    print('LevelResults - planning phase: Checking player positions')

    local movedEastCount = 0
    local movedWestCount = 0
    local players = owner.map.getAllObjectsTagged('player')

    for player in players do
        local playerXPos = player.gridPosition[1]
        if playerXPos > playersStartX then
            movedEastCount = movedEastCount + 1
            print('Player is east of their starting position at x pos: ' .. playerXPos)
        elseif playerXPos < playersStartX then
            movedWestCount = movedWestCount + 1
            print('Player is west of their starting position at x pos: ' .. playerXPos)
        end
    end

    -- TODO: Should vary depending on context (e.g. if level was lost, neither option should trigger 'continue to next level')
    if movedEastCount > movedWestCount then
        print('Majority of players moved east, so next level wins!')
        game.bus.send({'level.next'})
    elseif movedWestCount > movedEastCount then
        print('Majority of players moved west, so play again wins!')
        game.bus.send({'level.reload'})
    else
        print('Players have not yet reached a consensus')
    end
end

-- subscribe to get informed when game rounds start
game.bus.subscribe('gamePhase', onGamePhaseChanged)
