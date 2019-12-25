local function init()
	hook.Add("CanPlayerAccessDoor", "housessystemownerbuddy", ghomes.canUseKeyOnDoor)
end


local function getMoney(ply)
	return ply:getChar():getMoney()
end

local function addMoney(ply, amount)
	return ply:getChar():giveMoney(amount)
end

local function formatMoney(amount)
	return nut.currency.get(amount)
end


local function notify(ply, type, time, message)
	ply:ChatPrint(message)
end



local function gHomeizeDoor(door, id)
	door:setNetVar("name", ghomes.list[id].name)
	door:setNetVar("noSell", true)
end

local function un_gHomeizeDoor(door, id)
	door:setNetVar("noSell", false)
end

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