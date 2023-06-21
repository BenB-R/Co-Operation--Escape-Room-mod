--- Destroys its owner when a player enters the square
LoadFacility('Game')

owner.tags.addTag('test')

local function onSiblingAdded(message)
	-- check whether there's a player in the same square as our owner
	local player = owner.map.getFirstTagged(owner.gridPosition, 'Player')
	if nil == player then
		return -- early out = not a player
	end

	-- Wake up, it's time to die
	owner.destroyObject()
end

-- MAIN
-- Subscribe to be told when something enters the same square we're on
owner.bus.subscribe('siblingAdded', onSiblingAdded)