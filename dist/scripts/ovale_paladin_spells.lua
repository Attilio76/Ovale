local __addonName, __addon = ...
__addon.require(__addonName, __addon, "ovale_paladin_spells", { "../Scripts" }, function(__exports, __Scripts)
do
    local name = "ovale_paladin_spells"
    local desc = "[7.0] Ovale: Paladin spells"
    local code = [[
# Items
Define(heathcliffs_immortality 137047)
Define(pillars_of_inmost_light 151812)

Define(liadrins_fury_unleashed_buff 208410)
Define(scarlet_inquisitors_expurgation_buff 248289)

ItemRequire(shifting_cosmic_sliver unusable 1=oncooldown,!guardian_of_ancient_kings,buff,!guardian_of_ancient_kings_buff)	
	
# Paladin spells and functions.

# Learned spells.
Define(aegis_of_light 204150)
	SpellInfo(aegis_of_light cd=300 duration=6)
Define(aegis_of_light_buff 204150)
Define(ardent_defender 31850)
	SpellInfo(ardent_defender cd=120 gcd=0 offgcd=1)
	SpellAddBuff(ardent_defender ardent_defender_buff=1)
Define(ardent_defender_buff 31850)
	SpellInfo(ardent_defender_buff duration=8)
Define(aura_mastery 31821)
	SpellInfo(aura_mastery cd=180)
Define(avengers_reprieve_buff 185676)
	SpellInfo(avengers_reprieve_buff duration=10)
Define(avengers_shield 31935)
	SpellInfo(avengers_shield cd=15 travel_time=1)
	SpellAddBuff(avengers_shield avengers_reprieve_buff=1 itemset=T18 itemcount=2 specialization=protection)
	SpellAddBuff(avengers_shield grand_crusader_buff=0 if_spell=grand_crusader)
	SpellAddBuff(avengers_shield faith_barricade_buff=1 itemset=T17 itemcount=2 specialization=protection)
Define(avenging_wrath_heal 31842)
	SpellInfo(avenging_wrath_heal cd=180 gcd=0)
Define(avenging_wrath_heal_buff 31882)
	SpellInfo(avenging_wrath_heal_buff duration=25)
	SpellInfo(avenging_wrath_heal_buff addduration=5 talent=sanctified_wrath_talent)
Define(avenging_wrath_melee 31884)
	SpellInfo(avenging_wrath_melee cd=120 gcd=0)
	SpellInfo(avenging_wrath_melee replace=crusade talent=crusade_talent)
	SpellAddBuff(avenging_wrath_melee avenging_wrath_melee_buff=1)
Define(avenging_wrath_melee_buff 31884)
	SpellInfo(avenging_wrath_melee_buff duration=30)
Define(bastion_of_light 204035)
	SpellInfo(bastion_of_light cd=180 gcd=0 offgcd=1)
Define(bastion_of_power_buff 144569)
	SpellInfo(bastion_of_power_buff duration=20)
Define(beacon_of_light 53563)
	SpellInfo(beacon_of_light cd=3)
	SpellAddTargetBuff(beacon_of_light beacon_of_light_buff=1)
Define(beacon_of_light_buff 53563)
Define(beacon_of_virtue 200025)
	SpellInfo(beacon_of_virtue cd=15)
Define(bestow_faith 223306)
	SpellInfo(bestow_faith cd=12)
Define(blade_of_justice 184575)
	SpellInfo(blade_of_justice holy=-2 cd=10.5)
	SpellInfo(blade_of_justice replace=divine_hammer talent=divine_hammer_talent)
	SpellInfo(blade_of_justice addholy=-1 itemset=T20 itemcount=4)
Define(blazing_contempt_buff 166831)
	SpellInfo(blazing_contempt_buff duration=20)
Define(blessed_hammer 204019)
Define(blessed_hammer_debuff 204301)
Define(blinding_light 115750)
	SpellInfo(blinding_light cd=120 interrupt=1 tag=cd)
Define(cleanse 4987)
	SpellInfo(cleanse cd=8)
Define(consecration 26573)
	SpellInfo(consecration cd=9 tag=main cd_haste=melee)
Define(consecration_buff 188370)
Define(consecration_debuff 81298)
	SpellInfo(consecration_debuff duration=9 tick=1 haste=melee)
Define(crusade 231895)
	SpellInfo(crusade cd=120)
	SpellAddBuff(crusade crusade_buff=1)
Define(crusade_buff 231895)
	SpellInfo(crusade_buff duration=30 max_stacks=15)
Define(crusader_strike 35395)
	SpellInfo(crusader_strike cd=4.5 cd_haste=melee)
	SpellInfo(crusader_strike cd=3.5 talent=the_fires_of_justice_talent specialization=retribution)
	SpellInfo(crusader_strike unusable=1 talent=zeal_talent specialization=retribution)
Define(crusaders_fury_buff 165442)
	SpellInfo(crusaders_fury_buff duration=10)
Define(defender_of_the_light_buff 167742)
	SpellInfo(defender_of_the_light_buff duration=8)
Define(divine_crusader_buff 144595)
	SpellInfo(divine_crusader_buff duration=12)
Define(divine_hammer 198034)
	SpellInfo(divine_hammer cd=12 holy=-2)
	SpellInfo(divine_hammer addholy=-1 itemset=T20 itemcount=2)
Define(divine_protection 498)
	SpellInfo(divine_protection cd=60 gcd=0 offgcd=1 tag=cd)
	SpellInfo(divine_protection replace=ardent_defender level=50)
	SpellAddBuff(divine_protection divine_protection_buff=1)
Define(divine_protection_buff 498)
	SpellInfo(divine_protection_buff duration=8)
Define(divine_purpose 223817)
Define(divine_purpose_buff 223819)
	SpellInfo(divine_purpose_buff duration=12)
Define(divine_shield 642)
	SpellInfo(divine_shield cd=300 gcd=0 offgcd=1)
	SpellAddBuff(divine_shield divine_shield_buff=1)
	SpellRequire(divine_shield unusable 1=debuff,forbearance_debuff)
Define(divine_shield_buff 642)
	SpellInfo(divine_shield_buff duration=8)
Define(divine_steed 190784)
	SpellInfo(divine_steed cd=45 tag=cd)
	SpellAddBuff(divine_steed divine_steed_buff=1)
Define(divine_steed_buff 221886)
	SpellInfo(divine_steed_buff duration=3)
Define(divine_storm 53385)
	SpellInfo(divine_storm holy=3)
	SpellRequire(divine_storm holy 0=buff,divine_storm_no_holy_buff)
	SpellRequire(divine_storm holy 2=buff,the_fires_of_justice_buff)
	SpellAddBuff(divine_storm divine_crusader_buff=0)
	SpellAddBuff(divine_storm divine_purpose_buff=0 if_spell=divine_purpose)
	SpellAddBuff(divine_storm final_verdict_buff=0 if_spell=final_verdict)
SpellList(divine_storm_no_holy_buff divine_crusader_buff divine_purpose_buff)
Define(execution_sentence 213757)
	SpellInfo(execution_sentence cd=20 holy=3)
	SpellRequire(execution_sentence holy 2=buff,the_fires_of_justice_buff)
	SpellAddTargetDebuff(execution_sentence execution_sentence_debuff=1)
Define(execution_sentence_debuff 213757)
	SpellInfo(execution_sentence_debuff duration=7)
Define(eye_of_tyr 209202)
	SpellInfo(eye_of_tyr cd=60 tag=cd)
	SpellInfo(eye_of_tyr cd=45 if_equipped=pillars_of_inmost_light)
	SpellAddTargetDebuff(eye_of_tyr eye_of_tyr_debuff=1)
Define(eye_of_tyr_debuff 209202)
	SpellInfo(eye_of_tyr_debuff duration=9)
Define(faith_barricade_buff 165447)
	SpellInfo(faith_barricade_buff duration=5)
Define(final_verdict 157048)
	SpellInfo(final_verdict holy=3)
	SpellRequire(final_verdict holy 0=buff,divine_purpose_buff if_spell=divine_purpose)
	SpellAddBuff(final_verdict divine_purpose_buff=0 if_spell=divine_purpose)
	SpellAddBuff(final_verdict final_verdict_buff=1)
Define(final_verdict_buff 157048)
	SpellInfo(final_verdict_buff duration=30)
Define(flash_of_light 19750)
	SpellAddBuff(flash_of_light infusion_of_light_buff=-1)
Define(forbearance_debuff 25771)
	SpellInfo(forbearance_debuff duration=30)
Define(grand_crusader 85043)
Define(grand_crusader_buff 85416)
	SpellInfo(grand_crusader_buff duration=6)
Define(greater_blessing_of_might 203528)
	SpellAddBuff(greater_blessing_of_might greater_blessing_of_might_buff=1)
	SpellRequire(greater_blessing_of_might unusable 1=buff,greater_blessing_of_might_buff)
Define(greater_blessing_of_might_buff 203528)
Define(guardian_of_ancient_kings 86659)
	SpellInfo(guardian_of_ancient_kings cd=300 gcd=0 offgcd=1)
	SpellAddBuff(guardian_of_ancient_kings guardian_of_ancient_kings_buff=1)
Define(guardian_of_ancient_kings_buff 86659)
	SpellInfo(guardian_of_ancient_kings_buff duration=8)
Define(hammer_of_justice 853)
	SpellInfo(hammer_of_justice cd=60 interrupt=1)
Define(hammer_of_the_righteous 53595)
	SpellInfo(hammer_of_the_righteous holy=-1 cd=4.5)
	SpellInfo(hammer_of_the_righteous cd_haste=melee protection=protection)
	SpellInfo(hammer_of_the_righteous replace=blessed_hammer talent=blessed_hammer_talent)
Define(hand_of_freedom 1044)
	SpellInfo(hand_of_freedom cd=25)
Define(hand_of_protection 1022)
	SpellInfo(hand_of_protection cd=300 gcd=0 offgcd=1)
	SpellAddBuff(hand_of_protection hand_of_protection_buff=1)
Define(hand_of_protection_buff 1022)
	SpellInfo(hand_of_protection_buff duration=10)
Define(hand_of_sacrifice 6940)
	SpellInfo(hand_of_sacrifice cd=120 gcd=0 offgcd=1)
	SpellAddTargetBuff(hand_of_sacrifice hand_of_sacrifice_buff=1)
Define(hand_of_sacrifice_buff 6940)
	SpellInfo(hand_of_sacrifice_buff duration=10)
Define(hand_of_the_protector 213652)
	SpellInfo(hand_of_the_protector cd=10 cd_haste=melee tag=shortcd gcd=0 offgcd=1)
	SpellInfo(hand_of_the_protector charges=2 if_equipped=saruans_resolve)
Define(harsh_word 136494)
	SpellInfo(harsh_word tag=shortcd)
Define(holy_avenger 105809)
	SpellInfo(holy_avenger cd=90)
	SpellAddBuff(holy_avenger holy_avenger_buff=1)
Define(holy_avenger_buff 105809)
	SpellInfo(holy_avenger_buff duration=20)
Define(holy_light 82326)
	SpellAddBuff(holy_light infusion_of_light_buff=-1)
Define(holy_prism 114165)
	SpellInfo(holy_prism cd=20)
Define(holy_shock 20473)
	SpellInfo(holy_shock cd=6 cd_haste=melee)
	SpellRequire(holy_shock cd 3=buff,avenging_wrath_heal_buff talent=sanctified_wrath_talent)
Define(holy_wrath 210220)
	SpellInfo(holy_wrath cd=180)
Define(improved_forbearance 157482)
Define(infusion_of_light_buff 54149)
	SpellInfo(infusion_of_light_buff duration=15)
Define(judgment 20271)
	SpellInfo(judgment cd=12 charges=1)
	SpellInfo(judgment cd_haste=melee specialization=!holy)
	SpellInfo(judgment cd_haste=spell specialization=holy)
	SpellInfo(judgment holy=-1 specialization=retribution)
	SpellInfo(judgment charges=2 specialization=protection talent=crusaders_judgment_talent)
	SpellAddBuff(judgment selfless_healer_buff=1 if_spell=selfless_healer)
	SpellAddTargetDebuff(judgment judgment_ret_debuff=1 specialization=retribution)
	SpellAddTargetDebuff(judgment judgment_holy_debuff=1 specialization=holy)
	SpellAddTargetDebuff(judgment judgement_of_light_debuff=40 if_spell=judgment_of_light)
Define(judgment_holy_debuff 214222)
	SpellInfo(judgment_holy_debuff duration=6)
Define(judgment_of_light 183778)
Define(judgement_of_light_debuff 196941)
	SpellInfo(judgement_of_light_debuff duration=30)
Define(judgment_ret_debuff 197277)
	SpellInfo(judgment_ret_debuff duration=8)
Define(justicars_vengeance 215661)
	SpellInfo(justicars_vengeance holy=5)
	SpellRequire(justicars_vengeance holy 4=buff,the_fires_of_justice_buff)
	SpellRequire(justicars_vengeance holy 0=buff,divine_purpose_buff)
Define(lawful_words_buff 166780)
	SpellInfo(lawful_words_buff duration=10)
Define(lay_on_hands 633)
	SpellInfo(lay_on_hands cd=600)
	SpellRequire(lay_on_hands unusable 1=target_debuff,forbearance_debuff)
	SpellAddTargetDebuff(lay_on_hands forbearance_debuff=1)
Define(liadrins_righteousness_buff 156989)
	SpellInfo(liadrins_righteousness_buff duration=20)
Define(light_of_dawn 85222)
	SpellInfo(light_of_dawn cd=12 cd_haste=spell)
SpellList(light_of_dawn_no_holy_buff divine_purpose_buff lights_favor_buff)
Define(light_of_the_martyr 183998)
Define(light_of_the_protector 184092)
	SpellInfo(light_of_the_protector cd=15 cd_haste=melee tag=shortcd gcd=0 offgcd=1)
	SpellInfo(light_of_the_protector charges=2 if_equipped=saruans_resolve)
	SpellInfo(light_of_the_protector replace=hand_of_the_protector talent=hand_of_the_protector_talent)
Define(lights_favor_buff 166781)
	SpellInfo(lights_favor_buff duration=10)
Define(lights_hammer 114158)
	SpellInfo(lights_hammer cd=60)
Define(maraads_truth_buff 156990)
	SpellInfo(maraads_truth_buff duration=20)
Define(rebuke 96231)
	SpellInfo(rebuke cd=15 gcd=0 interrupt=1 offgcd=1)
Define(redemption 7328)
Define(sacred_shield 20925)
	SpellInfo(sacred_shield cd=6)
	SpellAddBuff(sacred_shield sacred_shield_buff=1)
Define(sacred_shield_buff 20925)
	SpellInfo(sacred_shield duration=30 haste=spell tick=6)
Define(saruans_resolve 144275)
Define(selfless_healer 85804)
Define(selfless_healer_buff 114250)
	SpellInfo(selfless_healer_buff duration=15 max_stacks=3)
Define(seraphim 152262)
	SpellInfo(seraphim cd=30 gcd=0 offgcd=1)
Define(seraphim_buff 152262)
	SpellInfo(seraphim_buff duration=15)
Define(shield_of_the_righteous 53600)
	SpellInfo(shield_of_the_righteous cd=1 gcd=0 offgcd=1)
	SpellInfo(shield_of_the_righteous cd_haste=melee haste=melee specialization=protection)
	SpellAddBuff(shield_of_the_righteous shield_of_the_righteous_buff=1)
Define(shield_of_the_righteous_buff 132403)
	SpellInfo(shield_of_the_righteous_buff duration=4)
Define(shield_of_vengeance 184662)
	SpellInfo(shield_of_vengeance cd=90 gcd=0 offgcd=1)
Define(speed_of_light 85499)
	SpellInfo(speed_of_light cd=45 gcd=0 offgcd=1)
Define(t18_class_trinket 124518)
Define(templars_verdict 85256)
	SpellInfo(templars_verdict holy=3)
	SpellRequire(templars_verdict holy 2=buff,the_fires_of_justice_buff talent=the_fires_of_justice_talent)
	SpellRequire(templars_verdict holy 0=buff,divine_purpose_buff if_spell=divine_purpose)
	SpellAddBuff(templars_verdict divine_purpose_buff=0 if_spell=divine_purpose)
Define(the_fires_of_justice_buff 209785)
	SpellInfo(the_fires_of_justice_buff duration=15)
Define(tyrs_deliverance 200652)
	SpellInfo(tyrs_deliverance cd=90)
Define(uthers_insight_buff 156988)
	SpellInfo(uthers_insight_buff duration=21 haste=spell tick=3)
Define(wake_of_ashes 205273)
	SpellInfo(wake_of_ashes cd=30 tag=main)
Define(whisper_of_the_nathrezim 137020)
Define(whisper_of_the_nathrezim_buff 207633)
Define(wings_of_liberty_buff 185647)
	SpellInfo(wings_of_liberty_buff duration=10 max_stacks=10)
Define(word_of_glory 85673)
	SpellInfo(word_of_glory cd=1 holy=finisher max_holy=3)
	SpellInfo(word_of_glory gcd=0 offgcd=1)
	SpellRequire(word_of_glory holy 0=buff,word_of_glory_no_holy_buff)
	SpellAddBuff(word_of_glory bastion_of_glory_buff=0 if_spell=shield_of_the_righteous)
	SpellAddBuff(word_of_glory bastion_of_power_buff=0 if_spell=shield_of_the_righteous itemset=T16_tank itemcount=4)
	SpellAddBuff(word_of_glory divine_purpose_buff=0 if_spell=divine_purpose)
	SpellAddBuff(word_of_glory lawful_words_buff=0 itemset=T17 itemcount=4 specialization=holy)
SpellList(word_of_glory_no_holy_buff bastion_of_power_buff divine_purpose_buff lawful_words_buff)
Define(zeal 217020)
	SpellInfo(zeal cd=4.5 holy=-1)

#Talents
Define(bastion_of_light_talent 5)
Define(beacon_of_virtue_talent 21)
Define(blade_of_wrath_talent 11)
Define(blessed_hammer_talent 2)
Define(consecrated_hammer_talent 3)
Define(crusade_talent 20)
Define(crusaders_judgment_talent 6)
Define(divine_hammer_talent 12)
Define(execution_sentence_talent 2)
Define(final_stand_talent 15)
Define(final_verdict_talent 1)
Define(fist_of_justice_talent 7)
Define(greater_judgment_talent 6)
Define(hand_of_the_protector_talent 13)
Define(judgment_of_light_talent 18)
Define(knight_templar_talent 14)
Define(lights_hammer_talent 17)
Define(righteous_protector_talent 19)
Define(sanctified_wrath_talent 14)
Define(selfless_healer_talent 7)
Define(seraphim_talent 20)
Define(the_fires_of_justice_talent 4)
Define(virtues_blade_talent 10)
Define(zeal_talent 5)
]]
    __Scripts.OvaleScripts:RegisterScript("PALADIN", nil, name, desc, code, "include")
end
end)
