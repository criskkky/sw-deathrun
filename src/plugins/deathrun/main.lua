PrefixHTML = "<font color='red'>[Deathrun]</font>"
PrefixChat = "{red}[Deathrun]{default}"

MAX_TIME = 20
MAX_TR = 2

AddEventHandler("OnMapLoad", function(event, map)
	PluginConfig()
    return EventResult.Continue
end)

AddEventHandler("OnPluginStart", function (event)
	PluginConfig()
	return EventResult.Continue
end)

AddEventHandler("OnRoundAnnounceWarmup", function(event)
	PluginConfig()
	return EventResult.Continue
end)

AddEventHandler("OnWarmupEnd", function(event)
	PluginConfig()
	return EventResult.Continue
end)

AddEventHandler("OnClientCommand", function(event, playerid, command) -- Player Management
    local player = GetPlayer(playerid)
    if not player then return end
	local TPlayers = FindPlayersByTarget("@t", true)
	local jointeam_ct = "^jointeam 3%s?%d*$" -- CT
	local jointeam_t = "^jointeam 2%s?%d*$" -- T
	-- Block CT when there's no players on T
	if string.match(command, jointeam_ct) and #TPlayers == 0 then
		player:SendMsg(MessageType.Center, string.format("%s %s", PrefixHTML, FetchTranslation("deathrun.teamlimit")))
		event:SetReturn(false)
	end
	-- Block T when there's more than X players on T
	if string.match(command, jointeam_t) and #TPlayers >= MAX_TR then
		player:SendMsg(MessageType.Center, string.format("%s %s", PrefixHTML, FetchTranslation("deathrun.teamlimit")))
		event:SetReturn(false)
	end
    return EventResult.Continue
end)

AddEventHandler("OnPostRoundEnd", function(event)
    local TPlayers = FindPlayersByTarget("@t", true)
    for i=1,#TPlayers do
        TPlayers[i]:SwitchTeam(3)
    end
    if not MAX_TR then
        print("Error: MAX_TR not defined")
        return EventResult.Continue
    end
    local CTPlayers = FindPlayersByTarget("@ct", true)
    if #CTPlayers >= MAX_TR then
        MAX_TR = 1
    end
    for i = 1, math.min(MAX_TR, #CTPlayers) do
        local randomIndex = math.random(#CTPlayers)
        local player = table.remove(CTPlayers, randomIndex)
        player:SwitchTeam(2)
    end
	playermanager:SendMsg(MessageType.Center, string.format("%s %s", PrefixHTML, FetchTranslation("deathrun.randomtr")))
	server:Execute("mp_halftime 0") -- Required here
    return EventResult.Continue
end)

AddEventHandler("OnClientCommand", function(event, playerid, command) -- Block Commands
    local player = GetPlayer(playerid)
    if not player then return end
    if string.find(command, "^buy") then
        player:SendMsg(MessageType.Chat, string.format("%s %s", PrefixChat, FetchTranslation("deathrun.blocked_cmd")))
        event:SetReturn(false)
    end
    return EventResult.Continue
end)

AddEventHandler("OnPlayerSpawn", function(event)
	local playerid = event:GetInt("userid")
	local player = GetPlayer(playerid)
	if not player then return end
	if player:IsFirstSpawn() then return end
	NextTick(function()
	if not player:CBaseEntity():IsValid() then return end
		local team = player:CBaseEntity().TeamNum
		if team == Team.T then
			SetSpeed(player, 3)
			player:GetWeaponManager():RemoveWeapons()
			player:GetWeaponManager():GiveWeapon("weapon_knife")
		elseif team == Team.CT then
			SetSpeed(player, 1)
			player:GetWeaponManager():RemoveWeapons()
			player:GetWeaponManager():GiveWeapon("weapon_knife")
		end
	end)
	return EventResult.Continue
end)
