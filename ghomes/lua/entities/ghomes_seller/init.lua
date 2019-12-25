AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- took from https://gmod.facepunch.com/f/gmoddev/nskm/NPC-Shop-Tutorial/1/
function ENT:Initialize()
	self:SetModel("models/breen.mdl")
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(CAP_ANIMATEDFACE)
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetMaxYawSpeed(90)
end

function ENT:AcceptInput(Name, Activator, ply)
	if Name == "Use" and ply:IsPlayer() then
		if not ply.lastghomesnpccall then
			ply.lastghomesnpccall = CurTime()
		elseif CurTime() - ply.lastghomesnpccall < 1 then
			return
		else
			ply.lastghomesnpccall = CurTime()
		end

		if #ghomes.list ~= 0 then
			net.Start("ghomes_npc_use")
			net.Send(ply)
		else
			ply:ChatPrint("I don't sell any home right now, tell someone in the staff to setup homes using the right tool !")
		end
	end
end

local a180 = Angle(0,180,0)
local posOffset = Vector(0,0,50.42)
function ENT:SpawnFunction( ply, tr, ClassName )
	if ( not tr.Hit ) then return end
	local ent = ents.Create( ClassName )
	local SpawnPos = tr.HitPos
	SpawnPos:Add(posOffset)
	local angle = Angle(0, ply:GetAngles().y ,0)
	angle:Sub(a180)
	ent:SetPos( SpawnPos )
	ent:SetAngles(angle)
	ent:Spawn()
	ent:Activate()
	ghomes.registernpc(ent)
	return ent
end

function ENT:OnRemove()
	if self.npcid == nil then return end
	local cpint = self.npcid -- copy integer
	timer.Simple(3,function() -- hack, cuz it get triggered ont the server exit
		ghomes.npconremove(cpint)
	end)
end