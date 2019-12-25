concommand.Add("ghomes_debug_door",function(ply)
	if not ply:CanMasterHouse() then return end
	local ent = ply:GetEyeTrace().Entity

	if not IsValid(ent) then ply:ChatPrint("NULL ENTITY") return end
	if not ghomes.IsDoorOkayForHouse(ent:GetClass()) then  ply:ChatPrint("wrong entity class") return end
	if ent:MapCreationID() == -1 then ply:ChatPrint("Entity wasn't created by the map") return end
	local found1 = false
	local id = ent:MapCreationID()
	for k, v in ipairs(ghomes.list) do
		if table.HasValue(v.doorsid,id) then found1 = true break end
	end
	local found2 = false
	for k, v in ipairs(ghomes.list) do
		if table.HasValue(v.doors,ent) then found2 = true break end
	end

	ply:ChatPrint(Format("Found ID in db : %s, found door entity in DB : %s", tostring(found1), tostring(found2)))

end)

concommand.Add("ghomes_RegenDoors",function (ply)
	if not IsValid(ply) then
		print("you were supposed to type it in your CLIENT console you silly goose, buy let's do it anyway...")
	else
		if not ply:CanMasterHouse() then return end
	end

	for _k, tblhouse in ipairs(ghomes.list) do
		tblhouse.doorsid = {}

		for k, v in pairs(ents.FindInBox(tblhouse.boxes[1], tblhouse.boxes[2])) do
			local class = v:GetClass()
			if not ghomes.IsDoorOkayForHouse(class) then continue end

			local id2 = v:MapCreationID()

			if (id2 ~= -1) then
				table.insert(tblhouse.doorsid, id2)
			end
		end
		ghomes.generatedoors(_k)
		ghomes.savehouse(_k)
	end
end)
