local __addonName, __addon = ...
__addon.require(__addonName, __addon, "ovale_hunter", { "../Scripts" }, function(__exports, __Scripts)
do
    local name = "simulationcraft_hunter_bm_t19p"
    local desc = "[7.0] SimulationCraft: Hunter_BM_T19P"
    local code = [[
# Based on SimulationCraft profile "Hunter_BM_T19P".
#	class=hunter
#	spec=beast_mastery
#	talents=2102012

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_hunter_spells)

AddCheckBox(opt_interrupt L(interrupt) default specialization=beast_mastery)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=beast_mastery)
AddCheckBox(opt_volley SpellName(volley) default specialization=beast_mastery)

AddFunction BeastMasteryInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
	{
		if target.InRange(counter_shot) and target.IsInterruptible() Spell(counter_shot)
		if target.Distance(less 8) and target.IsInterruptible() Spell(arcane_torrent_focus)
		if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
		if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
	}
}

AddFunction BeastMasterySummonPet
{
	if pet.IsDead()
	{
		if not DebuffPresent(heart_of_the_phoenix_debuff) Spell(heart_of_the_phoenix)
		Spell(revive_pet)
	}
	if not pet.Present() and not pet.IsDead() and not PreviousSpell(revive_pet) Texture(ability_hunter_beastcall help=L(summon_pet))
}

### actions.default

AddFunction BeastMasteryDefaultMainActions
{
	#volley,toggle=on
	if CheckBoxOn(opt_volley) Spell(volley)
	#dire_beast,if=cooldown.bestial_wrath.remains>3
	if SpellCooldown(bestial_wrath) > 3 Spell(dire_beast)
	#dire_frenzy,if=(cooldown.bestial_wrath.remains>6&(!equipped.the_mantle_of_command|pet.cat.buff.dire_frenzy.remains<=gcd.max*1.2))|(charges>=2&focus.deficit>=25+talent.dire_stable.enabled*12)|target.time_to_die<9
	if SpellCooldown(bestial_wrath) > 6 and { not HasEquippedItem(the_mantle_of_command) or pet.BuffRemaining(pet_dire_frenzy_buff) <= GCD() * 1.2 } or Charges(dire_frenzy) >= 2 and FocusDeficit() >= 25 + TalentPoints(dire_stable_talent) * 12 or target.TimeToDie() < 9 Spell(dire_frenzy)
	#multishot,if=spell_targets>4&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
	if Enemies() > 4 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } Spell(multishot)
	#kill_command
	if pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() Spell(kill_command)
	#multishot,if=spell_targets>1&(pet.cat.buff.beast_cleave.remains<gcd.max*2|pet.cat.buff.beast_cleave.down)
	if Enemies() > 1 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() * 2 or pet.BuffExpires(pet_beast_cleave_buff) } Spell(multishot)
	#chimaera_shot,if=focus<90
	if Focus() < 90 Spell(chimaera_shot)
	#cobra_shot,if=(cooldown.kill_command.remains>focus.time_to_max&cooldown.bestial_wrath.remains>focus.time_to_max)|(buff.bestial_wrath.up&focus.regen*cooldown.kill_command.remains>30)|target.time_to_die<cooldown.kill_command.remains
	if SpellCooldown(kill_command) > TimeToMaxFocus() and SpellCooldown(bestial_wrath) > TimeToMaxFocus() or BuffPresent(bestial_wrath_buff) and FocusRegenRate() * SpellCooldown(kill_command) > 30 or target.TimeToDie() < SpellCooldown(kill_command) Spell(cobra_shot)
}

AddFunction BeastMasteryDefaultMainPostConditions
{
}

AddFunction BeastMasteryDefaultShortCdActions
{
	unless CheckBoxOn(opt_volley) and Spell(volley)
	{
		#a_murder_of_crows
		Spell(a_murder_of_crows)

		unless SpellCooldown(bestial_wrath) > 3 and Spell(dire_beast) or { SpellCooldown(bestial_wrath) > 6 and { not HasEquippedItem(the_mantle_of_command) or pet.BuffRemaining(pet_dire_frenzy_buff) <= GCD() * 1.2 } or Charges(dire_frenzy) >= 2 and FocusDeficit() >= 25 + TalentPoints(dire_stable_talent) * 12 or target.TimeToDie() < 9 } and Spell(dire_frenzy)
		{
			#barrage,if=spell_targets.barrage>1
			if Enemies() > 1 Spell(barrage)
			#titans_thunder,if=talent.dire_frenzy.enabled|cooldown.dire_beast.remains>=3|(buff.bestial_wrath.up&pet.dire_beast.active)
			if Talent(dire_frenzy_talent) or SpellCooldown(dire_beast) >= 3 or BuffPresent(bestial_wrath_buff) and pet.Present() Spell(titans_thunder)
			#bestial_wrath
			Spell(bestial_wrath)
		}
	}
}

AddFunction BeastMasteryDefaultShortCdPostConditions
{
	CheckBoxOn(opt_volley) and Spell(volley) or SpellCooldown(bestial_wrath) > 3 and Spell(dire_beast) or { SpellCooldown(bestial_wrath) > 6 and { not HasEquippedItem(the_mantle_of_command) or pet.BuffRemaining(pet_dire_frenzy_buff) <= GCD() * 1.2 } or Charges(dire_frenzy) >= 2 and FocusDeficit() >= 25 + TalentPoints(dire_stable_talent) * 12 or target.TimeToDie() < 9 } and Spell(dire_frenzy) or Enemies() > 4 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multishot) or pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() and Spell(kill_command) or Enemies() > 1 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() * 2 or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multishot) or Focus() < 90 and Spell(chimaera_shot) or { SpellCooldown(kill_command) > TimeToMaxFocus() and SpellCooldown(bestial_wrath) > TimeToMaxFocus() or BuffPresent(bestial_wrath_buff) and FocusRegenRate() * SpellCooldown(kill_command) > 30 or target.TimeToDie() < SpellCooldown(kill_command) } and Spell(cobra_shot)
}

AddFunction BeastMasteryDefaultCdActions
{
	#auto_shot
	#counter_shot
	BeastMasteryInterruptActions()
	#arcane_torrent,if=focus.deficit>=30
	if FocusDeficit() >= 30 Spell(arcane_torrent_focus)
	#berserking
	Spell(berserking)
	#blood_fury
	Spell(blood_fury_ap)

	unless CheckBoxOn(opt_volley) and Spell(volley)
	{
		#potion,name=prolonged_power,if=buff.bestial_wrath.remains|!cooldown.bestial_wrath.remains
		if { BuffPresent(bestial_wrath_buff) or not SpellCooldown(bestial_wrath) > 0 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)

		unless Spell(a_murder_of_crows)
		{
			#stampede,if=buff.bloodlust.up|buff.bestial_wrath.up|cooldown.bestial_wrath.remains<=2|target.time_to_die<=14
			if BuffPresent(burst_haste_buff any=1) or BuffPresent(bestial_wrath_buff) or SpellCooldown(bestial_wrath) <= 2 or target.TimeToDie() <= 14 Spell(stampede)

			unless SpellCooldown(bestial_wrath) > 3 and Spell(dire_beast) or { SpellCooldown(bestial_wrath) > 6 and { not HasEquippedItem(the_mantle_of_command) or pet.BuffRemaining(pet_dire_frenzy_buff) <= GCD() * 1.2 } or Charges(dire_frenzy) >= 2 and FocusDeficit() >= 25 + TalentPoints(dire_stable_talent) * 12 or target.TimeToDie() < 9 } and Spell(dire_frenzy)
			{
				#aspect_of_the_wild,if=buff.bestial_wrath.up|target.time_to_die<12
				if BuffPresent(bestial_wrath_buff) or target.TimeToDie() < 12 Spell(aspect_of_the_wild)
			}
		}
	}
}

AddFunction BeastMasteryDefaultCdPostConditions
{
	CheckBoxOn(opt_volley) and Spell(volley) or Spell(a_murder_of_crows) or SpellCooldown(bestial_wrath) > 3 and Spell(dire_beast) or { SpellCooldown(bestial_wrath) > 6 and { not HasEquippedItem(the_mantle_of_command) or pet.BuffRemaining(pet_dire_frenzy_buff) <= GCD() * 1.2 } or Charges(dire_frenzy) >= 2 and FocusDeficit() >= 25 + TalentPoints(dire_stable_talent) * 12 or target.TimeToDie() < 9 } and Spell(dire_frenzy) or Enemies() > 1 and Spell(barrage) or { Talent(dire_frenzy_talent) or SpellCooldown(dire_beast) >= 3 or BuffPresent(bestial_wrath_buff) and pet.Present() } and Spell(titans_thunder) or Enemies() > 4 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multishot) or pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() and Spell(kill_command) or Enemies() > 1 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() * 2 or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multishot) or Focus() < 90 and Spell(chimaera_shot) or { SpellCooldown(kill_command) > TimeToMaxFocus() and SpellCooldown(bestial_wrath) > TimeToMaxFocus() or BuffPresent(bestial_wrath_buff) and FocusRegenRate() * SpellCooldown(kill_command) > 30 or target.TimeToDie() < SpellCooldown(kill_command) } and Spell(cobra_shot)
}

### actions.precombat

AddFunction BeastMasteryPrecombatMainActions
{
}

AddFunction BeastMasteryPrecombatMainPostConditions
{
}

AddFunction BeastMasteryPrecombatShortCdActions
{
	#flask,type=flask_of_the_seventh_demon
	#food,type=nightborne_delicacy_platter
	#summon_pet
	BeastMasterySummonPet()
}

AddFunction BeastMasteryPrecombatShortCdPostConditions
{
}

AddFunction BeastMasteryPrecombatCdActions
{
	#snapshot_stats
	#potion,name=prolonged_power
	if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
}

AddFunction BeastMasteryPrecombatCdPostConditions
{
}

### BeastMastery icons.

AddCheckBox(opt_hunter_beast_mastery_aoe L(AOE) default specialization=beast_mastery)

AddIcon checkbox=!opt_hunter_beast_mastery_aoe enemies=1 help=shortcd specialization=beast_mastery
{
	if not InCombat() BeastMasteryPrecombatShortCdActions()
	unless not InCombat() and BeastMasteryPrecombatShortCdPostConditions()
	{
		BeastMasteryDefaultShortCdActions()
	}
}

AddIcon checkbox=opt_hunter_beast_mastery_aoe help=shortcd specialization=beast_mastery
{
	if not InCombat() BeastMasteryPrecombatShortCdActions()
	unless not InCombat() and BeastMasteryPrecombatShortCdPostConditions()
	{
		BeastMasteryDefaultShortCdActions()
	}
}

AddIcon enemies=1 help=main specialization=beast_mastery
{
	if not InCombat() BeastMasteryPrecombatMainActions()
	unless not InCombat() and BeastMasteryPrecombatMainPostConditions()
	{
		BeastMasteryDefaultMainActions()
	}
}

AddIcon checkbox=opt_hunter_beast_mastery_aoe help=aoe specialization=beast_mastery
{
	if not InCombat() BeastMasteryPrecombatMainActions()
	unless not InCombat() and BeastMasteryPrecombatMainPostConditions()
	{
		BeastMasteryDefaultMainActions()
	}
}

AddIcon checkbox=!opt_hunter_beast_mastery_aoe enemies=1 help=cd specialization=beast_mastery
{
	if not InCombat() BeastMasteryPrecombatCdActions()
	unless not InCombat() and BeastMasteryPrecombatCdPostConditions()
	{
		BeastMasteryDefaultCdActions()
	}
}

AddIcon checkbox=opt_hunter_beast_mastery_aoe help=cd specialization=beast_mastery
{
	if not InCombat() BeastMasteryPrecombatCdActions()
	unless not InCombat() and BeastMasteryPrecombatCdPostConditions()
	{
		BeastMasteryDefaultCdActions()
	}
}

### Required symbols
# a_murder_of_crows
# arcane_torrent_focus
# aspect_of_the_wild
# barrage
# berserking
# bestial_wrath
# bestial_wrath_buff
# blood_fury_ap
# chimaera_shot
# cobra_shot
# counter_shot
# dire_beast
# dire_frenzy
# dire_frenzy_talent
# dire_stable_talent
# kill_command
# multishot
# pet_beast_cleave_buff
# pet_dire_frenzy_buff
# prolonged_power_potion
# quaking_palm
# revive_pet
# stampede
# the_mantle_of_command
# titans_thunder
# volley
# war_stomp
]]
    __Scripts.OvaleScripts:RegisterScript("HUNTER", "beast_mastery", name, desc, code, "script")
end
do
    local name = "simulationcraft_hunter_mm_t19p"
    local desc = "[7.0] SimulationCraft: Hunter_MM_T19P"
    local code = [[
# Based on SimulationCraft profile "Hunter_MM_T19P".
#	class=hunter
#	spec=marksmanship
#	talents=1303013

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_hunter_spells)


AddFunction pooling_for_piercing
{
	Talent(piercing_shot_talent) and SpellCooldown(piercing_shot) < 5 and target.DebuffRemaining(vulnerable) > 0 and target.DebuffRemaining(vulnerable) > SpellCooldown(piercing_shot) and { BuffExpires(trueshot_buff) or Enemies() == 1 }
}

AddFunction vuln_aim_casts
{
	if vuln_window() / ExecuteTime(aimed_shot) > 0 and vuln_window() / ExecuteTime(aimed_shot) > { Focus() + FocusCastingRegen(aimed_shot) * { vuln_window() / ExecuteTime(aimed_shot) - 1 } } / PowerCost(aimed_shot) { Focus() + FocusCastingRegen(aimed_shot) * { vuln_window() / ExecuteTime(aimed_shot) - 1 } } / PowerCost(aimed_shot)
	vuln_window() / ExecuteTime(aimed_shot)
}

AddFunction waiting_for_sentinel
{
	Talent(sentinel_talent) and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and not { not SpellCooldown(sentinel) > 0 } and { SpellCooldown(sentinel) > 54 and SpellCooldown(sentinel) < 54 + GCD() or SpellCooldown(sentinel) > 48 and SpellCooldown(sentinel) < 48 + GCD() or SpellCooldown(sentinel) > 42 and SpellCooldown(sentinel) < 42 + GCD() }
}

AddFunction vuln_window
{
	if Talent(sidewinders_talent) and { 24 - SpellCharges(sidewinders count=0) * 12 } * { 100 / { 100 + MeleeHaste() } } < target.DebuffPresent(vulnerability_debuff) { 24 - SpellCharges(sidewinders count=0) * 12 } * { 100 / { 100 + MeleeHaste() } }
	target.DebuffPresent(vulnerability_debuff)
}

AddFunction trueshot_cooldown
{
	if TimeInCombat() > 15 and not SpellCooldown(trueshot) > 0 and 0 == 0 TimeInCombat() * 1.1
}

AddFunction can_gcd
{
	vuln_window() > vuln_aim_casts() * ExecuteTime(aimed_shot) + GCD()
}

AddCheckBox(opt_interrupt L(interrupt) default specialization=marksmanship)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=marksmanship)
AddCheckBox(opt_volley SpellName(volley) default specialization=marksmanship)

AddFunction MarksmanshipInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
	{
		if target.InRange(counter_shot) and target.IsInterruptible() Spell(counter_shot)
		if target.Distance(less 8) and target.IsInterruptible() Spell(arcane_torrent_focus)
		if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
		if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
	}
}

AddFunction MarksmanshipSummonPet
{
	if not Talent(lone_wolf_talent)
	{
		if pet.IsDead()
		{
			if not DebuffPresent(heart_of_the_phoenix_debuff) Spell(heart_of_the_phoenix)
			Spell(revive_pet)
		}
		if not pet.Present() and not pet.IsDead() and not PreviousSpell(revive_pet) Texture(ability_hunter_beastcall help=L(summon_pet))
	}
}

### actions.default

AddFunction MarksmanshipDefaultMainActions
{
	#volley,toggle=on
	if CheckBoxOn(opt_volley) Spell(volley)
	#variable,name=pooling_for_piercing,value=talent.piercing_shot.enabled&cooldown.piercing_shot.remains<5&lowest_vuln_within.5>0&lowest_vuln_within.5>cooldown.piercing_shot.remains&(buff.trueshot.down|spell_targets=1)
	#variable,name=waiting_for_sentinel,value=talent.sentinel.enabled&(buff.marking_targets.up|buff.trueshot.up)&!cooldown.sentinel.up&((cooldown.sentinel.remains>54&cooldown.sentinel.remains<(54+gcd.max))|(cooldown.sentinel.remains>48&cooldown.sentinel.remains<(48+gcd.max))|(cooldown.sentinel.remains>42&cooldown.sentinel.remains<(42+gcd.max)))
	#call_action_list,name=cooldowns
	MarksmanshipCooldownsMainActions()

	unless MarksmanshipCooldownsMainPostConditions()
	{
		#call_action_list,name=targetdie,if=target.time_to_die<6&spell_targets.multishot=1
		if target.TimeToDie() < 6 and Enemies() == 1 MarksmanshipTargetdieMainActions()

		unless target.TimeToDie() < 6 and Enemies() == 1 and MarksmanshipTargetdieMainPostConditions()
		{
			#call_action_list,name=patient_sniper,if=talent.patient_sniper.enabled
			if Talent(patient_sniper_talent) MarksmanshipPatientSniperMainActions()

			unless Talent(patient_sniper_talent) and MarksmanshipPatientSniperMainPostConditions()
			{
				#call_action_list,name=non_patient_sniper,if=!talent.patient_sniper.enabled
				if not Talent(patient_sniper_talent) MarksmanshipNonPatientSniperMainActions()
			}
		}
	}
}

AddFunction MarksmanshipDefaultMainPostConditions
{
	MarksmanshipCooldownsMainPostConditions() or target.TimeToDie() < 6 and Enemies() == 1 and MarksmanshipTargetdieMainPostConditions() or Talent(patient_sniper_talent) and MarksmanshipPatientSniperMainPostConditions() or not Talent(patient_sniper_talent) and MarksmanshipNonPatientSniperMainPostConditions()
}

AddFunction MarksmanshipDefaultShortCdActions
{
	unless CheckBoxOn(opt_volley) and Spell(volley)
	{
		#variable,name=pooling_for_piercing,value=talent.piercing_shot.enabled&cooldown.piercing_shot.remains<5&lowest_vuln_within.5>0&lowest_vuln_within.5>cooldown.piercing_shot.remains&(buff.trueshot.down|spell_targets=1)
		#variable,name=waiting_for_sentinel,value=talent.sentinel.enabled&(buff.marking_targets.up|buff.trueshot.up)&!cooldown.sentinel.up&((cooldown.sentinel.remains>54&cooldown.sentinel.remains<(54+gcd.max))|(cooldown.sentinel.remains>48&cooldown.sentinel.remains<(48+gcd.max))|(cooldown.sentinel.remains>42&cooldown.sentinel.remains<(42+gcd.max)))
		#call_action_list,name=cooldowns
		MarksmanshipCooldownsShortCdActions()

		unless MarksmanshipCooldownsShortCdPostConditions()
		{
			#call_action_list,name=targetdie,if=target.time_to_die<6&spell_targets.multishot=1
			if target.TimeToDie() < 6 and Enemies() == 1 MarksmanshipTargetdieShortCdActions()

			unless target.TimeToDie() < 6 and Enemies() == 1 and MarksmanshipTargetdieShortCdPostConditions()
			{
				#call_action_list,name=patient_sniper,if=talent.patient_sniper.enabled
				if Talent(patient_sniper_talent) MarksmanshipPatientSniperShortCdActions()

				unless Talent(patient_sniper_talent) and MarksmanshipPatientSniperShortCdPostConditions()
				{
					#call_action_list,name=non_patient_sniper,if=!talent.patient_sniper.enabled
					if not Talent(patient_sniper_talent) MarksmanshipNonPatientSniperShortCdActions()
				}
			}
		}
	}
}

AddFunction MarksmanshipDefaultShortCdPostConditions
{
	CheckBoxOn(opt_volley) and Spell(volley) or MarksmanshipCooldownsShortCdPostConditions() or target.TimeToDie() < 6 and Enemies() == 1 and MarksmanshipTargetdieShortCdPostConditions() or Talent(patient_sniper_talent) and MarksmanshipPatientSniperShortCdPostConditions() or not Talent(patient_sniper_talent) and MarksmanshipNonPatientSniperShortCdPostConditions()
}

AddFunction MarksmanshipDefaultCdActions
{
	#auto_shot
	#counter_shot
	MarksmanshipInterruptActions()

	unless CheckBoxOn(opt_volley) and Spell(volley)
	{
		#variable,name=pooling_for_piercing,value=talent.piercing_shot.enabled&cooldown.piercing_shot.remains<5&lowest_vuln_within.5>0&lowest_vuln_within.5>cooldown.piercing_shot.remains&(buff.trueshot.down|spell_targets=1)
		#variable,name=waiting_for_sentinel,value=talent.sentinel.enabled&(buff.marking_targets.up|buff.trueshot.up)&!cooldown.sentinel.up&((cooldown.sentinel.remains>54&cooldown.sentinel.remains<(54+gcd.max))|(cooldown.sentinel.remains>48&cooldown.sentinel.remains<(48+gcd.max))|(cooldown.sentinel.remains>42&cooldown.sentinel.remains<(42+gcd.max)))
		#call_action_list,name=cooldowns
		MarksmanshipCooldownsCdActions()

		unless MarksmanshipCooldownsCdPostConditions()
		{
			#call_action_list,name=targetdie,if=target.time_to_die<6&spell_targets.multishot=1
			if target.TimeToDie() < 6 and Enemies() == 1 MarksmanshipTargetdieCdActions()

			unless target.TimeToDie() < 6 and Enemies() == 1 and MarksmanshipTargetdieCdPostConditions()
			{
				#call_action_list,name=patient_sniper,if=talent.patient_sniper.enabled
				if Talent(patient_sniper_talent) MarksmanshipPatientSniperCdActions()

				unless Talent(patient_sniper_talent) and MarksmanshipPatientSniperCdPostConditions()
				{
					#call_action_list,name=non_patient_sniper,if=!talent.patient_sniper.enabled
					if not Talent(patient_sniper_talent) MarksmanshipNonPatientSniperCdActions()
				}
			}
		}
	}
}

AddFunction MarksmanshipDefaultCdPostConditions
{
	CheckBoxOn(opt_volley) and Spell(volley) or MarksmanshipCooldownsCdPostConditions() or target.TimeToDie() < 6 and Enemies() == 1 and MarksmanshipTargetdieCdPostConditions() or Talent(patient_sniper_talent) and MarksmanshipPatientSniperCdPostConditions() or not Talent(patient_sniper_talent) and MarksmanshipNonPatientSniperCdPostConditions()
}

### actions.cooldowns

AddFunction MarksmanshipCooldownsMainActions
{
}

AddFunction MarksmanshipCooldownsMainPostConditions
{
}

AddFunction MarksmanshipCooldownsShortCdActions
{
}

AddFunction MarksmanshipCooldownsShortCdPostConditions
{
}

AddFunction MarksmanshipCooldownsCdActions
{
	#arcane_torrent,if=focus.deficit>=30&(!talent.sidewinders.enabled|cooldown.sidewinders.charges<2)
	if FocusDeficit() >= 30 and { not Talent(sidewinders_talent) or SpellCharges(sidewinders) < 2 } Spell(arcane_torrent_focus)
	#berserking,if=buff.trueshot.up
	if BuffPresent(trueshot_buff) Spell(berserking)
	#blood_fury,if=buff.trueshot.up
	if BuffPresent(trueshot_buff) Spell(blood_fury_ap)
	#potion,name=prolonged_power,if=spell_targets.multishot>2&((buff.trueshot.react&buff.bloodlust.react)|buff.bullseye.react>=23|target.time_to_die<62)
	if Enemies() > 2 and { BuffPresent(trueshot_buff) and BuffPresent(burst_haste_buff any=1) or BuffStacks(bullseye_buff) >= 23 or target.TimeToDie() < 62 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
	#potion,name=deadly_grace,if=(buff.trueshot.react&buff.bloodlust.react)|buff.bullseye.react>=23|target.time_to_die<31
	if { BuffPresent(trueshot_buff) and BuffPresent(burst_haste_buff any=1) or BuffStacks(bullseye_buff) >= 23 or target.TimeToDie() < 31 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(deadly_grace_potion usable=1)
	#variable,name=trueshot_cooldown,op=set,value=time*1.1,if=time>15&cooldown.trueshot.up&variable.trueshot_cooldown=0
	#trueshot,if=variable.trueshot_cooldown=0|buff.bloodlust.up|(variable.trueshot_cooldown>0&target.time_to_die>(variable.trueshot_cooldown+duration))|buff.bullseye.react>25|target.time_to_die<16
	if trueshot_cooldown() == 0 or BuffPresent(burst_haste_buff any=1) or trueshot_cooldown() > 0 and target.TimeToDie() > trueshot_cooldown() + BaseDuration(trueshot_buff) or BuffStacks(bullseye_buff) > 25 or target.TimeToDie() < 16 Spell(trueshot)
}

AddFunction MarksmanshipCooldownsCdPostConditions
{
}

### actions.non_patient_sniper

AddFunction MarksmanshipNonPatientSniperMainActions
{
	#aimed_shot,if=spell_targets>1&debuff.vulnerability.remains>cast_time&talent.trick_shot.enabled&buff.sentinels_sight.stack=20
	if Enemies() > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and BuffStacks(sentinels_sight_buff) == 20 Spell(aimed_shot)
	#marked_shot,if=spell_targets>1
	if Enemies() > 1 Spell(marked_shot)
	#multishot,if=spell_targets>1&(buff.marking_targets.up|buff.trueshot.up)
	if Enemies() > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } Spell(multishot)
	#black_arrow,if=talent.sidewinders.enabled|spell_targets.multishot<6
	if Talent(sidewinders_talent) or Enemies() < 6 Spell(black_arrow)
	#windburst
	Spell(windburst)
	#marked_shot,if=buff.marking_targets.up|buff.trueshot.up
	if BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) Spell(marked_shot)
	#sidewinders,if=!variable.waiting_for_sentinel&(debuff.hunters_mark.down|(buff.trueshot.down&buff.marking_targets.down))&((buff.marking_targets.up|buff.trueshot.up)|charges_fractional>1.8)&(focus.deficit>cast_regen)
	if not waiting_for_sentinel() and { target.DebuffExpires(hunters_mark_debuff) or BuffExpires(trueshot_buff) and BuffExpires(marking_targets_buff) } and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.8 } and FocusDeficit() > FocusCastingRegen(sidewinders) Spell(sidewinders)
	#aimed_shot,if=talent.sidewinders.enabled&debuff.vulnerability.remains>cast_time
	if Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) Spell(aimed_shot)
	#aimed_shot,if=!talent.sidewinders.enabled&debuff.vulnerability.remains>cast_time&(!variable.pooling_for_piercing|(buff.lock_and_load.up&lowest_vuln_within.5>gcd.max))&(spell_targets.multishot<4|talent.trick_shot.enabled|buff.sentinels_sight.stack=20)
	if not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or BuffPresent(lock_and_load_buff) and target.DebuffRemaining(vulnerable) > GCD() } and { Enemies() < 4 or Talent(trick_shot_talent) or BuffStacks(sentinels_sight_buff) == 20 } Spell(aimed_shot)
	#marked_shot
	Spell(marked_shot)
	#aimed_shot,if=talent.sidewinders.enabled&spell_targets.multi_shot=1&focus>110
	if Talent(sidewinders_talent) and Enemies() == 1 and Focus() > 110 Spell(aimed_shot)
	#multishot,if=spell_targets.multi_shot>1&!variable.waiting_for_sentinel
	if Enemies() > 1 and not waiting_for_sentinel() Spell(multishot)
	#arcane_shot,if=spell_targets.multi_shot<2&!variable.waiting_for_sentinel
	if Enemies() < 2 and not waiting_for_sentinel() Spell(arcane_shot)
}

AddFunction MarksmanshipNonPatientSniperMainPostConditions
{
}

AddFunction MarksmanshipNonPatientSniperShortCdActions
{
	#explosive_shot
	Spell(explosive_shot)
	#piercing_shot,if=lowest_vuln_within.5>0&focus>100
	if target.DebuffRemaining(vulnerable) > 0 and Focus() > 100 Spell(piercing_shot)

	unless Enemies() > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and BuffStacks(sentinels_sight_buff) == 20 and Spell(aimed_shot) or Enemies() > 1 and Spell(marked_shot) or Enemies() > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot)
	{
		#sentinel,if=!debuff.hunters_mark.up
		if not target.DebuffPresent(hunters_mark_debuff) Spell(sentinel)

		unless { Talent(sidewinders_talent) or Enemies() < 6 } and Spell(black_arrow)
		{
			#a_murder_of_crows
			Spell(a_murder_of_crows)

			unless Spell(windburst)
			{
				#barrage,if=spell_targets>2|(target.health.pct<20&buff.bullseye.stack<25)
				if Enemies() > 2 or target.HealthPercent() < 20 and BuffStacks(bullseye_buff) < 25 Spell(barrage)
			}
		}
	}
}

AddFunction MarksmanshipNonPatientSniperShortCdPostConditions
{
	Enemies() > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and BuffStacks(sentinels_sight_buff) == 20 and Spell(aimed_shot) or Enemies() > 1 and Spell(marked_shot) or Enemies() > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or { Talent(sidewinders_talent) or Enemies() < 6 } and Spell(black_arrow) or Spell(windburst) or { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(marked_shot) or not waiting_for_sentinel() and { target.DebuffExpires(hunters_mark_debuff) or BuffExpires(trueshot_buff) and BuffExpires(marking_targets_buff) } and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.8 } and FocusDeficit() > FocusCastingRegen(sidewinders) and Spell(sidewinders) or Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Spell(aimed_shot) or not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or BuffPresent(lock_and_load_buff) and target.DebuffRemaining(vulnerable) > GCD() } and { Enemies() < 4 or Talent(trick_shot_talent) or BuffStacks(sentinels_sight_buff) == 20 } and Spell(aimed_shot) or Spell(marked_shot) or Talent(sidewinders_talent) and Enemies() == 1 and Focus() > 110 and Spell(aimed_shot) or Enemies() > 1 and not waiting_for_sentinel() and Spell(multishot) or Enemies() < 2 and not waiting_for_sentinel() and Spell(arcane_shot)
}

AddFunction MarksmanshipNonPatientSniperCdActions
{
}

AddFunction MarksmanshipNonPatientSniperCdPostConditions
{
	Spell(explosive_shot) or target.DebuffRemaining(vulnerable) > 0 and Focus() > 100 and Spell(piercing_shot) or Enemies() > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and BuffStacks(sentinels_sight_buff) == 20 and Spell(aimed_shot) or Enemies() > 1 and Spell(marked_shot) or Enemies() > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or not target.DebuffPresent(hunters_mark_debuff) and Spell(sentinel) or { Talent(sidewinders_talent) or Enemies() < 6 } and Spell(black_arrow) or Spell(a_murder_of_crows) or Spell(windburst) or { Enemies() > 2 or target.HealthPercent() < 20 and BuffStacks(bullseye_buff) < 25 } and Spell(barrage) or { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(marked_shot) or not waiting_for_sentinel() and { target.DebuffExpires(hunters_mark_debuff) or BuffExpires(trueshot_buff) and BuffExpires(marking_targets_buff) } and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.8 } and FocusDeficit() > FocusCastingRegen(sidewinders) and Spell(sidewinders) or Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Spell(aimed_shot) or not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or BuffPresent(lock_and_load_buff) and target.DebuffRemaining(vulnerable) > GCD() } and { Enemies() < 4 or Talent(trick_shot_talent) or BuffStacks(sentinels_sight_buff) == 20 } and Spell(aimed_shot) or Spell(marked_shot) or Talent(sidewinders_talent) and Enemies() == 1 and Focus() > 110 and Spell(aimed_shot) or Enemies() > 1 and not waiting_for_sentinel() and Spell(multishot) or Enemies() < 2 and not waiting_for_sentinel() and Spell(arcane_shot)
}

### actions.patient_sniper

AddFunction MarksmanshipPatientSniperMainActions
{
	#aimed_shot,if=spell_targets>1&debuff.vulnerability.remains>cast_time&talent.trick_shot.enabled&(buff.sentinels_sight.stack=20|(buff.trueshot.up&buff.sentinels_sight.stack>=spell_targets.multishot*5))
	if Enemies() > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and { BuffStacks(sentinels_sight_buff) == 20 or BuffPresent(trueshot_buff) and BuffStacks(sentinels_sight_buff) >= Enemies() * 5 } Spell(aimed_shot)
	#marked_shot,if=spell_targets>1
	if Enemies() > 1 Spell(marked_shot)
	#multishot,if=spell_targets>1&(buff.marking_targets.up|buff.trueshot.up)
	if Enemies() > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } Spell(multishot)
	#windburst,if=variable.vuln_aim_casts<1&!variable.pooling_for_piercing
	if vuln_aim_casts() < 1 and not pooling_for_piercing() Spell(windburst)
	#black_arrow,if=variable.can_gcd&(talent.sidewinders.enabled|spell_targets.multishot<6)&(!variable.pooling_for_piercing|(lowest_vuln_within.5>gcd.max&focus>85))
	if can_gcd() and { Talent(sidewinders_talent) or Enemies() < 6 } and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() and Focus() > 85 } Spell(black_arrow)
	#aimed_shot,if=debuff.vulnerability.up&buff.lock_and_load.up&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)&(spell_targets.multi_shot<4|talent.trick_shot.enabled)
	if target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and { Enemies() < 4 or Talent(trick_shot_talent) } Spell(aimed_shot)
	#aimed_shot,if=spell_targets.multishot>1&debuff.vulnerability.remains>execute_time&(!variable.pooling_for_piercing|(focus>100&lowest_vuln_within.5>(execute_time+gcd.max)))&(spell_targets.multishot<4|buff.sentinels_sight.stack=20|talent.trick_shot.enabled)
	if Enemies() > 1 and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and { Enemies() < 4 or BuffStacks(sentinels_sight_buff) == 20 or Talent(trick_shot_talent) } Spell(aimed_shot)
	#multishot,if=spell_targets>1&variable.can_gcd&focus+cast_regen+action.aimed_shot.cast_regen<focus.max&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
	if Enemies() > 1 and can_gcd() and Focus() + FocusCastingRegen(multishot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } Spell(multishot)
	#arcane_shot,if=spell_targets.multi_shot=1&variable.vuln_aim_casts>0&variable.can_gcd&focus+cast_regen+action.aimed_shot.cast_regen<focus.max&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
	if Enemies() == 1 and vuln_aim_casts() > 0 and can_gcd() and Focus() + FocusCastingRegen(arcane_shot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } Spell(arcane_shot)
	#aimed_shot,if=talent.sidewinders.enabled&(debuff.vulnerability.remains>cast_time|(buff.lock_and_load.down&action.windburst.in_flight))&(variable.vuln_window-(execute_time*variable.vuln_aim_casts)<1|focus.deficit<25|buff.trueshot.up)&(spell_targets.multishot=1|focus>100)
	if Talent(sidewinders_talent) and { target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) or BuffExpires(lock_and_load_buff) and InFlightToTarget(windburst) } and { vuln_window() - ExecuteTime(aimed_shot) * vuln_aim_casts() < 1 or FocusDeficit() < 25 or BuffPresent(trueshot_buff) } and { Enemies() == 1 or Focus() > 100 } Spell(aimed_shot)
	#aimed_shot,if=!talent.sidewinders.enabled&debuff.vulnerability.remains>cast_time&(!variable.pooling_for_piercing|(focus>100&lowest_vuln_within.5>(execute_time+gcd.max)))
	if not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } Spell(aimed_shot)
	#marked_shot,if=!talent.sidewinders.enabled&!variable.pooling_for_piercing
	if not Talent(sidewinders_talent) and not pooling_for_piercing() Spell(marked_shot)
	#marked_shot,if=talent.sidewinders.enabled&(variable.vuln_aim_casts<1|buff.trueshot.up|variable.vuln_window<action.aimed_shot.cast_time)
	if Talent(sidewinders_talent) and { vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or vuln_window() < CastTime(aimed_shot) } Spell(marked_shot)
	#aimed_shot,if=spell_targets.multi_shot=1&focus>110
	if Enemies() == 1 and Focus() > 110 Spell(aimed_shot)
	#sidewinders,if=(!debuff.hunters_mark.up|(!buff.marking_targets.up&!buff.trueshot.up))&((buff.marking_targets.up&variable.vuln_aim_casts<1)|buff.trueshot.up|charges_fractional>1.9)
	if { not target.DebuffPresent(hunters_mark_debuff) or not BuffPresent(marking_targets_buff) and not BuffPresent(trueshot_buff) } and { BuffPresent(marking_targets_buff) and vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.9 } Spell(sidewinders)
	#arcane_shot,if=spell_targets.multi_shot=1&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
	if Enemies() == 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } Spell(arcane_shot)
	#multishot,if=spell_targets>1&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
	if Enemies() > 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } Spell(multishot)
}

AddFunction MarksmanshipPatientSniperMainPostConditions
{
}

AddFunction MarksmanshipPatientSniperShortCdActions
{
	#variable,name=vuln_window,op=set,value=debuff.vulnerability.remains
	#variable,name=vuln_window,op=set,value=(24-cooldown.sidewinders.charges_fractional*12)*attack_haste,if=talent.sidewinders.enabled&(24-cooldown.sidewinders.charges_fractional*12)*attack_haste<variable.vuln_window
	#variable,name=vuln_aim_casts,op=set,value=floor(variable.vuln_window%action.aimed_shot.execute_time)
	#variable,name=vuln_aim_casts,op=set,value=floor((focus+action.aimed_shot.cast_regen*(variable.vuln_aim_casts-1))%action.aimed_shot.cost),if=variable.vuln_aim_casts>0&variable.vuln_aim_casts>floor((focus+action.aimed_shot.cast_regen*(variable.vuln_aim_casts-1))%action.aimed_shot.cost)
	#variable,name=can_gcd,value=variable.vuln_window>variable.vuln_aim_casts*action.aimed_shot.execute_time+gcd.max
	#piercing_shot,if=cooldown.piercing_shot.up&spell_targets=1&lowest_vuln_within.5>0&lowest_vuln_within.5<1
	if not SpellCooldown(piercing_shot) > 0 and Enemies() == 1 and target.DebuffRemaining(vulnerable) > 0 and target.DebuffRemaining(vulnerable) < 1 Spell(piercing_shot)
	#piercing_shot,if=cooldown.piercing_shot.up&spell_targets>1&lowest_vuln_within.5>0&((!buff.trueshot.up&focus>80&(lowest_vuln_within.5<1|debuff.hunters_mark.up))|(buff.trueshot.up&focus>105&lowest_vuln_within.5<6))
	if not SpellCooldown(piercing_shot) > 0 and Enemies() > 1 and target.DebuffRemaining(vulnerable) > 0 and { not BuffPresent(trueshot_buff) and Focus() > 80 and { target.DebuffRemaining(vulnerable) < 1 or target.DebuffPresent(hunters_mark_debuff) } or BuffPresent(trueshot_buff) and Focus() > 105 and target.DebuffRemaining(vulnerable) < 6 } Spell(piercing_shot)

	unless Enemies() > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and { BuffStacks(sentinels_sight_buff) == 20 or BuffPresent(trueshot_buff) and BuffStacks(sentinels_sight_buff) >= Enemies() * 5 } and Spell(aimed_shot) or Enemies() > 1 and Spell(marked_shot) or Enemies() > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or vuln_aim_casts() < 1 and not pooling_for_piercing() and Spell(windburst) or can_gcd() and { Talent(sidewinders_talent) or Enemies() < 6 } and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() and Focus() > 85 } and Spell(black_arrow)
	{
		#a_murder_of_crows,if=(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)&(target.time_to_die>=cooldown+duration|target.health.pct<20|target.time_to_die<16)
		if { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and { target.TimeToDie() >= SpellCooldown(a_murder_of_crows) + BaseDuration(a_murder_of_crows_debuff) or target.HealthPercent() < 20 or target.TimeToDie() < 16 } Spell(a_murder_of_crows)
		#barrage,if=spell_targets>2|(target.health.pct<20&buff.bullseye.stack<25)
		if Enemies() > 2 or target.HealthPercent() < 20 and BuffStacks(bullseye_buff) < 25 Spell(barrage)
	}
}

AddFunction MarksmanshipPatientSniperShortCdPostConditions
{
	Enemies() > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and { BuffStacks(sentinels_sight_buff) == 20 or BuffPresent(trueshot_buff) and BuffStacks(sentinels_sight_buff) >= Enemies() * 5 } and Spell(aimed_shot) or Enemies() > 1 and Spell(marked_shot) or Enemies() > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or vuln_aim_casts() < 1 and not pooling_for_piercing() and Spell(windburst) or can_gcd() and { Talent(sidewinders_talent) or Enemies() < 6 } and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() and Focus() > 85 } and Spell(black_arrow) or target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and { Enemies() < 4 or Talent(trick_shot_talent) } and Spell(aimed_shot) or Enemies() > 1 and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and { Enemies() < 4 or BuffStacks(sentinels_sight_buff) == 20 or Talent(trick_shot_talent) } and Spell(aimed_shot) or Enemies() > 1 and can_gcd() and Focus() + FocusCastingRegen(multishot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(multishot) or Enemies() == 1 and vuln_aim_casts() > 0 and can_gcd() and Focus() + FocusCastingRegen(arcane_shot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(arcane_shot) or Talent(sidewinders_talent) and { target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) or BuffExpires(lock_and_load_buff) and InFlightToTarget(windburst) } and { vuln_window() - ExecuteTime(aimed_shot) * vuln_aim_casts() < 1 or FocusDeficit() < 25 or BuffPresent(trueshot_buff) } and { Enemies() == 1 or Focus() > 100 } and Spell(aimed_shot) or not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and Spell(aimed_shot) or not Talent(sidewinders_talent) and not pooling_for_piercing() and Spell(marked_shot) or Talent(sidewinders_talent) and { vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or vuln_window() < CastTime(aimed_shot) } and Spell(marked_shot) or Enemies() == 1 and Focus() > 110 and Spell(aimed_shot) or { not target.DebuffPresent(hunters_mark_debuff) or not BuffPresent(marking_targets_buff) and not BuffPresent(trueshot_buff) } and { BuffPresent(marking_targets_buff) and vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.9 } and Spell(sidewinders) or Enemies() == 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(arcane_shot) or Enemies() > 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(multishot)
}

AddFunction MarksmanshipPatientSniperCdActions
{
}

AddFunction MarksmanshipPatientSniperCdPostConditions
{
	not SpellCooldown(piercing_shot) > 0 and Enemies() == 1 and target.DebuffRemaining(vulnerable) > 0 and target.DebuffRemaining(vulnerable) < 1 and Spell(piercing_shot) or not SpellCooldown(piercing_shot) > 0 and Enemies() > 1 and target.DebuffRemaining(vulnerable) > 0 and { not BuffPresent(trueshot_buff) and Focus() > 80 and { target.DebuffRemaining(vulnerable) < 1 or target.DebuffPresent(hunters_mark_debuff) } or BuffPresent(trueshot_buff) and Focus() > 105 and target.DebuffRemaining(vulnerable) < 6 } and Spell(piercing_shot) or Enemies() > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and { BuffStacks(sentinels_sight_buff) == 20 or BuffPresent(trueshot_buff) and BuffStacks(sentinels_sight_buff) >= Enemies() * 5 } and Spell(aimed_shot) or Enemies() > 1 and Spell(marked_shot) or Enemies() > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or vuln_aim_casts() < 1 and not pooling_for_piercing() and Spell(windburst) or can_gcd() and { Talent(sidewinders_talent) or Enemies() < 6 } and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() and Focus() > 85 } and Spell(black_arrow) or { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and { target.TimeToDie() >= SpellCooldown(a_murder_of_crows) + BaseDuration(a_murder_of_crows_debuff) or target.HealthPercent() < 20 or target.TimeToDie() < 16 } and Spell(a_murder_of_crows) or { Enemies() > 2 or target.HealthPercent() < 20 and BuffStacks(bullseye_buff) < 25 } and Spell(barrage) or target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and { Enemies() < 4 or Talent(trick_shot_talent) } and Spell(aimed_shot) or Enemies() > 1 and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and { Enemies() < 4 or BuffStacks(sentinels_sight_buff) == 20 or Talent(trick_shot_talent) } and Spell(aimed_shot) or Enemies() > 1 and can_gcd() and Focus() + FocusCastingRegen(multishot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(multishot) or Enemies() == 1 and vuln_aim_casts() > 0 and can_gcd() and Focus() + FocusCastingRegen(arcane_shot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(arcane_shot) or Talent(sidewinders_talent) and { target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) or BuffExpires(lock_and_load_buff) and InFlightToTarget(windburst) } and { vuln_window() - ExecuteTime(aimed_shot) * vuln_aim_casts() < 1 or FocusDeficit() < 25 or BuffPresent(trueshot_buff) } and { Enemies() == 1 or Focus() > 100 } and Spell(aimed_shot) or not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and Spell(aimed_shot) or not Talent(sidewinders_talent) and not pooling_for_piercing() and Spell(marked_shot) or Talent(sidewinders_talent) and { vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or vuln_window() < CastTime(aimed_shot) } and Spell(marked_shot) or Enemies() == 1 and Focus() > 110 and Spell(aimed_shot) or { not target.DebuffPresent(hunters_mark_debuff) or not BuffPresent(marking_targets_buff) and not BuffPresent(trueshot_buff) } and { BuffPresent(marking_targets_buff) and vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.9 } and Spell(sidewinders) or Enemies() == 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(arcane_shot) or Enemies() > 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(multishot)
}

### actions.precombat

AddFunction MarksmanshipPrecombatMainActions
{
	#augmentation,type=defiled
	#windburst
	Spell(windburst)
}

AddFunction MarksmanshipPrecombatMainPostConditions
{
}

AddFunction MarksmanshipPrecombatShortCdActions
{
	#flask,type=flask_of_the_seventh_demon
	#food,type=nightborne_delicacy_platter
	#summon_pet
	MarksmanshipSummonPet()
}

AddFunction MarksmanshipPrecombatShortCdPostConditions
{
	Spell(windburst)
}

AddFunction MarksmanshipPrecombatCdActions
{
	#snapshot_stats
	#potion,name=prolonged_power,if=spell_targets.multi_shot>2
	if Enemies() > 2 and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
	#potion,name=deadly_grace
	if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(deadly_grace_potion usable=1)
}

AddFunction MarksmanshipPrecombatCdPostConditions
{
	Spell(windburst)
}

### actions.targetdie

AddFunction MarksmanshipTargetdieMainActions
{
	#windburst
	Spell(windburst)
	#aimed_shot,if=debuff.vulnerability.up&buff.lock_and_load.up
	if target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) Spell(aimed_shot)
	#marked_shot
	Spell(marked_shot)
	#arcane_shot,if=buff.marking_targets.up|buff.trueshot.up
	if BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) Spell(arcane_shot)
	#aimed_shot,if=debuff.vulnerability.remains>execute_time&target.time_to_die>cast_time
	if target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and target.TimeToDie() > CastTime(aimed_shot) Spell(aimed_shot)
	#sidewinders
	Spell(sidewinders)
	#arcane_shot
	Spell(arcane_shot)
}

AddFunction MarksmanshipTargetdieMainPostConditions
{
}

AddFunction MarksmanshipTargetdieShortCdActions
{
	#piercing_shot,if=debuff.vulnerability.up
	if target.DebuffPresent(vulnerability_debuff) Spell(piercing_shot)
	#explosive_shot
	Spell(explosive_shot)
}

AddFunction MarksmanshipTargetdieShortCdPostConditions
{
	Spell(windburst) or target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) and Spell(aimed_shot) or Spell(marked_shot) or { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(arcane_shot) or target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and target.TimeToDie() > CastTime(aimed_shot) and Spell(aimed_shot) or Spell(sidewinders) or Spell(arcane_shot)
}

AddFunction MarksmanshipTargetdieCdActions
{
}

AddFunction MarksmanshipTargetdieCdPostConditions
{
	target.DebuffPresent(vulnerability_debuff) and Spell(piercing_shot) or Spell(explosive_shot) or Spell(windburst) or target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) and Spell(aimed_shot) or Spell(marked_shot) or { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(arcane_shot) or target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and target.TimeToDie() > CastTime(aimed_shot) and Spell(aimed_shot) or Spell(sidewinders) or Spell(arcane_shot)
}

### Marksmanship icons.

AddCheckBox(opt_hunter_marksmanship_aoe L(AOE) default specialization=marksmanship)

AddIcon checkbox=!opt_hunter_marksmanship_aoe enemies=1 help=shortcd specialization=marksmanship
{
	if not InCombat() MarksmanshipPrecombatShortCdActions()
	unless not InCombat() and MarksmanshipPrecombatShortCdPostConditions()
	{
		MarksmanshipDefaultShortCdActions()
	}
}

AddIcon checkbox=opt_hunter_marksmanship_aoe help=shortcd specialization=marksmanship
{
	if not InCombat() MarksmanshipPrecombatShortCdActions()
	unless not InCombat() and MarksmanshipPrecombatShortCdPostConditions()
	{
		MarksmanshipDefaultShortCdActions()
	}
}

AddIcon enemies=1 help=main specialization=marksmanship
{
	if not InCombat() MarksmanshipPrecombatMainActions()
	unless not InCombat() and MarksmanshipPrecombatMainPostConditions()
	{
		MarksmanshipDefaultMainActions()
	}
}

AddIcon checkbox=opt_hunter_marksmanship_aoe help=aoe specialization=marksmanship
{
	if not InCombat() MarksmanshipPrecombatMainActions()
	unless not InCombat() and MarksmanshipPrecombatMainPostConditions()
	{
		MarksmanshipDefaultMainActions()
	}
}

AddIcon checkbox=!opt_hunter_marksmanship_aoe enemies=1 help=cd specialization=marksmanship
{
	if not InCombat() MarksmanshipPrecombatCdActions()
	unless not InCombat() and MarksmanshipPrecombatCdPostConditions()
	{
		MarksmanshipDefaultCdActions()
	}
}

AddIcon checkbox=opt_hunter_marksmanship_aoe help=cd specialization=marksmanship
{
	if not InCombat() MarksmanshipPrecombatCdActions()
	unless not InCombat() and MarksmanshipPrecombatCdPostConditions()
	{
		MarksmanshipDefaultCdActions()
	}
}

### Required symbols
# a_murder_of_crows
# a_murder_of_crows_debuff
# aimed_shot
# arcane_shot
# arcane_torrent_focus
# barrage
# berserking
# black_arrow
# blood_fury_ap
# bullseye_buff
# counter_shot
# deadly_grace_potion
# explosive_shot
# hunters_mark_debuff
# lock_and_load_buff
# lone_wolf_talent
# marked_shot
# marking_targets_buff
# multishot
# patient_sniper_talent
# piercing_shot
# piercing_shot_talent
# prolonged_power_potion
# quaking_palm
# revive_pet
# sentinel
# sentinel_talent
# sentinels_sight_buff
# sidewinders
# sidewinders_talent
# trick_shot_talent
# trueshot
# trueshot_buff
# volley
# vulnerability_debuff
# vulnerable
# war_stomp
# windburst
]]
    __Scripts.OvaleScripts:RegisterScript("HUNTER", "marksmanship", name, desc, code, "script")
end
do
    local name = "simulationcraft_hunter_sv_t19p"
    local desc = "[7.0] SimulationCraft: Hunter_SV_T19P"
    local code = [[
# Based on SimulationCraft profile "Hunter_SV_T19P".
#	class=hunter
#	spec=survival
#	talents=3101031

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_hunter_spells)

AddCheckBox(opt_interrupt L(interrupt) default specialization=survival)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=survival)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=survival)
AddCheckBox(opt_trap_launcher SpellName(trap_launcher) default specialization=survival)

AddFunction SurvivalInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
	{
		if target.InRange(muzzle) and target.IsInterruptible() Spell(muzzle)
		if target.Distance(less 8) and target.IsInterruptible() Spell(arcane_torrent_focus)
		if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
		if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
	}
}

AddFunction SurvivalUseItemActions
{
	Item(Trinket0Slot text=13 usable=1)
	Item(Trinket1Slot text=14 usable=1)
}

AddFunction SurvivalSummonPet
{
	if not Talent(lone_wolf_talent)
	{
		if pet.IsDead()
		{
			if not DebuffPresent(heart_of_the_phoenix_debuff) Spell(heart_of_the_phoenix)
			Spell(revive_pet)
		}
		if not pet.Present() and not pet.IsDead() and not PreviousSpell(revive_pet) Texture(ability_hunter_beastcall help=L(summon_pet))
	}
}

AddFunction SurvivalGetInMeleeRange
{
	if CheckBoxOn(opt_melee_range) and not target.InRange(raptor_strike)
	{
		Texture(misc_arrowlup help=L(not_in_melee_range))
	}
}

### actions.default

AddFunction SurvivalDefaultMainActions
{
	#call_action_list,name=moknathal,if=talent.way_of_the_moknathal.enabled
	if Talent(way_of_the_moknathal_talent) SurvivalMoknathalMainActions()

	unless Talent(way_of_the_moknathal_talent) and SurvivalMoknathalMainPostConditions()
	{
		#call_action_list,name=nomok,if=!talent.way_of_the_moknathal.enabled
		if not Talent(way_of_the_moknathal_talent) SurvivalNomokMainActions()
	}
}

AddFunction SurvivalDefaultMainPostConditions
{
	Talent(way_of_the_moknathal_talent) and SurvivalMoknathalMainPostConditions() or not Talent(way_of_the_moknathal_talent) and SurvivalNomokMainPostConditions()
}

AddFunction SurvivalDefaultShortCdActions
{
	#auto_attack
	SurvivalGetInMeleeRange()
	#call_action_list,name=moknathal,if=talent.way_of_the_moknathal.enabled
	if Talent(way_of_the_moknathal_talent) SurvivalMoknathalShortCdActions()

	unless Talent(way_of_the_moknathal_talent) and SurvivalMoknathalShortCdPostConditions()
	{
		#call_action_list,name=nomok,if=!talent.way_of_the_moknathal.enabled
		if not Talent(way_of_the_moknathal_talent) SurvivalNomokShortCdActions()
	}
}

AddFunction SurvivalDefaultShortCdPostConditions
{
	Talent(way_of_the_moknathal_talent) and SurvivalMoknathalShortCdPostConditions() or not Talent(way_of_the_moknathal_talent) and SurvivalNomokShortCdPostConditions()
}

AddFunction SurvivalDefaultCdActions
{
	#muzzle
	SurvivalInterruptActions()
	#use_item,name=tirathons_betrayal
	SurvivalUseItemActions()
	#arcane_torrent,if=focus.deficit>=30
	if FocusDeficit() >= 30 Spell(arcane_torrent_focus)
	#berserking,if=(buff.spitting_cobra.up&buff.mongoose_fury.stack>2&buff.aspect_of_the_eagle.up)|(!talent.spitting_cobra.enabled&buff.aspect_of_the_eagle.up)
	if BuffPresent(spitting_cobra_buff) and BuffStacks(mongoose_fury_buff) > 2 and BuffPresent(aspect_of_the_eagle_buff) or not Talent(spitting_cobra_talent) and BuffPresent(aspect_of_the_eagle_buff) Spell(berserking)
	#blood_fury,if=(buff.spitting_cobra.up&buff.mongoose_fury.stack>2&buff.aspect_of_the_eagle.up)|(!talent.spitting_cobra.enabled&buff.aspect_of_the_eagle.up)
	if BuffPresent(spitting_cobra_buff) and BuffStacks(mongoose_fury_buff) > 2 and BuffPresent(aspect_of_the_eagle_buff) or not Talent(spitting_cobra_talent) and BuffPresent(aspect_of_the_eagle_buff) Spell(blood_fury_ap)
	#potion,name=prolonged_power,if=(talent.spitting_cobra.enabled&buff.spitting_cobra.remains)|(!talent.spitting_cobra.enabled&buff.aspect_of_the_eagle.remains)
	if { Talent(spitting_cobra_talent) and BuffPresent(spitting_cobra_buff) or not Talent(spitting_cobra_talent) and BuffPresent(aspect_of_the_eagle_buff) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
	#call_action_list,name=moknathal,if=talent.way_of_the_moknathal.enabled
	if Talent(way_of_the_moknathal_talent) SurvivalMoknathalCdActions()

	unless Talent(way_of_the_moknathal_talent) and SurvivalMoknathalCdPostConditions()
	{
		#call_action_list,name=nomok,if=!talent.way_of_the_moknathal.enabled
		if not Talent(way_of_the_moknathal_talent) SurvivalNomokCdActions()
	}
}

AddFunction SurvivalDefaultCdPostConditions
{
	Talent(way_of_the_moknathal_talent) and SurvivalMoknathalCdPostConditions() or not Talent(way_of_the_moknathal_talent) and SurvivalNomokCdPostConditions()
}

### actions.moknathal

AddFunction SurvivalMoknathalMainActions
{
	#raptor_strike,if=buff.moknathal_tactics.stack<=1
	if BuffStacks(moknathal_tactics_buff) <= 1 Spell(raptor_strike)
	#raptor_strike,if=buff.moknathal_tactics.remains<gcd
	if BuffRemaining(moknathal_tactics_buff) < GCD() Spell(raptor_strike)
	#raptor_strike,if=buff.mongoose_fury.stack>=4&buff.mongoose_fury.remains>gcd&buff.moknathal_tactics.stack>=3&buff.moknathal_tactics.remains<4&cooldown.fury_of_the_eagle.remains<buff.mongoose_fury.remains
	if BuffStacks(mongoose_fury_buff) >= 4 and BuffRemaining(mongoose_fury_buff) > GCD() and BuffStacks(moknathal_tactics_buff) >= 3 and BuffRemaining(moknathal_tactics_buff) < 4 and SpellCooldown(fury_of_the_eagle) < BuffRemaining(mongoose_fury_buff) Spell(raptor_strike)
	#flanking_strike,if=cooldown.mongoose_bite.charges<=1&focus>75-buff.moknathal_tactics.remains*focus.regen
	if SpellCharges(mongoose_bite) <= 1 and Focus() > 75 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() Spell(flanking_strike)
	#carve,if=equipped.frizzos_fingertrap&dot.lacerate.ticking&dot.lacerate.refreshable&focus>65-buff.moknathal_tactics.remains*focus.regen&buff.mongoose_fury.remains>=gcd
	if HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffRemaining(mongoose_fury_buff) >= GCD() Spell(carve)
	#butchery,if=equipped.frizzos_fingertrap&dot.lacerate.ticking&dot.lacerate.refreshable&focus>65-buff.moknathal_tactics.remains*focus.regen&buff.mongoose_fury.remains>=gcd
	if HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffRemaining(mongoose_fury_buff) >= GCD() Spell(butchery)
	#lacerate,if=refreshable&((focus>55-buff.moknathal_tactics.remains*focus.regen&buff.mongoose_fury.duration>=gcd&cooldown.mongoose_bite.charges=0&buff.mongoose_fury.stack<3)|(focus>65-buff.moknathal_tactics.remains*focus.regen&buff.mongoose_fury.down&cooldown.mongoose_bite.charges<3))
	if target.Refreshable(lacerate_debuff) and { Focus() > 55 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) == 0 and BuffStacks(mongoose_fury_buff) < 3 or Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffExpires(mongoose_fury_buff) and SpellCharges(mongoose_bite) < 3 } Spell(lacerate)
	#caltrops,if=(buff.mongoose_fury.duration>=gcd&buff.mongoose_fury.stack<1&!dot.caltrops.ticking)
	if BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 1 and not target.DebuffPresent(caltrops_debuff) Spell(caltrops)
	#butchery,if=active_enemies>1&focus>65-buff.moknathal_tactics.remains*focus.regen&(buff.mongoose_fury.down|buff.mongoose_fury.remains>gcd*cooldown.mongoose_bite.charges)
	if Enemies() > 1 and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and { BuffExpires(mongoose_fury_buff) or BuffRemaining(mongoose_fury_buff) > GCD() * SpellCharges(mongoose_bite) } Spell(butchery)
	#carve,if=active_enemies>1&focus>65-buff.moknathal_tactics.remains*focus.regen&(buff.mongoose_fury.down&focus>65-buff.moknathal_tactics.remains*focus.regen|buff.mongoose_fury.remains>gcd*cooldown.mongoose_bite.charges&focus>70-buff.moknathal_tactics.remains*focus.regen)
	if Enemies() > 1 and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and { BuffExpires(mongoose_fury_buff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() or BuffRemaining(mongoose_fury_buff) > GCD() * SpellCharges(mongoose_bite) and Focus() > 70 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() } Spell(carve)
	#raptor_strike,if=buff.moknathal_tactics.stack=2
	if BuffStacks(moknathal_tactics_buff) == 2 Spell(raptor_strike)
	#raptor_strike,if=buff.moknathal_tactics.remains<4&buff.mongoose_fury.stack=6&buff.mongoose_fury.remains>cooldown.fury_of_the_eagle.remains&cooldown.fury_of_the_eagle.remains<=5
	if BuffRemaining(moknathal_tactics_buff) < 4 and BuffStacks(mongoose_fury_buff) == 6 and BuffRemaining(mongoose_fury_buff) > SpellCooldown(fury_of_the_eagle) and SpellCooldown(fury_of_the_eagle) <= 5 Spell(raptor_strike)
	#mongoose_bite,if=buff.aspect_of_the_eagle.up&buff.mongoose_fury.up&buff.moknathal_tactics.stack>=4
	if BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and BuffStacks(moknathal_tactics_buff) >= 4 Spell(mongoose_bite)
	#raptor_strike,if=buff.mongoose_fury.up&buff.mongoose_fury.remains<=3*gcd&buff.moknathal_tactics.remains<4+gcd&cooldown.fury_of_the_eagle.remains<gcd
	if BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) <= 3 * GCD() and BuffRemaining(moknathal_tactics_buff) < 4 + GCD() and SpellCooldown(fury_of_the_eagle) < GCD() Spell(raptor_strike)
	#mongoose_bite,if=buff.mongoose_fury.up&buff.mongoose_fury.remains<cooldown.aspect_of_the_eagle.remains
	if BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) Spell(mongoose_bite)
	#caltrops,if=(!dot.caltrops.ticking)
	if not target.DebuffPresent(caltrops_debuff) Spell(caltrops)
	#carve,if=equipped.frizzos_fingertrap&dot.lacerate.ticking&dot.lacerate.refreshable&focus>65-buff.moknathal_tactics.remains*focus.regen
	if HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() Spell(carve)
	#butchery,if=equipped.frizzos_fingertrap&dot.lacerate.ticking&dot.lacerate.refreshable&focus>65-buff.moknathal_tactics.remains*focus.regen
	if HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() Spell(butchery)
	#lacerate,if=refreshable&focus>55-buff.moknathal_tactics.remains*focus.regen
	if target.Refreshable(lacerate_debuff) and Focus() > 55 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() Spell(lacerate)
	#mongoose_bite,if=(charges>=2&cooldown.mongoose_bite.remains<=gcd|charges=3)
	if Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) <= GCD() or Charges(mongoose_bite) == 3 Spell(mongoose_bite)
	#flanking_strike
	Spell(flanking_strike)
	#butchery,if=focus>65-buff.moknathal_tactics.remains*focus.regen
	if Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() Spell(butchery)
	#raptor_strike,if=focus>75-cooldown.flanking_strike.remains*focus.regen
	if Focus() > 75 - SpellCooldown(flanking_strike) * FocusRegenRate() Spell(raptor_strike)
}

AddFunction SurvivalMoknathalMainPostConditions
{
}

AddFunction SurvivalMoknathalShortCdActions
{
	unless BuffStacks(moknathal_tactics_buff) <= 1 and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) < GCD() and Spell(raptor_strike)
	{
		#fury_of_the_eagle,if=buff.mongoose_fury.stack>=4&buff.mongoose_fury.remains<gcd
		if BuffStacks(mongoose_fury_buff) >= 4 and BuffRemaining(mongoose_fury_buff) < GCD() Spell(fury_of_the_eagle)

		unless BuffStacks(mongoose_fury_buff) >= 4 and BuffRemaining(mongoose_fury_buff) > GCD() and BuffStacks(moknathal_tactics_buff) >= 3 and BuffRemaining(moknathal_tactics_buff) < 4 and SpellCooldown(fury_of_the_eagle) < BuffRemaining(mongoose_fury_buff) and Spell(raptor_strike)
		{
			#snake_hunter,if=cooldown.mongoose_bite.charges<=0&buff.mongoose_fury.remains>3*gcd&time>15
			if SpellCharges(mongoose_bite) <= 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and TimeInCombat() > 15 Spell(snake_hunter)
			#spitting_cobra,if=buff.mongoose_fury.duration>=gcd&cooldown.mongoose_bite.charges>=0&buff.mongoose_fury.stack<4&buff.moknathal_tactics.stack=3
			if BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and BuffStacks(moknathal_tactics_buff) == 3 Spell(spitting_cobra)
			#steel_trap,if=buff.mongoose_fury.duration>=gcd&buff.mongoose_fury.stack<1
			if BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 1 and CheckBoxOn(opt_trap_launcher) Spell(steel_trap)
			#a_murder_of_crows,if=focus>55-buff.moknathal_tactics.remains*focus.regen&buff.mongoose_fury.stack<4&buff.mongoose_fury.duration>=gcd
			if Focus() > 55 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffStacks(mongoose_fury_buff) < 4 and BaseDuration(mongoose_fury_buff) >= GCD() Spell(a_murder_of_crows)

			unless SpellCharges(mongoose_bite) <= 1 and Focus() > 75 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(flanking_strike) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(carve) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(butchery) or target.Refreshable(lacerate_debuff) and { Focus() > 55 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) == 0 and BuffStacks(mongoose_fury_buff) < 3 or Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffExpires(mongoose_fury_buff) and SpellCharges(mongoose_bite) < 3 } and Spell(lacerate) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 1 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops)
			{
				#explosive_trap,if=buff.mongoose_fury.duration>=gcd&cooldown.mongoose_bite.charges=0&buff.mongoose_fury.stack<1
				if BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) == 0 and BuffStacks(mongoose_fury_buff) < 1 and CheckBoxOn(opt_trap_launcher) Spell(explosive_trap)

				unless Enemies() > 1 and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and { BuffExpires(mongoose_fury_buff) or BuffRemaining(mongoose_fury_buff) > GCD() * SpellCharges(mongoose_bite) } and Spell(butchery) or Enemies() > 1 and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and { BuffExpires(mongoose_fury_buff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() or BuffRemaining(mongoose_fury_buff) > GCD() * SpellCharges(mongoose_bite) and Focus() > 70 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() } and Spell(carve) or BuffStacks(moknathal_tactics_buff) == 2 and Spell(raptor_strike)
				{
					#dragonsfire_grenade,if=buff.mongoose_fury.duration>=gcd&cooldown.mongoose_bite.charges>=0&buff.mongoose_fury.stack<1
					if BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 1 Spell(dragonsfire_grenade)

					unless BuffRemaining(moknathal_tactics_buff) < 4 and BuffStacks(mongoose_fury_buff) == 6 and BuffRemaining(mongoose_fury_buff) > SpellCooldown(fury_of_the_eagle) and SpellCooldown(fury_of_the_eagle) <= 5 and Spell(raptor_strike)
					{
						#fury_of_the_eagle,if=buff.moknathal_tactics.remains>4&buff.mongoose_fury.stack=6&cooldown.mongoose_bite.charges<=1
						if BuffRemaining(moknathal_tactics_buff) > 4 and BuffStacks(mongoose_fury_buff) == 6 and SpellCharges(mongoose_bite) <= 1 Spell(fury_of_the_eagle)

						unless BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and BuffStacks(moknathal_tactics_buff) >= 4 and Spell(mongoose_bite) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) <= 3 * GCD() and BuffRemaining(moknathal_tactics_buff) < 4 + GCD() and SpellCooldown(fury_of_the_eagle) < GCD() and Spell(raptor_strike)
						{
							#fury_of_the_eagle,if=buff.mongoose_fury.up&buff.mongoose_fury.remains<=2*gcd
							if BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) <= 2 * GCD() Spell(fury_of_the_eagle)

							unless BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) and Spell(mongoose_bite)
							{
								#spitting_cobra
								Spell(spitting_cobra)
								#steel_trap
								if CheckBoxOn(opt_trap_launcher) Spell(steel_trap)
								#a_murder_of_crows,if=focus>55-buff.moknathal_tactics.remains*focus.regen
								if Focus() > 55 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() Spell(a_murder_of_crows)

								unless not target.DebuffPresent(caltrops_debuff) and Spell(caltrops)
								{
									#explosive_trap
									if CheckBoxOn(opt_trap_launcher) Spell(explosive_trap)

									unless HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(carve) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(butchery) or target.Refreshable(lacerate_debuff) and Focus() > 55 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(lacerate)
									{
										#dragonsfire_grenade
										Spell(dragonsfire_grenade)
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

AddFunction SurvivalMoknathalShortCdPostConditions
{
	BuffStacks(moknathal_tactics_buff) <= 1 and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) < GCD() and Spell(raptor_strike) or BuffStacks(mongoose_fury_buff) >= 4 and BuffRemaining(mongoose_fury_buff) > GCD() and BuffStacks(moknathal_tactics_buff) >= 3 and BuffRemaining(moknathal_tactics_buff) < 4 and SpellCooldown(fury_of_the_eagle) < BuffRemaining(mongoose_fury_buff) and Spell(raptor_strike) or SpellCharges(mongoose_bite) <= 1 and Focus() > 75 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(flanking_strike) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(carve) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(butchery) or target.Refreshable(lacerate_debuff) and { Focus() > 55 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) == 0 and BuffStacks(mongoose_fury_buff) < 3 or Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffExpires(mongoose_fury_buff) and SpellCharges(mongoose_bite) < 3 } and Spell(lacerate) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 1 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or Enemies() > 1 and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and { BuffExpires(mongoose_fury_buff) or BuffRemaining(mongoose_fury_buff) > GCD() * SpellCharges(mongoose_bite) } and Spell(butchery) or Enemies() > 1 and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and { BuffExpires(mongoose_fury_buff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() or BuffRemaining(mongoose_fury_buff) > GCD() * SpellCharges(mongoose_bite) and Focus() > 70 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() } and Spell(carve) or BuffStacks(moknathal_tactics_buff) == 2 and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) < 4 and BuffStacks(mongoose_fury_buff) == 6 and BuffRemaining(mongoose_fury_buff) > SpellCooldown(fury_of_the_eagle) and SpellCooldown(fury_of_the_eagle) <= 5 and Spell(raptor_strike) or BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and BuffStacks(moknathal_tactics_buff) >= 4 and Spell(mongoose_bite) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) <= 3 * GCD() and BuffRemaining(moknathal_tactics_buff) < 4 + GCD() and SpellCooldown(fury_of_the_eagle) < GCD() and Spell(raptor_strike) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) and Spell(mongoose_bite) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(carve) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(butchery) or target.Refreshable(lacerate_debuff) and Focus() > 55 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(lacerate) or { Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) <= GCD() or Charges(mongoose_bite) == 3 } and Spell(mongoose_bite) or Spell(flanking_strike) or Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(butchery) or Focus() > 75 - SpellCooldown(flanking_strike) * FocusRegenRate() and Spell(raptor_strike)
}

AddFunction SurvivalMoknathalCdActions
{
	unless BuffStacks(moknathal_tactics_buff) <= 1 and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) < GCD() and Spell(raptor_strike) or BuffStacks(mongoose_fury_buff) >= 4 and BuffRemaining(mongoose_fury_buff) < GCD() and Spell(fury_of_the_eagle) or BuffStacks(mongoose_fury_buff) >= 4 and BuffRemaining(mongoose_fury_buff) > GCD() and BuffStacks(moknathal_tactics_buff) >= 3 and BuffRemaining(moknathal_tactics_buff) < 4 and SpellCooldown(fury_of_the_eagle) < BuffRemaining(mongoose_fury_buff) and Spell(raptor_strike) or SpellCharges(mongoose_bite) <= 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and TimeInCombat() > 15 and Spell(snake_hunter) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and BuffStacks(moknathal_tactics_buff) == 3 and Spell(spitting_cobra) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 1 and CheckBoxOn(opt_trap_launcher) and Spell(steel_trap) or Focus() > 55 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffStacks(mongoose_fury_buff) < 4 and BaseDuration(mongoose_fury_buff) >= GCD() and Spell(a_murder_of_crows) or SpellCharges(mongoose_bite) <= 1 and Focus() > 75 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(flanking_strike) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(carve) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(butchery) or target.Refreshable(lacerate_debuff) and { Focus() > 55 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) == 0 and BuffStacks(mongoose_fury_buff) < 3 or Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffExpires(mongoose_fury_buff) and SpellCharges(mongoose_bite) < 3 } and Spell(lacerate) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 1 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) == 0 and BuffStacks(mongoose_fury_buff) < 1 and CheckBoxOn(opt_trap_launcher) and Spell(explosive_trap) or Enemies() > 1 and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and { BuffExpires(mongoose_fury_buff) or BuffRemaining(mongoose_fury_buff) > GCD() * SpellCharges(mongoose_bite) } and Spell(butchery) or Enemies() > 1 and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and { BuffExpires(mongoose_fury_buff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() or BuffRemaining(mongoose_fury_buff) > GCD() * SpellCharges(mongoose_bite) and Focus() > 70 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() } and Spell(carve) or BuffStacks(moknathal_tactics_buff) == 2 and Spell(raptor_strike) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 1 and Spell(dragonsfire_grenade) or BuffRemaining(moknathal_tactics_buff) < 4 and BuffStacks(mongoose_fury_buff) == 6 and BuffRemaining(mongoose_fury_buff) > SpellCooldown(fury_of_the_eagle) and SpellCooldown(fury_of_the_eagle) <= 5 and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) > 4 and BuffStacks(mongoose_fury_buff) == 6 and SpellCharges(mongoose_bite) <= 1 and Spell(fury_of_the_eagle) or BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and BuffStacks(moknathal_tactics_buff) >= 4 and Spell(mongoose_bite) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) <= 3 * GCD() and BuffRemaining(moknathal_tactics_buff) < 4 + GCD() and SpellCooldown(fury_of_the_eagle) < GCD() and Spell(raptor_strike) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) <= 2 * GCD() and Spell(fury_of_the_eagle)
	{
		#aspect_of_the_eagle,if=buff.mongoose_fury.stack>4&time<15
		if BuffStacks(mongoose_fury_buff) > 4 and TimeInCombat() < 15 Spell(aspect_of_the_eagle)
		#aspect_of_the_eagle,if=buff.mongoose_fury.stack>1&time>15
		if BuffStacks(mongoose_fury_buff) > 1 and TimeInCombat() > 15 Spell(aspect_of_the_eagle)
		#aspect_of_the_eagle,if=buff.mongoose_fury.up&buff.mongoose_fury.remains>6&cooldown.mongoose_bite.charges<2
		if BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) > 6 and SpellCharges(mongoose_bite) < 2 Spell(aspect_of_the_eagle)
	}
}

AddFunction SurvivalMoknathalCdPostConditions
{
	BuffStacks(moknathal_tactics_buff) <= 1 and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) < GCD() and Spell(raptor_strike) or BuffStacks(mongoose_fury_buff) >= 4 and BuffRemaining(mongoose_fury_buff) < GCD() and Spell(fury_of_the_eagle) or BuffStacks(mongoose_fury_buff) >= 4 and BuffRemaining(mongoose_fury_buff) > GCD() and BuffStacks(moknathal_tactics_buff) >= 3 and BuffRemaining(moknathal_tactics_buff) < 4 and SpellCooldown(fury_of_the_eagle) < BuffRemaining(mongoose_fury_buff) and Spell(raptor_strike) or SpellCharges(mongoose_bite) <= 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and TimeInCombat() > 15 and Spell(snake_hunter) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and BuffStacks(moknathal_tactics_buff) == 3 and Spell(spitting_cobra) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 1 and CheckBoxOn(opt_trap_launcher) and Spell(steel_trap) or Focus() > 55 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffStacks(mongoose_fury_buff) < 4 and BaseDuration(mongoose_fury_buff) >= GCD() and Spell(a_murder_of_crows) or SpellCharges(mongoose_bite) <= 1 and Focus() > 75 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(flanking_strike) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(carve) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(butchery) or target.Refreshable(lacerate_debuff) and { Focus() > 55 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) == 0 and BuffStacks(mongoose_fury_buff) < 3 or Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and BuffExpires(mongoose_fury_buff) and SpellCharges(mongoose_bite) < 3 } and Spell(lacerate) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 1 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) == 0 and BuffStacks(mongoose_fury_buff) < 1 and CheckBoxOn(opt_trap_launcher) and Spell(explosive_trap) or Enemies() > 1 and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and { BuffExpires(mongoose_fury_buff) or BuffRemaining(mongoose_fury_buff) > GCD() * SpellCharges(mongoose_bite) } and Spell(butchery) or Enemies() > 1 and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and { BuffExpires(mongoose_fury_buff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() or BuffRemaining(mongoose_fury_buff) > GCD() * SpellCharges(mongoose_bite) and Focus() > 70 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() } and Spell(carve) or BuffStacks(moknathal_tactics_buff) == 2 and Spell(raptor_strike) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 1 and Spell(dragonsfire_grenade) or BuffRemaining(moknathal_tactics_buff) < 4 and BuffStacks(mongoose_fury_buff) == 6 and BuffRemaining(mongoose_fury_buff) > SpellCooldown(fury_of_the_eagle) and SpellCooldown(fury_of_the_eagle) <= 5 and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) > 4 and BuffStacks(mongoose_fury_buff) == 6 and SpellCharges(mongoose_bite) <= 1 and Spell(fury_of_the_eagle) or BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and BuffStacks(moknathal_tactics_buff) >= 4 and Spell(mongoose_bite) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) <= 3 * GCD() and BuffRemaining(moknathal_tactics_buff) < 4 + GCD() and SpellCooldown(fury_of_the_eagle) < GCD() and Spell(raptor_strike) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) <= 2 * GCD() and Spell(fury_of_the_eagle) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) and Spell(mongoose_bite) or Spell(spitting_cobra) or CheckBoxOn(opt_trap_launcher) and Spell(steel_trap) or Focus() > 55 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(a_murder_of_crows) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or CheckBoxOn(opt_trap_launcher) and Spell(explosive_trap) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(carve) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(butchery) or target.Refreshable(lacerate_debuff) and Focus() > 55 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(lacerate) or Spell(dragonsfire_grenade) or { Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) <= GCD() or Charges(mongoose_bite) == 3 } and Spell(mongoose_bite) or Spell(flanking_strike) or Focus() > 65 - BuffRemaining(moknathal_tactics_buff) * FocusRegenRate() and Spell(butchery) or Focus() > 75 - SpellCooldown(flanking_strike) * FocusRegenRate() and Spell(raptor_strike)
}

### actions.nomok

AddFunction SurvivalNomokMainActions
{
	#caltrops,if=(buff.mongoose_fury.duration>=gcd&buff.mongoose_fury.stack<4&!dot.caltrops.ticking)
	if BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) Spell(caltrops)
	#flanking_strike,if=cooldown.mongoose_bite.charges<=1&buff.aspect_of_the_eagle.remains>=gcd
	if SpellCharges(mongoose_bite) <= 1 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() Spell(flanking_strike)
	#carve,if=equipped.frizzos_fingertrap&dot.lacerate.ticking&dot.lacerate.refreshable&focus>65&buff.mongoose_fury.remains>=gcd
	if HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and BuffRemaining(mongoose_fury_buff) >= GCD() Spell(carve)
	#butchery,if=equipped.frizzos_fingertrap&dot.lacerate.ticking&dot.lacerate.refreshable&focus>65&buff.mongoose_fury.remains>=gcd
	if HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and BuffRemaining(mongoose_fury_buff) >= GCD() Spell(butchery)
	#lacerate,if=buff.mongoose_fury.duration>=gcd&refreshable&cooldown.mongoose_bite.charges=0&buff.mongoose_fury.stack<2|buff.mongoose_fury.down&cooldown.mongoose_bite.charges<3&refreshable
	if BaseDuration(mongoose_fury_buff) >= GCD() and target.Refreshable(lacerate_debuff) and SpellCharges(mongoose_bite) == 0 and BuffStacks(mongoose_fury_buff) < 2 or BuffExpires(mongoose_fury_buff) and SpellCharges(mongoose_bite) < 3 and target.Refreshable(lacerate_debuff) Spell(lacerate)
	#raptor_strike,if=talent.serpent_sting.enabled&dot.serpent_sting.refreshable&buff.mongoose_fury.stack<3&cooldown.mongoose_bite.charges<1
	if Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) and BuffStacks(mongoose_fury_buff) < 3 and SpellCharges(mongoose_bite) < 1 Spell(raptor_strike)
	#mongoose_bite,if=buff.aspect_of_the_eagle.up&buff.mongoose_fury.up
	if BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) Spell(mongoose_bite)
	#flanking_strike,if=cooldown.mongoose_bite.charges<=1&buff.mongoose_fury.remains>(1+action.mongoose_bite.charges*gcd)
	if SpellCharges(mongoose_bite) <= 1 and BuffRemaining(mongoose_fury_buff) > 1 + Charges(mongoose_bite) * GCD() Spell(flanking_strike)
	#mongoose_bite,if=buff.mongoose_fury.up&buff.mongoose_fury.remains<cooldown.aspect_of_the_eagle.remains
	if BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) Spell(mongoose_bite)
	#flanking_strike,if=talent.animal_instincts.enabled&cooldown.mongoose_bite.charges<3
	if Talent(animal_instincts_talent) and SpellCharges(mongoose_bite) < 3 Spell(flanking_strike)
	#caltrops,if=(!dot.caltrops.ticking)
	if not target.DebuffPresent(caltrops_debuff) Spell(caltrops)
	#carve,if=equipped.frizzos_fingertrap&dot.lacerate.ticking&dot.lacerate.refreshable&focus>65
	if HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 Spell(carve)
	#butchery,if=equipped.frizzos_fingertrap&dot.lacerate.ticking&dot.lacerate.refreshable&focus>65
	if HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 Spell(butchery)
	#lacerate,if=refreshable
	if target.Refreshable(lacerate_debuff) Spell(lacerate)
	#throwing_axes,if=cooldown.throwing_axes.charges=2
	if SpellCharges(throwing_axes) == 2 Spell(throwing_axes)
	#mongoose_bite,if=(charges>=2&cooldown.mongoose_bite.remains<=gcd|charges=3)
	if Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) <= GCD() or Charges(mongoose_bite) == 3 Spell(mongoose_bite)
	#flanking_strike
	Spell(flanking_strike)
	#butchery
	Spell(butchery)
	#throwing_axes
	Spell(throwing_axes)
	#raptor_strike,if=focus>75-cooldown.flanking_strike.remains*focus.regen
	if Focus() > 75 - SpellCooldown(flanking_strike) * FocusRegenRate() Spell(raptor_strike)
}

AddFunction SurvivalNomokMainPostConditions
{
}

AddFunction SurvivalNomokShortCdActions
{
	#spitting_cobra,if=buff.mongoose_fury.duration>=gcd&cooldown.mongoose_bite.charges>=0&buff.mongoose_fury.stack<4
	if BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 Spell(spitting_cobra)
	#steel_trap,if=buff.mongoose_fury.duration>=gcd&buff.mongoose_fury.stack<1
	if BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 1 and CheckBoxOn(opt_trap_launcher) Spell(steel_trap)
	#a_murder_of_crows,if=cooldown.mongoose_bite.charges>=0&buff.mongoose_fury.stack<4
	if SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 Spell(a_murder_of_crows)
	#snake_hunter,if=action.mongoose_bite.charges<=0&buff.mongoose_fury.remains>3*gcd&time>15
	if Charges(mongoose_bite) <= 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and TimeInCombat() > 15 Spell(snake_hunter)

	unless BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or SpellCharges(mongoose_bite) <= 1 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() and Spell(flanking_strike) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(carve) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(butchery) or { BaseDuration(mongoose_fury_buff) >= GCD() and target.Refreshable(lacerate_debuff) and SpellCharges(mongoose_bite) == 0 and BuffStacks(mongoose_fury_buff) < 2 or BuffExpires(mongoose_fury_buff) and SpellCharges(mongoose_bite) < 3 and target.Refreshable(lacerate_debuff) } and Spell(lacerate)
	{
		#dragonsfire_grenade,if=buff.mongoose_fury.duration>=gcd&cooldown.mongoose_bite.charges<=1&buff.mongoose_fury.stack<3|buff.mongoose_fury.down&cooldown.mongoose_bite.charges<3
		if BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) <= 1 and BuffStacks(mongoose_fury_buff) < 3 or BuffExpires(mongoose_fury_buff) and SpellCharges(mongoose_bite) < 3 Spell(dragonsfire_grenade)
		#explosive_trap,if=buff.mongoose_fury.duration>=gcd&cooldown.mongoose_bite.charges>=0&buff.mongoose_fury.stack<4
		if BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and CheckBoxOn(opt_trap_launcher) Spell(explosive_trap)

		unless Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) and BuffStacks(mongoose_fury_buff) < 3 and SpellCharges(mongoose_bite) < 1 and Spell(raptor_strike)
		{
			#fury_of_the_eagle,if=buff.mongoose_fury.stack=6&cooldown.mongoose_bite.charges<=1
			if BuffStacks(mongoose_fury_buff) == 6 and SpellCharges(mongoose_bite) <= 1 Spell(fury_of_the_eagle)

			unless BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and Spell(mongoose_bite)
			{
				#fury_of_the_eagle,if=cooldown.mongoose_bite.charges<=1&buff.mongoose_fury.duration>6
				if SpellCharges(mongoose_bite) <= 1 and BaseDuration(mongoose_fury_buff) > 6 Spell(fury_of_the_eagle)

				unless SpellCharges(mongoose_bite) <= 1 and BuffRemaining(mongoose_fury_buff) > 1 + Charges(mongoose_bite) * GCD() and Spell(flanking_strike) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) and Spell(mongoose_bite) or Talent(animal_instincts_talent) and SpellCharges(mongoose_bite) < 3 and Spell(flanking_strike)
				{
					#spitting_cobra
					Spell(spitting_cobra)
					#steel_trap
					if CheckBoxOn(opt_trap_launcher) Spell(steel_trap)
					#a_murder_of_crows
					Spell(a_murder_of_crows)

					unless not target.DebuffPresent(caltrops_debuff) and Spell(caltrops)
					{
						#explosive_trap
						if CheckBoxOn(opt_trap_launcher) Spell(explosive_trap)

						unless HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and Spell(carve) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and Spell(butchery) or target.Refreshable(lacerate_debuff) and Spell(lacerate)
						{
							#dragonsfire_grenade
							Spell(dragonsfire_grenade)
						}
					}
				}
			}
		}
	}
}

AddFunction SurvivalNomokShortCdPostConditions
{
	BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or SpellCharges(mongoose_bite) <= 1 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() and Spell(flanking_strike) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(carve) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(butchery) or { BaseDuration(mongoose_fury_buff) >= GCD() and target.Refreshable(lacerate_debuff) and SpellCharges(mongoose_bite) == 0 and BuffStacks(mongoose_fury_buff) < 2 or BuffExpires(mongoose_fury_buff) and SpellCharges(mongoose_bite) < 3 and target.Refreshable(lacerate_debuff) } and Spell(lacerate) or Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) and BuffStacks(mongoose_fury_buff) < 3 and SpellCharges(mongoose_bite) < 1 and Spell(raptor_strike) or BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and Spell(mongoose_bite) or SpellCharges(mongoose_bite) <= 1 and BuffRemaining(mongoose_fury_buff) > 1 + Charges(mongoose_bite) * GCD() and Spell(flanking_strike) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) and Spell(mongoose_bite) or Talent(animal_instincts_talent) and SpellCharges(mongoose_bite) < 3 and Spell(flanking_strike) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and Spell(carve) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and Spell(butchery) or target.Refreshable(lacerate_debuff) and Spell(lacerate) or SpellCharges(throwing_axes) == 2 and Spell(throwing_axes) or { Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) <= GCD() or Charges(mongoose_bite) == 3 } and Spell(mongoose_bite) or Spell(flanking_strike) or Spell(butchery) or Spell(throwing_axes) or Focus() > 75 - SpellCooldown(flanking_strike) * FocusRegenRate() and Spell(raptor_strike)
}

AddFunction SurvivalNomokCdActions
{
	unless BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(spitting_cobra) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 1 and CheckBoxOn(opt_trap_launcher) and Spell(steel_trap) or SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(a_murder_of_crows) or Charges(mongoose_bite) <= 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and TimeInCombat() > 15 and Spell(snake_hunter) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or SpellCharges(mongoose_bite) <= 1 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() and Spell(flanking_strike) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(carve) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(butchery) or { BaseDuration(mongoose_fury_buff) >= GCD() and target.Refreshable(lacerate_debuff) and SpellCharges(mongoose_bite) == 0 and BuffStacks(mongoose_fury_buff) < 2 or BuffExpires(mongoose_fury_buff) and SpellCharges(mongoose_bite) < 3 and target.Refreshable(lacerate_debuff) } and Spell(lacerate) or { BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) <= 1 and BuffStacks(mongoose_fury_buff) < 3 or BuffExpires(mongoose_fury_buff) and SpellCharges(mongoose_bite) < 3 } and Spell(dragonsfire_grenade) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and CheckBoxOn(opt_trap_launcher) and Spell(explosive_trap) or Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) and BuffStacks(mongoose_fury_buff) < 3 and SpellCharges(mongoose_bite) < 1 and Spell(raptor_strike) or BuffStacks(mongoose_fury_buff) == 6 and SpellCharges(mongoose_bite) <= 1 and Spell(fury_of_the_eagle) or BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and Spell(mongoose_bite)
	{
		#aspect_of_the_eagle,if=buff.mongoose_fury.up&buff.mongoose_fury.duration>6&cooldown.mongoose_bite.charges>=2
		if BuffPresent(mongoose_fury_buff) and BaseDuration(mongoose_fury_buff) > 6 and SpellCharges(mongoose_bite) >= 2 Spell(aspect_of_the_eagle)
	}
}

AddFunction SurvivalNomokCdPostConditions
{
	BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(spitting_cobra) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 1 and CheckBoxOn(opt_trap_launcher) and Spell(steel_trap) or SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(a_murder_of_crows) or Charges(mongoose_bite) <= 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and TimeInCombat() > 15 and Spell(snake_hunter) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or SpellCharges(mongoose_bite) <= 1 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() and Spell(flanking_strike) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(carve) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(butchery) or { BaseDuration(mongoose_fury_buff) >= GCD() and target.Refreshable(lacerate_debuff) and SpellCharges(mongoose_bite) == 0 and BuffStacks(mongoose_fury_buff) < 2 or BuffExpires(mongoose_fury_buff) and SpellCharges(mongoose_bite) < 3 and target.Refreshable(lacerate_debuff) } and Spell(lacerate) or { BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) <= 1 and BuffStacks(mongoose_fury_buff) < 3 or BuffExpires(mongoose_fury_buff) and SpellCharges(mongoose_bite) < 3 } and Spell(dragonsfire_grenade) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellCharges(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and CheckBoxOn(opt_trap_launcher) and Spell(explosive_trap) or Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) and BuffStacks(mongoose_fury_buff) < 3 and SpellCharges(mongoose_bite) < 1 and Spell(raptor_strike) or BuffStacks(mongoose_fury_buff) == 6 and SpellCharges(mongoose_bite) <= 1 and Spell(fury_of_the_eagle) or BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and Spell(mongoose_bite) or SpellCharges(mongoose_bite) <= 1 and BaseDuration(mongoose_fury_buff) > 6 and Spell(fury_of_the_eagle) or SpellCharges(mongoose_bite) <= 1 and BuffRemaining(mongoose_fury_buff) > 1 + Charges(mongoose_bite) * GCD() and Spell(flanking_strike) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) and Spell(mongoose_bite) or Talent(animal_instincts_talent) and SpellCharges(mongoose_bite) < 3 and Spell(flanking_strike) or Spell(spitting_cobra) or CheckBoxOn(opt_trap_launcher) and Spell(steel_trap) or Spell(a_murder_of_crows) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or CheckBoxOn(opt_trap_launcher) and Spell(explosive_trap) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and Spell(carve) or HasEquippedItem(frizzos_fingertrap) and target.DebuffPresent(lacerate_debuff) and target.DebuffRefreshable(lacerate_debuff) and Focus() > 65 and Spell(butchery) or target.Refreshable(lacerate_debuff) and Spell(lacerate) or Spell(dragonsfire_grenade) or SpellCharges(throwing_axes) == 2 and Spell(throwing_axes) or { Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) <= GCD() or Charges(mongoose_bite) == 3 } and Spell(mongoose_bite) or Spell(flanking_strike) or Spell(butchery) or Spell(throwing_axes) or Focus() > 75 - SpellCooldown(flanking_strike) * FocusRegenRate() and Spell(raptor_strike)
}

### actions.precombat

AddFunction SurvivalPrecombatMainActions
{
	#harpoon
	Spell(harpoon)
}

AddFunction SurvivalPrecombatMainPostConditions
{
}

AddFunction SurvivalPrecombatShortCdActions
{
	#flask,type=flask_of_the_seventh_demon
	#food,type=azshari_salad
	#summon_pet
	SurvivalSummonPet()
	#augmentation,type=defiled
	#explosive_trap
	if CheckBoxOn(opt_trap_launcher) Spell(explosive_trap)
	#steel_trap
	if CheckBoxOn(opt_trap_launcher) Spell(steel_trap)
	#dragonsfire_grenade
	Spell(dragonsfire_grenade)
}

AddFunction SurvivalPrecombatShortCdPostConditions
{
	Spell(harpoon)
}

AddFunction SurvivalPrecombatCdActions
{
	#snapshot_stats
	#potion,name=prolonged_power
	if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
}

AddFunction SurvivalPrecombatCdPostConditions
{
	CheckBoxOn(opt_trap_launcher) and Spell(explosive_trap) or CheckBoxOn(opt_trap_launcher) and Spell(steel_trap) or Spell(dragonsfire_grenade) or Spell(harpoon)
}

### Survival icons.

AddCheckBox(opt_hunter_survival_aoe L(AOE) default specialization=survival)

AddIcon checkbox=!opt_hunter_survival_aoe enemies=1 help=shortcd specialization=survival
{
	if not InCombat() SurvivalPrecombatShortCdActions()
	unless not InCombat() and SurvivalPrecombatShortCdPostConditions()
	{
		SurvivalDefaultShortCdActions()
	}
}

AddIcon checkbox=opt_hunter_survival_aoe help=shortcd specialization=survival
{
	if not InCombat() SurvivalPrecombatShortCdActions()
	unless not InCombat() and SurvivalPrecombatShortCdPostConditions()
	{
		SurvivalDefaultShortCdActions()
	}
}

AddIcon enemies=1 help=main specialization=survival
{
	if not InCombat() SurvivalPrecombatMainActions()
	unless not InCombat() and SurvivalPrecombatMainPostConditions()
	{
		SurvivalDefaultMainActions()
	}
}

AddIcon checkbox=opt_hunter_survival_aoe help=aoe specialization=survival
{
	if not InCombat() SurvivalPrecombatMainActions()
	unless not InCombat() and SurvivalPrecombatMainPostConditions()
	{
		SurvivalDefaultMainActions()
	}
}

AddIcon checkbox=!opt_hunter_survival_aoe enemies=1 help=cd specialization=survival
{
	if not InCombat() SurvivalPrecombatCdActions()
	unless not InCombat() and SurvivalPrecombatCdPostConditions()
	{
		SurvivalDefaultCdActions()
	}
}

AddIcon checkbox=opt_hunter_survival_aoe help=cd specialization=survival
{
	if not InCombat() SurvivalPrecombatCdActions()
	unless not InCombat() and SurvivalPrecombatCdPostConditions()
	{
		SurvivalDefaultCdActions()
	}
}

### Required symbols
# a_murder_of_crows
# animal_instincts_talent
# arcane_torrent_focus
# aspect_of_the_eagle
# aspect_of_the_eagle_buff
# berserking
# blood_fury_ap
# butchery
# caltrops
# caltrops_debuff
# carve
# dragonsfire_grenade
# explosive_trap
# flanking_strike
# frizzos_fingertrap
# fury_of_the_eagle
# harpoon
# lacerate
# lacerate_debuff
# lone_wolf_talent
# moknathal_tactics_buff
# mongoose_bite
# mongoose_fury_buff
# muzzle
# prolonged_power_potion
# quaking_palm
# raptor_strike
# revive_pet
# serpent_sting_debuff
# serpent_sting_talent
# snake_hunter
# spitting_cobra
# spitting_cobra_buff
# spitting_cobra_talent
# steel_trap
# throwing_axes
# trap_launcher
# war_stomp
# way_of_the_moknathal_talent
]]
    __Scripts.OvaleScripts:RegisterScript("HUNTER", "survival", name, desc, code, "script")
end
end)
