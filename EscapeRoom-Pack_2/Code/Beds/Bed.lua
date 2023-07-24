-- CoOperation Bed mod
-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
LoadFacility('Game')

local function updateClipboards(siblingAdded)
    local patient = owner.map.getFirstTagged(owner.gridPosition, 'Patient')
    local clipboards = owner.map.getAllTagged(owner.gridPosition, 'Clipboard')

    if siblingAdded and patient ~= nil then
        -- Weird syntax for calling between mods
        local patientNeed = patient['getNeed']()
        print('Bed has patient that needs ' .. patientNeed)
        for i, clipboard in pairs(clipboards) do
            if clipboard ~= nil then
                -- Weird syntax for calling between mods
                clipboard['setVisibleForNeed'](patientNeed)
            end
        end
    else
        print('No patient in bed - hiding all clipboards')
        for i, clipboard in pairs(clipboards) do
            -- Weird syntax for calling between mods
            clipboard['setVisible'](false)
        end
    end
end

local function onSiblingAdded(message)
    print('Bed sibling added - updating clipboards')
    updateClipboards(true)
end

local function onSiblingRemoved(message)
    print('Bed sibling removed - updating clipboads')
    updateClipboards(false)
end

local function setVisible(newVisible)
    print('Bed set visible:', newVisible)
    owner.bus.send({visible = newVisible}, nil, false)
end

local function onGamePhaseChanged(message)
    local phase = message.data.gamePhase;
    print('Game phase: "'.. phase ..'"')
    if phase == 'planning' then
        -- Ensure bed is visible at the beginning of each round
        setVisible(true)
        return
    end
end

owner.bus.subscribe('siblingAdded', onSiblingAdded)
owner.bus.subscribe('siblingRemoved', onSiblingRemoved)
game.bus.subscribe('gamePhase', onGamePhaseChanged)
