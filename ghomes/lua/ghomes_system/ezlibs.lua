local angAdd = Angle(0, 90, 90)
function ghomes.getezpanelpos(ply)
	local trace = ply:GetEyeTrace()
	local ang = trace.HitNormal:Angle()
	local pos = ang:Forward()
	pos:Mul(2)
	pos:Add(trace.HitPos)
	local angfixed = ang
	angfixed:Add(angAdd)

	return pos, angfixed
end

function ghomes.findrightvector(vec1, vec2)
	local newvec1 = Vector(math.min(vec1.x, vec2.x), math.min(vec1.y, vec2.y), math.min(vec1.z, vec2.z))
	local newvec2 = Vector(math.max(vec1.x, vec2.x), math.max(vec1.y, vec2.y), math.max(vec1.z, vec2.z))

	return newvec1, newvec2
end

local classtabledoor = {
	func_door = true,
	func_door_rotating = true,
	prop_door_rotating = true,
	door_breakable = true
}

function ghomes.IsDoorOkayForHouse(class)
	if classtabledoor[class] then return true end

	return false
end

function ghomes.daytosaletotimestamp(days)
	return 3600 * 24 * days
end

function ghomes.timetorentprice(id, time)
	local price = ghomes.list[id].rentprice

	return price / ghomes.daytosaletotimestamp(1) * time
end

function ghomes.getaimingcreate()
	local vec = LocalPlayer():EyePos()
	local forward = EyeAngles():Forward()
	forward:Mul(30)
	vec:Add(forward)

	return vec
end