include("shared.lua")

surface.CreateFont("DrawBoxGhomes", {
	font = "Roboto",
	size = 28,
	italic = false
})

surface.CreateFont("DrawBoxGhomes42", {
	font = "Roboto",
	size = 26.5,
	italic = false
})

surface.CreateFont("DrawBoxGhomes2", {
	font = "Roboto",
	size = 20,
	italic = false
})

surface.CreateFont("DrawBoxGhomes3", {
	font = "Roboto",
	size = 30,
	italic = false
})
ENT.inited = false
ENT.lastMove = CurTime()

ENT.inzone = false;
ENT.lastframeinzone = false
ENT.dist = 120
ENT.battery = "Battery : 100%"

local locked = Material("houses/locked.png")


-- from zero to 1
function ENT:Open()
	self:EmitSound("buttons/button24.wav",70,100,1,CHAN_AUTO)
	self:EmitSound("ambient/machines/squeak_2.wav",120,100,1,CHAN_AUTO)
	self:EmitSound("ghome/open.wav",120,100,1,CHAN_AUTO)
end

function ENT:Close()
	self:EmitSound("ambient/machines/squeak_2.wav",120,100,1,CHAN_AUTO)
	self:EmitSound("ghome/close.wav",120,100,1,CHAN_AUTO)
end

ENT.ownername = ""

local dark = Color(20, 20, 20)

function ENT:Draw()
	if not self.inited then self:Initialize() end
	if self:GetHouse() > #ghomes.list then return end
	local house = ghomes.list[self:GetHouse()]
	local selected = self:GetHouse() > 0

	self:DrawModel()




	if (self:GetSequence() == 1) then
		do
			local tbl = self:GetAttachment(1)
			tbl.Ang:RotateAroundAxis(tbl.Ang:Up() ,90)
			tbl.Ang:RotateAroundAxis(tbl.Ang:Forward() ,90)
			local campos = tbl.Ang:Up()
			campos:Mul(0.2)
			campos:Add(tbl.Pos)
			cam.Start3D2D(campos, tbl.Ang, 0.07)
				local alpha = 255
				surface.SetDrawColor(20, 20, 20, alpha / 1.03)
				local text = Color(50, 205, 50, alpha)
				surface.DrawRect(0, 0, 585, 340)

				local i = 0
				local size = 1
				while (i < 340) do
					surface.SetDrawColor(0,27,0)
					surface.DrawRect(0,i , 585,size)
					i = i + size * 2
				end


				if selected then
					if (math.floor(CurTime() % 2) == 0) then
						draw.SimpleText(Format("%s@%s:~$", self.ownername, house.name), "DrawBoxGhomes3",5,10, text ) -- hackerman
					else
						draw.SimpleText(Format("%s@%s:~$█", self.ownername, house.name), "DrawBoxGhomes3",5,10, text )
					end
				else
					if (math.floor(CurTime() % 2) == 0) then
						draw.SimpleText("Login : ", "DrawBoxGhomes3",5,10, text )
					else
						draw.SimpleText("Login : █", "DrawBoxGhomes3",5,10, text )
					end
				end
			cam.End3D2D()
		end



		do
			local tbl = self:GetAttachment(2)
			tbl.Ang:RotateAroundAxis(tbl.Ang:Up() ,90)
			tbl.Ang:RotateAroundAxis(tbl.Ang:Forward() ,90)
			local campos = tbl.Ang:Up()
			campos:Mul(0.2)
			campos:Add(tbl.Pos)
			cam.Start3D2D(campos, tbl.Ang, 0.05)
				local alpha = 255
				surface.SetDrawColor(20, 20, 20, alpha / 1.03)
				local text = Color(50, 205, 50, alpha)
				surface.DrawRect(0, 0, 215, 180)

				local i = 0
				local size = 1
				while (i < 180) do
					surface.SetDrawColor(0,27,0)
					surface.DrawRect(0,i , 215,size)
					i = i + size * 2
				end


				if selected then
					local color = Color(20 + 0.3 * self:GetPercentage(), 20 + 1.85 * self:GetPercentage(), 20 + 0.3 * self:GetPercentage())					
					surface.SetDrawColor(text)
					surface.DrawRect(10,20,190,40)
					surface.SetDrawColor(dark)
					surface.DrawRect(12,21,186,38)
					surface.SetDrawColor(color)
					surface.DrawRect(12, 21, 1.86 * self:GetPercentage(), 38)
					draw.SimpleText(self.battery, "DrawBoxGhomes2",107,72, text, TEXT_ALIGN_CENTER )

					draw.SimpleText("STATUS : UNLOCKED", "DrawBoxGhomes42",107,142, text, TEXT_ALIGN_CENTER )

				elseif (math.floor(CurTime() % 2) == 0) then
					surface.SetDrawColor(text)
					surface.SetMaterial(locked)
					surface.DrawTexturedRect(62 , 25, 90, 90)
					draw.SimpleText("STATUS : LOCKED", "DrawBoxGhomes3",107,142, text, TEXT_ALIGN_CENTER )
				end
			cam.End3D2D()
		end


	end


end

function ENT:Initialize()

	local selected = self:GetHouse() > 0
	self.battery = Format("Battery : %i%%", self:GetPercentage())
	self:SetNW2VarProxy( "User", function (ent, name, old, new) -- the DataTable one is bugged, i have to use NW2 vars
		if new == LocalPlayer() then
			ghomes.dlcs.dlc1.selecthouse(self)
		end
	end )

	self:SetNW2VarProxy( "Opened", function (ent, name, old, new)
		if new == false then
			self:Close()
		else
			self:Open()
		end
	end )

	self.ownername = selected and ghomes.list[self:GetHouse()].ownername or ""
	self.inited = true
end


function ENT:Think()
	local selected = self:GetHouse() > 0
	self.battery = Format("Battery : %i%%", self:GetPercentage())
	if selected and self:GetHouse() <= #ghomes.list  and ghomes.list[self:GetHouse()].isrented then
		self.ownername = ghomes.list[self:GetHouse()].ownername
	else
		self.ownername = "Loading"
	end

	self:SetNextClientThink(CurTime() + 1)
	return true
end