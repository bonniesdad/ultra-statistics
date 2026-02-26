radioButtons = {}

LAYOUT = {
  SECTION_HEADER_HEIGHT = 28,
  ROW_HEIGHT = 46,
  HEADER_TO_CONTENT_GAP = 5,
  SECTION_SPACING = 10,
  CONTENT_INDENT = 20,
  ROW_INDENT = 12,
  CONTENT_PADDING = 8,
}

local function shouldRadioBeChecked(settingName, settings)
  if settings[settingName] ~= nil then
    return settings[settingName]
  end
  return false
end

tempSettings = {}

local function initializeTempSettings()
  if type(GLOBAL_SETTINGS) ~= 'table' then
    GLOBAL_SETTINGS = {}
  end
  for key, value in pairs(GLOBAL_SETTINGS) do
    tempSettings[key] = value
  end

  for settingName, _ in pairs(radioButtons) do
    if tempSettings[settingName] == nil then
      tempSettings[settingName] = shouldRadioBeChecked(settingName, GLOBAL_SETTINGS)
    end
  end
end

local CLASS_BACKGROUND_MAP = {
  WARRIOR = 'Interface\\AddOns\\UltraStatistics\\Textures\\bg_warrior.png',
  PALADIN = 'Interface\\AddOns\\UltraStatistics\\Textures\\bg_pally.png',
  HUNTER = 'Interface\\AddOns\\UltraStatistics\\Textures\\bg_hunter.png',
  ROGUE = 'Interface\\AddOns\\UltraStatistics\\Textures\\bg_rogue.png',
  PRIEST = 'Interface\\AddOns\\UltraStatistics\\Textures\\bg_priest.png',
  MAGE = 'Interface\\AddOns\\UltraStatistics\\Textures\\bg_mage.png',
  WARLOCK = 'Interface\\AddOns\\UltraStatistics\\Textures\\bg_warlock.png',
  DRUID = 'Interface\\AddOns\\UltraStatistics\\Textures\\bg_druid.png',
  SHAMAN = 'Interface\\AddOns\\UltraStatistics\\Textures\\bg_shaman.png',
}

local CLASS_BACKGROUND_ASPECT_RATIO = 1200 / 700

local function getClassBackgroundTexture()
  local _, classFileName = UnitClass('player')
  if classFileName and CLASS_BACKGROUND_MAP[classFileName] then
    return CLASS_BACKGROUND_MAP[classFileName]
  end
  return 'Interface\\DialogFrame\\UI-DialogBox-Background'
end

local settingsFrame =
  CreateFrame('Frame', 'UltraStatisticsSettingsFrame', UIParent, 'BackdropTemplate')
tinsert(UISpecialFrames, 'UltraStatisticsSettingsFrame')
settingsFrame:SetSize(535, 700)
settingsFrame:SetMovable(true)
settingsFrame:EnableMouse(true)
settingsFrame:RegisterForDrag('LeftButton')
settingsFrame:SetScript('OnDragStart', function(self)
  self:StartMoving()
end)
settingsFrame:SetScript('OnDragStop', function(self)
  self:StopMovingOrSizing()
end)
settingsFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, 30)

settingsFrame:Hide()
settingsFrame:SetFrameStrata('DIALOG')
settingsFrame:SetFrameLevel(15)
settingsFrame:SetClipsChildren(true)

local settingsFrameBackground = settingsFrame:CreateTexture(nil, 'BACKGROUND')
settingsFrameBackground:SetPoint('CENTER', settingsFrame, 'CENTER')
settingsFrameBackground:SetTexCoord(0, 1, 0, 1)

local function updateSettingsFrameBackdrop()
  settingsFrameBackground:SetTexture(getClassBackgroundTexture())
  local frameHeight = settingsFrame:GetHeight()
  settingsFrameBackground:SetSize(frameHeight * CLASS_BACKGROUND_ASPECT_RATIO, frameHeight)

  settingsFrame:SetBackdrop({
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    tile = false,
    edgeSize = 2,
    insets = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    },
  })
  settingsFrame:SetBackdropBorderColor(0, 0, 0, 1)
end
updateSettingsFrameBackdrop()

local titleBar = CreateFrame('Frame', nil, settingsFrame, 'BackdropTemplate')
titleBar:SetSize(535, 60)
titleBar:SetPoint('TOP', settingsFrame, 'TOP')
titleBar:SetFrameStrata('DIALOG')
titleBar:SetFrameLevel(20)
titleBar:SetBackdropBorderColor(0, 0, 0, 1)
titleBar:SetBackdropColor(0, 0, 0, 0.95)

local titleBarBackground = titleBar:CreateTexture(nil, 'BACKGROUND')
titleBarBackground:SetAllPoints()
titleBarBackground:SetTexture('Interface\\AddOns\\UltraStatistics\\Textures\\header.png')
titleBarBackground:SetTexCoord(0, 1, 0, 1)

local titleBarLeftIcon = titleBar:CreateTexture(nil, 'OVERLAY')
titleBarLeftIcon:SetSize(36, 36)
titleBarLeftIcon:SetPoint('LEFT', titleBar, 'LEFT', 15, 3)
titleBarLeftIcon:SetTexture('Interface\\AddOns\\UltraStatistics\\Textures\\bonnie-round.png')
titleBarLeftIcon:SetTexCoord(0, 1, 0, 1)

local settingsTitleLabel = titleBar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightHuge')
settingsTitleLabel:SetPoint('CENTER', titleBar, 'CENTER', 0, 4)
settingsTitleLabel:SetText('Ultra Statistics')
settingsTitleLabel:SetTextColor(0.922, 0.871, 0.761)

local dividerFrame = CreateFrame('Frame', nil, settingsFrame)
dividerFrame:SetSize(545, 24)
dividerFrame:SetPoint('BOTTOM', titleBar, 'BOTTOM', 0, -10)
dividerFrame:SetFrameStrata('DIALOG')
dividerFrame:SetFrameLevel(20)

local dividerTexture = dividerFrame:CreateTexture(nil, 'ARTWORK')
dividerTexture:SetAllPoints()
dividerTexture:SetTexture('Interface\\AddOns\\UltraStatistics\\Textures\\divider.png')
dividerTexture:SetTexCoord(0, 1, 0, 1)

local closeButton = CreateFrame('Button', nil, titleBar, 'UIPanelCloseButton')
closeButton:SetPoint('RIGHT', titleBar, 'RIGHT', -15, 4)
closeButton:SetSize(12, 12)
closeButton:SetScript('OnClick', function()
  if UltraStatistics_ResetTabState then
    UltraStatistics_ResetTabState()
  end
  initializeTempSettings()
  settingsFrame:Hide()
end)
closeButton:SetNormalTexture('Interface\\AddOns\\UltraStatistics\\Textures\\header-x.png')
closeButton:SetPushedTexture('Interface\\AddOns\\UltraStatistics\\Textures\\header-x.png')
closeButton:SetHighlightTexture('Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight', 'ADD')

local closeButtonTex = closeButton:GetNormalTexture()
if closeButtonTex then
  closeButtonTex:SetTexCoord(0, 1, 0, 1)
end
local closeButtonPushed = closeButton:GetPushedTexture()
if closeButtonPushed then
  closeButtonPushed:SetTexCoord(0, 1, 0, 1)
end

-- Use a unique name so we don't overwrite Ultra/UltraHardcore's ToggleSettings or menu opener
function ToggleUltraStatistics()
  if settingsFrame:IsShown() then
    if UltraStatistics_ResetTabState then
      UltraStatistics_ResetTabState()
    end
    settingsFrame:Hide()
  else
    updateSettingsFrameBackdrop()
    if UltraStatistics_InitializeTabs then
      UltraStatistics_InitializeTabs(settingsFrame)
    end

    initializeTempSettings()

    if UltraStatistics_HideAllTabs and UltraStatistics_SetDefaultTab then
      UltraStatistics_HideAllTabs()
      UltraStatistics_SetDefaultTab()
    elseif UltraStatistics_SwitchToTab then
      UltraStatistics_SwitchToTab(1)
    end

    settingsFrame:Show()
    if _G.UpdateLowestHealthDisplay then
      _G.UpdateLowestHealthDisplay()
    end
  end
end
SLASH_ULTRASTATISTICS1 = '/ustats'
SLASH_ULTRASTATISTICS2 = '/ultrastats'
SlashCmdList['ULTRASTATISTICS'] = ToggleUltraStatistics

initializeTempSettings()

local addonLDB = LibStub('LibDataBroker-1.1'):NewDataObject('UltraStatistics', {
  type = 'data source',
  text = 'ULTRASTATS',
  icon = 'Interface\\AddOns\\UltraStatistics\\Textures\\stats-icons\\playerJumps.png',
  OnClick = function(_, btn)
    if btn == 'LeftButton' then
      ToggleUltraStatistics()
    end
  end,
  OnTooltipShow = function(tooltip)
    if not tooltip or not tooltip.AddLine then return end
    tooltip:AddLine('|cffffffffStats|r\n\nLeft-click to open stats', nil, nil, nil, nil)
  end,
})

-- Register minimap icon only after ADDON_LOADED so UltraStatisticsDB is the saved table from disk.
-- LibDBIcon writes minimapPos into the db we pass; that must be UltraStatisticsDB.minimapButton so it persists.
local function registerMinimapIcon()
  if not UltraStatisticsDB then
    UltraStatisticsDB = {}
  end
  if not UltraStatisticsDB.minimapButton then
    UltraStatisticsDB.minimapButton = { hide = false }
  elseif UltraStatisticsDB.minimapButton.hide == nil then
    UltraStatisticsDB.minimapButton.hide = false
  end
  local addonIcon = LibStub('LibDBIcon-1.0')
  addonIcon:Register('UltraStatistics', addonLDB, UltraStatisticsDB.minimapButton)
end

local minimapLoadFrame = CreateFrame('Frame')
minimapLoadFrame:RegisterEvent('ADDON_LOADED')
minimapLoadFrame:SetScript('OnEvent', function(_, event, addonName)
  if event == 'ADDON_LOADED' and addonName == 'UltraStatistics' then
    minimapLoadFrame:UnregisterEvent('ADDON_LOADED')
    registerMinimapIcon()
  end
end)
