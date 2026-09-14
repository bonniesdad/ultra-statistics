-- Settings Tab - Statistics-related options only

local settingsCheckboxOptions = { {
  name = 'Show Statistics on Main Screen',
  dbSettingsValueName = 'showOnScreenStatistics',
  tooltip = 'Show selected statistics on the screen at all times',
}, {
  name = 'Opt out of Guild Leaderboard',
  dbSettingsValueName = 'leaderboardOptOutGuild',
  tooltip = 'Stop sharing and receiving guild leaderboard data via addon messages',
}, {
  name = 'Opt out of Server Leaderboard',
  dbSettingsValueName = 'leaderboardOptOutServer',
  tooltip = 'Stop sharing and receiving realm leaderboard data via the data channel',
} }

local LAYOUT = {
  PAGE_WIDTH = 395,
  ROW_WIDTH = 355,
  HEADER_HEIGHT = 28,
  HEADER_PADDING_H = 12,
  COLOR_ROW_HEIGHT = 24,
  HEADER_CONTENT_GAP = 10,
  LABEL_WIDTH = 140,
}

local ROW_BUTTON_HEIGHT = 48
local ROW_BUTTON_PAD_H = 14
local OPTION_ROW_TOTAL = 58 -- height of each option row (button + gap between rows)

--- Create a simple checkbox row (standard WoW checkbox + label + optional description).
--- Returned object is click-compatible with older row-button code: SetChecked/GetChecked/Enable/Disable, plus .Text and .Description.
local function CreateOptionRowButton(parent)
  local row = CreateFrame('Button', nil, parent)
  row:SetHeight(ROW_BUTTON_HEIGHT)
  row:RegisterForClicks('LeftButtonUp')

  local check = CreateFrame('CheckButton', nil, row, 'UICheckButtonTemplate')
  check:SetPoint('TOPLEFT', row, 'TOPLEFT', 0, -6)
  -- Expose the underlying CheckButton so callers can safely attach OnClick to it.
  row.Check = check

  -- Title
  local label = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  label:SetPoint('TOPLEFT', check, 'TOPRIGHT', 4, -2)
  label:SetPoint('RIGHT', row, 'RIGHT', 0, 0)
  label:SetJustifyH('LEFT')
  label:SetNonSpaceWrap(false)
  row.Text = label

  -- Description
  local desc = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  desc:SetPoint('TOPLEFT', label, 'BOTTOMLEFT', 0, -2)
  desc:SetPoint('RIGHT', row, 'RIGHT', 0, 0)
  desc:SetJustifyH('LEFT')
  desc:SetWordWrap(true)
  desc:SetNonSpaceWrap(false)
  desc:SetTextColor(0.75, 0.72, 0.65, 1)
  row.Description = desc

  function row:SetDescription(text)
    if self.Description then
      self.Description:SetText(text or '')
      self.Description:SetShown(text and text ~= '')
    end
  end

  function row:SetChecked(on)
    check:SetChecked(on and true or false)
  end

  function row:GetChecked()
    return check:GetChecked() and true or false
  end

  do
    local rawEnable, rawDisable = row.Enable, row.Disable
    row.Enable = function(self)
      if rawEnable then
        rawEnable(self)
      end
      check:Enable()
      check:SetAlpha(1)
    end
    row.Disable = function(self)
      if rawDisable then
        rawDisable(self)
      end
      check:Disable()
      check:SetAlpha(0.6)
    end
  end

  -- Clicking the row toggles the checkbox (preserves old behavior where the whole row was clickable).
  row:SetScript('OnClick', function(self)
    if not check:IsEnabled() then
      return
    end
    -- Delegate to the actual CheckButton so its OnClick handler (set by the caller) runs.
    check:Click()
  end)

  row:SetChecked(false)
  row:SetDescription('')
  return row
end

function updateRadioButtons()
  for settingName, radio in pairs(radioButtons or {}) do
    if radio then
      local isChecked = (tempSettings or {})[settingName] or false
      radio:SetChecked(isChecked)
      if ULTRA_STATISTICS_GLOBAL_SETTINGS then
        ULTRA_STATISTICS_GLOBAL_SETTINGS[settingName] = tempSettings[settingName]
      end
    end
  end
end

function UltraStatistics_InitializeSettingsTab(tabContents)
  -- Settings tab is tab index 3 in TabManager.lua
  if not tabContents or not tabContents[3] then return end
  if tabContents[3].initialized then return end
  tabContents[3].initialized = true

  tempSettings = tempSettings or {}

  local checkboxes = {}

  local function cascadeDependencyUpdates(settingName)
    if not settingName then return end
    for _, otherCheckboxItem in ipairs(settingsCheckboxOptions) do
      if otherCheckboxItem.dependsOn == settingName or otherCheckboxItem.dependsOff == settingName then
        local otherCheckbox = checkboxes[otherCheckboxItem.dbSettingsValueName]
        if otherCheckbox and otherCheckbox._updateDependency then
          otherCheckbox._updateDependency()
        end
      end
    end
  end

  local function updateCheckboxes()
    for _, checkboxItem in ipairs(settingsCheckboxOptions) do
      local checkbox = checkboxes[checkboxItem.dbSettingsValueName]
      if checkbox then
        local isChecked = tempSettings[checkboxItem.dbSettingsValueName]
        if isChecked == nil then
          isChecked = false
        end
        checkbox:SetChecked(isChecked)
        if checkbox._updateDependency then
          checkbox._updateDependency()
        end
      end
    end
  end

  local optionsFrame = CreateFrame('Frame', nil, tabContents[3], 'BackdropTemplate')
  optionsFrame:SetPoint('TOPLEFT', tabContents[3], 'TOPLEFT', 0, -60)
  optionsFrame:SetPoint('TOPRIGHT', tabContents[3], 'TOPRIGHT', 0, -60)
  optionsFrame:SetPoint('BOTTOM', tabContents[3], 'BOTTOM', 0, 10)
  optionsFrame:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 64,
    edgeSize = 16,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  optionsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
  optionsFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

  local HEADER_HEIGHT = LAYOUT.HEADER_HEIGHT
  local HEADER_CONTENT_GAP = LAYOUT.HEADER_CONTENT_GAP

  if tempSettings.statisticsBackgroundOpacity == nil then
    tempSettings.statisticsBackgroundOpacity = ULTRA_STATISTICS_GLOBAL_SETTINGS.statisticsBackgroundOpacity or 0.3
  end
  if tempSettings.statisticsBorderOpacity == nil then
    tempSettings.statisticsBorderOpacity = ULTRA_STATISTICS_GLOBAL_SETTINGS.statisticsBorderOpacity or 0.9
  end

  local displaySection = CreateFrame('Frame', nil, optionsFrame, 'BackdropTemplate')
  displaySection:SetPoint('TOPLEFT', optionsFrame, 'TOPLEFT', 10, -10)
  displaySection:SetPoint('TOPRIGHT', optionsFrame, 'TOPRIGHT', -10, -10)
  displaySection:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  displaySection:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  displaySection:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  local displayHeader = CreateFrame('Frame', nil, displaySection, 'BackdropTemplate')
  displayHeader:SetPoint('TOPLEFT', displaySection, 'TOPLEFT', 0, 0)
  displayHeader:SetPoint('TOPRIGHT', displaySection, 'TOPRIGHT', 0, 0)
  displayHeader:SetHeight(HEADER_HEIGHT)
  displayHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  displayHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  displayHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  local displayHeaderPad = LAYOUT.HEADER_PADDING_H or 12
  local displayHeaderText = displayHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  displayHeaderText:SetPoint('LEFT', displayHeader, 'LEFT', displayHeaderPad, 0)
  displayHeaderText:SetText('Main Screen Statistics Display')
  displayHeaderText:SetTextColor(0.9, 0.85, 0.75, 1)
  displayHeaderText:SetShadowOffset(1, -1)
  displayHeaderText:SetShadowColor(0, 0, 0, 0.8)

  local onScreenCheckboxItem
  for _, item in ipairs(settingsCheckboxOptions) do
    if item.dbSettingsValueName == 'showOnScreenStatistics' then
      onScreenCheckboxItem = item
      break
    end
  end
  if onScreenCheckboxItem then
    local onScreenRow = CreateOptionRowButton(displaySection)
    onScreenRow:SetPoint(
      'TOPLEFT',
      displaySection,
      'TOPLEFT',
      ROW_BUTTON_PAD_H,
      -(HEADER_HEIGHT + HEADER_CONTENT_GAP)
    )
    onScreenRow:SetPoint(
      'TOPRIGHT',
      displaySection,
      'TOPRIGHT',
      -ROW_BUTTON_PAD_H,
      -(HEADER_HEIGHT + HEADER_CONTENT_GAP)
    )
    onScreenRow.Text:SetText(onScreenCheckboxItem.name)
    onScreenRow:SetDescription(onScreenCheckboxItem.tooltip)
    onScreenRow:SetChecked(tempSettings.showOnScreenStatistics and true or false)
    checkboxes['showOnScreenStatistics'] = onScreenRow
    onScreenRow.Check:SetScript('OnClick', function(btn)
      local newVal = btn:GetChecked() and true or false
      onScreenRow:SetChecked(newVal)
      tempSettings.showOnScreenStatistics = newVal
      if ULTRA_STATISTICS_GLOBAL_SETTINGS then
        ULTRA_STATISTICS_GLOBAL_SETTINGS.showOnScreenStatistics = newVal
      end
      if CheckAddonEnabled then
        CheckAddonEnabled()
      end
      cascadeDependencyUpdates('showOnScreenStatistics')
    end)
  end

  local displayRowsHeight =
    HEADER_HEIGHT + HEADER_CONTENT_GAP + OPTION_ROW_TOTAL + LAYOUT.COLOR_ROW_HEIGHT * 2 + 24
  displaySection:SetHeight(displayRowsHeight)

  local opacityRow = CreateFrame('Frame', nil, displaySection)
  opacityRow:SetHeight(LAYOUT.COLOR_ROW_HEIGHT)
  opacityRow:SetPoint(
    'TOPLEFT',
    displaySection,
    'TOPLEFT',
    ROW_BUTTON_PAD_H,
    -(HEADER_HEIGHT + HEADER_CONTENT_GAP + OPTION_ROW_TOTAL)
  )
  opacityRow:SetPoint(
    'TOPRIGHT',
    displaySection,
    'TOPRIGHT',
    -ROW_BUTTON_PAD_H,
    -(HEADER_HEIGHT + HEADER_CONTENT_GAP + OPTION_ROW_TOTAL)
  )
  local opacityLabel = opacityRow:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  opacityLabel:SetPoint('LEFT', opacityRow, 'LEFT', 0, 0)
  opacityLabel:SetText('Background Opacity')
  local bgSlider = CreateFrame('Slider', nil, opacityRow, 'OptionsSliderTemplate')
  bgSlider:SetPoint('RIGHT', opacityRow, 'RIGHT', 0, 0)
  bgSlider:SetSize(180, 16)
  local percentText = opacityRow:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  percentText:SetPoint('RIGHT', bgSlider, 'LEFT', -10, 0)
  percentText:SetWidth(40)
  percentText:SetJustifyH('RIGHT')
  percentText:SetText(
    tostring(math.floor((tempSettings.statisticsBackgroundOpacity or 0.3) * 100)) .. '%'
  )
  local bgSliderTrack = bgSlider:CreateTexture(nil, 'BACKGROUND')
  bgSliderTrack:SetAllPoints(bgSlider)
  bgSliderTrack:SetTexture('Interface\\Tooltips\\UI-Tooltip-Background')
  bgSliderTrack:SetTexCoord(0, 1, 0, 1)
  bgSliderTrack:SetVertexColor(0.2, 0.2, 0.25, 0.95)
  bgSlider:SetMinMaxValues(0, 100)
  bgSlider:SetValueStep(1)
  bgSlider:SetObeyStepOnDrag(true)
  bgSlider:SetValue((tempSettings.statisticsBackgroundOpacity or 0.3) * 100)
  bgSlider:SetScript('OnValueChanged', function(self, val)
    local pct = math.floor(val + 0.5)
    percentText:SetText(pct .. '%')
    tempSettings.statisticsBackgroundOpacity = pct / 100
    ULTRA_STATISTICS_GLOBAL_SETTINGS.statisticsBackgroundOpacity = tempSettings.statisticsBackgroundOpacity
    if _G.ApplyStatsBackgroundOpacity then
      _G.ApplyStatsBackgroundOpacity()
    end
  end)

  local borderOpacityRow = CreateFrame('Frame', nil, displaySection)
  borderOpacityRow:SetHeight(LAYOUT.COLOR_ROW_HEIGHT)
  borderOpacityRow:SetPoint('TOPLEFT', opacityRow, 'BOTTOMLEFT', 0, -6)
  borderOpacityRow:SetPoint('TOPRIGHT', opacityRow, 'BOTTOMRIGHT', 0, -6)
  local borderLabel = borderOpacityRow:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  borderLabel:SetPoint('LEFT', borderOpacityRow, 'LEFT', 0, 0)
  borderLabel:SetText('Border Opacity')
  local borderSlider = CreateFrame('Slider', nil, borderOpacityRow, 'OptionsSliderTemplate')
  borderSlider:SetPoint('RIGHT', borderOpacityRow, 'RIGHT', 0, 0)
  borderSlider:SetSize(180, 16)
  local borderPercentText = borderOpacityRow:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  borderPercentText:SetPoint('RIGHT', borderSlider, 'LEFT', -10, 0)
  borderPercentText:SetWidth(40)
  borderPercentText:SetJustifyH('RIGHT')
  borderPercentText:SetText(
    tostring(math.floor((tempSettings.statisticsBorderOpacity or 0.9) * 100)) .. '%'
  )
  local borderSliderTrack = borderSlider:CreateTexture(nil, 'BACKGROUND')
  borderSliderTrack:SetAllPoints(borderSlider)
  borderSliderTrack:SetTexture('Interface\\Tooltips\\UI-Tooltip-Background')
  borderSliderTrack:SetTexCoord(0, 1, 0, 1)
  borderSliderTrack:SetVertexColor(0.2, 0.2, 0.25, 0.95)
  borderSlider:SetMinMaxValues(0, 100)
  borderSlider:SetValueStep(1)
  borderSlider:SetObeyStepOnDrag(true)
  borderSlider:SetValue((tempSettings.statisticsBorderOpacity or 0.9) * 100)
  borderSlider:SetScript('OnValueChanged', function(self, val)
    local pct = math.floor(val + 0.5)
    borderPercentText:SetText(pct .. '%')
    tempSettings.statisticsBorderOpacity = pct / 100
    ULTRA_STATISTICS_GLOBAL_SETTINGS.statisticsBorderOpacity = tempSettings.statisticsBorderOpacity
    if _G.ApplyStatsBackgroundOpacity then
      _G.ApplyStatsBackgroundOpacity()
    end
  end)

  local leaderboardSection = CreateFrame('Frame', nil, optionsFrame, 'BackdropTemplate')
  leaderboardSection:SetPoint('TOPLEFT', displaySection, 'BOTTOMLEFT', 0, -10)
  leaderboardSection:SetPoint('TOPRIGHT', displaySection, 'BOTTOMRIGHT', 0, -10)
  leaderboardSection:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  leaderboardSection:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  leaderboardSection:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  local leaderboardHeader = CreateFrame('Frame', nil, leaderboardSection, 'BackdropTemplate')
  leaderboardHeader:SetPoint('TOPLEFT', leaderboardSection, 'TOPLEFT', 0, 0)
  leaderboardHeader:SetPoint('TOPRIGHT', leaderboardSection, 'TOPRIGHT', 0, 0)
  leaderboardHeader:SetHeight(HEADER_HEIGHT)
  leaderboardHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  leaderboardHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  leaderboardHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  local leaderboardHeaderText = leaderboardHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  leaderboardHeaderText:SetPoint('LEFT', leaderboardHeader, 'LEFT', LAYOUT.HEADER_PADDING_H or 12, 0)
  leaderboardHeaderText:SetText('Leaderboard Sharing')
  leaderboardHeaderText:SetTextColor(0.9, 0.85, 0.75, 1)
  leaderboardHeaderText:SetShadowOffset(1, -1)
  leaderboardHeaderText:SetShadowColor(0, 0, 0, 0.8)

  local prevLbRow
  local lbRowCount = 0
  for _, item in ipairs(settingsCheckboxOptions) do
    if item.dbSettingsValueName == 'leaderboardOptOutGuild'
      or item.dbSettingsValueName == 'leaderboardOptOutServer'
    then
      lbRowCount = lbRowCount + 1
      local row = CreateOptionRowButton(leaderboardSection)
      if prevLbRow then
        row:SetPoint('TOPLEFT', prevLbRow, 'BOTTOMLEFT', 0, -10)
        row:SetPoint('TOPRIGHT', prevLbRow, 'BOTTOMRIGHT', 0, -10)
      else
        row:SetPoint(
          'TOPLEFT',
          leaderboardSection,
          'TOPLEFT',
          ROW_BUTTON_PAD_H,
          -(HEADER_HEIGHT + HEADER_CONTENT_GAP)
        )
        row:SetPoint(
          'TOPRIGHT',
          leaderboardSection,
          'TOPRIGHT',
          -ROW_BUTTON_PAD_H,
          -(HEADER_HEIGHT + HEADER_CONTENT_GAP)
        )
      end
      row.Text:SetText(item.name)
      row:SetDescription(item.tooltip)
      local key = item.dbSettingsValueName
      row:SetChecked(tempSettings[key] and true or false)
      checkboxes[key] = row
      row.Check:SetScript('OnClick', function(btn)
        local newVal = btn:GetChecked() and true or false
        row:SetChecked(newVal)
        tempSettings[key] = newVal
      end)
      prevLbRow = row
    end
  end
  leaderboardSection:SetHeight(
    HEADER_HEIGHT + HEADER_CONTENT_GAP + (lbRowCount * OPTION_ROW_TOTAL) + 8
  )

  -- Save button
  local saveButton = CreateFrame('Button', nil, tabContents[3], 'UIPanelButtonTemplate')
  saveButton:SetSize(120, 30)
  saveButton:SetPoint('BOTTOM', tabContents[3], 'BOTTOM', 0, -35)
  saveButton:SetText('Save and Reload')

  local function updateSaveButtonState()
    local inCombat = UnitAffectingCombat('player') == true
    saveButton:SetEnabled(not inCombat)
    saveButton:SetText(inCombat and 'In Combat' or 'Save and Reload')
  end
  local combatFrame = CreateFrame('Frame')
  combatFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
  combatFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
  combatFrame:SetScript('OnEvent', updateSaveButtonState)
  updateSaveButtonState()

  local function doSaveAndReload()
    for key, value in pairs(tempSettings) do
      ULTRA_STATISTICS_GLOBAL_SETTINGS[key] = value
    end
    if SaveCharacterSettings then
      SaveCharacterSettings(ULTRA_STATISTICS_GLOBAL_SETTINGS)
    end
    ReloadUI()
  end

  saveButton:SetScript('OnClick', function()
    if ShowConfirmationDialog then
      ShowConfirmationDialog(
        'Save and Reload',
        'Are you sure you want to save your settings and reload the UI?',
        doSaveAndReload,
        nil,
        'Save and Reload',
        'Cancel'
      )
    else
      doSaveAndReload()
    end
  end)

  _G.updateCheckboxes = updateCheckboxes
  _G.updateRadioButtons = updateRadioButtons
  _G.checkboxes = checkboxes
end
