-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
LoadFacility('Game')

print('Scoreboard lua script started')

-- Counters
local playersEscaped = 0
local coinsCollected = 0

turnsLeft = turnsLeft or 10

local movesInTurn = 0

print('Scoreboard - Turns left at start: ' .. turnsLeft)

local addTurnsLeftCounterMsg = { metadata = { 'addCounter' }, data = { counterName = "turnsLeft", value = turnsLeft } }
local addPlayersEscapedCounterMsg = { metadata = { 'addCounter' }, data = { counterName = "playersEscaped", value = playersEscaped } }
local addCoinsCollectedCounterMsg = { metadata = { 'addCounter' }, data = { counterName = "coinsCollected", value = coinsCollected } }

owner.bus.send(addTurnsLeftCounterMsg, nil, false)
owner.bus.send(addPlayersEscapedCounterMsg, nil, false)
owner.bus.send(addCoinsCollectedCounterMsg, nil, false)

local function onPlayerEscaped(message)
    local playerPos = message.data.position;

    print('Scoreboard onPlayerEscaped')

    playersEscaped = playersEscaped + 1

    local setPlayersEscapedCounterMsg = { metadata = { 'setCounter' }, data = { counterName = 'playersEscaped', value = playersEscaped, originPos = playerPos } }
    owner.bus.send(setPlayersEscapedCounterMsg, nil, false)
end

local function onCoinCollected(message)
    local coinPos = message.data.position;

    print('Scoreboard onCoinCollected')

    coinsCollected = coinsCollected + 1

    local setCoinsCollectedCounterMsg = { metadata = { 'setCounter' }, data = { counterName = 'coinsCollected', value = coinsCollected, originPos = coinPos } }
    owner.bus.send(setCoinsCollectedCounterMsg, nil, false)
end

local function onTurnStart(message)
    print('Scoreboard onTurnStart')

    movesInTurn = movesInTurn + 1

    if movesInTurn == 4 then
        turnsLeft = turnsLeft - 1
        movesInTurn = 0
        local setTurnsLeftCounterMsg = { metadata = { 'setCounter' }, data = { counterName = 'turnsLeft', value = turnsLeft } }
        owner.bus.send(setTurnsLeftCounterMsg, nil, false)
    end

    if turnsLeft < 0 then
        turnsLeft = 0
    end
end


-- Subscribe to know when a player escapes
game.bus.subscribe('playerEscaped', onPlayerEscaped)
-- Subscribe to know when a player collects a Coin
game.bus.subscribe('coinCollected', onCoinCollected)
-- Subscribe to know when a turn starts
game.bus.subscribe('turnStart', onTurnStart)
