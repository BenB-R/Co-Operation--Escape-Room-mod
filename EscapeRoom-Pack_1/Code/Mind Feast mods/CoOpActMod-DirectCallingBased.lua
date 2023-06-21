---CoOperation Act mod.
---Handles the `act` verb to handle picking-up and placing-down carryable items in a direction.
---This initially includes patients and medicine.

-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
LoadFacility('Game')

local Vector = require('Vector')

local function carryOrApplyToNeighbourUsingCoOpActor(actDirection)
    print('Acting getting actor from owner', owner)
    -- That weird block thing below is a Luanalysis block comment cast saying convert from IComponent to CoOpActor
    local coOpActor = --[[---@type CoOpActor]] owner.getFirstComponentTagged('CoOpActor', SearchType.SelfOnly)
    print('Acting with actor', coOpActor)
    -- return success at either carrying or applying to neighbour (placing patient in bed)
    local result = coOpActor.carryOrApplyToNeighbour(actDirection)
    print('Result of acting with actor', result)

    return result
end

local function endIntoAcceptorMapObject(carrier, acceptorMapObject)
    local acceptor = acceptorMapObject.getFirstComponentTagged('acceptor')
    print('Acceptor from', acceptorMapObject, 'got', acceptor)
    assert(nil ~= acceptor)
    return carrier.endCarryInto(acceptor)
end

local function actWithPatient(carrier, actDirection)
    
    -- If there is empty floor with nothing blocking us, place the patient down
    if owner.getFirstFacingObjectTagged('blocksMove') == nil and owner.getFirstFacingObjectTagged('floor') ~= nil then
        local dropPos = Vector.new(owner.gridPosition[1], owner.gridPosition[2]) + Vector.directionNameToVector(actDirection)
        return carrier.endCarry(dropPos)
    end

    -- If carrying and no empty floor, look for a bed or player in the direction the player is facing
    -- Priority goes to beds then players
    local bestAcceptorMapObject = nil
    for acceptorMapObject in owner.getFacingObjectsTagged('bed or player') do
        print('Acceptor:', acceptorMapObject)
        if acceptorMapObject.tags.hasTag('bed') then
            local dropSuccess = endIntoAcceptorMapObject(carrier, acceptorMapObject)
            print('Plopped', carrier, 'into bed')
            if dropSuccess then
                return true
            end
        else -- it's a player
            if nil == bestAcceptorMapObject then
                bestAcceptorMapObject = acceptorMapObject
            end
        end
    end

    if nil ~= bestAcceptorMapObject then
        return endIntoAcceptorMapObject(carrier, bestAcceptorMapObject)
    end

    return false
end

local function actWithMedicine(carrier, carried, actDirection)
    -- If there is empty floor with nothing blocking us, drop the medicine
    if owner.getFirstFacingObjectTagged('blocksMove') == nil and owner.getFirstFacingObjectTagged('floor') ~= nil then
        local dropPos = Vector.new(owner.gridPosition[1], owner.gridPosition[2]) + Vector.directionNameToVector(actDirection)
        if carrier.endCarry(dropPos) then
            -- Medicine is destroyed when dropped on the ground
            carried.owner.destroyObject()
            return true
        else
            return false
        end
    end

    -- There's no empty floor, try administering the medicine instead
    return carried.owner['administer']()
end

---Act for the doctor.
---Called externally (from framework).
---If not carrying, tries to pick something up.
---If carrying patient, tries to place in bed (or another acceptable place if not).
---If carrying medicine, calls 'administer' on the medicine lua script
function act(actDirection)
    print('acting in direction:', actDirection)

    -- Face in direction of action
    owner.setFacing(actDirection)

    -- Check whether carrying
    local carrier = owner.getFirstComponentTagged('carrier');
    assert(nil ~= carrier, 'Player lacks carrier component')
    local isCarrying = carrier.isCarrying
    print('Lua isCarrying:', isCarrying)

    local success = false

    if isCarrying then
        local carried = carrier.getCurrentlyCarried() -- gives us a Carryable component
        print('current carried:', carried)

        -- If we're carrying a patient, try to drop them
        -- Or if we're carrying medicine, try to administer it
        if carried.owner.tags.hasTag('patient') then
            success = actWithPatient(carrier, actDirection)
        elseif carried.owner.tags.hasTag('medicine') then
            success = actWithMedicine(carrier, carried, actDirection)
        end
    else
        -- Not carrying, look for something to pick up
        success = carryOrApplyToNeighbourUsingCoOpActor(actDirection) -- cheat for now by using C# functionality
        -- TODO: Lua version that looks in neighbouring squares for items tagged `carryable`
    end

    if not success then
        -- Acting failed/we did nothing
        game.bus.send({ metadata = { 'player.actionFailed' }, data = { position = owner.gridPosition, direction = actDirection } }, false)
        game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'InvalidAction' } }, false)
        owner.bus.send({ 'player.actionFailed' }, false)
    end

    return success
end

print 'Act mod ready'
