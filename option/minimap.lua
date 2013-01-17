
local tdOption = tdCore(...)
local GUI = tdCore('GUI')

local MinimapGroup = tdOption:NewModule('MinimapGroup', GUI('Widget'):New(UIParent, true))
GUI:NewMenu('MinimapMenu', MinimapGroup, 10, true)
MinimapGroup.buttons = {}
MinimapGroup:SetSize(32, 32)
MinimapGroup:SetBackdrop(nil)
MinimapGroup:SetFrameStrata('HIGH')
MinimapGroup:HookScript('OnShow', function(self)
    self:SetWidth((#self.buttons - 1) * 32)
end)

function MinimapGroup:GetPositionArgs()
    local orientation = tdOption:GetProfile().minimapOrientation
    if orientation == 'LEFT' then
        return 'RIGHT', self:GetCaller(), 'LEFT'
    elseif orientation == 'RIGHT' then
        return 'LEFT', self:GetCaller(), 'RIGHT'
    elseif orientation == 'TOP' then
        return 'BOTTOM', self:GetCaller(), 'TOP'
    else
        return 'TOP', self:GetCaller(), 'BOTTOM'
    end
end

function MinimapGroup:Add(args, addon)
    args.type = 'MinimapButton'
    args.profile = {addon:GetName(), 'minimapAngle'}
    args.angle = addon:GetProfile() and addon:GetProfile().minimapAngle or args.angle or 0
    
    local button = GUI:CreateGUI(args, UIParent, false)
    tinsert(self.buttons, button)
    
    self:SetAllowGroup(self:GetAllowGroup())
    
    return button
end

function MinimapGroup:SetAllowGroup(allow)
    for i, button in ipairs(self.buttons) do
        if i == 1 then
            button:SetAllowGroup(false)
            button:Update()
        else
            button:SetAllowGroup(allow)
            if allow then
                button:SetParent(self)
                button:ClearAllPoints()
                if i == 2 then
                    button:SetPoint('TOPLEFT')
                else
                    button:SetPoint('TOPLEFT', self.buttons[i-1], 'TOPRIGHT')
                end
            else
                button:SetParent(Minimap)
                button:SetFrameLevel(Minimap:GetFrameLevel() + 10)
                button:Update()
            end
        end
    end
end

function MinimapGroup:GetAllowGroup()
    if tdOption:GetProfile() then
        return tdOption:GetProfile().minimapGroup
    else
        return true
    end
end

function MinimapGroup:OnProfileUpdate()
    self:SetAllowGroup(self:GetAllowGroup())
end

function MinimapGroup:OnInit()
    self:SetAllowGroup(tdOption:GetProfile().minimapGroup)
    self:SetHandle('OnProfileUpdate', self.OnProfileUpdate)
end
