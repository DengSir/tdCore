
local tdOption = tdCore(...)
local GUI = tdCore('GUI')

local MinimapMenu = tdOption:NewModule('MinimapMenu', GUI('Widget'):New(UIParent, true))

GUI:NewMenu('MinimapMenu', MinimapMenu, 10, true)

MinimapMenu.buttons = {}
MinimapMenu:SetSize(32, 32)
MinimapMenu:SetBackdrop(nil)
MinimapMenu:SetFrameStrata('HIGH')
MinimapMenu:HookScript('OnShow', function(self)
    local orientation = tdOption:GetProfile().minimapOrientation
    if orientation == 'LEFT' or orientation == 'RIGHT' then
        self:SetSize((#self.buttons - 1) * 32, 32)
    else
        self:SetSize(32, (#self.buttons - 1) * 32)
    end
end)

function MinimapMenu:GetPositionArgs()
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

function MinimapMenu:Add(args, addon)
    args.type = 'MinimapButton'
    args.profile = {addon:GetName(), 'minimapAngle'}
    args.angle = addon:GetProfile() and addon:GetProfile().minimapAngle or args.angle or 0
    
    local button = GUI:CreateGUI(args, UIParent, false)
    tinsert(self.buttons, button)
    
    self:SetAllowGroup(self:GetAllowGroup())
    
    return button
end

function MinimapMenu:SetAllowGroup(allow)
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

function MinimapMenu:GetAllowGroup()
    if tdOption:GetProfile() then
        return tdOption:GetProfile().minimapGroup
    else
        return true
    end
end

function MinimapMenu:OnProfileUpdate()
    self:SetAllowGroup(self:GetAllowGroup())
end

function MinimapMenu:OnInit()
    self:SetAllowGroup(tdOption:GetProfile().minimapGroup)
    self:SetHandle('OnProfileUpdate', self.OnProfileUpdate)
end
