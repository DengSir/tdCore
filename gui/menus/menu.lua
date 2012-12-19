
local GUI = tdCore('GUI')

local menus = {}

local function OnUpdate(self, elapsed)
    if self.__caller and not self.__caller:IsVisible() then
        self:Hide()
    end
    if self:IsMouseOver() then
        self.__hideTimer = self.__holdTime
    end
    
    self.__hideTimer = self.__hideTimer - elapsed
    if self.__hideTimer < 0 then
        self:Hide()
    end
end

local function OnShow(self)
    PlaySound("igMainMenuOpen")
    self.__hideTimer = self.__holdTime
end

local function OnHide(self)
    PlaySound("igMainMenuClose")
    self.__caller = nil
    self.__hideTimer = self.__holdTime
end

local function SetCaller(self, caller)
    self.__caller = caller
end

local function GetCaller(self)
    return self.__caller
end

function GUI:NewMenu(name, obj, holdTime)
    obj:Hide()
    obj.__holdTime = holdTime or 2
    obj.__hideTimer = holdTime or 2
    obj:HookScript('OnUpdate', OnUpdate)
    obj:HookScript('OnShow', OnShow)
    obj:HookScript('OnHide', OnHide)
    obj.SetCaller = SetCaller
    obj.GetCaller = GetCaller
    
    obj:SetFrameStrata('DIALOG')
    obj:SetBackdropColor(0, 0, 0, 0.9)
    
    menus[name] = obj
    
    return obj
end

function GUI:GetMenu(name)
    if type(name) == 'string' then
        return menus[name]
    else
        return name
    end
end

function GUI:ShowMenu(name, caller, anchor, ...)
    local menu = self:GetMenu(name)
    if not menu then
        error('error menu.')
    end
    
    if (...) and type(menu.SetMenuArgs) == 'function' then
        menu:SetMenuArgs(...)
    end
    
--[[
    local cx, cy = GetCursorPosition()
    local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
    
    if anchor and anchor:GetHeight() < screenHeight * 2/3 and anchor:GetWidth() < screenWidth * 2/3 then
        local h = (anchor:GetWidth() < 200 or cx < anchor:GetLeft() + anchor:GetWidth() / 2) and 'LEFT' or 'RIGHT'
        local v1, v2 = 'TOP', 'BOTTOM'
        if cy < screenHeight / 2 then
            v1, v2 = v2, v1
        end
        
        menu:ClearAllPoints()
        menu:SetPoint(v1..h, anchor, v2..h, 0, 0)
    else
        local uiScale = UIParent:GetEffectiveScale()
        
        menu:ClearAllPoints()
        menu:SetPoint(
            (cy < screenHeight / 2 and 'BOTTOM' or 'TOP')..(cx < screenWidth / 2 and 'LEFT' or 'RIGHT'),
            UIParent, 'BOTTOMLEFT', cx / uiScale, cy / uiScale)
    end
--]]
    anchor = anchor or 'center'
    if anchor == 'center' then
        menu:ClearAllPoints()
        menu:SetPoint('CENTER', 0, 0)
    else
        local cx, cy = GetCursorPosition()
        local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
        if anchor == 'cursor' then
            local uiScale = UIParent:GetEffectiveScale()
            
            menu:ClearAllPoints()
            menu:SetPoint(
                (cy < screenHeight / 2 and 'BOTTOM' or 'TOP')..(cx < screenWidth / 2 and 'LEFT' or 'RIGHT'),
                UIParent, 'BOTTOMLEFT', cx / uiScale, cy / uiScale)
        else
            local h = (anchor:GetWidth() < 200 or cx < anchor:GetLeft() + anchor:GetWidth() / 2) and 'LEFT' or 'RIGHT'
            local v1, v2 = 'TOP', 'BOTTOM'
            if cy < screenHeight / 2 then
                v1, v2 = v2, v1
            end
            
            menu:ClearAllPoints()
            menu:SetPoint(v1..h, anchor, v2..h, 0, 0)
        end
    end

    menu:SetCaller(caller)
    menu:Show()
end

function GUI:ToggleMenu(name, caller, anchor, ...)
    local menu = self:GetMenu(name)
    if not menu then
        error('error menu.')
    end
    
    if menu:IsVisible() then
        menu:Hide()
    else
        self:ShowMenu(menu, caller, anchor, ...)
    end
end
