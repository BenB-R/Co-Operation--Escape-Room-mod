-- PressurePlate mod

-- Bring in the ability to use the GameManager's message bus
LoadFacility('Game')

-- Set-up the key type if not supplied by JSON data
---@type string
keyType = keyType or 'defaultKey'

owner.tags.addTag('pressurePlate')

local function playerOnPlate(message)
    print(message.data.gridPosition)
    local player = owner.map.getFirstTagged(message.data.gridPosition, 'Player')
    if player == nil then
        return {success = false} -- return a table with a "success" field set to false
    end

    local gatesIterator = owner.map.getAllObjectsTagged('gate')
    local gates = {}
    for gate in gatesIterator do
        table.insert(gates, gate)
    end

    if #gates == 0 then
        print('No gates found')
        return {success = false} -- return a table with a "success" field set to false
    end

    for _, gate in ipairs(gates) do
        local success = unlockGate(gate)
        if success then
            return {success = true} -- return a table with a "success" field
        end
    end
    return {success = false} -- return a table with a "success" field set to false
end



---@param gateMapObject MapObjectProxy
---@return boolean
function unlockGate(gateMapObject)
    local canUnlock = gateMapObject['canUnlock'](keyType)

    print('trying to unlock gate with ' .. keyType .. ' resulted in', json.serialize(canUnlock))
    if canUnlock and canUnlock.result == 'success' then
        -- Unlock the gate
        gateMapObject['unlock']()
        print('Gate was successfully unlocked by pressure plate')
        return true
    else
        print('This pressure plate cannot unlock the gate')

        -- Play 'Wrong Key' sound effect
        game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'WrongKey' } }, false)

        return false
    end
end

-- MAIN
-- Subscribe to be told when a player steps on the pressure plate
owner.bus.subscribe('playerOnPlate', playerOnPlate)

print('PressurePlate mod ready for', owner)