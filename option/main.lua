
local tdOption = tdCore:NewAddon(...)
local L = tdCore:GetLocale('tdCore')

local Addon = tdCore.Addon

function Addon:InitOption(gui, title)
    self.__option = tdOption('Option'):New(gui, self, title)
end

function Addon:ToggleOption()
    if self:GetOption():GetFrame():IsVisible() then
        tdOption('Frame'):Hide()
    else
        tdOption('Frame'):SetOption(self:GetOption())
        tdOption('Frame'):Show()
    end
end

function Addon:GetOption()
    return self.__option
end

function Addon:InitMinimap(args)
    self.__minimap = tdOption('MinimapGroup'):Add(args, self)
end

function Addon:GetMinimap()
    return self.__minimap
end

function tdOption:OnInit()
    self:InitDB('TDDB_TDCORE', {minimapGroup = true, minimapAngle = -253, minimapOrientation = 'LEFT'})
    self:RegisterCmd('/taiduo', '/td')
    self:SetHandle('OnSlashCmd', self.ToggleOption)
    self:InitOption({
        type = 'TabWidget',
        {
            type = 'Widget', label = L['About'], name = 'AboutWidget',
        },
        {
            type = 'Widget', label = L['Config'],
            {
                type = 'CheckBox', label = L['Pack mini map buttons'], name = 'PackMinimapCheckBox',
                profile = {self:GetName(), 'minimapGroup'}
            },
            {
                type = 'ComboBox', label = L['Mini map orientation'], depend = 'PackMinimapCheckBox',
                profile = {self:GetName(), 'minimapOrientation'},
                itemList = {
                    {text = L['Left'], value = 'LEFT'},
                    {text = L['Right'], value = 'RIGHT'},
                    {text = L['Top'], value = 'TOP'},
                    {text = L['Bottom'], value = 'BOTTOM'},
                }
            },
        },
    }, L['About'])
    
    self:InitMinimap({
        itemList = self('Frame'):GetAddonList(),
        note = {L['Taiduo\'s Addons']},
        icon = [[Interface\MacroFrame\MacroFrame-Icon]],
        scripts = {
            OnCall = function(self)
                tdOption:ToggleOption()
            end,
            OnMenu = function(o, option)
                option:GetAddon():ToggleOption()
            end,
            OnEnter = function(self)
                tdOption('MinimapGroup'):Hide()
                self:ToggleMenu('MinimapMenu')
            end,
        }
    })
    
    local widget = self:GetOption():GetFrame():GetControl('AboutWidget')
    
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
