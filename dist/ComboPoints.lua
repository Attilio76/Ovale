local __addonName, __addon = ...
            __addon.require("./ComboPoints", { "./Debug", "./Profiler", "./Aura", "./Data", "./Equipment", "./PaperDoll", "./Power", "./SpellBook", "./Ovale", "./State", "./Requirement", "./LastSpell", "./DataState" }, function(__exports, __Debug, __Profiler, __Aura, __Data, __Equipment, __PaperDoll, __Power, __SpellBook, __Ovale, __State, __Requirement, __LastSpell, __DataState)
local OvaleComboPointsBase = __Ovale.Ovale:NewModule("OvaleComboPoints", "AceEvent-3.0")
local tinsert = table.insert
local tremove = table.remove
local API_GetTime = GetTime
local API_UnitPower = UnitPower
local _MAX_COMBO_POINTS = MAX_COMBO_POINTS
local _UNKNOWN = UNKNOWN
local ANTICIPATION = 115189
local ANTICIPATION_DURATION = 15
local ANTICIPATION_TALENT = 18
local self_hasAnticipation = false
local RUTHLESSNESS = 14161
local self_hasRuthlessness = false
local ENVENOM = 32645
local self_hasAssassination4pT17 = false
local self_pendingComboEvents = {}
local PENDING_THRESHOLD = 0.8
local AddPendingComboEvent = function(atTime, spellId, guid, reason, combo)
    local comboEvent = {
        atTime = atTime,
        spellId = spellId,
        guid = guid,
        reason = reason,
        combo = combo
    }
    tinsert(self_pendingComboEvents, comboEvent)
    __Ovale.Ovale:needRefresh()
end

local RemovePendingComboEvents = function(atTime, spellId, guid, reason, combo)
    local count = 0
    for k = #self_pendingComboEvents, 1, -1 do
        local comboEvent = self_pendingComboEvents[k]
        if (atTime and atTime - comboEvent.atTime > PENDING_THRESHOLD) or (comboEvent.spellId == spellId and comboEvent.guid == guid and ( not reason or comboEvent.reason == reason) and ( not combo or comboEvent.combo == combo)) then
            if comboEvent.combo == "finisher" then
                __exports.OvaleComboPoints:Debug("Removing expired %s event: spell %d combo point finisher from %s.", comboEvent.reason, comboEvent.spellId, comboEvent.reason)
            else
                __exports.OvaleComboPoints:Debug("Removing expired %s event: spell %d for %d combo points from %s.", comboEvent.reason, comboEvent.spellId, comboEvent.combo, comboEvent.reason)
            end
            count = count + 1
            tremove(self_pendingComboEvents, k)
            __Ovale.Ovale:needRefresh()
        end
    end
    return count
end

local OvaleComboPointsClass = __addon.__class(__Ovale.RegisterPrinter(__Profiler.OvaleProfiler:RegisterProfiling(__Debug.OvaleDebug:RegisterDebugging(OvaleComboPointsBase))), {
    constructor = function(self)
        self.combo = 0
        self.SaveSpellcastInfo = function(module, spellcast, atTime, state)
            local spellId = spellcast.spellId
            if spellId then
                local si = __Data.OvaleData.spellInfo[spellId]
                if si then
                    local comboPointModule = state or self
                    if si.combo == "finisher" then
                        local combo
                        if state then
                            combo = __DataState.dataState:GetSpellInfoProperty(spellId, atTime, "combo", spellcast.target)
                        else
                            combo = __Data.OvaleData:GetSpellInfoProperty(spellId, atTime, "combo", spellcast.target)
                        end
                        if combo == "finisher" then
                            local min_combo = si.min_combo or si.mincombo or 1
                            if comboPointModule.combo >= min_combo then
                                combo = comboPointModule.combo
                            else
                                combo = min_combo
                            end
                        elseif combo == 0 then
                            combo = _MAX_COMBO_POINTS
                        end
                        spellcast.combo = combo
                    end
                end
            end
        end
        __Ovale.RegisterPrinter(__Profiler.OvaleProfiler:RegisterProfiling(__Debug.OvaleDebug:RegisterDebugging(OvaleComboPointsBase))).constructor(self)
        if __Ovale.Ovale.playerClass == "ROGUE" or __Ovale.Ovale.playerClass == "DRUID" then
            self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
                return self:Update()
            end)
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self:RegisterEvent("UNIT_POWER")
            self:RegisterEvent("Ovale_EquipmentChanged")
            self:RegisterMessage("Ovale_SpellFinished")
            self:RegisterMessage("Ovale_TalentsChanged")
            __Requirement.RegisterRequirement("combo", "RequireComboPointsHandler", self)
            __LastSpell.lastSpell:RegisterSpellcastInfo(self)
        end
    end,
    OnDisable = function(self)
        if __Ovale.Ovale.playerClass == "ROGUE" or __Ovale.Ovale.playerClass == "DRUID" then
            __LastSpell.lastSpell:UnregisterSpellcastInfo(self)
            __Requirement.UnregisterRequirement("combo")
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
            self:UnregisterEvent("PLAYER_TARGET_CHANGED")
            self:UnregisterEvent("UNIT_POWER")
            self:UnregisterEvent("Ovale_EquipmentChanged")
            self:UnregisterMessage("Ovale_SpellFinished")
            self:UnregisterMessage("Ovale_TalentsChanged")
        end
    end,
    PLAYER_TARGET_CHANGED = function(self, event, cause)
        if cause == "NIL" or cause == "down" then
        else
            self:Update()
        end
    end,
    UNIT_POWER = function(self, event, unitId, powerToken)
        if powerToken ~= __Power.OvalePower.POWER_INFO.combopoints.token then
            return 
        end
        if unitId == "player" then
            local oldCombo = self.combo
            self:Update()
            local difference = self.combo - oldCombo
            self:DebugTimestamp("%s: %d -> %d.", event, oldCombo, self.combo)
            local now = API_GetTime()
            RemovePendingComboEvents(now)
            local pendingMatched = false
            if #self_pendingComboEvents > 0 then
                local comboEvent = self_pendingComboEvents[1]
                local spellId, _, reason, combo = comboEvent.spellId, comboEvent.guid, comboEvent.reason, comboEvent.combo
                if combo == difference or (combo == "finisher" and self.combo == 0 and difference < 0) then
                    self:Debug("    Matches pending %s event for %d.", reason, spellId)
                    pendingMatched = true
                    tremove(self_pendingComboEvents, 1)
                end
            end
        end
    end,
    Ovale_EquipmentChanged = function(self, event)
        self_hasAssassination4pT17 = (__Ovale.Ovale.playerClass == "ROGUE" and __PaperDoll.OvalePaperDoll:IsSpecialization("assassination") and __Equipment.OvaleEquipment:GetArmorSetCount("T17") >= 4)
    end,
    Ovale_SpellFinished = function(self, event, atTime, spellId, targetGUID, finish)
        self:Debug("%s (%f): Spell %d finished (%s) on %s", event, atTime, spellId, finish, targetGUID or _UNKNOWN)
        local si = __Data.OvaleData.spellInfo[spellId]
        if si and si.combo == "finisher" and finish == "hit" then
            self:Debug("    Spell %d hit and consumed all combo points.", spellId)
            AddPendingComboEvent(atTime, spellId, targetGUID, "finisher", "finisher")
            if self_hasRuthlessness and self.combo == _MAX_COMBO_POINTS then
                self:Debug("    Spell %d has 100% chance to grant an extra combo point from Ruthlessness.", spellId)
                AddPendingComboEvent(atTime, spellId, targetGUID, "Ruthlessness", 1)
            end
            if self_hasAssassination4pT17 and spellId == ENVENOM then
                self:Debug("    Spell %d refunds 1 combo point from Assassination 4pT17 set bonus.", spellId)
                AddPendingComboEvent(atTime, spellId, targetGUID, "Assassination 4pT17", 1)
            end
            if self_hasAnticipation and targetGUID ~= __Ovale.Ovale.playerGUID then
                if __SpellBook.OvaleSpellBook:IsHarmfulSpell(spellId) then
                    local aura = __Aura.OvaleAura:GetAuraByGUID(__Ovale.Ovale.playerGUID, ANTICIPATION, "HELPFUL", true)
                    if __Aura.OvaleAura:IsActiveAura(aura, atTime) then
                        self:Debug("    Spell %d hit with %d Anticipation charges.", spellId, aura.stacks)
                        AddPendingComboEvent(atTime, spellId, targetGUID, "Anticipation", aura.stacks)
                    end
                end
            end
        end
    end,
    Ovale_TalentsChanged = function(self, event)
        if __Ovale.Ovale.playerClass == "ROGUE" then
            self_hasAnticipation = __SpellBook.OvaleSpellBook:GetTalentPoints(ANTICIPATION_TALENT) > 0
            self_hasRuthlessness = __SpellBook.OvaleSpellBook:IsKnownSpell(RUTHLESSNESS)
        end
    end,
    Update = function(self)
        self:StartProfiling("OvaleComboPoints_Update")
        self.combo = API_UnitPower("player", 4)
        __Ovale.Ovale:needRefresh()
        self:StopProfiling("OvaleComboPoints_Update")
    end,
    GetComboPoints = function(self)
        local now = API_GetTime()
        RemovePendingComboEvents(now)
        local total = self.combo
        for k = 1, #self_pendingComboEvents, 1 do
            local combo = self_pendingComboEvents[k].combo
            if combo == "finisher" then
                total = 0
            else
                total = total + combo
            end
            if total > _MAX_COMBO_POINTS then
                total = _MAX_COMBO_POINTS
            end
        end
        return total
    end,
    DebugComboPoints = function(self)
        self:Print("Player has %d combo points.", self.combo)
    end,
    ComboPointCost = function(self, spellId, atTime, targetGUID)
        self:StartProfiling("OvaleComboPoints_ComboPointCost")
        local spellCost = 0
        local spellRefund = 0
        local si = __Data.OvaleData.spellInfo[spellId]
        if si and si.combo then
            local GetAura, IsActiveAura
            local GetSpellInfoProperty
            local auraModule, dataModule
            GetAura, auraModule = self:GetMethod("GetAura", __Aura.OvaleAura)
            IsActiveAura, auraModule = self:GetMethod("IsActiveAura", __Aura.OvaleAura)
            GetSpellInfoProperty, dataModule = self:GetMethod("GetSpellInfoProperty", __Data.OvaleData)
            local cost = GetSpellInfoProperty(dataModule, spellId, atTime, "combo", targetGUID)
            if cost == "finisher" then
                cost = self:GetComboPoints()
                local minCost = si.min_combo or si.mincombo or 1
                local maxCost = si.max_combo
                if cost < minCost then
                    cost = minCost
                end
                if maxCost and cost > maxCost then
                    cost = maxCost
                end
            else
                local buffExtra = si.buff_combo
                if buffExtra then
                    local aura = GetAura(auraModule, "player", buffExtra, nil, true)
                    local isActiveAura = IsActiveAura(auraModule, aura, atTime)
                    if isActiveAura then
                        local buffAmount = si.buff_combo_amount or 1
                        cost = cost + buffAmount
                    end
                end
                cost = -1 * cost
            end
            spellCost = cost
            local refundParam = "refund_combo"
            local refund = GetSpellInfoProperty(dataModule, spellId, atTime, refundParam, targetGUID)
            if refund == "cost" then
                refund = spellCost
            end
            spellRefund = refund or 0
        end
        self:StopProfiling("OvaleComboPoints_ComboPointCost")
        return spellCost, spellRefund
    end,
    RequireComboPointsHandler = function(self, spellId, atTime, requirement, tokens, index, targetGUID)
        local verified = false
        local cost = tokens
        if index then
            cost = tokens[index]
            index = index + 1
        end
        if cost then
            cost = self:ComboPointCost(spellId, atTime, targetGUID)
            if cost > 0 then
                local power = self:GetComboPoints()
                if power >= cost then
                    verified = true
                end
            else
                verified = true
            end
            if cost > 0 then
                local result = verified and "passed" or "FAILED"
                self:Log("    Require %d combo point(s) at time=%f: %s", cost, atTime, result)
            end
        else
            __Ovale.Ovale:OneTimeMessage("Warning: requirement '%s' is missing a cost argument.", requirement)
        end
        return verified, requirement, index
    end,
    CopySpellcastInfo = function(self, spellcast, dest)
        if spellcast.combo then
            dest.combo = spellcast.combo
        end
    end,
})
__exports.OvaleComboPoints = OvaleComboPointsClass()
__exports.ComboPointsState = __addon.__class(nil, {
    ApplySpellAfterCast = function(self, spellId, targetGUID, startCast, endCast, isChanneled, spellcast)
        __exports.OvaleComboPoints:StartProfiling("OvaleComboPoints_ApplySpellAfterCast")
        local si = __Data.OvaleData.spellInfo[spellId]
        if si and si.combo then
            local cost, refund = self:ComboPointCost(spellId, endCast, targetGUID)
            local power = self.combo
            power = power - cost + refund
            if power <= 0 then
                power = 0
                if self_hasRuthlessness and self.combo == _MAX_COMBO_POINTS then
                    __exports.OvaleComboPoints:Log("Spell %d grants one extra combo point from Ruthlessness.", spellId)
                    power = power + 1
                end
                if self_hasAnticipation and self.combo > 0 then
                    local aura = __Aura.auraState:GetAuraByGUID(__Ovale.Ovale.playerGUID, ANTICIPATION, "HELPFUL", true)
                    if __Aura.auraState:IsActiveAura(aura, endCast) then
                        power = power + aura.stacks
                        __Aura.auraState:RemoveAuraOnGUID(__Ovale.Ovale.playerGUID, ANTICIPATION, "HELPFUL", true, endCast)
                        if power > _MAX_COMBO_POINTS then
                            power = _MAX_COMBO_POINTS
                        end
                    end
                end
            end
            if power > _MAX_COMBO_POINTS then
                if self_hasAnticipation and  not si.temp_combo then
                    local stacks = power - _MAX_COMBO_POINTS
                    local aura = __Aura.auraState:GetAuraByGUID(__Ovale.Ovale.playerGUID, ANTICIPATION, "HELPFUL", true)
                    if __Aura.auraState:IsActiveAura(aura, endCast) then
                        stacks = stacks + aura.stacks
                        if stacks > _MAX_COMBO_POINTS then
                            stacks = _MAX_COMBO_POINTS
                        end
                    end
                    local start = endCast
                    local ending = start + ANTICIPATION_DURATION
                    aura = __Aura.auraState:AddAuraToGUID(__Ovale.Ovale.playerGUID, ANTICIPATION, __Ovale.Ovale.playerGUID, "HELPFUL", nil, start, ending)
                    aura.stacks = stacks
                end
                power = _MAX_COMBO_POINTS
            end
            self.combo = power
        end
        __exports.OvaleComboPoints:StopProfiling("OvaleComboPoints_ApplySpellAfterCast")
    end,
    GetComboPoints = function(self)
        return self.combo
    end,
    ComboPointCost = function(self, spellId, atTime, targetGUID)
        return __exports.OvaleComboPoints:ComboPointCost(spellId, atTime, targetGUID)
    end,
    RequireComboPointsHandler = function(self, spellId, atTime, requirement, tokens, index, targetGUID)
        return __exports.OvaleComboPoints:RequireComboPointsHandler(spellId, atTime, requirement, tokens, index, targetGUID)
    end,
    InitializeState = function(self)
        self.combo = 0
    end,
    ResetState = function(self)
        self.combo = self:GetComboPoints()
        for k = 1, #self_pendingComboEvents, 1 do
            local comboEvent = self_pendingComboEvents[k]
            if comboEvent.reason == "Anticipation" then
                __Aura.auraState:RemoveAuraOnGUID(__Ovale.Ovale.playerGUID, ANTICIPATION, "HELPFUL", true, comboEvent.atTime)
                break
            end
        end
    end,
    CleanState = function(self)
    end,
    constructor = function(self)
        self.combo = nil
    end
})
__exports.comboPointsState = __exports.ComboPointsState()
__State.OvaleState:RegisterState(__exports.comboPointsState)
end)
