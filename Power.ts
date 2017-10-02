import { L } from "./Localization";
import { OvaleDebug } from "./Debug";
import { OvaleProfiler } from "./Profiler";
import { Ovale } from "./Ovale";
import { OvaleAura } from "./Aura";
import { OvaleFuture } from "./Future";
import { OvaleData } from "./Data";
import { OvaleState } from "./State";

let OvalePowerBase = Ovale.NewModule("OvalePower", "AceEvent-3.0");
export let OvalePower:OvalePowerClass;

let ceil = math.ceil;
let format = string.format;
let gsub = string.gsub;
let _pairs = pairs;
let strmatch = string.match;
let tconcat = table.concat;
let _tonumber = tonumber;
let _tostring = tostring;
let _wipe = wipe;
let API_CreateFrame = CreateFrame;
let API_GetPowerRegen = GetPowerRegen;
let API_GetSpellPowerCost = GetSpellPowerCost;
let API_GetTime = GetTime;
let API_UnitPower = UnitPower;
let API_UnitPowerMax = UnitPowerMax;
let API_UnitPowerType = UnitPowerType;
let INFINITY = math.huge;
OvaleDebug.RegisterDebugging(OvalePower);
OvaleProfiler.RegisterProfiling(OvalePower);
let self_playerGUID = undefined;
let self_updateSpellcastInfo = {
}
let self_SpellcastInfoPowerTypes = {
    1: "chi",
    2: "holy"
}
let self_button = undefined;
{
    let debugOptions = {
        power: {
            name: L["Power"],
            type: "group",
            args: {
                power: {
                    name: L["Power"],
                    type: "input",
                    multiline: 25,
                    width: "full",
                    get: function (info) {
                        return OvaleState.state.DebugPower();
                    }
                }
            }
        }
    }
    for (const [k, v] of _pairs(debugOptions)) {
        OvaleDebug.options.args[k] = v;
    }
}

class OvalePowerClass extends OvaleDebug.RegisterDebugging(OvaleProfiler.RegisterProfiling(OvalePowerBase)) {
    powerType = undefined;
    powerRate:number = undefined;
    power = {}
    maxPower = {}
    activeRegen = 0;
    inactiveRegen = 0;
    POWER_INFO = {
        alternate: {
            id: SPELL_POWER_ALTERNATE_POWER,
            token: "ALTERNATE_RESOURCE_TEXT",
            mini: 0
        },
        chi: {
            id: SPELL_POWER_CHI,
            token: "CHI",
            mini: 0,
            costString: CHI_COST
        },
        combopoints: {
            id: SPELL_POWER_COMBO_POINTS,
            token: "COMBO_POINTS",
            mini: 0,
            costString: COMBO_POINTS_COST
        },
        energy: {
            id: SPELL_POWER_ENERGY,
            token: "ENERGY",
            mini: 0,
            costString: ENERGY_COST
        },
        focus: {
            id: SPELL_POWER_FOCUS,
            token: "FOCUS",
            mini: 0,
            costString: FOCUS_COST
        },
        holy: {
            id: SPELL_POWER_HOLY_POWER,
            token: "HOLY_POWER",
            mini: 0,
            costString: HOLY_POWER_COST
        },
        mana: {
            id: SPELL_POWER_MANA,
            token: "MANA",
            mini: 0,
            costString: MANA_COST
        },
        rage: {
            id: SPELL_POWER_RAGE,
            token: "RAGE",
            mini: 0,
            costString: RAGE_COST
        },
        runicpower: {
            id: SPELL_POWER_RUNIC_POWER,
            token: "RUNIC_POWER",
            mini: 0,
            costString: RUNIC_POWER_COST
        },
        soulshards: {
            id: SPELL_POWER_SOUL_SHARDS,
            token: "SOUL_SHARDS",
            mini: 0,
            costString: SOUL_SHARDS_COST
        },
        astralpower: {
            id: SPELL_POWER_LUNAR_POWER,
            token: "LUNAR_POWER",
            mini: 0,
            costString: LUNAR_POWER_COST
        },
        insanity: {
            id: SPELL_POWER_INSANITY,
            token: "INSANITY",
            mini: 0,
            costString: INSANITY_COST
        },
        maelstrom: {
            id: SPELL_POWER_MAELSTROM,
            token: "MAELSTROM",
            mini: 0,
            costString: MAELSTROM_COST
        },
        arcanecharges: {
            id: SPELL_POWER_ARCANE_CHARGES,
            token: "ARCANE_CHARGES",
            mini: 0,
            costString: ARCANE_CHARGES_COST
        },
        pain: {
            id: SPELL_POWER_PAIN,
            token: "PAIN",
            mini: 0,
            costString: PAIN_COST
        },
        fury: {
            id: SPELL_POWER_FURY,
            token: "FURY",
            mini: 0,
            costString: FURY_COST
        }
    }

    PRIMARY_POWER = {
        energy: true,
        focus: true,
        mana: true
    }
    POWER_TYPE = {}

    constructor() {
        super();
        for (const [powerType, v] of _pairs(OvalePower.POWER_INFO)) {
            if (!v.id) {
                this.Print("Unknown resource %s", v.token);
            }
            OvalePower.POWER_TYPE[v.id] = powerType;
            OvalePower.POWER_TYPE[v.token] = powerType;
        }
    }
    POOLED_RESOURCE = {
        ["DRUID"]: "energy",
        ["HUNTER"]: "focus",
        ["MONK"]: "energy",
        ["ROGUE"]: "energy"
    }
    OnInitialize() {
    }
    OnEnable() {
        self_playerGUID = Ovale.playerGUID;
        this.RegisterEvent("PLAYER_ENTERING_WORLD", "EventHandler");
        this.RegisterEvent("PLAYER_LEVEL_UP", "EventHandler");
        this.RegisterEvent("UNIT_DISPLAYPOWER");
        this.RegisterEvent("UNIT_LEVEL");
        this.RegisterEvent("UNIT_MAXPOWER");
        this.RegisterEvent("UNIT_POWER");
        this.RegisterEvent("UNIT_POWER_FREQUENT", "UNIT_POWER");
        this.RegisterEvent("UNIT_RANGEDDAMAGE");
        this.RegisterEvent("UNIT_SPELL_HASTE", "UNIT_RANGEDDAMAGE");
        this.RegisterMessage("Ovale_StanceChanged", "EventHandler");
        this.RegisterMessage("Ovale_TalentsChanged", "EventHandler");
        for (const [powerType] of _pairs(this.POWER_INFO)) {
            OvaleData.RegisterRequirement(powerType, "RequirePowerHandler", this);
        }
        OvaleFuture.RegisterSpellcastInfo(this);
        OvaleState.RegisterState(this, this.statePrototype);
    }
    OnDisable() {
        OvaleState.UnregisterState(this);
        OvaleFuture.UnregisterSpellcastInfo(this);
        for (const [powerType] of _pairs(this.POWER_INFO)) {
            OvaleData.UnregisterRequirement(powerType);
        }
        this.UnregisterEvent("PLAYER_ENTERING_WORLD");
        this.UnregisterEvent("PLAYER_LEVEL_UP");
        this.UnregisterEvent("UNIT_DISPLAYPOWER");
        this.UnregisterEvent("UNIT_LEVEL");
        this.UnregisterEvent("UNIT_MAXPOWER");
        this.UnregisterEvent("UNIT_POWER");
        this.UnregisterEvent("UNIT_POWER_FREQUENT");
        this.UnregisterEvent("UNIT_RANGEDDAMAGE");
        this.UnregisterEvent("UNIT_SPELL_HASTE");
        this.UnregisterMessage("Ovale_StanceChanged");
        this.UnregisterMessage("Ovale_TalentsChanged");
    }
    EventHandler(event) {
        this.UpdatePowerType(event);
        this.UpdateMaxPower(event);
        this.UpdatePower(event);
        this.UpdatePowerRegen(event);
    }
    UNIT_DISPLAYPOWER(event, unitId) {
        if (unitId == "player") {
            this.UpdatePowerType(event);
            this.UpdatePowerRegen(event);
        }
    }
    UNIT_LEVEL(event, unitId) {
        if (unitId == "player") {
            this.EventHandler(event);
        }
    }
    UNIT_MAXPOWER(event, unitId, powerToken) {
        if (unitId == "player") {
            let powerType = this.POWER_TYPE[powerToken];
            if (powerType) {
                this.UpdateMaxPower(event, powerType);
            }
        }
    }
    UNIT_POWER(event, unitId, powerToken) {
        if (unitId == "player") {
            let powerType = this.POWER_TYPE[powerToken];
            if (powerType) {
                this.UpdatePower(event, powerType);
            }
        }
    }
    UNIT_RANGEDDAMAGE(event, unitId) {
        if (unitId == "player") {
            this.UpdatePowerRegen(event);
        }
    }
    UpdateMaxPower(event, powerType) {
        this.StartProfiling("OvalePower_UpdateMaxPower");
        if (powerType) {
            let powerInfo = this.POWER_INFO[powerType];
            let maxPower = API_UnitPowerMax("player", powerInfo.id, powerInfo.segments);
            if (this.maxPower[powerType] != maxPower) {
                this.maxPower[powerType] = maxPower;
                Ovale.refreshNeeded[self_playerGUID] = true;
            }
        } else {
            for (const [powerType, powerInfo] of _pairs(this.POWER_INFO)) {
                let maxPower = API_UnitPowerMax("player", powerInfo.id, powerInfo.segments);
                if (this.maxPower[powerType] != maxPower) {
                    this.maxPower[powerType] = maxPower;
                    Ovale.refreshNeeded[self_playerGUID] = true;
                }
            }
        }
        this.StopProfiling("OvalePower_UpdateMaxPower");
    }
    UpdatePower(event, powerType) {
        this.StartProfiling("OvalePower_UpdatePower");
        if (powerType) {
            let powerInfo = this.POWER_INFO[powerType];
            let power = API_UnitPower("player", powerInfo.id, powerInfo.segments);
            if (this.power[powerType] != power) {
                this.power[powerType] = power;
                Ovale.refreshNeeded[self_playerGUID] = true;
            }
            this.DebugTimestamp("%s: %d -> %d (%s).", event, this.power[powerType], power, powerType);
        } else {
            for (const [powerType, powerInfo] of _pairs(this.POWER_INFO)) {
                let power = API_UnitPower("player", powerInfo.id, powerInfo.segments);
                if (this.power[powerType] != power) {
                    this.power[powerType] = power;
                    Ovale.refreshNeeded[self_playerGUID] = true;
                }
                this.DebugTimestamp("%s: %d -> %d (%s).", event, this.power[powerType], power, powerType);
            }
        }
        Ovale.refreshNeeded[self_playerGUID] = true;
        this.StopProfiling("OvalePower_UpdatePower");
    }
    UpdatePowerRegen(event) {
        this.StartProfiling("OvalePower_UpdatePowerRegen");
        let [inactiveRegen, activeRegen] = API_GetPowerRegen();
        if (this.inactiveRegen != inactiveRegen || this.activeRegen != activeRegen) {
            [this.inactiveRegen, this.activeRegen] = [inactiveRegen, activeRegen];
            Ovale.refreshNeeded[self_playerGUID] = true;
        }
        this.StopProfiling("OvalePower_UpdatePowerRegen");
    }
    UpdatePowerType(event) {
        this.StartProfiling("OvalePower_UpdatePowerType");
        let [currentType, currentToken] = API_UnitPowerType("player");
        let powerType = this.POWER_TYPE[currentType];
        if (this.powerType != powerType) {
            this.powerType = powerType;
            Ovale.refreshNeeded[self_playerGUID] = true;
        }
        Ovale.refreshNeeded[self_playerGUID] = true;
        this.StopProfiling("OvalePower_UpdatePowerType");
    }
    GetSpellCost(spellId, powerType) {
        this.StartProfiling("OvalePower_GetSpellCost");
        let spellPowerCost = API_GetSpellPowerCost(spellId)[1];
        if (spellPowerCost) {
            let cost = spellPowerCost.cost;
            let typeId = spellPowerCost.type;
            for (const [pt, p] of _pairs(this.POWER_INFO)) {
                if (p.id == typeId && (powerType == undefined || pt == powerType)) {
                    return [cost, pt];
                }
            }
        }
        return undefined;
    }
    GetPower(powerType, atTime) {
        let power = (this.power && this.power[powerType]) || this[powerType] || 0;
        let powerRate = 0;
        if (this.powerType && this.powerType == powerType && this.activeRegen) {
            powerRate = this.activeRegen;
        } else if (this.powerRate && this.powerRate[powerType]) {
            powerRate = this.powerRate[powerType];
        }
        if (atTime) {
            let now = this.currentTime || API_GetTime();
            let seconds = atTime - now;
            if (seconds > 0) {
                power = power + powerRate * seconds;
            }
        }
        return power;
    }
    PowerCost(spellId, powerType, atTime, targetGUID, maximumCost?) {
        OvalePower.StartProfiling("OvalePower_PowerCost");
        let buffParam = "buff_" + powerType;
        let spellCost = 0;
        let spellRefund = 0;
        let si = OvaleData.spellInfo[spellId];
        if (si && si[powerType]) {
            let cost = OvaleData.GetSpellInfoProperty(spellId, atTime, powerType, targetGUID);
            if (cost == "finisher") {
                cost = this.GetPower(powerType, atTime);
                let minCostParam = "min_" + powerType;
                let maxCostParam = "max_" + powerType;
                let minCost = si[minCostParam] || 1;
                let maxCost = si[maxCostParam];
                if (cost < minCost) {
                    cost = minCost;
                }
                if (maxCost && cost > maxCost) {
                    cost = maxCost;
                }
            } else if (cost == "refill") {
                cost = this.GetPower(powerType, atTime) - OvalePower.maxPower[powerType];
            } else {
                let buffExtraParam = buffParam;
                let buffAmountParam = buffParam + "_amount";
                let buffExtra = si[buffExtraParam];
                if (buffExtra) {
                    let aura = OvaleAura.GetAura("player", buffExtra, undefined, true);
                    let isActiveAura = OvaleAura.IsActiveAura(aura, atTime);
                    if (isActiveAura) {
                        let buffAmount = 0;
                        if (type(buffAmountParam) == "number") {
                            buffAmount = si[buffAmountParam] || -1;
                        } else if (si[buffAmountParam] == "value3") {
                            buffAmount = aura.value3 || -1;
                        } else if (si[buffAmountParam] == "value2") {
                            buffAmount = aura.value2 || -1;
                        } else if (si[buffAmountParam] == "value1") {
                            buffAmount = aura.value1 || -1;
                        } else {
                            buffAmount = -1;
                        }
                        let siAura = OvaleData.spellInfo[buffExtra];
                        if (siAura && siAura.stacking == 1) {
                            buffAmount = buffAmount * aura.stacks;
                        }
                        cost = cost + buffAmount;
                        this.Log("Spell ID '%d' had %f %s added from aura ID '%d'.", spellId, buffAmount, powerType, aura.spellId);
                    }
                }
            }
            let extraPowerParam = "extra_" + powerType;
            let extraPower = OvaleData.GetSpellInfoProperty(spellId, atTime, extraPowerParam, targetGUID);
            if (extraPower) {
                if (!maximumCost) {
                    let power = math.floor(this.GetPower(powerType, atTime));
                    power = power > cost && power - cost || 0;
                    if (extraPower >= power) {
                        extraPower = power;
                    }
                }
                cost = cost + extraPower;
            }
            spellCost = ceil(cost);
            let refundParam = "refund_" + powerType;
            let refund = OvaleData.GetSpellInfoProperty(spellId, atTime, refundParam, targetGUID);
            if (refund == "cost") {
                refund = spellCost;
            }
            refund = refund || 0;
            spellRefund = ceil(refund);
        } else {
            let [cost] = OvalePower.GetSpellCost(spellId, powerType);
            if (cost) {
                spellCost = cost;
            }
        }
        OvalePower.StopProfiling("OvalePower_PowerCost");
        return [spellCost, spellRefund];
    }
    RequirePowerHandler(spellId, atTime, requirement, tokens, index, targetGUID) {
        let verified = false;
        let cost = tokens;
        if (index) {
            cost = tokens[index];
            index = index + 1;
        }
        if (cost) {
            let powerType = requirement;
            cost = this.PowerCost(spellId, powerType, atTime, targetGUID);
            if (cost > 0) {
                let power = this.GetPower(powerType, atTime);
                if (power >= cost) {
                    verified = true;
                }
                this.Log("   Has power %f %s", power, powerType);
            } else {
                verified = true;
            }
            if (cost > 0) {
                let result = verified && "passed" || "FAILED";
                this.Log("    Require %f %s at time=%f: %s", cost, powerType, atTime, result);
            }
        } else {
            Ovale.OneTimeMessage("Warning: requirement '%s' is missing a cost argument.", requirement);
        }
        return [verified, requirement, index];
    }
    DebugPower() {
        this.Print("Power type: %s", this.powerType);
        for (const [powerType, v] of _pairs(this.power)) {
            this.Print("Power (%s): %d / %d", powerType, v, this.maxPower[powerType]);
        }
        this.Print("Active regen: %f", this.activeRegen);
        this.Print("Inactive regen: %f", this.inactiveRegen);
    }
    CopySpellcastInfo(spellcast, dest) {
        for (const [_, powerType] of _pairs(self_SpellcastInfoPowerTypes)) {
            if (spellcast[powerType]) {
                dest[powerType] = spellcast[powerType];
            }
        }
    }
    SaveSpellcastInfo(spellcast, atTime, state) {
        let spellId = spellcast.spellId;
        if (spellId) {
            let si = OvaleData.spellInfo[spellId];
            if (si) {
                let dataModule = state || OvaleData;
                let powerModule = state || this;
                for (const [_, powerType] of _pairs(self_SpellcastInfoPowerTypes)) {
                    if (si[powerType] == "finisher") {
                        let maxCostParam = "max_" + powerType;
                        let maxCost = si[maxCostParam] || 1;
                        let cost = dataModule.GetSpellInfoProperty(spellId, atTime, powerType, spellcast.target);
                        if (cost == "finisher") {
                            let power = powerModule.GetPower(powerType, atTime);
                            if (power > maxCost) {
                                cost = maxCost;
                            } else {
                                cost = power;
                            }
                        } else if (cost == 0) {
                            cost = maxCost;
                        }
                        spellcast[powerType] = cost;
                    }
                }
            }
        }
    }
}
OvalePower.statePrototype = {
}
let statePrototype = OvalePower.statePrototype;
statePrototype.powerRate = undefined;
class OvalePower {
    InitializeState(state) {
        for (const [powerType] of _pairs(this.POWER_INFO)) {
            state[powerType] = 0;
        }
        state.powerRate = {
        }
    }
    ResetState(state) {
        this.StartProfiling("OvalePower_ResetState");
        for (const [powerType] of _pairs(this.POWER_INFO)) {
            state[powerType] = this.power[powerType] || 0;
        }
        for (const [powerType] of _pairs(this.POWER_INFO)) {
            state.powerRate[powerType] = 0;
        }
        if (OvaleFuture.inCombat) {
            state.powerRate[this.powerType] = this.activeRegen;
        } else {
            state.powerRate[this.powerType] = this.inactiveRegen;
        }
        this.StopProfiling("OvalePower_ResetState");
    }
    CleanState(state) {
        for (const [powerType] of _pairs(this.POWER_INFO)) {
            state[powerType] = undefined;
        }
        for (const [k] of _pairs(state.powerRate)) {
            state.powerRate[k] = undefined;
        }
    }
    ApplySpellStartCast(state, spellId, targetGUID, startCast, endCast, isChanneled, spellcast) {
        this.StartProfiling("OvalePower_ApplySpellStartCast");
        if (isChanneled) {
            if (state.inCombat) {
                state.powerRate[this.powerType] = this.activeRegen;
            }
            state.ApplyPowerCost(spellId, targetGUID, startCast, spellcast);
        }
        this.StopProfiling("OvalePower_ApplySpellStartCast");
    }
    ApplySpellAfterCast(state, spellId, targetGUID, startCast, endCast, isChanneled, spellcast) {
        this.StartProfiling("OvalePower_ApplySpellAfterCast");
        if (!isChanneled) {
            if (state.inCombat) {
                state.powerRate[this.powerType] = this.activeRegen;
            }
            state.ApplyPowerCost(spellId, targetGUID, endCast, spellcast);
        }
        this.StopProfiling("OvalePower_ApplySpellAfterCast");
    }
}
statePrototype.ApplyPowerCost = function (state, spellId, targetGUID, atTime, spellcast) {
    OvalePower.StartProfiling("OvalePower_state_ApplyPowerCost");
    let si = OvaleData.spellInfo[spellId];
    {
        let [cost, powerType] = OvalePower.GetSpellCost(spellId);
        if (cost && powerType && state[powerType] && !(si && si[powerType])) {
            state[powerType] = state[powerType] - cost;
        }
    }
    if (si) {
        for (const [powerType, powerInfo] of _pairs(OvalePower.POWER_INFO)) {
            let [cost, refund] = state.PowerCost(spellId, powerType, atTime, targetGUID);
            let power = state[powerType] || 0;
            if (cost) {
                power = power - cost + refund;
                let seconds = state.nextCast - atTime;
                if (seconds > 0) {
                    let powerRate = state.powerRate[powerType] || 0;
                    power = power + powerRate * seconds;
                }
                let mini = powerInfo.mini || 0;
                let maxi = powerInfo.maxi || OvalePower.maxPower[powerType];
                if (mini && power < mini) {
                    power = mini;
                }
                if (maxi && power > maxi) {
                    power = maxi;
                }
                state[powerType] = power;
            }
        }
    }
    OvalePower.StopProfiling("OvalePower_state_ApplyPowerCost");
}
statePrototype.TimeToPower = function (state, spellId, atTime, targetGUID, powerType, extraPower) {
    let seconds = 0;
    powerType = powerType || OvalePower.POOLED_RESOURCE[state.class];
    if (powerType) {
        let cost = state.PowerCost(spellId, powerType, atTime, targetGUID);
        let power = state.GetPower(powerType, atTime);
        let powerRate = state.powerRate[powerType] || 0;
        if (extraPower) {
            cost = cost + extraPower;
        }
        if (power < cost) {
            if (powerRate > 0) {
                seconds = (cost - power) / powerRate;
            } else {
                seconds = INFINITY;
            }
        }
    }
    return seconds;
}
statePrototype.GetPower = OvalePower.GetPower;
statePrototype.PowerCost = OvalePower.PowerCost;
statePrototype.RequirePowerHandler = OvalePower.RequirePowerHandler;
{
    let output = {
    }
    statePrototype.DebugPower = function (state) {
        _wipe(output);
        for (const [powerType] of _pairs(OvalePower.POWER_INFO)) {
            output[lualength(output) + 1] = Ovale.MakeString("%s = %d", powerType, state[powerType]);
        }
        return tconcat(output, "\n");
    }
}
