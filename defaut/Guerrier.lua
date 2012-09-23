Ovale.defaut["WARRIOR"] = [[Define(avatar 107574)
  SpellInfo(avatar duration=20 cd=180 )
  SpellAddBuff(avatar avatar=1)
Define(battle_shout 6673)
  SpellInfo(battle_shout duration=300 cd=60 )
  SpellAddBuff(battle_shout battle_shout=1)
Define(battle_stance 2457)
  SpellInfo(battle_stance cd=3 )
Define(berserker_rage 18499)
  SpellInfo(berserker_rage duration=6 cd=30 )
  SpellAddBuff(berserker_rage berserker_rage=1)
Define(bladestorm 46924)
  SpellInfo(bladestorm duration=6 cd=90 )
  SpellAddBuff(bladestorm bladestorm=1)
Define(bloodbath 113344)
  SpellInfo(bloodbath duration=6 tick=1 )
  SpellAddTargetDebuff(bloodbath bloodbath=1)
Define(bloodsurge 46915)
Define(bloodthirst 23881)
  SpellInfo(bloodthirst rage=-10 cd=4.5 )
Define(colossus_smash 86346)
  SpellInfo(colossus_smash duration=6.5 cd=20 )
  SpellAddTargetDebuff(colossus_smash colossus_smash=1)
Define(deadly_calm 85730)
  SpellInfo(deadly_calm duration=9 cd=60 )
  SpellAddBuff(deadly_calm deadly_calm=1)
Define(defensive_stance 71)
  SpellInfo(defensive_stance cd=3 )
Define(demoralizing_shout 1160)
  SpellInfo(demoralizing_shout duration=10 cd=60 )
  SpellAddTargetDebuff(demoralizing_shout demoralizing_shout=1)
Define(devastate 20243)
Define(dragon_roar 118000)
  SpellInfo(dragon_roar cd=60 )
Define(enrage 5229)
  SpellInfo(enrage duration=10 rage=-20 cd=60 )
  SpellAddBuff(enrage enrage=1)
Define(execute 5308)
Define(heroic_leap 6544)
  SpellInfo(heroic_leap duration=1 cd=45 )
  AddCheckBox(heroic_leap_check SpellName(heroic_leap))
Define(heroic_strike 78)
  SpellInfo(heroic_strike cd=1.5 )
Define(heroic_throw 57755)
  SpellInfo(heroic_throw cd=30 )
Define(impending_victory 103840)
  SpellInfo(impending_victory cd=30 )
Define(mortal_strike 12294)
  SpellInfo(mortal_strike duration=10 rage=-10 cd=6 )
  SpellAddTargetDebuff(mortal_strike mortal_wounds=1)
Define(overpower 7384)
  SpellAddBuff(overpower taste_for_blood=-1)
Define(raging_blow 85288)
  SpellAddBuff(raging_blow raging_blow_aura=-1)
Define(raging_blow_aura 131116)
  SpellInfo(raging_blow_aura duration=12 )
  SpellAddBuff(raging_blow_aura raging_blow_aura=1)
Define(recklessness 1719)
  SpellInfo(recklessness duration=12 cd=300 )
  SpellAddBuff(recklessness recklessness=1)
Define(revenge 6572)
  SpellInfo(revenge rage=-15 cd=9 )
Define(shield_barrier 112048)
  SpellInfo(shield_barrier duration=6 cd=1.5 )
  SpellAddBuff(shield_barrier shield_barrier=1)
Define(shield_block 2565)
  SpellInfo(shield_block cd=1.5 )
Define(shield_slam 23922)
  SpellInfo(shield_slam rage=-20 cd=6 )
Define(shield_wall 871)
  SpellInfo(shield_wall duration=12 cd=300 )
  SpellAddBuff(shield_wall shield_wall=1)
Define(shockwave 46968)
  SpellInfo(shockwave cd=20 )
  SpellAddBuff(shockwave shockwave=1)
Define(slam 1464)
Define(storm_bolt 107570)
  SpellInfo(storm_bolt cd=30 )
  SpellAddBuff(storm_bolt storm_bolt=1)
Define(taste_for_blood 56638)
Define(thunder_clap 6343)
  SpellInfo(thunder_clap cd=6 )
  SpellAddTargetDebuff(thunder_clap weakened_blows=1)
Define(ultimatum 122509)
Define(weakened_blows 115798)
  SpellInfo(weakened_blows duration=30 )
  SpellAddBuff(weakened_blows weakened_blows=1)
Define(wild_strike 100130)
  SpellAddBuff(wild_strike bloodsurge=-1)
  SpellAddTargetDebuff(wild_strike wild_strike=1)
Define(avatar_talent 16)
Define(bladestorm_talent 10)
Define(bloodbath_talent 17)
Define(dragon_roar_talent 12)
Define(impending_victory_talent 6)
Define(shockwave_talent 11)
Define(storm_bolt_talent 18)
AddCheckBox(showwait L(showwait) default)
AddIcon mastery=1 help=main
{
	if not InCombat() 
	{
		unless Stance(1) Spell(battle_stance)
	}
	Spell(mortal_strike)
	if target.DebuffRemains(colossus_smash) <=1.5 Spell(colossus_smash)
	if target.HealthPercent(less 20) Spell(execute)
	if TalentPoints(storm_bolt_talent) Spell(storm_bolt)
	if BuffPresent(overpower) Spell(overpower usable=1)
	if {Rage() >=70 or target.DebuffPresent(colossus_smash) } and target.HealthPercent() >=20 Spell(slam)
	Spell(heroic_throw)
	if Rage() <70 and not target.DebuffPresent(colossus_smash) Spell(battle_shout)
	if target.HealthPercent() >=20 Spell(slam)
	if TalentPoints(impending_victory_talent) and target.HealthPercent() >=20 Spell(impending_victory)
	if Rage() <70 Spell(battle_shout)
}
AddIcon mastery=1 help=offgcd
{
	if TalentPoints(bloodbath_talent) and {{{SpellCooldown(recklessness) >=10 or BuffPresent(recklessness) } or {target.HealthPercent() >=20 and {target.DeadIn() <=165 or {target.DeadIn() <=315 and not ArmorSetParts(T14 more 4) } } and target.DeadIn() >75 } } or target.DeadIn() <=19 } Spell(bloodbath)
	if not BuffPresent(enrage) Spell(berserker_rage)
	if target.DebuffPresent(colossus_smash) if CheckBoxOn(heroic_leap_check) Spell(heroic_leap)
	if Rage() >=40 Spell(deadly_calm)
	if {{BuffPresent(taste_for_blood) and BuffRemains(taste_for_blood) <=2 } or {BuffStacks(taste_for_blood) ==5 and BuffPresent(overpower) } or {BuffPresent(taste_for_blood) and target.DebuffRemains(colossus_smash) <=2 and not SpellCooldown(colossus_smash) ==0 } or BuffPresent(deadly_calm) or Rage() >110 } and target.HealthPercent() >=20 and target.DebuffPresent(colossus_smash) Spell(heroic_strike)
}
AddIcon mastery=1 help=aoe
{
	if TalentPoints(shockwave_talent) Spell(shockwave)
	if TalentPoints(dragon_roar_talent) Spell(dragon_roar)
	if TalentPoints(bladestorm_talent) and SpellCooldown(colossus_smash) >=5 and not target.DebuffPresent(colossus_smash) and SpellCooldown(bloodthirst) >=2 and target.HealthPercent() >=20 Spell(bladestorm)
}
AddIcon mastery=1 help=cd
{
	if {{target.DebuffRemains(colossus_smash) >=5 or SpellCooldown(colossus_smash) <=4 } and {{not TalentPoints(avatar_talent) or not ArmorSetParts(T14 more 4) } and {{target.HealthPercent() <20 or target.DeadIn() >315 or {target.DeadIn() >165 and ArmorSetParts(T14 more 4) } } } or {TalentPoints(avatar_talent) and ArmorSetParts(T14 more 4) and BuffPresent(avatar) } } } or target.DeadIn() <=18 Spell(recklessness)
	if TalentPoints(avatar_talent) and {{{SpellCooldown(recklessness) >=180 or BuffPresent(recklessness) } or {target.HealthPercent() >=20 and target.DeadIn() >195 } or {target.HealthPercent() <20 and ArmorSetParts(T14 more 4) } } or target.DeadIn() <=20 } Spell(avatar)
}
AddIcon mastery=2 help=main
{
	if not InCombat() 
	{
		unless Stance(1) Spell(battle_stance)
	}
	if not {target.HealthPercent() <20 and target.DebuffPresent(colossus_smash) and Rage() >=30 } Spell(bloodthirst)
	if BuffPresent(bloodsurge) and target.HealthPercent() >=20 and SpellCooldown(bloodthirst) <=1 Spell(wild_strike)
	if not {target.HealthPercent() <20 and target.DebuffPresent(colossus_smash) and Rage() >=30 } and SpellCooldown(bloodthirst) <=1 if CheckBoxOn(showwait) Texture(Spell_nature_timestop) 
	Spell(colossus_smash)
	if target.HealthPercent(less 20) Spell(execute)
	if TalentPoints(storm_bolt_talent) Spell(storm_bolt)
	if BuffPresent(raging_blow_aura) Spell(raging_blow)
	if BuffPresent(bloodsurge) and target.HealthPercent() >=20 Spell(wild_strike)
	Spell(heroic_throw)
	if Rage() <70 and not target.DebuffPresent(colossus_smash) Spell(battle_shout)
	if target.DebuffPresent(colossus_smash) and target.HealthPercent() >=20 Spell(wild_strike)
	if TalentPoints(impending_victory_talent) and target.HealthPercent() >=20 Spell(impending_victory)
	if SpellCooldown(colossus_smash) >=1 and Rage() >=60 and target.HealthPercent() >=20 Spell(wild_strike)
	if Rage() <70 Spell(battle_shout)
}
AddIcon mastery=2 help=offgcd
{
	if TalentPoints(bloodbath_talent) and {{{SpellCooldown(recklessness) >=10 or BuffPresent(recklessness) } or {target.HealthPercent() >=20 and {target.DeadIn() <=165 or {target.DeadIn() <=315 and not ArmorSetParts(T14 more 4) } } and target.DeadIn() >75 } } or target.DeadIn() <=19 } Spell(bloodbath)
	if not {BuffPresent(enrage) or {BuffPresent(raging_blow_aura) ==2 and target.HealthPercent() >=20 } } Spell(berserker_rage)
	if target.DebuffPresent(colossus_smash) if CheckBoxOn(heroic_leap_check) Spell(heroic_leap)
	if Rage() >=40 Spell(deadly_calm)
	if {{{target.DebuffPresent(colossus_smash) and Rage() >=40 } or {BuffPresent(deadly_calm) and Rage() >=30 } } and target.HealthPercent() >=20 } or Rage() >=110 Spell(heroic_strike)
}
AddIcon mastery=2 help=aoe
{
	if TalentPoints(shockwave_talent) Spell(shockwave)
	if TalentPoints(dragon_roar_talent) Spell(dragon_roar)
	if TalentPoints(bladestorm_talent) and SpellCooldown(colossus_smash) >=5 and not target.DebuffPresent(colossus_smash) and SpellCooldown(bloodthirst) >=2 and target.HealthPercent() >=20 Spell(bladestorm)
}
AddIcon mastery=2 help=cd
{
	if {{target.DebuffRemains(colossus_smash) >=5 or SpellCooldown(colossus_smash) <=4 } and {{not TalentPoints(avatar_talent) or not ArmorSetParts(T14 more 4) } and {{target.HealthPercent() <20 or target.DeadIn() >315 or {target.DeadIn() >165 and ArmorSetParts(T14 more 4) } } } or {TalentPoints(avatar_talent) and ArmorSetParts(T14 more 4) and BuffPresent(avatar) } } } or target.DeadIn() <=18 Spell(recklessness)
	if TalentPoints(avatar_talent) and {{{SpellCooldown(recklessness) >=180 or BuffPresent(recklessness) } or {target.HealthPercent() >=20 and target.DeadIn() >195 } or {target.HealthPercent() <20 and ArmorSetParts(T14 more 4) } } or target.DeadIn() <=20 } Spell(avatar)
}
AddIcon mastery=3 help=main
{
	if not InCombat() 
	{
		unless Stance(3) Spell(defensive_stance)
	}
	if Rage() <85 Spell(shield_slam)
	if Rage() <90 Spell(revenge)
	if BuffExpires(weakened_blows) Spell(thunder_clap)
	if Rage() <70 Spell(battle_shout)
	Spell(devastate)
}
AddIcon mastery=3 help=offgcd
{
	Spell(berserker_rage)
	Spell(shield_block)
	if BuffExpires(shield_barrier) and Rage() >80 Spell(shield_barrier)
	Spell(demoralizing_shout)
	if BuffPresent(ultimatum) Spell(heroic_strike)
}
AddIcon mastery=3 help=cd
{
	if TalentPoints(avatar_talent) Spell(avatar)
	if BuffExpires(shield_block) Spell(shield_wall)
}
]]