
local pairs, ipairs, next, type, format = pairs, ipairs, next, type, string.format

local DB = tdCore:NewLibrary('DB', tdCore.DB, 1)

local UnitName = UnitName or function() return 'player' end
local GetRealmName = GetRealmName or function() return 'realmname' end

local PROFILE_KEY = format('%s - %s', UnitName('player'), GetRealmName())

local function copyTable(tbl, defaults)
    for k, v in pairs(defaults) do
        if type(v) == 'table' then
            tbl[k] = copyTable(tbl[k] or {}, v)
        elseif tbl[k] == nil then
            tbl[k] = v
        end
    end
    return tbl
end

local function removeTable(tbl, defaults)
    for k, v in pairs(defaults) do
        if type(tbl[k]) == 'table' and type(v) == 'table' then
            removeTable(tbl[k], v)
            if next(tbl[k]) == nil then
                tbl[k] = nil
            end
        elseif tbl[k] == v then
            tbl[k] = nil
        end
    end
    return tbl
end

function DB:New(name, defaultProfile)
    local db = self:Bind({})
    
    _G[name] = _G[name] or {}
    
    db.__db = _G[name]
    db.__name = name
    db.__defaultProfile = defaultProfile
    
    return db
end

function DB:GetName()
    return self.__name
end

function DB:GetDefaultProfile()
    return self.__defaultProfile
end

function DB:GetCurrentProfile()
   return self.__profile
end

function DB:NewProfile()
    self.__db[PROFILE_KEY] = copyTable(self.__db[PROFILE_KEY] or {}, self:GetDefaultProfile())
    self.__profile = self.__db[PROFILE_KEY]
    
    return self.__profile
end

function DB:DeleteProfile(key)
    self.__db[key] = nil
end

function DB:ResetProfile()
    local profile = self.__profile
    self.__db[PROFILE_KEY] = copyTable({}, self:GetDefaultProfile())
    self.__profile = self.__db[PROFILE_KEY]
    wipe(profile)
end

function DB:RemoveBackupProfile()
    if type(self.__backupProfile) == 'table' then
        wipe(self.__backupProfile)
        self.__backupProfile = nil
    end
end

function DB:BackupCurrentProfile()
    if type(self.__profile) == 'table' then
        self.__backupProfile = copyTable({}, self.__profile)
    end
end

function DB:RestoreCurrentProfile()
    if type(self.__backupProfile) == 'table' then
        self.__db[PROFILE_KEY], self.__backupProfile = self.__backupProfile, self.__db[PROFILE_KEY]
        self.__profile = self.__db[PROFILE_KEY]
        self:RemoveBackupProfile()
    end
end

local function isProfileSame(a, b)
    if type(a) ~= type(b) then
        return false
    end
    
    if type(a) == 'table' then
        if #a ~= #b then
            return false
        end
        
        for k, v in pairs(b) do
            if not isProfileSame(a[k], v) then
                return false
            end
        end
        
        for k, v in pairs(a) do
            if not isProfileSame(b[k], v) then
                return false
            end
        end
        return true
    end
    return a == b
end

function DB:IsProfileChanged()
    if not self.__backupProfile then
        return
    end
    return not isProfileSame(self.__backupProfile, self.__profile)
end

function DB:IterateProfiles()
    return pairs(self.__db)
end

function DB:RemoveDefault()
    removeTable(self:GetCurrentProfile(), self:GetDefaultProfile())
end
