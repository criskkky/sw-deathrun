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
