local tried = false
local gotpackage = false


hook.Add("HUDPaint", "Restore housesCL", function()
	if not tried and util.NetworkStringToID("ghomes_gettable") == 0 then
		tried = true
		notification.AddLegacy("The server could not load GHomes, please read your console for more informations", NOTIFY_ERROR, 20)
		MsgC(Color(50, 255, 50), [[Hello there, looks like ghomes failed to load on the server.
Here is what you can do :

Get the logs, (guide here : https://www.gmodstore.com/community/threads/2682-how-to-send-real-logs )

Open a ticket, upload the logs on pastebin, and send me the pastebin link.

]])

		return
	end

	hook.Remove("HUDPaint", "Restore housesCL")
	if not ghomes.wrapper.init then ghomes.SetupWrapper() end
	net.Start("ghomes_gettable")
	net.SendToServer()
	gotpackage = true
end)

net.Receive("ghomes_getsingletable", function(len, ply)
	local id = net.ReadUInt(7)
	local tbl = ghomes.net.readHouse()

	if ghomes.list[id] then
		for k, v in pairs(ghomes.list[id].panels) do
			vgui.Reset3D2DDermaLapin(v)
			v:Remove()
		end
	end

	ghomes.list[id] = tbl
	hook.Run("UpdatedHouseList", id)
end)

net.Receive("ghomes_OwnerUpdate", function()
	if not gotpackage then return false end -- server is trying to dispatch new owner that connected before localplayer finished loading the house table
	local ply = net.ReadEntity()
	local len = net.ReadUInt(7)
	local i = 1
	while i <= len do

		local id = net.ReadUInt(7)
		if not ghomes.list[id] then continue end -- fuck this shit
		ghomes.list[id].owner = ply
		hook.Run("UpdatedHouseList", id)
		i = i + 1
	end
end)

net.Receive("ghomes_bell", function()
	if not gotpackage then return false end
	local id = net.ReadUInt(7)
	if not ghomes.list[id] then return end
	sound.Play("ghome/doorbell.wav", ghomes.list[id].bellpos)
end)

net.Receive("ghomes_newmail", function()
	LocalPlayer().nmails = net.ReadUInt(7)
end)

net.Receive("ghomes_requestlastmail", function()
	local mail = net.ReadTable()
	LocalPlayer().nmails = LocalPlayer().nmails - 1
	ghomes.mails.mailshow(mail)
end)

net.Receive("ghomes_npc_use", function()
	ghomes.sellermenu()
end)

net.Receive("ghomes_reset_data", function()
	ghomes.list = {}
end)

