local metaentity = FindMetaTable("Entity")
local metavector = FindMetaTable("Vector")
local metaplayer = FindMetaTable("Player")

function metaentity:IsInHouse(id)
	local pos = self:GetPos()
	if pos:WithinAABox(ghomes.list[id].boxes[1], ghomes.list[id].boxes[2]) then return true end

	return false
end

function ghomes.generatedoors(id)
	-- cleaning old entries
	for k, door in ipairs(ghomes.list[id].doors) do
		door.IsGhomesDoor = nil
		door.House = nil
		door.HouseID = nil
		door.HasPlayerAccess = nil
	end

	ghomes.list[id].doors = {}

	for i, v in ipairs(ghomes.list[id].doorsid) do
		local door = ents.GetMapCreatedEntity(v)
		if not IsValid(door) then
			MsgC(Color(255,255,0),Format("//////////////////////////////\nCouldn't restore door with the CreationID [%i] in house : [%s]\nMaybe you changed the map since the creation, or maybe the door entity was removed or not even created yet RUN THE COMMAND ghomes_RegenDoors TO REGENERATE THE DOORS, THEN RELOAD THE MAP\n//////////////////////////////\n\n", v, ghomes.list[id].name))
			continue
		end

		ghomes.wrapper.gHomeizeDoor(door, id)
		ghomes.list[id].doors[i] = door
		door.IsGhomesDoor = true
		door.House = ghomes.list[id]
		door.HouseID = id
		door.HasPlayerAccess = function(ply)
			if not IsValid(ply) then
				return false
			end

			return ply == door.House.owner or table.HasValue(door.House.friends or {}, ply:SteamID())
		end


	end
end

function metavector:IsInHouse(id)
	return self:WithinAABox(ghomes.list[id].boxes[1], ghomes.list[id].boxes[2])
end

function metaplayer:CanSpawnInHouse(id)
	if (ghomes.list[id].owner == self) or table.HasValue(ghomes.list[id].friends or {}, self:SteamID()) then return true end
	return false
end

function metaplayer:HasAnyHouse(owner_only, purchased_only)
	for k, v in ipairs(ghomes.list) do
		if not v.isrented then continue end
		if purchased_only and not v.ispermarented then continue end
		if v.owner == self then return true end
		if not owner_only and table.HasValue(v.friends,self:SteamID()) then return true end
	end
	return false;
end

function metaplayer:GetHousesName(owner_only, purchased_only)
	local tbl = {}
	for k, v in ipairs(ghomes.list) do
		if not v.isrented then continue end
		if purchased_only and not v.ispermarented then continue end
		if v.owner == self then table.insert(tbl, v.name) continue end
		if not owner_only and table.HasValue(v.friends,self:SteamID()) then table.insert(tbl, v.name) continue end
	end
	return tbl;
end

-- also used for the panel auth rights
function ghomes.lockdoors(id)
	for k, v in pairs(ghomes.list[id].doors) do
		if not IsValid(v) then continue end
		v:Fire("close")
		v:Fire("lock")
	end
end

function ghomes.unlockdoors(id)
	for k, v in pairs(ghomes.list[id].doors) do
		if not IsValid(v) then continue end
		v:Fire("unlock")
	end
end

local function propSpawn(ply, model)
	for k, v in ipairs(ghomes.list) do
		if ply:GetEyeTrace().HitPos:IsInHouse(k) and not ply:CanSpawnInHouse(k) then ply:ChatPrint("You can't spawn a prop here, you don't own the property") return false end
	end
end

local function propSpawned(ply, model, ent)
	for k, v in ipairs(ghomes.list) do
		if ent:GetPos():IsInHouse(k) and not ply:CanSpawnInHouse(k) then return false end
	end
end




hook.Add("PlayerSpawnedProp", "Housesystem_SpawnedProp", propSpawned)


if ghomes.propsSecurity  then
	hook.Add("PlayerSpawnObject", "Housesystem_SpawnEffect", propSpawn)
	hook.Add("PlayerSpawnProp", "Housesystem_SpawnProp", propSpawn)

	timer.Create("HousesPropSecurity", ghomes.propsSecurityDelay, 0, function()
		for houseid, house in ipairs(ghomes.list) do
			for k, v in pairs(ents.FindInBox(house.boxes[1], house.boxes[2])) do
				if (v:GetClass() ~= "prop_physics") then continue end
				local owner = v:CPPIGetOwner()
				if not IsValid(owner) then continue end
				if not owner:CanSpawnInHouse(houseid) then
					--owner:ChatPrint("You can't spawn props on this area : " .. house.name)
					v:Remove()
				end
			end
		end
	end)
else
	hook.Remove("PlayerSpawnObject", "Housesystem_SpawnEffect")
	hook.Remove("PlayerSpawnProp", "Housesystem_SpawnProp")
end
function ghomes.canUseKeyOnDoor(ply, door)
	if (door.IsGhomesDoor) then
		return door.HasPlayerAccess(ply)
	end
end

timer.Create("ghomesAutoExpire", 10, 0, function()
	for k, v in ipairs(ghomes.list) do
		if v.isrented and (
			(not v.ispermarented and v.selltime < os.time()) or
			(not IsValid(v.owner) and ghomes.autosellafternotconnecterforxdays ~= 0 and (v.lastJoin + ghomes.autosellafternotconnecterforxdays) < os.time()) )  then
			ghomes.setowner(false, k)
		end
	end
end)


hook.Add("PlayerDisconnected", "ghomes detect leave",function (ply)
	if ghomes.sellwhenplayerleaves then
		for k, v in ipairs(ghomes.list) do
			if v.owner == ply then
				--[[local found = false
				for k2, v2 in pairs(v.friends or {}) do -- fuck off im lazy
					found = player.GetBySteamID()
					if found then break end
				end
				if found then

				end]]
				ghomes.setowner(false, k)
			end
		end
	end

	for k, v in ipairs(ghomes.list) do
		if v.isrented and v.owner == ply then
			v.lastJoin = os.time()
		end
	end
end)

hook.Add("PlayerInitialSpawnHouse", "AssignHouse", function(ply)

	local hlist = {}

	for k, v in ipairs(ghomes.list) do
		if v.ownersteamid == ply:SteamID() then
			v.owner = ply
			v.lastJoin = os.time() -- can't log it on server end so it's a lil trick
			table.insert(hlist, k)
		end
	end

	if #hlist > 0 then
		net.Start("ghomes_OwnerUpdate")
		net.WriteEntity(ply)
		net.WriteUInt(#hlist, 7)
		local i = 1

		while (i <= #hlist) do
			net.WriteUInt(hlist[i], 7)
			i = i + 1
		end

		net.Broadcast()
	end

	for k, v in pairs(hlist) do
		if (ghomes.shouldsaveprops and (not FPP or (not FPP.DisconnectedPlayers[ply:SteamID()]))) then -- don't restore if the props are not even removed m8
			ghomes.restoreprops(v, ply)
		end
	end
	if ghomes.dlcs.dlc1 and not ply._ghome_spawned then
		ply._ghome_spawned = true -- you silly cheater
		local list = ghomes.dlcs.dlc1.generateSpawnableHouses(ply)
		if (#list > 0) then
			ghomes.dlcs.dlc1.randomSpawn(ply, list[1])
		end
		ghomes.dlcs.dlc1.restoreentities(ply)
	end
end)

hook.Add("ShutDown","ghomes_save", function()
	if ghomes.sellwhenplayerleaves then
		for k, v in ipairs(ghomes.list) do
			ghomes.setowner(false, k) -- sell all houses
		end
	end

	if ghomes.dlcs.dlc1 then
		for k, v in pairs(player.GetAll()) do
			ghomes.dlcs.dlc1.saveentities(v)
		end
	end
	for k, v in ipairs(ghomes.list) do
		ghomes.savehouse(k)
	end
end)


if ghomes.emulate2Dmode then
	hook.Add("ShowTeam", "gHomes door menu", function(ply)
		if not IsValid(ply) then return end
		if not ply:Alive() then return end
		local trace = ply:GetEyeTrace()
		local target = trace.Entity
		if not IsValid(target) then return end
		local distanceHit = ply:EyePos():DistToSqr(trace.HitPos)
		if distanceHit > 4000 then return end
		if not target.IsGhomesDoor then return end
		local id = target.HouseID
		net.Start("ghomes_door_f2")
		net.WriteUInt(id, 7)
		net.Send(ply)

		return true -- overwrite other hooks
	end)
else
	hook.Remove("ShowTeam", "gHomes door menu")
end