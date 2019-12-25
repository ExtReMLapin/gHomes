local function vectotbl(vec, isangle)
	if isangle then
		return {vec.p, vec.y, vec.r}
	else
		return {vec.x, vec.y, vec.z}
	end
end

local function generateproplist(ply, id)
	local tbl = {}
	tbl.ents = {}
	tbl.pos = {}
	tbl.angles = {}
	tbl._ents = {}

	local house = ghomes.list[id]


	for k, v in pairs(ents.FindInBox(house.boxes[1], house.boxes[2])) do
		if not IsValid(v) or v:GetClass() ~= "prop_physics" or v:CPPIGetOwner() ~= ply then continue end
		local pos = v:GetPos() -- only call the function once
		local modelstr = string.gsub(v:GetModel(), "\\", "/")
		table.insert(tbl.ents, modelstr)
		table.insert(tbl._ents, v)
		table.insert(tbl.pos, vectotbl(pos, false))
		table.insert(tbl.angles, vectotbl(v:GetAngles(), true))
	end

	return tbl
end

function ghomes.saveprops(id)
	if ghomes.list[id].isrented == false then
		return
	end

	local owner = ghomes.list[id].owner

	if owner == NULL or not IsValid(owner) then
		if ghomes.debug then
			MsgC(ghomes.rgb, "Player with SteamID " .. ghomes.list[id].ownersteamid .. " is not connected !\n")
		end

		return
	end

	if ghomes.debug then
		MsgC(ghomes.rgb, "===Adding prop for house : " .. ghomes.list[id].name .. " ...")
	end

	ghomes.list[id].props = generateproplist(owner, id)

	if ghomes.debug then
		MsgC(ghomes.rgb, "Done !\n")
	end
	ghomes.savehouse(id)
end

function ghomes.restoreprops(id, ply)
	if ghomes.debug then
		MsgC(ghomes.rgb, "Restoring props for house : " .. ghomes.list[id].name .. " ...")
	end

	if ghomes.list[id].props and ghomes.list[id].props.ents and #ghomes.list[id].props.ents > 0 then
		ghomes.list[id].props._ents = {}

		for k, v in pairs(ghomes.list[id].props.ents) do
			local tmpent = ents.Create("prop_physics")
			tmpent:SetModel(v)
			tmpent:SetPos(Vector(ghomes.list[id].props.pos[k][1], ghomes.list[id].props.pos[k][2], ghomes.list[id].props.pos[k][3]))
			tmpent:SetAngles(Angle(ghomes.list[id].props.angles[k][1], ghomes.list[id].props.angles[k][2], ghomes.list[id].props.angles[k][3]))
			tmpent:SetSolid(SOLID_VPHYSICS)
			tmpent:PhysicsInit(SOLID_VPHYSICS)
			tmpent:GetPhysicsObject():EnableMotion(false)
			tmpent:CPPISetOwner(ply)
			table.insert(ghomes.list[id].props._ents, tmpents)
			if ( IsValid( ply ) ) then
				gamemode.Call( "PlayerSpawnedProp", ply, v, tmpent )
				undo.Create( "Prop" )
					undo.SetPlayer( ply )
					undo.AddEntity( tmpent )
				undo.Finish( "Prop (" .. tostring( v ) .. ")" )

				--ply:AddCleanup( "props", tmpent )
			end
		end
	else
		if ghomes.debug then
			MsgC(ghomes.rgb, "No props found for this house !\n")
		end
	end

	if ghomes.debug then
		MsgC(ghomes.rgb, "Done !\n")
	end
end

if ghomes.shouldsaveprops then
	timer.Create("HousesCheckSaveProps", ghomes.delayPropSaving, 0, function()
		if ghomes.debug then
			MsgC(ghomes.rgb, "Started generating props save ...\n")
		end

		for k, v in ipairs(ghomes.list) do
			ghomes.saveprops(k)
		end
	end)
end