-- Coin mod
LoadFacility('Game')

owner.tags.addTag('Coin')

local function playerOnCoin(message)
    local player = owner.map.getFirstTagged(message.data.gridPosition, 'Player')
    if nil == player then
        return -- early out = not a player
    end

    -- Wake up, it's time to die
    owner.destroyObject()
end


owner.bus.subscribe('playerOnCoin', playerOnCoin)

print('coin ready for', owner)