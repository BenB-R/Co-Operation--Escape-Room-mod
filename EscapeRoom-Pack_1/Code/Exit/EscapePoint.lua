-- Include the 'Vectors' lib (in 'lib/Vectors.lua')
require('Vectors')

-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
LoadFacility('Game')

owner.tags.addTag('escapePoint')

locationX = locationX or 11
locationY = locationY or 1

location = { locationX, locationY }

local function playerOnEscapePoint(message)
    local player = owner.map.getFirstTagged(message.data.gridPosition, 'Player')
    local playerPosition = message.data.gridPosition

    if not player then
        print('No player object found at the received position')
        return
    end

    player.repositionTo(location)
    print('Player teleported')

    -- Update playerPosition after teleportation
    playerPosition = location

    -- Send a message to the GameManager to increment the escapedPlayers value
    game.bus.send({metadata = {'playerEscaped'}, data = {position = playerPosition}}, nil, false)
end


-- Subscribe to know when a new game phase (planning/acting) happens
owner.bus.subscribe('playerOnEscapePoint', playerOnEscapePoint)

print('owner', owner, 'id:', id, 'owner.id', owner.id, 'owner.instanceId', owner.instanceId)
