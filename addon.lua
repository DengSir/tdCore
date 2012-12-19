
local Addon = tdCore:NewLibrary('Addon', tdCore.Addon, 1)
Addon:RegisterHandle('OnProfileUpdate', 'OnSlashCmd')

local addons = {}

function Addon:New(name, addon, version)
    assert(type(name) == 'string', 'Bad argument #1 to `New\' (string expected)')
    
    if not addons[name] then
        addon = self:Bind(addon or {})
        
        addon.__version = tonumber(version) or tonumber(GetAddOnMetadata(name, 'Version')) or 1
        addon.__name = name
        addon.__title = select(2, GetAddOnInfo(name))
        addon.__modules = {}
        
        addons[name] = addon
    end
    return addons[name]
end

function Addon:Get(name)
    assert(type(name) == 'string', 'Bad argument #1 to `New\' (string expected)')
    
    return addons[name]
end

function Addon:IterateAddons()
    return pairs(addons)
end

function Addon:GetName()
    return self.__name
end

function Addon:GetTitle()
    return self.__title
end

function Addon:GetVersion()
    return self.__version
end

------ module

local Embeds = {
    BaseEmbed = {
        GetAddon = function(obj)
            return obj.__tdaddon
        end,
    },
    
    Event = function(obj)
        obj:SetScript('OnEvent', tdCore.OnEvent)
    end,
    
    Update = {
        StartUpdate = function(obj, onUpdate)
            onUpdate = onUpdate or obj.OnUpdate
            if onUpdate then
                obj:SetScript('OnUpdate', onUpdate)
                obj:Show()
            end
        end,
        StopUpdate = function(obj)
            obj:SetScript('OnUpdate', nil)
        end,
    }
}

local function Embed(self, obj, ...)
    for i = 1, select('#', ...) do
        local name = select(i, ...)
        local embed = self.__embeds and self.__embeds[name] or Embeds[name]
        
        if type(embed) == 'function' then
            embed(obj)
        elseif type(embed) == 'table' then
            for name, method in pairs(embed) do
                obj[name] = method
            end
        end
    end
end

function Addon:NewModule(name, obj, ...)
    assert(type(name) == 'string', 'Bad argument #1 to `NewModule\' (string expected)')
    if not self.__modules[name] then
        obj = tdCore:NewClass(name, type(obj) == 'table' and obj or {})
        obj.__tdaddon = self
        obj:RegisterHandle('OnProfileUpdate')
        
        Embed(self, obj, 'BaseEmbed', ...)
        self.__modules[name] = obj
        
        if obj.Hide and type(obj.Hide) == 'function' then obj:Hide() end
    end
    return self.__modules[name]
end

function Addon:GetModule(name)
    assert(type(name) == 'string', 'Bad argument #1 to `GetModule\' (string expected)')
    
    return self.__modules[name]
end
Addon.__call = Addon.GetModule

function Addon:IterateModules()
    return pairs(self.__modules)
end

function Addon:RegisterEmbed(name, embed)
    assert(type(name) == 'string', 'Bad argument #1 to `RegisterEmbed\' (string expected)')
    assert(type(embed) == 'table' or type(embed) == 'function', 'Bad argument #1 to `RegisterEmbed\' (table or function expected)')
    
    self.__embeds = self.__embeds or {}
    self.__embeds[name] = embed
end

------ locale

function Addon:NewLocale(locale)
    return tdCore.Locale:New(self:GetName(), locale)
end

function Addon:GetLocale()
    return tdCore.Locale:Get(self:GetName())
end

------ db

function Addon:InitDB(name, defaultProfile)
    self.__db = tdCore.DB:New(name, defaultProfile)
    self.__db:NewProfile()
end

function Addon:GetDB()
    return self.__db
end

function Addon:GetProfile()
    return self:GetDB() and self:GetDB():GetCurrentProfile()
end

function Addon:UpdateProfile()
    self:RunHandle('OnProfileUpdate')
    for i, module in self:IterateModules() do
        module:RunHandle('OnProfileUpdate')
    end
end

------ command

function Addon:RegisterCmd(...)
    local name = strupper(self:GetName())
    
    for i = 1, select('#', ...) do
        _G['SLASH_' .. name .. i] = select(i, ...)
    end
    
    SlashCmdList[name] = function(text)
        self:RunHandle('OnSlashCmd', strsplit(' ', (text or ''):lower()))
    end
end
