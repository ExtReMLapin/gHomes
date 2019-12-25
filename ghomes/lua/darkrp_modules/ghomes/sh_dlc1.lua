DarkRP.createCategory{
	name = "gHomes",
	categorises = "entities",
	startExpanded = true,
	color = Color(0, 107, 0, 255),
	canSee = function(ply)
		return true
	end,
	sortOrder = 100
}


local posOffset =  Vector(0, 0, 10)
local ang180 = Angle(0, 180, 0)
DarkRP.createEntity("gHomes Control Case", {
	ent = "ghomes_suitcase",
	model = "models/ghomes/ghomes_case.mdl",
	price = 2000,
	max = 1,
	cmd = "buyghomescommandercase",
	category = "gHomes",
	sortOrder = 100,
	allowTools = false,
	spawn = function(ply, tr, tblEnt)
		local ent = ents.Create("ghomes_suitcase")
		tr.HitPos:Add(posOffset)
		local angle = Angle(0, ply:GetAngles().y, 0)
		angle:Add(ang180)
		ent:SetPos(tr.HitPos)
		ent:SetAngles(angle)
		ent:Spawn()
		ent:Activate()
		ent:PhysWake()
		return ent
	end
})
