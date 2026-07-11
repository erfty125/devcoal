class WaveProjectile : Missile
{
	Default
	{
		Radius 66.5;
		Height 7;
		Missile.RadiusScale 0.05;
		
		Missile.MaxRadiusScale 4;
		Missile.RadiusScaleFactor 0.12;
		
		XScale 0.05;
		Missile.MaxXScale 4;
		Missile.XScaleFactor 0.12;
		
		DamageFunction 70;
		Speed 32;
		RenderStyle "Add";
		Alpha 0.5;
		DeathSound "weapons/bfgx";
		Obituary "%o was beamed down by %k.";
		Decal "BFGLightning";
		
		+FORCEXYBILLBOARD
		+MISSILE.HITONCE
	}
	
	States
	{
		Spawn:
			BFE1 E 1 Bright;
			Loop;
			
		Death:
			BFE1 F 2 Bright A_Splash(70, radius*1.5, XF_NOSPLASH, splashDOT: "WaveDOT");
			Stop;
	}
}

class WaveDOT : CustomDOT
{
	Default
	{
		CustomDOT.Duration 35;
		CustomDOT.StackType "Additive";
		
		+ADDITIVEPOISONDURATION
	}
	
	override void DoEffect()
	{
		super.DoEffect();
		
		if (!owner || bDestroyed || IsFrozen())
			return;
		
		if (owner.health > 0)
		{
			let pain = owner.FindState("Pain");
			if (pain)
			{
				owner.SetState(pain);
				owner.A_StartSound(owner.PainSound, CHAN_BODY);
			}
		}
	}
}

class Wave : Ammo replaces Clip
{
	Default
	{
		Inventory.Amount 20;
		Inventory.MaxAmount 300;
		Ammo.BackpackAmount 20;
		Ammo.BackpackMaxAmount 600;
		Inventory.PickupMessage "Picked up an energy pack.";
		Inventory.Icon "CLIPA0";
	}
	
	States
	{
		Spawn:
			CLIP A -1;
			Stop;
	}
}

class LargeWave : Wave replaces ClipBox
{
	Default
	{
		Inventory.Amount 100;
		Inventory.PickupMessage "Picked up a box of energy packs.";
	}
	
	States
	{
		Spawn:
			AMMO A -1;
			Stop;
	}
}

class WaveGun : DoomWeapon replaces BFG9000
{
	Default
	{
		Weapon.SlotNumber 7;
		Weapon.SelectionOrder 2800;
		Weapon.AmmoUse 20;
		Weapon.AmmoGive 20;
		Weapon.AmmoType "Wave";
		Inventory.PickupMessage "Picked up a Wave Gun!";
		Tag "Wave Gun";
	}
	
	States
	{
		Ready:
			BFGG A 1 A_WeaponReady;
			Loop;
			
		Deselect:
			BFGG A 1 A_Lower;
			Loop;
			
		Select:
			BFGG A 1 A_Raise;
			Loop;
			
		Fire:
			BFGG A 10 A_BFGSound;
			BFGG B 10 A_GunFlash;
			BFGG B 10 A_FireProjectile("WaveProjectile");
			BFGG B 10 A_ReFire;
			Goto Ready;
			
		Flash:
			BFGF A 11 Bright A_Light1;
			BFGF B 6 Bright A_Light2;
			Goto LightDone;
			
		Spawn:
			BFUG A -1;
			Stop;
	}
}