-- Move mod

-- Function called when the object moves to a new position
function IfTaggedObjectAtPosition(newPosition, tagName, messageName)
	local taggedObject = owner.map.getFirstTagged(newPosition, tagName)
	if taggedObject ~= nil then
		print('Player stepped on a', tagName)
		print('Player with id: ', owner.id)
		taggedObject.bus.send({ metadata = { messageName }, data = { gridPosition = newPosition } }, false)
	end
end

function onMove(newPosition)
	print("Player moved to:", newPosition[1], newPosition[2])
	IfTaggedObjectAtPosition(newPosition, 'pressurePlate', 'playerOnPlate')
	IfTaggedObjectAtPosition(newPosition, 'escapePoint', 'playerOnEscapePoint')
	IfTaggedObjectAtPosition(newPosition, 'test', 'siblingAdded')
	IfTaggedObjectAtPosition(newPosition, 'Coin', 'playerOnCoin')
end


-- Action called by the "move" action from the 'phone' controller
function move(direction)
	print('Moving', direction, 'with owner', owner)

	-- Cannot do own movement by checking target space because resolution is more complex
	local result = owner.move1SpaceIfPossible(direction)
	-- only return a value if we succeeded (so other things can be tried otherwise)
	if result then
		print('Moved', direction, 'with owner', owner, 'SUCCEEDED')

		-- Call onMove with the new position
		onMove(owner.gridPosition)

		return true
	else
		print('Moved', direction, 'with owner', owner, 'FAILED')
		return false
	end
end

print('Move mod ready for', owner)