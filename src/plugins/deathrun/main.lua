PrefixHTML = "<font color='red'>[Deathrun]</font>"
PrefixChat = "{red}[Deathrun]{default}"

MAX_TIME = 20
MAX_TR = 2

function SetSpeed(player, speed)
	-- Get the player pawn
	local playerPawn = player:CCSPlayerPawn()
	if not playerPawn:IsValid() then return end  -- Ensure the pawn is valid

	-- Set the velocity modifier (speed) for the player
	playerPawn.VelocityModifier = speed
end

function PluginConfig()
	server:Execute("mp_roundtime " .. MAX_TIME)
	server:Execute("mp_roundtime_defuse " .. MAX_TIME)
	server:Execute("mp_roundtime_hostage " .. MAX_TIME)
	-- Punishment settings
	server:Execute("mp_autokick 0")
	server:Execute("mp_friendlyfire 0")
	server:Execute("mp_suicide_penalty 0")
	server:Execute("mp_autokick 0")
	-- Rounds Setup
	server:Execute("mp_maxrounds 30")
	server:Execute("mp_freezetime 2")
	server:Execute("mp_limitteams 0")
	-- server:Execute("mp_halftime 0") -- DISABLED HERE DUE SCOREBOARD VISUAL BUG
	server:Execute("mp_tkpunish 0")
	server:Execute("bot_knives_only 1")
	-- Talk
	server:Execute("sv_alltalk 1")
	server:Execute("sv_full_alltalk 1")
	server:Execute("sv_talk_enemy_dead 1")
	server:Execute("sv_talk_enemy_living 1")
	-- Others
	server:Execute("bot_quota_mode normal")
	server:Execute("sv_enablebunnyhopping 1")
	-- Required
	server:Execute("mp_warmup_end")
	server:Execute("mp_restartgame 2")
end

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
    for _, player in ipairs(TPlayers) do
        player:SwitchTeam(3)
    end
    if not MAX_TR then
        print("Error: MAX_TR no definido")
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
	if not player:CBaseEntity():IsValid() then return print("Player is not valid") end
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