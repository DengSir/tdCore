
local GUI = tdCore('GUI')

local List = GUI('List')
local Media = GUI:NewModule('Media')

Media.Fonts = List:New()
Media.Bars = List:New()

function Media:GetFonts()
    return self.Fonts
end

function Media:GetBars()
    return self.Bars
end

function Media:CheckFontPath(path)
    if not self.testFont then
        self.testFont = UIParent:CreateFontString()
    end
    if self.testFont:SetFont(path, 12) then
        return path:lower()
    end
end

function Media:FindFont(path)
    for i, v in ipairs(self.Fonts) do
        if v == path then
            return i
        end
    end
end

function Media:DeleteFont(path)
    local i = self:FindFont(path)
    tremove(self.Fonts, i)
end

function Media:AddFont(path)
    path = self:CheckFontPath(path)
    if path and not self:FindFont(path) then
        tinsert(self.Fonts, path)
        return path
    end
end

do
    local fonts = {
        [[fonts\arkai_t.ttf]],
        [[fonts\arkai_c.ttf]],
        [[fonts\arhei.ttf]],
        [[fonts\arialn.ttf]],
        [[fonts\frizqt__.ttf]],
        [[fonts\2002b.ttf]],
        [[fonts\2002.ttf]],
        [[fonts\k_damage.ttf]],
        [[fonts\k_pagetext.ttf]],
        [[fonts\bhei00m.ttf]],
        [[fonts\bhei01b.ttf]],
        [[fonts\bkai00m.ttf]],
        [[fonts\blei00d.ttf]],
        [[fonts\morpheus.ttf]],
        [[fonts\nim_____.ttf]],
        [[fonts\skurri.ttf]],
    }
    
    for _, v in ipairs(fonts) do
        local path = Media:CheckFontPath(v)
        if path then
            tinsert(Media.Fonts, path)
        end
    end
end
