AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("ghomes_dlc1_use_suitcase")

function ENT:Initialize()
	self:SetModel("models/ghomes/ghomes_case.mdl")
	-- Physics stuff
	--Give it some kind of model
	--Set physics box
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetHouse(0)
	self:SetPercentage(100)
	self:SetNW2Entity("User", NULL) -- used for need hooks, dt hooks are broken in this gmod version
	self:SetNW2Bool("Opened", false)
end

function ENT:Think()
	self:SetPercentage(self:GetPercentage() - 1)
	self:NextThink(CurTime() + 6)

	if self:GetPercentage() <= 0 then
		util.BlastDamage(self, self, self:GetPos(), 2, 0)
		self:Remove()
	end

	return true
end

local ang180 = Angle(0, 180, 0)
local posoffset = Vector(0, 0, 10)
function ENT:SpawnFunction(ply, tr, ClassName)
	if (not tr.Hit) then
		return
	end

	local ent = ents.Create(ClassName)
	tr.HitPos:Add(posoffset)
	local angle = Angle(0, ply:GetAngles().y, 0) Angle(0, 180, 0)
	angle:Sub(ang180)
	ent:SetPos(tr.HitPos)
	ent:SetAngles(angle)
	ent:Spawn()
	ent:Activate()

	return ent
end

ENT.opened = false

function ENT:Use(activator, caller)
	if not IsValid(caller) or not caller:IsPlayer() then
		return
	end

	if not self.opened then
		self:SetNW2Bool("Opened", true)
		self.opened = true
		self:SetSequence(1)
		return
	end

	if self:GetNW2Entity("User") == NULL then
		local c = 0

		for k, v in ipairs(ghomes.list) do
			if v.owner == caller then
				c = c + 1
			end
		end

		if c > 0 then
			self:SetNW2Entity("User", caller)
		else
			caller:ChatPrint(ghomes.youdontownany)
		end
	elseif self:GetHouse() ~= 0 and ghomes.list[self:GetHouse()].owner == caller then
		local house = ghomes.list[self:GetHouse()]

		net.Start("ghomes_dlc1_use_suitcase")
		net.WriteUInt(self:GetHouse(), 7)
		net.WriteEntity(self)
		net.WriteBool(tobool(house.spawnHere))
		net.WriteBool(tobool(house.spawnHereFriends))
		net.WriteBool(tobool(house.saveEntities))
		net.WriteBool(tobool(house.alarmProtected))
		net.Send(caller)
	end
end

net.Receive("ghomes_dlc1_use_suitcase", function(len, ply)
	local _type = net.ReadBool()
	local ent = net.ReadEntity()

	if not IsValid(ent) or ent:GetClass() ~= "ghomes_suitcase" then
		return
	end

	-- silly cheater
	if _type == true then
		local id = net.ReadUInt(7)

		if id == 0 then
			ent:SetNW2Entity("User", NULL)

			return
		end

		if id <= #ghomes.list and ghomes.list[id].isrented and ghomes.list[id].owner == ply then
			ent:SetHouse(id)
		end
		-- else cheater
	elseif ply == ent:GetNW2Entity("User") then
		local house = ghomes.list[ent:GetHouse()]

		if house.owner ~= ply then
			return
		end

		ent:SetNW2Bool("Opened", false)
		ent:SetSequence(3)
		ent:SetNW2Entity("User", NULL)
		house.spawnHere = net.ReadBool()
		house.spawnHereFriends = net.ReadBool()
		house.saveEntities = net.ReadBool()
		local alarmrequest = net.ReadBool()

		if alarmrequest and not house.alarmProtected then
			if ply:getDarkRPVar("money") >= ghomes.alarmprice then
				ply:addMoney(-ghomes.alarmprice)
				house.alarmProtected = true
			end
		elseif not alarmrequest then
			house.alarmProtected = false
		end

		ghomes.savehouse(ent:GetHouse())
		ent.opened = false
		ent:SetHouse(0)
	else
		ply:ChatPrint("fuck off cheater")
	end
end)

local function handle_death_deco(ply)
	for k, v in pairs(ents.FindByClass("ghomes_suit")) do
		if v:GetUser() == ply then
			v:SetNW2Entity("User", NULL)

			return
		end
	end
end

hook.Add("PlayerDeath", "ghomes_suitcase", handle_death_deco)
hook.Add("PlayerDisconnected", "ghomes_suitcase", handle_death_deco)