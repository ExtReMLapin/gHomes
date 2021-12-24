ghomes = ghomes or {}
ghomes.list = ghomes.list or {}
ghomes.dlcs = {}
ghomes.debug = false -- enable or disable console messages, don't ask for support if you can't tell me how to reproduce a bug or if you don't have the debug message enabled
ghomes.rgb = Color(50, 255, 50)
ghomes.percentageOnSell = 0.9 -- 90% of original price
ghomes.emulate2Dmode = false -- replaces the 3D panels (the ones floating in the air) by the same menu but opening in a derma window when you press F2 on any door of your house.

ghomes.enabledhousenames = true -- enable the 3d panel with the house name
ghomes.maxpropertiesperuser = 3; -- it will prevent the guy from buying all the houses
ghomes.alarmprice = 2000 -- the price the guy will pay in the DLC if he want to enable the alarm that will be triggered when someone lockpicks one of his doors
ghomes.cooldownspawnafterrobbery = 60 * 5 -- in seconds, (60*5 = 5mins) don't let the player spawn in any house that was robbed less than x secs ago, it also applies for a battering ram used on a door
ghomes.autosellafternotconnecterforxdays = 3600 * 24 * 30 -- in seconds,(0 => it never expires)  if the player doesn't connect for x seconds then his houses get auto sold so anyone else can get them
-- ^^^^ --> 3600 * 24 * 30<-- ^^^^ for 30 days
ghomes.maxdaysrent = 182 -- in days, don't put it > 182 because renting it 182 days = purchase price (you can still change it in the NPC config menu tho)

--[[

	YOU CAN SET THE LIMIT IN HOURS BY USING SIMPLE MATHS LIKE  ghomes.maxdaysrent = (6/24)

																		^^ 6 hours here ^^
]]

ghomes.shouldsaveprops = true -- set it to false to disable the prop saving
ghomes.delayPropSaving = 60 -- save the props every X seconds


ghomes.propsSecurity =  false-- Disabled by default, it scans for each each properties and find any props from players that are not owners or co-owner of this property and remove thoses props
ghomes.propsSecurityDelay = 15 -- search for those props every X seconds


ghomes.sellwhenplayerleaves = false -- auto-sell the house when the player leaves the server, like vanilla darkrp
--[[ THERE IS NOT ANY WARNING TELLING THE PLAYER THAT THE HOUSE WILL AUTO-SELL WHEN HE LEAVES,
     IT IS YOUR JOB TO SET THE CORRECTS THE LIMITS ON THE HOUSES
     LIKE : 3 hours max and not any of the houses are available to purchase, you can only rent them. That's an example, do what you want.
--]]


ghomes.onlyAllowFriendsAsCoOwner = false
--[[ with this enabled you can only add your friends as co-owner, PREVENTING the following : 
		>Adding a stranger as co-owner
		>in the DLC menu, make him spawn in your house when he respawns even if he don't want to
]]


--[[


YOU CAN CHANGE THE LANGUAGE AT THE BOTTOM OF THE FILE
YOU CAN CHANGE THE LANGUAGE AT THE BOTTOM OF THE FILE
YOU CAN CHANGE THE LANGUAGE AT THE BOTTOM OF THE FILE
YOU CAN CHANGE THE LANGUAGE AT THE BOTTOM OF THE FILE
YOU CAN CHANGE THE LANGUAGE AT THE BOTTOM OF THE FILE
YOU CAN CHANGE THE LANGUAGE AT THE BOTTOM OF THE FILE

**** If you don't know what you're doing, don't touch anything after this comment or in any other file
--]]
local metaplayer = FindMetaTable("Player")

function metaplayer:CanMasterHouse()
	return self:IsUserGroup("superadmin")
end

if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("ghomes_system/sh_lang.lua")
	AddCSLuaFile("ghomes_system/client/mails.lua")
	AddCSLuaFile("ghomes_system/client/network.lua")
	AddCSLuaFile("ghomes_system/client/rendernames.lua")
	AddCSLuaFile("ghomes_system/client/3d2dvgui.lua") -- 3d vgui, modded
	AddCSLuaFile("ghomes_system/client/dermabuddy.lua") -- derma popup
	AddCSLuaFile("ghomes_system/client/ghomes_render_lib.lua")
	AddCSLuaFile("ghomes_system/ezlibs.lua")
	AddCSLuaFile("ghomes_system/sh_network.lua")
	include("ghomes_system/sh_lang.lua")
	include("ghomes_system/ezlibs.lua")
	include("ghomes_system/server/houses.lua") -- houses functions with right system
	include("ghomes_system/server/save.lua") -- houses save (vars)
	include("ghomes_system/server/propsave.lua") -- prop saving system  
	include("ghomes_system/server/mails.lua") -- mails system
	include("ghomes_system/server/npc_restore.lua") -- restore the npc
	include("ghomes_system/sh_network.lua")
	include("ghomes_system/server/debug.lua")
	include("ghomes_system/sh_compatibility/main.lua")
	local directories = select(2,file.Find( "ghomes_system/dlcs/*", "LUA" ))

	for k, v in pairs(directories) do
		local path = "ghomes_system/dlcs/" .. v .. "/"
		ghomes.dlcs[v] = {}
		local files = select(1,file.Find( path .. "*", "LUA" ))
		for k2, v2 in pairs(files) do
			include(path .. v2)
			AddCSLuaFile(path .. v2)
		end

		files = select(1,file.Find( path .. "server/*", "LUA" ))
		for k2, v2 in pairs(files) do
			include(path .. "server/" .. v2)
		end

		files = select(1,file.Find( path .. "client/*", "LUA" ))
		for k2, v2 in pairs(files) do
			AddCSLuaFile(path .. "client/" .. v2)
		end
	end

	AddCSLuaFile()
	local filesCompatibility = select(1,file.Find( "ghomes_system/sh_compatibility/*", "LUA" ))
	local pathComp = "ghomes_system/sh_compatibility/"
	for k, v in pairs(filesCompatibility) do
		AddCSLuaFile(pathComp .. v)
	end

	resource.AddWorkshop("1217926859") -- icons and bell sound
end

if CLIENT then
	include("ghomes_system/sh_lang.lua")
	include("ghomes_system/client/network.lua")
	include("ghomes_system/client/rendernames.lua")
	include("ghomes_system/client/dermabuddy.lua")
	include("ghomes_system/client/ghomes_render_lib.lua")
	include("ghomes_system/client/mails.lua")
	include("ghomes_system/ezlibs.lua")
	include("ghomes_system/sh_network.lua")
	include ("ghomes_system/sh_compatibility/main.lua")

	local directories = select(2,file.Find( "ghomes_system/dlcs/*", "LUA" ))

	for k, v in pairs(directories) do
		local path = "ghomes_system/dlcs/" .. v .. "/"
		ghomes.dlcs[v] = {}
		local files = select(1,file.Find( path .. "*", "LUA" ))
		for k2, v2 in pairs(files) do
			include(path .. v2)
		end

		files = select(1,file.Find( path .. "client/*", "LUA" ))
		for k2, v2 in pairs(files) do
			include(path .. "client/" .. v2)
		end
	end
end

-- available choices :
--[[
	ghomes.picklanguage(ghomes.languages.fr) -- baguette
	ghomes.picklanguage(ghomes.languages.en) -- yer bloody wanker
	ghomes.picklanguage(ghomes.languages.ru) -- cyka blyat
--]] 
ghomes.picklanguage(ghomes.languages.en)
