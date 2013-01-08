
local GUI = tdCore('GUI')

local L = tdCore:GetLocale('tdCore')

local ICON_SIZE, BUTTON_WIDTH, BUTTON_HEIGHT, MENU_PADDING = 64, 100, 22, 10

local DialogMenu = GUI:NewMenu('DialogMenu', GUI('Widget'):New(UIParent), 20)

GUI.DialogButton = {
    Okay    = OKAY,
    Cancel  = CANCEL,
    Yes     = YES,
    No      = NO,
    Apply   = APPLY,
    Discard = L['Discard'],
    Open    = L['Open'],
    Close   = CLOSE,
    Save    = SAVE,
    Reset   = RESET,
    Retry   = L['Retry'],
    Abort   = L['Abort'],
    Ignore  = IGNORE_DIALOG,
}

GUI.DialogIcon = {
    Information = [[Interface\HelpFrame\HelpIcon-Suggestion]],
    Question    = [[Interface\HelpFrame\HelpIcon-KnowledgeBase]],
    Warning     = [[Interface\HelpFrame\HelpIcon-ReportAbuse]],
    Setting     = [[Interface\HelpFrame\HelpIcon-CharacterStuck]],
    Critical    = [[Interface\HelpFrame\HelpIcon-Bug]],
    Default     = [[Interface\HelpFrame\ReportLagIcon-Chat]],
}

local function ButtonOnClick(self)
    if type(DialogMenu.func) == 'function' then
        DialogMenu.func(self:GetText(),
            (DialogMenu.hasMultiText and DialogMenu.textedit:GetText()) or (DialogMenu.hasText and DialogMenu.lineedit:GetText()))
    end
    DialogMenu:Hide()
end

function DialogMenu:GetButton(i)
    if not self.buttons[i] then
        local button = GUI('Button'):New(DialogMenu)
        button:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
        button:SetScript('OnClick', ButtonOnClick)
        self.buttons[i] = button
    end
    return self.buttons[i]
end

local defaultButtons = {GUI.DialogButton.Okay}
function DialogMenu:UpdateButton(buttons)
    buttons = type(buttons) == 'table' and buttons or defaultButtons
    
    local i = 0
    for _, text in ipairs(buttons) do
        if text then
            i = i + 1;
            local button = self:GetButton(i)
            button:SetPoint('BOTTOMLEFT', MENU_PADDING + BUTTON_WIDTH * (i - 1), MENU_PADDING)
            button:Show()
            button:SetText(text)
        end
    end
    self.buttonCount = i;
end

function DialogMenu:UpdateDialog()
    local label = self:GetLabelFontString()
    
    local width = self.buttonCount * BUTTON_WIDTH + MENU_PADDING * 2 + ICON_SIZE
    local height = ceil(label:GetStringWidth() / (width - MENU_PADDING - ICON_SIZE) + 0.5) * label:GetStringHeight()
    
--    self:GetLabelFontString():SetHeight(height)
    
    if self.hasMultiText then
        self.textedit:Show()
        self.textedit:SetPoint('TOPLEFT', MENU_PADDING + 5, -MENU_PADDING * 2 - height)
        self.textedit:SetPoint('TOPRIGHT', -MENU_PADDING-5-ICON_SIZE, -MENU_PADDING * 2 - height)
        self.textedit:SetText(type(self.hasMultiText) == 'string' and self.hasMultiText or '')
        height = height + 110
    elseif self.hasText then
        self.lineedit:Show()
        self.lineedit:SetPoint('TOPLEFT', MENU_PADDING, -20 - height)
        self.lineedit:SetPoint('TOPRIGHT', -MENU_PADDING-ICON_SIZE, -20 -height)
        self.lineedit:SetText(type(self.hasText) == 'string' and self.hasText or '')
        height = height + 30
    end
    
    self:SetSize(width, MENU_PADDING*2 + 30 + height)
end

function DialogMenu:SetMenuArgs(attr)
    if type(attr) == 'string' then
        self.icon:SetTexture(GUI.DialogIcon.Default)
        self:SetLabelText(attr)
        self:UpdateButton()
        self:UpdateDialog()
    elseif type(attr) == 'table' then
        self.hasText = attr.text
        self.hasMultiText = attr.multitext
        self.func = attr.func
        self.icon:SetTexture(attr.mode or GUI.DialogIcon.Default)
        self:SetLabelText(attr.label)
        self:UpdateButton(attr.buttons)
        self:UpdateDialog()
    else
        return
    end
end

do
    DialogMenu:Hide()
    DialogMenu:SetSize(310, 50)
    DialogMenu:HookScript('OnHide', function(self)
        self.func = nil
        self.buttonCount = nil
        self.hasText = nil
        self.hasMultiText = nil
            
        for i, button in ipairs(self.buttons) do
            button:Hide()
        end
        self.lineedit:SetText('')
        self.textedit:SetText('')
        self.lineedit:Hide()
        self.textedit:Hide()
    end)
    
    local label = DialogMenu:GetLabelFontString()
    label:ClearAllPoints()
    label:SetPoint('TOPLEFT', MENU_PADDING, -MENU_PADDING)
    label:SetPoint('TOPRIGHT', -ICON_SIZE, -MENU_PADDING)
    label:SetHeight(50)
    label:SetJustifyH('LEFT')
    label:SetJustifyV('TOP')
    
    local icon = DialogMenu:CreateTexture(nil, 'ATKWORK')
    icon:SetSize(64, 64)
    icon:SetPoint('RIGHT', 0, 0)
    
    DialogMenu.icon = icon
    DialogMenu.buttons = {}
    
    DialogMenu.lineedit = GUI('LineEdit'):New(DialogMenu)
    DialogMenu.textedit = GUI('TextEdit'):New(DialogMenu)
    DialogMenu.textedit:SetHeight(100)
end
