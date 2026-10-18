version "4.11.0"

#include "ftlib/zscript.zs"

class CumstomDookPlayer : DoomPlayer replaces DoomPlayer
{
    Default
    {
        Player.ViewHeight 25;
        Player.StartItem "Ahh";
        Player.StartItem "ModernFlamethrower";
        Player.StartItem "Buttn";
	Player.WeaponSlot 1, "Ahh";
	Player.WeaponSlot 2, "ModernFlamethrower", "buttn";
    }
}



class Ahh : Weapon replaces Fist
{
int fired;

        action void A_Punch(int damage)
        {
                FTranslatedLineTarget t;

                if (player != null)
                {
                        Weapon weap = player.ReadyWeapon;
                        if (weap != null && !weap.bDehAmmo && invoker == weap && stateinfo != null && stateinfo.mStateType == STATE_Psprite)
                        {
                                if (!weap.DepleteAmmo (weap.bAltFire))
                                        return;
                        }
                }

                if (FindInventory("PowerStrength"))
                        damage *= 10;

                double ang = angle;
                double range = 64 + MELEEDELTA;
                double pitch = AimLineAttack (ang, range, null, 0., ALF_CHECK3D);

		LineAttack (ang, range, pitch, damage, 'Melee', "BulletPuff", LAF_ISMELEEATTACK, t);
                // turn to face target
                if (t.linetarget)
                {
                        A_StartSound ("weapons/grenlx", CHAN_WEAPON);
//                      angle = t.angleFromSource;
                }
        }

        Default
        {
		Weapon.SlotNumber 1;
                Weapon.SelectionOrder 3700;
                Weapon.Kickback 100;
                Obituary "$OB_MPFIST";
                Tag "$TAG_FIST";
                +WEAPON.WIMPY_WEAPON
                +WEAPON.MELEEWEAPON
                +WEAPON.NOAUTOSWITCHTO
        }
        States
        {
        Ready:
                PUNG A 1 { A_WeaponReady(); invoker.fired=0;}
                Loop;
        Deselect:
                PUNG A 0 A_Lower(40);
                Loop;
        Select:
                PUNG A 0 A_Raise(40);
                Loop;
        Fire:
                PUNG A 1
		{  if(invoker.fired<1){A_Punch(1000); invoker.fired=1;}}
                PUNG A 0;
                PUNG B 1 A_ReFire;
                PUNG C 1;
                PUNG D 0;
		PUNG E 1;
		PUNG F 0;
		PUNG G 0;
		PUNG H 1;
                Goto Ready;
        }
}


class AHHPistol : Pistol
{
        int fired;
        Default
        {
                Weapon.SelectionOrder 1900;
                Weapon.AmmoUse 0;
                Weapon.AmmoGive 585;
                Weapon.AmmoType "Clip";
		Weapon.SlotNumber 4;
        }
        States
        {
        Ready:
                PISG A 1 { A_WeaponReady(); invoker.fired=0;}
                Loop;
        Deselect:
                PISG A 0 A_Lower(40);
                Loop;
        Select:
                PISG A 0 A_Raise(40);
                Loop;
        Fire:
                TNT1 A 0 {  if(invoker.fired<1){A_FirePistol(); invoker.fired=1;}}
                PISG B 1;
                PISG C 0 A_ReFire;
                GoTo Ready;
        Ahh:
                PISG C 1;
        Flash:
                PISF A 1 Bright A_Light1;
                Goto LightDone;
                PISF A 1 Bright A_Light1;
                Goto LightDone;
        Spawn:
                PIST A -1;
                Stop;
        }
}


class Buttn : Pistol
{
        int fired;

        Default
        {
                Weapon.SelectionOrder 1900;
                Weapon.AmmoUse 0;
                Weapon.AmmoGive 585;
                Weapon.AmmoType "Clip";
                Weapon.SlotNumber 2;
        }

	action bool IsKefir(Actor thing)
	{
		return (thing.GetClassName()=="KefirGrenade" && (thing.InStateSequence(thing.curstate, thing.ResolveState("Spawn")) || thing.InStateSequence(thing.curstate, thing.ResolveState("Flyin")) ));
	}

	action void A_PushButtn()
        {
                BlockThingsIterator itr = BlockThingsIterator.Create(self, 5000);
                while (itr.Next())
                {
                        Actor victim = itr.thing;
                        if (!IsKefir(victim)) //check for bSHOOTABLE, health, friendliness, etc.
                                continue;
		        victim.SetStateLabel("Explode");
                }
	}

	action void A_TrowKefir()
	{
	double savedpitch = pitch;
        pitch -= 15.328125;
	SpawnPlayerMissile("KefirGrenade", nofreeaim:0,noautoaim:1);
	pitch = SavedPitch;
	}


        Default
        {
                Weapon.SelectionOrder 1900;
                Weapon.AmmoUse 0;
                Weapon.AmmoGive 585;
                Weapon.AmmoType "Clip";
        }
        States
        {
        Ready:
                PIST A 1 { A_WeaponReady(); invoker.fired=0;}
                Loop;
        Deselect:
                PIST A 0 A_Lower(40);
                Loop;
        Select:
                PIST A 0 A_Raise(40);
                Loop;
        AltFire:
                TNT1 A 0 {  if(invoker.fired<1){A_PushButtn(); invoker.fired=1;}}
                PIST E 1;
                PIST F 1 A_ReFire;
                GoTo Ready;
        Fire:
		PIST A 1 {  if(invoker.fired<1){invoker.fired=1;}}
                PIST B 1 A_ReFire;
                PIST C 1;
		PIST D 1 A_TrowKefir();
                GoTo Ready;
        Flash:
                PIST A 1 Bright A_Light1;
                Goto LightDone;
                PIST A 1 Bright A_Light1;
                Goto LightDone;
        Spawn:
                PIST A -1;
                Stop;
        }
}



class KefirGrenade : Actor
{
        Default
        {
                Radius 3;
                Height 3;
                Speed 25;
                Damage 1;
		Scale 0.25;
		//Projectile;
                -NOGRAVITY
                +RANDOMIZE
                //+DEHEXPLOSION
                //+GRENADETRAIL
                BounceType "Doom";
                Gravity 1;
                SeeSound "weapons/grenlf";
                DeathSound "weapons/grenlx";
                BounceSound "weapons/grbnce";
                Obituary "$OB_GRENADE";
                DamageType "Grenade";
        }
        States
        {
	Spawn:
		MISL A 1 Applyfriction();
		MISL A 1 A_JumpIf(HasHorVel(), "Flyin");
		Loop;
        Flyin:
                MISL A 4;
		MISL B 6;
		MISL C 6 Applyfriction();
		MISL D 6;
                Goto Spawn;

        Explode:
                MISL A 1;
                MISL B 8 Bright {A_StartSound ("weapons/grenlx", CHAN_WEAPON); A_Explode(1000,300,0);}
                MISL C 6 Bright;
                MISL D 4 Bright;
                Stop;
	Death:
		MISL D 4 Bright;
		Stop;
        Grenade:
                MISL A 5000 A_Die;
		stop;
        Detonate:
                MISL A 1;
                MISL B 4 A_Scream;
                MISL C 6 A_Detonate;
                MISL D 10;
                Stop;
        Mushroom:
                MISL A 1;
		loop;
                MISL B 8 A_Mushroom;
                Goto Death+1;
        }



void Applyfriction(){
if((z-floorz)<=1.0){vel.x=0;vel.y=0;}
		    }


 bool HasHorVel()
    {
        Vector3 vel = vel;
        return (abs(vel.x) > 3.0 || abs(vel.y) > 3.0);
    }


}

