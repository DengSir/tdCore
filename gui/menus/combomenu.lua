
local GUI = tdCore('GUI')

local ListWidget = GUI('ListWidget')

local ComboMenu = GUI:NewMenu('ComboMenu', ListWidget:New(UIParent))

function ComboMenu:OnItemClick(index)
    local caller = self:GetCaller()
    if caller and type(caller.SetValue) == 'function' then
        caller:SetValue(self:GetItemValue(index))
    end
    self:Hide()
end

function ComboMenu:SetMenuArgs(itemList)
    self:SetItemList(itemList)
end

do
    ComboMenu:SetAutoSize(true)
    ComboMenu:SetMaxCount(20)
    ComboMenu:SetItemHeight(20)
    ComboMenu:SetHandle('OnItemClick', function(self, index)
        local caller = self:GetCaller()
        if caller and type(caller.SetValue) == 'function' then
            caller:SetValue(self:GetItemValue(index))
        end
        self:Hide()
    end)
end