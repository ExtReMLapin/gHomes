ghomes.render = {}
local doormat = Material("houses/door_open.png")
local bellmat = Material("houses/bell3d.png")
local panelmat = Material("houses/panel.png")

surface.CreateFont("PermaHouses4", {
	font = "Roboto Bk",
	size = ScrW() / 50,
	weight = 1000
})

local metavector = FindMetaTable("Vector")
function metavector:IsInHouse(id)
	return self:WithinAABox(ghomes.list[id].boxes[1], ghomes.list[id].boxes[2])
end

local function torealpos(vec, twoD)
	if twoD then
		return vec:LocalToWorld(vec:OBBCenter()):ToScreen()
	else
		return vec:LocalToWorld(vec:OBBCenter())
	end
end

local drawpngcolor = Color(255, 255, 255, 150)

function ghomes.render.details(houseid, beta)
	local targethouse

	if (isnumber(houseid)) then
		targethouse = ghomes.list[selectedhouse]
	elseif (istable(houseid)) then
		targethouse = houseid
	else
		return
	end

	if not targethouse then return end
	if not targethouse.boxes then return end
	local vec1 = targethouse.boxes[1]
	local vec2 = targethouse.boxes[2]
	if not vec1 then return end

	if not vec2 then
		vec2 = ghomes.getaimingcreate()
	end

	if (beta) then
		vec1, vec2 = ghomes.findrightvector(vec1, vec2)
	end

	local diffvec = vec2 - vec1
	local centerhouse = vec1 + diffvec / 2
	local housewidth = diffvec:Length()
	local dist1 = LocalPlayer():GetPos():Distance(centerhouse)
	local dist = math.Clamp(dist1, housewidth, housewidth * 2.5)
	drawpngcolor.a = math.Remap(dist, housewidth, housewidth * 2.5, 200, 0)

	if drawpngcolor.a < 1 and not beta then
		surface.SetFont("PermaHouses4")
		local tblpos = centerhouse:ToScreen()
		draw.SimpleText("Over Here !", "PermaHouses4", tblpos.x, tblpos.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return
	end

	for k, v in pairs(ents.FindInBox(vec1, vec2)) do
		local class = v:GetClass()
		if not ghomes.IsDoorOkayForHouse(class) then continue end
		local pos2d = torealpos(v, true)
		local x, y = pos2d.x, pos2d.y
		local pos3d = torealpos(v, false)

		if pos3d:ToScreen().visible then
			surface.SetDrawColor(drawpngcolor)
			surface.SetMaterial(doormat)
			surface.DrawTexturedRect(x - 16, y - 16, 32, 32)
		end
	end

	if (targethouse.bellpos) then
		local bellpos = targethouse.bellpos:ToScreen()

		if bellpos.visible then
			surface.SetDrawColor(drawpngcolor)
			surface.SetMaterial(bellmat)
			surface.DrawTexturedRect(bellpos.x - 16, bellpos.y - 16, 32, 32)
		end
	end

	for k, v in pairs(targethouse.panelpos or {}) do
		local tblpos = (v + targethouse.panelangle[k]:Forward() * 25):ToScreen()
		local x = tblpos.x
		local y = tblpos.y
		surface.SetDrawColor(drawpngcolor)
		surface.SetMaterial(panelmat) -- If you use Material, cache it!
		surface.DrawTexturedRect(x - 16, y - 16, 32, 32)
	end
end

local anglnil = Angle(0, 0, 0)
local vecnul = Vector(0, 0, 0)
local barwidth = 7
local vecoffset = Vector(-barwidth / 2, -barwidth / 2, 0)
local color_green = Color(50, 205, 50)
local color_red = Color(255,50,50)
local matren = Material("debug/debugdrawflatpolygons")

function ghomes.render.details2(houseid, beta)
	local targethouse

	if (isnumber(houseid)) then
		targethouse = ghomes.list[houseid]
	elseif (istable(houseid)) then
		targethouse = houseid
	else
		return
	end
	if not targethouse then return end
	if not targethouse.boxes then return end
	local vec1 = targethouse.boxes[1]
	local vec2 = targethouse.boxes[2]

	if not vec1 then return end


	if not vec2 then
		vec2 = ghomes.getaimingcreate()
	end

	if (beta) then
		vec1, vec2 = ghomes.findrightvector(vec1, vec2)
	end

	local color_to_use;

	local editingExisting = isnumber(houseid)
	-- editing existing house
	for k, v in ipairs(ghomes.list) do

		if editingExisting and k == houseid then continue end

		if vec1:IsInHouse(k) or vec2:IsInHouse(k) then
			color_to_use = color_red;
			break
		end
	end
	if not color_to_use then color_to_use = color_green end



	local insidezone = LocalPlayer():GetPos():WithinAABox(vec1, vec2) and LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP
	render.SetMaterial(matren)
	local diffvec = vec2 - vec1
	local h = vec2.z - vec1.z
	local hwidth = Vector(barwidth / 2, barwidth / 2, h)
	render.DrawWireframeBox(vec1, anglnil, vecnul, vec2 - vec1, color_to_use, insidezone) -- fucking hell
	render.DrawBox(vec1, anglnil, vecoffset, hwidth, color_to_use, insidezone) -- origin
	render.DrawBox(vec1 + Vector(diffvec.x, diffvec.y, 0), anglnil, vecoffset, hwidth, color_to_use, insidezone) -- opposite origin
	render.DrawBox(vec1 + Vector(diffvec.x, 0, 0), anglnil, vecoffset, hwidth, color_to_use, insidezone)
	render.DrawBox(vec1 + Vector(0, diffvec.y, 0), anglnil, vecoffset, hwidth, color_to_use, insidezone)
	render.DrawBox(vec1, anglnil, vecoffset, Vector(diffvec.x + barwidth / 2, barwidth / 2, 0), color_to_use, insidezone) -- from origin
	render.DrawBox(vec1 + Vector(0, diffvec.y, 0), anglnil, vecoffset, Vector(diffvec.x + barwidth / 2, barwidth / 2, 0), color_to_use, insidezone)
	render.DrawBox(vec1, anglnil, vecoffset, Vector(barwidth / 2, diffvec.y + barwidth / 2, 0), color_to_use, insidezone) -- from origin
	render.DrawBox(vec1 + Vector(diffvec.x, 0, 0), anglnil, vecoffset, Vector(barwidth / 2, diffvec.y + barwidth / 2, 0), color_to_use, insidezone) -- from origin
	render.DrawBox(vec1 + Vector(0, 0, h), anglnil, vecoffset, Vector(diffvec.x + barwidth / 2, barwidth / 2, 0), color_to_use, insidezone) -- from origin
	render.DrawBox(vec1 + Vector(0, diffvec.y, h), anglnil, vecoffset, Vector(diffvec.x + barwidth / 2, barwidth / 2, 0), color_to_use, insidezone)
	render.DrawBox(vec1 + Vector(0, 0, h), anglnil, vecoffset, Vector(barwidth / 2, diffvec.y + barwidth / 2, 0), color_to_use, insidezone) -- from origin
	render.DrawBox(vec1 + Vector(diffvec.x, 0, h), anglnil, vecoffset, Vector(barwidth / 2, diffvec.y + barwidth / 2, 0), color_to_use, insidezone) -- from origin
end