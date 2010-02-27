local ADDONNAME = "ZebraKarmaFrames"
ZebraKarmaFrames = LibStub("AceAddon-3.0"):NewAddon(ADDONNAME, "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0","AceComm-3.0", "AceTimer-3.0")
local S = LibStub("AceSerializer-3.0")
local addon = ZebraKarmaFrames
addon.ADDONNAME = ADDONNAME
addon.VERSION = "0.1"
addon.CommPrefix = ADDONNAME.."_1"

local L = LibStub("AceLocale-3.0"):GetLocale(addon.ADDONNAME, true)
local AceGUI = LibStub("AceGUI-3.0")



function addon:OnInitialize()
	self:RegisterComm(self.CommPrefix)



end


function addon:TimerFeedback()
  ZebraKarmaFrames:Callme(1,6948)
  self.timerCount = self.timerCount + 1

  if self.timerCount == 50 then
    self:CancelAllTimers()
  end
end


function addon:Callme(parx,pary)
	addon:CreateLootFrame(parx,pary)
end 

function addon:CreateLootFrame(fIndex,itemID)
	local zkf = getglobal("ZebraKarmaFramesLootFrame"..fIndex)

	if not zkf then
		zkf = CreateFrame("Frame","ZebraKarmaFramesLootFrame"..fIndex, UIParent , "ZKFFormTemplate")
	end
	itemName, itemLink, _, _, _, _, _, _,_, itemTexture = GetItemInfo(itemID) 
	getglobal("ZebraKarmaFramesLootFrame"..fIndex.."Icon"):SetNormalTexture(itemTexture)
	getglobal("ZebraKarmaFramesLootFrame"..fIndex.."Icon"):SetText(itemID)
	getglobal("ZebraKarmaFramesLootFrame"..fIndex.."IconText"):Hide()
	getglobal("ZebraKarmaFramesLootFrame"..fIndex.."LabelText"):SetText(itemName)
	getglobal("ZebraKarmaFramesLootFrame"..fIndex.."Roll"):Disable()
--	getglobal("ZebraKarmaFramesLootFrame"..fIndex.."Roll"):SetNormalTexture("")
	getglobal("ZebraKarmaFramesLootFrame"..fIndex.."Roll"):SetDisabledTexture("")
	zkf:ClearAllPoints()
	zkf:SetParent(UIParent)
	local leftOffset = fIndex * (zkf:GetWidth() + 20)
	local topOffset = 0

	if leftOffset > GetScreenWidth()  then
		leftOffset = 0 
		topOffset = 120
	end
	zkf:SetPoint("LEFT", UIParent, "LEFT", leftOffset, topOffset )
--	zkf:SetPoint("TOP",  )	
	zkf:SetFrameStrata("BACKGROUND")
	zkf:Show()
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








function myIconEnter(self)
itemid = self:GetText()
print(itemid)
local itemName  = GetItemInfo(itemid)
self:SetNormalTexture("Interface\\Icons\\"..GetItemIcon(itemid))
GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
GameTooltip:SetHyperlink("item:"..itemid..":0:0:0:0:0:0:0")
GameTooltip:Show()
end


function myIconLeave(self)
GameTooltip:Hide()
end



function btnClick(self)
--debug
--print (button.text:GetText())
addon:SendComm("WHISPER",  UnitName("player"), "BTNCLICK", self.text:GetText()) 
end

function addon:OnBTNCLICK(sender,msg)
print(sender..msg)
end 


function addon:OnBROADCAST(sender,msg,...)
	fIndex = select(1,...)
	ZebraKarmaFrames:Callme(msg, fIndex)
--		self.timer..fIndex = self:ScheduleRepeatingTimer("ZKF"..fIndex,0.2)
	print(sender..msg..select(1,...))
end 

function addon:OnITEMROLLSTART(sender,msg)
	getglobal("ZebraKarmaFramesLootFrame"..msg.."Roll"):SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
	getglobal("ZebraKarmaFramesLootFrame"..msg.."Roll"):Enable()	
end

function addon:OnWINNERANNOUNCE(sender,msg)
	getglobal("ZebraKarmaFramesLootFrame"..msg):Hide()		
end

function addon:CanUse(itemlink)

	GameTooltip:Show()
	GameTooltip:SetHyperlink(itemlink)
	local l = { "TextLeft", "TextRight" }
	
	for i = 2, GameTooltip:NumLines() do
		for _, v in pairs( l ) do
			local obj = getfenv()[GameTooltip:GetName() .. v .. i]
			if obj and obj:IsShown() then
				local txt = obj:GetText()
				local r, g, b = obj:GetTextColor()
				local c = string.format( "%02x%02x%02x", r * 255, g * 255, b * 255 )
				print(c)
				if c == "fe1f1f" then
					if txt ~= ITEM_DISENCHANT_NOT_DISENCHANTABLE then
						GameTooltip:Hide()
						return false
					end
				end
			end
		end
	end
	GameTooltip:Hide()
	return true

end

function myIconClick()
	print("iconclick")
end


function myPassClick(obj)
	obj:GetParent():Hide()
end


function myOffSpecClick(self)
	self.glow = self:CreateTexture(nil,"OVERLAY")
	self.glow:SetTexture("Interface\\Buttons\\UI-Panel-Button-Glow")
	self.glow:SetAlpha(1)
	self.glow:SetBlendMode("ADD")	
	self.glow:SetTexCoord(0,0.7,0,0.5)
	self.glow:SetPoint("TOPLEFT", self ,"TOPLEFT", -5, 5)
	self.glow:SetPoint("BOTTOMRIGHT", self ,"BOTTOMRIGHT", 0, 0)
	

	addon:SendComm("WHISPER", UnitName("player"), "BTNCLICK", self:GetText()) 
	print("offspec")
	self:Disable()
	
end


function myBonusClick(self)
	self.glow = self:CreateTexture(nil,"OVERLAY")
	self.glow:SetTexture("Interface\\Buttons\\UI-Panel-Button-Glow")
	self.glow:SetAlpha(1)
	self.glow:SetBlendMode("ADD")	
	self.glow:SetTexCoord(0,0.7,0,0.5)
	self.glow:SetPoint("TOPLEFT", self ,"TOPLEFT", -5, 5)
	self.glow:SetPoint("BOTTOMRIGHT", self ,"BOTTOMRIGHT", 0, 0)
	

	addon:SendComm("WHISPER", UnitName("player"), "BTNCLICK", self:GetText()) 
	print("bonus")
end


function myNoBonusClick(self)
	self.glow = self:CreateTexture(nil,"OVERLAY")
	self.glow:SetTexture("Interface\\Buttons\\UI-Panel-Button-Glow")
	self.glow:SetAlpha(1)
	self.glow:SetBlendMode("ADD")	
	self.glow:SetTexCoord(0,0.7,0,0.5)
	self.glow:SetPoint("TOPLEFT", self ,"TOPLEFT", -5, 5)
	self.glow:SetPoint("BOTTOMRIGHT", self ,"BOTTOMRIGHT", 0, 0)
	

	addon:SendComm("WHISPER", UnitName("player"), "BTNCLICK", self:GetText()) 
	print("nobonus")
end

function addon:ZKFRoll(self)
	RandomRoll(1,100)
	self:SetNormalTexture("")
	self:SetDisabledTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
	self:Disable()
end