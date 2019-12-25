ghomes.wrapper = ghomes.wrapper or {}

local function getCurGamemode()
	if DarkRP then return "darkrp" end
	if nut then return "nutscript" end
	if ix then return "ix" end

	return "default"

end

function ghomes.SetupWrapper()
	local gm = "ghomes_system/sh_compatibility/" .. getCurGamemode()
	ghomes.wrapper = include(gm .. ".lua")

	ghomes.wrapper.init()
end
