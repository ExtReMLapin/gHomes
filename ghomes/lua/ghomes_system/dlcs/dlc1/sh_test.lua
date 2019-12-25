ghomes.dlcs.dlc1.ent_save_list = {"money_printer",}

--[[
	Here is what you need to know, most of the darkrp entities have the DT Var : owning_ent which defines who is the owner
	It allows me to detect if an entitiy should be removed when the player leaves to be later restored (removed so it doesn't get duplicated when he joins back)
	If the DT var doesn't exist, it's not going to do any check and remove it anyway, this is why you need to be careful when adding entities classes here
	It's a case-sensitive field btw, no things like money_*
--]]