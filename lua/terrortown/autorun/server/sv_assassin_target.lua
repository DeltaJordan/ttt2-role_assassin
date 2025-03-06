CreateConVar("ttt2_assassin_credit_bonus", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_assassin_target_awarditem", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})

local function CanBeTarget(ply, target, blacklisted)
	return target:IsActive()
		and not target:IsInTeam(ply)
		and not (target.IsGhost and target:IsGhost())
		and target ~= blacklisted
		and hook.Run("TTT2CanBeAssassinTarget", ply, target) ~= false
end

local function GetTargets(ply, blacklisted)
	local targets = {}
	local policingRoles = {}
	if not IsValid(ply) or not ply:IsActive() or (ply.IsGhost and ply:IsGhost()) or ply:GetSubRole() ~= ROLE_ASSASSIN then return targets end
	local plys = player.GetAll()
	for i = 1, #plys do
		local p = plys[i]
		if not CanBeTarget(ply, p, blacklisted) then continue end
		local pRoleData = p:GetSubRoleData()
		if pRoleData.isPolicingRole and pRoleData.isPublicRole then
			policingRoles[#policingRoles + 1] = p
		else
			targets[#targets + 1] = p
		end
	end

	if #targets < 1 then targets = policingRoles end
	return targets
end

local function SelectNewTarget(ply, blacklisted)
	local targets = GetTargets(ply, blacklisted)
	if #targets > 0 then
		ply:SetTargetPlayer(targets[math.random(1, #targets)])
	else
		ply:SetTargetPlayer(nil)
		LANG.Msg(ply, "ttt2_assassin_target_unavailable", nil, MSG_STACK_PLAIN)
	end
end

local function AssassinTargetDied(ply, attacker, dmgInfo)
	if GetRoundState() ~= ROUND_ACTIVE then return end
	local wasTargetKill = false
	if IsValid(attacker)
		and attacker:IsPlayer()
		and attacker:GetSubRole() == ROLE_ASSASSIN
		and attacker:GetTargetPlayer()
		and (not attacker.IsGhost or not attacker:IsGhost())
		and attacker:GetTargetPlayer() == ply -- if attacker's target is the dead player
	then
		wasTargetKill = true
		local val = GetConVar("ttt2_assassin_target_awarditem"):GetBool()
		if val and attacker:IsActive() then
			local t_weapons = {}
			local value = 0
			for _, v in pairs(weapons.GetList()) do
				if table.HasValue(v.CanBuy, ROLE_TRAITOR) then
					table.insert(t_weapons, v.ClassName)
					value = value + 1
				end
			end
			local randwep = t_weapons[math.random(1, value)]
			attacker:GiveEquipmentWeapon(randwep:GetClass())
			LANG.Msg(attacker, "ttt2_assassin_target_killed_item", {
				item = randwep:GetPrintName()
			}, MSG_MSTACK_ROLE)
		else
			LANG.Msg(attacker, "ttt2_assassin_target_killed", nil, MSG_MSTACK_ROLE)
		end
	end

	local plys = player.GetAll()
	for i = 1, #plys do
		local plyAssassin = plys[i]
		if plyAssassin:GetSubRole() ~= ROLE_ASSASSIN or (plyAssassin.IsGhost and plyAssassin:IsGhost()) then continue end
		local target = plyAssassin:GetTargetPlayer()
		if IsValid(target) and (not target:IsActive() or target == ply or (target.IsGhost and target:IsGhost())) then
			if not wasTargetKill then LANG.Msg(plyAssassin, "ttt2_assassin_target_died", nil, MSG_MSTACK_PLAIN) end
			SelectNewTarget(plyAssassin, ply)
		end
	end
end
hook.Add("DoPlayerDeath", "AssassinTargetDied", AssassinTargetDied)

local function AssassinTargetSpawned(ply)
	if GetRoundState() ~= ROUND_ACTIVE then return end

	local plys = player.GetAll()

	for i = 1, #plys do
		local plyAssassin = plys[i]

		if plyAssassin:GetSubRole() ~= ROLE_ASSASSIN
			or (plyAssassin.IsGhost and plyAssassin:IsGhost())
			or IsValid(plyAssassin:GetTargetPlayer())
		then continue end

		SelectNewTarget(plyAssassin)
	end
end
hook.Add("PlayerSpawn", "AssassinTargetSpawned", AssassinTargetSpawned)

local function AssassinTargetDisconnected(ply)
	if GetRoundState() ~= ROUND_ACTIVE then return end

	local plys = player.GetAll()

	for i = 1, #plys do
		local plyAssassin = plys[i]

		if plyAssassin:GetSubRole() ~= ROLE_ASSASSIN
			or (plyAssassin.IsGhost and plyAssassin:IsGhost())
			or plyAssassin:GetTargetPlayer() ~= ply
		then continue end

		SelectNewTarget(plyAssassin, ply)
	end
end
hook.Add("PlayerDisconnected", "AssassinTargetDisconnected", AssassinTargetDisconnected)

local function AssassinTargetRoleChanged(ply, old, new)
	if GetRoundState() ~= ROUND_ACTIVE then return end

	-- handle target of the role itself
	if new == ROLE_ASSASSIN then
		SelectNewTarget(ply)
	elseif old == ROLE_ASSASSIN then
		ply:SetTargetPlayer(nil)
	end

	-- handle role changes of the target
	local plys = player.GetAll()

	for i = 1, #plys do
		local plyAssassin = plys[i]

		if plyAssassin:GetSubRole() ~= ROLE_ASSASSIN
			or (plyAssassin.IsGhost and plyAssassin:IsGhost())
			or CanBeTarget(plyAssassin, ply)
		then continue end

		SelectNewTarget(plyAssassin)
	end
end
hook.Add("TTT2UpdateSubrole", "AssassinTargetRoleChanged", AssassinTargetRoleChanged)

local function AssassinGotSelected()
	local plys = player.GetAll()

	for i = 1, #plys do
		local plyAssassin = plys[i]

		if plyAssassin:GetSubRole() ~= ROLE_ASSASSIN
			or (plyAssassin.IsGhost and plyAssassin:IsGhost())
		then continue end

		SelectNewTarget(plyAssassin)
	end
end
hook.Add("TTTBeginRound", "AssassinGotSelected", AssassinGotSelected)