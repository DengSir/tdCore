
local GUI = tdCore('GUI')

local InputDialog = GUI:NewModule('InputDialog', GUI('Dialog'):New())

local function DialogButtonOnClick(self)
    self:GetParent():SetResultHandle(self.handle)
    self:GetParent():Hide()
end

function InputDialog:New(parent)
    local obj = self:Bind(GUI('Dialog'):New(parent))
    if parent then
        local lineedit = GUI('LineEdit'):New(obj)
        lineedit:SetPoint('BOTTOMLEFT', obj.accept, 'TOPLEFT', 0, 5)
        lineedit:SetPoint('RIGHT', -64, 0)
        lineedit:Show()
        
        obj.lineedit = lineedit
    end
    return obj
end

function InputDialog:GetResultValue()
    return self.lineedit:GetText()
end

function InputDialog:GetShowHeight()
    return GUI('Dialog').GetShowHeight(self) + self.lineedit:GetHeight() + 5
end
