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

	local spawnChoose = SpawnChooser.Settings.Spawn[SpawnLocation]
	
	if 
		!ply.spawned and 
		(!istable(spawnChoose.restricted) or table.IsEmpty(spawnChoose.restricted) or spawnChoose.restricted[ply:Team()        ]) and 
		(!istable(spawnChoose.groups    ) or table.IsEmpty(spawnChoose.group     ) or spawnChoose.groups    [ply:GetUserGroup()])
	then
		ply:SetPos(table.Random(spawnChoose.pos))
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