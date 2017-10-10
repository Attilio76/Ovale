local __addonName, __addon = ...
__addon.require(__addonName, __addon, "./PaperDoll", { "./Debug", "./Profiler", "./Ovale", "./Equipment", "./Stance", "./State", "./LastSpell" }, function(__exports, __Debug, __Profiler, __Ovale, __Equipment, __Stance, __State, __LastSpell)
local OvalePaperDollBase = __Ovale.Ovale:NewModule("OvalePaperDoll", "AceEvent-3.0")
local _pairs = pairs
local _tonumber = tonumber
local _type = type
local API_GetCombatRating = GetCombatRating
local API_GetCritChance = GetCritChance
local API_GetMastery = GetMastery
local API_GetMasteryEffect = GetMasteryEffect
local API_GetMeleeHaste = GetMeleeHaste
local API_GetMultistrike = GetMultistrike
local API_GetMultistrikeEffect = GetMultistrikeEffect
local API_GetRangedCritChance = GetRangedCritChance
local API_GetRangedHaste = GetRangedHaste
local API_GetSpecialization = GetSpecialization
local API_GetSpellBonusDamage = GetSpellBonusDamage
local API_GetSpellBonusHealing = GetSpellBonusHealing
local API_GetSpellCritChance = GetSpellCritChance
local API_GetTime = GetTime
local API_UnitAttackPower = UnitAttackPower
local API_UnitAttackSpeed = UnitAttackSpeed
local API_UnitDamage = UnitDamage
local API_UnitLevel = UnitLevel
local API_UnitRangedAttackPower = UnitRangedAttackPower
local API_UnitSpellHaste = UnitSpellHaste
local API_UnitStat = UnitStat
local _CR_CRIT_MELEE = CR_CRIT_MELEE
local _CR_HASTE_MELEE = CR_HASTE_MELEE
local OVALE_SPELLDAMAGE_SCHOOL = {
    DEATHKNIGHT = 4,
    DEMONHUNTER = 3,
    DRUID = 4,
    HUNTER = 4,
    MAGE = 5,
    MONK = 4,
    PALADIN = 2,
    PRIEST = 2,
    ROGUE = 4,
    SHAMAN = 4,
    WARLOCK = 6,
    WARRIOR = 4
}
local OVALE_SPECIALIZATION_NAME = {
    DEATHKNIGHT = {
        [1] = "blood",
        [2] = "frost",
        [3] = "unholy"
    },
    DEMONHUNTER = {
        [1] = "havoc",
        [2] = "vengeance"
    },
    DRUID = {
        [1] = "balance",
        [2] = "feral",
        [3] = "guardian",
        [4] = "restoration"
    },
    HUNTER = {
        [1] = "beast_mastery",
        [2] = "marksmanship",
        [3] = "survival"
    },
    MAGE = {
        [1] = "arcane",
        [2] = "fire",
        [3] = "frost"
    },
    MONK = {
        [1] = "brewmaster",
        [2] = "mistweaver",
        [3] = "windwalker"
    },
    PALADIN = {
        [1] = "holy",
        [2] = "protection",
        [3] = "retribution"
    },
    PRIEST = {
        [1] = "discipline",
        [2] = "holy",
        [3] = "shadow"
    },
    ROGUE = {
        [1] = "assassination",
        [2] = "outlaw",
        [3] = "subtlety"
    },
    SHAMAN = {
        [1] = "elemental",
        [2] = "enhancement",
        [3] = "restoration"
    },
    WARLOCK = {
        [1] = "affliction",
        [2] = "demonology",
        [3] = "destruction"
    },
    WARRIOR = {
        [1] = "arms",
        [2] = "fury",
        [3] = "protection"
    }
}
local OvalePaperDollClass = __class(__Debug.OvaleDebug:RegisterDebugging(__Profiler.OvaleProfiler:RegisterProfiling(OvalePaperDollBase)), {
    constructor = function(self)
        self.class = __Ovale.Ovale.playerClass
        self.level = API_UnitLevel("player")
        self.specialization = nil
        self.STAT_NAME = {
            snapshotTime = true,
            agility = true,
            intellect = true,
            spirit = true,
            stamina = true,
            strength = true,
            attackPower = true,
            rangedAttackPower = true,
            spellBonusDamage = true,
            spellBonusHealing = true,
            masteryEffect = true,
            meleeCrit = true,
            meleeHaste = true,
            rangedCrit = true,
            rangedHaste = true,
            spellCrit = true,
            spellHaste = true,
            multistrike = true,
            critRating = true,
            hasteRating = true,
            masteryRating = true,
            multistrikeRating = true,
            mainHandWeaponDamage = true,
            offHandWeaponDamage = true,
            baseDamageMultiplier = true
        }
        self.SNAPSHOT_STAT_NAME = {
            snapshotTime = true,
            masteryEffect = true,
            baseDamageMultiplier = true
        }
        self.snapshotTime = 0
        self.agility = 0
        self.intellect = 0
        self.spirit = 0
        self.stamina = 0
        self.strength = 0
        self.attackPower = 0
        self.rangedAttackPower = 0
        self.spellBonusDamage = 0
        self.spellBonusHealing = 0
        self.masteryEffect = 0
        self.meleeCrit = 0
        self.meleeHaste = 0
        self.rangedCrit = 0
        self.rangedHaste = 0
        self.spellCrit = 0
        self.spellHaste = 0
        self.multistrike = 0
        self.critRating = 0
        self.hasteRating = 0
        self.masteryRating = 0
        self.multistrikeRating = 0
        self.mainHandWeaponDamage = 0
        self.offHandWeaponDamage = 0
        self.baseDamageMultiplier = 1
        self.CopySpellcastInfo = function(module, spellcast, dest)
            self:UpdateSnapshot(dest, spellcast, true)
        end
        self.SaveSpellcastInfo = function(module, spellcast, atTime, state)
            local paperDollModule = state or self
            self:UpdateSnapshot(paperDollModule, spellcast, true)
        end
        __Debug.OvaleDebug:RegisterDebugging(__Profiler.OvaleProfiler:RegisterProfiling(OvalePaperDollBase)).constructor(self)
        self:RegisterEvent("COMBAT_RATING_UPDATE")
        self:RegisterEvent("MASTERY_UPDATE")
        self:RegisterEvent("MULTISTRIKE_UPDATE")
        self:RegisterEvent("PLAYER_ALIVE", "UpdateStats")
        self:RegisterEvent("PLAYER_DAMAGE_DONE_MODS")
        self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateStats")
        self:RegisterEvent("PLAYER_LEVEL_UP")
        self:RegisterEvent("SPELL_POWER_CHANGED")
        self:RegisterEvent("UNIT_ATTACK_POWER")
        self:RegisterEvent("UNIT_DAMAGE", "UpdateDamage")
        self:RegisterEvent("UNIT_LEVEL")
        self:RegisterEvent("UNIT_RANGEDDAMAGE")
        self:RegisterEvent("UNIT_RANGED_ATTACK_POWER")
        self:RegisterEvent("UNIT_SPELL_HASTE")
        self:RegisterEvent("UNIT_STATS")
        self:RegisterMessage("Ovale_EquipmentChanged", "UpdateDamage")
        self:RegisterMessage("Ovale_StanceChanged", "UpdateDamage")
        self:RegisterMessage("Ovale_TalentsChanged", "UpdateStats")
        __LastSpell.lastSpell:RegisterSpellcastInfo(self)
    end,
    OnDisable = function(self)
        __LastSpell.lastSpell:UnregisterSpellcastInfo(self)
        self:UnregisterEvent("COMBAT_RATING_UPDATE")
        self:UnregisterEvent("MASTERY_UPDATE")
        self:UnregisterEvent("MULTISTRIKE_UPDATE")
        self:UnregisterEvent("PLAYER_ALIVE")
        self:UnregisterEvent("PLAYER_DAMAGE_DONE_MODS")
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        self:UnregisterEvent("PLAYER_LEVEL_UP")
        self:UnregisterEvent("SPELL_POWER_CHANGED")
        self:UnregisterEvent("UNIT_ATTACK_POWER")
        self:UnregisterEvent("UNIT_DAMAGE")
        self:UnregisterEvent("UNIT_LEVEL")
        self:UnregisterEvent("UNIT_RANGEDDAMAGE")
        self:UnregisterEvent("UNIT_RANGED_ATTACK_POWER")
        self:UnregisterEvent("UNIT_SPELL_HASTE")
        self:UnregisterEvent("UNIT_STATS")
        self:UnregisterMessage("Ovale_EquipmentChanged")
        self:UnregisterMessage("Ovale_StanceChanged")
        self:UnregisterMessage("Ovale_TalentsChanged")
    end,
    COMBAT_RATING_UPDATE = function(self, event)
        self:StartProfiling("OvalePaperDoll_UpdateStats")
        self.meleeCrit = API_GetCritChance()
        self.rangedCrit = API_GetRangedCritChance()
        self.spellCrit = API_GetSpellCritChance(OVALE_SPELLDAMAGE_SCHOOL[self.class])
        self.critRating = API_GetCombatRating(_CR_CRIT_MELEE)
        self.hasteRating = API_GetCombatRating(_CR_HASTE_MELEE)
        self.snapshotTime = API_GetTime()
        __Ovale.Ovale:needRefresh()
        self:StopProfiling("OvalePaperDoll_UpdateStats")
    end,
    MASTERY_UPDATE = function(self, event)
        self:StartProfiling("OvalePaperDoll_UpdateStats")
        self.masteryRating = API_GetMastery()
        if self.level < 80 then
            self.masteryEffect = 0
        else
            self.masteryEffect = API_GetMasteryEffect()
            __Ovale.Ovale:needRefresh()
        end
        self.snapshotTime = API_GetTime()
        self:StopProfiling("OvalePaperDoll_UpdateStats")
    end,
    MULTISTRIKE_UPDATE = function(self, event)
        self:StartProfiling("OvalePaperDoll_UpdateStats")
        self.multistrikeRating = API_GetMultistrike()
        self.multistrike = API_GetMultistrikeEffect()
        self.snapshotTime = API_GetTime()
        __Ovale.Ovale:needRefresh()
        self:StopProfiling("OvalePaperDoll_UpdateStats")
    end,
    PLAYER_LEVEL_UP = function(self, event, level, ...)
        self:StartProfiling("OvalePaperDoll_UpdateStats")
        self.level = _tonumber(level) or API_UnitLevel("player")
        self.snapshotTime = API_GetTime()
        __Ovale.Ovale:needRefresh()
        self:DebugTimestamp("%s: level = %d", event, self.level)
        self:StopProfiling("OvalePaperDoll_UpdateStats")
    end,
    PLAYER_DAMAGE_DONE_MODS = function(self, event, unitId)
        self:StartProfiling("OvalePaperDoll_UpdateStats")
        self.spellBonusDamage = API_GetSpellBonusDamage(OVALE_SPELLDAMAGE_SCHOOL[self.class])
        self.spellBonusHealing = API_GetSpellBonusHealing()
        self.snapshotTime = API_GetTime()
        __Ovale.Ovale:needRefresh()
        self:StopProfiling("OvalePaperDoll_UpdateStats")
    end,
    SPELL_POWER_CHANGED = function(self, event)
        self:StartProfiling("OvalePaperDoll_UpdateStats")
        self.spellBonusDamage = API_GetSpellBonusDamage(OVALE_SPELLDAMAGE_SCHOOL[self.class])
        self.spellBonusDamage = API_GetSpellBonusDamage(OVALE_SPELLDAMAGE_SCHOOL[self.class])
        self.snapshotTime = API_GetTime()
        __Ovale.Ovale:needRefresh()
        self:StopProfiling("OvalePaperDoll_UpdateStats")
    end,
    UNIT_ATTACK_POWER = function(self, event, unitId)
        if unitId == "player" then
            self:StartProfiling("OvalePaperDoll_UpdateStats")
            local base, posBuff, negBuff = API_UnitAttackPower(unitId)
            self.attackPower = base + posBuff + negBuff
            self.snapshotTime = API_GetTime()
            __Ovale.Ovale:needRefresh()
            self:UpdateDamage(event)
            self:StopProfiling("OvalePaperDoll_UpdateStats")
        end
    end,
    UNIT_LEVEL = function(self, event, unitId)
        __Ovale.Ovale.refreshNeeded[unitId] = true
        if unitId == "player" then
            self:StartProfiling("OvalePaperDoll_UpdateStats")
            self.level = API_UnitLevel(unitId)
            self:DebugTimestamp("%s: level = %d", event, self.level)
            self.snapshotTime = API_GetTime()
            self:StopProfiling("OvalePaperDoll_UpdateStats")
        end
    end,
    UNIT_RANGEDDAMAGE = function(self, event, unitId)
        if unitId == "player" then
            self:StartProfiling("OvalePaperDoll_UpdateStats")
            self.rangedHaste = API_GetRangedHaste()
            self.snapshotTime = API_GetTime()
            __Ovale.Ovale:needRefresh()
            self:StopProfiling("OvalePaperDoll_UpdateStats")
        end
    end,
    UNIT_RANGED_ATTACK_POWER = function(self, event, unitId)
        if unitId == "player" then
            self:StartProfiling("OvalePaperDoll_UpdateStats")
            local base, posBuff, negBuff = API_UnitRangedAttackPower(unitId)
            __Ovale.Ovale:needRefresh()
            self.rangedAttackPower = base + posBuff + negBuff
            self.snapshotTime = API_GetTime()
            self:StopProfiling("OvalePaperDoll_UpdateStats")
        end
    end,
    UNIT_SPELL_HASTE = function(self, event, unitId)
        if unitId == "player" then
            self:StartProfiling("OvalePaperDoll_UpdateStats")
            self.meleeHaste = API_GetMeleeHaste()
            self.spellHaste = API_UnitSpellHaste(unitId)
            self.snapshotTime = API_GetTime()
            __Ovale.Ovale:needRefresh()
            self:UpdateDamage(event)
            self:StopProfiling("OvalePaperDoll_UpdateStats")
        end
    end,
    UNIT_STATS = function(self, event, unitId)
        if unitId == "player" then
            self:StartProfiling("OvalePaperDoll_UpdateStats")
            self.strength = API_UnitStat(unitId, 1)
            self.agility = API_UnitStat(unitId, 2)
            self.stamina = API_UnitStat(unitId, 3)
            self.intellect = API_UnitStat(unitId, 4)
            self.spirit = 0
            self.snapshotTime = API_GetTime()
            __Ovale.Ovale:needRefresh()
            self:StopProfiling("OvalePaperDoll_UpdateStats")
        end
    end,
    UpdateDamage = function(self, event)
        self:StartProfiling("OvalePaperDoll_UpdateDamage")
        local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, _, _, damageMultiplier = API_UnitDamage("player")
        local mainHandAttackSpeed, offHandAttackSpeed = API_UnitAttackSpeed("player")
        if damageMultiplier == 0 then
            damageMultiplier = 1
        end
        self.baseDamageMultiplier = damageMultiplier
        if self.class == "DRUID" and __Stance.OvaleStance:IsStance("druid_cat_form") then
            damageMultiplier = damageMultiplier * 2
        elseif self.class == "MONK" and __Equipment.OvaleEquipment:HasOneHandedWeapon() then
            damageMultiplier = damageMultiplier * 1.25
        end
        local avgDamage = (minDamage + maxDamage) / 2 / damageMultiplier
        local mainHandWeaponSpeed = mainHandAttackSpeed * self:GetMeleeHasteMultiplier()
        local normalizedMainHandWeaponSpeed = __Equipment.OvaleEquipment.mainHandWeaponSpeed or 1.5
        if self.class == "DRUID" then
            if __Stance.OvaleStance:IsStance("druid_cat_form") then
                normalizedMainHandWeaponSpeed = 1
            elseif __Stance.OvaleStance:IsStance("druid_bear_form") then
                normalizedMainHandWeaponSpeed = 2.5
            end
        end
        self.mainHandWeaponDamage = avgDamage / mainHandWeaponSpeed * normalizedMainHandWeaponSpeed
        if __Equipment.OvaleEquipment:HasOffHandWeapon() then
            local avgOffHandDamage = (minOffHandDamage + maxOffHandDamage) / 2 / damageMultiplier
            offHandAttackSpeed = offHandAttackSpeed or mainHandAttackSpeed
            local offHandWeaponSpeed = offHandAttackSpeed * self:GetMeleeHasteMultiplier()
            local normalizedOffHandWeaponSpeed = __Equipment.OvaleEquipment.offHandWeaponSpeed or 1.5
            if self.class == "DRUID" then
                if __Stance.OvaleStance:IsStance("druid_cat_form") then
                    normalizedOffHandWeaponSpeed = 1
                elseif __Stance.OvaleStance:IsStance("druid_bear_form") then
                    normalizedOffHandWeaponSpeed = 2.5
                end
            end
            self.offHandWeaponDamage = avgOffHandDamage / offHandWeaponSpeed * normalizedOffHandWeaponSpeed
        else
            self.offHandWeaponDamage = 0
        end
        self.snapshotTime = API_GetTime()
        __Ovale.Ovale:needRefresh()
        self:StopProfiling("OvalePaperDoll_UpdateDamage")
    end,
    UpdateSpecialization = function(self, event)
        self:StartProfiling("OvalePaperDoll_UpdateSpecialization")
        local newSpecialization = API_GetSpecialization()
        if self.specialization ~= newSpecialization then
            local oldSpecialization = self.specialization
            self.specialization = newSpecialization
            self.snapshotTime = API_GetTime()
            __Ovale.Ovale:needRefresh()
            self:SendMessage("Ovale_SpecializationChanged", self:GetSpecialization(newSpecialization), self:GetSpecialization(oldSpecialization))
        end
        self:StopProfiling("OvalePaperDoll_UpdateSpecialization")
    end,
    UpdateStats = function(self, event)
        self:UpdateSpecialization(event)
        self:COMBAT_RATING_UPDATE(event)
        self:MASTERY_UPDATE(event)
        self:PLAYER_DAMAGE_DONE_MODS(event, "player")
        self:SPELL_POWER_CHANGED(event)
        self:UNIT_ATTACK_POWER(event, "player")
        self:UNIT_RANGEDDAMAGE(event, "player")
        self:UNIT_RANGED_ATTACK_POWER(event, "player")
        self:UNIT_SPELL_HASTE(event, "player")
        self:UNIT_STATS(event, "player")
        self:UpdateDamage(event)
    end,
    GetSpecialization = function(self, specialization)
        specialization = specialization or self.specialization
        return OVALE_SPECIALIZATION_NAME[self.class][specialization]
    end,
    IsSpecialization = function(self, name)
        if name and self.specialization then
            if _type(name) == "number" then
                return name == self.specialization
            else
                return name == OVALE_SPECIALIZATION_NAME[self.class][self.specialization]
            end
        end
        return false
    end,
    GetMasteryMultiplier = function(self, snapshot)
        snapshot = snapshot or self
        return 1 + snapshot.masteryEffect / 100
    end,
    GetMeleeHasteMultiplier = function(self, snapshot)
        snapshot = snapshot or self
        return 1 + snapshot.meleeHaste / 100
    end,
    GetRangedHasteMultiplier = function(self, snapshot)
        snapshot = snapshot or self
        return 1 + snapshot.rangedHaste / 100
    end,
    GetSpellHasteMultiplier = function(self, snapshot)
        snapshot = snapshot or self
        return 1 + snapshot.spellHaste / 100
    end,
    GetHasteMultiplier = function(self, haste, snapshot)
        snapshot = snapshot or self
        local multiplier = 1
        if haste == "melee" then
            multiplier = self:GetMeleeHasteMultiplier(snapshot)
        elseif haste == "ranged" then
            multiplier = self:GetRangedHasteMultiplier(snapshot)
        elseif haste == "spell" then
            multiplier = self:GetSpellHasteMultiplier(snapshot)
        end
        return multiplier
    end,
    UpdateSnapshot = function(self, target, snapshot, updateAllStats)
        local nameTable = updateAllStats and __exports.OvalePaperDoll.STAT_NAME or __exports.OvalePaperDoll.SNAPSHOT_STAT_NAME
        for k in _pairs(nameTable) do
            target[k] = snapshot[k]
        end
    end,
})
local PaperDollState = __class(nil, {
    InitializeState = function(self)
        self.class = nil
        self.level = nil
        self.specialization = nil
        self.snapshotTime = 0
        self.agility = 0
        self.intellect = 0
        self.spirit = 0
        self.stamina = 0
        self.strength = 0
        self.attackPower = 0
        self.rangedAttackPower = 0
        self.spellBonusDamage = 0
        self.spellBonusHealing = 0
        self.masteryEffect = 0
        self.meleeCrit = 0
        self.meleeHaste = 0
        self.rangedCrit = 0
        self.rangedHaste = 0
        self.spellCrit = 0
        self.spellHaste = 0
        self.multistrike = 0
        self.critRating = 0
        self.hasteRating = 0
        self.masteryRating = 0
        self.multistrikeRating = 0
        self.mainHandWeaponDamage = 0
        self.offHandWeaponDamage = 0
        self.baseDamageMultiplier = 1
    end,
    CleanState = function(self)
    end,
    ResetState = function(self)
        self.class = self.class
        self.level = self.level
        self.specialization = self.specialization
        self:UpdateSnapshot(__exports.OvalePaperDoll, self, true)
    end,
    GetMasteryMultiplier = function(self, snapshot)
        return __exports.OvalePaperDoll:GetMasteryMultiplier(snapshot)
    end,
    GetMeleeHasteMultiplier = function(self, snapshot)
        return __exports.OvalePaperDoll:GetMeleeHasteMultiplier(snapshot)
    end,
    GetRangedHasteMultiplier = function(self, snapshot)
        return __exports.OvalePaperDoll:GetRangedHasteMultiplier(snapshot)
    end,
    GetSpellHasteMultiplier = function(self, snapshot)
        return __exports.OvalePaperDoll:GetSpellHasteMultiplier(snapshot)
    end,
    GetHasteMultiplier = function(self, haste, snapshot)
        return __exports.OvalePaperDoll:GetHasteMultiplier(haste, snapshot)
    end,
    UpdateSnapshot = function(self, target, snapshot, updateAllStats)
        __exports.OvalePaperDoll:UpdateSnapshot(target, snapshot, updateAllStats)
    end,
    constructor = function(self)
        self.class = nil
        self.level = nil
        self.specialization = nil
        self.snapshotTime = nil
        self.agility = nil
        self.intellect = nil
        self.spirit = nil
        self.stamina = nil
        self.strength = nil
        self.attackPower = nil
        self.rangedAttackPower = nil
        self.spellBonusDamage = nil
        self.spellBonusHealing = nil
        self.masteryEffect = nil
        self.meleeCrit = nil
        self.meleeHaste = nil
        self.rangedCrit = nil
        self.rangedHaste = nil
        self.spellCrit = nil
        self.spellHaste = nil
        self.multistrike = nil
        self.critRating = nil
        self.hasteRating = nil
        self.masteryRating = nil
        self.multistrikeRating = nil
        self.mainHandWeaponDamage = nil
        self.offHandWeaponDamage = nil
        self.baseDamageMultiplier = nil
    end
})
__exports.paperDollState = PaperDollState()
__State.OvaleState:RegisterState(__exports.paperDollState)
__exports.OvalePaperDoll = OvalePaperDollClass()
end)
