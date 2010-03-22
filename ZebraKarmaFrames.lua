--/run ZebraKarmaFrames:SendComm("RAID", nil, "ITEMROLLSTART", 2)
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
	self.maxFrameIdx = 0
end

function addon:OnEnable()
	self:RegisterEvent("CHAT_MSG_WHISPER", "ParseWhipers")
end

function addon:OnDisable()
	self:UnregisterEvent("CHAT_MSG_WHISPER")
end


function addon:Callme(index, itemID)
	addon:CreateLootFrame(index, itemID)
end

function addon:CreateLootFrame(fIndex, itemID)
	itemName, itemLink, _, _, _, _, _, _,_, itemTexture = GetItemInfo(itemID)

	local zkf = getglobal("ZebraKarmaFramesLootFrame"..fIndex)
	if not zkf then
		zkf = CreateFrame("Frame","ZebraKarmaFramesLootFrame"..fIndex, UIParent , "ZKFFormTemplate")
		self.maxFrameIdx = math.max(self.maxFrameIdx, fIndex)
	end

	zkf.dontShow = nil
	zkf.currentButton = nil
	zkf.rolling = false

	zkf.Icon:SetNormalTexture(itemTexture)
	zkf.Icon:SetText(itemID)
	zkf.IconText:Hide()
	zkf.LabelText:SetText(itemName)
	zkf.NoticeText:SetText("")
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
	zkf:SetFrameStrata("HIGH")
	self:EnableButtons(zkf)
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



function addon:OnBTNCLICK(sender,msg)
	print(sender..msg)
end


function addon:OnBROADCAST(sender, index, itemID)
	-- Record the sender name, so that we can whisper back to him...
	self.KarmaMaster = sender

	if index == 1 then
		addon:HideAllFrames()
	end

	local zkf = getglobal("ZebraKarmaFramesLootFrame"..index)
	if not zkf then
		ZebraKarmaFrames:CreateLootFrame(index, itemID)
	elseif (tostring(itemID) == zkf.Icon:GetText()) then
		if not zkf.dontShow then
			zkf:Show()
		end
	else
		ZebraKarmaFrames:CreateLootFrame(index, itemID)
	end
end

function addon:OnITEMROLLSTART(sender, index)
	local zkf = getglobal("ZebraKarmaFramesLootFrame"..index)
	self.activeFrame = zkf
	zkf.rolling = true
	if not zkf.currentButton then
		addon:CreateGlow(zkf,3)
		zkf.timer = addon:ScheduleRepeatingTimer("Flasher", 0.25, zkf)
		zkf.timerends = addon:ScheduleTimer("FlashEnds",10, zkf)
	else
		self:SendComm("WHISPER", self.KarmaMaster, "BTNCLICK", zkf.currentButton.whisperText)
		if zkf.Roll:IsEnabled() == 1 then
			zkf.Roll:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
			zkf.Roll:Show()
			addon:CreateGlow(zkf.Roll,2)
			zkf.timer = addon:ScheduleRepeatingTimer("Flasher", 0.25, zkf.Roll)
			zkf.timerends = addon:ScheduleTimer("FlashEnds",10, zkf.Roll)
		end
	end
end

function addon:Flasher(frame)
	frame.glow:SetAlpha(1 - frame.glow:GetAlpha())
end

function addon:FlashEnds(frame)
	addon:CancelTimer(frame.timer)
	frame.glow:Hide()
end

function addon:OnWINNERANNOUNCE(sender,msg)
	local zkf = getglobal("ZebraKarmaFramesLootFrame"..msg)
	if zkf then
		zkf:Hide()
		zkf.dontShow = true
	end
	-- Not checking ZKF here. Clearly something is wrong if there is a mismatch.
	self.activeFrame = nil
end

function addon:HideAllFrames()
	for i=1, self.maxFrameIdx do
		local zkf = getglobal("ZebraKarmaFramesLootFrame"..i)
		if zkf then
			zkf:Hide()
		end
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
--	print("iconclick")
end

function DeclareButtonClick(self)
	local parent = self:GetParent()

	-- First hide the glow of old selection, and enable it
	if parent.currentButton then
		parent.currentButton:Enable()
		if parent.currentButton.glow then
			parent.currentButton.glow:Hide()
		end
	end

	-- If we are going to whisper, make the selection glow until needed.
	-- If not, hide the frame, and make sure it doesn't come back
	if self.whisperText then
		if parent.rolling then
			addon:SendComm("WHISPER", addon.KarmaMaster, "BTNCLICK", self.whisperText)
		end
	else
		parent:Hide()
		parent.dontShow = true
	end

	parent.currentButton = self

	-- Don't add glow to the button if we are going to hide the frame.
	if not parent.dontShow then
		-- Disable this button, and add a glow to it
		self:Disable()
		addon:CreateGlow(self, 1)

		-- If there is a previous timer or glow, get rid of it ...
		addon:CancelTimer(parent.timer, true)
		addon:CancelTimer(parent.timerends, true)

		if parent.glow then
			parent.glow:Hide()
		end

		-- If we are supposed to roll now, add a glow
		if parent.rolling then
			parent.Roll:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
			parent.Roll:Show()
			addon:CreateGlow(parent.Roll, 2)
			parent.timer = addon:ScheduleRepeatingTimer("Flasher", 0.25, parent.Roll)
			parent.timerends = addon:ScheduleTimer("FlashEnds",10, parent.Roll)
		end
	end
end

function addon:CreateGlow(self, x)
	self.glow = self:CreateTexture(nil,"OVERLAY")
	self.glow:SetTexture("Interface\\Buttons\\UI-Panel-Button-Glow")
	self.glow:SetTexCoord(0, 0.75, 0, 1)
	self.glow:SetAlpha(1)
	self.glow:SetBlendMode("ADD")
	if x == 1 then
		self.glow:SetPoint("TOPLEFT", self ,"TOPLEFT", -7, 2)
		self.glow:SetPoint("BOTTOMRIGHT", self ,"BOTTOMRIGHT", 7, -9)
	elseif x == 2 then
		self.glow:SetPoint("TOPLEFT", self ,"TOPLEFT", -5, 13)
		self.glow:SetPoint("BOTTOMRIGHT", self ,"BOTTOMRIGHT", 5, -52)
	elseif x == 3 then
		self.glow:SetPoint("TOPLEFT", self ,"TOPLEFT", 0, -155)
		self.glow:SetPoint("BOTTOMRIGHT", self ,"BOTTOMRIGHT", 0, -80)
	end
end

function addon:ZKFRoll(frame)
	RandomRoll(1,100)
	frame:SetNormalTexture("")
	frame:SetDisabledTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
	self:DisableButtons(frame:GetParent())
	self:CancelTimer(frame:GetParent().timer, true)
	self:CancelTimer(frame:GetParent().timerends,true)
	if frame.glow then
		frame.glow:Hide()
	end
end

function addon:ParseWhipers(msg, sender)
	-- If sender is the karma master, there is an active frame which is rolling,
	-- and the whisper is from the KarmaBot, then look at the contents
	if ( sender == self.KarmaMaster and
		 self.activeFrame and self.activeFrame.rolling and
		 msg:find("^KarmaBot:") )
	then
		local bonusing, _, amount = msg:find("Your karma of (%d+) will be added to your roll")

		if bonusing then
			local will_lose = 5*math.ceil(tonumber(amount)/10)
			self.activeFrame.NoticeText:SetText(L["Current Karma"] .. ":\n".. amount .. "\n" .. L["You will lose"] .. ":\n" .. will_lose)
		elseif msg:find("Not using Karma") then
			self.activeFrame.NoticeText:SetText("")
		end
	end
end

function addon:DisableButtons(frame)
	frame.btnBonus:Disable()
	frame.btnNoBonus:Disable()
	frame.btnOffSpec:Disable()
	frame.btnPass:Disable()
	frame.Roll:Disable()
end

function addon:EnableButtons(frame)
	frame.btnBonus:Enable()
	frame.btnNoBonus:Enable()
	frame.btnOffSpec:Enable()
	frame.btnPass:Enable()
	frame.Roll:Enable()
end
