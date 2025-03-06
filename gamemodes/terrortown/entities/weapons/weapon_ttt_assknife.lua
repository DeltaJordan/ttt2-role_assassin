AddCSLuaFile()
SWEP.PrintName = "Assassin Knife"
SWEP.Category = "DeltaJordan's SWEPs"
SWEP.Author = "DeltaJordan"
SWEP.Contact = "deltajordan@protonmail.com"
SWEP.Purpose = "Attacking from the front does 40 damage, backstabs do 999."
SWEP.Instructions = "Primary attack - stab. Secondary announce stabbing."
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelBoneMods = {}
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.EquipMenuData = {
	type = "ass",
	desc = "Knife them in the back for an instant kill."
}

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {
	ROLE_TRAITOR -- only traitors can buy
}

SWEP.LimitedStock = true -- only buyable once
SWEP.IsSilent = true
SWEP.DeploySpeed = 2
SWEP.NoSights = true
SWEP.AutoSpawnable = false
SWEP.Icon = "vgui/ttt/icon_knife"
SWEP.IconLetter = "c"
SWEP.InLoadoutFor = nil

if SERVER then resource.AddFile("materials/vgui/ttt/icon_knife.vmt") end

SWEP.Slot = 8
SWEP.SlotPos = 1
SWEP.UseHands = true
SWEP.HoldType = "knife"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.ReloadSound = ""
SWEP.Base = "weapon_tttbase"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "None"
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "None"

function SWEP:Deploy()
	if CLIENT then surface.PlaySound("shank/dontgetshanked.wav") end
end

function SWEP:PrimaryAttack()
	self:GetOwner():EmitSound("shank/attack1.wav")
	if (self:GetNextPrimaryFire() >= CurTime()) then return end
	local tr = self:GetOwner():GetEyeTrace()
	if (tr.HitPos - self:GetOwner():GetShootPos()):Length() < 80 then
		if IsValid(tr.Entity) and SERVER then
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType(DMG_CLUB)
			dmginfo:SetAttacker(self:GetOwner())
			dmginfo:SetInflictor(self)
			local angle = self:GetOwner():GetAngles().y - tr.Entity:GetAngles().y
			if angle < -180 then angle = 360 + angle end
			if angle <= 90 and angle >= -90 then
				dmginfo:SetDamage(999)
				vm = self:GetOwner():GetViewModel()
			else
				dmginfo:SetDamage(40)
			end

			if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
				dmginfo:SetDamageForce(self:GetOwner():GetForward() * .5)
			else
				if IsValid(tr.Entity:GetPhysicsObject()) then tr.Entity:GetPhysicsObject():ApplyForceCenter(self:GetOwner():GetForward() * .5) end
			end

			tr.Entity:TakeDamageInfo(dmginfo)
		end

		self:SetNextPrimaryFire(CurTime() + 0.8)
		if IsValid(hitEnt) then
			self:SendWeaponAnim(ACT_VM_HITCENTER)
			local edata = EffectData()
			edata:SetStart(spos)
			edata:SetOrigin(tr.HitPos)
			edata:SetNormal(tr.Normal)
			edata:SetEntity(hitEnt)
			if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then util.Effect("BloodImpact", edata) end
		else
			self:SendWeaponAnim(ACT_VM_MISSCENTER)
		end

		if SERVER then self:GetOwner():SetAnimation(PLAYER_ATTACK1) end
	end
end

function SWEP:SecondaryAttack()
	if SERVER then self:GetOwner():EmitSound("shank/hyuking.wav") end
end

function SWEP:Reload()
	if SERVER then self:GetOwner():EmitSound("shank/toldya.wav") end
end

function SWEP:PreDrop()
	-- for consistency, dropped knife should not have DNA/prints
	self.fingerprints = {}
end

function SWEP:OnRemove()
	if CLIENT and IsValid(self:GetOwner()) and self:GetOwner() == LocalPlayer() and self:GetOwner():Alive() then RunConsoleCommand("lastinv") end
end