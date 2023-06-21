-- Throw mod

-- Action called by the "throw" action from the 'phone' controller
function throw(direction)
    print('Acting getting actor from owner', owner)
    -- That weird block thing below is a Luanalysis block comment cast saying convert from IComponent to CoOpActor
    coOpActor = --[[---@type CoOpActor]] owner.getFirstComponentTagged("CoOpActor", SearchType.SelfOnly)
    print('Modding throwing', direction, 'for owner', owner, 'with actor', coOpActor)

    local result = coOpActor.throwInDirection(direction)
    -- only return a value if we succeeded (so other things can be tried otherwise)
    -- This is provisional = not yet finalised approach -- might change to false means try others
    if result then
        return true
    end
end

print 'Throw mod ready'
