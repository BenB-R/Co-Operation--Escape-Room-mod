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

        if carried.owner.tags.hasTag('key') then
            print('Trying to use the key...')
            success = carried.owner['act']()
            print('Key use result:', success)
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