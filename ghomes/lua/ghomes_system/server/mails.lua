if not file.Exists("ghomes_system/mails/", "DATA") then
	file.CreateDir("ghomes_system/mails/")
end

util.AddNetworkString("ghomes_requestlastmail")
util.AddNetworkString("ghomes_writenote")
util.AddNetworkString("ghomes_newmail")
ghomes.mail = ghomes.mail or {}

function ghomes.mail.savemail(sid)
	local target = "ghomes_system/mails/" .. sid .. ".txt"
	file.Write(target, util.TableToJSON(ghomes.mail[sid], true))
end

function ghomes.mail.restoremails()
	for k, v in pairs(file.Find("ghomes_system/mails/*", "DATA")) do
		local trg = string.Left(v, 17)
		ghomes.mail[trg] = util.JSONToTable(file.Read("ghomes_system/mails/" .. v))
	end
end

net.Receive("ghomes_requestlastmail", function(len, ply)
	local sid = ply:SteamID64()
	net.Start("ghomes_requestlastmail")
	net.WriteTable(ghomes.mail[sid][1] or {})
	table.remove(ghomes.mail[sid], 1)
	ghomes.mail.savemail(sid)
	net.Send(ply)
end)

net.Receive("ghomes_writenote", function(len, ply)
	local target = net.ReadString()
	local _message = net.ReadString()
	--local anon = net.ReadBool()

	if not ply.lastwrotenote then
		ply.lastwrotenote = CurTime()
	else
		if CurTime() - ply.lastwrotenote < 60 then -- stop spamming u cunt
			ghomes.wrapper.notify(ply, 1, 4, Format("You need to wait another %i seconds before writing a message/mail", 60 - (CurTime() - ply.lastwrotenote) ))
			return
		end
	end
	ply.lastwrotenote = CurTime()
	if string.len(_message) > 1024 then return end -- fuck off mate
	target = util.SteamIDTo64(target)

	if not ghomes.mail[target] then
		ghomes.mail[target] = {}
	end

	local message = {}

	/*if anon then
		message.author = "???"
	else*/
		message.author = ply:Nick()
	--end

	message.text = _message
	table.insert(ghomes.mail[target], message)
	ghomes.mail.savemail(target)
	local plytrg = player.GetBySteamID64(target)
	if plytrg then
		net.Start("ghomes_newmail")
		net.WriteUInt(#ghomes.mail[target], 7)
		net.Send(plytrg)
	end
end)