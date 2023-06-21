-- Throw mod

-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
LoadFacility('Game')

-- Action called by the 'throw' action from the 'phone' controller
function throw(throwDirection)
    print('Acting getting actor from owner', owner)
    -- That weird block thing below is a Luanalysis block comment cast saying convert from IComponent to CoOpActor
    coOpActor = --[[---@type CoOpActor]] owner.getFirstComponentTagged('CoOpActor', SearchType.SelfOnly)
    print('Modding throwing', throwDirection, 'for owner', owner, 'with actor', coOpActor)

    local result = coOpActor.throwInDirection(throwDirection)
    -- only return a value if we succeeded (so other things can be tried otherwise)
    -- This is provisional = not yet finalised approach -- might change to false means try others
    if result then
        return true -- TODO-20221104: Needs updating to check whether carrying first, if so, always handled by this since can now throw to no-catcher
    else
        game.bus.send({ metadata = { 'player.actionFailed' }, data = { position = owner.gridPosition, direction = throwDirection } }, false)
        game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'InvalidAction' } }, false)
        owner.bus.send({ 'player.actionFailed' }, false)
    end
end

print 'Throw mod ready'
