
local GUI = tdCore('GUI')
local L = tdCore:GetLocale('tdCore')

local ListWidgetButton = GUI:NewModule('ListWidgetButton', CreateFrame('Button'), 'UIObject')

local ListButtonTexture = {
    Add = [[Interface\AddOns\tdCore\gui\media\add.tga]],
    Delete = [[Interface\AddOns\tdCore\gui\media\delete.tga]],
    SelectAll = [[Interface\AddOns\tdCore\gui\media\all.tga]],
    SelectNone = [[Interface\AddOns\tdCore\gui\media\none.tga]],
}

local ListButtonNote = {
    Add = ADD,
    Delete = DELETE,
    SelectAll = L['Select all'],
    SelectNone = L['Select none']
}

function ListWidgetButton:New(parent, type)
    assert(GUI.ListButton[type], 'Bad argument')
    
    local obj = self:Bind(CreateFrame('Button', nil, parent))
    
    obj.handle = 'On' .. type
    
    obj:SetScript('OnClick', self.OnClick)
    obj:SetNote(ListButtonNote[type])
    
    obj:SetNormalTexture(ListButtonTexture[type])
    obj:SetHighlightTexture(ListButtonTexture[type])
    
    return obj
end

function ListWidgetButton:OnClick()
    self:GetParent():RunHandle(self.handle)
end
