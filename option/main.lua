
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
    self:InitDB('TDDB_TDCORE', {minimapGroup = true, minimapAngle = -253})
    self:RegisterCmd('/taiduo', '/td')
    self:SetHandle('OnSlashCmd', self.ToggleOption)
    self:InitOption({
        type = 'TabWidget',
        {
            type = 'Widget', label = 'About',
        },
        {
            type = 'Widget', label = 'Config',
        },
    }, 'About')
    
    self:InitMinimap({
        itemList = self('Frame'):GetAddonList(),
        note = {L['Taiduo\'s Addons']},
        icon = [[Interface\MacroFrame\MacroFrame-Icon]],
        scripts = {
            OnCall = function(self)
                self:ToggleMenu('MinimapMenu')
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
    
    for i = 1, 10 do
        tdCore:NewAddon('Addon' .. i):InitMinimap{}
    end
end
