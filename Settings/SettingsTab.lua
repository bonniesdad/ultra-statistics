-- Settings Tab - Statistics-related options only

local settingsCheckboxOptions = { {
  name = 'Show Tiers',
  dbSettingsValueName = 'showTiers',
  tooltip = 'Use the tier system (Bronze, Silver, Gold, Master, Demon)',
}, {
  name = 'Show Statistics on Main Screen',
  dbSettingsValueName = 'showOnScreenStatistics',
  tooltip = 'Show selected statistics on the screen at all times',
}, {
  name = 'Show Statistics Notifications',
  dbSettingsValueName = 'showStatisticsTracking',
  tooltip = 'Show statistic update notifications (e.g. Enemies Slain)',
}, {
  name = 'Minimal Style Notifications',
  dbSettingsValueName = 'minimalStatisticsTracking',
  tooltip = 'Show "+X [icon]" only (no stat name text)',
  dependsOn = 'showStatisticsTracking',
}, {
  name = 'Only Show Tier Notifications',
  dbSettingsValueName = 'statisticsTrackingTierOnly',
  tooltip = 'Only show a notification when you advance to a new tier',
  dependsOn = 'showStatisticsTracking',
} }

local settingsSliderOptions = {}

local LAYOUT = {
  PAGE_WIDTH = 520,
  ROW_WIDTH = 480,
  SEARCH_WIDTH = 400,
  HEADER_HEIGHT = 28,
  HEADER_PADDING_H = 12,
  ROW_HEIGHT = 30,
  COLOR_ROW_HEIGHT = 24,
  SECTION_GAP = 10,
  HEADER_CONTENT_GAP = 10,
  LABEL_WIDTH = 140,
  SLIDER_WIDTH = 150,
}

local function IsSearchMatch(searchBlob, query)
  if not query or query == '' then
    return true
  end
  if not searchBlob then
    return false
  end
  return string.find(searchBlob, query, 1, true) ~= nil
end

function updateRadioButtons()
  for settingName, radio in pairs(radioButtons or {}) do
    if radio then
      local isChecked = (tempSettings or {})[settingName] or false
      radio:SetChecked(isChecked)
      if GLOBAL_SETTINGS then
        GLOBAL_SETTINGS[settingName] = tempSettings[settingName]
      end
    end
  end
end

-- Single section: Statistics (showOnScreenStatistics is in Statistics Display panel)
local STATISTICS_SECTIONS = { {
  title = 'Statistics',
  settings = {
    'showTiers',
    'showStatisticsTracking',
    'minimalStatisticsTracking',
    'statisticsTrackingTierOnly',
  },
} }

function UltraStatistics_InitializeSettingsTab(tabContents)
  if not tabContents or not tabContents[2] then return end
  if tabContents[2].initialized then return end
  tabContents[2].initialized = true

  tempSettings = tempSettings or {}
  if not GLOBAL_SETTINGS.collapsedSettingsSections then
    GLOBAL_SETTINGS.collapsedSettingsSections = {}
  end
  if GLOBAL_SETTINGS.collapsedSettingsSections.presetSection == nil then
    GLOBAL_SETTINGS.collapsedSettingsSections.presetSection = {}
  end

  local checkboxes = {}
  local sectionFrames = {}
  local lastSectionFrame = nil

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

  -- Search row full width: [Search bar stretches] [Clear] [Collapse All], right edge lines up with panel below (LEFT 10, RIGHT -10)
  local searchBox = CreateFrame('EditBox', nil, tabContents[2], 'InputBoxTemplate')
  searchBox:SetHeight(24)
  searchBox:SetAutoFocus(false)

  local clearSearchButton = CreateFrame('Button', nil, tabContents[2], 'UIPanelButtonTemplate')
  clearSearchButton:SetSize(56, 22)
  clearSearchButton:SetText('Clear')

  local collapseAllButton = CreateFrame('Button', nil, tabContents[2], 'UIPanelButtonTemplate')
  collapseAllButton:SetSize(96, 22)
  collapseAllButton:SetText('Collapse')
  collapseAllButton:SetPoint('TOPRIGHT', tabContents[2], 'TOPRIGHT', -40, -60)

  clearSearchButton:SetPoint('TOPRIGHT', collapseAllButton, 'TOPLEFT', -6, 0)

  searchBox:SetPoint('TOPLEFT', tabContents[2], 'TOPLEFT', 20, -60)
  searchBox:SetPoint('TOPRIGHT', clearSearchButton, 'TOPLEFT', -6, 0)
  searchBox:SetHeight(24)

  local searchPlaceholder = searchBox:CreateFontString(nil, 'OVERLAY', 'GameFontDisableSmall')
  searchPlaceholder:SetPoint('LEFT', searchBox, 'LEFT', 6, 0)
  searchPlaceholder:SetText('Search options...')

  local optionsFrame = CreateFrame('Frame', nil, tabContents[2], 'BackdropTemplate')
  optionsFrame:SetPoint('TOP', searchBox, 'BOTTOM', 0, -10)
  optionsFrame:SetPoint('LEFT', tabContents[2], 'LEFT', 10, 0)
  optionsFrame:SetPoint('RIGHT', tabContents[2], 'RIGHT', -10, 0)
  optionsFrame:SetPoint('BOTTOM', tabContents[2], 'BOTTOM', 0, 10)
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

  local scrollFrame = CreateFrame('ScrollFrame', nil, optionsFrame, 'UIPanelScrollFrameTemplate')
  scrollFrame:SetPoint('TOPLEFT', optionsFrame, 'TOPLEFT', 10, -10)
  scrollFrame:SetPoint('BOTTOMRIGHT', optionsFrame, 'BOTTOMRIGHT', -30, 10)
  local scrollChild = CreateFrame('Frame')
  scrollFrame:SetScrollChild(scrollChild)
  scrollChild:SetHeight(400)
  scrollChild:SetWidth(scrollFrame:GetWidth() - 10)

  local sectionChildren = {}
  local sectionCollapsed = {}
  local sectionHeaderIcons = {}
  local sectionExpandedHeights = {}
  local sectionCollapsedHeights = {}
  local prevSectionFrame = nil
  local HEADER_HEIGHT = LAYOUT.HEADER_HEIGHT
  local ROW_HEIGHT = LAYOUT.ROW_HEIGHT
  local HEADER_CONTENT_GAP = LAYOUT.HEADER_CONTENT_GAP
  local SECTION_GAP = LAYOUT.SECTION_GAP

  for sectionIndex, section in ipairs(STATISTICS_SECTIONS) do
    local sectionFrame = CreateFrame('Frame', nil, scrollChild, 'BackdropTemplate')
    sectionFrame:SetWidth(LAYOUT.PAGE_WIDTH)
    if prevSectionFrame then
      sectionFrame:SetPoint('TOPLEFT', prevSectionFrame, 'BOTTOMLEFT', 0, -SECTION_GAP)
      sectionFrame:SetPoint('TOPRIGHT', prevSectionFrame, 'BOTTOMRIGHT', 0, -SECTION_GAP)
    else
      sectionFrame:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 10, -10)
      sectionFrame:SetPoint('TOPRIGHT', scrollChild, 'TOPRIGHT', 0, -10)
    end
    sectionFrame:SetBackdrop({
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
    sectionFrame:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
    sectionFrame:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

    local sectionHeaderButton = CreateFrame('Button', nil, sectionFrame, 'BackdropTemplate')
    sectionHeaderButton:SetPoint('TOPLEFT', sectionFrame, 'TOPLEFT', 0, 0)
    sectionHeaderButton:SetPoint('TOPRIGHT', sectionFrame, 'TOPRIGHT', 0, 0)
    sectionHeaderButton:SetHeight(HEADER_HEIGHT)
    sectionHeaderButton:SetBackdrop({
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
    sectionHeaderButton:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
    sectionHeaderButton:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
    sectionHeaderButton:SetScript('OnEnter', function(self)
      self:SetBackdropColor(0.2, 0.2, 0.28, 0.95)
      self:SetBackdropBorderColor(0.6, 0.6, 0.75, 1)
    end)
    sectionHeaderButton:SetScript('OnLeave', function(self)
      self:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
      self:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
    end)

    local headerPad = LAYOUT.HEADER_PADDING_H or 12
    local sectionHeader =
      sectionHeaderButton:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    sectionHeader:SetPoint('LEFT', sectionHeaderButton, 'LEFT', headerPad, 0)
    sectionHeader:SetText(section.title)
    sectionHeader:SetTextColor(0.9, 0.85, 0.75, 1)
    sectionHeader:SetShadowOffset(1, -1)
    sectionHeader:SetShadowColor(0, 0, 0, 0.8)

    local headerIcon = sectionHeaderButton:CreateTexture(nil, 'ARTWORK')
    headerIcon:SetPoint('RIGHT', sectionHeaderButton, 'RIGHT', -headerPad, 0)
    headerIcon:SetSize(16, 16)
    headerIcon:SetTexture('Interface\\Buttons\\UI-MinusButton-Up')
    sectionChildren[sectionIndex] = {}
    sectionHeaderIcons[sectionIndex] = headerIcon

    local numRows = 0
    for _, settingName in ipairs(section.settings) do
      local checkboxItem = nil
      for _, item in ipairs(settingsCheckboxOptions) do
        if item.dbSettingsValueName == settingName then
          checkboxItem = item
          break
        end
      end

      if checkboxItem then
        numRows = numRows + 1
        local checkbox =
          CreateFrame('CheckButton', nil, sectionFrame, 'ChatConfigCheckButtonTemplate')
        local rowY = -(HEADER_HEIGHT + HEADER_CONTENT_GAP + ((numRows - 1) * ROW_HEIGHT))
        checkbox:SetPoint('TOPLEFT', sectionFrame, 'TOPLEFT', 10, rowY)
        checkbox._originalOffsetY = rowY
        checkbox.Text:SetText(checkboxItem.name)
        checkbox.Text:SetPoint('LEFT', checkbox, 'RIGHT', 5, 0)
        checkbox:SetChecked(tempSettings[checkboxItem.dbSettingsValueName])

        checkbox._uhcSearch =
          string.lower(
            (checkboxItem.name or '') .. ' ' .. (checkboxItem.tooltip or '') .. ' ' .. (checkboxItem.dbSettingsValueName or '')
          )

        local function updateDependencyState()
          local shouldDisable = false
          if checkboxItem.dependsOn then
            if not (tempSettings[checkboxItem.dependsOn] or false) then
              shouldDisable = true
            end
          end
          if not shouldDisable and checkboxItem.dependsOff then
            if (tempSettings[checkboxItem.dependsOff] or false) then
              shouldDisable = true
            end
          end
          if shouldDisable then
            checkbox:Disable()
            checkbox.Text:SetTextColor(0.5, 0.5, 0.5)
            checkbox:SetChecked(false)
            tempSettings[checkboxItem.dbSettingsValueName] = false
            cascadeDependencyUpdates(checkboxItem.dbSettingsValueName)
          else
            checkbox:Enable()
            checkbox.Text:SetTextColor(1, 1, 1)
          end
        end
        updateDependencyState()
        checkboxes[checkboxItem.dbSettingsValueName] = checkbox
        table.insert(sectionChildren[sectionIndex], checkbox)
        checkbox._updateDependency = updateDependencyState

        checkbox:SetScript('OnClick', function(self)
          if checkboxItem.dependsOn and not (tempSettings[checkboxItem.dependsOn] or false) then return end
          if checkboxItem.dependsOff and (tempSettings[checkboxItem.dependsOff] or false) then return end
          tempSettings[checkboxItem.dbSettingsValueName] = self:GetChecked()
          cascadeDependencyUpdates(checkboxItem.dbSettingsValueName)
        end)

        checkbox:SetScript('OnEnter', function(self)
          GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
          local tooltipText = checkboxItem.tooltip or ''
          if checkboxItem.dependsOn then
            for _, item in ipairs(settingsCheckboxOptions) do
              if item.dbSettingsValueName == checkboxItem.dependsOn then
                local dep = tempSettings[checkboxItem.dependsOn] or false
                if not dep then
                  tooltipText = tooltipText .. '\n\n|cFFFF0000Requires: ' .. item.name .. '|r'
                end
                break
              end
            end
          end
          if checkboxItem.dependsOff then
            for _, item in ipairs(settingsCheckboxOptions) do
              if item.dbSettingsValueName == checkboxItem.dependsOff then
                if (tempSettings[checkboxItem.dependsOff] or false) then
                  tooltipText = tooltipText .. '\n\n|cFFFF0000Conflicts with: ' .. item.name .. '|r'
                end
                break
              end
            end
          end
          GameTooltip:SetText(tooltipText)
          GameTooltip:Show()
        end)
        checkbox:SetScript('OnLeave', function()
          GameTooltip:Hide()
        end)

        if checkboxItem.dbSettingsValueName == 'statisticsTrackingTierOnly' then
          numRows = numRows + 1
          local repositionButton = CreateFrame('Button', nil, sectionFrame, 'UIPanelButtonTemplate')
          repositionButton:SetSize(180, 25)
          local btnY = -(HEADER_HEIGHT + HEADER_CONTENT_GAP + ((numRows - 1) * ROW_HEIGHT))
          repositionButton:SetPoint('TOPLEFT', sectionFrame, 'TOPLEFT', 10, btnY)
          repositionButton._originalOffsetY = btnY
          repositionButton:SetText('Reposition Statistics Toast')
          repositionButton:SetScript('OnClick', function()
            if _G.EnableStatisticsTrackingToastRepositioning then
              _G.EnableStatisticsTrackingToastRepositioning()
              print(
                '|cfff44336[ULTRA]|r Statistics Tracking Toast repositioning mode enabled. Drag the highlighted area and click Confirm to save.'
              )
            end
          end)
          repositionButton:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
            GameTooltip:SetText('Reposition Statistics Toast', 1, 1, 1)
            GameTooltip:AddLine(
              'Highlights the Statistics Tracking Toast area and makes it draggable. Drag it to your desired position and click Confirm to save.',
              0.8,
              0.8,
              0.8,
              true
            )
            GameTooltip:Show()
          end)
          repositionButton:SetScript('OnLeave', function()
            GameTooltip:Hide()
          end)
          repositionButton._uhcSearch = 'reposition statistics toast notification position'
          table.insert(sectionChildren[sectionIndex], repositionButton)
        end
      end
    end

    local expandedHeight = HEADER_HEIGHT + HEADER_CONTENT_GAP + (numRows * ROW_HEIGHT) + 5
    local collapsedHeight = HEADER_HEIGHT
    sectionExpandedHeights[sectionIndex] = expandedHeight
    sectionCollapsedHeights[sectionIndex] = collapsedHeight

    local initialCollapsed = GLOBAL_SETTINGS.collapsedSettingsSections.presetSection[section.title]
    if initialCollapsed == nil then
      initialCollapsed = false
    end
    sectionCollapsed[sectionIndex] = initialCollapsed
    headerIcon:SetTexture(
      initialCollapsed and 'Interface\\Buttons\\UI-PlusButton-Up' or 'Interface\\Buttons\\UI-MinusButton-Up'
    )
    for _, child in ipairs(sectionChildren[sectionIndex]) do
      child:SetShown(not initialCollapsed)
    end
    sectionFrame:SetHeight(initialCollapsed and collapsedHeight or expandedHeight)

    sectionHeaderButton:SetScript('OnClick', function()
      local collapsed = not sectionCollapsed[sectionIndex]
      sectionCollapsed[sectionIndex] = collapsed
      headerIcon:SetTexture(
        collapsed and 'Interface\\Buttons\\UI-PlusButton-Up' or 'Interface\\Buttons\\UI-MinusButton-Up'
      )
      for _, child in ipairs(sectionChildren[sectionIndex]) do
        child:SetShown(not collapsed)
      end
      sectionFrame:SetHeight(collapsed and collapsedHeight or expandedHeight)
      GLOBAL_SETTINGS.collapsedSettingsSections.presetSection[section.title] = collapsed
      if SaveCharacterSettings then
        SaveCharacterSettings(GLOBAL_SETTINGS)
      end
    end)

    prevSectionFrame = sectionFrame
    lastSectionFrame = sectionFrame
    table.insert(sectionFrames, sectionFrame)
  end

  -- Statistics Display section (opacity sliders)
  if tempSettings.statisticsBackgroundOpacity == nil then
    tempSettings.statisticsBackgroundOpacity = GLOBAL_SETTINGS.statisticsBackgroundOpacity or 0.3
  end
  if tempSettings.statisticsBorderOpacity == nil then
    tempSettings.statisticsBorderOpacity = GLOBAL_SETTINGS.statisticsBorderOpacity or 0.9
  end

  local displaySection = CreateFrame('Frame', nil, scrollChild, 'BackdropTemplate')
  displaySection:SetWidth(LAYOUT.PAGE_WIDTH)
  displaySection:SetPoint('TOPLEFT', lastSectionFrame, 'BOTTOMLEFT', 0, -SECTION_GAP)
  displaySection:SetPoint('TOPRIGHT', lastSectionFrame, 'BOTTOMRIGHT', 0, -SECTION_GAP)
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

  local displayHeaderBtn = CreateFrame('Button', nil, displaySection, 'BackdropTemplate')
  displayHeaderBtn:SetPoint('TOPLEFT', displaySection, 'TOPLEFT', 0, 0)
  displayHeaderBtn:SetPoint('TOPRIGHT', displaySection, 'TOPRIGHT', 0, 0)
  displayHeaderBtn:SetHeight(HEADER_HEIGHT)
  displayHeaderBtn:SetBackdrop({
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
  displayHeaderBtn:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  displayHeaderBtn:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  local displayHeaderPad = LAYOUT.HEADER_PADDING_H or 12
  local displayHeaderText = displayHeaderBtn:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  displayHeaderText:SetPoint('LEFT', displayHeaderBtn, 'LEFT', displayHeaderPad, 0)
  displayHeaderText:SetText('Main Screen Statistics Display')
  displayHeaderText:SetTextColor(0.9, 0.85, 0.75, 1)
  displayHeaderText:SetShadowOffset(1, -1)
  displayHeaderText:SetShadowColor(0, 0, 0, 0.8)
  local displayHeaderIcon = displayHeaderBtn:CreateTexture(nil, 'ARTWORK')
  displayHeaderIcon:SetPoint('RIGHT', displayHeaderBtn, 'RIGHT', -displayHeaderPad, 0)
  displayHeaderIcon:SetSize(16, 16)
  displayHeaderIcon:SetTexture('Interface\\Buttons\\UI-MinusButton-Up')

  local LABEL_WIDTH = LAYOUT.LABEL_WIDTH
  local GAP = 12
  -- On Screen Statistics checkbox as first row in Statistics Display
  local onScreenCheckboxItem
  for _, item in ipairs(settingsCheckboxOptions) do
    if item.dbSettingsValueName == 'showOnScreenStatistics' then
      onScreenCheckboxItem = item
      break
    end
  end
  if onScreenCheckboxItem then
    local onScreenCheckbox =
      CreateFrame('CheckButton', nil, displaySection, 'ChatConfigCheckButtonTemplate')
    onScreenCheckbox:SetPoint(
      'TOPLEFT',
      displaySection,
      'TOPLEFT',
      10,
      -(HEADER_HEIGHT + HEADER_CONTENT_GAP)
    )
    onScreenCheckbox.Text:SetText(onScreenCheckboxItem.name)
    onScreenCheckbox.Text:SetPoint('LEFT', onScreenCheckbox, 'RIGHT', 5, 0)
    onScreenCheckbox:SetChecked(tempSettings.showOnScreenStatistics)
    checkboxes['showOnScreenStatistics'] = onScreenCheckbox
    onScreenCheckbox:SetScript('OnClick', function(self)
      tempSettings.showOnScreenStatistics = self:GetChecked()
      cascadeDependencyUpdates('showOnScreenStatistics')
    end)
    onScreenCheckbox:SetScript('OnEnter', function()
      GameTooltip:SetOwner(onScreenCheckbox, 'ANCHOR_RIGHT')
      GameTooltip:SetText(onScreenCheckboxItem.tooltip or '')
      GameTooltip:Show()
    end)
    onScreenCheckbox:SetScript('OnLeave', function()
      GameTooltip:Hide()
    end)
  end

  local displayRowsHeight =
    HEADER_HEIGHT + HEADER_CONTENT_GAP + ROW_HEIGHT + LAYOUT.COLOR_ROW_HEIGHT * 2 + 20
  displaySection:SetHeight(displayRowsHeight)

  local opacityRow = CreateFrame('Frame', nil, displaySection)
  opacityRow:SetSize(LAYOUT.ROW_WIDTH, LAYOUT.COLOR_ROW_HEIGHT)
  opacityRow:SetPoint(
    'TOPLEFT',
    displaySection,
    'TOPLEFT',
    10,
    -(HEADER_HEIGHT + HEADER_CONTENT_GAP + ROW_HEIGHT)
  )
  local opacityLabel = opacityRow:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  opacityLabel:SetPoint('LEFT', opacityRow, 'LEFT', 0, 0)
  opacityLabel:SetWidth(LABEL_WIDTH)
  opacityLabel:SetText('Background Opacity')
  local percentText = opacityRow:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  percentText:SetPoint('LEFT', opacityRow, 'LEFT', LABEL_WIDTH + GAP, 0)
  percentText:SetWidth(40)
  percentText:SetText(
    tostring(math.floor((tempSettings.statisticsBackgroundOpacity or 0.3) * 100)) .. '%'
  )
  local bgSlider = CreateFrame('Slider', nil, opacityRow, 'OptionsSliderTemplate')
  bgSlider:SetPoint('LEFT', percentText, 'RIGHT', 10, 0)
  bgSlider:SetSize(180, 16)
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
    GLOBAL_SETTINGS.statisticsBackgroundOpacity = tempSettings.statisticsBackgroundOpacity
    if _G.ApplyStatsBackgroundOpacity then
      _G.ApplyStatsBackgroundOpacity()
    end
  end)

  local borderOpacityRow = CreateFrame('Frame', nil, displaySection)
  borderOpacityRow:SetSize(LAYOUT.ROW_WIDTH, LAYOUT.COLOR_ROW_HEIGHT)
  borderOpacityRow:SetPoint('TOPLEFT', opacityRow, 'BOTTOMLEFT', 0, -6)
  local borderLabel = borderOpacityRow:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  borderLabel:SetPoint('LEFT', borderOpacityRow, 'LEFT', 0, 0)
  borderLabel:SetWidth(LABEL_WIDTH)
  borderLabel:SetText('Border Opacity')
  local borderPercentText = borderOpacityRow:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  borderPercentText:SetPoint('LEFT', borderOpacityRow, 'LEFT', LABEL_WIDTH + GAP, 0)
  borderPercentText:SetWidth(40)
  borderPercentText:SetText(
    tostring(math.floor((tempSettings.statisticsBorderOpacity or 0.9) * 100)) .. '%'
  )
  local borderSlider = CreateFrame('Slider', nil, borderOpacityRow, 'OptionsSliderTemplate')
  borderSlider:SetPoint('LEFT', borderPercentText, 'RIGHT', 10, 0)
  borderSlider:SetSize(180, 16)
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
    GLOBAL_SETTINGS.statisticsBorderOpacity = tempSettings.statisticsBorderOpacity
    if _G.ApplyStatsBackgroundOpacity then
      _G.ApplyStatsBackgroundOpacity()
    end
  end)

  table.insert(sectionFrames, displaySection)

  local function recalcContentHeight()
    local total = 10
    for i, sf in ipairs(sectionFrames) do
      if i > 1 then
        total = total + SECTION_GAP
      end
      total = total + (sf:GetHeight() or 0)
    end
    scrollChild:SetHeight(total + 30)
  end

  local function applySearchFilter(query)
    local q = string.lower(query or '')
    if q == '' then
      -- Restore all and use saved collapse state for Statistics
      local saved = GLOBAL_SETTINGS.collapsedSettingsSections.presetSection['Statistics']
      if saved == nil then
        saved = false
      end
      sectionCollapsed[1] = saved
      sectionHeaderIcons[1]:SetTexture(
        saved and 'Interface\\Buttons\\UI-PlusButton-Up' or 'Interface\\Buttons\\UI-MinusButton-Up'
      )
      for _, child in ipairs(sectionChildren[1]) do
        child:ClearAllPoints()
        child:SetPoint('TOPLEFT', sectionFrames[1], 'TOPLEFT', 10, child._originalOffsetY or 0)
        child:SetShown(not saved)
      end
      sectionFrames[1]:SetHeight(saved and sectionCollapsedHeights[1] or sectionExpandedHeights[1])
    else
      -- Expand Statistics section and filter children
      sectionCollapsed[1] = false
      sectionHeaderIcons[1]:SetTexture('Interface\\Buttons\\UI-MinusButton-Up')
      local visibleCount = 0
      for _, child in ipairs(sectionChildren[1]) do
        local blob = child._uhcSearch or ''
        if IsSearchMatch(blob, q) then
          child:Show()
          child:ClearAllPoints()
          child:SetPoint(
            'TOPLEFT',
            sectionFrames[1],
            'TOPLEFT',
            10,
            -(HEADER_HEIGHT + HEADER_CONTENT_GAP + visibleCount * ROW_HEIGHT)
          )
          visibleCount = visibleCount + 1
        else
          child:Hide()
        end
      end
      sectionFrames[1]:SetHeight(HEADER_HEIGHT + HEADER_CONTENT_GAP + visibleCount * ROW_HEIGHT + 5)
    end
    recalcContentHeight()
  end

  clearSearchButton:SetScript('OnClick', function()
    searchBox:SetText('')
    searchBox:ClearFocus()
    searchPlaceholder:Show()
    applySearchFilter('')
  end)

  collapseAllButton:SetScript('OnClick', function()
    for idx = 1, #sectionFrames do
      if sectionCollapsed[idx] ~= nil then
        sectionCollapsed[idx] = true
        if sectionHeaderIcons[idx] then
          sectionHeaderIcons[idx]:SetTexture('Interface\\Buttons\\UI-PlusButton-Up')
        end
        if sectionCollapsedHeights[idx] then
          sectionFrames[idx]:SetHeight(sectionCollapsedHeights[idx])
        end
        if sectionChildren[idx] then
          for _, child in ipairs(sectionChildren[idx]) do
            child:SetShown(false)
          end
        end
        local title = (STATISTICS_SECTIONS[idx] and STATISTICS_SECTIONS[idx].title)
        if title and GLOBAL_SETTINGS.collapsedSettingsSections and GLOBAL_SETTINGS.collapsedSettingsSections.presetSection then
          GLOBAL_SETTINGS.collapsedSettingsSections.presetSection[title] = true
        end
      end
    end
    recalcContentHeight()
  end)

  recalcContentHeight()
  scrollFrame:SetScript('OnSizeChanged', function()
    scrollChild:SetWidth(scrollFrame:GetWidth() - 10)
  end)

  -- Save button
  local saveButton = CreateFrame('Button', nil, tabContents[2], 'UIPanelButtonTemplate')
  saveButton:SetSize(120, 30)
  saveButton:SetPoint('BOTTOM', tabContents[2], 'BOTTOM', 0, -35)
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
      GLOBAL_SETTINGS[key] = value
    end
    if SaveCharacterSettings then
      SaveCharacterSettings(GLOBAL_SETTINGS)
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

  searchBox:SetScript('OnTextChanged', function(self)
    local txt = self:GetText() or ''
    if txt == '' then
      searchPlaceholder:Show()
    else
      searchPlaceholder:Hide()
    end
    applySearchFilter(txt)
  end)
  searchBox:SetScript('OnEditFocusGained', function()
    if (searchBox:GetText() or '') == '' then
      searchPlaceholder:Hide()
    end
  end)
  searchBox:SetScript('OnEditFocusLost', function()
    if (searchBox:GetText() or '') == '' then
      searchPlaceholder:Show()
    end
  end)
  searchBox:SetScript('OnEscapePressed', function(self)
    self:SetText('')
    self:ClearFocus()
    searchPlaceholder:Show()
    applySearchFilter('')
  end)

  _G.updateCheckboxes = updateCheckboxes
  _G.updateRadioButtons = updateRadioButtons
  _G.checkboxes = checkboxes
end
