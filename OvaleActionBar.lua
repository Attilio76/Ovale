--[[--------------------------------------------------------------------
    Ovale Spell Priority
    Copyright (C) 2012 Sidoine

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License in the LICENSE
    file accompanying this program.
----------------------------------------------------------------------]]

-- Keep data about the player action bars (key bindings mostly)
OvaleActionBar = LibStub("AceAddon-3.0"):NewAddon("OvaleActionBar", "AceEvent-3.0")

--<private-static-properties>
local Ovale = LibStub("AceAddon-3.0"):GetAddon("Ovale")

local GetActionInfo = GetActionInfo
local GetActionText = GetActionText
local tonumber = tonumber
--</private-static-properties>

--<public-static-properties>
--key: spell name / value: action icon id
OvaleActionBar.actionSort = {}
OvaleActionBar.actionMacro = {}
OvaleActionBar.actionObjet = {}
OvaleActionBar.shortCut = {}
--</public-static-properties>

--<public-static-methods>
function OvaleActionBar:OnEnable()
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	self:RegisterEvent("UPDATE_BINDINGS")
end
	
function OvaleActionBar:OnDisable()
	self:UnregisterEvent("ACTIONBAR_SLOT_CHANGED")
	self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_TALENT_UPDATE")
	self:UnregisterEvent("UPDATE_BINDINGS")
end
	
function OvaleActionBar:ACTIONBAR_SLOT_CHANGED(event, slot, unknown)
	if (slot == 0) then
		self:FillActionIndexes(event)
	elseif (slot) then
	-- on re�oit aussi si c'est une macro avec mouseover � chaque fois que la souris passe sur une cible!
		self:FillActionIndex(tonumber(slot))
		Ovale:debugPrint("action_bar", "Mapping button " ..tonumber(slot).." to spell/macro")
	end
end

function OvaleActionBar:ACTIVE_TALENT_GROUP_CHANGED(event)
	self:FillActionIndexes(event)
end

function OvaleActionBar:PLAYER_ENTERING_WORLD(event)
	self:FillActionIndexes(event)
end

function OvaleActionBar:PLAYER_TALENT_UPDATE(event)
	self:FillActionIndexes(event)
end

--Called when the user changed his key bindings
function OvaleActionBar:UPDATE_BINDINGS(event)
	self:FillActionIndexes(event)
end

function OvaleActionBar:FillActionIndexes(event)
	Ovale:debugPrint("action_bar", "Mapping buttons to spells/macros for " ..event)
	self.actionSort = {}
	self.actionMacro = {}
	self.actionObjet = {}
	self.shortCut = {}
	for i=1,120 do
		self:FillActionIndex(i)
	end
end

function OvaleActionBar:FillActionIndex(i)
	self.shortCut[i] = self:FindKeyBinding(i)
	local actionText = GetActionText(i)
	if actionText then
		self.actionMacro[actionText] = i
	else
		local type, spellId = GetActionInfo(i);
		if (type=="spell") then
			self.actionSort[spellId] = i
		elseif (type =="item") then
			self.actionObjet[spellId] = i
		end
	end
end

function OvaleActionBar:FindKeyBinding(id)
-- ACTIONBUTTON1..12 => principale (1..12, 13..24, 73..108)
-- MULTIACTIONBAR1BUTTON1..12 => bas gauche (61..72)
-- MULTIACTIONBAR2BUTTON1..12 => bas droite (49..60)
-- MULTIACTIONBAR3BUTTON1..12 => haut droit (25..36)
-- MULTIACTIONBAR4BUTTON1..12 => haut gauche (37..48)
	local name;
	if (id<=24 or id>72) then
		name = "ACTIONBUTTON"..(((id-1)%12)+1);
	elseif (id<=36) then
		name = "MULTIACTIONBAR3BUTTON"..(id-24);
	elseif (id<=48) then
		name = "MULTIACTIONBAR4BUTTON"..(id-36);
	elseif (id<=60) then
		name = "MULTIACTIONBAR2BUTTON"..(id-48);
	else
		name = "MULTIACTIONBAR1BUTTON"..(id-60);
	end
	local key = GetBindingKey(name);
--[[	if (not key) then
		DEFAULT_CHAT_FRAME:AddMessage(id.."=>"..name.." introuvable")
	else
		DEFAULT_CHAT_FRAME:AddMessage(id.."=>"..name.."="..key)
	end]]
	return key;
end

-- Get the action id that match a spell id
function OvaleActionBar:GetForSpell(spellId)
	return self.actionSort[spellId]
end

-- Get the action id that match a macro id
function OvaleActionBar:GetForMacro(macroId)
	return self.actionMacro[macroId]
end

-- Get the action id that match an item id
function OvaleActionBar:GetForItem(itemId)
	return self.actionObjet[itemId]
end

function OvaleActionBar:GetBinding(actionId)
	return self.shortCut[actionId]
end
--</public-static-methods>
