local __addonName, __addon = ...
__addon.require(__addonName, __addon, "./Aura", { "./Localization", "./Debug", "./Pool", "./Profiler", "./Data", "./Future", "./GUID", "./PaperDoll", "./SpellBook", "./State", "./Ovale" }, function(__exports, __Localization, __Debug, __Pool, __Profiler, __Data, __Future, __GUID, __PaperDoll, __SpellBook, __State, __Ovale)
local OvaleAuraBase = __Ovale.Ovale:NewModule("OvaleAura", "AceEvent-3.0")
local bit_band = bit.band
local bit_bor = bit.bor
local floor = math.floor
local _ipairs = ipairs
local _next = next
local _pairs = pairs
local strfind = string.find
local strlower = string.lower
local strsub = string.sub
local tconcat = table.concat
local tinsert = table.insert
local _tonumber = tonumber
local tsort = table.sort
local _type = type
local _wipe = wipe
local API_GetTime = GetTime
local API_UnitAura = UnitAura
local INFINITY = math.huge
local _SCHOOL_MASK_ARCANE = SCHOOL_MASK_ARCANE
local _SCHOOL_MASK_FIRE = SCHOOL_MASK_FIRE
local _SCHOOL_MASK_FROST = SCHOOL_MASK_FROST
local _SCHOOL_MASK_HOLY = SCHOOL_MASK_HOLY
local _SCHOOL_MASK_NATURE = SCHOOL_MASK_NATURE
local _SCHOOL_MASK_SHADOW = SCHOOL_MASK_SHADOW
local self_playerGUID = nil
local self_petGUID = nil
local self_pool = __Pool.OvalePool("OvaleAura_pool")
local UNKNOWN_GUID = 0
do
    local output = {}
    local debugOptions = {
        playerAura = {
            name = __Localization.L["Auras (player)"],
            type = "group",
            args = {
                buff = {
                    name = __Localization.L["Auras on the player"],
                    type = "input",
                    multiline = 25,
                    width = "full",
                    get = function(info)
                        _wipe(output)
                        local helpful = __exports.auraState:DebugUnitAuras("player", "HELPFUL")
                        if helpful then
                            output[#output + 1] = "== BUFFS =="
                            output[#output + 1] = helpful
                        end
                        local harmful = __exports.auraState:DebugUnitAuras("player", "HARMFUL")
                        if harmful then
                            output[#output + 1] = "== DEBUFFS =="
                            output[#output + 1] = harmful
                        end
                        return tconcat(output, "\n")
                    end

                }
            }
        },
        targetAura = {
            name = __Localization.L["Auras (target)"],
            type = "group",
            args = {
                targetbuff = {
                    name = __Localization.L["Auras on the target"],
                    type = "input",
                    multiline = 25,
                    width = "full",
                    get = function(info)
                        _wipe(output)
                        local helpful = __exports.auraState:DebugUnitAuras("target", "HELPFUL")
                        if helpful then
                            output[#output + 1] = "== BUFFS =="
                            output[#output + 1] = helpful
                        end
                        local harmful = __exports.auraState:DebugUnitAuras("target", "HARMFUL")
                        if harmful then
                            output[#output + 1] = "== DEBUFFS =="
                            output[#output + 1] = harmful
                        end
                        return tconcat(output, "\n")
                    end

                }
            }
        }
    }
    for k, v in _pairs(debugOptions) do
        __Debug.OvaleDebug.options.args[k] = v
    end
end
local DEBUFF_TYPE = {
    Curse = true,
    Disease = true,
    Enrage = true,
    Magic = true,
    Poison = true
}
local SPELLINFO_DEBUFF_TYPE = {}
do
    for debuffType in _pairs(DEBUFF_TYPE) do
        local siDebuffType = strlower(debuffType)
        SPELLINFO_DEBUFF_TYPE[siDebuffType] = debuffType
    end
end
local CLEU_AURA_EVENTS = {
    SPELL_AURA_APPLIED = true,
    SPELL_AURA_REMOVED = true,
    SPELL_AURA_APPLIED_DOSE = true,
    SPELL_AURA_REMOVED_DOSE = true,
    SPELL_AURA_REFRESH = true,
    SPELL_AURA_BROKEN = true,
    SPELL_AURA_BROKEN_SPELL = true
}
local CLEU_TICK_EVENTS = {
    SPELL_PERIODIC_DAMAGE = true,
    SPELL_PERIODIC_HEAL = true,
    SPELL_PERIODIC_ENERGIZE = true,
    SPELL_PERIODIC_DRAIN = true,
    SPELL_PERIODIC_LEECH = true
}
local CLEU_SCHOOL_MASK_MAGIC = bit_bor(_SCHOOL_MASK_ARCANE, _SCHOOL_MASK_FIRE, _SCHOOL_MASK_FROST, _SCHOOL_MASK_HOLY, _SCHOOL_MASK_NATURE, _SCHOOL_MASK_SHADOW)
local PutAura = function(auraDB, guid, auraId, casterGUID, aura)
    if  not auraDB[guid] then
        auraDB[guid] = self_pool:Get()
    end
    if  not auraDB[guid][auraId] then
        auraDB[guid][auraId] = self_pool:Get()
    end
    if auraDB[guid][auraId][casterGUID] then
        self_pool:Release(auraDB[guid][auraId][casterGUID])
    end
    auraDB[guid][auraId][casterGUID] = aura
    aura.guid = guid
    aura.spellId = auraId
    aura.source = casterGUID
end

local GetAura = function(auraDB, guid, auraId, casterGUID)
    if auraDB[guid] and auraDB[guid][auraId] and auraDB[guid][auraId][casterGUID] then
        if auraId == 215570 then
            local spellcast = __Future.OvaleFuture:LastInFlightSpell()
            if spellcast and spellcast.spellId and spellcast.spellId == 190411 and spellcast.start then
                local aura = auraDB[guid][auraId][casterGUID]
                if aura.start and aura.start < spellcast.start then
                    aura.ending = spellcast.start
                end
            end
        end
        return auraDB[guid][auraId][casterGUID]
    end
end

local GetAuraAnyCaster = function(auraDB, guid, auraId)
    local auraFound
    if auraDB[guid] and auraDB[guid][auraId] then
        for casterGUID, aura in _pairs(auraDB[guid][auraId]) do
            if  not auraFound or auraFound.ending < aura.ending then
                auraFound = aura
            end
        end
    end
    return auraFound
end

local GetDebuffType = function(auraDB, guid, debuffType, filter, casterGUID)
    local auraFound
    if auraDB[guid] then
        for auraId, whoseTable in _pairs(auraDB[guid]) do
            local aura = whoseTable[casterGUID]
            if aura and aura.debuffType == debuffType and aura.filter == filter then
                if  not auraFound or auraFound.ending < aura.ending then
                    auraFound = aura
                end
            end
        end
    end
    return auraFound
end

local GetDebuffTypeAnyCaster = function(auraDB, guid, debuffType, filter)
    local auraFound
    if auraDB[guid] then
        for auraId, whoseTable in _pairs(auraDB[guid]) do
            for casterGUID, aura in _pairs(whoseTable) do
                if aura and aura.debuffType == debuffType and aura.filter == filter then
                    if  not auraFound or auraFound.ending < aura.ending then
                        auraFound = aura
                    end
                end
            end
        end
    end
    return auraFound
end

local GetAuraOnGUID = function(auraDB, guid, auraId, filter, mine)
    local auraFound
    if DEBUFF_TYPE[auraId] then
        if mine then
            auraFound = GetDebuffType(auraDB, guid, auraId, filter, self_playerGUID)
            if  not auraFound then
                for petGUID in _pairs(self_petGUID) do
                    local aura = GetDebuffType(auraDB, guid, auraId, filter, petGUID)
                    if aura and ( not auraFound or auraFound.ending < aura.ending) then
                        auraFound = aura
                    end
                end
            end
        else
            auraFound = GetDebuffTypeAnyCaster(auraDB, guid, auraId, filter)
        end
    else
        if mine then
            auraFound = GetAura(auraDB, guid, auraId, self_playerGUID)
            if  not auraFound then
                for petGUID in _pairs(self_petGUID) do
                    local aura = GetAura(auraDB, guid, auraId, petGUID)
                    if aura and ( not auraFound or auraFound.ending < aura.ending) then
                        auraFound = aura
                    end
                end
            end
        else
            auraFound = GetAuraAnyCaster(auraDB, guid, auraId)
        end
    end
    return auraFound
end

local RemoveAurasOnGUID = function(auraDB, guid)
    if auraDB[guid] then
        local auraTable = auraDB[guid]
        for auraId, whoseTable in _pairs(auraTable) do
            for casterGUID, aura in _pairs(whoseTable) do
                self_pool:Release(aura)
                whoseTable[casterGUID] = nil
            end
            self_pool:Release(whoseTable)
            auraTable[auraId] = nil
        end
        self_pool:Release(auraTable)
        auraDB[guid] = nil
    end
end

local IsWithinAuraLag = function(time1, time2, factor)
    factor = factor or 1
    local auraLag = __Ovale.Ovale.db.profile.apparence.auraLag
    local tolerance = factor * auraLag / 1000
    return (time1 - time2 < tolerance) and (time2 - time1 < tolerance)
end

local OvaleAuraClass = __class(__Profiler.OvaleProfiler:RegisterProfiling(__Debug.OvaleDebug:RegisterDebugging(OvaleAuraBase)), {
    OnInitialize = function(self)
    end,
    OnEnable = function(self)
        self_playerGUID = __Ovale.Ovale.playerGUID
        self_petGUID = __GUID.OvaleGUID.petGUID
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self:RegisterEvent("UNIT_AURA")
        self:RegisterMessage("Ovale_GroupChanged", "ScanAllUnitAuras")
        self:RegisterMessage("Ovale_UnitChanged")
        __Data.OvaleData:RegisterRequirement("buff", "RequireBuffHandler", self)
        __Data.OvaleData:RegisterRequirement("buff_any", "RequireBuffHandler", self)
        __Data.OvaleData:RegisterRequirement("debuff", "RequireBuffHandler", self)
        __Data.OvaleData:RegisterRequirement("debuff_any", "RequireBuffHandler", self)
        __Data.OvaleData:RegisterRequirement("pet_buff", "RequireBuffHandler", self)
        __Data.OvaleData:RegisterRequirement("pet_debuff", "RequireBuffHandler", self)
        __Data.OvaleData:RegisterRequirement("stealth", "RequireStealthHandler", self)
        __Data.OvaleData:RegisterRequirement("stealthed", "RequireStealthHandler", self)
        __Data.OvaleData:RegisterRequirement("target_buff", "RequireBuffHandler", self)
        __Data.OvaleData:RegisterRequirement("target_buff_any", "RequireBuffHandler", self)
        __Data.OvaleData:RegisterRequirement("target_debuff", "RequireBuffHandler", self)
        __Data.OvaleData:RegisterRequirement("target_debuff_any", "RequireBuffHandler", self)
    end,
    OnDisable = function(self)
        __Data.OvaleData:UnregisterRequirement("buff")
        __Data.OvaleData:UnregisterRequirement("buff_any")
        __Data.OvaleData:UnregisterRequirement("debuff")
        __Data.OvaleData:UnregisterRequirement("debuff_any")
        __Data.OvaleData:UnregisterRequirement("pet_buff")
        __Data.OvaleData:UnregisterRequirement("pet_debuff")
        __Data.OvaleData:UnregisterRequirement("stealth")
        __Data.OvaleData:UnregisterRequirement("stealthed")
        __Data.OvaleData:UnregisterRequirement("target_buff")
        __Data.OvaleData:UnregisterRequirement("target_buff_any")
        __Data.OvaleData:UnregisterRequirement("target_debuff")
        __Data.OvaleData:UnregisterRequirement("target_debuff_any")
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        self:UnregisterEvent("PLAYER_UNGHOST")
        self:UnregisterEvent("UNIT_AURA")
        self:UnregisterMessage("Ovale_GroupChanged")
        self:UnregisterMessage("Ovale_UnitChanged")
        for guid in _pairs(self.aura) do
            RemoveAurasOnGUID(self.aura, guid)
        end
        self_pool:Drain()
    end,
    COMBAT_LOG_EVENT_UNFILTERED = function(self, event, timestamp, cleuEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
        local arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25 = ...
        local mine = (sourceGUID == self_playerGUID or __GUID.OvaleGUID:IsPlayerPet(sourceGUID))
        if mine and cleuEvent == "SPELL_MISSED" then
            local spellId, spellName, spellSchool = arg12, arg13, arg14
            local si = __Data.OvaleData.spellInfo[spellId]
            local bypassState = __exports.OvaleAura.bypassState
            if si and si.aura and si.aura.player then
                for filter, auraTable in _pairs(si.aura.player) do
                    for auraId in _pairs(auraTable) do
                        if  not bypassState[auraId] then
                            bypassState[auraId] = {}
                        end
                        bypassState[auraId][self_playerGUID] = true
                    end
                end
            end
            if si and si.aura and si.aura.target then
                for filter, auraTable in _pairs(si.aura.target) do
                    for auraId in _pairs(auraTable) do
                        if  not bypassState[auraId] then
                            bypassState[auraId] = {}
                        end
                        bypassState[auraId][destGUID] = true
                    end
                end
            end
            if si and si.aura and si.aura.pet then
                for filter, auraTable in _pairs(si.aura.pet) do
                    for auraId, index in _pairs(auraTable) do
                        for petGUID in _pairs(self_petGUID) do
                            if  not bypassState[petGUID] then
                                bypassState[auraId] = {}
                            end
                            bypassState[auraId][petGUID] = true
                        end
                    end
                end
            end
        end
        if CLEU_AURA_EVENTS[cleuEvent] then
            local unitId = __GUID.OvaleGUID:GUIDUnit(destGUID)
            if unitId then
                if  not __GUID.OvaleGUID.UNIT_AURA_UNIT[unitId] then
                    self:DebugTimestamp("%s: %s (%s)", cleuEvent, destGUID, unitId)
                    self:ScanAuras(unitId, destGUID)
                end
            elseif mine then
                local spellId, spellName, spellSchool = arg12, arg13, arg14
                self:DebugTimestamp("%s: %s (%d) on %s", cleuEvent, spellName, spellId, destGUID)
                local now = API_GetTime()
                if cleuEvent == "SPELL_AURA_REMOVED" or cleuEvent == "SPELL_AURA_BROKEN" or cleuEvent == "SPELL_AURA_BROKEN_SPELL" then
                    self:LostAuraOnGUID(destGUID, now, spellId, sourceGUID)
                else
                    local auraType, amount = arg15, arg16
                    local filter = (auraType == "BUFF") and "HELPFUL" or "HARMFUL"
                    local si = __Data.OvaleData.spellInfo[spellId]
                    local aura = GetAuraOnGUID(self.aura, destGUID, spellId, filter, true)
                    local duration
                    if aura then
                        duration = aura.duration
                    elseif si and si.duration then
                        duration = __Data.OvaleData:GetSpellInfoProperty(spellId, now, "duration", destGUID)
                        if si.addduration then
                            duration = duration + si.addduration
                        end
                    else
                        duration = 15
                    end
                    local expirationTime = now + duration
                    local count
                    if cleuEvent == "SPELL_AURA_APPLIED" then
                        count = 1
                    elseif cleuEvent == "SPELL_AURA_APPLIED_DOSE" or cleuEvent == "SPELL_AURA_REMOVED_DOSE" then
                        count = amount
                    elseif cleuEvent == "SPELL_AURA_REFRESH" then
                        count = aura and aura.stacks or 1
                    end
                    self:GainedAuraOnGUID(destGUID, now, spellId, sourceGUID, filter, true, nil, count, nil, duration, expirationTime, nil, spellName)
                end
            end
        elseif mine and CLEU_TICK_EVENTS[cleuEvent] then
            local spellId, spellName, spellSchool = arg12, arg13, arg14
            local multistrike
            if strsub(cleuEvent, -7) == "_DAMAGE" then
                multistrike = arg25
            elseif strsub(cleuEvent, -5) == "_HEAL" then
                multistrike = arg19
            end
            if  not multistrike then
                self:DebugTimestamp("%s: %s", cleuEvent, destGUID)
                local aura = GetAura(self.aura, destGUID, spellId, self_playerGUID)
                local now = API_GetTime()
                if self:IsActiveAura(aura, now) then
                    local name = aura.name or "Unknown spell"
                    local baseTick, lastTickTime = aura.baseTick, aura.lastTickTime
                    local tick = baseTick
                    if lastTickTime then
                        tick = timestamp - lastTickTime
                    elseif  not baseTick then
                        self:Debug("    First tick seen of unknown periodic aura %s (%d) on %s.", name, spellId, destGUID)
                        local si = __Data.OvaleData.spellInfo[spellId]
                        baseTick = (si and si.tick) and si.tick or 3
                        tick = __Data.OvaleData:GetTickLength(spellId)
                    end
                    aura.baseTick = baseTick
                    aura.lastTickTime = timestamp
                    aura.tick = tick
                    self:Debug("    Updating %s (%s) on %s, tick=%s, lastTickTime=%s", name, spellId, destGUID, tick, lastTickTime)
                    __Ovale.Ovale.refreshNeeded[destGUID] = true
                end
            end
        end
    end,
    PLAYER_ENTERING_WORLD = function(self, event)
        self:ScanAllUnitAuras()
    end,
    PLAYER_REGEN_ENABLED = function(self, event)
        self:RemoveAurasOnInactiveUnits()
        self_pool:Drain()
    end,
    UNIT_AURA = function(self, event, unitId)
        self:Debug("%s: %s", event, unitId)
        self:ScanAuras(unitId)
    end,
    Ovale_UnitChanged = function(self, event, unitId, guid)
        if (unitId == "pet" or unitId == "target") and guid then
            self:Debug(event, unitId, guid)
            self:ScanAuras(unitId, guid)
        end
    end,
    ScanAllUnitAuras = function(self)
        for unitId in _pairs(__GUID.OvaleGUID.UNIT_AURA_UNIT) do
            self:ScanAuras(unitId)
        end
    end,
    RemoveAurasOnInactiveUnits = function(self)
        for guid in _pairs(self.aura) do
            local unitId = __GUID.OvaleGUID:GUIDUnit(guid)
            if  not unitId then
                self:Debug("Removing auras from GUID %s", guid)
                RemoveAurasOnGUID(self.aura, guid)
                self.serial[guid] = nil
            end
        end
    end,
    IsActiveAura = function(self, aura, atTime)
        local boolean = false
        if aura then
            atTime = atTime or API_GetTime()
            if aura.serial == self.serial[aura.guid] and aura.stacks > 0 and aura.gain <= atTime and atTime <= aura.ending then
                boolean = true
            elseif aura.consumed and IsWithinAuraLag(aura.ending, atTime) then
                boolean = true
            end
        end
        return boolean
    end,
    GainedAuraOnGUID = function(self, guid, atTime, auraId, casterGUID, filter, visible, icon, count, debuffType, duration, expirationTime, isStealable, name, value1, value2, value3)
        self:StartProfiling("OvaleAura_GainedAuraOnGUID")
        casterGUID = casterGUID or UNKNOWN_GUID
        count = (count and count > 0) and count or 1
        duration = (duration and duration > 0) and duration or INFINITY
        expirationTime = (expirationTime and expirationTime > 0) and expirationTime or INFINITY
        local aura = GetAura(self.aura, guid, auraId, casterGUID)
        local auraIsActive
        if aura then
            auraIsActive = (aura.stacks > 0 and aura.gain <= atTime and atTime <= aura.ending)
        else
            aura = self_pool:Get()
            PutAura(self.aura, guid, auraId, casterGUID, aura)
            auraIsActive = false
        end
        local auraIsUnchanged = (aura.source == casterGUID and aura.duration == duration and aura.ending == expirationTime and aura.stacks == count and aura.value1 == value1 and aura.value2 == value2 and aura.value3 == value3)
        aura.serial = self.serial[guid]
        if  not auraIsActive or  not auraIsUnchanged then
            self:Debug("    Adding %s %s (%s) to %s at %f, aura.serial=%d", filter, name, auraId, guid, atTime, aura.serial)
            aura.name = name
            aura.duration = duration
            aura.ending = expirationTime
            if duration < INFINITY and expirationTime < INFINITY then
                aura.start = expirationTime - duration
            else
                aura.start = atTime
            end
            aura.gain = atTime
            aura.lastUpdated = atTime
            local direction = aura.direction or 1
            if aura.stacks then
                if aura.stacks < count then
                    direction = 1
                elseif aura.stacks > count then
                    direction = -1
                end
            end
            aura.direction = direction
            aura.stacks = count
            aura.consumed = nil
            aura.filter = filter
            aura.visible = visible
            aura.icon = icon
            aura.debuffType = debuffType
            aura.enrage = (debuffType == "Enrage") or nil
            aura.stealable = isStealable
            aura.value1, aura.value2, aura.value3 = value1, value2, value3
            local mine = (casterGUID == self_playerGUID or __GUID.OvaleGUID:IsPlayerPet(casterGUID))
            if mine then
                local spellcast = __Future.OvaleFuture:LastInFlightSpell()
                if spellcast and spellcast.stop and  not IsWithinAuraLag(spellcast.stop, atTime) then
                    spellcast = __Future.OvaleFuture.lastSpellcast
                    if spellcast and spellcast.stop and  not IsWithinAuraLag(spellcast.stop, atTime) then
                        spellcast = nil
                    end
                end
                if spellcast and spellcast.target == guid then
                    local spellId = spellcast.spellId
                    local spellName = __SpellBook.OvaleSpellBook:GetSpellName(spellId) or "Unknown spell"
                    local keepSnapshot = false
                    local si = __Data.OvaleData.spellInfo[spellId]
                    if si and si.aura then
                        local auraTable = __GUID.OvaleGUID:IsPlayerPet(guid) and si.aura.pet or si.aura.target
                        if auraTable and auraTable[filter] then
                            local spellData = auraTable[filter][auraId]
                            if spellData == "refresh_keep_snapshot" then
                                keepSnapshot = true
                            elseif _type(spellData) == "table" and spellData[1] == "refresh_keep_snapshot" then
                                keepSnapshot = __Data.OvaleData:CheckRequirements(spellId, atTime, spellData, 2, guid)
                            end
                        end
                    end
                    if keepSnapshot then
                        self:Debug("    Keeping snapshot stats for %s %s (%d) on %s refreshed by %s (%d) from %f, now=%f, aura.serial=%d", filter, name, auraId, guid, spellName, spellId, aura.snapshotTime, atTime, aura.serial)
                    else
                        self:Debug("    Snapshot stats for %s %s (%d) on %s applied by %s (%d) from %f, now=%f, aura.serial=%d", filter, name, auraId, guid, spellName, spellId, spellcast.snapshotTime, atTime, aura.serial)
                        __Future.OvaleFuture:CopySpellcastInfo(spellcast, aura)
                    end
                end
                local si = __Data.OvaleData.spellInfo[auraId]
                if si then
                    if si.tick then
                        self:Debug("    %s (%s) is a periodic aura.", name, auraId)
                        if  not auraIsActive then
                            aura.baseTick = si.tick
                            if spellcast and spellcast.target == guid then
                                aura.tick = __Data.OvaleData:GetTickLength(auraId, spellcast)
                            else
                                aura.tick = __Data.OvaleData:GetTickLength(auraId)
                            end
                        end
                    end
                    if si.buff_cd and guid == self_playerGUID then
                        self:Debug("    %s (%s) is applied by an item with a cooldown of %ds.", name, auraId, si.buff_cd)
                        if  not auraIsActive then
                            aura.cooldownEnding = aura.gain + si.buff_cd
                        end
                    end
                end
            end
            if  not auraIsActive then
                self:SendMessage("Ovale_AuraAdded", atTime, guid, auraId, aura.source)
            elseif  not auraIsUnchanged then
                self:SendMessage("Ovale_AuraChanged", atTime, guid, auraId, aura.source)
            end
            __Ovale.Ovale.refreshNeeded[guid] = true
        end
        self:StopProfiling("OvaleAura_GainedAuraOnGUID")
    end,
    LostAuraOnGUID = function(self, guid, atTime, auraId, casterGUID)
        self:StartProfiling("OvaleAura_LostAuraOnGUID")
        local aura = GetAura(self.aura, guid, auraId, casterGUID)
        if aura then
            local filter = aura.filter
            self:Debug("    Expiring %s %s (%d) from %s at %f.", filter, aura.name, auraId, guid, atTime)
            if aura.ending > atTime then
                aura.ending = atTime
            end
            local mine = (casterGUID == self_playerGUID or __GUID.OvaleGUID:IsPlayerPet(casterGUID))
            if mine then
                aura.baseTick = nil
                aura.lastTickTime = nil
                aura.tick = nil
                if aura.start + aura.duration > aura.ending then
                    local spellcast
                    if guid == self_playerGUID then
                        spellcast = __Future.OvaleFuture:LastSpellSent()
                    else
                        spellcast = __Future.OvaleFuture.lastSpellcast
                    end
                    if spellcast then
                        if (spellcast.success and spellcast.stop and IsWithinAuraLag(spellcast.stop, aura.ending)) or (spellcast.queued and IsWithinAuraLag(spellcast.queued, aura.ending)) then
                            aura.consumed = true
                            local spellName = __SpellBook.OvaleSpellBook:GetSpellName(spellcast.spellId) or "Unknown spell"
                            self:Debug("    Consuming %s %s (%d) on %s with queued %s (%d) at %f.", filter, aura.name, auraId, guid, spellName, spellcast.spellId, spellcast.queued)
                        end
                    end
                end
            end
            aura.lastUpdated = atTime
            self:SendMessage("Ovale_AuraRemoved", atTime, guid, auraId, aura.source)
            __Ovale.Ovale.refreshNeeded[guid] = true
        end
        self:StopProfiling("OvaleAura_LostAuraOnGUID")
    end,
    ScanAuras = function(self, unitId, guid)
        self:StartProfiling("OvaleAura_ScanAuras")
        guid = guid or __GUID.OvaleGUID:UnitGUID(unitId)
        if guid then
            self:DebugTimestamp("Scanning auras on %s (%s)", guid, unitId)
            local serial = self.serial[guid] or 0
            serial = serial + 1
            self:Debug("    Advancing age of auras for %s (%s) to %d.", guid, unitId, serial)
            self.serial[guid] = serial
            local i = 1
            local filter = "HELPFUL"
            local now = API_GetTime()
            while true do
                local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, isCastByPlayer, value1, value2, value3 = API_UnitAura(unitId, i, filter)
                if  not name then
                    if filter == "HELPFUL" then
                        filter = "HARMFUL"
                        i = 1
                    else
                        break
                    end
                else
                    local casterGUID = __GUID.OvaleGUID:UnitGUID(unitCaster)
                    if debuffType == "" then
                        debuffType = "Enrage"
                    end
                    self:GainedAuraOnGUID(guid, now, spellId, casterGUID, filter, true, icon, count, debuffType, duration, expirationTime, isStealable, name, value1, value2, value3)
                    i = i + 1
                end
            end
            if self.aura[guid] then
                local auraTable = self.aura[guid]
                for auraId, whoseTable in _pairs(auraTable) do
                    for casterGUID, aura in _pairs(whoseTable) do
                        if aura.serial == serial - 1 then
                            if aura.visible then
                                self:LostAuraOnGUID(guid, now, auraId, casterGUID)
                            else
                                aura.serial = serial
                                self:Debug("    Preserving aura %s (%d), start=%s, ending=%s, aura.serial=%d", aura.name, aura.spellId, aura.start, aura.ending, aura.serial)
                            end
                        end
                    end
                end
            end
            self:Debug("End scanning of auras on %s (%s).", guid, unitId)
        end
        self:StopProfiling("OvaleAura_ScanAuras")
    end,
    GetAuraByGUID = function(self, guid, auraId, filter, mine)
        if  not self.serial[guid] then
            local unitId = __GUID.OvaleGUID:GUIDUnit(guid)
            self:ScanAuras(unitId, guid)
        end
        local auraFound
        if __Data.OvaleData.buffSpellList[auraId] then
            for id in _pairs(__Data.OvaleData.buffSpellList[auraId]) do
                local aura = GetAuraOnGUID(self.aura, guid, id, filter, mine)
                if aura and ( not auraFound or auraFound.ending < aura.ending) then
                    auraFound = aura
                end
            end
        else
            auraFound = GetAuraOnGUID(self.aura, guid, auraId, filter, mine)
        end
        return auraFound
    end,
    GetAura = function(self, unitId, auraId, filter, mine)
        local guid = __GUID.OvaleGUID:UnitGUID(unitId)
        return self:GetAuraByGUID(guid, auraId, filter, mine)
    end,
    RequireBuffHandler = function(self, spellId, atTime, requirement, tokens, index, targetGUID)
        local verified = false
        local buffName = tokens
        local stacks = 1
        if index then
            buffName = tokens[index]
            index = index + 1
            local count = _tonumber(tokens[index])
            if count then
                stacks = count
                index = index + 1
            end
        end
        if buffName then
            local isBang = false
            if strsub(buffName, 1, 1) == "!" then
                isBang = true
                buffName = strsub(buffName, 2)
            end
            buffName = _tonumber(buffName) or buffName
            local guid, unitId, filter, mine
            if strsub(requirement, 1, 7) == "target_" then
                if targetGUID then
                    guid = targetGUID
                    unitId = __GUID.OvaleGUID:GUIDUnit(guid)
                else
                    unitId = __State.baseState.defaultTarget or "target"
                end
                filter = (strsub(requirement, 8, 11) == "buff") and "HELPFUL" or "HARMFUL"
                mine =  not (strsub(requirement, -4) == "_any")
            elseif strsub(requirement, 1, 4) == "pet_" then
                unitId = "pet"
                filter = (strsub(requirement, 5, 11) == "buff") and "HELPFUL" or "HARMFUL"
                mine = false
            else
                unitId = "player"
                filter = (strsub(requirement, 1, 4) == "buff") and "HELPFUL" or "HARMFUL"
                mine =  not (strsub(requirement, -4) == "_any")
            end
            guid = guid or __GUID.OvaleGUID:UnitGUID(unitId)
            local aura = self:GetAuraByGUID(guid, buffName, filter, mine)
            local isActiveAura = self:IsActiveAura(aura, atTime) and aura.stacks >= stacks
            if  not isBang and isActiveAura or isBang and  not isActiveAura then
                verified = true
            end
            local result = verified and "passed" or "FAILED"
            if isBang then
                self:Log("    Require aura %s with at least %d stack(s) NOT on %s at time=%f: %s", buffName, stacks, unitId, atTime, result)
            else
                self:Log("    Require aura %s with at least %d stack(s) on %s at time=%f: %s", buffName, stacks, unitId, atTime, result)
            end
        else
            __Ovale.Ovale:OneTimeMessage("Warning: requirement '%s' is missing a buff argument.", requirement)
        end
        return verified, requirement, index
    end,
    RequireStealthHandler = function(self, spellId, atTime, requirement, tokens, index, targetGUID)
        local verified = false
        local stealthed = tokens
        if index then
            stealthed = tokens[index]
            index = index + 1
        end
        if stealthed then
            stealthed = _tonumber(stealthed)
            local aura = self:GetAura("player", "stealthed_buff", "HELPFUL", true)
            local isActiveAura = self:IsActiveAura(aura, atTime)
            if stealthed == 1 and isActiveAura or stealthed ~= 1 and  not isActiveAura then
                verified = true
            end
            local result = verified and "passed" or "FAILED"
            if stealthed == 1 then
                self:Log("    Require stealth at time=%f: %s", atTime, result)
            else
                self:Log("    Require NOT stealth at time=%f: %s", atTime, result)
            end
        else
            __Ovale.Ovale:OneTimeMessage("Warning: requirement '%s' is missing an argument.", requirement)
        end
        return verified, requirement, index
    end,
})
local array = {}
local AuraState = __class(nil, {
    InitializeState = function(self)
        self.aura = {}
        self.serial = 0
    end,
    ResetState = function(self)
        __exports.OvaleAura:StartProfiling("OvaleAura_ResetState")
        self.serial = self.serial + 1
        if _next(self.aura) then
            __exports.OvaleAura:Log("Resetting aura state:")
        end
        for guid, auraTable in _pairs(self.aura) do
            for auraId, whoseTable in _pairs(auraTable) do
                for casterGUID, aura in _pairs(whoseTable) do
                    self_pool:Release(aura)
                    whoseTable[casterGUID] = nil
                    __exports.OvaleAura:Log("    Aura %d on %s removed.", auraId, guid)
                end
                if  not _next(whoseTable) then
                    self_pool:Release(whoseTable)
                    auraTable[auraId] = nil
                end
            end
            if  not _next(auraTable) then
                self_pool:Release(auraTable)
                self.aura[guid] = nil
            end
        end
        __exports.OvaleAura:StopProfiling("OvaleAura_ResetState")
    end,
    CleanState = function(self)
        for guid in _pairs(self.aura) do
            RemoveAurasOnGUID(self.aura, guid)
        end
    end,
    ApplySpellStartCast = function(self, spellId, targetGUID, startCast, endCast, isChanneled, spellcast)
        __exports.OvaleAura:StartProfiling("OvaleAura_ApplySpellStartCast")
        if isChanneled then
            local si = __Data.OvaleData.spellInfo[spellId]
            if si and si.aura then
                if si.aura.player then
                    self:ApplySpellAuras(spellId, self_playerGUID, startCast, si.aura.player, spellcast)
                end
                if si.aura.target then
                    self:ApplySpellAuras(spellId, targetGUID, startCast, si.aura.target, spellcast)
                end
                if si.aura.pet then
                    local petGUID = __GUID.OvaleGUID:UnitGUID("pet")
                    if petGUID then
                        self:ApplySpellAuras(spellId, petGUID, startCast, si.aura.pet, spellcast)
                    end
                end
            end
        end
        __exports.OvaleAura:StopProfiling("OvaleAura_ApplySpellStartCast")
    end,
    ApplySpellAfterCast = function(self, spellId, targetGUID, startCast, endCast, isChanneled, spellcast)
        __exports.OvaleAura:StartProfiling("OvaleAura_ApplySpellAfterCast")
        if  not isChanneled then
            local si = __Data.OvaleData.spellInfo[spellId]
            if si and si.aura then
                if si.aura.player then
                    self:ApplySpellAuras(spellId, self_playerGUID, endCast, si.aura.player, spellcast)
                end
                if si.aura.pet then
                    local petGUID = __GUID.OvaleGUID:UnitGUID("pet")
                    if petGUID then
                        self:ApplySpellAuras(spellId, petGUID, startCast, si.aura.pet, spellcast)
                    end
                end
            end
        end
        __exports.OvaleAura:StopProfiling("OvaleAura_ApplySpellAfterCast")
    end,
    ApplySpellOnHit = function(self, spellId, targetGUID, startCast, endCast, isChanneled, spellcast)
        __exports.OvaleAura:StartProfiling("OvaleAura_ApplySpellAfterHit")
        if  not isChanneled then
            local si = __Data.OvaleData.spellInfo[spellId]
            if si and si.aura and si.aura.target then
                local travelTime = si.travel_time or 0
                if travelTime > 0 then
                    local estimatedTravelTime = 1
                    if travelTime < estimatedTravelTime then
                        travelTime = estimatedTravelTime
                    end
                end
                local atTime = endCast + travelTime
                self:ApplySpellAuras(spellId, targetGUID, atTime, si.aura.target, spellcast)
            end
        end
        __exports.OvaleAura:StopProfiling("OvaleAura_ApplySpellAfterHit")
    end,
    GetStateAura = function(self, guid, auraId, casterGUID)
        local aura = GetAura(self.aura, guid, auraId, casterGUID)
        if  not aura or aura.serial < self.serial then
            aura = GetAura(__exports.OvaleAura.aura, guid, auraId, casterGUID)
        end
        return aura
    end,
    GetStateAuraAnyCaster = function(self, guid, auraId)
        local auraFound
        if __exports.OvaleAura.aura[guid] and __exports.OvaleAura.aura[guid][auraId] then
            for casterGUID in _pairs(__exports.OvaleAura.aura[guid][auraId]) do
                local aura = self:GetStateAura(guid, auraId, casterGUID)
                if aura and  not aura.state and __exports.OvaleAura:IsActiveAura(aura, __State.baseState.currentTime) then
                    if  not auraFound or auraFound.ending < aura.ending then
                        auraFound = aura
                    end
                end
            end
        end
        if self.aura[guid] and self.aura[guid][auraId] then
            for casterGUID, aura in _pairs(self.aura[guid][auraId]) do
                if aura.stacks > 0 then
                    if  not auraFound or auraFound.ending < aura.ending then
                        auraFound = aura
                    end
                end
            end
        end
        return auraFound
    end,
    GetStateDebuffType = function(self, guid, debuffType, filter, casterGUID)
        local auraFound
        if __exports.OvaleAura.aura[guid] then
            for auraId in _pairs(__exports.OvaleAura.aura[guid]) do
                local aura = self:GetStateAura(guid, auraId, casterGUID)
                if aura and  not aura.state and __exports.OvaleAura:IsActiveAura(aura, __State.baseState.currentTime) then
                    if aura.debuffType == debuffType and aura.filter == filter then
                        if  not auraFound or auraFound.ending < aura.ending then
                            auraFound = aura
                        end
                    end
                end
            end
        end
        if self.aura[guid] then
            for auraId, whoseTable in _pairs(self.aura[guid]) do
                local aura = whoseTable[casterGUID]
                if aura and aura.stacks > 0 then
                    if aura.debuffType == debuffType and aura.filter == filter then
                        if  not auraFound or auraFound.ending < aura.ending then
                            auraFound = aura
                        end
                    end
                end
            end
        end
        return auraFound
    end,
    GetStateDebuffTypeAnyCaster = function(self, guid, debuffType, filter)
        local auraFound
        if __exports.OvaleAura.aura[guid] then
            for auraId, whoseTable in _pairs(__exports.OvaleAura.aura[guid]) do
                for casterGUID in _pairs(whoseTable) do
                    local aura = self:GetStateAura(guid, auraId, casterGUID)
                    if aura and  not aura.state and __exports.OvaleAura:IsActiveAura(aura, __State.baseState.currentTime) then
                        if aura.debuffType == debuffType and aura.filter == filter then
                            if  not auraFound or auraFound.ending < aura.ending then
                                auraFound = aura
                            end
                        end
                    end
                end
            end
        end
        if self.aura[guid] then
            for auraId, whoseTable in _pairs(self.aura[guid]) do
                for casterGUID, aura in _pairs(whoseTable) do
                    if aura and  not aura.state and aura.stacks > 0 then
                        if aura.debuffType == debuffType and aura.filter == filter then
                            if  not auraFound or auraFound.ending < aura.ending then
                                auraFound = aura
                            end
                        end
                    end
                end
            end
        end
        return auraFound
    end,
    GetStateAuraOnGUID = function(self, guid, auraId, filter, mine)
        local auraFound
        if DEBUFF_TYPE[auraId] then
            if mine then
                auraFound = self:GetStateDebuffType(guid, auraId, filter, self_playerGUID)
                if  not auraFound then
                    for petGUID in _pairs(self_petGUID) do
                        local aura = self:GetStateDebuffType(guid, auraId, filter, petGUID)
                        if aura and ( not auraFound or auraFound.ending < aura.ending) then
                            auraFound = aura
                        end
                    end
                end
            else
                auraFound = self:GetStateDebuffTypeAnyCaster(guid, auraId, filter)
            end
        else
            if mine then
                local aura = self:GetStateAura(guid, auraId, self_playerGUID)
                if aura and aura.stacks > 0 then
                    auraFound = aura
                else
                    for petGUID in _pairs(self_petGUID) do
                        aura = self:GetStateAura(guid, auraId, petGUID)
                        if aura and aura.stacks > 0 then
                            auraFound = aura
                            break
                        end
                    end
                end
            else
                auraFound = self:GetStateAuraAnyCaster(guid, auraId)
            end
        end
        return auraFound
    end,
    DebugUnitAuras = function(self, unitId, filter)
        _wipe(array)
        local guid = __GUID.OvaleGUID:UnitGUID(unitId)
        if __exports.OvaleAura.aura[guid] then
            for auraId, whoseTable in _pairs(__exports.OvaleAura.aura[guid]) do
                for casterGUID in _pairs(whoseTable) do
                    local aura = self:GetStateAura(guid, auraId, casterGUID)
                    if self:IsActiveAura(aura) and aura.filter == filter and  not aura.state then
                        local name = aura.name or "Unknown spell"
                        tinsert(array, name .. auraId)
                    end
                end
            end
        end
        if self.aura[guid] then
            for auraId, whoseTable in _pairs(self.aura[guid]) do
                for casterGUID, aura in _pairs(whoseTable) do
                    if self:IsActiveAura(aura) and aura.filter == filter then
                        local name = aura.name or "Unknown spell"
                        tinsert(array, name .. auraId)
                    end
                end
            end
        end
        if _next(array) then
            tsort(array)
            return tconcat(array, "\n")
        end
    end,
    IsActiveAura = function(self, aura, atTime)
        atTime = atTime or __State.baseState.currentTime
        local boolean = false
        if aura then
            if aura.state then
                if aura.serial == self.serial and aura.stacks > 0 and aura.gain <= atTime and atTime <= aura.ending then
                    boolean = true
                elseif aura.consumed and IsWithinAuraLag(aura.ending, atTime) then
                    boolean = true
                end
            else
                boolean = __exports.OvaleAura:IsActiveAura(aura, atTime)
            end
        end
        return boolean
    end,
    CanApplySpellAura = function(self, spellData)
        if spellData["if_target_debuff"] then
        elseif spellData["if_buff"] then
        end
    end,
    ApplySpellAuras = function(self, spellId, guid, atTime, auraList, spellcast)
        __exports.OvaleAura:StartProfiling("OvaleAura_state_ApplySpellAuras")
        for filter, filterInfo in _pairs(auraList) do
            for auraId, spellData in _pairs(filterInfo) do
                local duration = __Data.OvaleData:GetBaseDuration(auraId, spellcast)
                local stacks = 1
                local count = nil
                local extend = 0
                local toggle = nil
                local refresh = false
                local keepSnapshot = false
                local verified, value, data = __Data.dataState:CheckSpellAuraData(auraId, spellData, atTime, guid)
                if value == "refresh" then
                    refresh = true
                elseif value == "refresh_keep_snapshot" then
                    refresh = true
                    keepSnapshot = true
                elseif value == "toggle" then
                    toggle = true
                elseif value == "count" then
                    count = data
                elseif value == "extend" then
                    extend = data
                elseif _tonumber(value) then
                    stacks = _tonumber(value)
                else
                    __exports.OvaleAura:Log("Unknown stack %s", stacks)
                end
                if verified then
                    local si = __Data.OvaleData.spellInfo[auraId]
                    local auraFound = self:GetAuraByGUID(guid, auraId, filter, true)
                    if self:IsActiveAura(auraFound, atTime) then
                        local aura
                        if auraFound.state then
                            aura = auraFound
                        else
                            aura = self:AddAuraToGUID(guid, auraId, auraFound.source, filter, nil, 0, INFINITY)
                            for k, v in _pairs(auraFound) do
                                aura[k] = v
                            end
                            aura.serial = self.serial
                            __exports.OvaleAura:Log("Aura %d is copied into simulator.", auraId)
                        end
                        if toggle then
                            __exports.OvaleAura:Log("Aura %d is toggled off by spell %d.", auraId, spellId)
                            stacks = 0
                        end
                        if count and count > 0 then
                            stacks = count - aura.stacks
                        end
                        if refresh or extend > 0 or stacks > 0 then
                            if refresh then
                                __exports.OvaleAura:Log("Aura %d is refreshed to %d stack(s).", auraId, aura.stacks)
                            elseif extend > 0 then
                                __exports.OvaleAura:Log("Aura %d is extended by %f seconds, preserving %d stack(s).", auraId, extend, aura.stacks)
                            else
                                local maxStacks = 1
                                if si and (si.max_stacks or si.maxstacks) then
                                    maxStacks = si.max_stacks or si.maxstacks
                                end
                                aura.stacks = aura.stacks + stacks
                                if aura.stacks > maxStacks then
                                    aura.stacks = maxStacks
                                end
                                __exports.OvaleAura:Log("Aura %d gains %d stack(s) to %d because of spell %d.", auraId, stacks, aura.stacks, spellId)
                            end
                            if extend > 0 then
                                aura.duration = aura.duration + extend
                                aura.ending = aura.ending + extend
                            else
                                aura.start = atTime
                                if aura.tick and aura.tick > 0 then
                                    local remainingDuration = aura.ending - atTime
                                    local extensionDuration = 0.3 * duration
                                    if remainingDuration < extensionDuration then
                                        aura.duration = remainingDuration + duration
                                    else
                                        aura.duration = extensionDuration + duration
                                    end
                                else
                                    aura.duration = duration
                                end
                                aura.ending = aura.start + aura.duration
                            end
                            aura.gain = atTime
                            __exports.OvaleAura:Log("Aura %d with duration %s now ending at %s", auraId, aura.duration, aura.ending)
                            if keepSnapshot then
                                __exports.OvaleAura:Log("Aura %d keeping previous snapshot.", auraId)
                            elseif spellcast then
                                __Future.OvaleFuture:CopySpellcastInfo(spellcast, aura)
                            end
                        elseif stacks == 0 or stacks < 0 then
                            if stacks == 0 then
                                aura.stacks = 0
                            else
                                aura.stacks = aura.stacks + stacks
                                if aura.stacks < 0 then
                                    aura.stacks = 0
                                end
                                __exports.OvaleAura:Log("Aura %d loses %d stack(s) to %d because of spell %d.", auraId, -1 * stacks, aura.stacks, spellId)
                            end
                            if aura.stacks == 0 then
                                __exports.OvaleAura:Log("Aura %d is completely removed.", auraId)
                                aura.ending = atTime
                                aura.consumed = true
                            end
                        end
                    else
                        if toggle then
                            __exports.OvaleAura:Log("Aura %d is toggled on by spell %d.", auraId, spellId)
                            stacks = 1
                        end
                        if  not refresh and stacks > 0 then
                            __exports.OvaleAura:Log("New aura %d at %f on %s", auraId, atTime, guid)
                            local debuffType
                            if si then
                                for k, v in _pairs(SPELLINFO_DEBUFF_TYPE) do
                                    if si[k] == 1 then
                                        debuffType = v
                                        break
                                    end
                                end
                            end
                            local aura = self:AddAuraToGUID(guid, auraId, self_playerGUID, filter, debuffType, 0, INFINITY)
                            aura.stacks = stacks
                            aura.start = atTime
                            aura.duration = duration
                            if si and si.tick then
                                aura.baseTick = si.tick
                                aura.tick = __Data.OvaleData:GetTickLength(auraId, spellcast)
                            end
                            aura.ending = aura.start + aura.duration
                            aura.gain = aura.start
                            if spellcast then
                                __Future.OvaleFuture:CopySpellcastInfo(spellcast, aura)
                            end
                        end
                    end
                else
                    __exports.OvaleAura:Log("Aura %d (%s) is not applied.", auraId, spellData)
                end
            end
        end
        __exports.OvaleAura:StopProfiling("OvaleAura_state_ApplySpellAuras")
    end,
    GetAuraByGUID = function(self, guid, auraId, filter, mine)
        local auraFound
        if __Data.OvaleData.buffSpellList[auraId] then
            for id in _pairs(__Data.OvaleData.buffSpellList[auraId]) do
                local aura = self:GetStateAuraOnGUID(guid, id, filter, mine)
                if aura and ( not auraFound or auraFound.ending < aura.ending) then
                    __exports.OvaleAura:Log("Aura %s matching '%s' found on %s with (%s, %s)", id, auraId, guid, aura.start, aura.ending)
                    auraFound = aura
                else
                end
            end
            if  not auraFound then
                __exports.OvaleAura:Log("Aura matching '%s' is missing on %s.", auraId, guid)
            end
        else
            auraFound = self:GetStateAuraOnGUID(guid, auraId, filter, mine)
            if auraFound then
                __exports.OvaleAura:Log("Aura %s found on %s with (%s, %s)", auraId, guid, auraFound.start, auraFound.ending)
            else
                __exports.OvaleAura:Log("Aura %s is missing on %s.", auraId, guid)
            end
        end
        return auraFound
    end,
    GetAura = function(self, unitId, auraId, filter, mine)
        local guid = __GUID.OvaleGUID:UnitGUID(unitId)
        local stateAura = self:GetAuraByGUID(guid, auraId, filter, mine)
        local aura = __exports.OvaleAura:GetAuraByGUID(guid, auraId, filter, mine)
        local bypassState = __exports.OvaleAura.bypassState
        if  not bypassState[auraId] then
            bypassState[auraId] = {}
        end
        if bypassState[auraId][guid] then
            if aura and aura.start and aura.ending and stateAura and stateAura.start and stateAura.ending and aura.start == stateAura.start and aura.ending == stateAura.ending then
                bypassState[auraId][guid] = false
                return stateAura
            else
                return aura
            end
        end
        return self:GetAuraByGUID(guid, auraId, filter, mine)
    end,
    AddAuraToGUID = function(self, guid, auraId, casterGUID, filter, debuffType, start, ending, snapshot)
        local aura = self_pool:Get()
        aura.state = true
        aura.serial = self.serial
        aura.lastUpdated = __State.baseState.currentTime
        aura.filter = filter
        aura.start = start or 0
        aura.ending = ending or INFINITY
        aura.duration = aura.ending - aura.start
        aura.gain = aura.start
        aura.stacks = 1
        aura.debuffType = debuffType
        aura.enrage = (debuffType == "Enrage") or nil
        __PaperDoll.paperDollState:UpdateSnapshot(aura, snapshot)
        PutAura(self.aura, guid, auraId, casterGUID, aura)
        return aura
    end,
    RemoveAuraOnGUID = function(self, guid, auraId, filter, mine, atTime)
        local auraFound = self:GetAuraByGUID(guid, auraId, filter, mine)
        if self:IsActiveAura(auraFound, atTime) then
            local aura
            if auraFound.state then
                aura = auraFound
            else
                aura = self:AddAuraToGUID(guid, auraId, auraFound.source, filter, nil, 0, INFINITY)
                for k, v in _pairs(auraFound) do
                    aura[k] = v
                end
                aura.serial = self.serial
            end
            aura.stacks = 0
            aura.ending = atTime
            aura.lastUpdated = atTime
        end
    end,
    GetAuraWithProperty = function(self, unitId, propertyName, filter, atTime)
        atTime = atTime or __State.baseState.currentTime
        local count = 0
        local guid = __GUID.OvaleGUID:UnitGUID(unitId)
        local start, ending = INFINITY, 0
        if __exports.OvaleAura.aura[guid] then
            for auraId, whoseTable in _pairs(__exports.OvaleAura.aura[guid]) do
                for casterGUID in _pairs(whoseTable) do
                    local aura = self:GetStateAura(guid, auraId, self_playerGUID)
                    if self:IsActiveAura(aura, atTime) and  not aura.state then
                        if aura[propertyName] and aura.filter == filter then
                            count = count + 1
                            start = (aura.gain < start) and aura.gain or start
                            ending = (aura.ending > ending) and aura.ending or ending
                        end
                    end
                end
            end
        end
        if self.aura[guid] then
            for auraId, whoseTable in _pairs(self.aura[guid]) do
                for casterGUID, aura in _pairs(whoseTable) do
                    if self:IsActiveAura(aura, atTime) then
                        if aura[propertyName] and aura.filter == filter then
                            count = count + 1
                            start = (aura.gain < start) and aura.gain or start
                            ending = (aura.ending > ending) and aura.ending or ending
                        end
                    end
                end
            end
        end
        if count > 0 then
            __exports.OvaleAura:Log("Aura with '%s' property found on %s (count=%s, minStart=%s, maxEnding=%s).", propertyName, unitId, count, start, ending)
        else
            __exports.OvaleAura:Log("Aura with '%s' property is missing on %s.", propertyName, unitId)
            start = nil
            ending = nil
        end
        return start, ending
    end,
    CountMatchingActiveAura = function(self, aura)
        local count
        local stacks
        local startChangeCount, endingChangeCount
        local startFirst, endingLast
        __State.OvaleState:Log("Counting aura %s found on %s with (%s, %s)", aura.spellId, aura.guid, aura.start, aura.ending)
        count = count + 1
        stacks = stacks + aura.stacks
        if aura.ending < endingChangeCount then
            startChangeCount, endingChangeCount = aura.gain, aura.ending
        end
        if aura.gain < startFirst then
            startFirst = aura.gain
        end
        if aura.ending > endingLast then
            endingLast = aura.ending
        end
    end,
    AuraCount = function(self, auraId, filter, mine, minStacks, atTime, excludeUnitId)
        __exports.OvaleAura:StartProfiling("OvaleAura_state_AuraCount")
        minStacks = minStacks or 1
        local count = 0
        local stacks = 0
        local startChangeCount, endingChangeCount = INFINITY, INFINITY
        local startFirst, endingLast = INFINITY, 0
        local excludeGUID = excludeUnitId and __GUID.OvaleGUID:UnitGUID(excludeUnitId) or nil
        for guid, auraTable in _pairs(__exports.OvaleAura.aura) do
            if guid ~= excludeGUID and auraTable[auraId] then
                if mine then
                    local aura = self:GetStateAura(guid, auraId, self_playerGUID)
                    if self:IsActiveAura(aura, atTime) and aura.filter == filter and aura.stacks >= minStacks and  not aura.state then
                        self:CountMatchingActiveAura(aura)
                    end
                    for petGUID in _pairs(self_petGUID) do
                        aura = self:GetStateAura(guid, auraId, petGUID)
                        if self:IsActiveAura(aura, atTime) and aura.filter == filter and aura.stacks >= minStacks and  not aura.state then
                            self:CountMatchingActiveAura(aura)
                        end
                    end
                else
                    for casterGUID in _pairs(auraTable[auraId]) do
                        local aura = self:GetStateAura(guid, auraId, casterGUID)
                        if self:IsActiveAura(aura, atTime) and aura.filter == filter and aura.stacks >= minStacks and  not aura.state then
                            self:CountMatchingActiveAura(aura)
                        end
                    end
                end
            end
        end
        for guid, auraTable in _pairs(self.aura) do
            if guid ~= excludeGUID and auraTable[auraId] then
                if mine then
                    local aura = auraTable[auraId][self_playerGUID]
                    if aura then
                        if self:IsActiveAura(aura, atTime) and aura.filter == filter and aura.stacks >= minStacks then
                            self:CountMatchingActiveAura(aura)
                        end
                    end
                    for petGUID in _pairs(self_petGUID) do
                        aura = auraTable[auraId][petGUID]
                        if self:IsActiveAura(aura, atTime) and aura.filter == filter and aura.stacks >= minStacks and  not aura.state then
                            self:CountMatchingActiveAura(aura)
                        end
                    end
                else
                    for casterGUID, aura in _pairs(auraTable[auraId]) do
                        if self:IsActiveAura(aura, atTime) and aura.filter == filter and aura.stacks >= minStacks then
                            self:CountMatchingActiveAura(aura)
                        end
                    end
                end
            end
        end
        __exports.OvaleAura:Log("AuraCount(%d) is %s, %s, %s, %s, %s, %s", auraId, count, stacks, startChangeCount, endingChangeCount, startFirst, endingLast)
        __exports.OvaleAura:StopProfiling("OvaleAura_state_AuraCount")
        return count, stacks, startChangeCount, endingChangeCount, startFirst, endingLast
    end,
    RequireBuffHandler = function(self, spellId, atTime, requirement, tokens, index, targetGUID)
        return __exports.OvaleAura:RequireBuffHandler(spellId, atTime, requirement, tokens, index, targetGUID)
    end,
    RequireStealthHandler = function(self, spellId, atTime, requirement, tokens, index, targetGUID)
        return __exports.OvaleAura:RequireStealthHandler(spellId, atTime, requirement, tokens, index, targetGUID)
    end,
})
__exports.auraState = AuraState()
__State.OvaleState:RegisterState(__exports.auraState)
end)
