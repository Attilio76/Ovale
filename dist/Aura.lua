local OVALE, Ovale = ...
require(OVALE, Ovale, "Aura", { "./L", "./OvaleDebug", "./OvalePool", "./OvaleProfiler", "./db" }, function(__exports, __L, __OvaleDebug, __OvalePool, __OvaleProfiler, __db)
local OvaleAura = Ovale:NewModule("OvaleAura", "AceEvent-3.0")
Ovale.OvaleAura = OvaleAura
local OvaleData = nil
local OvaleFuture = nil
local OvaleGUID = nil
local OvalePaperDoll = nil
local OvaleSpellBook = nil
local OvaleState = nil
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
__OvaleDebug.OvaleDebug:RegisterDebugging(OvaleAura)
__OvaleProfiler.OvaleProfiler:RegisterProfiling(OvaleAura)
local self_playerGUID = nil
local self_petGUID = nil
local self_pool = __OvalePool.OvalePool("OvaleAura_pool")
local UNKNOWN_GUID = 0
do
    local output = {}
    local debugOptions = {
        playerAura = {
            name = __L.L["Auras (player)"],
            type = "group",
            args = {
                buff = {
                    name = __L.L["Auras on the player"],
                    type = "input",
                    multiline = 25,
                    width = "full",
                    get = function(info)
                        _wipe(output)
                        local helpful = OvaleState.state:DebugUnitAuras("player", "HELPFUL")
                        if helpful then
                            output[#output + 1] = "== BUFFS =="
                            output[#output + 1] = helpful
                        end
                        local harmful = OvaleState.state:DebugUnitAuras("player", "HARMFUL")
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
            name = __L.L["Auras (target)"],
            type = "group",
            args = {
                targetbuff = {
                    name = __L.L["Auras on the target"],
                    type = "execute",
                    type = "input",
                    multiline = 25,
                    width = "full",
                    get = function(info)
                        _wipe(output)
                        local helpful = OvaleState.state:DebugUnitAuras("target", "HELPFUL")
                        if helpful then
                            output[#output + 1] = "== BUFFS =="
                            output[#output + 1] = helpful
                        end
                        local harmful = OvaleState.state:DebugUnitAuras("target", "HARMFUL")
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
        __OvaleDebug.OvaleDebug.options.args[k] = v
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
OvaleAura.aura = {}
OvaleAura.serial = {}
OvaleAura.bypassState = {}
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
            local spellcast = OvaleFuture:LastInFlightSpell()
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
    local tolerance = factor * __db.auraLag / 1000
    return (time1 - time2 < tolerance) and (time2 - time1 < tolerance)
end
local OvaleAura = __class()
function OvaleAura:OnInitialize()
    OvaleData = Ovale.OvaleData
    OvaleFuture = Ovale.OvaleFuture
    OvaleGUID = Ovale.OvaleGUID
    OvalePaperDoll = Ovale.OvalePaperDoll
    OvaleSpellBook = Ovale.OvaleSpellBook
    OvaleState = Ovale.OvaleState
end
function OvaleAura:OnEnable()
    self_playerGUID = Ovale.playerGUID
    self_petGUID = OvaleGUID.petGUID
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterMessage("Ovale_GroupChanged", "ScanAllUnitAuras")
    self:RegisterMessage("Ovale_UnitChanged")
    OvaleData:RegisterRequirement("buff", "RequireBuffHandler", self)
    OvaleData:RegisterRequirement("buff_any", "RequireBuffHandler", self)
    OvaleData:RegisterRequirement("debuff", "RequireBuffHandler", self)
    OvaleData:RegisterRequirement("debuff_any", "RequireBuffHandler", self)
    OvaleData:RegisterRequirement("pet_buff", "RequireBuffHandler", self)
    OvaleData:RegisterRequirement("pet_debuff", "RequireBuffHandler", self)
    OvaleData:RegisterRequirement("stealth", "RequireStealthHandler", self)
    OvaleData:RegisterRequirement("stealthed", "RequireStealthHandler", self)
    OvaleData:RegisterRequirement("target_buff", "RequireBuffHandler", self)
    OvaleData:RegisterRequirement("target_buff_any", "RequireBuffHandler", self)
    OvaleData:RegisterRequirement("target_debuff", "RequireBuffHandler", self)
    OvaleData:RegisterRequirement("target_debuff_any", "RequireBuffHandler", self)
    OvaleState:RegisterState(self, self.statePrototype)
end
function OvaleAura:OnDisable()
    OvaleState:UnregisterState(self)
    OvaleData:UnregisterRequirement("buff")
    OvaleData:UnregisterRequirement("buff_any")
    OvaleData:UnregisterRequirement("debuff")
    OvaleData:UnregisterRequirement("debuff_any")
    OvaleData:UnregisterRequirement("pet_buff")
    OvaleData:UnregisterRequirement("pet_debuff")
    OvaleData:UnregisterRequirement("stealth")
    OvaleData:UnregisterRequirement("stealthed")
    OvaleData:UnregisterRequirement("target_buff")
    OvaleData:UnregisterRequirement("target_buff_any")
    OvaleData:UnregisterRequirement("target_debuff")
    OvaleData:UnregisterRequirement("target_debuff_any")
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
end
function OvaleAura:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, cleuEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    local arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25 = ...
    local mine = (sourceGUID == self_playerGUID or OvaleGUID:IsPlayerPet(sourceGUID))
    if mine and cleuEvent == "SPELL_MISSED" then
        local spellId, spellName, spellSchool = arg12, arg13, arg14
        local si = OvaleData.spellInfo[spellId]
        local bypassState = OvaleAura.bypassState
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
        local unitId = OvaleGUID:GUIDUnit(destGUID)
        if unitId then
            if  not OvaleGUID.UNIT_AURA_UNIT[unitId] then
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
                local si = OvaleData.spellInfo[spellId]
                local aura = GetAuraOnGUID(self.aura, destGUID, spellId, filter, true)
                local duration
                if aura then
                    duration = aura.duration
                elseif si and si.duration then
                    duration = OvaleData:GetSpellInfoProperty(spellId, now, "duration", destGUID)
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
                    local si = OvaleData.spellInfo[spellId]
                    baseTick = (si and si.tick) and si.tick or 3
                    tick = OvaleData:GetTickLength(spellId)
                end
                aura.baseTick = baseTick
                aura.lastTickTime = timestamp
                aura.tick = tick
                self:Debug("    Updating %s (%s) on %s, tick=%s, lastTickTime=%s", name, spellId, destGUID, tick, lastTickTime)
                Ovale.refreshNeeded[destGUID] = true
            end
        end
    end
end
function OvaleAura:PLAYER_ENTERING_WORLD(event)
    self:ScanAllUnitAuras()
end
function OvaleAura:PLAYER_REGEN_ENABLED(event)
    self:RemoveAurasOnInactiveUnits()
    self_pool:Drain()
end
function OvaleAura:UNIT_AURA(event, unitId)
    self:Debug("%s: %s", event, unitId)
    self:ScanAuras(unitId)
end
function OvaleAura:Ovale_UnitChanged(event, unitId, guid)
    if (unitId == "pet" or unitId == "target") and guid then
        self:Debug(event, unitId, guid)
        self:ScanAuras(unitId, guid)
    end
end
function OvaleAura:ScanAllUnitAuras()
    for unitId in _pairs(OvaleGUID.UNIT_AURA_UNIT) do
        self:ScanAuras(unitId)
    end
end
function OvaleAura:RemoveAurasOnInactiveUnits()
    for guid in _pairs(self.aura) do
        local unitId = OvaleGUID:GUIDUnit(guid)
        if  not unitId then
            self:Debug("Removing auras from GUID %s", guid)
            RemoveAurasOnGUID(self.aura, guid)
            self.serial[guid] = nil
        end
    end
end
function OvaleAura:IsActiveAura(aura, atTime)
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
end
function OvaleAura:GainedAuraOnGUID(guid, atTime, auraId, casterGUID, filter, visible, icon, count, debuffType, duration, expirationTime, isStealable, name, value1, value2, value3)
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
        local mine = (casterGUID == self_playerGUID or OvaleGUID:IsPlayerPet(casterGUID))
        if mine then
            local spellcast = OvaleFuture:LastInFlightSpell()
            if spellcast and spellcast.stop and  not IsWithinAuraLag(spellcast.stop, atTime) then
                spellcast = OvaleFuture.lastSpellcast
                if spellcast and spellcast.stop and  not IsWithinAuraLag(spellcast.stop, atTime) then
                    spellcast = nil
                end
            end
            if spellcast and spellcast.target == guid then
                local spellId = spellcast.spellId
                local spellName = OvaleSpellBook:GetSpellName(spellId) or "Unknown spell"
                local keepSnapshot = false
                local si = OvaleData.spellInfo[spellId]
                if si and si.aura then
                    local auraTable = OvaleGUID:IsPlayerPet(guid) and si.aura.pet or si.aura.target
                    if auraTable and auraTable[filter] then
                        local spellData = auraTable[filter][auraId]
                        if spellData == "refresh_keep_snapshot" then
                            keepSnapshot = true
                        elseif _type(spellData) == "table" and spellData[1] == "refresh_keep_snapshot" then
                            keepSnapshot = OvaleData:CheckRequirements(spellId, atTime, spellData, 2, guid)
                        end
                    end
                end
                if keepSnapshot then
                    self:Debug("    Keeping snapshot stats for %s %s (%d) on %s refreshed by %s (%d) from %f, now=%f, aura.serial=%d", filter, name, auraId, guid, spellName, spellId, aura.snapshotTime, atTime, aura.serial)
                else
                    self:Debug("    Snapshot stats for %s %s (%d) on %s applied by %s (%d) from %f, now=%f, aura.serial=%d", filter, name, auraId, guid, spellName, spellId, spellcast.snapshotTime, atTime, aura.serial)
                    OvaleFuture:CopySpellcastInfo(spellcast, aura)
                end
            end
            local si = OvaleData.spellInfo[auraId]
            if si then
                if si.tick then
                    self:Debug("    %s (%s) is a periodic aura.", name, auraId)
                    if  not auraIsActive then
                        aura.baseTick = si.tick
                        if spellcast and spellcast.target == guid then
                            aura.tick = OvaleData:GetTickLength(auraId, spellcast)
                        else
                            aura.tick = OvaleData:GetTickLength(auraId)
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
        Ovale.refreshNeeded[guid] = true
    end
    self:StopProfiling("OvaleAura_GainedAuraOnGUID")
end
function OvaleAura:LostAuraOnGUID(guid, atTime, auraId, casterGUID)
    self:StartProfiling("OvaleAura_LostAuraOnGUID")
    local aura = GetAura(self.aura, guid, auraId, casterGUID)
    if aura then
        local filter = aura.filter
        self:Debug("    Expiring %s %s (%d) from %s at %f.", filter, aura.name, auraId, guid, atTime)
        if aura.ending > atTime then
            aura.ending = atTime
        end
        local mine = (casterGUID == self_playerGUID or OvaleGUID:IsPlayerPet(casterGUID))
        if mine then
            aura.baseTick = nil
            aura.lastTickTime = nil
            aura.tick = nil
            if aura.start + aura.duration > aura.ending then
                local spellcast
                if guid == self_playerGUID then
                    spellcast = OvaleFuture:LastSpellSent()
                else
                    spellcast = OvaleFuture.lastSpellcast
                end
                if spellcast then
                    if (spellcast.success and spellcast.stop and IsWithinAuraLag(spellcast.stop, aura.ending)) or (spellcast.queued and IsWithinAuraLag(spellcast.queued, aura.ending)) then
                        aura.consumed = true
                        local spellName = OvaleSpellBook:GetSpellName(spellcast.spellId) or "Unknown spell"
                        self:Debug("    Consuming %s %s (%d) on %s with queued %s (%d) at %f.", filter, aura.name, auraId, guid, spellName, spellcast.spellId, spellcast.queued)
                    end
                end
            end
        end
        aura.lastUpdated = atTime
        self:SendMessage("Ovale_AuraRemoved", atTime, guid, auraId, aura.source)
        Ovale.refreshNeeded[guid] = true
    end
    self:StopProfiling("OvaleAura_LostAuraOnGUID")
end
function OvaleAura:ScanAuras(unitId, guid)
    self:StartProfiling("OvaleAura_ScanAuras")
    guid = guid or OvaleGUID:UnitGUID(unitId)
    if guid then
        self:DebugTimestamp("Scanning auras on %s (%s)", guid, unitId)
        local serial = self.serial[guid] or 0
        serial = serial + 1
        self:Debug("    Advancing age of auras for %s (%s) to %d.", guid, unitId, serial)
        self.serial[guid] = serial
        local i = 1
        local filter = "HELPFUL"
        local now = API_GetTime()
        while truedo
            local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, isCastByPlayer, value1, value2, value3 = API_UnitAura(unitId, i, filter)
            if  not name then
                if filter == "HELPFUL" then
                    filter = "HARMFUL"
                    i = 1
                else
                    break
                end
            else
                local casterGUID = OvaleGUID:UnitGUID(unitCaster)
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
end
function OvaleAura:GetAuraByGUID(guid, auraId, filter, mine)
    if  not self.serial[guid] then
        local unitId = OvaleGUID:GUIDUnit(guid)
        self:ScanAuras(unitId, guid)
    end
    local auraFound
    if OvaleData.buffSpellList[auraId] then
        for id in _pairs(OvaleData.buffSpellList[auraId]) do
            local aura = GetAuraOnGUID(self.aura, guid, id, filter, mine)
            if aura and ( not auraFound or auraFound.ending < aura.ending) then
                auraFound = aura
            end
        end
    else
        auraFound = GetAuraOnGUID(self.aura, guid, auraId, filter, mine)
    end
    return auraFound
end
function OvaleAura:GetAura(unitId, auraId, filter, mine)
    local guid = OvaleGUID:UnitGUID(unitId)
    return self:GetAuraByGUID(guid, auraId, filter, mine)
end
function OvaleAura:RequireBuffHandler(spellId, atTime, requirement, tokens, index, targetGUID)
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
        local buffName = _tonumber(buffName) or buffName
        local guid, unitId, filter, mine
        if strsub(requirement, 1, 7) == "target_" then
            if targetGUID then
                guid = targetGUID
                unitId = OvaleGUID:GUIDUnit(guid)
            else
                unitId = self.defaultTarget or "target"
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
        guid = guid or OvaleGUID:UnitGUID(unitId)
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
        Ovale:OneTimeMessage("Warning: requirement '%s' is missing a buff argument.", requirement)
    end
    return verified, requirement, index
end
function OvaleAura:RequireStealthHandler(spellId, atTime, requirement, tokens, index, targetGUID)
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
        Ovale:OneTimeMessage("Warning: requirement '%s' is missing an argument.", requirement)
    end
    return verified, requirement, index
end
OvaleAura.statePrototype = {
    aura = nil,
    serial = nil
}
local statePrototype = OvaleAura.statePrototype
statePrototype.aura = nil
statePrototype.serial = nil
local OvaleAura = __class()
function OvaleAura:InitializeState(state)
    state.aura = {}
    state.serial = 0
end
function OvaleAura:ResetState(state)
    self:StartProfiling("OvaleAura_ResetState")
    state.serial = state.serial + 1
    if _next(state.aura) then
        state:Log("Resetting aura state:")
    end
    for guid, auraTable in _pairs(state.aura) do
        for auraId, whoseTable in _pairs(auraTable) do
            for casterGUID, aura in _pairs(whoseTable) do
                self_pool:Release(aura)
                whoseTable[casterGUID] = nil
                state:Log("    Aura %d on %s removed.", auraId, guid)
            end
            if  not _next(whoseTable) then
                self_pool:Release(whoseTable)
                auraTable[auraId] = nil
            end
        end
        if  not _next(auraTable) then
            self_pool:Release(auraTable)
            state.aura[guid] = nil
        end
    end
    self:StopProfiling("OvaleAura_ResetState")
end
function OvaleAura:CleanState(state)
    for guid in _pairs(state.aura) do
        RemoveAurasOnGUID(state.aura, guid)
    end
end
function OvaleAura:ApplySpellStartCast(state, spellId, targetGUID, startCast, endCast, isChanneled, spellcast)
    self:StartProfiling("OvaleAura_ApplySpellStartCast")
    if isChanneled then
        local si = OvaleData.spellInfo[spellId]
        if si and si.aura then
            if si.aura.player then
                state:ApplySpellAuras(spellId, self_playerGUID, startCast, si.aura.player, spellcast)
            end
            if si.aura.target then
                state:ApplySpellAuras(spellId, targetGUID, startCast, si.aura.target, spellcast)
            end
            if si.aura.pet then
                local petGUID = OvaleGUID:UnitGUID("pet")
                if petGUID then
                    state:ApplySpellAuras(spellId, petGUID, startCast, si.aura.pet, spellcast)
                end
            end
        end
    end
    self:StopProfiling("OvaleAura_ApplySpellStartCast")
end
function OvaleAura:ApplySpellAfterCast(state, spellId, targetGUID, startCast, endCast, isChanneled, spellcast)
    self:StartProfiling("OvaleAura_ApplySpellAfterCast")
    if  not isChanneled then
        local si = OvaleData.spellInfo[spellId]
        if si and si.aura then
            if si.aura.player then
                state:ApplySpellAuras(spellId, self_playerGUID, endCast, si.aura.player, spellcast)
            end
            if si.aura.pet then
                local petGUID = OvaleGUID:UnitGUID("pet")
                if petGUID then
                    state:ApplySpellAuras(spellId, petGUID, startCast, si.aura.pet, spellcast)
                end
            end
        end
    end
    self:StopProfiling("OvaleAura_ApplySpellAfterCast")
end
function OvaleAura:ApplySpellOnHit(state, spellId, targetGUID, startCast, endCast, isChanneled, spellcast)
    self:StartProfiling("OvaleAura_ApplySpellAfterHit")
    if  not isChanneled then
        local si = OvaleData.spellInfo[spellId]
        if si and si.aura and si.aura.target then
            local travelTime = si.travel_time or 0
            if travelTime > 0 then
                local estimatedTravelTime = 1
                if travelTime < estimatedTravelTime then
                    travelTime = estimatedTravelTime
                end
            end
            local atTime = endCast + travelTime
            state:ApplySpellAuras(spellId, targetGUID, atTime, si.aura.target, spellcast)
        end
    end
    self:StopProfiling("OvaleAura_ApplySpellAfterHit")
end
local GetStateAura = function(state, guid, auraId, casterGUID)
    local aura = GetAura(state.aura, guid, auraId, casterGUID)
    if  not aura or aura.serial < state.serial then
        aura = GetAura(OvaleAura.aura, guid, auraId, casterGUID)
    end
    return aura
end
local GetStateAuraAnyCaster = function(state, guid, auraId)
    local auraFound
    if OvaleAura.aura[guid] and OvaleAura.aura[guid][auraId] then
        for casterGUID in _pairs(OvaleAura.aura[guid][auraId]) do
            local aura = GetStateAura(state, guid, auraId, casterGUID)
            if aura and  not aura.state and OvaleAura:IsActiveAura(aura, state.currentTime) then
                if  not auraFound or auraFound.ending < aura.ending then
                    auraFound = aura
                end
            end
        end
    end
    if state.aura[guid] and state.aura[guid][auraId] then
        for casterGUID, aura in _pairs(state.aura[guid][auraId]) do
            if aura.stacks > 0 then
                if  not auraFound or auraFound.ending < aura.ending then
                    auraFound = aura
                end
            end
        end
    end
    return auraFound
end
local GetStateDebuffType = function(state, guid, debuffType, filter, casterGUID)
    local auraFound
    if OvaleAura.aura[guid] then
        for auraId in _pairs(OvaleAura.aura[guid]) do
            local aura = GetStateAura(state, guid, auraId, casterGUID)
            if aura and  not aura.state and OvaleAura:IsActiveAura(aura, state.currentTime) then
                if aura.debuffType == debuffType and aura.filter == filter then
                    if  not auraFound or auraFound.ending < aura.ending then
                        auraFound = aura
                    end
                end
            end
        end
    end
    if state.aura[guid] then
        for auraId, whoseTable in _pairs(state.aura[guid]) do
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
end
local GetStateDebuffTypeAnyCaster = function(state, guid, debuffType, filter)
    local auraFound
    if OvaleAura.aura[guid] then
        for auraId, whoseTable in _pairs(OvaleAura.aura[guid]) do
            for casterGUID in _pairs(whoseTable) do
                local aura = GetStateAura(state, guid, auraId, casterGUID)
                if aura and  not aura.state and OvaleAura:IsActiveAura(aura, state.currentTime) then
                    if aura.debuffType == debuffType and aura.filter == filter then
                        if  not auraFound or auraFound.ending < aura.ending then
                            auraFound = aura
                        end
                    end
                end
            end
        end
    end
    if state.aura[guid] then
        for auraId, whoseTable in _pairs(state.aura[guid]) do
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
end
local GetStateAuraOnGUID = function(state, guid, auraId, filter, mine)
    local auraFound
    if DEBUFF_TYPE[auraId] then
        if mine then
            auraFound = GetStateDebuffType(state, guid, auraId, filter, self_playerGUID)
            if  not auraFound then
                for petGUID in _pairs(self_petGUID) do
                    local aura = GetStateDebuffType(state, guid, auraId, filter, petGUID)
                    if aura and ( not auraFound or auraFound.ending < aura.ending) then
                        auraFound = aura
                    end
                end
            end
        else
            auraFound = GetStateDebuffTypeAnyCaster(state, guid, auraId, filter)
        end
    else
        if mine then
            local aura = GetStateAura(state, guid, auraId, self_playerGUID)
            if aura and aura.stacks > 0 then
                auraFound = aura
            else
                for petGUID in _pairs(self_petGUID) do
                    aura = GetStateAura(state, guid, auraId, petGUID)
                    if aura and aura.stacks > 0 then
                        auraFound = aura
                        break
                    end
                end
            end
        else
            auraFound = GetStateAuraAnyCaster(state, guid, auraId)
        end
    end
    return auraFound
end
do
    local array = {}
    statePrototype.DebugUnitAuras = function(state, unitId, filter)
        _wipe(array)
        local guid = OvaleGUID:UnitGUID(unitId)
        if OvaleAura.aura[guid] then
            for auraId, whoseTable in _pairs(OvaleAura.aura[guid]) do
                for casterGUID in _pairs(whoseTable) do
                    local aura = GetStateAura(state, guid, auraId, casterGUID)
                    if state:IsActiveAura(aura) and aura.filter == filter and  not aura.state then
                        local name = aura.name or "Unknown spell"
                        tinsert(array, name + ": " + auraId)
                    end
                end
            end
        end
        if state.aura[guid] then
            for auraId, whoseTable in _pairs(state.aura[guid]) do
                for casterGUID, aura in _pairs(whoseTable) do
                    if state:IsActiveAura(aura) and aura.filter == filter then
                        local name = aura.name or "Unknown spell"
                        tinsert(array, name + ": " + auraId)
                    end
                end
            end
        end
        if _next(array) then
            tsort(array)
            return tconcat(array, "\n")
        end
    end
end
statePrototype.IsActiveAura = function(state, aura, atTime)
    atTime = atTime or state.currentTime
    local boolean = false
    if aura then
        if aura.state then
            if aura.serial == state.serial and aura.stacks > 0 and aura.gain <= atTime and atTime <= aura.ending then
                boolean = true
            elseif aura.consumed and IsWithinAuraLag(aura.ending, atTime) then
                boolean = true
            end
        else
            boolean = OvaleAura:IsActiveAura(aura, atTime)
        end
    end
    return boolean
end
statePrototype.CanApplySpellAura = function(spellData)
    if spellData["if_target_debuff"] then
    elseif spellData["if_buff"] then
    end
end
statePrototype.ApplySpellAuras = function(state, spellId, guid, atTime, auraList, spellcast)
    OvaleAura:StartProfiling("OvaleAura_state_ApplySpellAuras")
    for filter, filterInfo in _pairs(auraList) do
        for auraId, spellData in _pairs(filterInfo) do
            local duration = OvaleData:GetBaseDuration(auraId, spellcast)
            local stacks = 1
            local count = nil
            local extend = 0
            local toggle = nil
            local refresh = false
            local keepSnapshot = false
            local verified, value, data = state:CheckSpellAuraData(auraId, spellData, atTime, guid)
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
                state:Log("Unknown stack %s", stacks)
            end
            if verified then
                local si = OvaleData.spellInfo[auraId]
                local auraFound = state:GetAuraByGUID(guid, auraId, filter, true)
                if state:IsActiveAura(auraFound, atTime) then
                    local aura
                    if auraFound.state then
                        aura = auraFound
                    else
                        aura = state:AddAuraToGUID(guid, auraId, auraFound.source, filter, nil, 0, INFINITY)
                        for k, v in _pairs(auraFound) do
                            aura[k] = v
                        end
                        aura.serial = state.serial
                        state:Log("Aura %d is copied into simulator.", auraId)
                    end
                    if toggle then
                        state:Log("Aura %d is toggled off by spell %d.", auraId, spellId)
                        stacks = 0
                    end
                    if count and count > 0 then
                        stacks = count - aura.stacks
                    end
                    if refresh or extend > 0 or stacks > 0 then
                        if refresh then
                            state:Log("Aura %d is refreshed to %d stack(s).", auraId, aura.stacks)
                        elseif extend > 0 then
                            state:Log("Aura %d is extended by %f seconds, preserving %d stack(s).", auraId, extend, aura.stacks)
                        else
                            local maxStacks = 1
                            if si and (si.max_stacks or si.maxstacks) then
                                maxStacks = si.max_stacks or si.maxstacks
                            end
                            aura.stacks = aura.stacks + stacks
                            if aura.stacks > maxStacks then
                                aura.stacks = maxStacks
                            end
                            state:Log("Aura %d gains %d stack(s) to %d because of spell %d.", auraId, stacks, aura.stacks, spellId)
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
                        state:Log("Aura %d with duration %s now ending at %s", auraId, aura.duration, aura.ending)
                        if keepSnapshot then
                            state:Log("Aura %d keeping previous snapshot.", auraId)
                        elseif spellcast then
                            OvaleFuture:CopySpellcastInfo(spellcast, aura)
                        end
                    elseif stacks == 0 or stacks < 0 then
                        if stacks == 0 then
                            aura.stacks = 0
                        else
                            aura.stacks = aura.stacks + stacks
                            if aura.stacks < 0 then
                                aura.stacks = 0
                            end
                            state:Log("Aura %d loses %d stack(s) to %d because of spell %d.", auraId, -1 * stacks, aura.stacks, spellId)
                        end
                        if aura.stacks == 0 then
                            state:Log("Aura %d is completely removed.", auraId)
                            aura.ending = atTime
                            aura.consumed = true
                        end
                    end
                else
                    if toggle then
                        state:Log("Aura %d is toggled on by spell %d.", auraId, spellId)
                        stacks = 1
                    end
                    if  not refresh and stacks > 0 then
                        state:Log("New aura %d at %f on %s", auraId, atTime, guid)
                        local debuffType
                        if si then
                            for k, v in _pairs(SPELLINFO_DEBUFF_TYPE) do
                                if si[k] == 1 then
                                    debuffType = v
                                    break
                                end
                            end
                        end
                        local aura = state:AddAuraToGUID(guid, auraId, self_playerGUID, filter, debuffType, 0, INFINITY)
                        aura.stacks = stacks
                        aura.start = atTime
                        aura.duration = duration
                        if si and si.tick then
                            aura.baseTick = si.tick
                            aura.tick = OvaleData:GetTickLength(auraId, spellcast)
                        end
                        aura.ending = aura.start + aura.duration
                        aura.gain = aura.start
                        if spellcast then
                            OvaleFuture:CopySpellcastInfo(spellcast, aura)
                        end
                    end
                end
            else
                state:Log("Aura %d (%s) is not applied.", auraId, spellData)
            end
        end
    end
    OvaleAura:StopProfiling("OvaleAura_state_ApplySpellAuras")
end
statePrototype.GetAuraByGUID = function(state, guid, auraId, filter, mine)
    local auraFound
    if OvaleData.buffSpellList[auraId] then
        for id in _pairs(OvaleData.buffSpellList[auraId]) do
            local aura = GetStateAuraOnGUID(state, guid, id, filter, mine)
            if aura and ( not auraFound or auraFound.ending < aura.ending) then
                state:Log("Aura %s matching '%s' found on %s with (%s, %s)", id, auraId, guid, aura.start, aura.ending)
                auraFound = aura
            else
            end
        end
        if  not auraFound then
            state:Log("Aura matching '%s' is missing on %s.", auraId, guid)
        end
    else
        auraFound = GetStateAuraOnGUID(state, guid, auraId, filter, mine)
        if auraFound then
            state:Log("Aura %s found on %s with (%s, %s)", auraId, guid, auraFound.start, auraFound.ending)
        else
            state:Log("Aura %s is missing on %s.", auraId, guid)
        end
    end
    return auraFound
end
statePrototype.GetAura = function(state, unitId, auraId, filter, mine)
    local guid = OvaleGUID:UnitGUID(unitId)
    local stateAura = state:GetAuraByGUID(guid, auraId, filter, mine)
    local aura = OvaleAura:GetAuraByGUID(guid, auraId, filter, mine)
    local bypassState = OvaleAura.bypassState
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
    return state:GetAuraByGUID(guid, auraId, filter, mine)
end
statePrototype.AddAuraToGUID = function(state, guid, auraId, casterGUID, filter, debuffType, start, ending, snapshot)
    local aura = self_pool:Get()
    aura.state = true
    aura.serial = state.serial
    aura.lastUpdated = state.currentTime
    aura.filter = filter
    aura.start = start or 0
    aura.ending = ending or INFINITY
    aura.duration = aura.ending - aura.start
    aura.gain = aura.start
    aura.stacks = 1
    aura.debuffType = debuffType
    aura.enrage = (debuffType == "Enrage") or nil
    state:UpdateSnapshot(aura, snapshot)
    PutAura(state.aura, guid, auraId, casterGUID, aura)
    return aura
end
statePrototype.RemoveAuraOnGUID = function(state, guid, auraId, filter, mine, atTime)
    local auraFound = state:GetAuraByGUID(guid, auraId, filter, mine)
    if state:IsActiveAura(auraFound, atTime) then
        local aura
        if auraFound.state then
            aura = auraFound
        else
            aura = state:AddAuraToGUID(guid, auraId, auraFound.source, filter, nil, 0, INFINITY)
            for k, v in _pairs(auraFound) do
                aura[k] = v
            end
            aura.serial = state.serial
        end
        aura.stacks = 0
        aura.ending = atTime
        aura.lastUpdated = atTime
    end
end
statePrototype.GetAuraWithProperty = function(state, unitId, propertyName, filter, atTime)
    atTime = atTime or state.currentTime
    local count = 0
    local guid = OvaleGUID:UnitGUID(unitId)
    local start, ending = INFINITY, 0
    if OvaleAura.aura[guid] then
        for auraId, whoseTable in _pairs(OvaleAura.aura[guid]) do
            for casterGUID in _pairs(whoseTable) do
                local aura = GetStateAura(state, guid, auraId, self_playerGUID)
                if state:IsActiveAura(aura, atTime) and  not aura.state then
                    if aura[propertyName] and aura.filter == filter then
                        count = count + 1
                        start = (aura.gain < start) and aura.gain or start
                        ending = (aura.ending > ending) and aura.ending or ending
                    end
                end
            end
        end
    end
    if state.aura[guid] then
        for auraId, whoseTable in _pairs(state.aura[guid]) do
            for casterGUID, aura in _pairs(whoseTable) do
                if state:IsActiveAura(aura, atTime) then
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
        state:Log("Aura with '%s' property found on %s (count=%s, minStart=%s, maxEnding=%s).", propertyName, unitId, count, start, ending)
    else
        state:Log("Aura with '%s' property is missing on %s.", propertyName, unitId)
        start, ending = nil
    end
    return start, ending
end
do
    local count
    local stacks
    local startChangeCount, endingChangeCount
    local startFirst, endingLast
    local CountMatchingActiveAura = function(state, aura)
        state:Log("Counting aura %s found on %s with (%s, %s)", aura.spellId, aura.guid, aura.start, aura.ending)
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
    end
    statePrototype.AuraCount = function(state, auraId, filter, mine, minStacks, atTime, excludeUnitId)
        OvaleAura:StartProfiling("OvaleAura_state_AuraCount")
        minStacks = minStacks or 1
        count = 0
        stacks = 0
        startChangeCount, endingChangeCount = INFINITY, INFINITY
        startFirst, endingLast = INFINITY, 0
        local excludeGUID = excludeUnitId and OvaleGUID:UnitGUID(excludeUnitId) or nil
        for guid, auraTable in _pairs(OvaleAura.aura) do
            if guid ~= excludeGUID and auraTable[auraId] then
                if mine then
                    local aura = GetStateAura(state, guid, auraId, self_playerGUID)
                    if state:IsActiveAura(aura, atTime) and aura.filter == filter and aura.stacks >= minStacks and  not aura.state then
                        CountMatchingActiveAura(state, aura)
                    end
                    for petGUID in _pairs(self_petGUID) do
                        aura = GetStateAura(state, guid, auraId, petGUID)
                        if state:IsActiveAura(aura, atTime) and aura.filter == filter and aura.stacks >= minStacks and  not aura.state then
                            CountMatchingActiveAura(state, aura)
                        end
                    end
                else
                    for casterGUID in _pairs(auraTable[auraId]) do
                        local aura = GetStateAura(state, guid, auraId, casterGUID)
                        if state:IsActiveAura(aura, atTime) and aura.filter == filter and aura.stacks >= minStacks and  not aura.state then
                            CountMatchingActiveAura(state, aura)
                        end
                    end
                end
            end
        end
        for guid, auraTable in _pairs(state.aura) do
            if guid ~= excludeGUID and auraTable[auraId] then
                if mine then
                    local aura = auraTable[auraId][self_playerGUID]
                    if aura then
                        if state:IsActiveAura(aura, atTime) and aura.filter == filter and aura.stacks >= minStacks then
                            CountMatchingActiveAura(state, aura)
                        end
                    end
                    for petGUID in _pairs(self_petGUID) do
                        aura = auraTable[auraId][petGUID]
                        if state:IsActiveAura(aura, atTime) and aura.filter == filter and aura.stacks >= minStacks and  not aura.state then
                            CountMatchingActiveAura(state, aura)
                        end
                    end
                else
                    for casterGUID, aura in _pairs(auraTable[auraId]) do
                        if state:IsActiveAura(aura, atTime) and aura.filter == filter and aura.stacks >= minStacks then
                            CountMatchingActiveAura(state, aura)
                        end
                    end
                end
            end
        end
        state:Log("AuraCount(%d) is %s, %s, %s, %s, %s, %s", auraId, count, stacks, startChangeCount, endingChangeCount, startFirst, endingLast)
        OvaleAura:StopProfiling("OvaleAura_state_AuraCount")
        return count, stacks, startChangeCount, endingChangeCount, startFirst, endingLast
    end
end
statePrototype.RequireBuffHandler = OvaleAura.RequireBuffHandler
statePrototype.RequireStealthHandler = OvaleAura.RequireStealthHandler
end))
