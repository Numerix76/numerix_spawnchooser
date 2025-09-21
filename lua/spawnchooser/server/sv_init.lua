--[[ SpawnChooser --------------------------------------------------------------------------------------

SpawnChooser made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]

util.AddNetworkString("SpawnChooser:OpenMenu")
util.AddNetworkString("SpawnChooser:CloseMenu")
util.AddNetworkString("SpawnChooser:SetPos")

local function SpawnTP(ply)
	if !DarkRP and true or !ply:isArrested() then
		if 
			(!SpawnChooser.Settings.BlackListTeam or !SpawnChooser.Settings.BlackListTeam[ply:Team()]) and 
			!IsValid(ply.__PEXRagdoll) and -- Compatibilty for https://steamcommunity.com/sharedfiles/filedetails/?id=1729622779
			!ply.ULibSpawnInfo -- Compatibility for ULX
		then
			net.Start("SpawnChooser:OpenMenu")
			net.Send(ply)
			ply.spawned = false
		end
	end
end
hook.Add( "PlayerSpawn", "SpawnChooser:PlayerSpawn", SpawnTP )

net.Receive("SpawnChooser:SetPos", function(len, ply)
	local SpawnLocation = net.ReadString()
	
	if !ply.spawned and (SpawnChooser.Settings.Spawn[SpawnLocation].restricted == false or SpawnChooser.Settings.Spawn[SpawnLocation].restricted[ply:Team()]) then
		ply:SetPos(table.Random(SpawnChooser.Settings.Spawn[SpawnLocation].pos))
		ply.spawned = true
	end

	ServerLog("[SpawnChooser] "..ply:Name().." ("..ply:SteamID()..") has selected a new spawn. ("..SpawnLocation..")")
end)

local function CloseTPMenu(ply)
	net.Start("SpawnChooser:CloseMenu")
	net.Send(ply)

	-- The player did not used the menu and we have to prevent a net hack
	ply.spawned = true
end
hook.Add("onPlayerRevived", "SpawnChooser:onPlayerRevived", CloseTPMenu ) -- Compatibility for https://www.gmodstore.com/market/view/amm-advanced-medic-mod-the-first-complete-and-realistic-medical-addon
hook.Add("CH_AdvMedic_RevivePlayer", "SpawnChooser:CH_AdvMedic_RevivePlayer", CloseTPMenu) -- Compatibility for https://www.gmodstore.com/market/view/paramedic-essentials