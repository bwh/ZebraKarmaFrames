local ADDONNAME = "ZebraKarmaFrames"
ZebraKarmaFrames = LibStub("AceAddon-3.0"):NewAddon(ADDONNAME, "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0","AceComm-3.0")
local S = LibStub("AceSerializer-3.0")
local addon = ZebraKarmaFrames
addon.ADDONNAME = ADDONNAME
addon.VERSION = "0.1"
addon.CommPrefix = ADDONNAME.."_1"

local L = LibStub("AceLocale-3.0"):GetLocale(addon.ADDONNAME, true)
local AceGUI = LibStub("AceGUI-3.0")



function addon:OnInitialize()
	self:RegisterComm(self.CommPrefix)
	count = 5
	for i = 1, count do
		local zkf = CreateFrame("Frame","myzkfframe"..i, nil , "ZKFFormTemplate")
		zkf:SetFrameStrata("BACKGROUND")
		zkf:SetPoint("CENTER",0,0)
		zkf:Show()
	end 
end



function addon:SendComm(distribution, target, ...)
	msgRaw = S:Serialize(...)
	self:SendCommMessage(self.CommPrefix, msgRaw, distribution, target)
end

function addon:OnCommReceived(prefix, msgRaw, distribution, sender)
	if prefix ~= self.CommPrefix then return end

	local msg = {S:Deserialize(msgRaw)}
	if not msg[1] then
		DEFAULT_CHAT_FRAME:AddMessage("ZebraKarmaFrames ERROR: Cannot unpack comms message")
		return
	end

	local handlerName = "On" .. msg[2]
	-- All messages are optional. ZebRaid sends a lot of messages we don't care about
	if self[handlerName] then
		self[handlerName](self, sender, select(3,unpack(msg)))
	end
end








function IconEnter(icon,itemid)
local itemName  = GetItemInfo(itemid)
icon:SetImage("Interface\\Icons\\"..GetItemIcon(itemid))
GameTooltip:SetOwner(icon.frame, "ANCHOR_PRESERVE")
GameTooltip:SetHyperlink("item:"..itemid..":0:0:0:0:0:0:0")
end


function IconLeave(icon)
icon:SetImage("Interface\\Icons\\spell_frost_wizardmark")
GameTooltip:Hide()
end



function btnClick(button)
--debug
--print (button.text:GetText())
addon:SendComm("WHISPER", "Bahadur", "BTNCLICK", button.text:GetText()) 
end

function addon:OnBTNCLICK(sender,msg)
print(sender..msg)
end 

function CanUse()

	local l = { "TextLeft", "TextRight" }
	
	for i = 2, GameTooltip:NumLines() do
		for _, v in pairs( l ) do
			local obj = getfenv()[GameTooltip:GetName() .. v .. i]
			if obj and obj:IsShown() then
				local txt = obj:GetText()
				local r, g, b = obj:GetTextColor()
				local c = string.format( "%02x%02x%02x", r * 255, g * 255, b * 255 )
				if c == "fe1f1f" then
					--ArkInventory.Output( { "line[", i, "]=[", txt, "]" } )
					if txt ~= ITEM_DISENCHANT_NOT_DISENCHANTABLE then
						return false
					end
				end
			end
		end
	end

	return true
	
end


function myIconEnter()
	print("iconenter")
end

function myIconLeave()
	print("iconleave")
end

function myIconClick()
	print("iconclick")
end


function myPassClick()
	print("pass")
end


function myOffSpecClick()
	print("offspec")
end


function myBonusClick()
	print("bonus")
end


function myNoBonusClick()
	print("nobonus")
end


function GroupLootFrame_OnShow(self)
	local texture, name, count, quality, bindOnPickUp = GetLootRollItemInfo(self.rollID);
	
	if ( bindOnPickUp ) then
		self:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } } );
		getglobal(self:GetName().."Corner"):SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Corner");
		getglobal(self:GetName().."Decoration"):Show();
	else 
		self:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } } );
		getglobal(self:GetName().."Corner"):SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner");
		getglobal(self:GetName().."Decoration"):Hide();
	end
	
	local id = self:GetID();
	getglobal("GroupLootFrame"..id.."IconFrameIcon"):SetTexture(texture);
	getglobal("GroupLootFrame"..id.."Name"):SetText(name);
	local color = ITEM_QUALITY_COLORS[quality];
	getglobal("GroupLootFrame"..id.."Name"):SetVertexColor(color.r, color.g, color.b);
end