local __addonName, __addon = ...
__addon.require(__addonName, __addon, "./State", { "./Localization", "./Debug", "./Queue", "./Ovale" }, function(__exports, __Localization, __Debug, __Queue, __Ovale)
local OvaleStateBase = __Ovale.Ovale:NewModule("OvaleState")
local _pairs = pairs
local self_statePrototype = {}
local self_stateAddons = __Queue.OvaleQueue("OvaleState_stateAddons")
local OvaleStateClass = __class(__Debug.OvaleDebug:RegisterDebugging(OvaleStateBase), {
    OnEnable = function(self)
    end,
    OnDisable = function(self)
    end,
    RegisterState = function(self, stateAddon)
        self_stateAddons:Insert(stateAddon)
    end,
    UnregisterState = function(self, stateAddon)
        local stateModules = __Queue.OvaleQueue("OvaleState_stateModules")
        while self_stateAddons:Size() > 0 do
            local addon = self_stateAddons:Remove()
            if stateAddon ~= addon then
                stateModules:Insert(addon)
            end
        end
        self_stateAddons = stateModules
        stateAddon:CleanState()
    end,
    InitializeState = function(self)
        local iterator = self_stateAddons:Iterator()
        while iterator:Next() do
            iterator.value:InitializeState()
        end
    end,
    ResetState = function(self)
        local iterator = self_stateAddons:Iterator()
        while iterator:Next() do
            iterator.value:ResetState()
        end
    end,
    ApplySpellStartCast = function(self, spellId, targetGUID, startCast, endCast, channel, spellcast)
        local iterator = self_stateAddons:Iterator()
        while iterator:Next() do
            iterator.value:ApplySpellStartCast(spellId, targetGUID, startCast, endCast, channel, spellcast)
        end
    end,
    ApplySpellAfterCast = function(self, spellId, targetGUID, startCast, endCast, channel, spellcast)
        local iterator = self_stateAddons:Iterator()
        while iterator:Next() do
            iterator.value:ApplySpellAfterCast(spellId, targetGUID, startCast, endCast, channel, spellcast)
        end
    end,
    ApplySpellOnHit = function(self, spellId, targetGUID, startCast, endCast, channel, spellcast)
        local iterator = self_stateAddons:Iterator()
        while iterator:Next() do
            iterator.value:ApplySpellOnHit(spellId, targetGUID, startCast, endCast, channel, spellcast)
        end
    end,
})
__exports.OvaleState = OvaleStateClass()
__exports.BaseState = __class(nil, {
    InitializeState = function(self)
        self.futureVariable = {}
        self.futureLastEnable = {}
        self.variable = {}
        self.lastEnable = {}
        self.defaultTarget = "target"
    end,
    ResetState = function(self)
        for k in _pairs(self.futureVariable) do
            self.futureVariable[k] = nil
            self.futureLastEnable[k] = nil
        end
        if  not self.inCombat then
            for k in _pairs(self.variable) do
                self:Log("Resetting state variable '%s'.", k)
                self.variable[k] = nil
                self.lastEnable[k] = nil
            end
        end
    end,
    CleanState = function(self)
        for k in _pairs(self.futureVariable) do
            self.futureVariable[k] = nil
        end
        for k in _pairs(self.futureLastEnable) do
            self.futureLastEnable[k] = nil
        end
        for k in _pairs(self.variable) do
            self.variable[k] = nil
        end
        for k in _pairs(self.lastEnable) do
            self.lastEnable[k] = nil
        end
        self.defaultTarget = nil
    end,
    GetState = function(self, name)
        return self.futureVariable[name] or self.variable[name] or 0
    end,
    GetStateDuration = function(self, name)
        local lastEnable = self.futureLastEnable[name] or self.lastEnable[name] or self.currentTime
        return self.currentTime - lastEnable
    end,
    PutState = function(self, name, value, isFuture)
        if isFuture then
            local oldValue = self:GetState(name)
            if value ~= oldValue then
                self:Log("Setting future state: %s from %s to %s.", name, oldValue, value)
                self.futureVariable[name] = value
                self.futureLastEnable[name] = self.currentTime
            end
        else
            local oldValue = self.variable[name] or 0
            if value ~= oldValue then
                __exports.OvaleState:DebugTimestamp("Advancing combat state: %s from %s to %s.", name, oldValue, value)
                self:Log("Advancing combat state: %s from %s to %s.", name, oldValue, value)
                self.variable[name] = value
                self.lastEnable[name] = self.currentTime
            end
        end
    end,
    Log = function(self, parameters)
        __exports.OvaleState:Log(parameters)
    end,
    constructor = function(self)
        self.isState = true
        self.isInitialized = false
        self.futureVariable = nil
        self.futureLastEnable = nil
        self.variable = nil
        self.lastEnable = nil
    end
})
__exports.baseState = __exports.BaseState()
end)
