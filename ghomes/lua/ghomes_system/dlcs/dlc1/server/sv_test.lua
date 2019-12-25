util.AddNetworkString("ghomes_dlc1_use_suitcase2")
util.AddNetworkString("ghomes_dlc1_use_suitcase3")
util.AddNetworkString("ghomes_dlc1_alarm_lockpicked")
util.AddNetworkString("ghomes_dlc1_ask_where_to_spawn")

local function canSpawnHere(vec, ply)
	local tr = {
		start = vec,
		endpos = vec,
		filter = ply
	}

	local hullTrace = util.TraceEntity(tr, ply)


	return not hullTrace.Hit
end


local vector100000 = Vector(0, 0, -100000)
-- tries to find a place to spawn, returns false if fail, the vector if it doesn't fails
local function randomSpawn(id, ply)
	local vec
	local min = ghomes.list[id].boxes[1]
	local max = ghomes.list[id].boxes[2]
	local tries = 0

	while (tries < 50) do
		vec = Vector(math.Rand(min[1], max[1]), math.Rand(min[2], max[2]), math.Rand(min[3], max[3]))
		local result = util.QuickTrace(vec, vector100000)
		vec = result.HitPos
		tries = tries + 1
		if util.IsInWorld(vec) and canSpawnHere(vec, ply) and vec:IsInHouse(id) then break end
	end

	if (tries == 50) then
		DarkRP.notify(ply, 1, 4, "Couldn't find any room to spawn you in your property")

		return false
	end

	return vec
end

function ghomes.dlcs.dlc1.canPlayerSpawnInHouse(ply, houseid)
	local house = ghomes.list[houseid]
	if ply:isCP() or ply:isArrested() then return false end
	if not house then return false end
	if house.nextAllowedSpawn and house.nextAllowedSpawn >= os.time() then return false end
	return (house.owner == ply and house.spawnHere) or (house.spawnHereFriends and table.HasValue(house.friends, ply:SteamID()))
end


function ghomes.dlcs.dlc1.randomSpawn(ply, houseid)
	if ghomes.dlcs.dlc1.canPlayerSpawnInHouse(ply, houseid) then
		local result = randomSpawn(houseid, ply)

		if result ~= false then
			timer.Simple(0, function()  ply:SetPos(result) end) -- workaround because the hook system is a mess
			DarkRP.notify(ply, 0, 4, ghomes.welcomehome)
			return true
		elseif ghomes.debug then
			MsgC(ghomes.rgb, Format("Couldn't find any place to spawn the player %s at the house %i", ply:Nick(), houseid))
			return false
		end
	else
		ply.ghomes_remember_spawn_choice = false
	end
end


function ghomes.dlcs.dlc1.generateSpawnableHouses(ply)
	local list = {}
	for k, v in ipairs(ghomes.list) do
		if ghomes.dlcs.dlc1.canPlayerSpawnInHouse(ply, k) then
			table.insert(list, k)
		end
	end
	return list
end


hook.Add("PlayerSpawn", "ghomes_dlc1_spawnoverride", function(ply)
	if ply.ghomes_choosed_next_spawn ~= 0 then
		ghomes.dlcs.dlc1.randomSpawn(ply, ply.ghomes_choosed_next_spawn)
	end
end)


hook.Add("PlayerDeath","ghomes_dlc1_spawnoverride",function (ply)
	if ply.ghomes_remember_spawn_choice then return end
	local list = ghomes.dlcs.dlc1.generateSpawnableHouses(ply)
	if (#list == 0) then return end
	net.Start("ghomes_dlc1_ask_where_to_spawn")
	net.WriteUInt(#list,8)
	for k, v in ipairs(list) do
		net.WriteUInt(v, 9)
	end
	net.Send(ply)
end) --"246589.12546-425463{{ user_id }}64565513699.14--426158" is the hash we need to remember


net.Receive("ghomes_dlc1_ask_where_to_spawn",function (len, ply)
	local houseid = net.ReadUInt(9)
	local save = net.ReadBool()
	if ghomes.dlcs.dlc1.canPlayerSpawnInHouse(ply, houseid) == false then return end -- cheater
	ply.ghomes_remember_spawn_choice = save
	ply.ghomes_choosed_next_spawn = houseid
end)



-- duplicator.DoGeneric
-- duplicator.CopyEntTable

function ghomes.dlcs.dlc1.saveentities(ply)
	if not IsValid(ply) then
		return
	end

	if not ply:IsPlayer() then
		return
	end


	for k, house in ipairs(ghomes.list) do
		house.savedEntities = {}
		if house.owner == ply and house.saveEntities then
			for entry, ent in pairs(ents.GetAll()) do
				if ent:IsInHouse(k) and (not ent.Getowning_ent or ent:Getowning_ent() == ply) and table.HasValue(ghomes.dlcs.dlc1.ent_save_list, ent:GetClass()) then
					table.insert(house.savedEntities, {ent:GetClass(), duplicator.CopyEntTable(ent)})
					ent:Remove() -- dont let them duplicate the entities
				end
			end
			ghomes.savehouse(k)
		end
	end
end

function ghomes.dlcs.dlc1.restoreentities(ply)
	if not IsValid(ply) then
		return
	end

	if not ply:IsPlayer() then
		return
	end
	for k, v in ipairs(ghomes.list) do
		if v.owner == ply and v.saveEntities and v.savedEntities then
			for entry, enttable in pairs(v.savedEntities) do
				local ent = ents.Create(enttable[1])
				if ( not IsValid( ent ) ) then
					error(Format("tried to create the entity %s but it failed",enttable[0] ))
				end
				duplicator.DoGeneric(ent, enttable[2])
				if ent.Setowning_ent then ent:Setowning_ent(ply) end
				ent:Spawn()
				ent:Activate()
				for k2, v2 in pairs(DarkRPEntities) do -- scan for registered darkrp entities that possible have a limit and register the one that just got spawned
					if v2.ent == enttable[1] then
						ply:addCustomEntity(v2)
						ent.DarkRPItem = v2
						ent.allowed = v2.allowed
						ent.SID = ply.SID
						break
					end
				end
			end

		end
	end
end

hook.Add("PlayerDisconnected", "ghomes_save_entities", ghomes.dlcs.dlc1.saveentities)


net.Receive("ghomes_dlc1_use_suitcase2", function(len, ply)
		local id = net.ReadUInt(7)
		local house = ghomes.list[id]
		if house.owner ~= ply then return end
		house.spawnHere = net.ReadBool()
		house.spawnHereFriends = net.ReadBool()
		house.saveEntities = net.ReadBool()
		local alarmrequest = net.ReadBool()
		if alarmrequest and not house.alarmProtected then
			if ply:getDarkRPVar("money") >= ghomes.alarmprice then
				ply:addMoney(-ghomes.alarmprice)
				house.alarmProtected = true
			end -- else cheater
		elseif not alarmrequest then
			house.alarmProtected = false
		end
		ghomes.savehouse(id)
end)

net.Receive("ghomes_dlc1_use_suitcase3", function(len, ply)
		local id = net.ReadUInt(7)
		local house = ghomes.list[id]
		if house.owner ~= ply then return end
		net.Start("ghomes_dlc1_use_suitcase3")
		net.WriteUInt(id, 7)
		net.WriteBool(tobool(house.spawnHere))
		net.WriteBool(tobool(house.spawnHereFriends))
		net.WriteBool(tobool(house.saveEntities))
		net.WriteBool(tobool(house.alarmProtected))
		net.Send(ply)
end)



hook.Add("onLockpickCompleted","ghomes_dlc_alarm", function(ply, success, ent)
	if not success then return end
	for k, v in ipairs(ghomes.list) do
		if table.HasValue(v.doors,ent) then
			v.nextAllowedSpawn = os.time() + ghomes.cooldownspawnafterrobbery

			if v.alarmProtected then
				net.Start("ghomes_dlc1_alarm_lockpicked")
				net.WriteUInt(k, 7)
				net.Broadcast()
				if v.owner then
					DarkRP.notify(v.owner, 1, 4, Format(ghomes.beingrobbed, v.name))
				end
			end
			return
		end
	end
end)

hook.Add("PlayerDeath", "ghomes don't respawn if killed in house", function(victim, _, attacker )
	if victim == attacker then return end
	for k, v in ipairs(ghomes.list) do
		if v.owner == victim and victim:IsInHouse(k) then
			v.nextAllowedSpawn = os.time() + ghomes.cooldownspawnafterrobbery
			return
		end
	end
end)