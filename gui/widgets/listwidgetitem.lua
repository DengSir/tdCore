
local GUI = tdCore('GUI')
local L = GUI:GetLocale()

local ListWidgetItem = GUI:NewModule('ListWidgetItem', CreateFrame('CheckButton'), 'UIObject')
ListWidgetItem:RegisterHandle('OnSetValue')

local function OnClick(self, button)
    if button == 'LeftButton' then
        PlaySound('igMainMenuOptionCheckBoxOn')
        if type(self.__onClick) == 'function' then
            self:__onClick()
        end
        
        local parent = self:GetParent()
        parent:RunHandle('OnItemClick', self:GetIndex())
        parent:SetSelected(self:GetIndex(), not parent:GetSelected(self:GetIndex()))
    elseif button == 'RightButton' then
        self:SetChecked(not self:GetChecked())
        
        --[[
        GUI:ShowMenu('ComboMenu', self:GetParent(), 'cursor', {
            {
                text = ADD, onClick = function(self, index)
                end,
            },
            {
                text = L['Select All'], onClick = function(self, index)
                    self:GetParent():GetCaller():SelectAll(true)
                end,
            },
            {
                text = L['Select None'], onClick = function(self, index)
                    self:GetParent():GetCaller():SelectAll(false)
                end,
            },
            {
                text = L['Delete selected'], onClick = function(self, index)
                    
                end,
            },
        })
        --]]
    end
end

local function OnDragStart(self)
    self:GetParent():ButtonStartMoving(self)
end

local function OnDragStop(self)
    self:GetParent():ButtonStopMoving(self)
end

function ListWidgetItem:New(parent)
    local obj = self:Bind(CreateFrame('CheckButton', nil, parent))
    obj:Hide()
    
    if GUI:IsWidgetType(parent, 'ListWidget') then
        obj:GetLabelFontString():SetPoint('LEFT', 5, 0)
        obj:SetFontString(obj:GetLabelFontString())
        obj:SetNormalFontObject('GameFontNormalSmall')
        obj:SetHighlightFontObject('GameFontHighlightSmall')
        
        obj:SetHighlightTexture([[Interface\QuestFrame\UI-QuestLogTitleHighlight]])
        obj:SetCheckedTexture([[Interface\QuestFrame\UI-QuestLogTitleHighlight]])
        
        obj:GetHighlightTexture():SetVertexColor(0.196, 0.388, 0.8)
        obj:GetCheckedTexture():SetVertexColor(0.82, 0.5, 0)
        
        obj:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
        obj:SetScript('OnClick', OnClick)
        
        if parent:GetAllowOrder() then
            obj:SetToplevel(true)
            obj:RegisterForDrag('LeftButton')
            
            obj:SetScript('OnDragStart', OnDragStart)
            obj:SetScript('OnDragStop', OnDragStop)
        end
    end
    return obj
end

function ListWidgetItem:SetIndex(index)
    self.__idx = index
end

function ListWidgetItem:GetIndex()
    return self.__idx
end

function ListWidgetItem:GetValue()
    return self.__value or self:GetText()
end

function ListWidgetItem:SetValue(value)
    self.__value = value
end

function ListWidgetItem:SetClick(onClick)
    self.__onClick = onClick
end

---- ListWidgetLinkItem

local ListWidgetLinkItem = GUI:NewModule('ListWidgetLinkItem', ListWidgetItem:New(), 'Update')

function ListWidgetLinkItem:New(parent)
    local obj = self:Bind(ListWidgetItem:New(parent))
    if parent then
        obj:SetAllowEnter(true)
    end
    return obj
end

local linktypes = {
    item = true,
    enchant = true,
    spell = true,
    quest = true,
    unit = true,
    talent = true,
    achievement = true,
    glyph = true,
    instancelock = true
}

function ListWidgetLinkItem:OnUpdate()
    self:SetText(self.__text)
end

function ListWidgetLinkItem:GetInfo(text)
    local linkType, id
    if type(text) == 'number' then
        linkType, id = 'item', text
    elseif type(text) == 'string' then
        linkType, id = text:match('^(.+):(%d+)$')
    end
    if not linkType then
        return text
    end
    
    if linkType == 'item' then
        local itemName, itemLink, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(id)
        if not itemName then
            self:StartUpdate()
            return
        end
        
        local r, g, b = GetItemQualityColor(itemQuality)
        return ('|T%s:18|t |cff%02x%02x%02x%s|r'):format(itemTexture, (r or 1) * 0xff, (g or 1) * 0xff, (b or 1) * 0xff, itemName), itemLink
    elseif linkType == 'spell' then
        return (GetSpellLink(id))
    elseif linkType == 'quest' then
    
    elseif linkType == '' then
    
    elseif linkType == '' then
    
    else
    
    end
end

function ListWidgetLinkItem:SetText(text)
    self.__text = text
    
    local text, link = self:GetInfo(text)
    if text then
        self.__link = link
        self:GetLabelFontString():SetText(text)
    end
end

function ListWidgetLinkItem:OnEnter()
    if self.__link then
        GameTooltip:SetHyperlink(self.__link)
    end
end
