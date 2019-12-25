local color2 = Color(110, 110, 110, 255)

surface.CreateFont("DrawBoxGhomes4", {
	font = "Roboto",
	size = 68,
	italic = false
})

surface.CreateFont("DrawBoxGhomes4Small", {
	font = "Roboto",
	size = 50,
	italic = false
})

local color42 = Color(240, 240, 240)
local uploadicon = Material("houses/upload.png")
function ghomes.dlcs.dlc1.selecthouse(ent)

	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(600, 600)
	DermaPanel:SetTitle("")
	DermaPanel:SetDraggable(false)
	DermaPanel:MakePopup()
	DermaPanel:Center()
	DermaPanel.lblTitle.Paint = function() end
	DermaPanel.goup = false
	DermaPanel.movetime = 0
	DermaPanel.movey = 0
	DermaPanel.Think = function(self)
		if self.goup then
			local time = CurTime() - self.movetime
			local x = self:GetPos()
			local target = self.movey - (time * 6000)

			if (target + self:GetTall() < 0) then
				self:Close()

				return
			end

			self:SetPos(x, target)
		end
	end


	DermaPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color2)
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, color42)
		draw.DrawText(ghomes.settings, "GuiSentData1", w / 2, 5, color2, TEXT_ALIGN_CENTER)

	end

	DermaPanel.btnClose.Paint = function(panel, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawLine(10, 10, 20, 20)
		surface.DrawLine(10, 20, 20, 10)
	end

	DermaPanel.btnMaxim.Paint = function(panel, w, h) end
	DermaPanel.btnMinim.Paint = function(panel, w, h) end

	DermaPanel.btnClose.DoClick = function(button)
		DermaPanel.goup = true
		DermaPanel.movetime = CurTime()
		DermaPanel.movey = select(2, DermaPanel:GetPos())
		net.Start("ghomes_dlc1_use_suitcase")
		net.WriteBool(true)
		net.WriteEntity(ent)
		net.WriteUInt(0 , 7)
		net.SendToServer()
	end

	local scrollHomes

	scrollHomes = vgui.Create("DScrollPanel", DermaPanel)
	scrollHomes:SetPos(5, 65)
	scrollHomes:SetSize(DermaPanel:GetWide() - 10, DermaPanel:GetTall() - 83)
	local color_black = Color(0, 0, 0)
	local radius = 8
	local  i = 0
	for k, v in pairs(ghomes.list) do
		if v.owner == LocalPlayer() then
			local DLabel = vgui.Create("DButton", scrollHomes)
			DLabel:SetSize(scrollHomes:GetWide() - 25, 90)
			DLabel:SetText("")
			DLabel:SetPos(5, 10 + i * 100)
			DLabel.Paint = function(pnl, w, h)
				draw.RoundedBox(radius, 0, 0, w, h, color_black)
				draw.RoundedBox(radius, 1, 1, w - 2, h - 2, color_white)
				draw.DrawText(v.name, "DrawBoxGhomes4Small", DLabel:GetWide() / 2, 6, color_black, TEXT_ALIGN_CENTER)
			end
			DLabel.DoClick = function()
				net.Start("ghomes_dlc1_use_suitcase")
				net.WriteBool(true)
				net.WriteEntity(ent)
				net.WriteUInt(k , 7)
				net.SendToServer()
				DermaPanel.goup = true
				DermaPanel.movetime = CurTime()
				DermaPanel.movey = select(2, DermaPanel:GetPos())
			end


			i = i + 1
		end

	end
end

local color_black = Color(0,0,0)

function ghomes.dlcs.dlc1.settingshouse(id, ent)
	local house = ghomes.list[id]
	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(700,400)
	DermaPanel:SetTitle("")
	DermaPanel:SetDraggable(false)
	DermaPanel:MakePopup()
	DermaPanel:Center()
	DermaPanel.lblTitle.Paint = function() end
	DermaPanel.goup = false
	DermaPanel.movetime = 0
	DermaPanel.movey = 0
	DermaPanel.Think = function(self)
		if self.goup then
			local time = CurTime() - self.movetime
			local x = self:GetPos()
			local target = self.movey - (time * 6000)

			if (target + self:GetTall() < 0) then
				self:Close()

				return
			end

			self:SetPos(x, target)
		end
	end

	DermaPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color2)
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, color42)
		draw.DrawText(ghomes.settings, "GuiSentData1", w / 2, 5, color2, TEXT_ALIGN_CENTER)
		draw.DrawText(house.name, "DrawBoxGhomes4", 10, 35, color_black, TEXT_ALIGN_LEFT)
		draw.DrawText(ghomes.spawnhomeowner, "DrawBoxGhomes3", 60, 135, color_black, TEXT_ALIGN_LEFT)
		draw.DrawText(ghomes.spawnhomefriends, "DrawBoxGhomes3", 60, 195, color_black, TEXT_ALIGN_LEFT)
		draw.DrawText(ghomes.saveentities, "DrawBoxGhomes3", 60, 255, color_black, TEXT_ALIGN_LEFT)
		draw.DrawText(ghomes.buyalarm, "DrawBoxGhomes3", 60, 315, color_black, TEXT_ALIGN_LEFT)


		surface.SetDrawColor(0,0,0)
		surface.DrawLine(0,110,DermaPanel:GetWide(),110)
	end

	DermaPanel.btnClose.Paint = function(panel, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawLine(10, 10, 20, 20)
		surface.DrawLine(10, 20, 20, 10)
	end

	DermaPanel.btnMaxim.Paint = function(panel, w, h) end
	DermaPanel.btnMinim.Paint = function(panel, w, h) end

	DermaPanel.btnClose.DoClick = function(button)
		DermaPanel.goup = true
		DermaPanel.movetime = CurTime()
		DermaPanel.movey = select(2, DermaPanel:GetPos())

	end


	local spawnhere = vgui.Create( "DCheckBox",DermaPanel )
	spawnhere:SetPos( 25, 143 )
	spawnhere:SetChecked(net.ReadBool())

	local spawnhereFriends = vgui.Create( "DCheckBox",DermaPanel )
	spawnhereFriends:SetPos( 25, 203 )
	spawnhereFriends:SetChecked(net.ReadBool())

	local saveEntities = vgui.Create( "DCheckBox",DermaPanel )
	saveEntities:SetPos( 25, 263 )
	saveEntities:SetChecked(net.ReadBool())

	local buyAlarm = vgui.Create( "DCheckBox",DermaPanel )
	buyAlarm:SetPos( 25, 323 )
	buyAlarm:SetChecked(net.ReadBool())

	local DermaButtonSend = vgui.Create("DButton", DermaPanel)
	DermaButtonSend:SetText("")
	DermaButtonSend:SetSize(DermaPanel:GetWide(), 40)
	DermaButtonSend:SetPos(0, DermaPanel:GetTall() - 40)



	DermaButtonSend.DoClick = function()
		DermaPanel.goup = true
		DermaPanel.movetime = CurTime()
		DermaPanel.movey = select(2, DermaPanel:GetPos())

		if (selectedhouse ~= 0) then
			ghomes.list[selectedhouse].beingedited = false
		end
		if ent ~= NULL then
			net.Start("ghomes_dlc1_use_suitcase")
			net.WriteBool(false)
			net.WriteEntity(ent)
			net.WriteBool(spawnhere:GetChecked())
			net.WriteBool(spawnhereFriends:GetChecked())
			net.WriteBool(saveEntities:GetChecked())
			net.WriteBool(buyAlarm:GetChecked())
			net.SendToServer()
		else
			net.Start("ghomes_dlc1_use_suitcase2")
			net.WriteUInt(id, 7)
			net.WriteBool(spawnhere:GetChecked())
			net.WriteBool(spawnhereFriends:GetChecked())
			net.WriteBool(saveEntities:GetChecked())
			net.WriteBool(buyAlarm:GetChecked())
			net.SendToServer()
		end
	end

	local n = Color(220, 220, 220)
	local y = Color(180, 180, 180)

	DermaButtonSend.Paint = function(self, w, h)
		local col = n

		if self:IsDown() then
			col = y
		end

		draw.RoundedBoxEx(8, 1, 0, w - 2, h - 1, col, false, false, true, true)
		surface.SetDrawColor(color_white)
		surface.SetMaterial(uploadicon)
		surface.DrawTexturedRect(w / 2 - 16, h / 2 - 16, 32, 32)
	end


end





net.Receive("ghomes_dlc1_ask_where_to_spawn",function ()
	local list = {}
	local i = 0
	local len = net.ReadUInt(8)
	while (i < len) do
		table.insert(list, net.ReadUInt(9))
		i = i + 1
	end

	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(600, 600)
	DermaPanel:SetTitle("")
	DermaPanel:SetDraggable(false)
	DermaPanel:MakePopup()
	DermaPanel:Center()
	DermaPanel.lblTitle.Paint = function() end
	DermaPanel.goup = false
	DermaPanel.movetime = 0
	DermaPanel.movey = 0
	DermaPanel.Think = function(self)
		if self.goup then
			local time = CurTime() - self.movetime
			local x = self:GetPos()
			local target = self.movey - (time * 6000)

			if (target + self:GetTall() < 0) then
				self:Close()

				return
			end

			self:SetPos(x, target)
		end
	end


	DermaPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color2)
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, color42)
		draw.DrawText(ghomes.chooseWhereToRespawn, "GuiSentData1", w / 2, 5, color2, TEXT_ALIGN_CENTER)

	end

	DermaPanel.btnClose.Paint = function(panel, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawLine(10, 10, 20, 20)
		surface.DrawLine(10, 20, 20, 10)
	end

	DermaPanel.btnMaxim.Paint = function(panel, w, h) end
	DermaPanel.btnMinim.Paint = function(panel, w, h) end

	DermaPanel.btnClose.DoClick = function(button)
		DermaPanel.goup = true
		DermaPanel.movetime = CurTime()
		DermaPanel.movey = select(2, DermaPanel:GetPos())
		net.Start("ghomes_dlc1_ask_where_to_spawn")
		net.WriteUInt(0,9)
		net.SendToServer()
	end


	local DermaCheckbox = vgui.Create( "DCheckBoxLabel", DermaPanel ) // Create the checkbox

	DermaCheckbox:SetPos( 12, 40 )
	DermaCheckbox:SetText( ghomes.rememberChoiceForThisSession )
	DermaCheckbox:SetTextColor(color_black)




	local scrollHomes

	scrollHomes = vgui.Create("DScrollPanel", DermaPanel)
	scrollHomes:SetPos(5, 65)
	scrollHomes:SetSize(DermaPanel:GetWide() - 10, DermaPanel:GetTall() - 83)


	local radius = 8
	i = 1

	local DLabel_default = vgui.Create("DButton", scrollHomes)
			DLabel_default:SetSize(scrollHomes:GetWide() - 25, 90)
			DLabel_default:SetText("")
			DLabel_default:SetPos(5, 10)
			DLabel_default.Paint = function(pnl, w, h)
				draw.RoundedBox(radius, 0, 0, w, h, color_black)
				draw.RoundedBox(radius, 1, 1, w - 2, h - 2, color_white)
				draw.DrawText(ghomes.defaultSpawn, "DrawBoxGhomes4Small", DLabel_default:GetWide() / 2, 6, color_black, TEXT_ALIGN_CENTER)
			end
			DLabel_default.DoClick = function()
				net.Start("ghomes_dlc1_ask_where_to_spawn")
				net.WriteUInt(0 , 9)
				net.WriteBool(DermaCheckbox:GetChecked())
				net.SendToServer()
				DermaPanel.goup = true
				DermaPanel.movetime = CurTime()
				DermaPanel.movey = select(2, DermaPanel:GetPos())
			end



	for k, v in pairs(list) do
		local house = ghomes.list[v]
		if house.owner == LocalPlayer() then
			local DLabel = vgui.Create("DButton", scrollHomes)
			DLabel:SetSize(scrollHomes:GetWide() - 25, 90)
			DLabel:SetText("")
			DLabel:SetPos(5, 10 + i * 100)
			DLabel.Paint = function(pnl, w, h)
				draw.RoundedBox(radius, 0, 0, w, h, color_black)
				draw.RoundedBox(radius, 1, 1, w - 2, h - 2, color_white)
				draw.DrawText(house.name, "DrawBoxGhomes4Small", DLabel:GetWide() / 2, 6, color_black, TEXT_ALIGN_CENTER)
			end
			DLabel.DoClick = function()
				net.Start("ghomes_dlc1_ask_where_to_spawn")
				net.WriteUInt(v , 9)
				net.WriteBool(DermaCheckbox:GetChecked())
				net.SendToServer()
				DermaPanel.goup = true
				DermaPanel.movetime = CurTime()
				DermaPanel.movey = select(2, DermaPanel:GetPos())
			end


			i = i + 1
		end

	end

end)








net.Receive("ghomes_dlc1_use_suitcase",function()
	local id = net.ReadUInt(7)
	local ent = net.ReadEntity()

	ghomes.dlcs.dlc1.settingshouse(id, ent)
end)


net.Receive("ghomes_dlc1_use_suitcase3",function()
	local id = net.ReadUInt(7)
	ghomes.dlcs.dlc1.settingshouse(id, NULL)
end)


net.Receive("ghomes_dlc1_alarm_lockpicked",function()
	sound.Play("ghome/alarm.mp3", ghomes.list[net.ReadUInt(7)].bellpos, 85, 100,1)
end)
