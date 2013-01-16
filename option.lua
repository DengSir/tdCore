
local assert, error, ipairs, pairs = assert, error, ipairs, pairs
local tinsert = table.insert

local GUI = tdCore('GUI')
local L = tdCore:GetLocale('tdCore')

local MinimapMenu = GUI:NewMenu('MinimapMenu', GUI('Widget'):New(UIParent, true), 4)
MinimapMenu:SetSize(100, 50)
MinimapMenu.buttons = {}
MinimapMenu:SetScript('OnShow', function(self)
    self:SetWidth(#self.buttons * self.buttons[1]:GetWidth())
end)

local addons = {}

local Option = GUI('MainFrame'):New(UIParent)

function Option:OnDefault()
    local addon = self:GetAddon()
    if not addon then return end
    
    self:ShowDialog(
        'Dialog',
        L['Are you sure to reset the addon |cffff0000[%s]|r configuration file?']:format(addon:GetTitle()) .. (addon.__reloaduiWhileReset and L[' And will reload addon'] or ''),
        GUI.DialogIcon.Warning,
        function()
            addon:GetDB():ResetProfile()
            if addon.__reloaduiWhileReset then
                ReloadUI()
            else
                addon:GetDB():BackupCurrentProfile()
                addon:UpdateProfile()
            end
        end
    )
end

function Option:OnCopyProfile(key)
    local addon = self:GetAddon()
    if not addon then return end
    
    self:ShowDialog(
        'Dialog',
        L['Are you sure overwrites the current configuration file to |cffffffff[%s]|r?']:format(key),
        GUI.DialogIcon.Question,
        function()
            addon:GetDB():CopyProfile(key)
            addon:GetDB():BackupCurrentProfile()
            addon:UpdateProfile()
            self.profileWidget:Update()
        end
    )
end

function Option:OnDeleteProfile(key)
    local addon = self:GetAddon()
    if not addon then return end
    
    self:ShowDialog(
        'Dialog',
        L['Are you sure to delete configuration file |cffffffff[%s]|r?']:format(key),
        GUI.DialogIcon.Warning,
        function()
            addon:GetDB():DeleteProfile(key)
            self.profileWidget:Update()
        end
    )
end

function Option:OnAccept()
    for _, v in ipairs(addons) do
        local db = v.value:GetDB()
        if db then
            db:RemoveBackupProfile()
        end
    end
end

function Option:OnCancel()
    if not self:IsProfileUnSave() then
        return self:OnAccept()
    end
    
    self:ShowDialog(
        'Dialog',
        L['You change the configuration of some addons, you want to save ?'],
        GUI.DialogIcon.Warning,
        function()
            self:OnAccept()
        end,
        function()
            for _, v in pairs(addons) do
                local db = v.value:GetDB()
                if db and db:IsProfileChanged() then
                    db:RestoreCurrentProfile()
                    v.value:UpdateProfile()
                end
            end
        end
    )
end

function Option:OnSettings()
    local addon = self:GetAddon()
    
    addon:GetOption():Hide()
    self.profileWidget:Show()
end

function Option:IsProfileUnSave()
    for _, v in ipairs(addons) do
        local db = v.value:GetDB()
        if db and db:IsProfileChanged() then
            return true
        end
    end
    return false
end

function Option:SetAddon(addon)
    self.profileWidget:Hide()
    
    for _, v in ipairs(addons) do
        if v.value == addon then
            self.currAddon = addon
            
            if addon:GetProfile() then
                self.profileButton:Enable()
            else
                self.profileButton:Disable()
            end
            self.addonList:SetSelected(addon)
            v.value:GetOption():Show()
        else
            v.value:GetOption():Hide()
        end
    end
end

function Option:GetAddon()
    return self.currAddon
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

function Option:Add(gui, title, addon)
    local obj = GUI:CreateGUI(gui)
    
    obj.GetAddon = OptionGetAddon
    obj.GetDB = OptionGetDB
    
    obj.__addon = addon
    obj:Hide()
    obj:SetParent(Option)
    obj:HookScript('OnShow', OptionOnShow)
    obj:ClearAllPoints()
    if obj:IsWidgetType('Widget') then
        obj:SetPoint('BOTTOMRIGHT', -20, 50)
        obj:SetPoint('TOPLEFT', Option.addonList, 'TOPRIGHT', 10, 0)
    elseif obj:IsWidgetType('TabWidget') then
        obj:SetPoint('BOTTOMRIGHT', -19, 49)
        obj:SetPoint('TOPLEFT', Option.addonList, 'TOPRIGHT', 9, 22)
    else
        error('error obj type ' .. obj:GetWidgetType())
    end
    
    tinsert(addons, {text = title, value = addon})
    
    return obj
end

---- Option

do
    Option:Hide()
    Option:SetSize(800, 600)
    Option:SetChildOrientation('HORIZONTAL')
    Option:SetAllowEscape(true)
    Option:SetPadding(20, -20, -50, 50)
    Option:SetLabelText(L['Taiduo\'s Addons'])
    Option:HookScript('OnHide', function(self)
        if self.__accept then
            self:OnAccept()
        else
            self:OnCancel()
        end
    end)
    
    local addonList = GUI('ListWidget'):New(Option)
    addonList:SetWidth(180)
    addonList:SetLabelText(ADDONS)
    addonList:SetItemList(addons)
    addonList:SetSelectMode('RADIO')
    addonList:SetHorizontalArgs(180, 0, 0, 0)
    addonList:SetHandle('OnItemClick', function(self, index)
        Option:SetAddon(self:GetItemValue(index))
    end)
    addonList:Into()
    
    local profileButton = GUI('Button'):New(Option)
    profileButton:SetWidth(130)
    profileButton:SetText(L['Profile manager'])
    profileButton:SetPoint('BOTTOMLEFT', 20, 20)
    profileButton:SetScript('OnClick', function()
        Option:OnSettings()
    end)
    
    local cancelButton = GUI('Button'):New(Option)
    cancelButton:SetText(CANCEL)
    cancelButton:SetPoint('BOTTOMRIGHT', -20, 20)
    cancelButton:SetScript('OnClick', function()
        Option:Hide()
    end)
    
    local acceptButton = GUI('Button'):New(Option)
    acceptButton:SetText(OKAY)
    acceptButton:SetPoint('RIGHT', cancelButton, 'LEFT', -5, 0)
    acceptButton:SetScript('OnClick', function()
        Option.__accept = true
        Option:Hide()
    end)
    
    local profileWidget = GUI('Widget'):New(Option)
    profileWidget:SetPoint('BOTTOMRIGHT', -20, 50)
    profileWidget:SetPoint('TOPLEFT', addonList, 'TOPRIGHT', 10, 0)
    
    function profileWidget:Update()
        self:SetLabelText(Option:GetAddon():GetTitle() .. ' - ' .. L['Profile manager'])
        
        local list = Option:GetAddon():GetDB():GetProfileList()
        
        Option.copyComboBox:SetItemList(list)
        Option.deleteComboBox:SetItemList(list)
    end
    
    profileWidget:SetScript('OnShow', profileWidget.Update)
    
    local copyComboBox = GUI('ComboBox'):New(profileWidget)
    copyComboBox:SetLabelText(L['Copy Profile'])
    copyComboBox:SetValueText(L['Please choose profile ...'])
    copyComboBox:GetValueFontString():SetPoint('LEFT', 10, 0)
    copyComboBox:SetHandle('OnValueChanged', function(self, value)
        Option:OnCopyProfile(value)
    end)
    copyComboBox:Into()
    
    local deleteComboBox = GUI('ComboBox'):New(profileWidget)
    deleteComboBox:SetLabelText(L['Remove Profile'])
    deleteComboBox:SetValueText(L['Please choose profile ...'])
    deleteComboBox:GetValueFontString():SetPoint('LEFT', 10, 0)
    deleteComboBox:SetHandle('OnValueChanged', function(self, value)
        Option:OnDeleteProfile(value)
    end)
    deleteComboBox:Into()
    
    local defaultButton = GUI('Button'):New(profileWidget)
    defaultButton:SetWidth(150)
    defaultButton:SetText(DEFAULTS)
    defaultButton:SetScript('OnClick', function()
        Option:OnDefault()
    end)
    defaultButton:Into()
    
    local returnButton = GUI('Button'):New(profileWidget)
    returnButton:SetWidth(150)
    returnButton:SetText(L['Return addon option'])
    returnButton:SetScript('OnClick', function()
        Option:SetAddon(Option:GetAddon())
    end)
    returnButton:Into()
    
    Option.addonList = addonList
    Option.profileButton = profileButton
    Option.copyComboBox = copyComboBox
    Option.deleteComboBox = deleteComboBox
    Option.profileWidget = profileWidget
end

---- Addon

local Addon = tdCore.Addon

function Addon:InitMinimap(args, isparent)
    assert(type(args) == 'table', 'Bad argument #1 to `InitMinimap\' (table expected)')
    
    args.type = 'MinimapButton'
--    args.profile = {self:GetName(), 'minimapangle'}
--    args.angle = self:GetProfile() and self:GetProfile().minimapangle or args.angle
    args.verticalArgs = {40, 0, 0}
    
    self.__minimap = GUI:CreateGUI(args, isparent and Minimap or MinimapMenu, false)
    tinsert(MinimapMenu.buttons, self.__minimap)
end

function Addon:GetMinimap()
    return self.__minimap
end

function Addon:InitOption(gui, title)
    assert(type(gui) == 'table', 'Bad argument #1 to `InitOption\' (string expected)')
    
    self.__option = Option:Add(gui, title or self:GetTitle(), self)
end

function Addon:GetOptionControl(name)
    return self:GetOption():GetControl(name)
end

function Addon:GetOption()
    return self.__option
end

function Addon:ToggleOption()
    if self:GetOption():IsVisible() then
        Option:Hide()
    else
        Option:SetAddon(self)
        Option:Show()
    end
end

function Addon:UpdateOption()
    self:GetOption():Update()
end

GUI:RegisterCmd('/td', '/taiduo', '/taiduooption', '/tdoption')
GUI:SetHandle('OnSlashCmd', GUI.ToggleOption)
GUI:InitOption({
    type = 'TabWidget',
    {
        type = 'Widget', label = L['About'], name = 'AboutWidget',
    },
    {
        type = 'Widget', label = L['Config'],
        {
            type = 'CheckBox', label = L['Hide minimap button'],
        },
    },
}, L['About'])

GUI:InitMinimap({
    note = {L['Taiduo\'s Addons']}, itemList = addons, angle = 0,
    scripts = {
        OnCall = function()
            GUI:ToggleMenu(GUI:GetMinimap(), 'MinimapMenu')
        end,
        OnMenu = function(self, addon)
            addon:ToggleOption()
        end,
    }
}, true)


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
            self:HighlightText(0, self.text:len())
        end
    end

    local function OnEditFocusGained(self)
        self:HighlightText(0, self.text:len())
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
    
    CreateLabel(L['Addon Name:'],       'GameFontNormalSmall', 'TOPLEFT', 50, -50)
    CreateLabel(L['Addon Version:'],    'GameFontNormalSmall', 'TOPLEFT', 50, -100)
    CreateLabel(L['Addon Author:'],     'GameFontNormalSmall', 'TOPLEFT', 50, -150)
    CreateLabel('Email:',               'GameFontNormalSmall', 'TOPLEFT', 50, -200)
    CreateLabel('GitHub:',              'GameFontNormalSmall', 'TOPLEFT', 50, -250)
    CreateLabel(L['Tencent Weibo:'],    'GameFontNormalSmall', 'TOPLEFT', 50, -300)
    CreateLabel(L['Sina Weibo:'],       'GameFontNormalSmall', 'TOPLEFT', 50, -350)
    
    CreateLabel(L['Taiduo\'s Addons'],                  'GameFontHighlightSmall', 'TOPLEFT', 200, -50)
    CreateLabel(GetAddOnMetadata('tdCore', 'Version'),  'GameFontHighlightSmall', 'TOPLEFT', 200, -100)
    CreateLabel(GetAddOnMetadata('tdCore', 'Author'),   'GameFontHighlightSmall', 'TOPLEFT', 200, -150)
    CreateEditbox('ldz5@qq.com',                    'TOPLEFT', 192, -200)
    CreateEditbox('http://github.com/dengsir',      'TOPLEFT', 192, -250)
    CreateEditbox('http://t.qq.com/taiduo_ldz',     'TOPLEFT', 192, -300)
    CreateEditbox('http://www.weibo.com/tdaddon',   'TOPLEFT', 192, -350)
end
