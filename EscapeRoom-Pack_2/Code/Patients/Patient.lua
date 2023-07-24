-- Patient health and ailment
-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
LoadFacility('Game')

allNeeds = allNeeds or { 'pill', 'syringe' }

need = need or 'pill'
-- Or assign from random selection with:
-- need = allNeeds[math.random(#allNeeds)]

if not health then
    health = 5
end

-- Setup progress bar displaying patient health
local healthBar = owner.getFirstComponentTagged('ProgressBar')
healthBar.setMaxValue(health, true)

-- Called from Bed.lua
function getNeed()
    return need;
end

-- called externally
function canAdministerRemedy(remedy)
    local bed = owner.map.getFirstTagged(owner.gridPosition, 'Bed')
    if nil == bed then
        print('Must be in bed to be cured!')
        return {result='not in bed'}
    end

    print('Need remedy ' .. remedy)
    if remedy == need then
        print('Correct remedy!')
        return {result='success'}
    else
        print('Wrong remedy!')
        return {result='wrong'}
    end
end

function cure(positionOfCurer)
    print('Cured')
    -- Set patient state to 'Cured', triggering the cure animation, then destroy
    owner.bus.send({state = 'Cured', curerPos = positionOfCurer})
    owner.destroyObject()

    -- Notify any interested listener (GameManager.lua) that a patient was cured so it can check whether the level has been won.
    game.bus.send({ 'patient.cured' })
end

-- make sure we're tagged 'patient' so Medicine knows to heal us!
-- Tag the MapObject
owner.tags.addTag('patient')

-- Don't want patients allowing passage
owner.tags.addTag('blocksMove')
owner.tags.addTag('blocksThrow')

-- Tagging self (component) too.  This allows Medicine Lua to find us later
tags.addTag('patient')

print('Patient ' ..tostring(owner).. ' has ' ..health.. ' health and needs ' ..need)
