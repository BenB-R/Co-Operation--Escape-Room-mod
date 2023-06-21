-- Key mod (
-- Bring in the ability to use the GameManager's message bus
LoadFacility('Game')

-- Set-up the key type if not supplied by JSON data
---@type string
keyType = keyType or 'default'

owner.tags.addTag('key')

function act()
  local gate = owner.getFirstNeighbouringObjectTagged('gate')
  if gate == nil then
    print('No neighboring gate found')
    return false
  end
  print('Found neighboring gate:', gate)
  local success = unlockGate(gate)
  if success then
    return true -- cancels attempts to call other functions with same name on other mods
  end
  return false -- explicitly return false when the key cannot unlock the gate
end


---@param gateMapObject MapObjectProxy
---@return boolean
function unlockGate(gateMapObject)
  local canUnlock = gateMapObject['canUnlock'](keyType)

  print('trying to unlock gate with ' .. keyType .. ' resulted in', json.serialize(canUnlock))
  if canUnlock and canUnlock.result == 'success' then
    -- Key is consumed when unlocking the gate
    owner.destroyObject()
    -- Unlock the gate
    gateMapObject['unlock']()
    print('Gate was successfully unlocked and the key was consumed')
    return true
  else
    print('This key cannot unlock the gate')

    -- Play 'Wrong Key' sound effect
    game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'WrongKey' } }, false)

    return false
  end
end