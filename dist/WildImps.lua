local __addonName, __addon = ...
            __addon.require("./WildImps", { "./State", "./Ovale", "AceEvent-3.0" }, function(__exports, __State, __Ovale, aceEvent)
local OvaleWildImpsBase = __Ovale.Ovale:NewModule("OvaleWildImps", aceEvent)
local demonData = {
    [55659] = {
        duration = 12
    },
    [98035] = {
        duration = 12
    },
    [103673] = {
        duration = 12
    },
    [11859] = {
        duration = 25
    },
    [89] = {
        duration = 25
    }
}
local self_demons = {}
local self_serial = 1
local API_GetTime = GetTime
local sfind = string.find
local OvaleWildImpsClass = __addon.__class(OvaleWildImpsBase, {
    constructor = function(self)
        OvaleWildImpsBase.constructor(self)
        if __Ovale.Ovale.playerClass == "WARLOCK" then
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            self_demons = {}
        end
    end,
    OnDisable = function(self)
        if __Ovale.Ovale.playerClass == "WARLOCK" then
            self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
    end,
    COMBAT_LOG_EVENT_UNFILTERED = function(self, event, timestamp, cleuEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId)
        self_serial = self_serial + 1
        __Ovale.Ovale:needRefresh()
        if sourceGUID ~= __Ovale.Ovale.playerGUID then
            return 
        end
        if cleuEvent == "SPELL_SUMMON" then
            local _, _, _, _, _, _, _, creatureId = sfind(destGUID, "(%S+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%S+)")
            creatureId = tonumber(creatureId)
            local now = API_GetTime()
            for id, v in pairs(demonData) do
                if id == creatureId then
                    self_demons[destGUID] = {
                        id = creatureId,
                        timestamp = now,
                        finish = now + v.duration
                    }
                    break
                end
            end
            for k, d in pairs(self_demons) do
                if d.finish < now then
                    self_demons[k] = nil
                end
            end
        elseif cleuEvent == "SPELL_INSTAKILL" then
            if spellId == 196278 then
                self_demons[destGUID] = nil
            end
        elseif cleuEvent == "SPELL_CAST_SUCCESS" then
            if spellId == 193396 then
                for _, d in pairs(self_demons) do
                    d.de = true
                end
            end
        end
    end,
})
local WildImpsState = __addon.__class(nil, {
    CleanState = function(self)
    end,
    InitializeState = function(self)
    end,
    ResetState = function(self)
    end,
    GetNotDemonicEmpoweredDemonsCount = function(self, creatureId, atTime)
        local count = 0
        for _, d in pairs(self_demons) do
            if d.finish >= atTime and d.id == creatureId and  not d.de then
                count = count + 1
            end
        end
        return count
    end,
    GetDemonsCount = function(self, creatureId, atTime)
        local count = 0
        for _, d in pairs(self_demons) do
            if d.finish >= atTime and d.id == creatureId then
                count = count + 1
            end
        end
        return count
    end,
    GetRemainingDemonDuration = function(self, creatureId, atTime)
        local max = 0
        for _, d in pairs(self_demons) do
            if d.finish >= atTime and d.id == creatureId then
                local remaining = d.finish - atTime
                if remaining > max then
                    max = remaining
                end
            end
        end
        return max
    end,
})
__exports.wildImpsState = WildImpsState()
__State.OvaleState:RegisterState(__exports.wildImpsState)
__exports.OvaleWildImps = OvaleWildImpsClass()
end)
