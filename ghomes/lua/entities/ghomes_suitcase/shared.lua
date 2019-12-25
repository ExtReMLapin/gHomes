ENT.Type = "anim";
ENT.Base = "base_entity"
ENT.PrintName = "gHomes Commander Case"
ENT.Author = "Lapin"
ENT.Category = "gHomes"
ENT.Spawnable = true
ENT.Contact = "https://www.gmodstore.com/dashboard/support/tickets/create/4858"

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "House" )
	self:NetworkVar( "Int", 1, "Percentage")
end;