Ovale.defaut["HUNTER"] =
[[
Define(SERPENTSTING 1978)
Define(ARCANESHOT 3044)
Define(AIMEDSHOT 19434)
Define(MULTISHOT 2643)
Define(STEADYSHOT 56641)
Define(EXPLOSIVESHOT 53301)
Define(KILLSHOT 53351)
Define(RAPIDFIRE 3045)
Define(KILLCOMMAND 34026)
Define(BESTIALWRATH 19574)
Define(HUNTERSMARK 53338)

AddCheckBox(multi SpellName(MULTISHOT))

AddIcon
{
	if TargetDebuffExpires(HUNTERSMARK 0) Spell(HUNTERSMARK)
	if TargetDebuffExpires(SERPENTSTING 0) Spell(SERPENTSTING)
	if TargetDebuffExpires(EXPLOSIVESHOT 0) Spell(EXPLOSIVESHOT)
	Spell(AIMEDSHOT)
	if CheckBoxOn(multi) Spell(MULTISHOT)
	Spell(ARCANESHOT)
	if TargetLifePercent(less 20) Spell(KILLSHOT)
	if TargetDebuffExpires(HUNTERSMARK 2) Spell(HUNTERSMARK)
	Spell(STEADYSHOT)
}

AddIcon
{
	Spell(BESTIALWRATH usable=1)
	Spell(KILLCOMMAND usable=1)
	Spell(RAPIDFIRE)
}
]]