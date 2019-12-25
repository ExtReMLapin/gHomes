local function init ()
	if CLIENT then return end

	hook.Add("canKeysUnlock", "housessystemownerbuddy", ghomes.canUseKeyOnDoor)
	hook.Add("canKeysLock", "housessystemownerbuddy", ghomes.canUseKeyOnDoor)


	local strfile = file.Read("weapons/keys/shared.lua", "LUA")

	timer.Create("retardsGHomes", 5, 0, function()
		local found = false
		if strfile and string.find(strfile, "not ent:getKeysNonOwnable() and") then
			found = true

			for k, v in pairs(player.GetAll()) do
				if not v:CanMasterHouse() then continue end
				v:ChatPrint("You can't use keys on the doors because the file gamemode/darkrp/entities/weapons/keys/shared.lua is outdated, DOWNLOAD THE LAST DARKRP VERSION ON GITHUB (the .ZIP) OR MANUALLY UPDATE IT (THE FILE)")
			end
		end

		if found == false then
			timer.Remove("retardsGHomes")
		end
	end)


	hook.Add("PostCleanupMap", "ghomesdoorsfix", function()
		timer.Simple(0.1, function() -- because hook.Add("PostCleanupMap", "DarkRP.hooks", function() can be ran right after
			for id, v in ipairs(ghomes.list) do
				ghomes.generatedoors(id)
			end
		end)
	end)

	hook.Add("canDoorRam", "housessystemownerbuddy", function(ply, trace, ent)
		local class = ent:GetClass()
		if not ghomes.IsDoorOkayForHouse(class) then return nil end
		if not ent:getKeysNonOwnable() then return nil end
		local house = false

		for k, v in ipairs(ghomes.list) do
			if table.HasValue(v.doors, ent) then
				house = k
			end
		end

		if not house then return nil end
		local found = false

		for k, v in pairs(player.GetAll()) do
			if (table.HasValue(ghomes.list[house].friends or {}, v:SteamID()) or ghomes.list[house].owner == v) and v.warranted then
				found = true
			end
		end

		-- check for online co-owner/owner
		if found then
			ent:keysUnLock()
			ent:Fire("open", "", .6)
			ent:Fire("setanimation", "open", .6)
			if ghomes.dlcs.dlc1 then
				ghomes.list[house].nextAllowedSpawn = os.time() + ghomes.cooldownspawnafterrobbery
				if ghomes.list[house].alarmProtected then
					net.Start("ghomes_dlc1_alarm_lockpicked")
					net.WriteUInt(house, 7)
					net.Broadcast()
				end
			end

			return true
		end

		return false
	end)


end

local function getMoney(ply)
	return ply:getDarkRPVar("money")
end

local function addMoney(ply, amount)
	ply:addMoney(amount)
	return
end

local function formatMoney(amount)
	return DarkRP.formatMoney(amount)
end

local function notify(ply, type, time, message)
	DarkRP.notify(ply,  type, time, message)
end


local function gHomeizeDoor(door, id)
	door:setKeysNonOwnable(true)
	door:setKeysTitle(ghomes.list[id].name)
end

local function un_gHomeizeDoor(door, id)
	door:setKeysNonOwnable(false)
	door:setKeysTitle("For sale")
end

local function canSpawnInHome(ply)
	if ply:isCP() or ply:isArrested() then
		return false
	end
	return true
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