
local function riter(t, i)
    i = i - 1
    if i > 0 then
        return i, t[i]
    end
end

function ripairs(t)
    assert(type(t) == 'table')
    
    return riter, t, #t + 1
end

local function copyTable(tbl, defaults)
    if type(defaults) == 'table' then
        for k, v in pairs(defaults) do
            if type(v) == 'table' then
                tbl[k] = copyTable(tbl[k] or {}, v)
            elseif tbl[k] == nil then
                tbl[k] = v
            end
        end
    end
    return tbl
end

tdCore.copyTable = copyTable