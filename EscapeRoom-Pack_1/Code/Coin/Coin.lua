-- Coin mod
LoadFacility('Game')

owner.tags.addTag('Coin')

local function playerOnCoin(message)
    local player = owner.map.getFirstTagged(message.data.gridPosition, 'Player')
    local playerPosition = message.data.gridPosition
    
    if nil == player then
        return -- early out = not a player
    end

    -- Wake up, it's time to die
    owner.destroyObject()
    game.bus.send({metadata = {'coinCollected'}, data = {position = playerPosition}}, nil, false)
end

owner.bus.subscribe('playerOnCoin', playerOnCoin)

print('coin ready for', owner)