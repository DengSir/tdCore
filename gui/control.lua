
local assert, error, ipairs, pairs, type = assert, error, ipairs, pairs, type
local tdCore = tdCore

local GUI = tdCore('GUI')

local copyTable = tdCore.copyTable

local function mergeTable(dest, src)
    if type(src) ~= 'table' or type(dest) ~= 'table' then
        return src
    end
    
    for k, v in pairs(src) do
        dest[k] = mergeTable(dest[k], v)
    end
    return dest
end

local function getProfile(name)
--    assert(type(name) == 'string')
    if type(name) ~= 'string' then
        return
    end
    
    local addon = tdCore:GetAddon(name)
    if addon then
        return addon:GetProfile()
    else
        return _G[name]
    end
end

local Control = {}
function Control:SetProfile(name, ...)
    assert(type(name) == 'string')
    
    self.__dbname = name
    self.__dbkeys = {...}
end

function Control:GetProfileValue()
    local profile = getProfile(self.__dbname)
    if not profile then
        return
    end
    
    for _, key in ipairs(self.__dbkeys) do
        profile = profile[key]
    end
    if type(profile) == 'table' then
        return copyTable({}, profile)
    else
        return profile
    end
end

function Control:SetProfileValue(value, replace)
    local profile = getProfile(self.__dbname)
    if not profile then
        return
    end
    
    for i, key in ipairs(self.__dbkeys) do
        if i == #self.__dbkeys then
            if type(value) ~= 'table' then
                profile[key] = value
            elseif replace then
                wipe(profile[key])
                copyTable(profile[key], value)
            else
                mergeTable(profile[key], value)
            end
        else
            profile = profile[key]
        end
    end
    
    local addon = tdCore:GetAddon(self.__dbname)
    if addon then
        addon:UpdateProfile()
    end
end

function Control:SetDepend(obj)
    if not GUI:IsWidgetType(obj, 'CheckBox') then
        error('obj must be CheckBox ' .. GUI:GetWidgetType())
    end
    obj:AddDepend(self)
end

GUI:RegisterEmbed('Control', Control)
