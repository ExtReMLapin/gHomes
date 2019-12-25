
-- specific code to run for this gamemode, could be hooks to be added or anything else
local function init() end


-- function to get the money the player has
local function getMoney(ply)
	return math.huge
end


-- function to add (or remove) money to the player
local function addMoney(ply, amount)
	return
end

-- turn a string (int/double) to string with currency 
local function formatMoney(amount)
	return '$' .. tostring(amount)
end

-- send a message to the player
local function notify(ply, type, time, message)
	ply:ChatPrint(message)
end


-- stop players from being able to buy this door using the gamemode default door system
local function gHomeizeDoor(door, id)

end


-- allow back the players to use the gamemode door system on a door to buy it
local function un_gHomeizeDoor(door, id)

end

--funcs used by dlc1 to check if player is arrested or a cop, to prevent him from spawning in home when he shouldn't
local function canSpawnInHome(ply)
	return false
end

return
{
	init = init,
	getMoney = getMoney,
	addMoney = addMoney,
	formatMoney = formatMoney,
	notify = notify,
	gHomeizeDoor = gHomeizeDoor,
	un_gHomeizeDoor = un_gHomeizeDoor,
	canSpawnInHome = canSpawnInHome
}