local __addonName, __addon = ...
__addon.require(__addonName, __addon, "ovale_rogue", { "../Scripts" }, function(__exports, __Scripts)
do
    local name = "simulationcraft_rogue_assassination_t19p"
    local desc = "[7.0] SimulationCraft: Rogue_Assassination_T19P"
    local code = [[
# Based on SimulationCraft profile "Rogue_Assassination_T19P".
#	class=rogue
#	spec=assassination
#	talents=1210111

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_rogue_spells)


AddFunction energy_regen_combined
{
	EnergyRegenRate() + { DebuffCountOnAny(rupture_debuff) + DebuffCountOnAny(garrote_debuff) + Talent(internal_bleeding_talent) * DebuffCountOnAny(internal_bleeding_debuff) } * { 7 + TalentPoints(venom_rush_talent) * 3 } / 2
}

AddFunction energy_time_to_max_combined
{
	EnergyDeficit() / energy_regen_combined()
}

AddCheckBox(opt_interrupt L(interrupt) default specialization=assassination)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=assassination)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=assassination)
AddCheckBox(opt_vanish SpellName(vanish) default specialization=assassination)

AddFunction AssassinationInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
	{
		if target.InRange(kick) and target.IsInterruptible() Spell(kick)
		if target.InRange(cheap_shot) and not target.Classification(worldboss) Spell(cheap_shot)
		if target.InRange(kidney_shot) and not target.Classification(worldboss) and ComboPoints() >= 1 Spell(kidney_shot)
		if target.Distance(less 8) and target.IsInterruptible() Spell(arcane_torrent_energy)
		if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
	}
}

AddFunction AssassinationUseItemActions
{
	Item(Trinket0Slot text=13 usable=1)
	Item(Trinket1Slot text=14 usable=1)
}

AddFunction AssassinationGetInMeleeRange
{
	if CheckBoxOn(opt_melee_range) and not target.InRange(kick)
	{
		Spell(shadowstep)
		Texture(misc_arrowlup help=L(not_in_melee_range))
	}
}

### actions.default

AddFunction AssassinationDefaultMainActions
{
	#variable,name=energy_regen_combined,value=energy.regen+poisoned_bleeds*(7+talent.venom_rush.enabled*3)%2
	#variable,name=energy_time_to_max_combined,value=energy.deficit%variable.energy_regen_combined
	#call_action_list,name=cds
	AssassinationCdsMainActions()

	unless AssassinationCdsMainPostConditions()
	{
		#call_action_list,name=maintain
		AssassinationMaintainMainActions()

		unless AssassinationMaintainMainPostConditions()
		{
			#call_action_list,name=finish,if=(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)&(!dot.rupture.refreshable|(dot.rupture.exsanguinated&dot.rupture.remains>=3.5)|target.time_to_die-dot.rupture.remains<=6)&active_dot.rupture>=spell_targets.rupture
			if { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies() AssassinationFinishMainActions()

			unless { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies() and AssassinationFinishMainPostConditions()
			{
				#call_action_list,name=build,if=combo_points.deficit>1|energy.deficit<=25+variable.energy_regen_combined
				if ComboPointsDeficit() > 1 or EnergyDeficit() <= 25 + energy_regen_combined() AssassinationBuildMainActions()
			}
		}
	}
}

AddFunction AssassinationDefaultMainPostConditions
{
	AssassinationCdsMainPostConditions() or AssassinationMaintainMainPostConditions() or { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies() and AssassinationFinishMainPostConditions() or { ComboPointsDeficit() > 1 or EnergyDeficit() <= 25 + energy_regen_combined() } and AssassinationBuildMainPostConditions()
}

AddFunction AssassinationDefaultShortCdActions
{
	#variable,name=energy_regen_combined,value=energy.regen+poisoned_bleeds*(7+talent.venom_rush.enabled*3)%2
	#variable,name=energy_time_to_max_combined,value=energy.deficit%variable.energy_regen_combined
	#call_action_list,name=cds
	AssassinationCdsShortCdActions()

	unless AssassinationCdsShortCdPostConditions()
	{
		#call_action_list,name=maintain
		AssassinationMaintainShortCdActions()

		unless AssassinationMaintainShortCdPostConditions()
		{
			#call_action_list,name=finish,if=(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)&(!dot.rupture.refreshable|(dot.rupture.exsanguinated&dot.rupture.remains>=3.5)|target.time_to_die-dot.rupture.remains<=6)&active_dot.rupture>=spell_targets.rupture
			if { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies() AssassinationFinishShortCdActions()

			unless { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies() and AssassinationFinishShortCdPostConditions()
			{
				#call_action_list,name=build,if=combo_points.deficit>1|energy.deficit<=25+variable.energy_regen_combined
				if ComboPointsDeficit() > 1 or EnergyDeficit() <= 25 + energy_regen_combined() AssassinationBuildShortCdActions()
			}
		}
	}
}

AddFunction AssassinationDefaultShortCdPostConditions
{
	AssassinationCdsShortCdPostConditions() or AssassinationMaintainShortCdPostConditions() or { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies() and AssassinationFinishShortCdPostConditions() or { ComboPointsDeficit() > 1 or EnergyDeficit() <= 25 + energy_regen_combined() } and AssassinationBuildShortCdPostConditions()
}

AddFunction AssassinationDefaultCdActions
{
	#kick
	AssassinationInterruptActions()
	#variable,name=energy_regen_combined,value=energy.regen+poisoned_bleeds*(7+talent.venom_rush.enabled*3)%2
	#variable,name=energy_time_to_max_combined,value=energy.deficit%variable.energy_regen_combined
	#call_action_list,name=cds
	AssassinationCdsCdActions()

	unless AssassinationCdsCdPostConditions()
	{
		#call_action_list,name=maintain
		AssassinationMaintainCdActions()

		unless AssassinationMaintainCdPostConditions()
		{
			#call_action_list,name=finish,if=(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)&(!dot.rupture.refreshable|(dot.rupture.exsanguinated&dot.rupture.remains>=3.5)|target.time_to_die-dot.rupture.remains<=6)&active_dot.rupture>=spell_targets.rupture
			if { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies() AssassinationFinishCdActions()

			unless { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies() and AssassinationFinishCdPostConditions()
			{
				#call_action_list,name=build,if=combo_points.deficit>1|energy.deficit<=25+variable.energy_regen_combined
				if ComboPointsDeficit() > 1 or EnergyDeficit() <= 25 + energy_regen_combined() AssassinationBuildCdActions()
			}
		}
	}
}

AddFunction AssassinationDefaultCdPostConditions
{
	AssassinationCdsCdPostConditions() or AssassinationMaintainCdPostConditions() or { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies() and AssassinationFinishCdPostConditions() or { ComboPointsDeficit() > 1 or EnergyDeficit() <= 25 + energy_regen_combined() } and AssassinationBuildCdPostConditions()
}

### actions.build

AddFunction AssassinationBuildMainActions
{
	#hemorrhage,if=refreshable
	if target.Refreshable(hemorrhage_debuff) Spell(hemorrhage)
	#hemorrhage,cycle_targets=1,if=refreshable&dot.rupture.ticking&spell_targets.fan_of_knives<2+equipped.insignia_of_ravenholdt
	if target.Refreshable(hemorrhage_debuff) and target.DebuffPresent(rupture_debuff) and Enemies() < 2 + HasEquippedItem(insignia_of_ravenholdt) Spell(hemorrhage)
	#fan_of_knives,if=spell_targets>=2+equipped.insignia_of_ravenholdt|buff.the_dreadlords_deceit.stack>=29
	if Enemies() >= 2 + HasEquippedItem(insignia_of_ravenholdt) or BuffStacks(the_dreadlords_deceit_buff) >= 29 Spell(fan_of_knives)
	#mutilate,cycle_targets=1,if=dot.deadly_poison_dot.refreshable
	if target.DebuffRefreshable(deadly_poison_dot_debuff) Spell(mutilate)
	#mutilate
	Spell(mutilate)
}

AddFunction AssassinationBuildMainPostConditions
{
}

AddFunction AssassinationBuildShortCdActions
{
}

AddFunction AssassinationBuildShortCdPostConditions
{
	target.Refreshable(hemorrhage_debuff) and Spell(hemorrhage) or target.Refreshable(hemorrhage_debuff) and target.DebuffPresent(rupture_debuff) and Enemies() < 2 + HasEquippedItem(insignia_of_ravenholdt) and Spell(hemorrhage) or { Enemies() >= 2 + HasEquippedItem(insignia_of_ravenholdt) or BuffStacks(the_dreadlords_deceit_buff) >= 29 } and Spell(fan_of_knives) or target.DebuffRefreshable(deadly_poison_dot_debuff) and Spell(mutilate) or Spell(mutilate)
}

AddFunction AssassinationBuildCdActions
{
}

AddFunction AssassinationBuildCdPostConditions
{
	target.Refreshable(hemorrhage_debuff) and Spell(hemorrhage) or target.Refreshable(hemorrhage_debuff) and target.DebuffPresent(rupture_debuff) and Enemies() < 2 + HasEquippedItem(insignia_of_ravenholdt) and Spell(hemorrhage) or { Enemies() >= 2 + HasEquippedItem(insignia_of_ravenholdt) or BuffStacks(the_dreadlords_deceit_buff) >= 29 } and Spell(fan_of_knives) or target.DebuffRefreshable(deadly_poison_dot_debuff) and Spell(mutilate) or Spell(mutilate)
}

### actions.cds

AddFunction AssassinationCdsMainActions
{
	#exsanguinate,if=prev_gcd.1.rupture&dot.rupture.remains>4+4*cp_max_spend&!stealthed.rogue|!dot.garrote.pmultiplier<=1&!cooldown.vanish.up&buff.subterfuge.up
	if PreviousGCDSpell(rupture) and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and not Stealthed() or not target.DebuffPersistentMultiplier(garrote_debuff) <= 1 and not { not SpellCooldown(vanish) > 0 } and BuffPresent(subterfuge_buff) Spell(exsanguinate)
}

AddFunction AssassinationCdsMainPostConditions
{
}

AddFunction AssassinationCdsShortCdActions
{
	#marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit*1.5|(raid_event.adds.in>40&combo_points.deficit>=cp_max_spend)
	if target.TimeToDie() < ComboPointsDeficit() * 1.5 or 600 > 40 and ComboPointsDeficit() >= MaxComboPoints() Spell(marked_for_death)
	#vanish,if=talent.nightstalker.enabled&combo_points>=cp_max_spend&!talent.exsanguinate.enabled&mantle_duration=0&((equipped.mantle_of_the_master_assassin&set_bonus.tier19_4pc)|((!equipped.mantle_of_the_master_assassin|!set_bonus.tier19_4pc)&(dot.rupture.refreshable|debuff.vendetta.up)))
	if Talent(nightstalker_talent) and ComboPoints() >= MaxComboPoints() and not Talent(exsanguinate_talent) and BuffRemaining(master_assassins_initiative) == 0 and { HasEquippedItem(mantle_of_the_master_assassin) and ArmorSetBonus(T19 4) or { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } and { target.DebuffRefreshable(rupture_debuff) or target.DebuffPresent(vendetta_debuff) } } and CheckBoxOn(opt_vanish) Spell(vanish)
	#vanish,if=talent.nightstalker.enabled&combo_points>=cp_max_spend&talent.exsanguinate.enabled&cooldown.exsanguinate.remains<1&(dot.rupture.ticking|time>10)
	if Talent(nightstalker_talent) and ComboPoints() >= MaxComboPoints() and Talent(exsanguinate_talent) and SpellCooldown(exsanguinate) < 1 and { target.DebuffPresent(rupture_debuff) or TimeInCombat() > 10 } and CheckBoxOn(opt_vanish) Spell(vanish)
	#vanish,if=talent.subterfuge.enabled&equipped.mantle_of_the_master_assassin&(debuff.vendetta.up|target.time_to_die<10)&mantle_duration=0
	if Talent(subterfuge_talent) and HasEquippedItem(mantle_of_the_master_assassin) and { target.DebuffPresent(vendetta_debuff) or target.TimeToDie() < 10 } and BuffRemaining(master_assassins_initiative) == 0 and CheckBoxOn(opt_vanish) Spell(vanish)
	#vanish,if=talent.subterfuge.enabled&!equipped.mantle_of_the_master_assassin&!stealthed.rogue&dot.garrote.refreshable&((spell_targets.fan_of_knives<=3&combo_points.deficit>=1+spell_targets.fan_of_knives)|(spell_targets.fan_of_knives>=4&combo_points.deficit>=4))
	if Talent(subterfuge_talent) and not HasEquippedItem(mantle_of_the_master_assassin) and not Stealthed() and target.DebuffRefreshable(garrote_debuff) and { Enemies() <= 3 and ComboPointsDeficit() >= 1 + Enemies() or Enemies() >= 4 and ComboPointsDeficit() >= 4 } and CheckBoxOn(opt_vanish) Spell(vanish)
	#vanish,if=talent.shadow_focus.enabled&variable.energy_time_to_max_combined>=2&combo_points.deficit>=4
	if Talent(shadow_focus_talent) and energy_time_to_max_combined() >= 2 and ComboPointsDeficit() >= 4 and CheckBoxOn(opt_vanish) Spell(vanish)
}

AddFunction AssassinationCdsShortCdPostConditions
{
	{ PreviousGCDSpell(rupture) and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and not Stealthed() or not target.DebuffPersistentMultiplier(garrote_debuff) <= 1 and not { not SpellCooldown(vanish) > 0 } and BuffPresent(subterfuge_buff) } and Spell(exsanguinate)
}

AddFunction AssassinationCdsCdActions
{
	#potion,if=buff.bloodlust.react|target.time_to_die<=60|debuff.vendetta.up&cooldown.vanish.remains<5
	if { BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 60 or target.DebuffPresent(vendetta_debuff) and SpellCooldown(vanish) < 5 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(old_war_potion usable=1)
	#use_item,name=draught_of_souls,if=energy.deficit>=35+variable.energy_regen_combined*2&(!equipped.mantle_of_the_master_assassin|cooldown.vanish.remains>8)
	if EnergyDeficit() >= 35 + energy_regen_combined() * 2 and { not HasEquippedItem(mantle_of_the_master_assassin) or SpellCooldown(vanish) > 8 } AssassinationUseItemActions()
	#use_item,name=draught_of_souls,if=mantle_duration>0&mantle_duration<3.5&dot.kingsbane.ticking
	if BuffRemaining(master_assassins_initiative) > 0 and BuffRemaining(master_assassins_initiative) < 3.5 and target.DebuffPresent(kingsbane_debuff) AssassinationUseItemActions()
	#use_item,name=specter_of_betrayal,if=buff.bloodlust.react|target.time_to_die<=20|debuff.vendetta.up
	if BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 20 or target.DebuffPresent(vendetta_debuff) AssassinationUseItemActions()
	#blood_fury,if=debuff.vendetta.up
	if target.DebuffPresent(vendetta_debuff) Spell(blood_fury_ap)
	#berserking,if=debuff.vendetta.up
	if target.DebuffPresent(vendetta_debuff) Spell(berserking)
	#arcane_torrent,if=dot.kingsbane.ticking&!buff.envenom.up&energy.deficit>=15+variable.energy_regen_combined*gcd.remains*1.1
	if target.DebuffPresent(kingsbane_debuff) and not BuffPresent(envenom_buff) and EnergyDeficit() >= 15 + energy_regen_combined() * GCDRemaining() * 1.1 Spell(arcane_torrent_energy)
	#vendetta,if=!artifact.urge_to_kill.enabled|energy.deficit>=60+variable.energy_regen_combined
	if not HasArtifactTrait(urge_to_kill) or EnergyDeficit() >= 60 + energy_regen_combined() Spell(vendetta)
}

AddFunction AssassinationCdsCdPostConditions
{
	{ PreviousGCDSpell(rupture) and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and not Stealthed() or not target.DebuffPersistentMultiplier(garrote_debuff) <= 1 and not { not SpellCooldown(vanish) > 0 } and BuffPresent(subterfuge_buff) } and Spell(exsanguinate)
}

### actions.finish

AddFunction AssassinationFinishMainActions
{
	#death_from_above,if=combo_points>=5
	if ComboPoints() >= 5 Spell(death_from_above)
	#envenom,if=combo_points>=4&(debuff.vendetta.up|mantle_duration>=gcd.remains+0.2|debuff.surge_of_toxins.remains<gcd.remains+0.2|energy.deficit<=25+variable.energy_regen_combined)
	if ComboPoints() >= 4 and { target.DebuffPresent(vendetta_debuff) or BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 or target.DebuffRemaining(surge_of_toxins_debuff) < GCDRemaining() + 0.2 or EnergyDeficit() <= 25 + energy_regen_combined() } Spell(envenom)
	#envenom,if=talent.elaborate_planning.enabled&combo_points>=3+!talent.exsanguinate.enabled&buff.elaborate_planning.remains<gcd.remains+0.2
	if Talent(elaborate_planning_talent) and ComboPoints() >= 3 + Talent(exsanguinate_talent no) and BuffRemaining(elaborate_planning_buff) < GCDRemaining() + 0.2 Spell(envenom)
}

AddFunction AssassinationFinishMainPostConditions
{
}

AddFunction AssassinationFinishShortCdActions
{
}

AddFunction AssassinationFinishShortCdPostConditions
{
	ComboPoints() >= 5 and Spell(death_from_above) or ComboPoints() >= 4 and { target.DebuffPresent(vendetta_debuff) or BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 or target.DebuffRemaining(surge_of_toxins_debuff) < GCDRemaining() + 0.2 or EnergyDeficit() <= 25 + energy_regen_combined() } and Spell(envenom) or Talent(elaborate_planning_talent) and ComboPoints() >= 3 + Talent(exsanguinate_talent no) and BuffRemaining(elaborate_planning_buff) < GCDRemaining() + 0.2 and Spell(envenom)
}

AddFunction AssassinationFinishCdActions
{
}

AddFunction AssassinationFinishCdPostConditions
{
	ComboPoints() >= 5 and Spell(death_from_above) or ComboPoints() >= 4 and { target.DebuffPresent(vendetta_debuff) or BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 or target.DebuffRemaining(surge_of_toxins_debuff) < GCDRemaining() + 0.2 or EnergyDeficit() <= 25 + energy_regen_combined() } and Spell(envenom) or Talent(elaborate_planning_talent) and ComboPoints() >= 3 + Talent(exsanguinate_talent no) and BuffRemaining(elaborate_planning_buff) < GCDRemaining() + 0.2 and Spell(envenom)
}

### actions.kb

AddFunction AssassinationKbMainActions
{
	#kingsbane,if=artifact.sinister_circulation.enabled&!(equipped.duskwalkers_footpads&equipped.convergence_of_fates&artifact.master_assassin.rank>=6)&(time>25|!equipped.mantle_of_the_master_assassin|(debuff.vendetta.up&debuff.surge_of_toxins.up))&(talent.subterfuge.enabled|!stealthed.rogue|(talent.nightstalker.enabled&(!equipped.mantle_of_the_master_assassin|!set_bonus.tier19_4pc)))
	if HasArtifactTrait(sinister_circulation) and not { HasEquippedItem(duskwalkers_footpads) and HasEquippedItem(convergence_of_fates) and ArtifactTraitRank(master_assassin) >= 6 } and { TimeInCombat() > 25 or not HasEquippedItem(mantle_of_the_master_assassin) or target.DebuffPresent(vendetta_debuff) and target.DebuffPresent(surge_of_toxins_debuff) } and { Talent(subterfuge_talent) or not Stealthed() or Talent(nightstalker_talent) and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } } Spell(kingsbane)
	#kingsbane,if=!talent.exsanguinate.enabled&buff.envenom.up&((debuff.vendetta.up&debuff.surge_of_toxins.up)|cooldown.vendetta.remains<=5.8|cooldown.vendetta.remains>=10)
	if not Talent(exsanguinate_talent) and BuffPresent(envenom_buff) and { target.DebuffPresent(vendetta_debuff) and target.DebuffPresent(surge_of_toxins_debuff) or SpellCooldown(vendetta) <= 5.8 or SpellCooldown(vendetta) >= 10 } Spell(kingsbane)
	#kingsbane,if=talent.exsanguinate.enabled&dot.rupture.exsanguinated
	if Talent(exsanguinate_talent) and target.DebuffRemaining(rupture_debuff_exsanguinated) Spell(kingsbane)
}

AddFunction AssassinationKbMainPostConditions
{
}

AddFunction AssassinationKbShortCdActions
{
}

AddFunction AssassinationKbShortCdPostConditions
{
	HasArtifactTrait(sinister_circulation) and not { HasEquippedItem(duskwalkers_footpads) and HasEquippedItem(convergence_of_fates) and ArtifactTraitRank(master_assassin) >= 6 } and { TimeInCombat() > 25 or not HasEquippedItem(mantle_of_the_master_assassin) or target.DebuffPresent(vendetta_debuff) and target.DebuffPresent(surge_of_toxins_debuff) } and { Talent(subterfuge_talent) or not Stealthed() or Talent(nightstalker_talent) and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } } and Spell(kingsbane) or not Talent(exsanguinate_talent) and BuffPresent(envenom_buff) and { target.DebuffPresent(vendetta_debuff) and target.DebuffPresent(surge_of_toxins_debuff) or SpellCooldown(vendetta) <= 5.8 or SpellCooldown(vendetta) >= 10 } and Spell(kingsbane) or Talent(exsanguinate_talent) and target.DebuffRemaining(rupture_debuff_exsanguinated) and Spell(kingsbane)
}

AddFunction AssassinationKbCdActions
{
}

AddFunction AssassinationKbCdPostConditions
{
	HasArtifactTrait(sinister_circulation) and not { HasEquippedItem(duskwalkers_footpads) and HasEquippedItem(convergence_of_fates) and ArtifactTraitRank(master_assassin) >= 6 } and { TimeInCombat() > 25 or not HasEquippedItem(mantle_of_the_master_assassin) or target.DebuffPresent(vendetta_debuff) and target.DebuffPresent(surge_of_toxins_debuff) } and { Talent(subterfuge_talent) or not Stealthed() or Talent(nightstalker_talent) and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } } and Spell(kingsbane) or not Talent(exsanguinate_talent) and BuffPresent(envenom_buff) and { target.DebuffPresent(vendetta_debuff) and target.DebuffPresent(surge_of_toxins_debuff) or SpellCooldown(vendetta) <= 5.8 or SpellCooldown(vendetta) >= 10 } and Spell(kingsbane) or Talent(exsanguinate_talent) and target.DebuffRemaining(rupture_debuff_exsanguinated) and Spell(kingsbane)
}

### actions.maintain

AddFunction AssassinationMaintainMainActions
{
	#rupture,if=talent.nightstalker.enabled&stealthed.rogue&(!equipped.mantle_of_the_master_assassin|!set_bonus.tier19_4pc)&(talent.exsanguinate.enabled|target.time_to_die-remains>4)
	if Talent(nightstalker_talent) and Stealthed() and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } and { Talent(exsanguinate_talent) or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 } Spell(rupture)
	#garrote,cycle_targets=1,if=talent.subterfuge.enabled&stealthed.rogue&combo_points.deficit>=1&set_bonus.tier20_4pc&((dot.garrote.remains<=13&!debuff.toxic_blade.up)|pmultiplier<=1)&!exsanguinated
	if Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and ArmorSetBonus(T20 4) and { target.DebuffRemaining(garrote_debuff) <= 13 and not target.DebuffPresent(toxic_blade_debuff) or PersistentMultiplier(garrote_debuff) <= 1 } and not target.DebuffPresent(exsanguinated) Spell(garrote)
	#garrote,cycle_targets=1,if=talent.subterfuge.enabled&stealthed.rogue&combo_points.deficit>=1&!set_bonus.tier20_4pc&refreshable&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>2
	if Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 Spell(garrote)
	#garrote,cycle_targets=1,if=talent.subterfuge.enabled&stealthed.rogue&combo_points.deficit>=1&!set_bonus.tier20_4pc&remains<=10&pmultiplier<=1&!exsanguinated&target.time_to_die-remains>2
	if Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) <= 10 and PersistentMultiplier(garrote_debuff) <= 1 and not target.DebuffPresent(exsanguinated) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 Spell(garrote)
	#rupture,if=!talent.exsanguinate.enabled&combo_points>=3&!ticking&mantle_duration<=gcd.remains+0.2&target.time_to_die>6
	if not Talent(exsanguinate_talent) and ComboPoints() >= 3 and not target.DebuffPresent(rupture_debuff) and BuffRemaining(master_assassins_initiative) <= GCDRemaining() + 0.2 and target.TimeToDie() > 6 Spell(rupture)
	#rupture,if=talent.exsanguinate.enabled&((combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1)|(!ticking&(time>10|combo_points>=2+artifact.urge_to_kill.enabled)))
	if Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } Spell(rupture)
	#rupture,cycle_targets=1,if=combo_points>=4&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>6
	if ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 Spell(rupture)
	#call_action_list,name=kb,if=combo_points.deficit>=1+(mantle_duration>=gcd.remains+0.2)
	if ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 } AssassinationKbMainActions()

	unless ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 } and AssassinationKbMainPostConditions()
	{
		#pool_resource,for_next=1
		#garrote,cycle_targets=1,if=(!talent.subterfuge.enabled|!(cooldown.vanish.up&cooldown.vendetta.remains<=4))&combo_points.deficit>=1&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>4
		if { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 Spell(garrote)
		unless { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and SpellUsable(garrote) and SpellCooldown(garrote) < TimeToEnergyFor(garrote)
		{
			#toxic_blade,if=combo_points.deficit>=1+(mantle_duration>=gcd.remains+0.2)&dot.rupture.remains>8
			if ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 } and target.DebuffRemaining(rupture_debuff) > 8 Spell(toxic_blade)
		}
	}
}

AddFunction AssassinationMaintainMainPostConditions
{
	ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 } and AssassinationKbMainPostConditions()
}

AddFunction AssassinationMaintainShortCdActions
{
	unless Talent(nightstalker_talent) and Stealthed() and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } and { Talent(exsanguinate_talent) or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 } and Spell(rupture) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and ArmorSetBonus(T20 4) and { target.DebuffRemaining(garrote_debuff) <= 13 and not target.DebuffPresent(toxic_blade_debuff) or PersistentMultiplier(garrote_debuff) <= 1 } and not target.DebuffPresent(exsanguinated) and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) <= 10 and PersistentMultiplier(garrote_debuff) <= 1 and not target.DebuffPresent(exsanguinated) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or not Talent(exsanguinate_talent) and ComboPoints() >= 3 and not target.DebuffPresent(rupture_debuff) and BuffRemaining(master_assassins_initiative) <= GCDRemaining() + 0.2 and target.TimeToDie() > 6 and Spell(rupture) or Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } and Spell(rupture) or ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 and Spell(rupture)
	{
		#call_action_list,name=kb,if=combo_points.deficit>=1+(mantle_duration>=gcd.remains+0.2)
		if ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 } AssassinationKbShortCdActions()
	}
}

AddFunction AssassinationMaintainShortCdPostConditions
{
	Talent(nightstalker_talent) and Stealthed() and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } and { Talent(exsanguinate_talent) or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 } and Spell(rupture) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and ArmorSetBonus(T20 4) and { target.DebuffRemaining(garrote_debuff) <= 13 and not target.DebuffPresent(toxic_blade_debuff) or PersistentMultiplier(garrote_debuff) <= 1 } and not target.DebuffPresent(exsanguinated) and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) <= 10 and PersistentMultiplier(garrote_debuff) <= 1 and not target.DebuffPresent(exsanguinated) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or not Talent(exsanguinate_talent) and ComboPoints() >= 3 and not target.DebuffPresent(rupture_debuff) and BuffRemaining(master_assassins_initiative) <= GCDRemaining() + 0.2 and target.TimeToDie() > 6 and Spell(rupture) or Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } and Spell(rupture) or ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 and Spell(rupture) or ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 } and AssassinationKbShortCdPostConditions() or { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and Spell(garrote) or not { { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and SpellUsable(garrote) and SpellCooldown(garrote) < TimeToEnergyFor(garrote) } and ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 } and target.DebuffRemaining(rupture_debuff) > 8 and Spell(toxic_blade)
}

AddFunction AssassinationMaintainCdActions
{
	unless Talent(nightstalker_talent) and Stealthed() and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } and { Talent(exsanguinate_talent) or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 } and Spell(rupture) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and ArmorSetBonus(T20 4) and { target.DebuffRemaining(garrote_debuff) <= 13 and not target.DebuffPresent(toxic_blade_debuff) or PersistentMultiplier(garrote_debuff) <= 1 } and not target.DebuffPresent(exsanguinated) and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) <= 10 and PersistentMultiplier(garrote_debuff) <= 1 and not target.DebuffPresent(exsanguinated) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or not Talent(exsanguinate_talent) and ComboPoints() >= 3 and not target.DebuffPresent(rupture_debuff) and BuffRemaining(master_assassins_initiative) <= GCDRemaining() + 0.2 and target.TimeToDie() > 6 and Spell(rupture) or Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } and Spell(rupture) or ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 and Spell(rupture)
	{
		#call_action_list,name=kb,if=combo_points.deficit>=1+(mantle_duration>=gcd.remains+0.2)
		if ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 } AssassinationKbCdActions()
	}
}

AddFunction AssassinationMaintainCdPostConditions
{
	Talent(nightstalker_talent) and Stealthed() and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } and { Talent(exsanguinate_talent) or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 } and Spell(rupture) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and ArmorSetBonus(T20 4) and { target.DebuffRemaining(garrote_debuff) <= 13 and not target.DebuffPresent(toxic_blade_debuff) or PersistentMultiplier(garrote_debuff) <= 1 } and not target.DebuffPresent(exsanguinated) and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) <= 10 and PersistentMultiplier(garrote_debuff) <= 1 and not target.DebuffPresent(exsanguinated) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or not Talent(exsanguinate_talent) and ComboPoints() >= 3 and not target.DebuffPresent(rupture_debuff) and BuffRemaining(master_assassins_initiative) <= GCDRemaining() + 0.2 and target.TimeToDie() > 6 and Spell(rupture) or Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } and Spell(rupture) or ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 and Spell(rupture) or ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 } and AssassinationKbCdPostConditions() or { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and Spell(garrote) or not { { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and SpellUsable(garrote) and SpellCooldown(garrote) < TimeToEnergyFor(garrote) } and ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 } and target.DebuffRemaining(rupture_debuff) > 8 and Spell(toxic_blade)
}

### actions.precombat

AddFunction AssassinationPrecombatMainActions
{
	#flask
	#augmentation
	#food
	#snapshot_stats
	#apply_poison
	#stealth
	Spell(stealth)
}

AddFunction AssassinationPrecombatMainPostConditions
{
}

AddFunction AssassinationPrecombatShortCdActions
{
	unless Spell(stealth)
	{
		#marked_for_death,if=raid_event.adds.in>40
		if 600 > 40 Spell(marked_for_death)
	}
}

AddFunction AssassinationPrecombatShortCdPostConditions
{
	Spell(stealth)
}

AddFunction AssassinationPrecombatCdActions
{
	unless Spell(stealth)
	{
		#potion
		if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(old_war_potion usable=1)
	}
}

AddFunction AssassinationPrecombatCdPostConditions
{
	Spell(stealth)
}

### Assassination icons.

AddCheckBox(opt_rogue_assassination_aoe L(AOE) default specialization=assassination)

AddIcon checkbox=!opt_rogue_assassination_aoe enemies=1 help=shortcd specialization=assassination
{
	if not InCombat() AssassinationPrecombatShortCdActions()
	unless not InCombat() and AssassinationPrecombatShortCdPostConditions()
	{
		AssassinationDefaultShortCdActions()
	}
}

AddIcon checkbox=opt_rogue_assassination_aoe help=shortcd specialization=assassination
{
	if not InCombat() AssassinationPrecombatShortCdActions()
	unless not InCombat() and AssassinationPrecombatShortCdPostConditions()
	{
		AssassinationDefaultShortCdActions()
	}
}

AddIcon enemies=1 help=main specialization=assassination
{
	if not InCombat() AssassinationPrecombatMainActions()
	unless not InCombat() and AssassinationPrecombatMainPostConditions()
	{
		AssassinationDefaultMainActions()
	}
}

AddIcon checkbox=opt_rogue_assassination_aoe help=aoe specialization=assassination
{
	if not InCombat() AssassinationPrecombatMainActions()
	unless not InCombat() and AssassinationPrecombatMainPostConditions()
	{
		AssassinationDefaultMainActions()
	}
}

AddIcon checkbox=!opt_rogue_assassination_aoe enemies=1 help=cd specialization=assassination
{
	if not InCombat() AssassinationPrecombatCdActions()
	unless not InCombat() and AssassinationPrecombatCdPostConditions()
	{
		AssassinationDefaultCdActions()
	}
}

AddIcon checkbox=opt_rogue_assassination_aoe help=cd specialization=assassination
{
	if not InCombat() AssassinationPrecombatCdActions()
	unless not InCombat() and AssassinationPrecombatCdPostConditions()
	{
		AssassinationDefaultCdActions()
	}
}

### Required symbols
# arcane_torrent_energy
# berserking
# blood_fury_ap
# cheap_shot
# convergence_of_fates
# deadly_poison_dot_debuff
# death_from_above
# duskwalkers_footpads
# elaborate_planning_buff
# elaborate_planning_talent
# envenom
# envenom_buff
# exsanguinate
# exsanguinate_talent
# exsanguinated
# fan_of_knives
# garrote
# garrote_debuff
# hemorrhage
# hemorrhage_debuff
# insignia_of_ravenholdt
# internal_bleeding_debuff
# internal_bleeding_talent
# kick
# kidney_shot
# kingsbane
# kingsbane_debuff
# mantle_of_the_master_assassin
# marked_for_death
# master_assassin
# master_assassins_initiative
# mutilate
# nightstalker_talent
# old_war_potion
# quaking_palm
# rupture
# rupture_debuff
# shadow_focus_talent
# shadowstep
# sinister_circulation
# stealth
# subterfuge_buff
# subterfuge_talent
# surge_of_toxins_debuff
# the_dreadlords_deceit_buff
# toxic_blade
# toxic_blade_debuff
# urge_to_kill
# vanish
# vendetta
# vendetta_debuff
# venom_rush_talent
]]
    __Scripts.OvaleScripts:RegisterScript("ROGUE", "assassination", name, desc, code, "script")
end
do
    local name = "simulationcraft_rogue_outlaw_t19p"
    local desc = "[7.0] SimulationCraft: Rogue_Outlaw_T19P"
    local code = [[
# Based on SimulationCraft profile "Rogue_Outlaw_T19P".
#	class=rogue
#	spec=outlaw
#	talents=1310022

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_rogue_spells)


AddFunction stealth_condition
{
	ComboPointsDeficit() >= 2 + 2 * { Talent(ghostly_strike_talent) and not target.DebuffPresent(ghostly_strike_debuff) } + BuffPresent(broadsides_buff) and Energy() > 60 and not BuffPresent(jolly_roger_buff) and not BuffPresent(hidden_blade_buff) and not BuffPresent(curse_of_the_dreadblades_buff)
}

AddFunction ss_useable
{
	Talent(anticipation_talent) and ComboPoints() < 4 or not Talent(anticipation_talent) and { rtb_reroll() and ComboPoints() < 4 + TalentPoints(deeper_stratagem_talent) or not rtb_reroll() and ss_useable_noreroll() }
}

AddFunction ss_useable_noreroll
{
	ComboPoints() < 5 + TalentPoints(deeper_stratagem_talent) - { BuffPresent(broadsides_buff) or BuffPresent(jolly_roger_buff) } - { Talent(alacrity_talent) and BuffStacks(alacrity_buff) <= 4 }
}

AddFunction rtb_reroll
{
	not Talent(slice_and_dice_talent) and BuffCount(roll_the_bones_buff) <= 2 and not BuffCount(roll_the_bones_buff more 5)
}

AddCheckBox(opt_interrupt L(interrupt) default specialization=outlaw)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=outlaw)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=outlaw)
AddCheckBox(opt_blade_flurry SpellName(blade_flurry) default specialization=outlaw)

AddFunction OutlawInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
	{
		if target.InRange(kick) and target.IsInterruptible() Spell(kick)
		if target.InRange(cheap_shot) and not target.Classification(worldboss) Spell(cheap_shot)
		if target.InRange(between_the_eyes) and not target.Classification(worldboss) and ComboPoints() >= 1 Spell(between_the_eyes)
		if target.Distance(less 8) and target.IsInterruptible() Spell(arcane_torrent_energy)
		if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
		if target.InRange(gouge) and not target.Classification(worldboss) Spell(gouge)
	}
}

AddFunction OutlawUseItemActions
{
	Item(Trinket0Slot text=13 usable=1)
	Item(Trinket1Slot text=14 usable=1)
}

AddFunction OutlawGetInMeleeRange
{
	if CheckBoxOn(opt_melee_range) and not target.InRange(kick)
	{
		Spell(shadowstep)
		Texture(misc_arrowlup help=L(not_in_melee_range))
	}
}

### actions.default

AddFunction OutlawDefaultMainActions
{
	#call_action_list,name=bf
	OutlawBfMainActions()

	unless OutlawBfMainPostConditions()
	{
		#call_action_list,name=cds
		OutlawCdsMainActions()

		unless OutlawCdsMainPostConditions()
		{
			#call_action_list,name=stealth,if=stealthed.rogue|cooldown.vanish.up|cooldown.shadowmeld.up
			if Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 OutlawStealthMainActions()

			unless { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthMainPostConditions()
			{
				#death_from_above,if=energy.time_to_max>2&!variable.ss_useable_noreroll
				if TimeToMaxEnergy() > 2 and not ss_useable_noreroll() Spell(death_from_above)
				#slice_and_dice,if=!variable.ss_useable&buff.slice_and_dice.remains<target.time_to_die&buff.slice_and_dice.remains<(1+combo_points)*1.8
				if not ss_useable() and BuffRemaining(slice_and_dice_buff) < target.TimeToDie() and BuffRemaining(slice_and_dice_buff) < { 1 + ComboPoints() } * 1.8 Spell(slice_and_dice)
				#roll_the_bones,if=!variable.ss_useable&buff.roll_the_bones.remains<target.time_to_die&(buff.roll_the_bones.remains<=3|variable.rtb_reroll)
				if not ss_useable() and BuffRemaining(roll_the_bones_buff) < target.TimeToDie() and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } Spell(roll_the_bones)
				#call_action_list,name=build
				OutlawBuildMainActions()

				unless OutlawBuildMainPostConditions()
				{
					#call_action_list,name=finish,if=!variable.ss_useable
					if not ss_useable() OutlawFinishMainActions()

					unless not ss_useable() and OutlawFinishMainPostConditions()
					{
						#gouge,if=talent.dirty_tricks.enabled&combo_points.deficit>=1
						if Talent(dirty_tricks_talent) and ComboPointsDeficit() >= 1 Spell(gouge)
					}
				}
			}
		}
	}
}

AddFunction OutlawDefaultMainPostConditions
{
	OutlawBfMainPostConditions() or OutlawCdsMainPostConditions() or { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthMainPostConditions() or OutlawBuildMainPostConditions() or not ss_useable() and OutlawFinishMainPostConditions()
}

AddFunction OutlawDefaultShortCdActions
{
	#call_action_list,name=bf
	OutlawBfShortCdActions()

	unless OutlawBfShortCdPostConditions()
	{
		#call_action_list,name=cds
		OutlawCdsShortCdActions()

		unless OutlawCdsShortCdPostConditions()
		{
			#call_action_list,name=stealth,if=stealthed.rogue|cooldown.vanish.up|cooldown.shadowmeld.up
			if Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 OutlawStealthShortCdActions()

			unless { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthShortCdPostConditions() or TimeToMaxEnergy() > 2 and not ss_useable_noreroll() and Spell(death_from_above) or not ss_useable() and BuffRemaining(slice_and_dice_buff) < target.TimeToDie() and BuffRemaining(slice_and_dice_buff) < { 1 + ComboPoints() } * 1.8 and Spell(slice_and_dice) or not ss_useable() and BuffRemaining(roll_the_bones_buff) < target.TimeToDie() and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } and Spell(roll_the_bones)
			{
				#call_action_list,name=build
				OutlawBuildShortCdActions()

				unless OutlawBuildShortCdPostConditions()
				{
					#call_action_list,name=finish,if=!variable.ss_useable
					if not ss_useable() OutlawFinishShortCdActions()
				}
			}
		}
	}
}

AddFunction OutlawDefaultShortCdPostConditions
{
	OutlawBfShortCdPostConditions() or OutlawCdsShortCdPostConditions() or { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthShortCdPostConditions() or TimeToMaxEnergy() > 2 and not ss_useable_noreroll() and Spell(death_from_above) or not ss_useable() and BuffRemaining(slice_and_dice_buff) < target.TimeToDie() and BuffRemaining(slice_and_dice_buff) < { 1 + ComboPoints() } * 1.8 and Spell(slice_and_dice) or not ss_useable() and BuffRemaining(roll_the_bones_buff) < target.TimeToDie() and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } and Spell(roll_the_bones) or OutlawBuildShortCdPostConditions() or not ss_useable() and OutlawFinishShortCdPostConditions() or Talent(dirty_tricks_talent) and ComboPointsDeficit() >= 1 and Spell(gouge)
}

AddFunction OutlawDefaultCdActions
{
	#variable,name=rtb_reroll,value=!talent.slice_and_dice.enabled&(rtb_buffs<=2&!rtb_list.any.6)
	#variable,name=ss_useable_noreroll,value=(combo_points<5+talent.deeper_stratagem.enabled-(buff.broadsides.up|buff.jolly_roger.up)-(talent.alacrity.enabled&buff.alacrity.stack<=4))
	#variable,name=ss_useable,value=(talent.anticipation.enabled&combo_points<4)|(!talent.anticipation.enabled&((variable.rtb_reroll&combo_points<4+talent.deeper_stratagem.enabled)|(!variable.rtb_reroll&variable.ss_useable_noreroll)))
	#kick
	OutlawInterruptActions()
	#call_action_list,name=bf
	OutlawBfCdActions()

	unless OutlawBfCdPostConditions()
	{
		#call_action_list,name=cds
		OutlawCdsCdActions()

		unless OutlawCdsCdPostConditions()
		{
			#call_action_list,name=stealth,if=stealthed.rogue|cooldown.vanish.up|cooldown.shadowmeld.up
			if Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 OutlawStealthCdActions()

			unless { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthCdPostConditions() or TimeToMaxEnergy() > 2 and not ss_useable_noreroll() and Spell(death_from_above) or not ss_useable() and BuffRemaining(slice_and_dice_buff) < target.TimeToDie() and BuffRemaining(slice_and_dice_buff) < { 1 + ComboPoints() } * 1.8 and Spell(slice_and_dice) or not ss_useable() and BuffRemaining(roll_the_bones_buff) < target.TimeToDie() and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } and Spell(roll_the_bones)
			{
				#killing_spree,if=energy.time_to_max>5|energy<15
				if TimeToMaxEnergy() > 5 or Energy() < 15 Spell(killing_spree)
				#call_action_list,name=build
				OutlawBuildCdActions()

				unless OutlawBuildCdPostConditions()
				{
					#call_action_list,name=finish,if=!variable.ss_useable
					if not ss_useable() OutlawFinishCdActions()
				}
			}
		}
	}
}

AddFunction OutlawDefaultCdPostConditions
{
	OutlawBfCdPostConditions() or OutlawCdsCdPostConditions() or { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthCdPostConditions() or TimeToMaxEnergy() > 2 and not ss_useable_noreroll() and Spell(death_from_above) or not ss_useable() and BuffRemaining(slice_and_dice_buff) < target.TimeToDie() and BuffRemaining(slice_and_dice_buff) < { 1 + ComboPoints() } * 1.8 and Spell(slice_and_dice) or not ss_useable() and BuffRemaining(roll_the_bones_buff) < target.TimeToDie() and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } and Spell(roll_the_bones) or OutlawBuildCdPostConditions() or not ss_useable() and OutlawFinishCdPostConditions() or Talent(dirty_tricks_talent) and ComboPointsDeficit() >= 1 and Spell(gouge)
}

### actions.bf

AddFunction OutlawBfMainActions
{
}

AddFunction OutlawBfMainPostConditions
{
}

AddFunction OutlawBfShortCdActions
{
	#cancel_buff,name=blade_flurry,if=equipped.shivarran_symmetry&cooldown.blade_flurry.up&buff.blade_flurry.up&spell_targets.blade_flurry>=2|spell_targets.blade_flurry<2&buff.blade_flurry.up
	if { HasEquippedItem(shivarran_symmetry) and not SpellCooldown(blade_flurry) > 0 and BuffPresent(blade_flurry_buff) and Enemies() >= 2 or Enemies() < 2 and BuffPresent(blade_flurry_buff) } and BuffPresent(blade_flurry_buff) Texture(blade_flurry text=cancel)
	#blade_flurry,if=spell_targets.blade_flurry>=2&!buff.blade_flurry.up
	if Enemies() >= 2 and not BuffPresent(blade_flurry_buff) and CheckBoxOn(opt_blade_flurry) Spell(blade_flurry)
}

AddFunction OutlawBfShortCdPostConditions
{
}

AddFunction OutlawBfCdActions
{
}

AddFunction OutlawBfCdPostConditions
{
}

### actions.build

AddFunction OutlawBuildMainActions
{
	#ghostly_strike,if=combo_points.deficit>=1+buff.broadsides.up&!buff.curse_of_the_dreadblades.up&(debuff.ghostly_strike.remains<debuff.ghostly_strike.duration*0.3|(cooldown.curse_of_the_dreadblades.remains<3&debuff.ghostly_strike.remains<14))&(combo_points>=3|(variable.rtb_reroll&time>=10))
	if ComboPointsDeficit() >= 1 + BuffPresent(broadsides_buff) and not BuffPresent(curse_of_the_dreadblades_buff) and { target.DebuffRemaining(ghostly_strike_debuff) < BaseDuration(ghostly_strike_debuff) * 0.3 or SpellCooldown(curse_of_the_dreadblades) < 3 and target.DebuffRemaining(ghostly_strike_debuff) < 14 } and { ComboPoints() >= 3 or rtb_reroll() and TimeInCombat() >= 10 } Spell(ghostly_strike)
	#pistol_shot,if=combo_points.deficit>=1+buff.broadsides.up&buff.opportunity.up&(energy.time_to_max>2-talent.quick_draw.enabled|(buff.blunderbuss.up&buff.greenskins_waterlogged_wristcuffs.up))
	if ComboPointsDeficit() >= 1 + BuffPresent(broadsides_buff) and BuffPresent(opportunity_buff) and { TimeToMaxEnergy() > 2 - TalentPoints(quick_draw_talent) or BuffPresent(blunderbuss_buff) and BuffPresent(greenskins_waterlogged_wristcuffs_buff) } Spell(pistol_shot text=PS)
	#saber_slash,if=variable.ss_useable
	if ss_useable() Spell(saber_slash)
}

AddFunction OutlawBuildMainPostConditions
{
}

AddFunction OutlawBuildShortCdActions
{
}

AddFunction OutlawBuildShortCdPostConditions
{
	ComboPointsDeficit() >= 1 + BuffPresent(broadsides_buff) and not BuffPresent(curse_of_the_dreadblades_buff) and { target.DebuffRemaining(ghostly_strike_debuff) < BaseDuration(ghostly_strike_debuff) * 0.3 or SpellCooldown(curse_of_the_dreadblades) < 3 and target.DebuffRemaining(ghostly_strike_debuff) < 14 } and { ComboPoints() >= 3 or rtb_reroll() and TimeInCombat() >= 10 } and Spell(ghostly_strike) or ComboPointsDeficit() >= 1 + BuffPresent(broadsides_buff) and BuffPresent(opportunity_buff) and { TimeToMaxEnergy() > 2 - TalentPoints(quick_draw_talent) or BuffPresent(blunderbuss_buff) and BuffPresent(greenskins_waterlogged_wristcuffs_buff) } and Spell(pistol_shot text=PS) or ss_useable() and Spell(saber_slash)
}

AddFunction OutlawBuildCdActions
{
}

AddFunction OutlawBuildCdPostConditions
{
	ComboPointsDeficit() >= 1 + BuffPresent(broadsides_buff) and not BuffPresent(curse_of_the_dreadblades_buff) and { target.DebuffRemaining(ghostly_strike_debuff) < BaseDuration(ghostly_strike_debuff) * 0.3 or SpellCooldown(curse_of_the_dreadblades) < 3 and target.DebuffRemaining(ghostly_strike_debuff) < 14 } and { ComboPoints() >= 3 or rtb_reroll() and TimeInCombat() >= 10 } and Spell(ghostly_strike) or ComboPointsDeficit() >= 1 + BuffPresent(broadsides_buff) and BuffPresent(opportunity_buff) and { TimeToMaxEnergy() > 2 - TalentPoints(quick_draw_talent) or BuffPresent(blunderbuss_buff) and BuffPresent(greenskins_waterlogged_wristcuffs_buff) } and Spell(pistol_shot text=PS) or ss_useable() and Spell(saber_slash)
}

### actions.cds

AddFunction OutlawCdsMainActions
{
}

AddFunction OutlawCdsMainPostConditions
{
}

AddFunction OutlawCdsShortCdActions
{
	#cannonball_barrage,if=spell_targets.cannonball_barrage>=1
	if Enemies() >= 1 Spell(cannonball_barrage)
	#marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit|((raid_event.adds.in>40|buff.true_bearing.remains>15)&combo_points.deficit>=4+talent.deeper_stratagem.enabled+talent.anticipation.enabled)
	if target.TimeToDie() < ComboPointsDeficit() or { 600 > 40 or BuffRemaining(true_bearing_buff) > 15 } and ComboPointsDeficit() >= 4 + TalentPoints(deeper_stratagem_talent) + TalentPoints(anticipation_talent) Spell(marked_for_death)
	#sprint,if=equipped.thraxis_tricksy_treads&!variable.ss_useable
	if HasEquippedItem(thraxis_tricksy_treads) and not ss_useable() Spell(sprint)
}

AddFunction OutlawCdsShortCdPostConditions
{
}

AddFunction OutlawCdsCdActions
{
	#potion,name=prolonged_power,if=buff.bloodlust.react|target.time_to_die<=25|buff.adrenaline_rush.up
	if { BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 25 or BuffPresent(adrenaline_rush_buff) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
	#use_item,slot=trinket2,if=buff.bloodlust.react|target.time_to_die<=20|combo_points.deficit<=2
	if BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 20 or ComboPointsDeficit() <= 2 OutlawUseItemActions()
	#blood_fury
	Spell(blood_fury_ap)
	#berserking
	Spell(berserking)
	#arcane_torrent,if=energy.deficit>40
	if EnergyDeficit() > 40 Spell(arcane_torrent_energy)

	unless Enemies() >= 1 and Spell(cannonball_barrage)
	{
		#adrenaline_rush,if=!buff.adrenaline_rush.up&energy.deficit>0
		if not BuffPresent(adrenaline_rush_buff) and EnergyDeficit() > 0 and EnergyDeficit() > 1 Spell(adrenaline_rush)

		unless HasEquippedItem(thraxis_tricksy_treads) and not ss_useable() and Spell(sprint)
		{
			#darkflight,if=equipped.thraxis_tricksy_treads&!variable.ss_useable&buff.sprint.down
			if HasEquippedItem(thraxis_tricksy_treads) and not ss_useable() and BuffExpires(sprint_buff) Spell(darkflight)
			#curse_of_the_dreadblades,if=combo_points.deficit>=4&(!talent.ghostly_strike.enabled|debuff.ghostly_strike.up)
			if ComboPointsDeficit() >= 4 and { not Talent(ghostly_strike_talent) or target.DebuffPresent(ghostly_strike_debuff) } Spell(curse_of_the_dreadblades)
		}
	}
}

AddFunction OutlawCdsCdPostConditions
{
	Enemies() >= 1 and Spell(cannonball_barrage) or HasEquippedItem(thraxis_tricksy_treads) and not ss_useable() and Spell(sprint)
}

### actions.finish

AddFunction OutlawFinishMainActions
{
	#between_the_eyes,if=equipped.greenskins_waterlogged_wristcuffs&!buff.greenskins_waterlogged_wristcuffs.up
	if HasEquippedItem(greenskins_waterlogged_wristcuffs) and not BuffPresent(greenskins_waterlogged_wristcuffs_buff) Spell(between_the_eyes text=BTE)
	#run_through,if=!talent.death_from_above.enabled|energy.time_to_max<cooldown.death_from_above.remains+3.5
	if not Talent(death_from_above_talent) or TimeToMaxEnergy() < SpellCooldown(death_from_above) + 3.5 Spell(run_through)
}

AddFunction OutlawFinishMainPostConditions
{
}

AddFunction OutlawFinishShortCdActions
{
}

AddFunction OutlawFinishShortCdPostConditions
{
	HasEquippedItem(greenskins_waterlogged_wristcuffs) and not BuffPresent(greenskins_waterlogged_wristcuffs_buff) and Spell(between_the_eyes text=BTE) or { not Talent(death_from_above_talent) or TimeToMaxEnergy() < SpellCooldown(death_from_above) + 3.5 } and Spell(run_through)
}

AddFunction OutlawFinishCdActions
{
}

AddFunction OutlawFinishCdPostConditions
{
	HasEquippedItem(greenskins_waterlogged_wristcuffs) and not BuffPresent(greenskins_waterlogged_wristcuffs_buff) and Spell(between_the_eyes text=BTE) or { not Talent(death_from_above_talent) or TimeToMaxEnergy() < SpellCooldown(death_from_above) + 3.5 } and Spell(run_through)
}

### actions.precombat

AddFunction OutlawPrecombatMainActions
{
	#flask,name=flask_of_the_seventh_demon
	#augmentation,name=defiled
	#food,name=seedbattered_fish_plate
	#snapshot_stats
	#stealth
	Spell(stealth)
	#roll_the_bones,if=!talent.slice_and_dice.enabled
	if not Talent(slice_and_dice_talent) Spell(roll_the_bones)
}

AddFunction OutlawPrecombatMainPostConditions
{
}

AddFunction OutlawPrecombatShortCdActions
{
	unless Spell(stealth)
	{
		#marked_for_death,if=raid_event.adds.in>40
		if 600 > 40 Spell(marked_for_death)
	}
}

AddFunction OutlawPrecombatShortCdPostConditions
{
	Spell(stealth) or not Talent(slice_and_dice_talent) and Spell(roll_the_bones)
}

AddFunction OutlawPrecombatCdActions
{
	unless Spell(stealth)
	{
		#potion,name=prolonged_power
		if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
	}
}

AddFunction OutlawPrecombatCdPostConditions
{
	Spell(stealth) or not Talent(slice_and_dice_talent) and Spell(roll_the_bones)
}

### actions.stealth

AddFunction OutlawStealthMainActions
{
	#variable,name=stealth_condition,value=combo_points.deficit>=2+2*(talent.ghostly_strike.enabled&!debuff.ghostly_strike.up)+buff.broadsides.up&energy>60&!buff.jolly_roger.up&!buff.hidden_blade.up&!buff.curse_of_the_dreadblades.up
	#ambush
	Spell(ambush)
}

AddFunction OutlawStealthMainPostConditions
{
}

AddFunction OutlawStealthShortCdActions
{
	unless Spell(ambush)
	{
		#vanish,if=(equipped.mantle_of_the_master_assassin&buff.true_bearing.up)|variable.stealth_condition
		if HasEquippedItem(mantle_of_the_master_assassin) and BuffPresent(true_bearing_buff) or stealth_condition() Spell(vanish)
	}
}

AddFunction OutlawStealthShortCdPostConditions
{
	Spell(ambush)
}

AddFunction OutlawStealthCdActions
{
	unless Spell(ambush)
	{
		#shadowmeld,if=variable.stealth_condition
		if stealth_condition() Spell(shadowmeld)
	}
}

AddFunction OutlawStealthCdPostConditions
{
	Spell(ambush)
}

### Outlaw icons.

AddCheckBox(opt_rogue_outlaw_aoe L(AOE) default specialization=outlaw)

AddIcon checkbox=!opt_rogue_outlaw_aoe enemies=1 help=shortcd specialization=outlaw
{
	if not InCombat() OutlawPrecombatShortCdActions()
	unless not InCombat() and OutlawPrecombatShortCdPostConditions()
	{
		OutlawDefaultShortCdActions()
	}
}

AddIcon checkbox=opt_rogue_outlaw_aoe help=shortcd specialization=outlaw
{
	if not InCombat() OutlawPrecombatShortCdActions()
	unless not InCombat() and OutlawPrecombatShortCdPostConditions()
	{
		OutlawDefaultShortCdActions()
	}
}

AddIcon enemies=1 help=main specialization=outlaw
{
	if not InCombat() OutlawPrecombatMainActions()
	unless not InCombat() and OutlawPrecombatMainPostConditions()
	{
		OutlawDefaultMainActions()
	}
}

AddIcon checkbox=opt_rogue_outlaw_aoe help=aoe specialization=outlaw
{
	if not InCombat() OutlawPrecombatMainActions()
	unless not InCombat() and OutlawPrecombatMainPostConditions()
	{
		OutlawDefaultMainActions()
	}
}

AddIcon checkbox=!opt_rogue_outlaw_aoe enemies=1 help=cd specialization=outlaw
{
	if not InCombat() OutlawPrecombatCdActions()
	unless not InCombat() and OutlawPrecombatCdPostConditions()
	{
		OutlawDefaultCdActions()
	}
}

AddIcon checkbox=opt_rogue_outlaw_aoe help=cd specialization=outlaw
{
	if not InCombat() OutlawPrecombatCdActions()
	unless not InCombat() and OutlawPrecombatCdPostConditions()
	{
		OutlawDefaultCdActions()
	}
}

### Required symbols
# adrenaline_rush
# adrenaline_rush_buff
# alacrity_buff
# alacrity_talent
# ambush
# anticipation_talent
# arcane_torrent_energy
# berserking
# between_the_eyes
# blade_flurry
# blade_flurry_buff
# blood_fury_ap
# blunderbuss_buff
# broadsides_buff
# cannonball_barrage
# cheap_shot
# curse_of_the_dreadblades
# curse_of_the_dreadblades_buff
# darkflight
# death_from_above
# death_from_above_talent
# deeper_stratagem_talent
# dirty_tricks_talent
# ghostly_strike
# ghostly_strike_debuff
# ghostly_strike_talent
# gouge
# greenskins_waterlogged_wristcuffs
# greenskins_waterlogged_wristcuffs_buff
# hidden_blade_buff
# jolly_roger_buff
# kick
# killing_spree
# mantle_of_the_master_assassin
# marked_for_death
# opportunity_buff
# pistol_shot
# prolonged_power_potion
# quaking_palm
# quick_draw_talent
# roll_the_bones
# roll_the_bones_buff
# run_through
# saber_slash
# shadowmeld
# shadowstep
# shivarran_symmetry
# slice_and_dice
# slice_and_dice_buff
# slice_and_dice_talent
# sprint
# sprint_buff
# stealth
# thraxis_tricksy_treads
# true_bearing_buff
# vanish
]]
    __Scripts.OvaleScripts:RegisterScript("ROGUE", "outlaw", name, desc, code, "script")
end
do
    local name = "simulationcraft_rogue_subtlety_t19p"
    local desc = "[7.0] SimulationCraft: Rogue_Subtlety_T19P"
    local code = [[
# Based on SimulationCraft profile "Rogue_Subtlety_T19P".
#	class=rogue
#	spec=subtlety
#	talents=2310012

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_rogue_spells)


AddFunction shd_fractional
{
	1.725 + 0.725 * TalentPoints(enveloping_shadows_talent)
}

AddFunction ssw_refund
{
	HasEquippedItem(shadow_satyrs_walk) * { 6 + { target.Distance() % 3 - 1 } }
}

AddFunction dsh_dfa
{
	Talent(death_from_above_talent) and Talent(dark_shadow_talent)
}

AddFunction stealth_threshold
{
	65 + TalentPoints(vigor_talent) * 35 + TalentPoints(master_of_shadows_talent) * 10 + ssw_refund()
}

AddCheckBox(opt_interrupt L(interrupt) default specialization=subtlety)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=subtlety)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=subtlety)

AddFunction SubtletyInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
	{
		if target.InRange(kick) and target.IsInterruptible() Spell(kick)
		if target.InRange(cheap_shot) and not target.Classification(worldboss) Spell(cheap_shot)
		if target.InRange(kidney_shot) and not target.Classification(worldboss) and ComboPoints() >= 1 Spell(kidney_shot)
		if target.Distance(less 8) and target.IsInterruptible() Spell(arcane_torrent_energy)
		if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
	}
}

AddFunction SubtletyUseItemActions
{
	Item(Trinket0Slot text=13 usable=1)
	Item(Trinket1Slot text=14 usable=1)
}

AddFunction SubtletyGetInMeleeRange
{
	if CheckBoxOn(opt_melee_range) and not target.InRange(kick)
	{
		Spell(shadowstep)
		Texture(misc_arrowlup help=L(not_in_melee_range))
	}
}

### actions.default

AddFunction SubtletyDefaultMainActions
{
	#wait,sec=0.1,if=buff.shadow_dance.up&gcd.remains>0
	#call_action_list,name=cds
	SubtletyCdsMainActions()

	unless SubtletyCdsMainPostConditions()
	{
		#run_action_list,name=stealthed,if=stealthed.all
		if Stealthed() SubtletyStealthedMainActions()

		unless Stealthed() and SubtletyStealthedMainPostConditions()
		{
			#nightblade,if=target.time_to_die>6&remains<gcd.max&combo_points>=4-(time<10)*2
			if target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 Spell(nightblade)
			#call_action_list,name=stealth_als,if=talent.dark_shadow.enabled&combo_points.deficit>=3&(dot.nightblade.remains>4+talent.subterfuge.enabled|cooldown.shadow_dance.charges_fractional>=1.9&(!equipped.denial_of_the_halfgiants|time>10))
			if Talent(dark_shadow_talent) and ComboPointsDeficit() >= 3 and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } SubtletyStealthAlsMainActions()

			unless Talent(dark_shadow_talent) and ComboPointsDeficit() >= 3 and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } and SubtletyStealthAlsMainPostConditions()
			{
				#call_action_list,name=stealth_als,if=!talent.dark_shadow.enabled&(combo_points.deficit>=3|cooldown.shadow_dance.charges_fractional>=1.9+talent.enveloping_shadows.enabled)
				if not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 3 or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } SubtletyStealthAlsMainActions()

				unless not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 3 or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } and SubtletyStealthAlsMainPostConditions()
				{
					#call_action_list,name=finish,if=combo_points>=5|(combo_points>=4&combo_points.deficit<=2&spell_targets.shuriken_storm>=3&spell_targets.shuriken_storm<=4)|(target.time_to_die<=1&combo_points>=3)
					if ComboPoints() >= 5 or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies() >= 3 and Enemies() <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 SubtletyFinishMainActions()

					unless { ComboPoints() >= 5 or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies() >= 3 and Enemies() <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishMainPostConditions()
					{
						#call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold
						if EnergyDeficit() <= stealth_threshold() SubtletyBuildMainActions()
					}
				}
			}
		}
	}
}

AddFunction SubtletyDefaultMainPostConditions
{
	SubtletyCdsMainPostConditions() or Stealthed() and SubtletyStealthedMainPostConditions() or Talent(dark_shadow_talent) and ComboPointsDeficit() >= 3 and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } and SubtletyStealthAlsMainPostConditions() or not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 3 or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } and SubtletyStealthAlsMainPostConditions() or { ComboPoints() >= 5 or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies() >= 3 and Enemies() <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishMainPostConditions() or EnergyDeficit() <= stealth_threshold() and SubtletyBuildMainPostConditions()
}

AddFunction SubtletyDefaultShortCdActions
{
	#shadow_dance,if=talent.dark_shadow.enabled&!stealthed.all&buff.death_from_above.up&buff.death_from_above.remains<=0.15
	if Talent(dark_shadow_talent) and not Stealthed() and BuffPresent(death_from_above_buff) and BuffRemaining(death_from_above_buff) <= 0.15 Spell(shadow_dance)
	#wait,sec=0.1,if=buff.shadow_dance.up&gcd.remains>0
	#call_action_list,name=cds
	SubtletyCdsShortCdActions()

	unless SubtletyCdsShortCdPostConditions()
	{
		#run_action_list,name=stealthed,if=stealthed.all
		if Stealthed() SubtletyStealthedShortCdActions()

		unless Stealthed() and SubtletyStealthedShortCdPostConditions() or target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 and Spell(nightblade)
		{
			#call_action_list,name=stealth_als,if=talent.dark_shadow.enabled&combo_points.deficit>=3&(dot.nightblade.remains>4+talent.subterfuge.enabled|cooldown.shadow_dance.charges_fractional>=1.9&(!equipped.denial_of_the_halfgiants|time>10))
			if Talent(dark_shadow_talent) and ComboPointsDeficit() >= 3 and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } SubtletyStealthAlsShortCdActions()

			unless Talent(dark_shadow_talent) and ComboPointsDeficit() >= 3 and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } and SubtletyStealthAlsShortCdPostConditions()
			{
				#call_action_list,name=stealth_als,if=!talent.dark_shadow.enabled&(combo_points.deficit>=3|cooldown.shadow_dance.charges_fractional>=1.9+talent.enveloping_shadows.enabled)
				if not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 3 or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } SubtletyStealthAlsShortCdActions()

				unless not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 3 or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } and SubtletyStealthAlsShortCdPostConditions()
				{
					#call_action_list,name=finish,if=combo_points>=5|(combo_points>=4&combo_points.deficit<=2&spell_targets.shuriken_storm>=3&spell_targets.shuriken_storm<=4)|(target.time_to_die<=1&combo_points>=3)
					if ComboPoints() >= 5 or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies() >= 3 and Enemies() <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 SubtletyFinishShortCdActions()

					unless { ComboPoints() >= 5 or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies() >= 3 and Enemies() <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishShortCdPostConditions()
					{
						#call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold
						if EnergyDeficit() <= stealth_threshold() SubtletyBuildShortCdActions()
					}
				}
			}
		}
	}
}

AddFunction SubtletyDefaultShortCdPostConditions
{
	SubtletyCdsShortCdPostConditions() or Stealthed() and SubtletyStealthedShortCdPostConditions() or target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 and Spell(nightblade) or Talent(dark_shadow_talent) and ComboPointsDeficit() >= 3 and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } and SubtletyStealthAlsShortCdPostConditions() or not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 3 or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } and SubtletyStealthAlsShortCdPostConditions() or { ComboPoints() >= 5 or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies() >= 3 and Enemies() <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishShortCdPostConditions() or EnergyDeficit() <= stealth_threshold() and SubtletyBuildShortCdPostConditions()
}

AddFunction SubtletyDefaultCdActions
{
	#kick
	SubtletyInterruptActions()
	#wait,sec=0.1,if=buff.shadow_dance.up&gcd.remains>0
	#call_action_list,name=cds
	SubtletyCdsCdActions()

	unless SubtletyCdsCdPostConditions()
	{
		#run_action_list,name=stealthed,if=stealthed.all
		if Stealthed() SubtletyStealthedCdActions()

		unless Stealthed() and SubtletyStealthedCdPostConditions() or target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 and Spell(nightblade)
		{
			#call_action_list,name=stealth_als,if=talent.dark_shadow.enabled&combo_points.deficit>=3&(dot.nightblade.remains>4+talent.subterfuge.enabled|cooldown.shadow_dance.charges_fractional>=1.9&(!equipped.denial_of_the_halfgiants|time>10))
			if Talent(dark_shadow_talent) and ComboPointsDeficit() >= 3 and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } SubtletyStealthAlsCdActions()

			unless Talent(dark_shadow_talent) and ComboPointsDeficit() >= 3 and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } and SubtletyStealthAlsCdPostConditions()
			{
				#call_action_list,name=stealth_als,if=!talent.dark_shadow.enabled&(combo_points.deficit>=3|cooldown.shadow_dance.charges_fractional>=1.9+talent.enveloping_shadows.enabled)
				if not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 3 or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } SubtletyStealthAlsCdActions()

				unless not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 3 or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } and SubtletyStealthAlsCdPostConditions()
				{
					#call_action_list,name=finish,if=combo_points>=5|(combo_points>=4&combo_points.deficit<=2&spell_targets.shuriken_storm>=3&spell_targets.shuriken_storm<=4)|(target.time_to_die<=1&combo_points>=3)
					if ComboPoints() >= 5 or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies() >= 3 and Enemies() <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 SubtletyFinishCdActions()

					unless { ComboPoints() >= 5 or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies() >= 3 and Enemies() <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishCdPostConditions()
					{
						#call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold
						if EnergyDeficit() <= stealth_threshold() SubtletyBuildCdActions()
					}
				}
			}
		}
	}
}

AddFunction SubtletyDefaultCdPostConditions
{
	SubtletyCdsCdPostConditions() or Stealthed() and SubtletyStealthedCdPostConditions() or target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 and Spell(nightblade) or Talent(dark_shadow_talent) and ComboPointsDeficit() >= 3 and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } and SubtletyStealthAlsCdPostConditions() or not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 3 or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } and SubtletyStealthAlsCdPostConditions() or { ComboPoints() >= 5 or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies() >= 3 and Enemies() <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishCdPostConditions() or EnergyDeficit() <= stealth_threshold() and SubtletyBuildCdPostConditions()
}

### actions.build

AddFunction SubtletyBuildMainActions
{
	#shuriken_storm,if=spell_targets.shuriken_storm>=2
	if Enemies() >= 2 Spell(shuriken_storm)
	#gloomblade
	Spell(gloomblade)
	#backstab
	Spell(backstab)
}

AddFunction SubtletyBuildMainPostConditions
{
}

AddFunction SubtletyBuildShortCdActions
{
}

AddFunction SubtletyBuildShortCdPostConditions
{
	Enemies() >= 2 and Spell(shuriken_storm) or Spell(gloomblade) or Spell(backstab)
}

AddFunction SubtletyBuildCdActions
{
}

AddFunction SubtletyBuildCdPostConditions
{
	Enemies() >= 2 and Spell(shuriken_storm) or Spell(gloomblade) or Spell(backstab)
}

### actions.cds

AddFunction SubtletyCdsMainActions
{
}

AddFunction SubtletyCdsMainPostConditions
{
}

AddFunction SubtletyCdsShortCdActions
{
	#symbols_of_death,if=!talent.death_from_above.enabled&((time>10&energy.deficit>=40-stealthed.all*30)|(time<10&dot.nightblade.ticking))
	if not Talent(death_from_above_talent) and { TimeInCombat() > 10 and EnergyDeficit() >= 40 - Stealthed() * 30 or TimeInCombat() < 10 and target.DebuffPresent(nightblade_debuff) } Spell(symbols_of_death)
	#symbols_of_death,if=talent.death_from_above.enabled&cooldown.death_from_above.remains<=3&(dot.nightblade.remains>=cooldown.death_from_above.remains+3|target.time_to_die-dot.nightblade.remains<=6)
	if Talent(death_from_above_talent) and SpellCooldown(death_from_above) <= 3 and { target.DebuffRemaining(nightblade_debuff) >= SpellCooldown(death_from_above) + 3 or target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) <= 6 } Spell(symbols_of_death)
	#marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit
	if target.TimeToDie() < ComboPointsDeficit() Spell(marked_for_death)
	#marked_for_death,if=raid_event.adds.in>40&!stealthed.all&combo_points.deficit>=cp_max_spend
	if 600 > 40 and not Stealthed() and ComboPointsDeficit() >= MaxComboPoints() Spell(marked_for_death)
	#goremaws_bite,if=!stealthed.all&cooldown.shadow_dance.charges_fractional<=variable.shd_fractional&((combo_points.deficit>=4-(time<10)*2&energy.deficit>50+talent.vigor.enabled*25-(time>=10)*15)|(combo_points.deficit>=1&target.time_to_die<8))
	if not Stealthed() and SpellCharges(shadow_dance count=0) <= shd_fractional() and { ComboPointsDeficit() >= 4 - { TimeInCombat() < 10 } * 2 and EnergyDeficit() > 50 + TalentPoints(vigor_talent) * 25 - { TimeInCombat() >= 10 } * 15 or ComboPointsDeficit() >= 1 and target.TimeToDie() < 8 } Spell(goremaws_bite)
	#pool_resource,for_next=1,extra_amount=40-talent.shadow_focus.enabled*10
	#vanish,if=variable.dsh_dfa&charges_fractional<=variable.shd_fractional&!buff.shadow_dance.up&!buff.stealth.up&mantle_duration=0&(dot.nightblade.remains>=cooldown.death_from_above.remains+3|target.time_to_die-dot.nightblade.remains<=6)&cooldown.death_from_above.remains<=1&combo_points.deficit>=2
	if dsh_dfa() and Charges(vanish count=0) <= shd_fractional() and not BuffPresent(shadow_dance_buff) and not BuffPresent(stealthed_buff any=1) and BuffRemaining(master_assassins_initiative) == 0 and { target.DebuffRemaining(nightblade_debuff) >= SpellCooldown(death_from_above) + 3 or target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) <= 6 } and SpellCooldown(death_from_above) <= 1 and ComboPointsDeficit() >= 2 Spell(vanish)
}

AddFunction SubtletyCdsShortCdPostConditions
{
}

AddFunction SubtletyCdsCdActions
{
	#potion,if=buff.bloodlust.react|target.time_to_die<=60|(buff.vanish.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=30))
	if { BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 60 or BuffPresent(vanish_buff) and { BuffPresent(shadow_blades_buff) or SpellCooldown(shadow_blades) <= 30 } } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
	#use_item,name=specter_of_betrayal,if=talent.dark_shadow.enabled&!buff.stealth.up&!buff.vanish.up&buff.shadow_dance.up&(buff.symbols_of_death.up|(!talent.death_from_above.enabled&((mantle_duration>=3|!equipped.mantle_of_the_master_assassin)|cooldown.vanish.remains>=43)))
	if Talent(dark_shadow_talent) and not BuffPresent(stealthed_buff any=1) and not BuffPresent(vanish_buff) and BuffPresent(shadow_dance_buff) and { BuffPresent(symbols_of_death_buff) or not Talent(death_from_above_talent) and { BuffRemaining(master_assassins_initiative) >= 3 or not HasEquippedItem(mantle_of_the_master_assassin) or SpellCooldown(vanish) >= 43 } } SubtletyUseItemActions()
	#use_item,name=specter_of_betrayal,if=!talent.dark_shadow.enabled&!buff.stealth.up&!buff.vanish.up&(mantle_duration>=3|!equipped.mantle_of_the_master_assassin)
	if not Talent(dark_shadow_talent) and not BuffPresent(stealthed_buff any=1) and not BuffPresent(vanish_buff) and { BuffRemaining(master_assassins_initiative) >= 3 or not HasEquippedItem(mantle_of_the_master_assassin) } SubtletyUseItemActions()
	#blood_fury,if=stealthed.rogue
	if Stealthed() Spell(blood_fury_ap)
	#berserking,if=stealthed.rogue
	if Stealthed() Spell(berserking)
	#arcane_torrent,if=stealthed.rogue&energy.deficit>70
	if Stealthed() and EnergyDeficit() > 70 Spell(arcane_torrent_energy)

	unless not Talent(death_from_above_talent) and { TimeInCombat() > 10 and EnergyDeficit() >= 40 - Stealthed() * 30 or TimeInCombat() < 10 and target.DebuffPresent(nightblade_debuff) } and Spell(symbols_of_death) or Talent(death_from_above_talent) and SpellCooldown(death_from_above) <= 3 and { target.DebuffRemaining(nightblade_debuff) >= SpellCooldown(death_from_above) + 3 or target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) <= 6 } and Spell(symbols_of_death)
	{
		#shadow_blades,if=(time>10&combo_points.deficit>=2+stealthed.all-equipped.mantle_of_the_master_assassin)|(time<10&(!talent.marked_for_death.enabled|combo_points.deficit>=3|dot.nightblade.ticking))
		if TimeInCombat() > 10 and ComboPointsDeficit() >= 2 + Stealthed() - HasEquippedItem(mantle_of_the_master_assassin) or TimeInCombat() < 10 and { not Talent(marked_for_death_talent) or ComboPointsDeficit() >= 3 or target.DebuffPresent(nightblade_debuff) } Spell(shadow_blades)
	}
}

AddFunction SubtletyCdsCdPostConditions
{
	not Talent(death_from_above_talent) and { TimeInCombat() > 10 and EnergyDeficit() >= 40 - Stealthed() * 30 or TimeInCombat() < 10 and target.DebuffPresent(nightblade_debuff) } and Spell(symbols_of_death) or Talent(death_from_above_talent) and SpellCooldown(death_from_above) <= 3 and { target.DebuffRemaining(nightblade_debuff) >= SpellCooldown(death_from_above) + 3 or target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) <= 6 } and Spell(symbols_of_death) or not Stealthed() and SpellCharges(shadow_dance count=0) <= shd_fractional() and { ComboPointsDeficit() >= 4 - { TimeInCombat() < 10 } * 2 and EnergyDeficit() > 50 + TalentPoints(vigor_talent) * 25 - { TimeInCombat() >= 10 } * 15 or ComboPointsDeficit() >= 1 and target.TimeToDie() < 8 } and Spell(goremaws_bite)
}

### actions.finish

AddFunction SubtletyFinishMainActions
{
	#nightblade,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>6&(mantle_duration=0|remains<=mantle_duration)&((refreshable&(!finality|buff.finality_nightblade.up))|remains<tick_time*2)
	if { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 6 and { BuffRemaining(master_assassins_initiative) == 0 or target.DebuffRemaining(nightblade_debuff) <= BuffRemaining(master_assassins_initiative) } and { target.Refreshable(nightblade_debuff) and { not HasArtifactTrait(finality) or DebuffPresent(finality_nightblade_debuff) } or target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 } Spell(nightblade)
	#nightblade,cycle_targets=1,if=!talent.death_from_above.enabled&(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>8&mantle_duration=0&((refreshable&(!finality|buff.finality_nightblade.up))|remains<tick_time*2)
	if not Talent(death_from_above_talent) and { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 8 and BuffRemaining(master_assassins_initiative) == 0 and { target.Refreshable(nightblade_debuff) and { not HasArtifactTrait(finality) or DebuffPresent(finality_nightblade_debuff) } or target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 } Spell(nightblade)
	#death_from_above,if=!talent.dark_shadow.enabled|(!buff.shadow_dance.up&(buff.symbols_of_death.up|cooldown.symbols_of_death.remains>=10+set_bonus.tier20_4pc*5))
	if not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) and { BuffPresent(symbols_of_death_buff) or SpellCooldown(symbols_of_death) >= 10 + ArmorSetBonus(T20 4) * 5 } Spell(death_from_above)
	#eviscerate
	Spell(eviscerate)
}

AddFunction SubtletyFinishMainPostConditions
{
}

AddFunction SubtletyFinishShortCdActions
{
}

AddFunction SubtletyFinishShortCdPostConditions
{
	{ not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 6 and { BuffRemaining(master_assassins_initiative) == 0 or target.DebuffRemaining(nightblade_debuff) <= BuffRemaining(master_assassins_initiative) } and { target.Refreshable(nightblade_debuff) and { not HasArtifactTrait(finality) or DebuffPresent(finality_nightblade_debuff) } or target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 } and Spell(nightblade) or not Talent(death_from_above_talent) and { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 8 and BuffRemaining(master_assassins_initiative) == 0 and { target.Refreshable(nightblade_debuff) and { not HasArtifactTrait(finality) or DebuffPresent(finality_nightblade_debuff) } or target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 } and Spell(nightblade) or { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) and { BuffPresent(symbols_of_death_buff) or SpellCooldown(symbols_of_death) >= 10 + ArmorSetBonus(T20 4) * 5 } } and Spell(death_from_above) or Spell(eviscerate)
}

AddFunction SubtletyFinishCdActions
{
}

AddFunction SubtletyFinishCdPostConditions
{
	{ not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 6 and { BuffRemaining(master_assassins_initiative) == 0 or target.DebuffRemaining(nightblade_debuff) <= BuffRemaining(master_assassins_initiative) } and { target.Refreshable(nightblade_debuff) and { not HasArtifactTrait(finality) or DebuffPresent(finality_nightblade_debuff) } or target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 } and Spell(nightblade) or not Talent(death_from_above_talent) and { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 8 and BuffRemaining(master_assassins_initiative) == 0 and { target.Refreshable(nightblade_debuff) and { not HasArtifactTrait(finality) or DebuffPresent(finality_nightblade_debuff) } or target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 } and Spell(nightblade) or { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) and { BuffPresent(symbols_of_death_buff) or SpellCooldown(symbols_of_death) >= 10 + ArmorSetBonus(T20 4) * 5 } } and Spell(death_from_above) or Spell(eviscerate)
}

### actions.precombat

AddFunction SubtletyPrecombatMainActions
{
	#flask
	#augmentation
	#food
	#snapshot_stats
	#variable,name=ssw_refund,value=equipped.shadow_satyrs_walk*(6+ssw_refund_offset)
	#variable,name=stealth_threshold,value=(65+talent.vigor.enabled*35+talent.master_of_shadows.enabled*10+variable.ssw_refund)
	#variable,name=shd_fractional,value=1.725+0.725*talent.enveloping_shadows.enabled
	#variable,name=dsh_dfa,value=talent.death_from_above.enabled&talent.dark_shadow.enabled
	#stealth
	Spell(stealth)
}

AddFunction SubtletyPrecombatMainPostConditions
{
}

AddFunction SubtletyPrecombatShortCdActions
{
	unless Spell(stealth)
	{
		#marked_for_death,precombat=1
		if not InCombat() Spell(marked_for_death)
	}
}

AddFunction SubtletyPrecombatShortCdPostConditions
{
	Spell(stealth)
}

AddFunction SubtletyPrecombatCdActions
{
	unless Spell(stealth)
	{
		#potion
		if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
	}
}

AddFunction SubtletyPrecombatCdPostConditions
{
	Spell(stealth)
}

### actions.stealth_als

AddFunction SubtletyStealthAlsMainActions
{
	#call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold-25*(!cooldown.goremaws_bite.up&!buff.feeding_frenzy.up)&(!equipped.shadow_satyrs_walk|cooldown.shadow_dance.charges_fractional>=variable.shd_fractional|energy.deficit>=10)
	if EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } SubtletyStealthCdsMainActions()

	unless EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } and SubtletyStealthCdsMainPostConditions()
	{
		#call_action_list,name=stealth_cds,if=mantle_duration>2.3
		if BuffRemaining(master_assassins_initiative) > 2.3 SubtletyStealthCdsMainActions()

		unless BuffRemaining(master_assassins_initiative) > 2.3 and SubtletyStealthCdsMainPostConditions()
		{
			#call_action_list,name=stealth_cds,if=spell_targets.shuriken_storm>=5
			if Enemies() >= 5 SubtletyStealthCdsMainActions()

			unless Enemies() >= 5 and SubtletyStealthCdsMainPostConditions()
			{
				#call_action_list,name=stealth_cds,if=(cooldown.shadowmeld.up&!cooldown.vanish.up&cooldown.shadow_dance.charges<=1)
				if not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 SubtletyStealthCdsMainActions()

				unless not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 and SubtletyStealthCdsMainPostConditions()
				{
					#call_action_list,name=stealth_cds,if=target.time_to_die<12*cooldown.shadow_dance.charges_fractional*(1+equipped.shadow_satyrs_walk*0.5)
					if target.TimeToDie() < 12 * SpellCharges(shadow_dance count=0) * { 1 + HasEquippedItem(shadow_satyrs_walk) * 0.5 } SubtletyStealthCdsMainActions()
				}
			}
		}
	}
}

AddFunction SubtletyStealthAlsMainPostConditions
{
	EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } and SubtletyStealthCdsMainPostConditions() or BuffRemaining(master_assassins_initiative) > 2.3 and SubtletyStealthCdsMainPostConditions() or Enemies() >= 5 and SubtletyStealthCdsMainPostConditions() or not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 and SubtletyStealthCdsMainPostConditions() or target.TimeToDie() < 12 * SpellCharges(shadow_dance count=0) * { 1 + HasEquippedItem(shadow_satyrs_walk) * 0.5 } and SubtletyStealthCdsMainPostConditions()
}

AddFunction SubtletyStealthAlsShortCdActions
{
	#call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold-25*(!cooldown.goremaws_bite.up&!buff.feeding_frenzy.up)&(!equipped.shadow_satyrs_walk|cooldown.shadow_dance.charges_fractional>=variable.shd_fractional|energy.deficit>=10)
	if EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } SubtletyStealthCdsShortCdActions()

	unless EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } and SubtletyStealthCdsShortCdPostConditions()
	{
		#call_action_list,name=stealth_cds,if=mantle_duration>2.3
		if BuffRemaining(master_assassins_initiative) > 2.3 SubtletyStealthCdsShortCdActions()

		unless BuffRemaining(master_assassins_initiative) > 2.3 and SubtletyStealthCdsShortCdPostConditions()
		{
			#call_action_list,name=stealth_cds,if=spell_targets.shuriken_storm>=5
			if Enemies() >= 5 SubtletyStealthCdsShortCdActions()

			unless Enemies() >= 5 and SubtletyStealthCdsShortCdPostConditions()
			{
				#call_action_list,name=stealth_cds,if=(cooldown.shadowmeld.up&!cooldown.vanish.up&cooldown.shadow_dance.charges<=1)
				if not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 SubtletyStealthCdsShortCdActions()

				unless not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 and SubtletyStealthCdsShortCdPostConditions()
				{
					#call_action_list,name=stealth_cds,if=target.time_to_die<12*cooldown.shadow_dance.charges_fractional*(1+equipped.shadow_satyrs_walk*0.5)
					if target.TimeToDie() < 12 * SpellCharges(shadow_dance count=0) * { 1 + HasEquippedItem(shadow_satyrs_walk) * 0.5 } SubtletyStealthCdsShortCdActions()
				}
			}
		}
	}
}

AddFunction SubtletyStealthAlsShortCdPostConditions
{
	EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } and SubtletyStealthCdsShortCdPostConditions() or BuffRemaining(master_assassins_initiative) > 2.3 and SubtletyStealthCdsShortCdPostConditions() or Enemies() >= 5 and SubtletyStealthCdsShortCdPostConditions() or not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 and SubtletyStealthCdsShortCdPostConditions() or target.TimeToDie() < 12 * SpellCharges(shadow_dance count=0) * { 1 + HasEquippedItem(shadow_satyrs_walk) * 0.5 } and SubtletyStealthCdsShortCdPostConditions()
}

AddFunction SubtletyStealthAlsCdActions
{
	#call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold-25*(!cooldown.goremaws_bite.up&!buff.feeding_frenzy.up)&(!equipped.shadow_satyrs_walk|cooldown.shadow_dance.charges_fractional>=variable.shd_fractional|energy.deficit>=10)
	if EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } SubtletyStealthCdsCdActions()

	unless EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } and SubtletyStealthCdsCdPostConditions()
	{
		#call_action_list,name=stealth_cds,if=mantle_duration>2.3
		if BuffRemaining(master_assassins_initiative) > 2.3 SubtletyStealthCdsCdActions()

		unless BuffRemaining(master_assassins_initiative) > 2.3 and SubtletyStealthCdsCdPostConditions()
		{
			#call_action_list,name=stealth_cds,if=spell_targets.shuriken_storm>=5
			if Enemies() >= 5 SubtletyStealthCdsCdActions()

			unless Enemies() >= 5 and SubtletyStealthCdsCdPostConditions()
			{
				#call_action_list,name=stealth_cds,if=(cooldown.shadowmeld.up&!cooldown.vanish.up&cooldown.shadow_dance.charges<=1)
				if not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 SubtletyStealthCdsCdActions()

				unless not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 and SubtletyStealthCdsCdPostConditions()
				{
					#call_action_list,name=stealth_cds,if=target.time_to_die<12*cooldown.shadow_dance.charges_fractional*(1+equipped.shadow_satyrs_walk*0.5)
					if target.TimeToDie() < 12 * SpellCharges(shadow_dance count=0) * { 1 + HasEquippedItem(shadow_satyrs_walk) * 0.5 } SubtletyStealthCdsCdActions()
				}
			}
		}
	}
}

AddFunction SubtletyStealthAlsCdPostConditions
{
	EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } and SubtletyStealthCdsCdPostConditions() or BuffRemaining(master_assassins_initiative) > 2.3 and SubtletyStealthCdsCdPostConditions() or Enemies() >= 5 and SubtletyStealthCdsCdPostConditions() or not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 and SubtletyStealthCdsCdPostConditions() or target.TimeToDie() < 12 * SpellCharges(shadow_dance count=0) * { 1 + HasEquippedItem(shadow_satyrs_walk) * 0.5 } and SubtletyStealthCdsCdPostConditions()
}

### actions.stealth_cds

AddFunction SubtletyStealthCdsMainActions
{
}

AddFunction SubtletyStealthCdsMainPostConditions
{
}

AddFunction SubtletyStealthCdsShortCdActions
{
	#vanish,if=!variable.dsh_dfa&mantle_duration=0&cooldown.shadow_dance.charges_fractional<variable.shd_fractional+(equipped.mantle_of_the_master_assassin&time<30)*0.3
	if not dsh_dfa() and BuffRemaining(master_assassins_initiative) == 0 and SpellCharges(shadow_dance count=0) < shd_fractional() + { HasEquippedItem(mantle_of_the_master_assassin) and TimeInCombat() < 30 } * 0.3 Spell(vanish)
	#shadow_dance,if=charges_fractional>=variable.shd_fractional|target.time_to_die<cooldown.symbols_of_death.remains
	if Charges(shadow_dance count=0) >= shd_fractional() or target.TimeToDie() < SpellCooldown(symbols_of_death) Spell(shadow_dance)
	#pool_resource,for_next=1,extra_amount=40
	#shadowmeld,if=energy>=40&energy.deficit>=10+variable.ssw_refund
	unless True(pool_energy 40) and EnergyDeficit() >= 10 + ssw_refund() and SpellUsable(shadowmeld) and SpellCooldown(shadowmeld) < TimeToEnergy(40)
	{
		#shadow_dance,if=!variable.dsh_dfa&combo_points.deficit>=2+(talent.subterfuge.enabled|buff.the_first_of_the_dead.up)*2&(buff.symbols_of_death.remains>=1.2+gcd.remains|cooldown.symbols_of_death.remains>=8)
		if not dsh_dfa() and ComboPointsDeficit() >= 2 + { Talent(subterfuge_talent) or BuffPresent(the_first_of_the_dead_buff) } * 2 and { BuffRemaining(symbols_of_death_buff) >= 1.2 + GCDRemaining() or SpellCooldown(symbols_of_death) >= 8 } Spell(shadow_dance)
	}
}

AddFunction SubtletyStealthCdsShortCdPostConditions
{
}

AddFunction SubtletyStealthCdsCdActions
{
	#pool_resource,for_next=1,extra_amount=40
	#shadowmeld,if=energy>=40&energy.deficit>=10+variable.ssw_refund
	if Energy() >= 40 and EnergyDeficit() >= 10 + ssw_refund() Spell(shadowmeld)
}

AddFunction SubtletyStealthCdsCdPostConditions
{
}

### actions.stealthed

AddFunction SubtletyStealthedMainActions
{
	#shadowstrike,if=buff.stealth.up
	if BuffPresent(stealthed_buff any=1) Spell(shadowstrike)
	#call_action_list,name=finish,if=combo_points>=5&(spell_targets.shuriken_storm>=3+equipped.shadow_satyrs_walk|(mantle_duration<=1.3&mantle_duration-gcd.remains>=0.3))
	if ComboPoints() >= 5 and { Enemies() >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } SubtletyFinishMainActions()

	unless ComboPoints() >= 5 and { Enemies() >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } and SubtletyFinishMainPostConditions()
	{
		#shuriken_storm,if=buff.shadowmeld.down&((combo_points.deficit>=3&spell_targets.shuriken_storm>=3+equipped.shadow_satyrs_walk)|(combo_points.deficit>=1&buff.the_dreadlords_deceit.stack>=29))
		if BuffExpires(shadowmeld_buff) and { ComboPointsDeficit() >= 3 and Enemies() >= 3 + HasEquippedItem(shadow_satyrs_walk) or ComboPointsDeficit() >= 1 and BuffStacks(the_dreadlords_deceit_buff) >= 29 } Spell(shuriken_storm)
		#call_action_list,name=finish,if=combo_points>=5&combo_points.deficit<3+buff.shadow_blades.up-equipped.mantle_of_the_master_assassin
		if ComboPoints() >= 5 and ComboPointsDeficit() < 3 + BuffPresent(shadow_blades_buff) - HasEquippedItem(mantle_of_the_master_assassin) SubtletyFinishMainActions()

		unless ComboPoints() >= 5 and ComboPointsDeficit() < 3 + BuffPresent(shadow_blades_buff) - HasEquippedItem(mantle_of_the_master_assassin) and SubtletyFinishMainPostConditions()
		{
			#shadowstrike
			Spell(shadowstrike)
		}
	}
}

AddFunction SubtletyStealthedMainPostConditions
{
	ComboPoints() >= 5 and { Enemies() >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } and SubtletyFinishMainPostConditions() or ComboPoints() >= 5 and ComboPointsDeficit() < 3 + BuffPresent(shadow_blades_buff) - HasEquippedItem(mantle_of_the_master_assassin) and SubtletyFinishMainPostConditions()
}

AddFunction SubtletyStealthedShortCdActions
{
	unless BuffPresent(stealthed_buff any=1) and Spell(shadowstrike)
	{
		#call_action_list,name=finish,if=combo_points>=5&(spell_targets.shuriken_storm>=3+equipped.shadow_satyrs_walk|(mantle_duration<=1.3&mantle_duration-gcd.remains>=0.3))
		if ComboPoints() >= 5 and { Enemies() >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } SubtletyFinishShortCdActions()

		unless ComboPoints() >= 5 and { Enemies() >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } and SubtletyFinishShortCdPostConditions() or BuffExpires(shadowmeld_buff) and { ComboPointsDeficit() >= 3 and Enemies() >= 3 + HasEquippedItem(shadow_satyrs_walk) or ComboPointsDeficit() >= 1 and BuffStacks(the_dreadlords_deceit_buff) >= 29 } and Spell(shuriken_storm)
		{
			#call_action_list,name=finish,if=combo_points>=5&combo_points.deficit<3+buff.shadow_blades.up-equipped.mantle_of_the_master_assassin
			if ComboPoints() >= 5 and ComboPointsDeficit() < 3 + BuffPresent(shadow_blades_buff) - HasEquippedItem(mantle_of_the_master_assassin) SubtletyFinishShortCdActions()
		}
	}
}

AddFunction SubtletyStealthedShortCdPostConditions
{
	BuffPresent(stealthed_buff any=1) and Spell(shadowstrike) or ComboPoints() >= 5 and { Enemies() >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } and SubtletyFinishShortCdPostConditions() or BuffExpires(shadowmeld_buff) and { ComboPointsDeficit() >= 3 and Enemies() >= 3 + HasEquippedItem(shadow_satyrs_walk) or ComboPointsDeficit() >= 1 and BuffStacks(the_dreadlords_deceit_buff) >= 29 } and Spell(shuriken_storm) or ComboPoints() >= 5 and ComboPointsDeficit() < 3 + BuffPresent(shadow_blades_buff) - HasEquippedItem(mantle_of_the_master_assassin) and SubtletyFinishShortCdPostConditions() or Spell(shadowstrike)
}

AddFunction SubtletyStealthedCdActions
{
	unless BuffPresent(stealthed_buff any=1) and Spell(shadowstrike)
	{
		#call_action_list,name=finish,if=combo_points>=5&(spell_targets.shuriken_storm>=3+equipped.shadow_satyrs_walk|(mantle_duration<=1.3&mantle_duration-gcd.remains>=0.3))
		if ComboPoints() >= 5 and { Enemies() >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } SubtletyFinishCdActions()

		unless ComboPoints() >= 5 and { Enemies() >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } and SubtletyFinishCdPostConditions() or BuffExpires(shadowmeld_buff) and { ComboPointsDeficit() >= 3 and Enemies() >= 3 + HasEquippedItem(shadow_satyrs_walk) or ComboPointsDeficit() >= 1 and BuffStacks(the_dreadlords_deceit_buff) >= 29 } and Spell(shuriken_storm)
		{
			#call_action_list,name=finish,if=combo_points>=5&combo_points.deficit<3+buff.shadow_blades.up-equipped.mantle_of_the_master_assassin
			if ComboPoints() >= 5 and ComboPointsDeficit() < 3 + BuffPresent(shadow_blades_buff) - HasEquippedItem(mantle_of_the_master_assassin) SubtletyFinishCdActions()
		}
	}
}

AddFunction SubtletyStealthedCdPostConditions
{
	BuffPresent(stealthed_buff any=1) and Spell(shadowstrike) or ComboPoints() >= 5 and { Enemies() >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } and SubtletyFinishCdPostConditions() or BuffExpires(shadowmeld_buff) and { ComboPointsDeficit() >= 3 and Enemies() >= 3 + HasEquippedItem(shadow_satyrs_walk) or ComboPointsDeficit() >= 1 and BuffStacks(the_dreadlords_deceit_buff) >= 29 } and Spell(shuriken_storm) or ComboPoints() >= 5 and ComboPointsDeficit() < 3 + BuffPresent(shadow_blades_buff) - HasEquippedItem(mantle_of_the_master_assassin) and SubtletyFinishCdPostConditions() or Spell(shadowstrike)
}

### Subtlety icons.

AddCheckBox(opt_rogue_subtlety_aoe L(AOE) default specialization=subtlety)

AddIcon checkbox=!opt_rogue_subtlety_aoe enemies=1 help=shortcd specialization=subtlety
{
	if not InCombat() SubtletyPrecombatShortCdActions()
	unless not InCombat() and SubtletyPrecombatShortCdPostConditions()
	{
		SubtletyDefaultShortCdActions()
	}
}

AddIcon checkbox=opt_rogue_subtlety_aoe help=shortcd specialization=subtlety
{
	if not InCombat() SubtletyPrecombatShortCdActions()
	unless not InCombat() and SubtletyPrecombatShortCdPostConditions()
	{
		SubtletyDefaultShortCdActions()
	}
}

AddIcon enemies=1 help=main specialization=subtlety
{
	if not InCombat() SubtletyPrecombatMainActions()
	unless not InCombat() and SubtletyPrecombatMainPostConditions()
	{
		SubtletyDefaultMainActions()
	}
}

AddIcon checkbox=opt_rogue_subtlety_aoe help=aoe specialization=subtlety
{
	if not InCombat() SubtletyPrecombatMainActions()
	unless not InCombat() and SubtletyPrecombatMainPostConditions()
	{
		SubtletyDefaultMainActions()
	}
}

AddIcon checkbox=!opt_rogue_subtlety_aoe enemies=1 help=cd specialization=subtlety
{
	if not InCombat() SubtletyPrecombatCdActions()
	unless not InCombat() and SubtletyPrecombatCdPostConditions()
	{
		SubtletyDefaultCdActions()
	}
}

AddIcon checkbox=opt_rogue_subtlety_aoe help=cd specialization=subtlety
{
	if not InCombat() SubtletyPrecombatCdActions()
	unless not InCombat() and SubtletyPrecombatCdPostConditions()
	{
		SubtletyDefaultCdActions()
	}
}

### Required symbols
# arcane_torrent_energy
# backstab
# berserking
# blood_fury_ap
# cheap_shot
# dark_shadow_talent
# death_from_above
# death_from_above_buff
# death_from_above_talent
# denial_of_the_halfgiants
# enveloping_shadows_talent
# eviscerate
# feeding_frenzy_buff
# finality_nightblade_debuff
# gloomblade
# goremaws_bite
# kick
# kidney_shot
# mantle_of_the_master_assassin
# marked_for_death
# marked_for_death_talent
# master_assassins_initiative
# master_of_shadows_talent
# nightblade
# nightblade_debuff
# prolonged_power_potion
# quaking_palm
# shadow_blades
# shadow_blades_buff
# shadow_dance
# shadow_dance_buff
# shadow_satyrs_walk
# shadowmeld
# shadowmeld_buff
# shadowstep
# shadowstrike
# shuriken_storm
# stealth
# subterfuge_talent
# symbols_of_death
# symbols_of_death_buff
# the_dreadlords_deceit_buff
# the_first_of_the_dead_buff
# vanish
# vanish_buff
# vigor_talent
]]
    __Scripts.OvaleScripts:RegisterScript("ROGUE", "subtlety", name, desc, code, "script")
end
end)
