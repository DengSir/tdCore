
local GUI = tdCore('GUI')

local MinimapButton = GUI:NewModule('MinimapButton', CreateFrame('Button'), 'UIObject', 'Control', 'Update')

function MinimapButton:New()
    local obj = self:Bind(CreateFrame('Button', nil, Minimap))
    
    obj:SetMovable(true)
    obj:RegisterForDrag('LeftButton')
    obj:SetFrameStrata('DIALOG')
    obj:SetSize(32, 32)
    obj:SetScript('OnDragStart', self.OnDragStart)
    obj:SetScript('OnDragStop', self.OnDragStop)
    obj:SetScript('OnShow', self.Update)
    
    obj:SetHighlightTexture([[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]])
    
    local t = obj:CreateTexture(nil, 'BACKGROUND')
    t:SetTexCoord(0.09375, 0.90625, 0.46875, 0.89375)
    t:SetSize(20, 20)
    t:SetPoint('CENTER', -1, 1)
    self.__icon = t
    
    t = obj:CreateTexture(nil, 'ARTWORK')
    t:SetTexture([[Interface\Minimap\MiniMap-TrackingBorder]])
    t:SetSize(52, 52)
    t:SetPoint('TOPLEFT')
    
    return obj
end

function MinimapButton:SetAngle(angle)
    local mapScale = Minimap:GetEffectiveScale()
    local scale = self:GetEffectiveScale()
    self:ClearAllPoints()
    self:SetPoint('CENTER', Minimap, 'TOPRIGHT', (sin(angle) * 80 - 70) * mapScale / scale, (cos(angle) * 77 - 73) * mapScale / scale)
end

function MinimapButton:GetAngle()
    local mapScale = Minimap:GetEffectiveScale()
    local cx, cy = GetCursorPosition()
    local x, y = (Minimap:GetRight() - 70) * mapScale, (Minimap:GetTop() - 70) * mapScale
    
    return atan2(cy - y, x - cx) - 90
end

function MinimapButton:OnUpdate()
    self:SetAngle(self:GetAngle())
end

function MinimapButton:OnDragStart()
    if IsShiftKeyDown() then
        self:StartUpdate()
        self:StartMoving()
    end
end

function MinimapButton:OnDragStop()
    self:StopUpdate()
    self:StopMovingOrSizing()
    
    self:SetProfileValue(self:GetAngle())
end

function MinimapButton:Update()
    self:SetAngle(self:GetProfileValue() or 0)
end

function MinimapButton:SetIcon(texture)
    self.__icon:SetTexture(texture)
end
