
local tdOption = tdCore(...)
local GUI = tdCore('GUI')

local MinimapGroup = tdOption:NewModule('MinimapGroup', GUI('Widget'):New(UIParent, true))
MinimapGroup.buttons = {}
MinimapGroup:SetSize(32, 32)
MinimapGroup:HookScript('OnShow', function(self)
    self:SetHeight((#self.buttons - 1) * 32)
end)

GUI:NewMenu('MinimapMenu', MinimapGroup, 2)

function MinimapGroup:Add(args, addon)
    args.type = 'MinimapButton'
    args.profile = {addon:GetName(), 'minimapAngle'}
    args.angle = addon:GetProfile() and addon:GetProfile().minimapAngle or args.angle or 0
    
    tinsert(self.buttons, GUI:CreateGUI(args, UIParent, false))
    
    self:SetAllowGroup(self:GetAllowGroup())
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
                    button:SetPoint('TOPLEFT', self.buttons[i-1], 'BOTTOMLEFT')
                end
            else
                button:SetParent(Minimap)
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

function MinimapGroup:OnInit()
    self:SetAllowGroup(tdOption:GetProfile().minimapGroup)
end
