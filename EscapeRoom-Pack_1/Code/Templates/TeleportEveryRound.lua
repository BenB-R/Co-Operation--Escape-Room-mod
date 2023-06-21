--- Moves one square at the start of every turn
--- Direction determined by a variable

-- Include the 'Vectors' lib (in 'lib/Vectors.lua')
require('Vectors')

-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
LoadFacility('Game')

-- Set default direction if not set in level file 'data'
direction = direction or 'North'

local function onGamePhaseChanged(message)
	-- Extract the game phase from the message
	local phase = message.data.gamePhase;
	print('phase:', phase)
	if phase ~= 'planning' then
		-- Not start of a new planning phase so early out
		return
	end

	print('Teleporting', direction, 'as', owner)

	-- Get the direction as a Vector (2-element array-like Table)
	local directionVector = DirectionArray[direction]
	print('directionVector', json.serialize(directionVector))

	-- Get the position as a Vector (2-element array-like Table)
	local ownPos = owner.gridPosition
	print('ownPos', json.serialize(ownPos))

	-- Maths!
	local targetPos = vectors_add(ownPos, directionVector)
	print('TargetPos:', json.serialize(targetPos))

	-- Teleport
	owner.repositionTo(targetPos)

	print('Done')
end

-- MAIN
-- Subscribe to know when a new game phase (planning/acting) happens
game.bus.subscribe('gamePhase', onGamePhaseChanged)

print('owner', owner, 'id:', id, 'owner.id', owner.id, 'owner.instanceId', owner.instanceId)