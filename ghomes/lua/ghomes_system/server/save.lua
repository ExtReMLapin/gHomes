if not file.Exists("ghomes_system", "DATA") then
	file.CreateDir("ghomes_system")
end

local targetfolder = "ghomes_system/" .. string.lower(game.GetMap()) .. "/"

if not file.Exists(targetfolder, "DATA") then
	file.CreateDir(targetfolder)
end

function ghomes.savehouse(id)
	if not id then
		return
	end

	local dest = targetfolder .. tostring(id) .. ".txt"
	local content = util.TableToJSON(ghomes.list[id], true)
	file.Write(dest, content)
	hook.Run("ghomes_savedhouse", id)
end

function ghomes.deletefilehome(id)
	file.Delete(targetfolder .. tostring(id) .. ".txt")
end

local function fixSave(files)
	local k = 1

	while (k <= #files) do
		local v = files[k]
		local str = string.gsub(v, ".txt", "")

		if k ~= tonumber(str) then
			print(Format("Found a gap before file %s fixing it and the next ones...", v))
			local i = k

			while (i <= #files) do
				local newFileName = string.format("%i.txt", i)
				file.Rename(targetfolder .. files[i], targetfolder .. newFileName)
				files[i] = newFileName
				i = i + 1
			end

			files[k] = string.format("%i.txt", k) -- just in case u know
		end

		local dest = targetfolder .. v

		if file.Size(dest, "DATA") == 0 then
			print(Format("File %s seems to be empty, ignoring it and removing it, renaming the next files to fill the gap", dest))
			local i = k
			file.Delete(dest)
			table.remove(files, k)

			while (i <= #files) do
				local newFileName = string.format("%i.txt", i)
				file.Rename(targetfolder .. files[i], targetfolder .. newFileName)
				files[i] = newFileName
				i = i + 1
			end

			if (#files >= k) then
				continue -- hack
			else
				return
			end -- if it wasn't the last of the list
		end

		k = k + 1
	end
end

function ghomes.restorehouses()
	local files = file.Find(targetfolder .. "*", "DATA")
	local _list = {}

	table.sort(files, function(a, b)
		local _a = string.gsub(a, ".txt", "")
		local _b = string.gsub(b, ".txt", "")

		return tonumber(_a) < tonumber(_b)
	end)

	fixSave(files)

	for k, v in pairs(files) do
		local str = string.gsub(v, ".txt", "")
		local id = tonumber(str)
		local dest = targetfolder .. v
		local txt = file.Read(dest, "DATA")
		local tbltmphouse = util.JSONToTable(txt)

		if not tbltmphouse then
			error(Format("FAILED TO PARSE FILE #%i please check the file : %s", id, dest))
		end -- parsing error

		tbltmphouse.owner = NULL

		if not tbltmphouse.ownersteamid then
			tbltmphouse.ownersteamid = ""
		end

		ghomes.list[id] = tbltmphouse

		if ghomes.list[id].isrented then
			for k1, v1 in pairs(player.GetAll()) do
				if v1:SteamID() == ghomes.list[id].ownersteamid then
					v1.owner = ply
				end
			end -- hot loading

			if ghomes.list[id].lastJoin == nil then
				ghomes.list[id].lastJoin = os.time()
			end -- upgrading the save for autosell update

			if (ghomes.list[id].ispermarented == false and ghomes.list[id].selltime < os.time()) or (ghomes.autosellafternotconnecterforxdays ~= 0 and (ghomes.list[id].lastJoin + ghomes.autosellafternotconnecterforxdays) < os.time()) then
				-- didn't join after x days
				ghomes.setowner(false, id)
			end -- expired
		end

		if ghomes.sellwhenplayerleaves then
			ghomes.setowner(false, id)
		end

		ghomes.generatedoors(id)

		if ghomes.list[id].isrented then
			ghomes.lockdoors(id)
		end

		hook.Run("ghomes_restoredhouse", id)
	end

	if ghomes.debug then
		MsgC(ghomes.rgb, Format(" Restored all houses [%i]!\n", #ghomes.list))
	end
end
