-- GameManagerLua

LoadFacility('Game')

game.bus.send({ metadata = { 'playMusic' }, data = { soundName = 'CoOperationLevelMusic' } }, false)

local turnsLeft = 10 * 4

local escapedPlayers = 0

local coinsCollected = 0

local function playerEscaped()
	escapedPlayers = escapedPlayers + 1
	print("Player escaped! Total escaped players: " .. escapedPlayers)
	-- You can modify the condition to check for a specific number of escaped players
	if escapedPlayers >= 1 then

		checkEnding()
	end
end

local function coinCollected()
	coinsCollected = coinsCollected + 1
	print("Coin collected! Total coins collected: " .. coinsCollected)
end

function checkEnding()
	print("checking ending")

	-- Iterate through the players and count them
	local totalPlayers = 0
	for _ in game.map.getAllObjectsTagged('Player') do
		totalPlayers = totalPlayers + 1
	end

	print("no error yet")
	local playersRemaining = totalPlayers - escapedPlayers
	print('Found '.. playersRemaining ..' players remaining')

	if playersRemaining <= 0 or turnsLeft <= 0 then
		-- You win if there are no players remaining
		local didWin = playersRemaining == 0;
		local endingMessage = didWin and {'level.won'} or {'level.lost'}
		print('Finishing the level with', endingMessage)
		game.bus.send(endingMessage)
	else
		print('Level still in-progress')
	end
end



local function onTurnStart()
	turnsLeft = turnsLeft - 1
	if turnsLeft < 0 then
		turnsLeft = 0
	end
	print("Turns left: " .. turnsLeft)
	checkEnding()
end

-- subscribe to know when a turn starts
game.bus.subscribe('turnStart', onTurnStart)
-- Subscribe to know when a player escapes
game.bus.subscribe('playerEscaped', playerEscaped)
-- Subscribe to know when a player collects a Coin
game.bus.subscribe('coinCollected', coinCollected)

print("Game Manager working")