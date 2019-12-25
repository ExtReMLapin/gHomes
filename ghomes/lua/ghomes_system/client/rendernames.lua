include("3d2dvgui.lua")
-- should give 20% perf boost
local surface = surface
local LocalPlayer = LocalPlayer
local net = net
local draw = draw
local util = util
local util_PixelVisible = util.PixelVisible

surface.CreateFont("DrawHouseName", {
	font = "Roboto Th", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 128,
	weight = 10,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("DrawHouseNameSmall", {
	font = "Roboto Th", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 64,
	weight = 10,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("DrawHouseNameSmall48", {
	font = "Roboto Th", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 48,
	weight = 10,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("DrawHouseNameSmall32", {
	font = "Roboto Lt", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 48,
	weight = 10,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("DrawHouseNameSmall24", {
	font = "Roboto Lt", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 32,
	weight = 10,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("DrawHouseNameSmall24Bold", {
	font = "Roboto Bk", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 27,
	weight = 0,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("DrawHouseNameSmall12", {
	font = "Roboto Lt", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 24,
	weight = 10,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("DrawHouseNameSmall5", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 20,
	weight = 10,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

local card = Material("houses/credit-card.png")
local letter = Material("houses/letter.png")
local doorbell = Material("houses/doorbell.png")
local refund = Material("houses/refund.png")
local handshake = Material("houses/handshake.png")
local delete = Material("houses/delete.png")
local gear = Material("houses/gear.png")


local textMaxDist = 1000 * 1000
local textFadeOutDist = 600 * 600

if ghomes.enabledhousenames then
	hook.Add("PostDrawOpaqueRenderables", "housesnamerender3d", function()
		if not (#ghomes.list > 0) then return end

		surface.SetFont("DrawHouseName")

		for k, v in ipairs(ghomes.list) do
			if not v.textpos or v.beingedited == true then break end
			local dist = LocalPlayer():EyePos():DistToSqr(v.textpos)
			if v.previewing then dist = 0 end
			if dist > textMaxDist then continue end
			local color = Color(255, 255, 255, math.Min(180, math.Remap(dist, textFadeOutDist, textMaxDist, 180, 0)))
			local colordark = Color(0, 0, 0, color.a)
			cam.Start3D2D(v.textpos, v.textangle, 0.1)
			local text = v.name
			local text2 = ""
			local text3 = ""
			local height = 0

			if v.isrented then
				text2 = v.ownername
				height = 250
			else
				if v.buyablemode > 2 then
					if (ghomes.maxdaysrent > 1) then
						text2 = Format(ghomes.sperday, ghomes.wrapper.formatMoney(v.rentprice))
					else
						text2 = Format(ghomes.sperhour, ghomes.wrapper.formatMoney(math.Round(v.rentprice / 24, 2)))
					end
					height = 250
				else
					text2 = Format("%s", ghomes.wrapper.formatMoney(v.permaprice))

					if v.buyablemode == 1 then
						text3 = Format(ghomes.oronlysperday, ghomes.wrapper.formatMoney(v.rentprice))
						height = 300
					else
						height = 250
					end
				end
			end

			surface.SetFont("DrawHouseName")
			local width = math.Max(surface.GetTextSize(text), surface.GetTextSize(text2))
			surface.SetFont("DrawHouseNameSmall")
			width = math.Max(width, surface.GetTextSize(text3))
			draw.RoundedBox(16, 0, 0, width + 50, height, colordark)
			draw.SimpleText(text, "DrawHouseName", 25, 0, color, TEXT_ALIGN_LEFT)
			draw.SimpleText(text2, "DrawHouseName", 25, 100, color, TEXT_ALIGN_LEFT)

			if (v.isrented == false and v.buyablemode == 1) then
				draw.SimpleText(text3, "DrawHouseNameSmall", 25, 220, color, TEXT_ALIGN_LEFT)
			end

			cam.End3D2D()
		end
	end)
else
	hook.Remove("PostDrawOpaqueRenderables", "housesnamerender3d")
end
local function unittometter(unit)
	return math.Remap(unit, 0, 96, 0, 1.73736)
end





hook.Add("UpdatedHouseList", "CreatePanel", function(id)
	local house = ghomes.list[id]

	-- prevent from recreating multiple panel
	house.panelsdetectors = {}
	local isFriend = table.HasValue(house.friends, LocalPlayer():SteamID())
	local isOwner = house.owner == LocalPlayer()

	for panelID in pairs(house.panelpos) do
		local nbuttons = 0
		house.panelsdetectors[panelID] = house.panelsdetectors[panelID] or {}
		house.panels[panelID] = vgui.Create("DPanel")
		local curDerma = house.panels[panelID]

		curDerma:SetPaintedManually(true) -- important (very)
		curDerma:ParentToHUD() -- DO NOT FUCKING TOUCH THIS

		if (ghomes.emulate2Dmode == true) then
			curDerma.alpha = 255
			curDerma.white = color_white
			curDerma.black = Color(0,0,0)
		end
		curDerma:SetPos(0, 0)
		curDerma:SetSize(450, 380)

		curDerma.OnRemove = function(pnl)
			local parent = pnl:GetParent()
			if (parent:GetClassName() == "CGModBase") then return end

			timer.Simple(0, function() -- it's not removed yet so we replace it on the next frame
				local newPanel = ghomes.list[id].panels[panelID]
				if (IsValid(newPanel) and newPanel:IsValid()) then
					newPanel:SetParent(parent)
					parent.EmulatedPanel = newPanel
					newPanel:SetPaintedManually(false)
					newPanel:SetPos(1,25)
				else
					parent:Remove()
				end
			end)
		end


		curDerma.Paint = function(pnl, w, h)
			local color_black = Color(0, 0, 0, curDerma.alpha)
			draw.RoundedBoxEx(12, 0, 0, w, 48, Color(50, 152, 255, curDerma.alpha), true, true, false, false)
			draw.RoundedBoxEx(12, 0, 48, w, 332, curDerma.white, false, false, true, true)
			local status = ""

			if not house.isrented then
				status = ghomes.vacant2
			else
				if house.ispermarented then
					status = ghomes.owned2
				else
					status = ghomes.rented2
				end
			end

			draw.SimpleText(house.name .. status, "DrawHouseNameSmall48", w / 2, 0, curDerma.white, TEXT_ALIGN_CENTER)

			if not house.isrented then
				local t_color = Color(40, 40, 40, curDerma.alpha)
				local m_color = Color(230, 230, 230, curDerma.alpha)
				local x = house.boxes[2].x - house.boxes[1].x
				local y = house.boxes[2].y - house.boxes[1].y
				local z = house.boxes[2].z - house.boxes[1].z

				if house.buyablemode == 1 then
					draw.RoundedBox(8, 25, 125, 400, 100, m_color)
					draw.SimpleText(Format(ghomes.purchaseprice2, ghomes.wrapper.formatMoney(house.permaprice)), "DrawHouseNameSmall24", 35, 130, t_color, TEXT_ALIGN_LEFT)
					draw.SimpleText(Format(ghomes.dailypricerental, ghomes.wrapper.formatMoney(house.rentprice)), "DrawHouseNameSmall24", 35, 160, t_color, TEXT_ALIGN_LEFT)
					draw.SimpleText(Format(ghomes.numberofdoors, house.ndoors), "DrawHouseNameSmall24", 35, 190, t_color, TEXT_ALIGN_LEFT)
					draw.RoundedBox(8, 25, 245, 200, 105, m_color)
					draw.SimpleText(Format(ghomes.heightm, unittometter(z)), "DrawHouseNameSmall24", 35, 250, t_color, TEXT_ALIGN_LEFT)
					draw.SimpleText(Format(ghomes.lengthm, unittometter(x)), "DrawHouseNameSmall24", 35, 280, t_color, TEXT_ALIGN_LEFT)
					draw.SimpleText(Format(ghomes.widthm, unittometter(y)), "DrawHouseNameSmall24", 35, 310, t_color, TEXT_ALIGN_LEFT)
				else
					draw.RoundedBox(8, 25, 125, 400, 70, m_color)

					if house.buyablemode == 2 then
						draw.SimpleText(Format(ghomes.purchaseprice2, ghomes.wrapper.formatMoney(house.permaprice)), "DrawHouseNameSmall24", 35, 130, t_color, TEXT_ALIGN_LEFT)
					else
						draw.SimpleText(Format(ghomes.dailypricerental, ghomes.wrapper.formatMoney(house.rentprice)), "DrawHouseNameSmall24", 35, 130, t_color, TEXT_ALIGN_LEFT)
					end

					draw.SimpleText(Format(ghomes.numberofdoors, house.ndoors), "DrawHouseNameSmall24", 35, 160, t_color, TEXT_ALIGN_LEFT)
					draw.RoundedBox(8, 25, 215, 200, 100, m_color)
					draw.SimpleText(Format(ghomes.heightm, unittometter(z)), "DrawHouseNameSmall24", 35, 220, t_color, TEXT_ALIGN_LEFT)
					draw.SimpleText(Format(ghomes.lengthm, unittometter(x)), "DrawHouseNameSmall24", 35, 250, t_color, TEXT_ALIGN_LEFT)
					draw.SimpleText(Format(ghomes.widthm, unittometter(y)), "DrawHouseNameSmall24", 35, 280, t_color, TEXT_ALIGN_LEFT)
				end
			else
				if not house.ispermarented then
					draw.RoundedBoxEx(12, 0, h - 25, w, 25, Color(15, 15, 15, curDerma.alpha - 150), false, false, true, true)
					local time = house.selltime - os.time()
					local text
					local formated

					if time > (3600 * 24) then
						formated = time / (3600 * 24)
						text = Format("%i %s%s", formated, ghomes.unitday, formated >= 2 and "s" or "")
					elseif time > 3600 then
						formated = time / 3600
						text = Format("%i %s%s", formated, ghomes.unithour, formated >= 2 and "s" or "")
					elseif time > 60 then
						formated = time / 60
						text = Format("%i %s%s", formated, ghomes.unitminute, formated >= 2 and "s" or "")
					else
						formated = time
						text = Format("%i %s%s", formated, ghomes.unitsecond, formated >= 2 and "s" or "")
					end

					if time >= 0 then
						draw.SimpleText(Format(ghomes.leaseexpiresin, text), "DrawHouseNameSmall5", w / 2, h - 22, color_black, TEXT_ALIGN_CENTER)
					else
						draw.SimpleText(Format(ghomes.leasehasexpired, text), "DrawHouseNameSmall5", w / 2, h - 22, color_black, TEXT_ALIGN_CENTER)
					end
				end
			end
		end

		if not house.isrented then
			local buttonBuy = vgui.Create("DButton", curDerma)
			nbuttons = nbuttons + 1
			buttonBuy:SetText("")
			buttonBuy:SetPos(25 + 425 * (math.ceil(nbuttons / 5) - 1), 60 * math.max(1, nbuttons % 6))
			buttonBuy:SetSize(400, 48)

			buttonBuy.DoClick = function()
				ghomes.confirmpurchase(id)
			end

			buttonBuy.Paint = function(pnl, w, h)
				local m_color = Color(230, 230, 230, curDerma.alpha)

				if (pnl.Hovered) then
					m_color = Color(200, 200, 200, curDerma.alpha)
				end

				draw.RoundedBox(8, 0, 0, w, h, m_color)
				surface.SetDrawColor(curDerma.white)
				surface.SetMaterial(card)
				surface.DrawTexturedRect(0, 0, 48, 48)
				local text = ghomes.purchaserent

				if (house.buyablemode == 2) then
					text = ghomes.purchase
				elseif (house.buyablemode == 3) then
					text = ghomes.rent
				end

				draw.SimpleText(text, "DrawHouseNameSmall32", 55, 0, Color(40, 40, 40, curDerma.alpha), TEXT_ALIGN_LEFT)
			end
		else
			local buttonRing = vgui.Create("DButton", curDerma)
			nbuttons = nbuttons + 1
			buttonRing:SetText("")
			buttonRing:SetPos(25 + 425 * (math.ceil(nbuttons / 5) - 1), 60 * math.max(1, nbuttons % 6))
			buttonRing:SetSize(400, 48)

			buttonRing.DoClick = function()
				net.Start("ghomes_command")
				net.WriteUInt(id, 7)
				net.WriteUInt(1, 4)
				net.SendToServer()
			end

			buttonRing.Paint = function(pnl, w, h)
				local m_color = Color(230, 230, 230, curDerma.alpha)

				if (pnl.Hovered) then
					m_color = Color(200, 200, 200, curDerma.alpha)
				end

				draw.RoundedBox(8, 0, 0, w, h, m_color)
				surface.SetDrawColor(curDerma.white)
				surface.SetMaterial(doorbell)
				surface.DrawTexturedRect(0, 0, 48, 48)
				draw.SimpleText(ghomes.ringthebell, "DrawHouseNameSmall32", 55, 0, Color(40, 40, 40, curDerma.alpha), TEXT_ALIGN_LEFT)
			end

			if isOwner or isFriend then
				local buttonReadMails = vgui.Create("DButton", curDerma)
				nbuttons = nbuttons + 1
				buttonReadMails:SetText("")
				buttonReadMails:SetPos(25 + 425 * (math.ceil(nbuttons / 5) - 1), 60 * math.max(1, nbuttons % 6))
				buttonReadMails:SetSize(400, 48)

				buttonReadMails.DoClick = function()
					if LocalPlayer().nmails == 0 then return end
					net.Start("ghomes_requestlastmail")
					net.SendToServer()
				end

				buttonReadMails.Paint = function(pnl, w, h)
					local m_color = Color(230, 230, 230, curDerma.alpha)

					if (pnl.Hovered) then
						m_color = Color(200, 200, 200, curDerma.alpha)
					end

					draw.RoundedBox(8, 0, 0, w, h, m_color)
					surface.SetDrawColor(curDerma.white)
					surface.SetMaterial(letter)
					surface.DrawTexturedRect(0, 0, 48, 48)
					draw.SimpleText(ghomes.readmail, "DrawHouseNameSmall32", 55, 0, Color(40, 40, 40, curDerma.alpha), TEXT_ALIGN_LEFT)
					draw.SimpleText(tostring(LocalPlayer().nmails), "DrawHouseNameSmall24Bold", 23, 10.5, Color(40, 40, 40, curDerma.alpha), TEXT_ALIGN_CENTER)
				end
			else
				local buttonLeaveAMessage = vgui.Create("DButton", curDerma)
				nbuttons = nbuttons + 1
				buttonLeaveAMessage:SetText("")
				buttonLeaveAMessage:SetPos(25 + 425 * (math.ceil(nbuttons/5)-1), 60 * math.max(1, nbuttons%6))
				buttonLeaveAMessage:SetSize(400, 48)

				buttonLeaveAMessage.DoClick = function()
					ghomes.mails.mailwrite(id)
				end

				buttonLeaveAMessage.Paint = function(pnl, w, h)
					local m_color = Color(230, 230, 230, curDerma.alpha)

					if (pnl.Hovered) then
						m_color = Color(200, 200, 200, curDerma.alpha)
					end

					draw.RoundedBox(8, 0, 0, w, h, m_color)
					surface.SetDrawColor(curDerma.white)
					surface.SetMaterial(letter)
					surface.DrawTexturedRect(0, 0, 48, 48)
					draw.SimpleText(ghomes.leaveamessage, "DrawHouseNameSmall32", 55, 0, Color(40, 40, 40, curDerma.alpha), TEXT_ALIGN_LEFT)
				end
			end

			if isOwner then
				if not house.ispermarented then
					local buttonReNew = vgui.Create("DButton", curDerma)
					nbuttons = nbuttons + 1
					buttonReNew:SetText("")
					buttonReNew:SetPos(25 + 425 * (math.ceil(nbuttons / 5) - 1), 60 * math.max(1, nbuttons % 6))
					buttonReNew:SetSize(400, 48)

					buttonReNew.DoClick = function()
						ghomes.renewlease(id)
					end

					buttonReNew.Paint = function(pnl, w, h)
						local m_color = Color(230, 230, 230, curDerma.alpha)

						if (pnl.Hovered) then
							m_color = Color(200, 200, 200, curDerma.alpha)
						end

						draw.RoundedBox(8, 0, 0, w, h, m_color)
						surface.SetDrawColor(curDerma.white)
						surface.SetMaterial(refund)
						surface.DrawTexturedRect(0, 0, 48, 48)
						draw.SimpleText(ghomes.renewthelease, "DrawHouseNameSmall32", 55, 0, Color(40, 40, 40, curDerma.alpha), TEXT_ALIGN_LEFT)
					end
				end

				local buttonCoOwners = vgui.Create("DButton", curDerma)
				nbuttons = nbuttons + 1
				buttonCoOwners:SetText("")
				buttonCoOwners:SetPos(25 + 425 * (math.ceil(nbuttons / 5) - 1), 60 * math.max(1, nbuttons % 6))
				buttonCoOwners:SetSize(400, 48)

				buttonCoOwners.DoClick = function()
					ghomes.buddiespanel(id)
				end

				buttonCoOwners.Paint = function(pnl, w, h)
					local m_color = Color(230, 230, 230, curDerma.alpha)

					if (pnl.Hovered) then
						m_color = Color(200, 200, 200, curDerma.alpha)
					end

					draw.RoundedBox(8, 0, 0, w, h, m_color)
					surface.SetDrawColor(curDerma.white)
					surface.SetMaterial(handshake)
					surface.DrawTexturedRect(2, 0, 48, 48)
					draw.SimpleText(ghomes.coowners, "DrawHouseNameSmall32", 55, 0, Color(40, 40, 40, curDerma.alpha), TEXT_ALIGN_LEFT)
				end

				local buttonConfirmSell = vgui.Create("DButton", curDerma)
				nbuttons = nbuttons + 1
				buttonConfirmSell:SetText("")
				buttonConfirmSell:SetPos(25 + 425 * (math.ceil(nbuttons / 5) - 1), 60 * math.max(1, nbuttons % 6))
				if ghomes.dlcs.dlc1 and not house.ispermarented then
					buttonConfirmSell:SetSize(340, 48)
				else
					buttonConfirmSell:SetSize(400, 48)
				end
				buttonConfirmSell.DoClick = function()
					ghomes.confirmsell(id)
				end

				local selltext
				local png

				if house.ispermarented then
					selltext = ghomes.sellthehome
					png = refund
				else
					selltext = ghomes.breakthelease
					png = delete
				end

				buttonConfirmSell.Paint = function(pnl, w, h)
					local m_color = Color(230, 230, 230, curDerma.alpha)

					if (pnl.Hovered) then
						m_color = Color(200, 200, 200, curDerma.alpha)
					end

					draw.RoundedBox(8, 0, 0, w, h, m_color)
					surface.SetDrawColor(curDerma.white)
					surface.SetMaterial(png)
					surface.DrawTexturedRect(0, 0, 48, 48)
					draw.SimpleText(selltext, "DrawHouseNameSmall32", 55, 0, Color(40, 40, 40, curDerma.alpha), TEXT_ALIGN_LEFT)
				end
				if ghomes.dlcs.dlc1 then
					local buttonSettings = vgui.Create("DButton", curDerma)
					if house.ispermarented then
						nbuttons = nbuttons + 1
					end

					buttonSettings:SetText("")
					if not house.ispermarented then
						buttonSettings:SetPos(377 + 425 * (math.ceil(nbuttons / 5) - 1), 60 * math.max(1, nbuttons % 6))
						buttonSettings:SetSize(48, 48)
					else
						buttonSettings:SetPos(25 + 425 * (math.ceil(nbuttons / 5) - 1), 60 * math.max(1, nbuttons % 6))
						buttonSettings:SetSize(400, 48)
					end

					buttonSettings.DoClick = function()
						--ghomes.dlcs.dlc1.settingshouse(id, NULL) -- need to request the data first
						net.Start("ghomes_dlc1_use_suitcase3")
						net.WriteUInt(id, 7)
						net.SendToServer()
					end
					if not house.ispermarented then
						buttonSettings.Paint = function(pnl, w, h)
							local m_color = Color(230, 230, 230, curDerma.alpha)

							if (pnl.Hovered) then
								m_color = Color(200, 200, 200, curDerma.alpha)
							end

							draw.RoundedBox(8, 0, 0, w, h, m_color)
							surface.SetDrawColor(curDerma.black)
							surface.SetMaterial(gear)
							surface.DrawTexturedRect(0, 0, 48, 48)
						end
					else
						buttonSettings.Paint = function(pnl, w, h)
							local m_color = Color(230, 230, 230, curDerma.alpha)

							if (pnl.Hovered) then
								m_color = Color(200, 200, 200, curDerma.alpha)
							end

							draw.RoundedBox(8, 0, 0, w, h, m_color)
							surface.SetDrawColor(curDerma.black)
							surface.SetMaterial(gear)
							surface.DrawTexturedRect(2, 0, 48, 48)
							draw.SimpleText(ghomes.settings, "DrawHouseNameSmall32", 55, 0, Color(40, 40, 40, curDerma.alpha), TEXT_ALIGN_LEFT)
						end

					end
				end
			end
		end

		house.panelsdetectors[panelID].visi1 = house.panelsdetectors[panelID].visi1 or util.GetPixelVisibleHandle()
		house.panelsdetectors[panelID].visi2 = house.panelsdetectors[panelID].visi2 or util.GetPixelVisibleHandle()
		house.panelsdetectors[panelID].visi3 = house.panelsdetectors[panelID].visi3 or util.GetPixelVisibleHandle()
		house.panelsdetectors[panelID].visi4 = house.panelsdetectors[panelID].visi4 or util.GetPixelVisibleHandle()
		house.panelsdetectors[panelID].visi5 = house.panelsdetectors[panelID].visi5 or util.GetPixelVisibleHandle()
	end
end)


local maxdist = 600 * 600
local fadeoutdist = 500 * 500
if not ghomes.emulate2Dmode then
	hook.Add("PostDrawTranslucentRenderables", "RenderPanelsHouse", function()
		local playerpos = Vector(LocalPlayer():GetPos().x, LocalPlayer():GetPos().y, 0)
		for k, v in ipairs(ghomes.list) do
			if v.beingedited == true then continue end
			for k2, v2 in pairs(v.panelpos) do
				if not v.panels[k2]:IsValid() then continue end

				-- new optimization code end
				local curdist = LocalPlayer():GetPos():DistToSqr(v.panelpos[k2]) -- not CURdistan, right

				if curdist > maxdist and v.previewing != true then
					v.panels[k2].shouldthink = false
					continue
				end

				local panelpos = Vector(v.panelpos[k2].x, v.panelpos[k2].y, 0)
				local ang = (playerpos - panelpos):Angle()
				ang:Normalize()
				ang = ang - v.panelangle[k2]
				ang:Normalize()

				if ang.y > 0 and v.previewing != true then
					v.panels[k2].shouldthink = false
					continue
				end

				local pos1 = v.panelpos[k2] -- top left
				local pos2 = v.panelpos[k2] + v.panelangle[k2]:Right() * 20 + v.panelangle[k2]:Forward() * 22.5 -- center of panel
				local pos3 = v.panelpos[k2] + v.panelangle[k2]:Right() * 40 -- bottom left
				local pos4 = v.panelpos[k2] + v.panelangle[k2]:Forward() * 45 -- top right
				local pos5 = v.panelpos[k2] + v.panelangle[k2]:Right() * 40 + v.panelangle[k2]:Forward() * 45 -- bottom right
				local score = 0
				score = score + util_PixelVisible(pos1, 9, v.panelsdetectors[k2].visi1)
				score = score + util_PixelVisible(pos2, 9, v.panelsdetectors[k2].visi2)
				score = score + util_PixelVisible(pos3, 9, v.panelsdetectors[k2].visi3)
				score = score + util_PixelVisible(pos4, 9, v.panelsdetectors[k2].visi4)
				score = score + util_PixelVisible(pos5, 9, v.panelsdetectors[k2].visi5)


				if score == 0 and v.previewing != true then
					v.panels[k2].shouldthink = false
					continue
				end

				v.panels[k2].shouldthink = true
				local tmpalpha = math.min(255, math.Remap(curdist, fadeoutdist, maxdist, 255, 0))

				if v.previewing == true then
					tmpalpha = 255
				end
				if (v.panels[k2].alpha != tmpalpha) then
					v.panels[k2].alpha = tmpalpha
					v.panels[k2].white = Color(255, 255, 255, v.panels[k2].alpha)
					v.panels[k2].black = Color(0, 0, 0, v.panels[k2].alpha)
				end
				vgui.Start3D2DLapin(v.panelpos[k2], v.panelangle[k2], 0.1)
					v.panels[k2]:Paint3D2DLapin()
				vgui.End3D2DLapin()
			end
		end
	end)
else
	hook.Remove("PostDrawTranslucentRenderables", "RenderPanelsHouse")
end

for k, v in ipairs(ghomes.list) do
	hook.Run("UpdatedHouseList", k)
end

local color2 = Color(110, 110, 110, 255)


net.Receive("ghomes_door_f2",function()
	local houseID = net.ReadUInt(7)
	local foundHouse = ghomes.list[houseID]
	if table.IsEmpty(foundHouse.panels) then return end
	local panel = foundHouse.panels[1]


	local DermaContainer = vgui.Create("DFrame",nil, "Ghomes Emulation")
	DermaContainer:SetSize(panel:GetWide() + 2, panel:GetTall() + 25)
	panel:SetParent(DermaContainer)
	panel:SetPaintedManually(false)
	panel:SetPos(1,25)

	DermaContainer:SetDraggable( true )
	DermaContainer:MakePopup()
	DermaContainer:Center()
	DermaContainer.EmulatedPanel = panel

	DermaContainer:SetTitle("")
	DermaContainer.lblTitle.Paint = function() end
	DermaContainer.Paint = function(pnl, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color2)
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, color_white)
		draw.SimpleText("gHomes Emulated 2D Panel", "GuiSentData1", 5, 0, pnl.EmulatedPanel.black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	DermaContainer.btnClose.Paint = function()
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawLine(10, 10, 20, 20)
		surface.DrawLine(10, 20, 20, 10)
	end

	DermaContainer.btnClose.DoClick = function(button)
		DermaContainer:Close()
	end

	DermaContainer.btnMaxim.Paint = function() end
	DermaContainer.btnMinim.Paint = function() end


	DermaContainer.OnClose = function(pnl)
		pnl.EmulatedPanel:ParentToHUD()
		pnl.EmulatedPanel:SetPaintedManually(true)
		pnl.EmulatedPanel:SetPos(0,0)
	end

end)

