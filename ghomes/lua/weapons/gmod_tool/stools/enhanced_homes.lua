TOOL.Category = "GHomes"
TOOL.Name = "GHomes tool"


if CLIENT then
	surface.CreateFont("PermaHouses1", {
		font = "Roboto Bk",
		size = 30,
		weight = 1000
	})

	surface.CreateFont("PermaHouses2", {
		font = "Roboto Bk",
		size = 25,
		weight = 1000
	})

	surface.CreateFont("PermaHouses25", {
		font = "Roboto Bk",
		size = 27.5,
		weight = 1000
	})

	surface.CreateFont("PermaHouses3", {
		font = "Roboto Bk",
		size = 30,
		weight = 1000
	})

	surface.CreateFont("PermaHouses35", {
		font = "Roboto Bk",
		size = 35,
		weight = 1000
	})

	surface.CreateFont("PermaHouses15", {
		font = "Roboto Bk",
		size = 21,
		weight = 1000
	})

	language.Add("tool.enhanced_homes.name", "GHomes creation tool")
	language.Add("tool.enhanced_homes.desc", "Follow the instructions on the screen, pressing R when selecting an existing aera allows you to TP to it")
	language.Add("tool.enhanced_homes.0", "")
end

local MODE_SELECTHOUSE = 1
local MODE_LIMITS = 2
local MODE_PANELS = 3
local MODE_BELL = 4
--local MODE_CAMERA = 5;
local MODE_HOUSENAME = 5
local MODE_CAMERA = 6
local MODE_FINALIZE = 7

local function rotateHouseList()
	if selectedhouse >= #ghomes.list then
		selectedhouse = 0

		return
	end

	selectedhouse = selectedhouse + 1
end

local function genEmptyHouse()
	local tbl = {} -- ik value = nil is not required
	tbl.boxes = {}
	tbl.bellpos = nil
	tbl.panels = {}
	tbl.panelpos = {}
	tbl.panelangle = {}
	tbl.textpos = nil
	tbl.textangle = nil
	tbl.camerapos = nil
	tbl.cameraangle = nil

	return tbl
end

local color_black = Color(0, 0, 0, 255)

local function drawdummypanel()
	draw.RoundedBox(16, 0, 0, 450, 380, color_white)
	draw.SimpleText("Panel Placeholer", "PermaHouses3", 225, 100, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("It's strongly recommended to put at least", "PermaHouses3", 225, 200, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("two panels per exit of the property :", "PermaHouses3", 225, 225, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("One inside and one outside", "PermaHouses3", 225, 250, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("No need to put two panels at each doors,", "PermaHouses3", 225, 280, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(" residents can still use keys,", "PermaHouses3", 225, 310, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	surface.SetDrawColor(color_black)
	surface.DrawLine(0, 0, 450, 380)
	surface.DrawLine(0, 380, 450, 0)
end

local colordark = Color(0, 0, 0, 180)

local function drawdummyname()
	local text = "Property Name"
	local text2 = "$Price"
	surface.SetFont("DrawHouseName")
	local width = math.Max(surface.GetTextSize(text), surface.GetTextSize(text2))
	draw.RoundedBox(16, 0, 0, width + 50, 250, colordark)
	draw.SimpleText(text, "DrawHouseName", 25, 0, color_white, TEXT_ALIGN_LEFT)
	draw.SimpleText(text2, "DrawHouseName", 25, 100, color_white, TEXT_ALIGN_LEFT)
end

local editingHouseTable = editingHouseTable or {}
--[[
*********************************************
 ]]
local leftmouseclick = Material("houses/lmb")
local rightmouseclick = Material("houses/rmb")
local reloadkey = Material("houses/r")
local usekey = Material("houses/e")
local back = Material("gui/html/back")
local forward = Material("gui/html/forward")
local matren = Material("debug/debugdrawflatpolygons")
local bellmat = Material("houses/bell3d.png")
local smartSnap = true
local color_green = Color(50, 205, 50)
local color_red = Color(255,50,50)
local color_green_dark = color_green
local color_green_dark_real = Color(0,50,0)
local CURRENT_MODE = MODE_SELECTHOUSE
selectedhouse = 0
smartSnap = true

local function getaimingpanelpos()
	local trace, angle = ghomes.getezpanelpos(LocalPlayer())
	trace = trace - (angle:Forward() * 25) - (angle:Right() * 20)

	if smartSnap then
		trace = Vector(trace.x, trace.y, math.Round(trace.z / 5) * 5)
	end

	return trace, angle
end

local modesdata = {}
modesdata[MODE_SELECTHOUSE] = {}

modesdata[MODE_SELECTHOUSE].draw = function(width, height)
	surface.SetDrawColor(color_white)
	surface.SetMaterial(leftmouseclick)
	surface.DrawTexturedRect(10, 10, 32, 32)
	draw.SimpleText("=> Select", "PermaHouses2", 40, 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	surface.SetDrawColor(color_white)
	surface.SetMaterial(rightmouseclick)
	surface.DrawTexturedRect(190, 10, 32, 32)
	draw.SimpleText("Rotate list =>", "PermaHouses2", 70, 25, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawLine(0, 50, width, 50)
	surface.SetFont("PermaHouses3")
	local textw, texth = surface.GetTextSize("New House")
	surface.SetDrawColor(20, 100, 20, 255)

	if (selectedhouse == 0) then
		surface.DrawRect(3, 60, textw + 4, 22)
	else
		surface.DrawRect(3, 60 + selectedhouse % 5 * texth, surface.GetTextSize(ghomes.list[selectedhouse].name) + 4, 22)
	end

	if (selectedhouse < 5) then
		draw.SimpleText("New House", "PermaHouses3", 5, 55, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	for k, v in pairs(ghomes.list) do
		if math.floor(k / 5) == math.floor(selectedhouse / 5) then
			draw.SimpleText(v.name, "PermaHouses3", 5, 55 + (k % 5) * texth, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end

	if (selectedhouse == 0) then
		draw.SimpleText("New Property", "PermaHouses2", 5, ScrH() - 35, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	else
		draw.SimpleText("Edit Selected property", "PermaHouses2", 5, ScrH() - 35, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end


	local scrollHeight = height - 50
	surface.SetDrawColor(color_green_dark_real)
	surface.DrawRect(width - 10, 50, 10, scrollHeight)
	local cursorheight = height / (1 + #ghomes.list)
	local position = math.Remap(selectedhouse, 0, #ghomes.list, 50, scrollHeight + cursorheight / 2)
	surface.SetDrawColor(color_green)
	surface.DrawRect(width - 9, position, 8, cursorheight)

end

modesdata[MODE_SELECTHOUSE].rightclick = function()
	rotateHouseList()
	surface.PlaySound(Format("ghome/rot0%i.wav", math.random(1, 2)))
end

modesdata[MODE_SELECTHOUSE].leftclick = function()
	if selectedhouse == 0 then
		editingHouseTable = genEmptyHouse()
	else
		editingHouseTable = table.Copy(ghomes.list[selectedhouse])
		ghomes.list[selectedhouse].beingedited = true
		editingHouseTable.beingedited = true
		editingHouseTable.boxes = {}
	end

	CURRENT_MODE = MODE_LIMITS
	surface.PlaySound("ghome/ok.wav")
end

modesdata[MODE_SELECTHOUSE].reload = function()
	--surface.PlaySound("tools/ifm/ifm_denyundo.wav") -- todo : tp to house
	if selectedhouse ~= 0 then
		net.Start("ghomes_tp")
		net.WriteUInt(selectedhouse, 7)
		net.SendToServer()
	end
end

modesdata[MODE_SELECTHOUSE].draw3d = function()
	if selectedhouse ~= 0 then
		ghomes.render.details2(selectedhouse)
	end
end

modesdata[MODE_SELECTHOUSE].draw2d = function()
	if selectedhouse ~= 0 then
		ghomes.render.details(selectedhouse)
	end
end

modesdata[MODE_LIMITS] = {}

modesdata[MODE_LIMITS].draw = function(width, height)
	if not editingHouseTable.boxes[1] then
		draw.SimpleText("Left Click => Set the", "PermaHouses3", 5, 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("first corner which", "PermaHouses3", 5, 30, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("will be one of the", "PermaHouses3", 5, 55, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("two used to set the", "PermaHouses3", 5, 80, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("boundaries of ", "PermaHouses3", 5, 105, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("the property", "PermaHouses3", 5, 130, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		surface.SetDrawColor(color_white)

		if (os.time() % 2 == 0) then
			surface.SetMaterial(leftmouseclick)
		else
			surface.SetMaterial(forward)
		end

		surface.DrawTexturedRect(145, 150, 64, 64)
	end

	if (editingHouseTable.boxes[1] and not editingHouseTable.boxes[2]) then
		draw.SimpleText("Left Click => Set the", "PermaHouses3", 5, 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("last corner.", "PermaHouses3", 5, 30, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Be sure all required", "PermaHouses3", 5, 80, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("doors are shown on", "PermaHouses3", 5, 105, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("your screen", "PermaHouses3", 5, 130, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		surface.SetDrawColor(color_white)

		if (os.time() % 2 == 0) then
			surface.SetMaterial(leftmouseclick)
		else
			surface.SetMaterial(forward)
		end

		surface.DrawTexturedRect(145, 150, 64, 64)
	end

	if (editingHouseTable.boxes[1] and editingHouseTable.boxes[2]) then
		draw.SimpleText("Press RELOAD to go", "PermaHouses3", 5, 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("to the next step or", "PermaHouses3", 5, 30, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("press Left Click to", "PermaHouses3", 5, 55, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Start Over the", "PermaHouses3", 5, 80, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("boundaries", "PermaHouses3", 5, 105, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		surface.SetDrawColor(color_white)

		if (os.time() % 2 == 0) then
			surface.SetMaterial(leftmouseclick)
			surface.DrawTexturedRect(35, 150, 64, 64)
			surface.SetMaterial(reloadkey)
			surface.DrawTexturedRect(135, 150, 64, 64)
		else
			surface.SetMaterial(back)
			surface.DrawTexturedRect(35, 150, 64, 64)
			surface.SetMaterial(forward)
			surface.DrawTexturedRect(135, 150, 64, 64)
		end
	end

	draw.SimpleText(Format("Found %i properties", #ghomes.list), "PermaHouses2", 5, ScrH() - 35, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

modesdata[MODE_LIMITS].leftclick = function()
	local vec = ghomes.getaimingcreate()
	for k, v in ipairs(ghomes.list) do
		if k == selectedhouse then continue end
		if vec:IsInHouse(k) then
			surface.PlaySound("tools/ifm/ifm_denyundo.wav")
			return
		end
	end

	if (editingHouseTable.boxes[1] == nil and editingHouseTable.boxes[2] == nil) then
		editingHouseTable.boxes[1] = vec
	elseif (editingHouseTable.boxes[1] and editingHouseTable.boxes[2] == nil) then
		editingHouseTable.boxes[2] = vec
	else
		editingHouseTable.boxes[1] = vec
		editingHouseTable.boxes[2] = nil
	end
end



local vec222 = Vector(2, 2, 2)
local vecm222 = Vector(-2, -2, -2)
modesdata[MODE_LIMITS].draw3d = function()
	ghomes.render.details2(editingHouseTable, true)
	local vec = ghomes.getaimingcreate()
	local color_to_use;

	for k, v in ipairs(ghomes.list) do
		if k == selectedhouse then continue end
		if vec:IsInHouse(k) then
			color_to_use = color_red;
			break
		end
	end
	if not color_to_use then color_to_use = color_green end

	if (not editingHouseTable.boxes[1]) or (editingHouseTable.boxes[1] and editingHouseTable.boxes[2]) then
		render.SetMaterial(matren)
		render.DrawBox(vec, angle_zero, vecm222, vec222, color_to_use, true)
	end
end

modesdata[MODE_LIMITS].draw2d = function()
	ghomes.render.details(editingHouseTable, true)
end

modesdata[MODE_LIMITS].reload = function()
	if (editingHouseTable.boxes[1] and editingHouseTable.boxes[2]) then
		editingHouseTable.boxes[1], editingHouseTable.boxes[2] = ghomes.findrightvector(editingHouseTable.boxes[1], editingHouseTable.boxes[2])
		CURRENT_MODE = MODE_PANELS
		surface.PlaySound("ghome/ok.wav")
	else
		surface.PlaySound("tools/ifm/ifm_denyundo.wav")
	end
end

modesdata[MODE_PANELS] = {}

modesdata[MODE_PANELS].draw = function(width, height)
	surface.SetDrawColor(color_white)
	surface.SetMaterial(leftmouseclick)
	surface.DrawTexturedRect(10, 10, 64, 64)
	draw.SimpleText("New Panel", "PermaHouses35", 80, 30, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	surface.SetMaterial(rightmouseclick)
	surface.DrawTexturedRect(10, 82, 64, 64)
	draw.SimpleText("Delete Last", "PermaHouses35", 80, 88, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("panel", "PermaHouses35", 80, 115, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	surface.SetMaterial(usekey)
	surface.DrawTexturedRect(25, 160, 32, 32)
	draw.SimpleText("Toggle SmartSnap", "PermaHouses2", 75, 165, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	surface.SetMaterial(reloadkey)
	surface.DrawTexturedRect(25, 205, 32, 32)
	draw.SimpleText("Next Step", "PermaHouses35", 75, 203, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

modesdata[MODE_PANELS].draw3d = function()
	local trace, angle = getaimingpanelpos()
	cam.Start3D2D(trace, angle, 0.1)
	drawdummypanel()
	cam.End3D2D()
	ghomes.render.details2(editingHouseTable, true)

	for k, v in pairs(editingHouseTable.panelpos) do
		cam.Start3D2D(v, editingHouseTable.panelangle[k], 0.1)
		drawdummypanel()
		cam.End3D2D()
	end
end

modesdata[MODE_PANELS].draw2d = function()
	ghomes.render.details(editingHouseTable, true)
end

modesdata[MODE_PANELS].leftclick = function()
	local trace, angle = getaimingpanelpos()
	table.insert(editingHouseTable.panelpos, trace)
	table.insert(editingHouseTable.panelangle, angle)
end

modesdata[MODE_PANELS].rightclick = function()
	table.remove(editingHouseTable.panelpos)
	table.remove(editingHouseTable.panelangle)
end

modesdata[MODE_PANELS].reload = function()
	if #editingHouseTable.panelpos < 2 then
		notification.AddLegacy("You need at least two panels, one inside and one outside the house/apartment", NOTIFY_ERROR, 3)
		surface.PlaySound("tools/ifm/ifm_denyundo.wav")

		return
	end

	surface.PlaySound("ghome/ok.wav")
	CURRENT_MODE = MODE_BELL
end

modesdata[MODE_PANELS].use = function()
	smartSnap = not smartSnap
end

modesdata[MODE_BELL] = {}

modesdata[MODE_BELL].draw = function(width, height)
	surface.SetDrawColor(color_white)
	surface.SetMaterial(leftmouseclick)
	surface.DrawTexturedRect(ScrW() / 2 - 64, 30, 124, 124)
	draw.SimpleText("Set house bell's", "PermaHouses35", 15, 150, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("position", "PermaHouses35", ScrW() / 2, 180, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

modesdata[MODE_BELL].draw3d = function()
	local trace, angle = ghomes.getezpanelpos(LocalPlayer())
	cam.Start3D2D(trace, angle, 0.5)
	surface.SetDrawColor(color_white)
	surface.SetMaterial(bellmat)
	surface.DrawTexturedRect(0, 0, 16, 16)
	cam.End3D2D()
	ghomes.render.details2(editingHouseTable, true)

	for k, v in pairs(editingHouseTable.panelpos) do
		cam.Start3D2D(v, editingHouseTable.panelangle[k], 0.1)
		drawdummypanel()
		cam.End3D2D()
	end
end

modesdata[MODE_BELL].draw2d = function()
	ghomes.render.details(editingHouseTable, true)
end

modesdata[MODE_BELL].leftclick = function()
	local pos = LocalPlayer():GetEyeTrace().HitPos

	if (pos:WithinAABox(editingHouseTable.boxes[1], editingHouseTable.boxes[2])) then
		editingHouseTable.bellpos = pos
		surface.PlaySound("ghome/ok.wav")
		CURRENT_MODE = MODE_HOUSENAME
	else
		notification.AddLegacy("The bell has to be inside the property boundaries", NOTIFY_ERROR, 3)
	end
end

modesdata[MODE_HOUSENAME] = {}

modesdata[MODE_HOUSENAME].draw = function(width, height)
	surface.SetDrawColor(color_white)
	surface.SetMaterial(leftmouseclick)
	surface.DrawTexturedRect(ScrW() / 2 - 64, 30, 124, 124)
	draw.SimpleText("Set house name's", "PermaHouses35", 15, 150, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("position", "PermaHouses35", ScrW() / 2, 180, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

modesdata[MODE_HOUSENAME].draw2d = function()
	ghomes.render.details(editingHouseTable, true)
end

modesdata[MODE_HOUSENAME].draw3d = function()
	local trace, angle = ghomes.getezpanelpos(LocalPlayer())
	cam.Start3D2D(trace, angle, 0.1)
	drawdummyname()
	cam.End3D2D()
	ghomes.render.details2(editingHouseTable, true)

	for k, v in pairs(editingHouseTable.panelpos) do
		cam.Start3D2D(v, editingHouseTable.panelangle[k], 0.1)
		drawdummypanel()
		cam.End3D2D()
	end
end

modesdata[MODE_HOUSENAME].leftclick = function()
	local trace, angle = ghomes.getezpanelpos(LocalPlayer())
	editingHouseTable.textpos = trace
	editingHouseTable.textangle = angle
	CURRENT_MODE = MODE_CAMERA
	surface.PlaySound("ghome/ok.wav")
end

modesdata[MODE_CAMERA] = {}

modesdata[MODE_CAMERA].draw = function(width, height)
	surface.SetDrawColor(color_white)
	surface.SetMaterial(leftmouseclick)
	surface.DrawTexturedRect(ScrW() / 2 - 64, 30, 124, 124)
	draw.SimpleText("Find a good camera", "PermaHouses35", ScrW() / 2, 150, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	draw.SimpleText("angle and then press", "PermaHouses35", ScrW() / 2, 180, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	draw.SimpleText("press left click", "PermaHouses35", ScrW() / 2, 210, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

modesdata[MODE_CAMERA].reload = function()
	surface.PlaySound("tools/ifm/ifm_denyundo.wav")
end

modesdata[MODE_CAMERA].draw2d = function()
	ghomes.render.details(editingHouseTable, true)
end

modesdata[MODE_CAMERA].draw3d = function()
	cam.Start3D2D(editingHouseTable.textpos, editingHouseTable.textangle, 0.1)
	drawdummyname()
	cam.End3D2D()

	for k, v in pairs(editingHouseTable.panelpos) do
		cam.Start3D2D(v, editingHouseTable.panelangle[k], 0.1)
		drawdummypanel()
		cam.End3D2D()
	end

	ghomes.render.details2(editingHouseTable, true)
end

modesdata[MODE_CAMERA].leftclick = function()
	editingHouseTable.camerapos = LocalPlayer():EyePos()
	editingHouseTable.cameraangle = LocalPlayer():EyeAngles()
	CURRENT_MODE = MODE_FINALIZE
	surface.PlaySound("ghome/ok.wav")
end

modesdata[MODE_FINALIZE] = {}

modesdata[MODE_FINALIZE].draw = function(width, height)
	surface.SetDrawColor(color_white)
	surface.SetMaterial(leftmouseclick)
	surface.DrawTexturedRect(10, 10, 96, 96)
	draw.SimpleText("Go to the final", "PermaHouses3", 82, 30, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("step", "PermaHouses3", 82, 55, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	surface.SetMaterial(reloadkey)
	surface.DrawTexturedRect(25, 135, 64, 64)
	draw.SimpleText("Go back to", "PermaHouses3", 95, 140, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("the first step", "PermaHouses3", 95, 165, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

modesdata[MODE_FINALIZE].reload = function()
	CURRENT_MODE = MODE_LIMITS
	surface.PlaySound("ghome/ok.wav")
end

modesdata[MODE_FINALIZE].draw2d = function()
	ghomes.render.details(editingHouseTable, true)
end

modesdata[MODE_FINALIZE].draw3d = function()
	cam.Start3D2D(editingHouseTable.textpos, editingHouseTable.textangle, 0.1)
	drawdummyname()
	cam.End3D2D()

	for k, v in pairs(editingHouseTable.panelpos) do
		cam.Start3D2D(v, editingHouseTable.panelangle[k], 0.1)
		drawdummypanel()
		cam.End3D2D()
	end

	ghomes.render.details2(editingHouseTable, true)
end

modesdata[MODE_FINALIZE].leftclick = function()
	ghomes.confirmcreation(editingHouseTable, selectedhouse)
end


local filename = "bool_boot_ghomes_2.txt"

local bootanim_done = file.Exists(filename, "DATA") 

local function handlepress(ply, key)
	if not IsFirstTimePredicted() then return end -- fkin hell
	if not bootanim_done then return end
	if not LocalPlayer():CanMasterHouse() then return end

	if key == IN_RELOAD and modesdata[CURRENT_MODE].reload then
		modesdata[CURRENT_MODE].reload()
	end

	if key == IN_ATTACK and modesdata[CURRENT_MODE].leftclick then
		modesdata[CURRENT_MODE].leftclick()
	end

	if key == IN_ATTACK2 and modesdata[CURRENT_MODE].rightclick then
		modesdata[CURRENT_MODE].rightclick()
	end

	if key == IN_USE and modesdata[CURRENT_MODE].use then
		modesdata[CURRENT_MODE].use()
	end
end

local function drawSelectedProperty()
	if modesdata[CURRENT_MODE].draw3d then
		modesdata[CURRENT_MODE].draw3d()
	end
end

local function drawDoorInsideHouse()
	if modesdata[CURRENT_MODE].draw2d then
		modesdata[CURRENT_MODE].draw2d()
	end
end

local DeployTime = CurTime()

local function Deploy()

	DeployTime = CurTime()

	editingHouseTable = {}
	CURRENT_MODE = MODE_SELECTHOUSE
	selectedhouse = 0
	smartSnap = true
	hook.Add("PostDrawOpaqueRenderables", "housetoolRender", drawSelectedProperty)
	hook.Add("HUDPaint", "housetoolRender", drawDoorInsideHouse)
	hook.Add("KeyPress", "keypresstoolhouses", handlepress)
end

local function Holster()

	hook.Remove("PostDrawOpaqueRenderables", "housetoolRender")
	hook.Remove("HUDPaint", "housetoolRender")
	hook.Remove("KeyPress", "keypresstoolhouses")

	for k, v in pairs(ghomes.list) do
		if v.beingedited == true then
			v.beingedited = false
		end
	end
end

net.Receive("ghomes_newhousecl", function()
	Holster()
	Deploy()
end)

if CLIENT then
local boottext = [[
******* EH-OS(R) V7.1.0.8 *******

COPYRIGHT 2019 LAPIN(R)
LOADER V0.2
EXEC VERSION 45.30
64K RAM SYSTEM
4531 BYTES FREE
NO HOLOTAPE FOUND
LOAD ROM(1): TOOL.ROM
BOUGHT ON GMODSTORE

*********************************]]
	local kerneltext =
[[******* GH-OS(R) V7.1.0.8 *******
1 0 0xA4 start memory discovery
1 0 0x81 start I/O discovery
*********************************
* ROM Version : 02.31
* ROM Date    : 12/07/2019
* BMC Version :  01.52
*********************************

0xA4 0x1 start memory discovery
0x14 0xD starting cell relocation
0x09 0x4 launch EFI
0x07 0x00E003D CPU0 starting EFI

EFI version 1.10 [14.61]
EFI64 Running on ARM64
EFI 1.10 IPF zx6000 1.22

Copyright (c) 2000-2019
(c) ExtReM-Team.com
Gigabit Ethernet EFI driver v3.1

Loading 'FPSWA'...
Loading 'lsi1030'...
Loading 'gigundi'...
0x20B EFI Launching Boot Manager              

EFI Boot Manager ver 1.0 [14.61]

Please select a boot option

    ToolGun                                                             
    net Library 
    Steam OS
    MINIX CPU OS                                 
    EFI Shell [Built-in]                                            
    Boot Option Maintenance Menu                                    
    System Configuration Menu                                       

    Use ^ and v to change.
    Use Enter to select an option

Loading.: Primary Boot: 0/0.1.0                           
Starting: Primary Boot: 0/0.1.0

	ExtReM-Team.com Boot Loader
	 for IPF  --  Revision 2.088

Press Any Key to stop Autoboot
\EFI\HPUX\AUTO ==> boot vmunix
Seconds left till autoboot -   0
AUTOBOOTING...
AUTO BOOT> boot vmunix
> System Memory = 24564 MB
loading section 0
................... (complete)
loading section 1
............ (complete)
loading symbol table
loading System Directory to MFS
....
loading MFSFILES directory to MFS
......
Launching /stand/vmunix
SIZE:
	Text:24488K +
	Data:5927K +
	BSS:5100K = Total:35516K

Console is on a Serial Device
Booting kernel...
]]
	local tblstr = string.Explode("\n", boottext)
	local tblkernel = string.Explode("\n", kerneltext)
	local matScreen = Material("models/weapons/v_toolgun/screen")
	local RTTexture = GetRenderTarget("GModToolgunScreen", 256, 256)
	local rendering = false
	local translatespeed = 400

	local function rendertextez(tbltext, time, translate, time2, maxtime)
		local x, y = 0, 0

		for k, v in pairs(tbltext) do
			local _, textLineHeight = surface.GetTextSize(v)

			if translate then
				surface.SetTextPos(x, y - (time * translatespeed))
			else
				surface.SetTextPos(x, y)
			end

			if (not translate and (k == #tbltext or k == #tbltext - 1)) then
				if (k == #tbltext) then
					local len = string.len(v)
					local targetlen = math.Remap(time2, 0, 3.5, 0, len)
					surface.DrawText(string.Left(v, targetlen))
				else
					local targetlen = math.Remap(time2, 0, 3.5, 0, 100)
					surface.DrawText(Format("Booting : %i%%", math.max(0, targetlen)))
				end
			else
				surface.DrawText(v)
			end

			y = y + textLineHeight
			if translate and k == #tbltext and (y - (time * translatespeed)) < 0 then return 1 end
		end

		return 0
	end

	local bootstatus = 0
	local timeoffset
	local firstrun = false

	local function bootanimate(time, maxtime)
		if not firstrun then
			surface.PlaySound("ghome/bootd.wav")
			firstrun = true
		end

		surface.SetFont("PermaHouses15")
		surface.SetTextColor(color_green_dark)

		if bootstatus == 0 then
			bootstatus = rendertextez(tblkernel, time, true)

			if (bootstatus == 1) then
				timeoffset = time
				surface.PlaySound("ghome/booth.wav")
			end
		else
			rendertextez(tblstr, time, false, time - timeoffset, maxtime)
		end

		if time > maxtime then
			bootanim_done = true
			surface.PlaySound("ghome/bootfinished.wav")
			file.Write(filename, "")
		end
	end

	hook.Add("RenderScene", "rendertool", function(origin, angle, fov)
		local TEX_SIZE = 256
		local oldW = ScrW()
		local oldH = ScrH()
		if selectedhouse > #ghomes.list then
			selectedhouse = 0;
		end

		local mode = GetConVarString("gmod_toolmode")
		--[[Dirty hack i have no choice to use because gmod prediction system sucks as hell]]
		if not IsValid(LocalPlayer():GetActiveWeapon()) then return end

		if LocalPlayer():GetActiveWeapon():GetClass() ~= "gmod_tool" or mode ~= "enhanced_homes" then
			if (rendering) then
				Holster()
				rendering = false
			end

			return
		end

		if (not rendering) then
			rendering = true
			Deploy()
		end

		matScreen:SetTexture("$basetexture", RTTexture)
		local OldRT = render.GetRenderTarget()
		render.SetRenderTarget(RTTexture)
		render.SetViewPort(0, 0, TEX_SIZE, TEX_SIZE)
		cam.Start2D()
		surface.SetDrawColor(20, 20, 20, 255)
		surface.DrawRect(0, 0, TEX_SIZE, TEX_SIZE)


		if bootanim_done then
			if modesdata[CURRENT_MODE] and modesdata[CURRENT_MODE].draw then
				if not LocalPlayer():CanMasterHouse() then
					draw.SimpleText("You're not allowed", "PermaHouses3", 5, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					draw.SimpleText("to use this tool", "PermaHouses3", 5, 35, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				else
					modesdata[CURRENT_MODE].draw(TEX_SIZE, TEX_SIZE)
				end
			end
		else
			bootanimate(CurTime() - DeployTime, 7.2)
		end

		cam.End2D()
		render.SetRenderTarget(OldRT)
		render.SetViewPort(0, 0, oldW, oldH)
	end)
end