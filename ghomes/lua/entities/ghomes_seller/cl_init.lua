include("shared.lua")

surface.CreateFont("GuiSentData4", {
	font = "Roboto",
	size = 65,
	italic = false
})

local color_dark = Color(25, 25, 25, 205)

function ENT:Draw()
	self:DrawModel()
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	Ang:RotateAroundAxis(Ang:Right(), -90)
	local plyxy = LocalPlayer():GetPos()
	local plyx = plyxy.x
	local plyy = plyxy.y
	local npcxy = self:GetPos()
	local npcx = npcxy.x
	local npcy = npcxy.y
	local cursorang = math.fmod(math.atan2(plyy - npcy, plyx - npcx), math.pi * 2) --whoever set the angle of the ply -180 to set the text angle is a fucking idiot
	local cursorangd = Angle(0, math.deg(cursorang), 0)
	cursorangd:RotateAroundAxis(cursorangd:Forward(), 90)
	cursorangd:RotateAroundAxis(cursorangd:Right(), -90)
	local angRight = Ang:Right()
	angRight:Mul(-80)
	Pos:Add(angRight)
	cam.Start3D2D(Pos, cursorangd, 0.1)
	draw.RoundedBox(8, -115, -2, 230, 78, color_dark)
	draw.DrawText("gHomes", "GuiSentData4", 2, 0, color_white, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end