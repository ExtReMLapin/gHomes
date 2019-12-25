
local function init()
	hook.Add("CanPlayerAccessDoor", "housessystemownerbuddy", ghomes.canUseKeyOnDoor)
end


local function getMoney(ply)
	return ply:GetCharacter():GetMoney()
end


local function addMoney(ply, amount)
	ply:GetCharacter():GiveMoney(amount)
end

local function formatMoney(amount)
	return ix.currency.get
end

local function notify(ply, type, time, message)
	ply:ChatPrint(message)
end


local function gHomeizeDoor(door, id)
	door:SetNetVar("name", ghomes.list[id].name)
	door:SetNetVar("ownable", false)
end

local function un_gHomeizeDoor(door, id)
	door:SetNetVar("ownable", true)
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