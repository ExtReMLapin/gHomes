surface.CreateFont("GuiSentData1", {
	font = "Roboto Lt",
	size = 25
})

surface.CreateFont("GuiSentData2", {
	font = "Roboto Lt",
	size = 48
})

surface.CreateFont("GuiSentData3", {
	font = "Roboto",
	size = 35,
	italic = false
})

--Rent mode [1 = all | 2 = buy only | 3 = rent only]


local allowedToRentInDays = ghomes.maxdaysrent > 1
local color2 = Color(110, 110, 110, 255)
local color_grey = Color(127, 127, 127)
local cart = Material("houses/cart.png")
local uploadicon = Material("houses/upload.png")
local refund = Material("houses/refund.png")
local refundw = Material("houses/refund2.png")
local billet = Material("houses/billet.png")
local friend = Material("houses/friend.png")
local eye = Material("houses/eye.png")
local close = Material("houses/close.png")
local tick = Material("houses/tick.png")
local gear = Material("houses/gear.png")
local boom = Material("houses/boom.png")

function ghomes.confirmcreation(housedata, selectedhouse)
	local propertysize = housedata.boxes[2] - housedata.boxes[1]
	propertysize = math.ceil(propertysize.x * propertysize.y * propertysize.z)
	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(650, 340)
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
			local target = self.movey - (time * 3000)

			if (target + self:GetTall() < 0) then
				self:Close()

				return
			end

			self:SetPos(x, target)
		end
	end

	local selectedRentalMode = 1
	local priceRatio = 1
	local purchasetext = ghomes.purchaseprice .. ghomes.wrapper.formatMoney(math.ceil(propertysize * priceRatio / 1000))
	local renttext = ghomes.rentalprice .. ghomes.wrapper.formatMoney(math.ceil(propertysize * priceRatio / 1000 / 182)) .. ghomes.perdays

	DermaPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color2)
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, color_white)
		draw.SimpleText("Property name", "GuiSentData1", 25, 20, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Rental mode", "GuiSentData1", 25, 70, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		--local rentalvalue = propertysize
		--if (selectedRentalMode == 1) then // both
		draw.SimpleText("Real estate value of the property", "GuiSentData1", 45, 120, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

		if (selectedRentalMode == 1) then
			draw.SimpleText(purchasetext, "GuiSentData1", 45, 145, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(renttext, "GuiSentData1", 45, 170, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		elseif (selectedRentalMode == 2) then
			draw.SimpleText(purchasetext, "GuiSentData1", 45, 145, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		else
			draw.SimpleText(renttext, "GuiSentData1", 45, 145, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end

		draw.SimpleText(ghomes.pricepropertysize, "GuiSentData1", 25, 210, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(ghomes.sliderchangeprice, "GuiSentData1", 25, 240, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	DermaPanel.btnClose.Paint = function(panel, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawLine(10, 10, 20, 20)
		surface.DrawLine(10, 20, 20, 10)
	end

	DermaPanel.btnClose.DoClick = function(button)
		DermaPanel:Close()
	end

	DermaPanel.btnMaxim.Paint = function(panel, w, h) end
	DermaPanel.btnMinim.Paint = function(panel, w, h) end
	local TextEntryTitle = vgui.Create("DTextEntry", DermaPanel)
	TextEntryTitle:SetPos(190, 20)
	TextEntryTitle:SetSize(130, 30)
	TextEntryTitle:SetText("")
	TextEntryTitle:SetDrawLanguageID(false)
	local DComboBoxRentalmode = vgui.Create("DComboBox", DermaPanel)
	DComboBoxRentalmode:SetPos(170, 70)
	DComboBoxRentalmode:SetSize(150, 30)
	DComboBoxRentalmode:SetSortItems(false)
	DComboBoxRentalmode:SetValue(ghomes.leasingpurchase)
	DComboBoxRentalmode:AddChoice(ghomes.leasingpurchase)
	DComboBoxRentalmode:AddChoice(ghomes.purchasesonly)
	DComboBoxRentalmode:AddChoice(ghomes.leasingonly)

	DComboBoxRentalmode.OnSelect = function(panel, index, value)
		selectedRentalMode = index
	end

	local sliderPercentValue = vgui.Create("DNumSlider", DermaPanel)
	sliderPercentValue:SetPos(365, 87)
	sliderPercentValue:SetSize(275, 10)
	sliderPercentValue:SetText("")
	sliderPercentValue:SetMin(0.01)
	sliderPercentValue:SetMax(10)
	sliderPercentValue:SetDecimals(1)
	sliderPercentValue.Scratch:SetVisible(false)
	sliderPercentValue.Label:SetVisible(false)
	sliderPercentValue:SetValue(priceRatio)

	sliderPercentValue.OnValueChanged = function(pnl, value)
		priceRatio = value
		purchasetext = ghomes.purchaseprice .. ghomes.wrapper.formatMoney(math.ceil(propertysize * priceRatio / 1000))
		renttext = ghomes.rentalprice .. ghomes.wrapper.formatMoney(math.ceil(propertysize * priceRatio / 1000 / 182)) .. ghomes.perdays
	end

	sliderPercentValue.Slider.Paint = function(self, w, h)
		surface.SetDrawColor(75, 75, 75, 100)
		surface.DrawRect(0, h / 2 - 2, w - 12, 3)
	end

	sliderPercentValue.Slider.Knob.Paint = function(self, w, h)
		surface.SetDrawColor(150, 150, 255, 255)
		surface.DrawRect(0, 0, 3, h)
	end

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

		net.Start("ghomes_newhouse")
		net.WriteBool(false)
		net.WriteUInt(selectedhouse, 7)
		net.WriteUInt(math.ceil(propertysize * priceRatio / 1000), 32)
		net.WriteUInt(math.ceil(propertysize * priceRatio / 1000 / 182), 32)
		net.WriteUInt(selectedRentalMode, 3)
		net.WriteString(TextEntryTitle:GetValue())
		net.WriteTable(housedata.boxes)
		net.WriteTable(housedata.panelpos)
		net.WriteTable(housedata.panelangle)
		net.WriteVector(housedata.textpos)
		net.WriteAngle(housedata.textangle)
		net.WriteVector(housedata.bellpos)
		net.WriteVector(housedata.camerapos)
		net.WriteAngle(housedata.cameraangle)
		net.SendToServer()
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

function ghomes.confirmpurchase(houseid, pnl)
	local house = ghomes.list[houseid]
	local btnToogle1
	local sliderPercentValue
	local day_hours_toggle
	local DermaPanel = vgui.Create("DFrame")
	local days = 1
	local hours = 1

	local rentingInDays = allowedToRentInDays


	if house.buyablemode == 1 then
		DermaPanel:SetSize(650, 200)
	elseif house.buyablemode == 2 then
		DermaPanel:SetSize(450, 120)
	else
		DermaPanel:SetSize(650, 150)
	end

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
			local target = self.movey - (time * 3000)

			if (target + self:GetTall() < 0) then
				self:Close()

				return
			end

			self:SetPos(x, target)
		end
	end

	local endText = ""

	if house.buyablemode < 3 then
		endText = Format(ghomes.purchasefor, house.name, ghomes.wrapper.formatMoney(house.permaprice))
	else
		if rentingInDays then
			endText = Format(ghomes.renthomefordays, house.name, 1, ghomes.wrapper.formatMoney(math.Truncate(house.rentprice)))
		else
			endText = Format(ghomes.renthomeforhours, house.name, 1, ghomes.wrapper.formatMoney(math.Truncate(house.rentprice / 24)))
		end
	end

	if house.buyablemode == 2 then
		surface.SetFont("GuiSentData1")
		local w1 = surface.GetTextSize(endText)
		w1 = math.Max(w1 + 50, 300)
		DermaPanel:SetWide(w1)
	end

	DermaPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color2)
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, color_white)
		draw.SimpleText(endText, "GuiSentData1", 25, 20, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

		if house.buyablemode == 1 and not btnToogle1:GetChecked() then
			draw.SimpleText(Format(rentingInDays and ghomes.numberofdays or ghomes.numberofhours, rentingInDays and days or hours), "GuiSentData1", 25, 110, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end

		if house.buyablemode == 3 then
			draw.SimpleText(Format(rentingInDays and ghomes.numberofdays or ghomes.numberofhours, rentingInDays and days or hours), "GuiSentData1", 25, 70, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end

	DermaPanel.btnClose.Paint = function(panel, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawLine(10, 10, 20, 20)
		surface.DrawLine(10, 20, 20, 10)
	end

	DermaPanel.btnClose.DoClick = function(button)
		DermaPanel:Close()
	end

	DermaPanel.btnMaxim.Paint = function(panel, w, h) end
	DermaPanel.btnMinim.Paint = function(panel, w, h) end
	local DermaButtonSend = vgui.Create("DButton", DermaPanel)
	DermaButtonSend:SetText("")
	DermaButtonSend:SetSize(DermaPanel:GetWide(), 40)
	DermaButtonSend:SetPos(0, DermaPanel:GetTall() - 40)
	DermaButtonSend.DoClick = function() end
	local n = Color(220, 220, 220)
	local y = Color(180, 180, 180)

	DermaButtonSend.Paint = function(self, w, h)
		local col = n

		if self:IsDown() then
			col = y
		end

		draw.RoundedBoxEx(8, 1, 0, w - 2, h - 1, col, false, false, true, true)
		surface.SetDrawColor(color_white)
		surface.SetMaterial(cart)
		surface.DrawTexturedRect(w / 2 - 16, h / 2 - 16, 32, 32)
	end

	DermaButtonSend.DoClick = function()
		DermaPanel.goup = true
		DermaPanel.movetime = CurTime()
		DermaPanel.movey = select(2, DermaPanel:GetPos())
		net.Start("ghomes_command")
		net.WriteUInt(houseid, 7)
		net.WriteUInt(0, 4)

		if house.buyablemode == 1 then
			if btnToogle1:GetChecked() then
				net.WriteBool(true)
			else
				net.WriteBool(false)
				if rentingInDays then
					net.WriteUInt(ghomes.daytosaletotimestamp(days), 32)
				else
					net.WriteUInt(3600 * hours, 32)
				end
			end
		elseif house.buyablemode == 2 then
			net.WriteBool(true)
		else
			net.WriteBool(false)
			if rentingInDays then
				net.WriteUInt(ghomes.daytosaletotimestamp(days), 32)
			else
				net.WriteUInt(3600 * hours, 32)
			end
		end

		net.SendToServer()

		if IsValid(pnl) then
			pnl:Close()
		end
	end

	if house.buyablemode == 1 then
		btnToogle1 = vgui.Create("DCheckBox", DermaPanel)
		btnToogle1:SetSize(146, 38)
		btnToogle1:SetPos(25, 60)
		btnToogle1:SetChecked(true)
		btnToogle1:SetValue(1)
		btnToogle1.changetime = CurTime()
		btnToogle1.text = ghomes.purchase

		btnToogle1.OnChange = function(pnl, val)
			pnl.changetime = CurTime()

			if (val) then
				btnToogle1.text = ghomes.purchase
				endText = Format(ghomes.purchasefor, house.name, ghomes.wrapper.formatMoney(math.Truncate(house.permaprice)))

				if sliderPercentValue then
					sliderPercentValue:Remove()
				end

				if day_hours_toggle then
					day_hours_toggle:Remove()
				end

			else
				if rentingInDays then
					endText = Format(ghomes.renthomefordays, house.name, days, ghomes.wrapper.formatMoney(math.Truncate(house.rentprice)))
				else
					endText = Format(ghomes.renthomeforhours, house.name, hours, ghomes.wrapper.formatMoney(math.Truncate(house.rentprice / 24)))
				end
				btnToogle1.text = ghomes.rent
				sliderPercentValue = vgui.Create("DNumSlider", DermaPanel)
				sliderPercentValue:SetPos(260, 118)
				sliderPercentValue:SetSize(275, 10)
				sliderPercentValue:SetText("")
				sliderPercentValue:SetMin(1)
				sliderPercentValue:SetMax(rentingInDays and ghomes.maxdaysrent or ghomes.maxdaysrent * 24)
				sliderPercentValue:SetDecimals(0)
				sliderPercentValue.Scratch:SetVisible(false)
				sliderPercentValue.Label:SetVisible(false)
				sliderPercentValue:SetValue(1)

				sliderPercentValue.OnValueChanged = function(pnl, value)
					days = math.Truncate(value)
					hours = math.Truncate(value)
					if rentingInDays then
						endText = Format(ghomes.renthomefordays, house.name, days, ghomes.wrapper.formatMoney(math.Truncate(house.rentprice * days)))
					else
						endText = Format(ghomes.renthomeforhours, house.name, days, ghomes.wrapper.formatMoney(math.Truncate(house.rentprice / 24 * days)))
					end
				end

				sliderPercentValue.Slider.Paint = function(self, w, h)
					surface.SetDrawColor(75, 75, 75, 100)
					surface.DrawRect(0, h / 2 - 2, w - 12, 4)
				end

				sliderPercentValue.Slider.Knob.Paint = function(self, w, h)
					surface.SetDrawColor(150, 150, 255, 255)
					surface.DrawRect(0, 0, 3, h)
				end

				if allowedToRentInDays then
					day_hours_toggle = vgui.Create( "DCheckBoxLabel", DermaPanel )
					day_hours_toggle:SetPos( 530, 115 )
					day_hours_toggle:SetSize(50,50)
					day_hours_toggle:SetText( Format("%s/%s", ghomes.unitday, ghomes.unithour) )
					day_hours_toggle:SetTextColor(Color(0,0,0))
					day_hours_toggle:SetChecked(rentingInDays)
					day_hours_toggle.OnChange = function(pnl, bVal)

						rentingInDays = bVal
						sliderPercentValue:SetMax(rentingInDays and ghomes.maxdaysrent or math.Min(72, ghomes.maxdaysrent * 24))
						if rentingInDays then
							sliderPercentValue:SetValue(sliderPercentValue:GetValue() / 24)
							endText = Format(ghomes.renthomefordays, house.name, days, ghomes.wrapper.formatMoney(math.Truncate(house.rentprice * days)))
						else
							sliderPercentValue:SetValue(sliderPercentValue:GetValue() * 24)
							endText = Format(ghomes.renthomeforhours, house.name, hours, ghomes.wrapper.formatMoney(math.Truncate(house.rentprice / 24 * days)))
						end
					end
				end

			end
		end

		local cursize = 32
		btnToogle1.curspos = btnToogle1:GetWide() - cursize
		local movtime = 0.1

		btnToogle1.Paint = function(pnl, w, h)
			local col21 = Color(68, 139, 202)
			local col22 = Color(229, 229, 229)
			draw.RoundedBox(8, 0, 0, w, h, color2)
			draw.RoundedBox(8, 1, 1, pnl.curspos + cursize / 2, h - 2, col21)
			draw.RoundedBox(8, pnl.curspos + cursize / 2, 1, w - pnl.curspos - cursize / 2 - 1, h - 2, col22)

			if (pnl:GetChecked()) then
				pnl.curspos = math.Remap(math.Min(CurTime(), pnl.changetime + movtime), pnl.changetime, pnl.changetime + movtime, 0, pnl:GetWide() - cursize)
			else
				pnl.curspos = math.Remap(math.Min(CurTime(), pnl.changetime + movtime), pnl.changetime, pnl.changetime + movtime, pnl:GetWide() - cursize, 0)
			end

			draw.RoundedBox(8, btnToogle1.curspos, 0, cursize, btnToogle1:GetTall(), color2)
			draw.RoundedBox(8, btnToogle1.curspos + 1, 1, cursize - 2, btnToogle1:GetTall() - 2, color_white)

			if (pnl:GetChecked()) then
				draw.SimpleText(pnl.text, "GuiSentData1", w / 2 - cursize / 2, 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			else
				draw.SimpleText(pnl.text, "GuiSentData1", w / 2 + cursize / 2, 5, color_grey, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end
		end
	end

	if house.buyablemode == 3 then
		sliderPercentValue = vgui.Create("DNumSlider", DermaPanel)
		sliderPercentValue:SetPos(260, 78)
		sliderPercentValue:SetSize(275, 10)
		sliderPercentValue:SetText("")
		sliderPercentValue:SetMin(1)
		sliderPercentValue:SetMax(rentingInDays and ghomes.maxdaysrent or ghomes.maxdaysrent * 24)
		sliderPercentValue:SetDecimals(0)
		sliderPercentValue.Scratch:SetVisible(false)
		sliderPercentValue.Label:SetVisible(false)
		sliderPercentValue:SetValue(1)

		sliderPercentValue.OnValueChanged = function(pnl, value)
			days = math.Truncate(value)
			hours = math.Truncate(value)
			if rentingInDays then
				endText = Format(ghomes.renthomefordays, house.name, days, ghomes.wrapper.formatMoney(math.Truncate(house.rentprice * days)))
			else
				endText = Format(ghomes.renthomeforhours, house.name, hours, ghomes.wrapper.formatMoney(math.Truncate(house.rentprice / 24 * days)))
			end
		end

		sliderPercentValue.Slider.Paint = function(self, w, h)
			surface.SetDrawColor(75, 75, 75, 100)
			surface.DrawRect(0, h / 2 - 2, w - 12, 4)
		end

		sliderPercentValue.Slider.Knob.Paint = function(self, w, h)
			surface.SetDrawColor(150, 150, 255, 255)
			surface.DrawRect(0, 0, 3, h)
		end

		if allowedToRentInDays then
			day_hours_toggle = vgui.Create( "DCheckBoxLabel", DermaPanel )

			day_hours_toggle:SetPos( 530, 75 )
			day_hours_toggle:SetSize(50,50)
			day_hours_toggle:SetText( Format("%s/%s", ghomes.unitday, ghomes.unithour) )
			day_hours_toggle:SetTextColor(Color(0,0,0))
			day_hours_toggle:SetChecked(rentingInDays)
			day_hours_toggle.OnChange = function(pnl, bVal)
				rentingInDays = bVal
				sliderPercentValue:SetMax(rentingInDays and ghomes.maxdaysrent or math.Min(72, ghomes.maxdaysrent * 24))
				if rentingInDays then
					sliderPercentValue:SetValue(sliderPercentValue:GetValue() / 24)
					endText = Format(ghomes.renthomefordays, house.name, days, ghomes.wrapper.formatMoney(math.Truncate(house.rentprice * days)))
				else
					sliderPercentValue:SetValue(sliderPercentValue:GetValue() * 24)
					endText = Format(ghomes.renthomeforhours, house.name, hours, ghomes.wrapper.formatMoney(math.Truncate(house.rentprice / 24 * days)))
				end
			end
		end



	end
end

local function WordWrap(str, limit)
	limit = limit or 72
	local here = 1
	local buf = ""
	local t = {}

	str:gsub("(%s*)()(%S+)()", function(sp, st, word, fi)
		if fi - here > limit then
			--# Break the line
			here = st
			table.insert(t, buf)
			buf = word
		else
			buf = buf .. sp .. word
		end
	end)

	if (buf ~= "") then
		table.insert(t, buf)
	end

	local result = ""

	for k, v in pairs(t) do
		result = result .. v .. "\n"
	end

	return result
end

function ghomes.confirmsell(id, pnl)
	local house = ghomes.list[id]
	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(1000, 300)
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

	local selltext

	if house.ispermarented then
		selltext = Format(ghomes.confirmsell1, house.name, ghomes.wrapper.formatMoney(math.Truncate(house.permaprice * ghomes.percentageOnSell)), ghomes.percentageOnSell * 100)
		selltext = WordWrap(selltext, 50)
	else
		selltext = Format(ghomes.confirmbreaklease)
	end

	DermaPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color2)
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, color_white)
		--draw.SimpleText(selltext, "GuiSentData1", 25, 20, color2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.DrawText(selltext, "GuiSentData2", 25, 20, color2, TEXT_ALIGN_LEFT)
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

	local DermaButtonSend = vgui.Create("DButton", DermaPanel)
	DermaButtonSend:SetText("")
	DermaButtonSend:SetSize(DermaPanel:GetWide(), 100)
	DermaButtonSend:SetPos(0, DermaPanel:GetTall() - 100)

	DermaButtonSend.DoClick = function()
		DermaPanel.goup = true
		DermaPanel.movetime = CurTime()
		DermaPanel.movey = select(2, DermaPanel:GetPos())

		if (selectedhouse ~= 0) then
			ghomes.list[selectedhouse].beingedited = false
		end

		net.Start("ghomes_command")
		net.WriteUInt(id, 7)
		net.WriteUInt(2, 4)
		net.SendToServer()

		if IsValid(pnl) then
			pnl:Close()
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
		surface.SetMaterial(refund)
		surface.DrawTexturedRect(w / 2 - 32, h / 2 - 32, 64, 64)
	end
end

function ghomes.buddiespanel(id, pnl)
	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(900, 450)
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
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, color_white)
		draw.DrawText(ghomes.managebuddies, "GuiSentData1", w / 2, 10, color2, TEXT_ALIGN_CENTER)
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

	local PlayerList = vgui.Create("DListView", DermaPanel)
	PlayerList:SetMultiSelect(false)
	PlayerList:AddColumn(ghomes.buddiestitle2)
	PlayerList:AddColumn("SteamID")
	PlayerList:SetPos(3, 50)
	PlayerList:SetSize(400, 300)
	local BuddiesList = vgui.Create("DListView", DermaPanel)
	BuddiesList:SetMultiSelect(false)
	BuddiesList:AddColumn(ghomes.buddiestitle3)
	BuddiesList:AddColumn("SteamID")
	BuddiesList:SetPos(503, 50)
	BuddiesList:SetSize(395, 300)
	local add = vgui.Create("DButton", DermaPanel)
	add:SetPos(440, 130)
	add:SetText(">>")
	add:SetSize(30, 30)

	add.DoClick = function()
		if not PlayerList:GetSelectedLine() then return end
		local selected = PlayerList:GetSelectedLine()
		local line = PlayerList:GetLines()
		BuddiesList:AddLine(line[selected]:GetValue(1), line[selected]:GetValue(2))
		PlayerList:RemoveLine(selected)
	end

	local remove = vgui.Create("DButton", DermaPanel)
	remove:SetPos(440, 170)
	remove:SetText("<<")
	remove:SetSize(30, 30)

	remove.Paint = function(pnl, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color2)
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, color_white)
	end

	add.Paint = remove.Paint

	remove.DoClick = function()
		if not BuddiesList:GetSelectedLine() then return end
		local selected = BuddiesList:GetSelectedLine()
		local line = BuddiesList:GetLines()
		PlayerList:AddLine(line[selected]:GetValue(1), line[selected]:GetValue(2))
		BuddiesList:RemoveLine(selected)
	end

	for k, v in pairs(player.GetAll()) do
		if v:SteamID() == LocalPlayer():SteamID() then continue end -- dnt ad urself lel
		if ghomes.onlyAllowFriendsAsCoOwner and  (v:GetFriendStatus() ~= "friend") then continue end
		if table.HasValue(ghomes.list[id].friends, v:SteamID()) then continue end --dnt ad ur friend twic lel
		PlayerList:AddLine(v:Nick(), v:SteamID())
	end

	for k, v in pairs(ghomes.list[id].friendsname) do
		BuddiesList:AddLine(v, ghomes.list[id].friends[k])
	end

	local DermaButtonSend = vgui.Create("DButton", DermaPanel)
	DermaButtonSend:SetText("")
	DermaButtonSend:SetSize(DermaPanel:GetWide(), 40)
	DermaButtonSend:SetPos(0, DermaPanel:GetTall() - 40)

	DermaButtonSend.DoClick = function()
		DermaPanel.goup = true
		DermaPanel.movetime = CurTime()
		DermaPanel.movey = select(2, DermaPanel:GetPos())
		local lines = BuddiesList:GetLines()
		local tbl1 = {}
		local tbl2 = {}

		for k, v in pairs(lines) do
			tbl1[k] = v:GetValue(1)
			tbl2[k] = v:GetValue(2)
		end

		net.Start("ghomes_command")
		net.WriteUInt(id, 7)
		net.WriteUInt(3, 4)
		net.WriteTable(tbl1)
		net.WriteTable(tbl2)
		net.SendToServer()

		if IsValid(pnl) then
			pnl:Remove()
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

function ghomes.renewlease(id)
	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(600, 250)
	DermaPanel:SetTitle("")
	DermaPanel:SetDraggable(false)
	DermaPanel:MakePopup()
	DermaPanel:Center()
	DermaPanel.lblTitle.Paint = function() end
	DermaPanel.goup = false
	DermaPanel.movetime = 0
	DermaPanel.movey = 0
	local rentingInDays = ghomes.maxdaysrent > 1
	local rentaldays = 1
	local rentalhours = 1

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
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, color_white)
		--draw.DrawText("Renew the lease", "GuiSentData1", w / 2, 10, color2, TEXT_ALIGN_CENTER)
		draw.DrawText(ghomes.renewleasetext, "GuiSentData1", 20, 30, color2, TEXT_ALIGN_LEFT)
		draw.DrawText(rentingInDays and ghomes.numberofdays2 or ghomes.numberofhours2 , "GuiSentData1", 20, 116, color2, TEXT_ALIGN_LEFT)
		if rentingInDays then
			draw.DrawText(Format(ghomes.itwillcostyou, ghomes.wrapper.formatMoney(math.Round(ghomes.list[id].rentprice * rentaldays)), rentaldays), "GuiSentData1", 20, 165, color2, TEXT_ALIGN_LEFT)
		else
			draw.DrawText(Format(ghomes.itwillcostyouhour, ghomes.wrapper.formatMoney(math.Round(ghomes.list[id].rentprice / 24 * rentaldays)), rentalhours), "GuiSentData1", 20, 165, color2, TEXT_ALIGN_LEFT)
		end
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

		net.Start("ghomes_command")
		net.WriteUInt(id, 7)
		net.WriteUInt(4, 4)
		if rentingInDays then
			net.WriteUInt(ghomes.daytosaletotimestamp(rentaldays), 32)
		else
			net.WriteUInt(3600 * rentalhours, 32)
		end
		net.SendToServer()
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
		surface.SetMaterial(refund)
		surface.DrawTexturedRect(w / 2 - 16, h / 2 - 16, 32, 32)
	end

	local sliderPercentValue = vgui.Create("DNumSlider", DermaPanel)
	sliderPercentValue:SetPos(260, 125)
	sliderPercentValue:SetSize(275, 10)
	sliderPercentValue:SetText("")
	sliderPercentValue:SetMin(1)
	sliderPercentValue:SetMax(rentingInDays and ghomes.maxdaysrent or ghomes.maxdaysrent * 24)
	sliderPercentValue:SetDecimals(0)
	sliderPercentValue.Scratch:SetVisible(false)
	sliderPercentValue.Label:SetVisible(false)
	sliderPercentValue:SetValue(1)

	sliderPercentValue.OnValueChanged = function(pnl, value)
		rentaldays = math.Truncate(value)
		rentalhours = math.Truncate(value)
	end

	sliderPercentValue.Slider.Paint = function(self, w, h)
		surface.SetDrawColor(75, 75, 75, 100)
		surface.DrawRect(0, h / 2 - 2, w - 12, 4)
	end

	sliderPercentValue.Slider.Knob.Paint = function(self, w, h)
		surface.SetDrawColor(150, 150, 255, 255)
		surface.DrawRect(0, 0, 3, h)
	end

	if allowedToRentInDays then
		local day_hours_toggle = vgui.Create( "DCheckBoxLabel", DermaPanel )
		day_hours_toggle:SetPos( 520, 124 )
		day_hours_toggle:SetSize(50,50)
		day_hours_toggle:SetText( Format("%s/%s", ghomes.unitday, ghomes.unithour) )
		day_hours_toggle:SetTextColor(Color(0,0,0))
		day_hours_toggle:SetChecked(rentingInDays)
		day_hours_toggle.OnChange = function(pnl, bVal)
			rentingInDays = bVal
			sliderPercentValue:SetMax(rentingInDays and ghomes.maxdaysrent or math.Min(72, ghomes.maxdaysrent * 24))
			if rentingInDays then
				sliderPercentValue:SetValue(sliderPercentValue:GetValue() / 24)
			else
				sliderPercentValue:SetValue(sliderPercentValue:GetValue() * 24)
			end
		end
	end

end

local function unittometter(unit)
	return math.Remap(unit, 0, 96, 0, 1.73736)
end

function ghomes.sellermenu()
	if ScrW() < 1280 or ScrH() < 720 then --  2018 mate, time to move on
		LocalPlayer():ChatPrint("Your monitor resolution is too small to show the panel, please enter the 21th century and get a new one.\nOr go directly to the homes to buy/rent them")
		return
	end
	local genlist
	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(1300, ScrH() - 100)
	DermaPanel:SetTitle("")
	DermaPanel:SetDraggable(false)
	DermaPanel:MakePopup()
	DermaPanel:Center()
	DermaPanel.lblTitle.Paint = function() end
	DermaPanel.goup = false
	DermaPanel.movetime = 0
	DermaPanel.movey = 0
	local previewhouse = false


	local Search = vgui.Create( "DTextEntry",  DermaPanel)
	Search:SetPlaceholderText( "#spawnmenu.search" )
	Search:SetSize(120, 20)
	Search:SetPos(DermaPanel:GetWide() - 150, 40 )
	Search:SetDrawLanguageID(false)
	Search:SetTooltip( "just type lol" )

	local btn = Search:Add( "DImageButton" )

	btn:SetImage( "icon16/magnifier.png" )
	btn:SetText( "" )
	btn:Dock( RIGHT )
	btn:DockMargin( 4, 2, 4, 2 )
	btn:SetSize( 16, 16 )
	btn:SetTooltip( "#spawnmenu.press_search" )

	Search.OnChange = function( p )
		genlist(p:GetValue())
	end

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

	local color42 = Color(240, 240, 240)
	local color_green = Color(100, 155, 100)
	local color_red = Color(155, 100, 100)
	local color_blue = Color(85, 156, 253)

	DermaPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color2)
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, color42)
		draw.DrawText(ghomes.realestateagent, "GuiSentData1", w / 2, 5, color2, TEXT_ALIGN_CENTER)
		draw.DrawText(ghomes.information, "GuiSentData3", 170, 30, color2, TEXT_ALIGN_LEFT)
		draw.DrawText(ghomes.status, "GuiSentData3", w / 2, 30, color2, TEXT_ALIGN_CENTER)
		draw.DrawText(ghomes.actions, "GuiSentData3", w - 170, 30, color2, TEXT_ALIGN_RIGHT)
		if previewhouse then
			draw.DrawText(ghomes.previewofhome, "GuiSentData3", w / 4, DermaPanel:GetTall() - 353, color2, TEXT_ALIGN_CENTER)
		end
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


	local function preview()
		DermaPanel.scrollHomes:SetSize(DermaPanel:GetWide() - 10,  DermaPanel:GetTall() - 420)
		local renderPanel = vgui.Create("DPanel", DermaPanel)
		renderPanel:SetSize(DermaPanel:GetWide() / 2 - 20, 300)
		renderPanel:SetPos(10, DermaPanel:GetTall() - renderPanel:GetTall() - 10)

		renderPanel.Paint = function(pnl, w, h)
			if not previewhouse then return end
			local x1, y1 = renderPanel:GetPos()
			local x2, y2 = DermaPanel:GetPos()
			local x = x1 + x2
			local y = y1 + y2
			--local offset = Vector(2.5, 0, 0) * math.sin(CurTime() / 2) + Vector(0, 1.5, 0) * math.cos(CurTime() / 1.5) + Vector(0, 0, 3) * math.cos(CurTime() / 3)
			local offset = Vector(2.5, 0, 0)
			offset:Mul(math.sin(CurTime() / 2))
			local offset2 = Vector(0, 1.5, 0)
			offset2:Mul(math.cos(CurTime() / 1.5))
			local offset3 = Vector(0, 0, 3)
			offset3:Mul(math.cos(CurTime() / 3))
			offset:Add(offset2)
			offset:Add(offset3)

			local offsetangle = Angle(offset.x, offset.y, 0)
			offsetangle:Add(previewhouse.cameraangle)
			cam.Start2D()
			offset:Add(previewhouse.camerapos)
			render.RenderView({
				origin = offset,
				angles = offsetangle,
				x = x,
				y = y,
				w = w,
				h = h,
				drawviewmodel = false
			})
			cam.End2D()
		end





		local panelInfos = vgui.Create("DPanel", DermaPanel)
		panelInfos.pos = false
		panelInfos.angle = false
		panelInfos:SetSize(DermaPanel:GetWide() / 2 - 20, 300)
		panelInfos:SetPos(DermaPanel:GetWide() / 2 + 10, DermaPanel:GetTall() - panelInfos:GetTall() - 10)
		local t_color = Color(40, 40, 40, 255)
		local m_color = Color(230, 230, 230, 255)

		panelInfos.Paint = function(pnl, w, h)
			draw.RoundedBox(8, 0, 0, w, h, color_white)
			local v = previewhouse
			--if not v.isrented then
			local x = v.boxes[2].x - v.boxes[1].x
			local y = v.boxes[2].y - v.boxes[1].y
			local z = v.boxes[2].z - v.boxes[1].z

			if v.buyablemode == 1 then
				draw.RoundedBox(8, 25, 25, 400, 100, m_color)
				draw.SimpleText(Format(ghomes.purchaseprice2, ghomes.wrapper.formatMoney(v.permaprice)), "DrawHouseNameSmall24", 35, 30, t_color, TEXT_ALIGN_LEFT)
				draw.SimpleText(Format(ghomes.dailypricerental, ghomes.wrapper.formatMoney(v.rentprice)), "DrawHouseNameSmall24", 35, 60, t_color, TEXT_ALIGN_LEFT)
				draw.SimpleText(Format(ghomes.numberofdoors, v.ndoors), "DrawHouseNameSmall24", 35, 90, t_color, TEXT_ALIGN_LEFT)
				draw.RoundedBox(8, 25, 145, 200, 105, m_color)
				draw.SimpleText(Format(ghomes.heightm, unittometter(z)), "DrawHouseNameSmall24", 35, 150, t_color, TEXT_ALIGN_LEFT)
				draw.SimpleText(Format(ghomes.lengthm, unittometter(x)), "DrawHouseNameSmall24", 35, 180, t_color, TEXT_ALIGN_LEFT)
				draw.SimpleText(Format(ghomes.widthm, unittometter(y)), "DrawHouseNameSmall24", 35, 210, t_color, TEXT_ALIGN_LEFT)
			else
				draw.RoundedBox(8, 25, 25, 400, 70, m_color)

				if v.buyablemode == 2 then
					draw.SimpleText(Format(ghomes.purchaseprice2, ghomes.wrapper.formatMoney(v.permaprice)), "DrawHouseNameSmall24", 35, 30, t_color, TEXT_ALIGN_LEFT)
				else
					draw.SimpleText(Format(ghomes.dailypricerental, ghomes.wrapper.formatMoney(v.rentprice)), "DrawHouseNameSmall24", 35, 30, t_color, TEXT_ALIGN_LEFT)
				end

				draw.SimpleText(Format(ghomes.numberofdoors, v.ndoors), "DrawHouseNameSmall24", 35, 60, t_color, TEXT_ALIGN_LEFT)
				draw.RoundedBox(8, 25, 115, 200, 100, m_color)
				draw.SimpleText(Format(ghomes.heightm, unittometter(z)), "DrawHouseNameSmall24", 35, 120, t_color, TEXT_ALIGN_LEFT)
				draw.SimpleText(Format(ghomes.lengthm, unittometter(x)), "DrawHouseNameSmall24", 35, 150, t_color, TEXT_ALIGN_LEFT)
				draw.SimpleText(Format(ghomes.widthm, unittometter(y)), "DrawHouseNameSmall24", 35, 180, t_color, TEXT_ALIGN_LEFT)
			end
		end

		local buttonClose = vgui.Create("DButton", panelInfos)
		buttonClose:SetSize(20, 20)
		buttonClose:SetPos(panelInfos:GetWide() - 40, 10)
		buttonClose:SetText("")

		buttonClose.Paint = function(panel, w, h)
			surface.SetDrawColor(240, 240, 240, 255)
			draw.RoundedBox(4, 0, 0, w, h, Color(240,240,240))
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawLine(0, 0, 20, 20)
			surface.DrawLine(0, 20, 20, 0)
		end

		buttonClose.DoClick = function()
			panelInfos:Remove()
			renderPanel:Remove()
			previewhouse.previewing = nil
			previewhouse = false;
			DermaPanel.scrollHomes:SetSize(DermaPanel:GetWide() - 10, DermaPanel:GetTall() - 83)
		end

	end

	--end

	local color_black = Color(0, 0, 0)
	local radius = 8
	genlist = function(filter)
		if filter == "" then filter = nil end
		if DermaPanel.scrollHomes then
			DermaPanel.scrollHomes:Remove()
		end

		DermaPanel.scrollHomes = vgui.Create("DScrollPanel", DermaPanel)
		DermaPanel.scrollHomes:SetPos(5, 65)
		DermaPanel.scrollHomes:SetSize(DermaPanel:GetWide() - 10, DermaPanel:GetTall() - 83)


		local y = 0
		for k, v in ipairs(ghomes.list) do
			if filter and not string.find(string.lower(v.name), string.lower(filter), 1, true) then continue end
			y = y + 1
			local DLabel = vgui.Create("DPanel", DermaPanel.scrollHomes)
			DLabel:SetSize(DermaPanel.scrollHomes:GetWide() - 25, 90)
			DLabel:SetPos(5, 10 + (y - 1) * 100)
			local pricetext

			if v.buyablemode == 1 then
				pricetext = Format(ghomes.priceorperday, ghomes.wrapper.formatMoney(v.permaprice), ghomes.wrapper.formatMoney(v.rentprice))
			elseif v.buyablemode == 2 then
				pricetext = Format(ghomes.priceorperday2, ghomes.wrapper.formatMoney(v.permaprice))
			else
				pricetext = Format(ghomes.priceorperday3, ghomes.wrapper.formatMoney(v.rentprice))
			end

			DLabel.Paint = function(pnl, w, h)
				draw.RoundedBox(radius, 0, 0, w, h, color_black)
				draw.RoundedBox(radius, 1, 1, w - 2, h - 2, color_white)
				draw.DrawText(v.name, "GuiSentData3", 10, 6, color_black, TEXT_ALIGN_LEFT)
				draw.DrawText(pricetext, "GuiSentData3", 10, 42, color_black, TEXT_ALIGN_LEFT)
			end

			local isFriend = table.HasValue(v.friends, LocalPlayer():SteamID())
			local isOwner = v.owner == LocalPlayer()

			do
				local xoffset = DLabel:GetTall()
				local color_red = Color(235, 75, 75, 255)
				local color_green = Color(151, 195, 34)

				if v.isrented then
					local statusNotAvailable = vgui.Create("DPanel", DLabel)
					statusNotAvailable:SetSize(xoffset * 1.5, xoffset)
					statusNotAvailable:SetPos(DLabel:GetWide() / 2 - statusNotAvailable:GetWide() / 2, 0)

					if not isOwner and not isFriend then
						statusNotAvailable.Paint = function(pnl, w, h)
							surface.SetDrawColor(color_red)
							surface.SetMaterial(close)
							surface.DrawTexturedRect(w / 2 - 32, 1, 64, 64)
							draw.DrawText(ghomes.notavailable, "GuiSentData1", w / 2, h - 30, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						end
					elseif isFriend then
						statusNotAvailable.Paint = function(pnl, w, h)
							surface.SetDrawColor(color_blue)
							surface.SetMaterial(tick)
							surface.DrawTexturedRect(w / 2 - 32, 1, 64, 64)
							draw.DrawText(ghomes.coowned, "GuiSentData1", w / 2, h - 30, color_blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						end
					else
						statusNotAvailable.Paint = function(pnl, w, h)
							surface.SetDrawColor(color_green)
							surface.SetMaterial(tick)
							surface.DrawTexturedRect(w / 2 - 32, 1, 64, 64)
							draw.DrawText(ghomes.owned, "GuiSentData1", w / 2, h - 30, color_green, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						end
					end
				end
			end

			do
				local nbutton = 0
				local buttonBuy
				local buttonSell
				local buttonBuddy
				local buttonAdmin
				local buttonConfig
				local xoffset = DLabel:GetTall()

				if v.isrented == false then
					nbutton = nbutton + 1
					buttonBuy = vgui.Create("DButton", DLabel)
					buttonBuy:SetSize(xoffset, xoffset)
					buttonBuy:SetPos(DLabel:GetWide() - xoffset * nbutton, 0)
					buttonBuy:SetText("")

					buttonBuy.Paint = function(pnl, w, h)
						surface.SetDrawColor(color_green)
						surface.SetMaterial(billet)
						surface.DrawTexturedRect(w / 2 - 32, 5, 64, 64)
						draw.DrawText(ghomes.buy, "GuiSentData1", w / 2, 60, color_green, TEXT_ALIGN_CENTER)
					end

					buttonBuy.DoClick = function()
						ghomes.confirmpurchase(k, DermaPanel)
					end
				elseif isOwner or LocalPlayer():CanMasterHouse() then
					nbutton = nbutton + 1
					buttonSell = vgui.Create("DButton", DLabel)
					buttonSell:SetSize(xoffset, xoffset)
					buttonSell:SetPos(DLabel:GetWide() - xoffset * nbutton, 0)
					buttonSell:SetText("")

					buttonSell.DoClick = function()
						if isOwner then
							ghomes.confirmsell(k, DermaPanel)
						else
							net.Start("ghomes_force_sell")
							net.WriteUInt(k, 7)
							net.SendToServer()
							DermaPanel.goup = true
							DermaPanel.movetime = CurTime()
							DermaPanel.movey = select(2, DermaPanel:GetPos())
						end
					end

					buttonSell.Paint = function(pnl, w, h)
						surface.SetDrawColor(color_red)
						surface.SetMaterial(refundw)
						surface.DrawTexturedRect(w / 2 - 32, 15, 64, 64)
						if isOwner then
							draw.DrawText(ghomes.clearoff, "GuiSentData1", w / 2, 60, color_red, TEXT_ALIGN_CENTER)
						else
							draw.DrawText(ghomes.evict, "GuiSentData1", w / 2, 60, color_red, TEXT_ALIGN_CENTER)
						end
					end

					nbutton = nbutton + 1
					buttonBuddy = vgui.Create("DButton", DLabel)
					buttonBuddy:SetSize(xoffset, xoffset)
					buttonBuddy:SetPos(DLabel:GetWide() - xoffset * nbutton, 0)
					buttonBuddy:SetText("")

					buttonBuddy.DoClick = function()
						ghomes.buddiespanel(k, DermaPanel)
					end

					buttonBuddy.Paint = function(pnl, w, h)
						surface.SetDrawColor(color_blue)
						surface.SetMaterial(friend)
						surface.DrawTexturedRect(w / 2 - 32, 5, 64, 64)
						draw.DrawText(ghomes.friends, "GuiSentData1", w / 2, 60, color_blue, TEXT_ALIGN_CENTER)
					end

					if ghomes.dlcs.dlc1 then
						nbutton = nbutton + 1
						buttonConfig = vgui.Create("DButton", DLabel)
						buttonConfig:SetSize(xoffset, xoffset)
						buttonConfig:SetPos(DLabel:GetWide() - xoffset * nbutton, 0)
						buttonConfig:SetText("")

						buttonConfig.Paint = function(pnl, w, h)
							surface.SetDrawColor(color_green)
							surface.SetMaterial(gear)
							surface.DrawTexturedRect(w / 2 - 32, 3, 64, 64)
							draw.DrawText("Edit", "GuiSentData1", w / 2, 60, color_green, TEXT_ALIGN_CENTER)
						end

						buttonConfig.DoClick = function()
							net.Start("ghomes_dlc1_use_suitcase3")
							net.WriteUInt(k, 7)
							net.SendToServer()
							--ghomes.dlcs.dlc1.settingshouse(k, NULL)
						end
					end
				end

				if v.isrented == false or isFriend or isOwner then
					nbutton = nbutton + 1
					local buttonPreview = vgui.Create("DButton", DLabel)
					buttonPreview:SetSize(xoffset, xoffset)
					buttonPreview:SetPos(DLabel:GetWide() - xoffset * nbutton, 0)
					buttonPreview:SetText("")

					buttonPreview.Paint = function(pnl, w, h)
						surface.SetDrawColor(color_black)
						surface.SetMaterial(eye)
						surface.DrawTexturedRect(w / 2 - 32, 3, 64, 64)
						draw.DrawText(ghomes.preview, "GuiSentData1", w / 2, 60, color_black, TEXT_ALIGN_CENTER)
					end

					buttonPreview.DoClick = function()
						if not previewhouse then
							preview()
						else
							previewhouse.previewing = nil
						end

						previewhouse = v
						previewhouse.previewing = true
					end
				end

				if LocalPlayer():CanMasterHouse() then
					nbutton = nbutton + 1
					buttonAdmin = vgui.Create("DButton", DLabel)
					buttonAdmin:SetSize(xoffset, xoffset)
					buttonAdmin:SetPos(DLabel:GetWide() - xoffset * nbutton, 0)
					buttonAdmin:SetText("")

					buttonAdmin.Paint = function(pnl, w, h)
						surface.SetDrawColor(color_black)
						surface.SetMaterial(gear)
						surface.DrawTexturedRect(w / 2 - 32, 3, 64, 64)
						draw.DrawText("Edit", "GuiSentData1", w / 2, 60, color_black, TEXT_ALIGN_CENTER)
					end

					buttonAdmin.DoClick = function()
						ghomes.edithouse(k, DermaPanel)
					end

					nbutton = nbutton + 1
					buttonAdmin = vgui.Create("DButton", DLabel)
					buttonAdmin:SetSize(xoffset, xoffset)
					buttonAdmin:SetPos(DLabel:GetWide() - xoffset * nbutton, 0)
					buttonAdmin:SetText("")

					buttonAdmin.Paint = function(pnl, w, h)
						surface.SetDrawColor(color_black)
						surface.SetMaterial(boom)
						surface.DrawTexturedRect(w / 2 - 32, 3, 64, 64)
						draw.DrawText("Remove", "GuiSentData1", w / 2, 60, color_black, TEXT_ALIGN_CENTER)
					end

					buttonAdmin.DoClick = function()
						ghomes.deletehouse(k, DermaPanel)
					end
				end
			end
		end
	end
	genlist()
end

function ghomes.edithouse(houseid, panelptr)
	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(600, 250)
	DermaPanel:SetTitle("")
	DermaPanel:SetDraggable(false)
	DermaPanel:MakePopup()
	DermaPanel:Center()
	DermaPanel.lblTitle.Paint = function() end
	DermaPanel.goup = false
	DermaPanel.movetime = 0
	DermaPanel.movey = 0
	local selectedRentalMode = ghomes.list[houseid].buyablemode

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

	local color42 = Color(240, 240, 240)

	DermaPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color2)
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, color42)
		draw.SimpleText("Property name", "GuiSentData1", 25, 20, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Leasing/Purchase mode", "GuiSentData1", 25, 70, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Daily price (Rental)", "GuiSentData1", 25, 120, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Purchase price (Perma)", "GuiSentData1", 25, 170, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
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

	local TextEntryTitle = vgui.Create("DTextEntry", DermaPanel)
	TextEntryTitle:SetPos(190, 20)
	TextEntryTitle:SetSize(130, 30)
	TextEntryTitle:SetDrawLanguageID(false)
	TextEntryTitle:SetText(ghomes.list[houseid].name)
	local DComboBoxRentalmode = vgui.Create("DComboBox", DermaPanel)
	DComboBoxRentalmode:SetPos(270, 70)
	DComboBoxRentalmode:SetSize(150, 30)
	DComboBoxRentalmode:SetSortItems(false)

	if (ghomes.list[houseid].buyablemode == 1) then
		DComboBoxRentalmode:SetValue(ghomes.leasingpurchase)
	elseif (ghomes.list[houseid].buyablemode == 2) then
		DComboBoxRentalmode:SetValue(ghomes.purchasesonly)
	else
		DComboBoxRentalmode:SetValue(ghomes.leasingonly)
	end

	DComboBoxRentalmode:AddChoice(ghomes.leasingpurchase)
	DComboBoxRentalmode:AddChoice(ghomes.purchasesonly)
	DComboBoxRentalmode:AddChoice(ghomes.leasingonly)

	DComboBoxRentalmode.OnSelect = function(panel, index, value)
		selectedRentalMode = index
	end

	local rentalPrice = vgui.Create("DNumberWang", DermaPanel)
	rentalPrice:SetPos(210, 120)
	rentalPrice:SetMinMax(0, 5000000000)
	rentalPrice:SetSize(70, 28)
	rentalPrice:SetValue(ghomes.list[houseid].rentprice)
	rentalPrice:HideWang()
	local purchasePrice = vgui.Create("DNumberWang", DermaPanel)
	purchasePrice:SetPos(250, 170)
	purchasePrice:SetMinMax(0, 5000000000)
	purchasePrice:SetSize(70, 28)
	purchasePrice:SetValue(ghomes.list[houseid].permaprice)
	purchasePrice:HideWang()
	local DermaButtonSend = vgui.Create("DButton", DermaPanel)
	DermaButtonSend:SetText("")
	DermaButtonSend:SetSize(DermaPanel:GetWide(), 40)
	DermaButtonSend:SetPos(0, DermaPanel:GetTall() - 40)
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

	DermaButtonSend.DoClick = function()
		DermaPanel.goup = true
		DermaPanel.movetime = CurTime()
		DermaPanel.movey = select(2, DermaPanel:GetPos())
		local housedata = ghomes.list[houseid]
		net.Start("ghomes_newhouse")
		net.WriteBool(true)
		net.WriteUInt(houseid, 7)
		net.WriteUInt(purchasePrice:GetValue(), 32)
		net.WriteUInt(rentalPrice:GetValue(), 32)
		net.WriteUInt(selectedRentalMode, 3)
		net.WriteString(TextEntryTitle:GetValue())
		net.WriteTable(housedata.boxes)
		net.WriteTable(housedata.panelpos)
		net.WriteTable(housedata.panelangle)
		net.WriteVector(housedata.textpos)
		net.WriteAngle(housedata.textangle)
		net.WriteVector(housedata.bellpos)
		net.WriteVector(housedata.camerapos)
		net.WriteAngle(housedata.cameraangle)
		net.SendToServer()

		if IsValid(panelptr) then
			panelptr:Close()
		end
	end
end


function ghomes.deletehouse(houseid, panelptr)
	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(500, 250)
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

	local color42 = Color(240, 240, 240)


	local cachedtext = WordWrap(Format("Are you sure you want to delete the property : [%s] ?\nAll the existing owner will NOT get refunded\nALSO BE SURE NO ONE ELSE IS USING ANY GHOMES PANEL WHILE YOU'RE GOING TO DELETE THE HOME", ghomes.list[houseid].name),40)
	DermaPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color2)
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, color42)
		draw.DrawText(cachedtext, "GuiSentData1", 25, 20, color2, TEXT_ALIGN_LEFT)
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

	local DermaButtonSend = vgui.Create("DButton", DermaPanel)
	DermaButtonSend:SetText("")
	DermaButtonSend:SetSize(DermaPanel:GetWide(), 40)
	DermaButtonSend:SetPos(0, DermaPanel:GetTall() - 40)
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

	DermaButtonSend.DoClick = function()
		DermaPanel.goup = true
		DermaPanel.movetime = CurTime()
		DermaPanel.movey = select(2, DermaPanel:GetPos())
		net.Start("ghomes_delete_home")
		net.WriteUInt(houseid, 7)
		net.SendToServer()

		if IsValid(panelptr) then
			panelptr:Close()
		end
	end
end