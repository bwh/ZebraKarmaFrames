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
	itemName, itemLink, _, _, _, _, _, _,_, itemTexture = GetItemInfo(itemID) 
	
	local zkf = getglobal("ZebraKarmaFramesLootFrame"..fIndex)
	if not zkf then
		zkf = CreateFrame("Frame","ZebraKarmaFramesLootFrame"..fIndex, UIParent , "ZKFFormTemplate")
	end
	
	zkf.Icon = getglobal("ZebraKarmaFramesLootFrame"..fIndex.."Icon")
	zkf.IconText = getglobal("ZebraKarmaFramesLootFrame"..fIndex.."IconText")
	zkf.LabelText = getglobal("ZebraKarmaFramesLootFrame"..fIndex.."LabelText")
	zkf.Roll = getglobal("ZebraKarmaFramesLootFrame"..fIndex.."Roll")
	zkf.btnBonus = getglobal("ZebraKarmaFramesLootFrame"..fIndex.."btnBonus")
	zkf.btnNoBonus = getglobal("ZebraKarmaFramesLootFrame"..fIndex.."btnNoBonus")
	zkf.btnOffSpec = getglobal("ZebraKarmaFramesLootFrame"..fIndex.."btnOffSpec")
	zkf.btnPass = getglobal("ZebraKarmaFramesLootFrame"..fIndex.."btnPass")		
	zkf.buttonValue = ""
		
	zkf.Icon:SetNormalTexture(itemTexture)
	zkf.Icon:SetText(itemID)
	zkf.IconText:Hide()
	zkf.LabelText:SetText(itemName)
	zkf.Roll:Enable()
	zkf.Roll:Hide()
	zkf.Roll:SetDisabledTexture("")
	zkf.btnBonus:Enable()
	if not (zkf.btnBonus.glow == nil) then
	   zkf.btnBonus.glow:Hide()
	end
	zkf.btnNoBonus:Enable()
	if not (zkf.btnNoBonus.glow == nil) then
	   zkf.btnNoBonus.glow:Hide()
	end
	zkf.btnOffSpec:Enable()	
	if not (zkf.btnOffSpec.glow == nil) then
	   zkf.btnOffSpec.glow:Hide()
	end

	zkf:ClearAllPoints()
	zkf:SetParent(UIParent)
	local leftOffset = 500 + fIndex * (zkf:GetWidth() + 20)
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
	itemID = select(1,...)
	local zkf = getglobal("ZebraKarmaFramesLootFrame"..msg)
	if not zkf then
		ZebraKarmaFrames:Callme(msg, itemID)
	elseif not(tostring(itemID) == zkf.Icon:GetText()) then
		if not (zkf.ButtonValue == "Pass") then
			ZebraKarmaFrames:Callme(msg, itemID)
		end
	end
end 

function addon:OnITEMROLLSTART(sender,msg)
	local zkf = getglobal("ZebraKarmaFramesLootFrame"..msg)
	zkf.Roll:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
	zkf.Roll:Show()
	getglobal("ZebraKarmaFramesLootFrame"..msg.."NoticeText"):SetText("Current Karma:\n".."300".."\nYou will lose:\n".."150")
end

function addon:OnWINNERANNOUNCE(sender,msg)
	local zkf = getglobal("ZebraKarmaFramesLootFrame"..msg)
	if zkf then 
		zkf:Hide()
		zkf.buttonValue = ""
	end
	
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


function myPassClick(self)
	self:GetParent():Hide()
	self:GetParent().buttonValue = "Pass"
end


function myOffSpecClick(self)
	addon:CreateGlow(self)
	addon:SendComm("WHISPER", UnitName("player"), "BTNCLICK", self:GetText()) 
	self:Disable()
	self:GetParent().buttonValue = "OffSpec"
	addon:UpdateButtonState(self)	
end


function myBonusClick(self)
	addon:CreateGlow(self)
	addon:SendComm("WHISPER", UnitName("player"), "BTNCLICK", self:GetText()) 
	self:Disable()
	self:GetParent().buttonValue = "Bonus"

	addon:UpdateButtonState(self)end


function myNoBonusClick(self)
	addon:CreateGlow(self)
	addon:SendComm("WHISPER", UnitName("player"), "BTNCLICK", self:GetText()) 
	self:Disable()
	self:GetParent().buttonValue = "NoBonus"
	addon:UpdateButtonState(self)
end

function addon:CreateGlow(self)
	self.glow = self:CreateTexture(nil,"OVERLAY")
	self.glow:SetTexture("Interface\\Buttons\\UI-Panel-Button-Glow")
	self.glow:SetAlpha(1)
	self.glow:SetBlendMode("ADD")	
	self.glow:SetTexCoord(0,0.7,0,0.5)
	self.glow:SetPoint("TOPLEFT", self ,"TOPLEFT", -5, 5)
	self.glow:SetPoint("BOTTOMRIGHT", self ,"BOTTOMRIGHT", 0, 0)

end

function addon:UpdateButtonState(self)
	if not (self:GetParent().buttonValue == "Bonus") then
		self:GetParent().btnBonus:Enable()
		if not (self:GetParent().btnBonus.glow == nil) then
			self:GetParent().btnBonus.glow:Hide()	
		end
	end
	if not (self:GetParent().buttonValue == "NoBonus") then	
		self:GetParent().btnNoBonus:Enable()
		if not (self:GetParent().btnNoBonus.glow == nil) then
			self:GetParent().btnNoBonus.glow:Hide()	
		end
	end
	if not (self:GetParent().buttonValue == "OffSpec") then
		self:GetParent().btnOffSpec:Enable()	
		if not (self:GetParent().btnOffSpec.glow == nil) then
			self:GetParent().btnOffSpec.glow:Hide()	
		end
	end
	

end
function addon:ZKFRoll(self)
	RandomRoll(1,100)
	self:SetNormalTexture("")
	self:SetDisabledTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
	self:Disable()
end