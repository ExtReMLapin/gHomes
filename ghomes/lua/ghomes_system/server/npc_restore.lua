if not file.Exists("ghomes_system/npcs/", "DATA") then
	file.CreateDir("ghomes_system/npcs/")
end

local mapfile = "ghomes_system/npcs/" .. string.lower(game.GetMap()) .. ".txt"
local data = {}

if not file.Exists(mapfile, "DATA") then
	file.Write(mapfile, util.TableToJSON({}))
else
	data = util.JSONToTable(file.Read(mapfile, "DATA")) or {}
end

function ghomes.registernpc(ent)
	local tbl = {ent:GetPos(), ent:GetAngles(), #data + 1}
	table.insert(data, tbl)
	ent.npcid = #data
	file.Write(mapfile, util.TableToJSON(data))
end

function ghomes.npconremove(npcid)
	for k, v in pairs(data) do

		if v[3] == npcid then
			table.remove(data, k)
			file.Write(mapfile, util.TableToJSON(data))
			break
		end
	end
end

hook.Add("InitPostEntity", "ghomesnpc", function()
	for k, v in pairs(data) do
		local ent = ents.Create("ghomes_seller")
		ent:SetPos(v[1])
		ent:SetAngles(v[2])
		ent.npcid = k
		ent:Spawn()
		ent:Activate()
	end
end)


concommand.Add("ghomes_remove_all_npc",function(ply)
	if not ply:CanMasterHouse() then return end
	for k, v in pairs(ents.FindByClass("ghomes_seller")) do
		v:Remove()
	end
	file.Delete(mapfile);
	timer.Simple(5, function() file.Delete(mapfile) end) -- because of the shutdownfix delayed of 3sec in the npc ent code
	data = {}
end)