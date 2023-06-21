-- Gate
-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
LoadFacility('Game')

-- Allow indicating whether to remove the gate in the YAML and default to true
removeGate = removeGate or true

activatorType = activatorType or 'default'

owner.tags.addTag('gate')

print('removeGate:', removeGate)

local function onSiblingRemoved(message)
    print('Gate sibling removed - removing gate.  removeGate:', removeGate)
    if removeGate then
        print('destroying gate!')
        owner.destroyObject()
    end
end

local function setVisible(newVisible)
    print('Gate set visible:', newVisible)
    owner.bus.send({visible = newVisible}, nil, false)
end

local function onGamePhaseChanged(message)
    local phase = message.data.gamePhase;
    print('Game phase: "'.. phase ..'"')
    if phase == 'planning' then
        -- Ensure gate is visible at the beginning of each round
        setVisible(true)
        return
    end
end

owner.bus.subscribe('siblingRemoved', onSiblingRemoved)
game.bus.subscribe('gamePhase', onGamePhaseChanged)

---@param keyType string
---@return table
function canUnlock(activator)
    print("Checking gate activator")
    -- If activatorType matches the activator or is a matching pressurePlateType, the gate can be opened
    if activator == activatorType or (activatorType and activatorType:find("PressurePlate")) then
        return {result = 'success'}
    else
        return {result = 'failure'}
    end
end

function unlock()
    -- Remove the gate (if the removeGate option is set)
    if removeGate then
        owner.destroyObject()
    end
end