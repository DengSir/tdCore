
local GUI = tdCore:NewAddon('GUI', {}, 1)

function GUI:GetWidgetType(obj)
    if type(obj) == 'table' and type(obj.GetWidgetType) == 'function' then
        return obj:GetWidgetType()
    end
end

function GUI:IsWidgetType(obj, widgetType)
    if type(obj) == 'table' and type(obj.IsWidgetType) == 'function' then
        return obj:IsWidgetType(widgetType)
    end
end

local oldunpack = unpack
local function unpack(t)
    if type(t) == 'table' then
        return oldunpack(t)
    end
end

local Set = setmetatable({}, {__index = function(o, k)
    o[k] = function(obj, ...)
        local arg1 = ...
        if arg1 == nil then
            return
        end
        if type(obj[k]) == 'function' then
            obj[k](obj, ...)
        else
            error('no method')
        end
    end
    return o[k]
end})

function GUI:CreateGUI(data, parent, uiparent)
    local Class = GUI(data.type)
    if not Class then
        error('error type')
    end
    
    local obj = Class:New(parent or UIParent)
    uiparent = uiparent or obj
    
    if data.name then
        uiparent.__namedControls = uiparent.__namedControls or {}
        uiparent.__namedControls[data.name] = obj
    end
    
    Set.SetChildOrientation(obj, data.orientation)
    Set.SetHorizontalArgs(obj, unpack(data.horizontalArgs))
    Set.SetVerticalArgs(obj, unpack(data.verticalArgs))
    Set.SetPadding(obj, unpack(data.padding))
    obj:Into()
    
    for i, childdata in ipairs(data) do
        self:CreateGUI(childdata, obj, uiparent)
    end
    
    -- Control
    Set.SetNote(obj, data.note)
    Set.SetProfile(obj, unpack(data.profile))
    Set.SetDepend(obj, uiparent:GetControl(data.depend))
    
    -- All UIObject
    Set.SetWidth(obj, data.width)
    Set.SetHeight(obj, data.height)
    Set.SetLabelText(obj, data.label)
    Set.SetPoint(obj, unpack(data.point))
    Set.SetPoints(obj, unpack(data.points))
    
    -- MainFrame
    Set.SetAllowEscape(obj, data.allowEscape)
    
    -- Slider
    Set.SetMinMaxValues(obj, data.minValue, data.maxValue)
    Set.SetValueStep(obj, data.valueStep)
    
    -- LineEdit
    Set.SetNumeric(obj, data.numeric)
    
    -- TextEdit
    Set.SetReadOnly(obj, data.readonly)
    
    -- ListWidget
    Set.SetAutoSize(obj, data.autoSize)
    Set.SetItemHeight(obj, data.itemHeight)
    Set.SetItemList(obj, data.itemList)
    Set.SetItemObject(obj, data.itemObject)
    Set.SetItemSpacing(obj, data.itemSpacing)
    Set.SetMaxCount(obj, data.maxCount)
    Set.SetAllowOrder(obj, data.allowOrder)
    Set.SetSelectMode(obj, data.selectMode)
    
    -- MinimapButton
    Set.SetAngle(obj, data.angle)
    Set.SetIcon(obj, data.icon)
    
    if type(data.scripts) == 'table' then
        for script, func in pairs(data.scripts) do
            if obj:HasScript(script) then
                obj:SetScript(script, func)
            elseif obj:HasHandle(script) then
                obj:SetHandle(script, func)
            end
        end
    end
    
    return obj
end
