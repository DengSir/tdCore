
local assert, error, pairs, type = assert, error, pairs, type
local format, strlen = string.format, string.len
local tinsert = table.insert
local tdCore = tdCore

local GUI = tdCore('GUI')
local L = tdCore:GetLocale('tdCore')
 
local addons = {}
local options = {}

local OptionFrame = GUI:CreateGUI({
    type = 'MainFrame', label = L['Taiduo\'s Addons'], allowEscape = true,
    width = 800, height = 600, orientation = 'HORIZONTAL',
    padding = {20, -20, -50, 50},
    {
        type = 'ListWidget', label = ADDONS, itemList = addons, selectMode = 'RADIO', 
        width = 180, horizontalArgs = {180, 0, 0, 0}, name = 'AddonsList',
        scripts = {
            OnItemClick = function(self, index)
                self:GetParent():SetAddon(self:GetItemValue(index))
            end,
        }
    },
    {
        type = 'Button', label = DEFAULTS, name = 'ButtonDefault',
        point = {'BOTTOMLEFT', 20, 20},
        scripts = {
            OnClick = function(self)
                self:GetParent():OnDefault()
            end,
        }
    },
    {
        type = 'Button', label = CANCEL,
        point = {'BOTTOMRIGHT', -20, 20},
        scripts = {
            OnClick = function(self)
                self:GetParent():Hide()
            end,
        }
    },
    {
        type = 'Button', label = OKAY,
        point = {'BOTTOMRIGHT', -125, 20},
        scripts = {
            OnClick = function(self)
                self:GetParent().__okay = true
                self:GetParent():Hide()
            end,
        },
    },
})

OptionFrame.addonList = OptionFrame:GetControl('AddonsList')

OptionFrame:HookScript('OnHide', function()
    if OptionFrame.__okay then
        OptionFrame:OnOkay()
    else
        OptionFrame:OnCancel()
    end
    OptionFrame.__okay = nil
end)

function OptionFrame:GetAddon()
    return self.__currentAddon
end

function OptionFrame:SetAddon(opt)
    for k, obj in pairs(options) do
        if obj == opt then
            self.addonList:SetSelected(opt)
            self.__currentAddon = obj:GetAddon()
            if obj:GetAddon():GetProfile() then
                self:GetControl('ButtonDefault'):Enable()
            else
                self:GetControl('ButtonDefault'):Disable()
            end
            obj:Show()
        else
            obj:Hide()
        end
    end
end

function OptionFrame:OnOkay()
    for _, obj in pairs(options) do
        local db = obj:GetDB()
        if db then
            db:RemoveBackupProfile()
        end
    end
end

function OptionFrame:OnCancel()
    local unsave = false
    for _, obj in pairs(options) do
        local db = obj:GetDB()
        if db and db:IsProfileChanged() then
            unsave = true
            break
        end
    end
    if not unsave then return end
    
    GUI:ShowMenu('DialogMenu', nil, nil,
        {
            mode = GUI.DialogIcon.Warning,
            label = L['You change the configuration of some addons, you want to save ?'],
            buttons = {GUI.DialogButton.Save, GUI.DialogButton.Ignore},
            func = function(result)
                if result ~= GUI.DialogButton.Save then
                    for _, obj in pairs(options) do
                        local db = obj:GetDB()
                        if db and db:IsProfileChanged() then
                            db:RestoreCurrentProfile()
                            obj:GetAddon():UpdateProfile()
                        end
                    end
                end
            end,
        })
end

function OptionFrame:OnDefault()
    local addon = self:GetAddon()
    if not addon then return end
    
    GUI:ShowMenu('DialogMenu', self, nil,
        {
            mode = GUI.DialogIcon.Question,
            label = L['Are you sure to reset the addon |cffff0000[%s]|r configuration file?']:format(addon:GetTitle()),
            buttons = {GUI.DialogButton.Reset, GUI.DialogButton.Cancel},
            func = function(result)
                if result == GUI.DialogButton.Reset and addon:GetDB() then
                    local db = addon:GetDB()
                    if db then
                        db:ResetProfile()
                        addon:UpdateProfile()
                        addon:GetOption():Update()
                        db:BackupCurrentProfile()
                    end
                end
            end,
        })
end

local function OptionOnShow(self)
    self:Update()
    
    local db = self:GetDB()
    if db then
        db:BackupCurrentProfile()
    end
end

local function OptionGetAddon(self)
    return self.__addon
end

local function OptionGetDB(self)
    return self.__addon and self.__addon:GetDB()
end

local function OptionGetTitle(self)
    return 
end

local Addon = tdCore.Addon

function Addon:InitOption(gui, title)
    assert(type(gui) == 'table', 'Bad argument #1 to `InitOption\' (string expected)')
    
    local obj = GUI:CreateGUI(gui)
    
    self.__option = obj
    obj.__addon = self
    
    obj.GetAddon = OptionGetAddon
    obj.GetDB = OptionGetDB
    
    obj:HookScript('OnShow', OptionOnShow)
    obj:SetParent(OptionFrame)
    
    obj:ClearAllPoints()
    
    if obj:IsWidgetType('Widget') then
        obj:SetPoint('BOTTOMRIGHT', -20, 50)
        obj:SetPoint('TOPLEFT', OptionFrame.addonList, 'TOPRIGHT', 10, 0)
    elseif obj:IsWidgetType('TabWidget') then
        obj:SetPoint('BOTTOMRIGHT', -19, 49)
        obj:SetPoint('TOPLEFT', OptionFrame.addonList, 'TOPRIGHT', 9, 22)
    else
        error('error obj type ' .. obj:GetWidgetType())
    end
    
    title = title or self:GetTitle()

    tinsert(addons, {text = title, value = obj})
    options[title] = obj
end

function Addon:GetOptionControl(name)
    return self:GetOption():GetControl(name)
end

function Addon:IsOptionOpened()
    return self:GetOption():IsVisible()
end

function Addon:GetOption()
    return self.__option
end

function Addon:ToggleOption()
    if self:IsOptionOpened() then
        OptionFrame:Hide()
    else
        OptionFrame:SetAddon(self:GetOption())
        OptionFrame:Show()
    end
end

function Addon:UpdateOption()
    self:GetOption():Update()
end

GUI:RegisterCmd('/td', '/taiduo', '/taiduooption', '/tdoption')
GUI:SetHandle('OnSlashCmd', GUI.ToggleOption)
GUI:InitOption({
    type = 'Widget', label = L['About'], name = 'AboutWidget',
}, L['About'])

do
    local widget = GUI:GetOptionControl('AboutWidget')
    
    local function CreateLabel(text, fontObject, ...)
        local label = widget:CreateFontString(nil, 'OVERLAY', fontObject)
        
        label:SetText(text)
        label:SetPoint(...)
    end
    
    local function OnTextChanged(self)
        if self:GetText() ~= self.text then
            self:SetText(self.text)
        end
        if self:HasFocus() then
            self:HighlightText(0, strlen(self.text))
        end
    end

    local function OnEditFocusGained(self)
        self:HighlightText(0, strlen(self.text))
    end

    local function OnEditFocusLost(self)
        self:HighlightText(0, 0)
        if not self:IsMouseOver() then
            self:SetBackdrop({})
        end
    end

    local function OnEnter(self)
        self:SetBackdrop({
            bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
            edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
            edgeSize = 14, tileSize = 20, tile = true,
            insets = {left = 2, right = 2, top = 2, bottom = 2}
        })
        self:SetBackdropColor(0, 0, 0, 0.4)
    end

    local function OnLeave(self)
        if not self:HasFocus() then
            self:SetBackdrop({})
        end
    end
    
    local function CreateEditbox(text, ...)
        local editbox = CreateFrame('Editbox', nil, widget)
        
        editbox:SetFontObject('GameFontHighlightSmall')
        editbox:SetTextInsets(8, 8, 0, 0)
        editbox:SetAutoFocus(false)
        editbox:SetSize(250, 20)
        editbox:SetScript('OnTextChanged', OnTextChanged)
        editbox:SetScript('OnEditFocusGained', OnEditFocusGained)
        editbox:SetScript('OnEditFocusLost', OnEditFocusLost)
        editbox:SetScript('OnEscapePressed', editbox.ClearFocus)
        editbox:SetScript('OnEnterPressed', editbox.ClearFocus)
        editbox:SetScript('OnEnter', OnEnter)
        editbox:SetScript('OnLeave', OnLeave)
        editbox:SetScript('OnMouseUp', OnEditFocusGained)
        editbox:HighlightText(0, 0)
        
        editbox.text = text
        editbox:SetText(text)
        editbox:SetPoint(...)
    end
    
    CreateLabel(L['Addon Name:'],    'GameFontNormalSmall', 'TOPLEFT', 50, -50)
    CreateLabel(L['Addon Version:'], 'GameFontNormalSmall', 'TOPLEFT', 50, -100)
    CreateLabel(L['Addon Author:'],  'GameFontNormalSmall', 'TOPLEFT', 50, -150)
    CreateLabel(L['Author Email:'],  'GameFontNormalSmall', 'TOPLEFT', 50, -200)
    CreateLabel(L['Author Weibo:'],  'GameFontNormalSmall', 'TOPLEFT', 50, -250)
    CreateLabel(L['Author GitHub:'],    'GameFontNormalSmall', 'TOPLEFT', 50, -300)
    
    CreateLabel(GetAddOnInfo('tdCore'),                 'GameFontHighlightSmall', 'TOPLEFT', 200, -50)
    CreateLabel(GetAddOnMetadata('tdCore', 'Version'),  'GameFontHighlightSmall', 'TOPLEFT', 200, -100)
    CreateLabel(GetAddOnMetadata('tdCore', 'Author'),   'GameFontHighlightSmall', 'TOPLEFT', 200, -150)
    CreateEditbox('ldz5@qq.com',                'TOPLEFT', 192, -200)
    CreateEditbox('http://t.qq.com/taiduo_ldz', 'TOPLEFT', 192, -250)
    CreateEditbox('http://github.com/dengsir',  'TOPLEFT', 192, -300)
end
