class FlamethrowerProjectile : FastMissile
{
	Default
	{
		Radius 36.5;
		Height 60;
		FastMissile.RadiusScale 0.1;
		FastMissile.HeightScale 0.1;
		FastMissile.RadiusScaleFactor 0.02;
		FastMissile.HeightScaleFactor 0.02;
		
		FastMissile.DOTType "BurnDOT";
		
		Scale 0.3;
		FastMissile.XScaleFactor 0.15;
		FastMissile.YScaleFactor 0.15;
		
		DamageFunction 10;
		DamageType "Fire";
		Speed 50;
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "weapons/rocklf";
		Obituary "%o was burned to death by %k.";
		Decal "Scorch";
		
		+FORCEXYBILLBOARD
		+NOBLOOD
		+PAINLESS
		+FASTMISSILE.HITONCE
	}
	
	States
	{
		Spawn:
			MISL B 6 Bright;
			Stop;
			
		Death:
			TNT1 A 0 A_AreaOfEffect("FireAoE", 12);
			MISL C 3 Bright A_Splash(32, radius*2, XF_NOSPLASH);
			MISL D 2 Bright;
			Stop;
	}
	
	override void CustomEffect()
	{
		//alpha -= min(0.02, alpha);
		XScaleFactor+=0.10;
		YScaleFactor+=0.10;
	}
}

class BurnDOT : CustomDOT
{
	Default
	{
		DamageType "Fire";
		CustomDOT.EffectRate 4;
		CustomDOT.EffectActor "FlameEffect";
		Inventory.MaxAmount 7;
		DamageFunction 5;
		
		+PAINLESS
	}
}

class FlameEffect : DOTEffect
{
	Default
	{
		RenderStyle "Add";
		Alpha 0.4;
		Scale 0.2;
		
		+DOTEFFECT.NOWARP
	}
	
	States
	{
		Spawn:
			FIRE ABCDEFGH 2 Bright;
			Stop;
	}
	
	override void Effect()
	{
		scale.x -= min(0.01, scale.x);
		scale.y -= min(0.01, scale.y);
	}
}

class FireAoE : AoE
{
	static const String noSpawn[] =
	{
		"FWATER1", "FWATER2", "FWATER3", "FWATER4",
		"BLOOD1", "BLOOD2", "BLOOD3"
	};
	
	Default
	{
		Radius 16;
		Height 24;
		DamageFunction 5;
		DamageType "Fire";
		
		AoE.DOTType "BurnDOT";
		AoE.EffectRate 4;
		AoE.EffectActor "GroundFireFlame";
		
		+PAINLESS
		+AOE.NOLIQUIDS
	}
	
	States
	{
		Spawn:
			TNT1 A 70;
			Stop;
	}
	
	override void BeginPlay()
	{
		super.BeginPlay();
		
		TextureID offLimits;
		for (int i = 0; i < noSpawn.Size(); ++i)
		{
			offLimits = TexMan.CheckForTexture(noSpawn[i], TexMan.Type_Flat);
			if (floorpic == offLimits)
			{
				Destroy();
				return;
			}
		}
	}
}

class GroundFireFlame : Actor
{
	Default
	{
		RenderStyle "Add";
		Alpha 0.4;
		Scale 0.3;
		
		+NOINTERACTION
	}
	
	States
	{
		Spawn:
			FIRE ABCDEFGH 2 Bright;
			Stop;
	}
	
	override void Tick()
	{
		super.Tick();
		
		if (bDestroyed || IsFrozen())
			return;
		
		scale.x -= min(0.02, scale.x);
		scale.y -= min(0.02, scale.y);
	}
}

class Fuel : Ammo replaces RocketAmmo
{
	Default
	{
		Inventory.Amount 25;
		Inventory.MaxAmount 300;
		Ammo.BackpackAmount 25;
		Ammo.BackpackMaxAmount 600;
		Inventory.PickupMessage "Picked up a fuel canister.";
		Inventory.Icon "ROCKA0";
	}
	
	States
	{
		Spawn:
			ROCK A -1;
			Stop;
	}
}

class LargeFuel : Fuel replaces RocketBox
{
	Default
	{
		Inventory.Amount 100;
		Inventory.PickupMessage "Picked up a box of fuel canisters.";
	}
	
	States
	{
		Spawn:
			BROK A -1;
			Stop;
	}
}

class ModernFlamethrower : DoomWeapon replaces RocketLauncher
{
	Default
	{
		Weapon.SlotNumber 2;
		Weapon.SelectionOrder 2500;
		Weapon.AmmoUse 0;
		Weapon.AmmoGive 50;
		Weapon.AmmoType "Fuel";
		Inventory.PickupMessage "Picked up a Flamethrower!";
		Tag "Flamethrower";
	}
	
	States
	{
		Ready:
			MISG A 1 A_WeaponReady;
			Loop;
			
		Deselect:
			MISG A 1 A_Lower(40);
			Loop;
			
		Select:
			MISG A 1 A_Raise(40);
			Loop;
			
		Fire:
			MISG B 1 SpawnPlayerMissile("FlamethrowerProjectile", nofreeaim:0,noautoaim:1);
			TNT1 A 0 A_ReFire;
			Goto Ready;
			
		Flash:
			MISF C 1 Bright A_Light1;
			Goto LightDone;
			
		Spawn:
			LAUN A -1;
			Stop;
	}
}
