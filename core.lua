
local lib, version = 'tdCore', 1

if _G[lib] and _G[lib].version >= version then return end

local rawget, setmetatable = rawget, setmetatable

_G[lib] = CreateFrame('Frame')

local tdCore = _G[lib]
tdCore:Hide()

tdCore.Addon = {}
tdCore.Locale = {}
tdCore.DB = {}

function tdCore:OnEvent(event, ...)
    if self[event] then
        self[event](self, event, ...)
    end
end

function tdCore:NewAddon(name, addon, version)
    return self.Addon:New(name, addon, version)
end

function tdCore:GetAddon(name)
    return self.Addon:Get(name)
end

function tdCore:NewLocale(name, locale)
    return self.Locale:New(name, locale)
end

function tdCore:GetLocale(name)
    return self.Locale:Get(name)
end

function tdCore:IterateAddons()
    return self.Addon:IterateAddons()
end

function tdCore:ADDON_LOADED(event, name)
    local addon = self:GetAddon(name)
    if addon then
        if addon.OnInit then
            addon:OnInit()
        end
        
        for _, module in addon:IterateModules() do
            if module.OnInit then
                module:OnInit()
            end
        end
    end
end

function tdCore:PLAYER_LOGOUT()
    for _, addon in self:IterateAddons() do
        addon:GetDB():RemoveDefault()
    end
end

tdCore:SetScript('OnEvent', tdCore.OnEvent)
tdCore:RegisterEvent('ADDON_LOADED')
tdCore:RegisterEvent('PLAYER_LOGOUT')

tdCore.__call = tdCore.GetAddon
setmetatable(tdCore, tdCore)
