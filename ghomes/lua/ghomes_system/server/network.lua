util.AddNetworkString("ghomes_force_sell")
util.AddNetworkString("ghomes_delete_home")
util.AddNetworkString("ghomes_reset_data")
util.AddNetworkString("ghomes_gettable")
util.AddNetworkString("ghomes_getsingletable")
util.AddNetworkString("ghomes_command")
util.AddNetworkString("ghomes_newhouse")
util.AddNetworkString("ghomes_newhousecl")
util.AddNetworkString("ghomes_OwnerUpdate")
util.AddNetworkString("ghomes_bell")
util.AddNetworkString("ghomes_tp")
util.AddNetworkString("ghomes_npc_use")
util.AddNetworkString("ghomes_door_f2")

net.Receive("ghomes_force_sell",function (len, ply)
	if not ply:CanMasterHouse() then return end
	ghomes.setowner(false, net.ReadUInt(7))
end)


net.Receive("ghomes_delete_home",function (len, ply)
	if not ply:CanMasterHouse() then return end
	local id = net.ReadUInt(7);
	for k, v in ipairs(ghomes.list) do -- experimental list, deleting the WHOLE INCREMENTAL SAVELIST TO REBUILD IT
		if (k < id) then continue end
		ghomes.deletefilehome(k)
	end
	for k, v in pairs(ghomes.list[id].doors) do
		if not IsValid(v) then continue end
		v:Fire("unlock")
		ghomes.wrapper.un_gHomeizeDoor(v, id)
	end
	table.remove(ghomes.list, id)
	for k, v in ipairs(ghomes.list) do -- then rebuild it
		ghomes.savehouse(k)
	end
	net.Start("ghomes_reset_data")
	net.Broadcast()
	ghomes.net.BroadcastData()
end)

function ghomes.net.SingleHousedata(ply, id)
	net.Start("ghomes_getsingletable")
	net.WriteUInt(id, 7)
	ghomes.net.writeHouse(id)
	net.Send(ply)
end

function ghomes.net.BroadCastSingleHouseData(id)
	net.Start("ghomes_getsingletable")
	net.WriteUInt(id, 7)
	ghomes.net.writeHouse(id)
	net.Broadcast()
end

function ghomes.net.BroadcastData()
	for k, v in ipairs(ghomes.list) do
		ghomes.net.BroadCastSingleHouseData(k)
	end
end

function ghomes.net.BroadcastDataply(ply)
	for k, v in ipairs(ghomes.list) do
		ghomes.net.SingleHousedata(ply, k)
	end
end

local veryfirstinit = false

net.Receive("ghomes_gettable", function(len, ply)
	if not veryfirstinit then
		if not ghomes.wrapper.init then ghomes.SetupWrapper() end
		if ghomes.debug then
			MsgC(ghomes.rgb, "Restoring all ghomes...\n")
		end
		ghomes.restorehouses()
		ghomes.mail.restoremails()
		veryfirstinit = true
	end

	ghomes.net.BroadcastDataply(ply)
	net.Start("ghomes_newmail")
	local n

	if ghomes.mail[ply:SteamID64()] then
		n = #ghomes.mail[ply:SteamID64()]
	else
		n = 0
	end

	net.WriteUInt(n, 7)
	net.Send(ply)
	hook.Run("PlayerInitialSpawnHouse", ply)
end)

net.Receive("ghomes_tp", function(len, ply)
	if not ply:CanMasterHouse() then return end
	local id = net.ReadUInt(7)
	local house = ghomes.list[id]
	local pos = house.boxes[1] + (house.boxes[2] - house.boxes[1]) / 2
	ply:SetPos(pos)
end)

net.Receive("ghomes_command", function(len, ply)
	local id = net.ReadUInt(7)
	local command = net.ReadUInt(4)
	local house = ghomes.list[id]
	if not house then return end
	if not IsValid(ply) then return end -- there is no reason this shit happen but whatever

	if command == 0 and not house.isrented then
		local permabuy = net.ReadBool()
		local renttime
		local rentprice

		if not permabuy then
			renttime = net.ReadUInt(32)
			rentprice = ghomes.timetorentprice(id, renttime)
		end

		if (house.buyablemode == 1) or (permabuy and house.buyablemode == 2) or (not permabuy and house.buyablemode == 3) then
			local money = ghomes.wrapper.getMoney(ply)
			local nhouses = 0

			for k, v in ipairs(ghomes.list) do
				if v.owner == ply then
					nhouses = nhouses + 1
				end
			end

			if nhouses >= ghomes.maxpropertiesperuser then
				ghomes.wrapper.notify(ply, 1, 4, Format("You can't live in more than %i houses",ghomes.maxpropertiesperuser) )
				return
			end

			if (permabuy and money >= house.permaprice) or (not permabuy and money >= rentprice) then
				ghomes.setowner(ply, id, permabuy, renttime) -- give house to the guy

				if not permabuy then
					ghomes.wrapper.addMoney(ply, -rentprice)
				else
					ghomes.wrapper.addMoney(ply, -house.permaprice)
				end
			else
				-- need more money
				if (permabuy) then
					ghomes.wrapper.notify(ply, 1, 4, "You don't have enough money")
				else
					ghomes.wrapper.notify(ply, 1, 4, Format("With your money you can only rent the home for %f days", money / rentprice))
				end
			end
		else
			-- exploiter
			ghomes.wrapper.notify(ply, 1, 4, "lol no")
			error("Wrong buy mode, it's not available, possible exploiter found : " .. ply:SteamID64())
		end
	end

	-- purchase
	if command == 1 then
		if not ply.lastbell then
			ply.lastbell = 0
		end

		local found = false
		for k, v in pairs(house.panelpos) do
			if (ply:EyePos():DistToSqr(v) < (100 * 100)) then
				found = true
				break;
			end
		end

		if found and (CurTime() - ply.lastbell > 4) then
			net.Start("ghomes_bell")
			net.WriteUInt(id, 7)
			net.Broadcast()
			ply.lastbell = CurTime()
		end
	end

	-- bell
	if command == 2 and house.isrented and ply == house.owner then
		if house.ispermarented then
			ghomes.wrapper.addMoney(ply, house.permaprice * ghomes.percentageOnSell)
		end

		ghomes.setowner(false, id)
	end -- sell

	if command == 3 and house.isrented and ply == house.owner then
		local tbl1 = net.ReadTable() -- lazy nigga
		local tbl2 = net.ReadTable()
		ghomes.list[id].friendsname = tbl1
		ghomes.list[id].friends = tbl2
		ghomes.savehouse(id)
		ghomes.net.BroadCastSingleHouseData(id)

		return
	end

	if command == 4 and house.isrented and ply == house.owner and not house.ispermarented then
		local time = net.ReadUInt(32)
		local rentprice = ghomes.timetorentprice(id, time)
		local money = ghomes.wrapper.getMoney(ply)

		if money < rentprice then
			ghomes.wrapper.notify(ply, 1, 4, "You don't have enough money")

			return
		end

		ghomes.wrapper.addMoney(ply, -rentprice)
		ghomes.setowner(ply, id, false, time)

		return
	end
end)

function ghomes.setowner(ply, id, isperma, renttime)
	if ply == false then
		ghomes.list[id].owner = NULL
		ghomes.list[id].ownername = ""
		ghomes.list[id].ownersteamid = ""
		ghomes.list[id].friends = {}
		ghomes.list[id].friendsname = {}
		ghomes.list[id].props = {}
		ghomes.list[id].selltime = nil
		ghomes.list[id].ispermarented = false
		ghomes.list[id].isrented = false
		ghomes.list[id].spawnHere = false
		ghomes.list[id].alarmProtected = false
		ghomes.list[id].spawnHereFriends = false
		ghomes.list[id].saveEntities = false
		ghomes.list[id].savedEntities = nil
		ghomes.list[id].lastJoin = nil
		hook.Run("SoldPermaHouse", id, ply)
	else
		if ghomes.list[id].isrented then
			for k, v in pairs(ghomes.list[id].friends or {}) do
				if v == ply:SteamID() then
					table.remove(ghomes.list[id].friends, k)
					table.remove(ghomes.list[id].friendsname, k)
					break
				end
			end

			-- remove new owner from friendlist
			ghomes.list[id].props = ghomes.list[id].props or {}

			for k, v in pairs(ghomes.list[id].props._ents or {}) do
				v:CPPISetOwner(ply)
			end

			if renttime then
				ghomes.list[id].selltime = os.time() + renttime
			end
		else
			-- also give him the props
			-- or {} because if not prop saved
			-- if new purchase/rent
			ghomes.list[id].isrented = true

			if (isperma) then
				ghomes.list[id].ispermarented = true
				ghomes.list[id].selltime = 0
			else
				ghomes.list[id].ispermarented = false
				ghomes.list[id].selltime = os.time() + renttime
			end
		end

		-- if transfer
		-- if right transfer
		-- don't reset timestamp just because he gave you the rights, it does prevent infinite house exploit
		-- aka if it's a right transfer and not a buy
		ghomes.list[id].owner = ply
		ghomes.list[id].ownersteamid = ply:SteamID()
		ghomes.list[id].ownername = ply:Nick()
		ghomes.list[id].lastJoin = os.time()
		hook.Run("BoughtPermaHouse", id, ply, isperma)
	end

	ghomes.unlockdoors(id) -- to prevent this : inb4 you buy house, put someone in it, lock every doors, sell it, and he's too poor to buy the house
	ghomes.savehouse(id)
	ghomes.net.BroadCastSingleHouseData(id)
end

net.Receive("ghomes_newhouse", function(len, ply)
	if not ply:CanMasterHouse() then return end
	local frommenu = net.ReadBool()
	local id = net.ReadUInt(7)
	local new = id == 0

	if (id == 0) then
		id = #ghomes.list + 1
	end

	-- new house, don't let the client choose the ID if creating a new one
	local tblhouse = ghomes.net.readHouse()
	tblhouse.doorsid = {}
	tblhouse.doors = {}

	for k, v in pairs(ents.FindInBox(tblhouse.boxes[1], tblhouse.boxes[2])) do
		local class = v:GetClass()
		if not ghomes.IsDoorOkayForHouse(class) then continue end

		local id2 = v:MapCreationID()
		if (id2 ~= -1) then
			table.insert(tblhouse.doorsid, id2)
		end
	end

	if (new) then
		tblhouse.friends = {}
		tblhouse.friendsname = {}
		tblhouse.ownername = ""
		tblhouse.ownersteamid = ""
		tblhouse.isrented = false
		tblhouse.ispermarented = false
	else
		tblhouse.isrented = ghomes.list[id].isrented
		tblhouse.ispermarented = ghomes.list[id].ispermarented
		tblhouse.selltime = ghomes.list[id].selltime
		tblhouse.friends = ghomes.list[id].friends or {}
		tblhouse.friendsname = ghomes.list[id].friendsname or {}
		tblhouse.ownername = ghomes.list[id].ownername or ""
		tblhouse.ownersteamid = ghomes.list[id].ownersteamid or ""
		tblhouse.owner = ghomes.list[id].owner
	end

	ghomes.list[id] = tblhouse
	ghomes.generatedoors(id)
	ghomes.lockdoors(id)
	ghomes.savehouse(id)
	ghomes.net.BroadCastSingleHouseData(id)

	if not frommenu then
		net.Start("ghomes_newhousecl")
		net.Send(ply)
	end
end)