ghomes.net = {}

if CLIENT then
	include("client/network.lua")
else
	include("server/network.lua")
end

function ghomes.net.writeHouse(houseID)
	if ghomes.list[houseID] then
		net.WriteUInt(ghomes.list[houseID].permaprice, 32)
		net.WriteUInt(ghomes.list[houseID].rentprice, 32)
		net.WriteUInt(ghomes.list[houseID].buyablemode, 3)

		if SERVER then
			net.WriteBool(ghomes.list[houseID].isrented)
			net.WriteBool(ghomes.list[houseID].ispermarented)

			if (ghomes.list[houseID].isrented and not ghomes.list[houseID].ispermarented) then
				net.WriteUInt(math.Max(0, ghomes.list[houseID].selltime - os.time()), 32)
			end

			net.WriteUInt(#ghomes.list[houseID].doorsid, 8)
		end

		net.WriteString(ghomes.list[houseID].name)
		net.WriteTable(ghomes.list[houseID].boxes)
		net.WriteTable(ghomes.list[houseID].panelpos)
		net.WriteTable(ghomes.list[houseID].panelangle)
		net.WriteVector(ghomes.list[houseID].textpos)
		net.WriteAngle(ghomes.list[houseID].textangle)
		net.WriteVector(ghomes.list[houseID].bellpos)
		net.WriteVector(ghomes.list[houseID].camerapos)
		net.WriteAngle(ghomes.list[houseID].cameraangle)

		if SERVER then
			net.WriteTable(ghomes.list[houseID].friends or {})
			net.WriteTable(ghomes.list[houseID].friendsname or {})
			net.WriteString(ghomes.list[houseID].ownername or "")
			net.WriteString(ghomes.list[houseID].ownersteamid or "")

			if IsValid(ghomes.list[houseID].owner) then
				net.WriteBool(true)
				net.WriteEntity(ghomes.list[houseID].owner)
			else
				net.WriteBool(false)
			end
		end
	end
end

-- server -> send already owned/created house to client | client -> send house generated with the tool
function ghomes.net.readHouse()
	local tblhouse = {}
	tblhouse.permaprice = net.ReadUInt(32)
	tblhouse.rentprice = net.ReadUInt(32)
	tblhouse.buyablemode = net.ReadUInt(3)

	if CLIENT then
		tblhouse.isrented = net.ReadBool()
		tblhouse.ispermarented = net.ReadBool()

		if (tblhouse.isrented and not tblhouse.ispermarented) then
			tblhouse.selltime = os.time() + net.ReadUInt(32) -- secs left of sell
		else
			tblhouse.selltime = 0
		end

		tblhouse.ndoors = net.ReadUInt(8)
	end

	tblhouse.name = net.ReadString() -- name
	tblhouse.boxes = net.ReadTable() -- vector box table
	tblhouse.panelpos = net.ReadTable() -- panel pos table
	tblhouse.panelangle = net.ReadTable() -- panel angle table
	tblhouse.textpos = net.ReadVector()
	tblhouse.textangle = net.ReadAngle()
	tblhouse.bellpos = net.ReadVector()
	tblhouse.camerapos = net.ReadVector()
	tblhouse.cameraangle = net.ReadAngle()

	if CLIENT then
		tblhouse.friends = net.ReadTable()
		tblhouse.friendsname = net.ReadTable()
		tblhouse.ownername = net.ReadString() -- owner name
		tblhouse.ownersteamid = net.ReadString()

		if net.ReadBool() then
			tblhouse.owner = net.ReadEntity()
		else
			tblhouse.owner = NULL
		end
	end

	tblhouse.panels = {}

	return tblhouse
end