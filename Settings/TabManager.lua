local TAB_WIDTH = 86
local TAB_HEIGHT = 32
local TAB_SPACING = 3

local MAX_TABS = 6 -- Stats / Dungeons / Heroics / Raids / Settings / Info
local TAB_WIDTHS = {
  [1] = TAB_WIDTH, -- Stats
  [2] = TAB_WIDTH, -- Dungeons
  [3] = TAB_WIDTH, -- Heroics
  [4] = TAB_WIDTH, -- Raids
  [5] = TAB_WIDTH, -- Settings
  [6] = TAB_WIDTH, -- Info
}

local BASE_TEXT_COLOR = {
  r = 0.922,
  g = 0.871,
  b = 0.761,
}
local ACTIVE_CLASS_FADE = 0.75

local function getPlayerClassColor()
  local _, playerClass = UnitClass('player')
  if not playerClass then
    return BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b
  end
  local r, g, b = GetClassColor(playerClass)
  if not r then
    return BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b
  end
  return r, g, b
end

local tabButtons = {}
local tabContents = {}
local activeTab = 1

local function calculateTabOffset(index)
  local totalWidth = 0
  for i = 1, MAX_TABS do
    local width = TAB_WIDTHS[i] or TAB_WIDTH
    if i < MAX_TABS then
      totalWidth = totalWidth + width + TAB_SPACING
    else
      totalWidth = totalWidth + width
    end
  end

  local leftEdge = -totalWidth / 2

  local cumulativeWidth = 0
  for i = 1, index - 1 do
    local width = TAB_WIDTHS[i] or TAB_WIDTH
    cumulativeWidth = cumulativeWidth + width + TAB_SPACING
  end

  local tabWidth = TAB_WIDTHS[index] or TAB_WIDTH
  return leftEdge + cumulativeWidth + (tabWidth / 2)
end

local function createTabButton(text, index, parentFrame)
  local button = CreateFrame('Button', nil, parentFrame, 'BackdropTemplate')
  local tabWidth = TAB_WIDTHS[index] or TAB_WIDTH
  button:SetSize(tabWidth, TAB_HEIGHT)
  local horizontalOffset = calculateTabOffset(index)
  button:SetPoint('TOP', parentFrame, 'TOP', horizontalOffset, -57)

  local background = button:CreateTexture(nil, 'BACKGROUND')
  background:SetAllPoints()
  background:SetTexture('Interface\\AddOns\\UltraStatistics\\Textures\\tab_texture.png')
  button.backgroundTexture = background

  button:SetBackdrop({
    bgFile = nil,
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    tile = false,
    edgeSize = 1,
    insets = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    },
  })
  button:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

  local buttonText = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  buttonText:SetPoint('CENTER', button, 'CENTER', 0, -2)
  buttonText:SetText(text)
  buttonText:SetTextColor(BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b)
  button.text = buttonText

  button:SetScript('OnClick', function()
    UltraStatistics_SwitchToTab(index)
  end)

  button.backgroundTexture:SetVertexColor(0.6, 0.6, 0.6, 1)
  button:SetAlpha(0.9)
  return button
end

local function createTabContent(_, parentFrame)
  local content = CreateFrame('Frame', nil, parentFrame)
  content:SetSize(495, 600)
  content:SetPoint('TOP', parentFrame, 'TOP', 0, -50)
  content:Hide()
  return content
end

-- Use UltraStatistics_* globals only so we never overwrite UltraHardcore's TabManager* when both addons load
function UltraStatistics_InitializeTabs(settingsFrame)
  if tabButtons[1] then return end

  tabButtons[1] = createTabButton('Stats', 1, settingsFrame)
  tabContents[1] = createTabContent(1, settingsFrame)
  tabButtons[2] = createTabButton('Dungeons', 2, settingsFrame)
  tabContents[2] = createTabContent(2, settingsFrame)
  tabButtons[3] = createTabButton('Heroics', 3, settingsFrame)
  tabContents[3] = createTabContent(3, settingsFrame)
  tabButtons[4] = createTabButton('Raids', 4, settingsFrame)
  tabContents[4] = createTabContent(4, settingsFrame)
  tabButtons[5] = createTabButton('Settings', 5, settingsFrame)
  tabContents[5] = createTabContent(5, settingsFrame)
  tabButtons[6] = createTabButton('Info', 6, settingsFrame)
  tabContents[6] = createTabContent(6, settingsFrame)
end

function UltraStatistics_SwitchToTab(index)
  index = tonumber(index) or 1
  if index < 1 then
    index = 1
  end
  if index > MAX_TABS then
    index = MAX_TABS
  end

  for _, content in ipairs(tabContents) do
    content:Hide()
  end

  for _, tabButton in ipairs(tabButtons) do
    if tabButton.backgroundTexture then
      tabButton.backgroundTexture:SetVertexColor(0.6, 0.6, 0.6, 1)
    end
    tabButton:SetAlpha(0.9)
    tabButton:SetHeight(TAB_HEIGHT)
    if tabButton.text then
      tabButton.text:SetTextColor(BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b)
    end
    tabButton:SetBackdrop({
      bgFile = nil,
      edgeFile = 'Interface\\Buttons\\WHITE8x8',
      tile = false,
      edgeSize = 1,
      insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      },
    })
    tabButton:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
  end

  tabContents[index]:Show()
  if tabButtons[index].backgroundTexture then
    tabButtons[index].backgroundTexture:SetVertexColor(1, 1, 1, 1)
  end
  tabButtons[index]:SetAlpha(1.0)
  tabButtons[index]:SetHeight(TAB_HEIGHT + 6)

  local classR, classG, classB = getPlayerClassColor()
  local fadedR = (classR * ACTIVE_CLASS_FADE) + (BASE_TEXT_COLOR.r * (1 - ACTIVE_CLASS_FADE))
  local fadedG = (classG * ACTIVE_CLASS_FADE) + (BASE_TEXT_COLOR.g * (1 - ACTIVE_CLASS_FADE))
  local fadedB = (classB * ACTIVE_CLASS_FADE) + (BASE_TEXT_COLOR.b * (1 - ACTIVE_CLASS_FADE))
  if tabButtons[index].text then
    tabButtons[index].text:SetTextColor(fadedR, fadedG, fadedB)
  end
  tabButtons[index]:SetBackdrop({
    bgFile = nil,
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    tile = false,
    edgeSize = 1,
    insets = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    },
  })
  tabButtons[index]:SetBackdropBorderColor(fadedR, fadedG, fadedB, 1)

  activeTab = index

  if index == 1 and UltraStatistics_InitializeStatisticsTab then
    UltraStatistics_InitializeStatisticsTab(tabContents)
    if UpdateLowestHealthDisplay then
      if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
          if UltraStatistics_GetActiveTab and UltraStatistics_GetActiveTab() == 1 and UpdateLowestHealthDisplay then
            UpdateLowestHealthDisplay()
          end
        end)
      else
        UpdateLowestHealthDisplay()
      end
    end
  elseif index == 2 and UltraStatistics_InitializeDungeonsTab then
    UltraStatistics_InitializeDungeonsTab(tabContents)
    if _G and _G.UltraStatistics_RefreshDungeonsTab then
      _G.UltraStatistics_RefreshDungeonsTab(true)
    end
  elseif index == 3 and UltraStatistics_InitializeHeroicsTab then
    UltraStatistics_InitializeHeroicsTab(tabContents)
    if _G and _G.UltraStatistics_RefreshHeroicsTab then
      _G.UltraStatistics_RefreshHeroicsTab(true)
    end
  elseif index == 4 and UltraStatistics_InitializeRaidsTab then
    UltraStatistics_InitializeRaidsTab(tabContents)
  elseif index == 5 and UltraStatistics_InitializeSettingsTab then
    UltraStatistics_InitializeSettingsTab(tabContents)
  elseif index == 6 and UltraStatistics_InitializeInfoTab then
    UltraStatistics_InitializeInfoTab(tabContents)
  end
end

function UltraStatistics_SetDefaultTab()
  UltraStatistics_SwitchToTab(1)
end

function UltraStatistics_GetActiveTab()
  return activeTab
end

function UltraStatistics_HideAllTabs()
  for _, content in ipairs(tabContents) do
    content:Hide()
  end
  for _, tabButton in ipairs(tabButtons) do
    if tabButton.backgroundTexture then
      tabButton.backgroundTexture:SetVertexColor(0.6, 0.6, 0.6, 1)
    end
    tabButton:SetAlpha(0.9)
    tabButton:SetHeight(TAB_HEIGHT)
    if tabButton.text then
      tabButton.text:SetTextColor(BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b)
    end
    tabButton:SetBackdrop({
      bgFile = nil,
      edgeFile = 'Interface\\Buttons\\WHITE8x8',
      tile = false,
      edgeSize = 1,
      insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      },
    })
    tabButton:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
  end
end

function UltraStatistics_ResetTabState()
  activeTab = 1
  for _, content in ipairs(tabContents) do
    content:Hide()
  end
  for _, tabButton in ipairs(tabButtons) do
    if tabButton then
      if tabButton.backgroundTexture then
        tabButton.backgroundTexture:SetVertexColor(0.6, 0.6, 0.6, 1)
      end
      tabButton:SetAlpha(0.9)
      tabButton:Show()
      tabButton:SetHeight(TAB_HEIGHT)
      if tabButton.text then
        tabButton.text:SetTextColor(BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b)
      end
      tabButton:SetBackdrop(nil)
    end
  end
end
