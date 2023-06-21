-- Include the 'Vectors' lib (in 'lib/Vectors.lua')
require('Vectors')

-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
LoadFacility('Game')

owner.tags.addTag('escapePoint')

locationX = locationX or 11
locationY = locationY or 1

location = { locationX, locationY }

local function playerOnEscapePoint(message)
    local playerPosition = message.data.gridPosition
    local player = owner.map.getFirstTagged(playerPosition, 'player')

    if not player then
        print('No player object found at the received position')
        return
    end

    player.repositionTo(location)
    print('Player teleported')

    -- Send a message to the GameManager to increment the escapedPlayers value
    game.bus.send({ metadata = { 'playerEscaped' } })
end

-- MAIN
-- Subscribe to know when a new game phase (planning/acting) happens
owner.bus.subscribe('playerOnEscapePoint', playerOnEscapePoint)

print('owner', owner, 'id:', id, 'owner.id', owner.id, 'owner.instanceId', owner.instanceId)
