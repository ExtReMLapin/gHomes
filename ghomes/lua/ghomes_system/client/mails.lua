ghomes.mails = {}
local color2 = Color(110, 110, 110, 255)
local color_grey = Color(127, 127, 127)

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

function ghomes.mails.mailshow(tblmail)
	if not tblmail or not tblmail.text then return end
	tblmail.text = string.gsub(tblmail.text, "\n", " ")
	tblmail.text = string.gsub(tblmail.text, "  ", " ") -- fuck double spaces
	tblmail.text = WordWrap(tblmail.text, 70)
	surface.SetFont("GuiSentData1")
	local w1, h1 = surface.GetTextSize(tblmail.text)

	if w1 > ScrW() or h1 > ScrH() then
		LocalPlayer():ChatPrint("The message is too big to be displayed on your monitor, so we're going to show it to you in the console.")
		MsgC(Color(50, 255, 50), "Author of the message : ")
		MsgC(color_white, tblmail.author .. '\n')
		MsgC(Color(50, 255, 50), "Message : \n")
		MsgC(color_white, tblmail.text .. '\n')

		return
	end

	w1 = math.Max(w1, 600)
	h1 = math.Max(h1, 240)
	--draw.DrawText
	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(w1 + 50, h1 + 100)
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
		draw.SimpleText(Format(ghomes.msgwroteby, tblmail.author), "GuiSentData1", 25, 20, color2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.DrawText(tblmail.text, "GuiSentData1", 25, 70, color_grey, TEXT_ALIGN_LEFT)
	end

	DermaPanel.btnClose.Paint = function(panel, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawLine(10, 10, 20, 20)
		surface.DrawLine(10, 20, 20, 10)
	end

	DermaPanel.btnClose.DoClick = function(button)
		DermaPanel.goup = true
		DermaPanel.movetime = CurTime()
		DermaPanel.movey = select(2, DermaPanel:GetPos())
	end

	DermaPanel.btnMaxim.Paint = function(panel, w, h) end
	DermaPanel.btnMinim.Paint = function(panel, w, h) end
end

local uploadicon = Material("houses/upload.png")

function ghomes.mails.mailwrite(houseid)
	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(1000, 520)
	DermaPanel:SetTitle("")
	DermaPanel:SetDraggable(false)
	DermaPanel:MakePopup()
	DermaPanel:Center()
	DermaPanel.lblTitle.Paint = function() end
	DermaPanel.goup = false
	DermaPanel.movetime = 0
	DermaPanel.movey = 0
	local steamid = ghomes.list[houseid].ownersteamid

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
		draw.SimpleText(ghomes.writingamsg, "GuiSentData1", 25, 20, color2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(ghomes.recipient, "GuiSentData1", 25, 430, color2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
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

	local DLabel = vgui.Create("DLabel", DermaPanel)
	DLabel:SetTextColor(Color(0, 0, 0))
	DLabel:SetPos(946, 440)
	DLabel:SetMouseInputEnabled(true)
	DLabel:SetKeyboardInputEnabled(true)
	DLabel:SetTall(70)
	DLabel:SetWide(100)
	local TextEntry = vgui.Create("DTextEntry", DermaPanel)
	TextEntry:SetPos(50, 70)
	TextEntry:SetWrap(true)
	TextEntry:SetSize(900, 360)
	TextEntry:SetMultiline(true)
	TextEntry:SetFont("GuiSentData1")
	TextEntry:SetText(ghomes.typemessagehere)
	DLabel:SetText("0/1023")
	TextEntry:SetUpdateOnType(true)
	TextEntry.m_bLoseFocusOnClickAway = false
	TextEntry:SetDrawBorder(false)
	TextEntry:SetPaintBackground(false)

	TextEntry.OnChange = function()
		if string.len(TextEntry:GetValue()) > 1023 then
			TextEntry:SetText(string.Left(TextEntry:GetValue(), 1023))
		end

		local text = TextEntry:GetValue()
		local textl = string.len(text)
		DLabel:SetText(textl .. "/1023")
	end

	local comboDest = vgui.Create("DComboBox", DermaPanel)
	comboDest:SetPos(130, 434)
	comboDest:SetSize(100, 20)
	comboDest:SetValue("Recipient")
	comboDest:AddChoice(ghomes.list[houseid].ownername)

	for k, v in pairs(ghomes.list[houseid].friendsname) do
		comboDest:AddChoice(v)
	end

	comboDest.OnSelect = function(panel, index, value)
		if index == 1 then
			steamid = ghomes.list[houseid].ownersteamid
		else
			steamid = ghomes.list[houseid].friends[index - 1]
		end
	end

	local DermaButtonSend = vgui.Create("DButton", DermaPanel)
	DermaButtonSend:SetText("")
	DermaButtonSend:SetSize(DermaPanel:GetWide(), 40)
	DermaButtonSend:SetPos(0, DermaPanel:GetTall() - 40)

	DermaButtonSend.DoClick = function()
		DermaPanel.goup = true
		DermaPanel.movetime = CurTime()
		DermaPanel.movey = select(2, DermaPanel:GetPos())
		net.Start("ghomes_writenote")
		net.WriteString(steamid)
		net.WriteString(string.Left(TextEntry:GetValue(), 1023))
		--net.WriteBool(false)
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
