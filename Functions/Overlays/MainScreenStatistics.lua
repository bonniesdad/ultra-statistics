-- Main Screen Statistics Display
-- Shows the same statistics that appear in the settings panel, but on the main screen at all times

local PANEL_WIDTH = 240
local SIDE_INSET = 14
local TOP_PADDING = 14
local BOTTOM_PADDING = 10
local ROW_HEIGHT = 18
local HEADER_LEVEL_HEIGHT = 18
local HEADER_GUILD_HEIGHT = 16
local DIVIDER_GAP_ABOVE = 4
local DIVIDER_GAP_BELOW = 8
local LABEL_FONT_SIZE = 12
local VALUE_FONT_SIZE = 12
local LEVEL_FONT_SIZE = 14
local GUILD_FONT_SIZE = 12

-- Create the main statistics frame with backdrop styling
local statsFrame = CreateFrame('Frame', 'UltraStatsFrame', UIParent, 'BackdropTemplate')
statsFrame:SetSize(PANEL_WIDTH, 360) -- Height adjusted by UpdateRowVisibility (+ bottom padding)
statsFrame:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 130, -10)

-- Tooltip-style border for a cleaner card look
statsFrame:SetBackdrop({
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

-- Background behind statistics with configurable opacity
local statsBackground = statsFrame:CreateTexture(nil, 'BACKGROUND')
statsBackground:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 3, -3)
statsBackground:SetPoint('BOTTOMRIGHT', statsFrame, 'BOTTOMRIGHT', -3, 3)
statsBackground:SetColorTexture(0.05, 0.05, 0.06, 0.3)

local MANA_POWER_TYPE = Enum and Enum.PowerType and Enum.PowerType.Mana or 0

local function GetPlayerPrimaryResourceLabelAndType()
  local powerType, powerToken = UnitPowerType('player')
  local labelsByType = {
    [0] = _G.MANA or 'Mana',
    [1] = _G.RAGE or 'Rage',
    [2] = _G.FOCUS or 'Focus',
    [3] = _G.ENERGY or 'Energy',
    [4] = _G.COMBO_POINTS or 'Combo Points',
    [5] = _G.RUNES or 'Runes',
    [6] = _G.RUNIC_POWER or 'Runic Power',
  }

  local label = labelsByType[powerType]
  if type(label) == 'string' and label ~= '' then
    return label, powerType
  end

  if type(powerToken) == 'string' and powerToken ~= '' then
    local tokenLabel = _G[powerToken]
    if type(tokenLabel) == 'string' and tokenLabel ~= '' then
      return tokenLabel, powerType
    end
    local pretty = string.lower(powerToken):gsub('_', ' '):gsub('(%a)([%w_]*)', function(a, b)
      return string.upper(a) .. b
    end)
    return pretty, powerType
  end

  return 'Resource', powerType
end

local function ApplyStatsBackgroundOpacity()
  local alpha = 0.3
  if ULTRA_STATISTICS_GLOBAL_SETTINGS and ULTRA_STATISTICS_GLOBAL_SETTINGS.statisticsBackgroundOpacity ~= nil then
    alpha = ULTRA_STATISTICS_GLOBAL_SETTINGS.statisticsBackgroundOpacity
  end
  -- Clamp between 0 and 1
  if alpha < 0 then
    alpha = 0
  end
  if alpha > 1 then
    alpha = 1
  end
  statsBackground:SetColorTexture(0.05, 0.05, 0.06, alpha)
  -- Also update backdrop color
  statsFrame:SetBackdropColor(0.08, 0.08, 0.1, alpha * 0.95)

  -- Border opacity
  local borderAlpha = 0.9
  if ULTRA_STATISTICS_GLOBAL_SETTINGS and ULTRA_STATISTICS_GLOBAL_SETTINGS.statisticsBorderOpacity ~= nil then
    borderAlpha = ULTRA_STATISTICS_GLOBAL_SETTINGS.statisticsBorderOpacity
  end
  -- Clamp between 0 and 1
  if borderAlpha < 0 then
    borderAlpha = 0
  end
  if borderAlpha > 1 then
    borderAlpha = 1
  end
  statsFrame:SetBackdropBorderColor(0.45, 0.45, 0.5, borderAlpha)
end

-- Expose globally for instant UI updates
_G.ApplyStatsBackgroundOpacity = ApplyStatsBackgroundOpacity

ApplyStatsBackgroundOpacity()

-- Make the frame draggable
UltraStatistics_MakeFrameDraggable(statsFrame)

-- Click to open settings (drag to move). Use OnMouseUp since Frame doesn't support OnClick.
local mouseDownPos
local function OpenStatisticsSettings()
  if not _G.UltraStatisticsSettingsFrame or not _G.UltraStatisticsSettingsFrame:IsShown() then
    if _G.ToggleUltraStatistics then
      _G.ToggleUltraStatistics()
    end
  else
    if _G.UltraStatistics_SwitchToTab then
      _G.UltraStatistics_SwitchToTab(1)
    end
  end
end

statsFrame:SetScript('OnMouseDown', function(_, button)
  if button == 'LeftButton' then
    local x, y = GetCursorPosition()
    mouseDownPos = { x = x, y = y }
  end
end)
statsFrame:SetScript('OnMouseUp', function(_, button)
  if button == 'LeftButton' and mouseDownPos then
    local x, y = GetCursorPosition()
    local dx = math.abs(x - mouseDownPos.x)
    local dy = math.abs(y - mouseDownPos.y)
    mouseDownPos = nil
    -- Only open settings if it was a click (minimal movement), not a drag
    if dx < 3 and dy < 3 then
      OpenStatisticsSettings()
    end
  end
end)
statsFrame:SetScript('OnEnter', function()
  GameTooltip:SetOwner(statsFrame, 'ANCHOR_RIGHT')
  GameTooltip:SetText('Click to open settings\nDrag to move', nil, nil, nil, nil, true)
  GameTooltip:Show()
end)
statsFrame:SetScript('OnLeave', function()
  mouseDownPos = nil
  GameTooltip:Hide()
end)

-- Helper function to create font strings with standard WoW font
local function CreatePixelFontString(parent, layer, template, size)
  local fontString = parent:CreateFontString(nil, layer, template)
  fontString:SetFont('Fonts\\FRIZQT__.TTF', size or LABEL_FONT_SIZE, 'OUTLINE')
  fontString:SetTextColor(0.9, 0.9, 0.85, 1)
  return fontString
end

-- Subtle rule under the identity (level/guild) header block
local identityDivider = statsFrame:CreateTexture(nil, 'ARTWORK')
identityDivider:SetColorTexture(1, 1, 1, 0.14)
identityDivider:SetHeight(1)
identityDivider:Hide()

-- Create statistics text elements
-- Character Level at the top
local levelLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight', LEVEL_FONT_SIZE)
levelLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', SIDE_INSET, -TOP_PADDING)
levelLabel:SetText('Level:')
levelLabel:SetTextColor(1, 0.9, 0.5, 1)
local levelValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight', VALUE_FONT_SIZE)
levelValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -SIDE_INSET, -TOP_PADDING)
levelValue:SetText(UltraStatistics_FormatNumberWithCommas(1))
levelValue:SetTextColor(1, 1, 1, 1)

local guildLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight', GUILD_FONT_SIZE)
guildLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', SIDE_INSET, -(TOP_PADDING + HEADER_LEVEL_HEIGHT))
guildLabel:SetText('Guildless')
guildLabel:SetTextColor(0.72, 0.72, 0.68, 1)
local guildValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight', VALUE_FONT_SIZE)
guildValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -SIDE_INSET, -(TOP_PADDING + HEADER_LEVEL_HEIGHT))
guildValue:SetText('')
guildValue:SetTextColor(1, 1, 1, 1)
local totalHPLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight', LABEL_FONT_SIZE)
totalHPLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', SIDE_INSET, -23)
totalHPLabel:SetText('Highest Health:')
totalHPLabel:SetTextColor(1, 0.9, 0.5, 1)

local totalHPValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight', VALUE_FONT_SIZE)
totalHPValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -SIDE_INSET, -23)
totalHPValue:SetText(UltraStatistics_FormatNumberWithCommas(UnitHealthMax('player') or 0))
totalHPValue:SetTextColor(1, 0.2, 0.2, 1) -- Red tint for HP
local totalManaLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight', LABEL_FONT_SIZE)
totalManaLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', SIDE_INSET, -38)
totalManaLabel:SetText('Highest Resource:')
totalManaLabel:SetTextColor(1, 0.9, 0.5, 1)

local totalManaValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight', VALUE_FONT_SIZE)
totalManaValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -SIDE_INSET, -38)
do
  local _, powerType = GetPlayerPrimaryResourceLabelAndType()
  totalManaValue:SetText(
    UltraStatistics_FormatNumberWithCommas(UnitPowerMax('player', powerType or MANA_POWER_TYPE) or 0)
  )
end
totalManaValue:SetTextColor(1, 1, 1, 1)
local enemiesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight', LABEL_FONT_SIZE)
enemiesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -98)
enemiesLabel:SetText('Enemies Slain:')
enemiesLabel:SetTextColor(1, 0.9, 0.5, 1)

local enemiesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
enemiesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -98)
enemiesValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
enemiesValue:SetTextColor(1, 1, 1, 1)

-- Additional statistics rows
local petDeathsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
petDeathsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -113)
petDeathsLabel:SetText('Pet Deaths:')
petDeathsLabel:SetTextColor(1, 0.9, 0.5, 1)
local petDeathsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
petDeathsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -113)
petDeathsValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
petDeathsValue:SetTextColor(1, 0.3, 0.3, 1)
local elitesSlainLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
elitesSlainLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -128)
elitesSlainLabel:SetText('Elites Slain:')
elitesSlainLabel:SetTextColor(1, 0.9, 0.5, 1)
local elitesSlainValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
elitesSlainValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -128)
elitesSlainValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
elitesSlainValue:SetTextColor(1, 1, 1, 1)
local rareElitesSlainLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
rareElitesSlainLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -143)
rareElitesSlainLabel:SetText('Rare Elites Slain:')
rareElitesSlainLabel:SetTextColor(1, 0.9, 0.5, 1)
local rareElitesSlainValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
rareElitesSlainValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -143)
rareElitesSlainValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
rareElitesSlainValue:SetTextColor(1, 0.8, 0.2, 1) -- Gold tint for rare
local worldBossesSlainLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
worldBossesSlainLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -158)
worldBossesSlainLabel:SetText('World Bosses Slain:')
worldBossesSlainLabel:SetTextColor(1, 0.9, 0.5, 1)
local worldBossesSlainValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
worldBossesSlainValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -158)
worldBossesSlainValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
worldBossesSlainValue:SetTextColor(1, 0.5, 0, 1) -- Orange tint for world bosses
local dungeonBossesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
dungeonBossesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -173)
dungeonBossesLabel:SetText('Dungeon Bosses Slain:')
dungeonBossesLabel:SetTextColor(1, 0.9, 0.5, 1)
local dungeonBossesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
dungeonBossesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -173)
dungeonBossesValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
dungeonBossesValue:SetTextColor(1, 1, 1, 1)
local dungeonsCompletedLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
dungeonsCompletedLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -188)
dungeonsCompletedLabel:SetText('Dungeons Completed:')
dungeonsCompletedLabel:SetTextColor(1, 0.9, 0.5, 1)
local dungeonsCompletedValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
dungeonsCompletedValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -188)
dungeonsCompletedValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
dungeonsCompletedValue:SetTextColor(1, 1, 1, 1)
-- Survival statistics rows
local healthPotionsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
healthPotionsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -203)
healthPotionsLabel:SetText('Health Potions:')
healthPotionsLabel:SetTextColor(1, 0.9, 0.5, 1)
local healthPotionsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
healthPotionsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -203)
healthPotionsValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
healthPotionsValue:SetTextColor(1, 0.3, 0.3, 1)
local manaPotionsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
manaPotionsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -218)
manaPotionsLabel:SetText('Mana Potions:')
manaPotionsLabel:SetTextColor(1, 0.9, 0.5, 1)
local manaPotionsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
manaPotionsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -218)
manaPotionsValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
manaPotionsValue:SetTextColor(0.3, 0.7, 1, 1)
local bandagesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
bandagesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -233)
bandagesLabel:SetText('Bandages Used:')
bandagesLabel:SetTextColor(1, 0.9, 0.5, 1)
local bandagesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
bandagesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -233)
bandagesValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
bandagesValue:SetTextColor(1, 1, 1, 1)
local targetDummiesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
targetDummiesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -218)
targetDummiesLabel:SetText('Target Dummies:')
targetDummiesLabel:SetTextColor(1, 0.9, 0.5, 1)
local targetDummiesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
targetDummiesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -218)
targetDummiesValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
targetDummiesValue:SetTextColor(1, 1, 1, 1)
local grenadesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
grenadesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -233)
grenadesLabel:SetText('Grenades Used:')
grenadesLabel:SetTextColor(1, 0.9, 0.5, 1)
local grenadesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
grenadesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -233)
grenadesValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
grenadesValue:SetTextColor(1, 0.5, 0, 1) -- Orange for grenades
local partyDeathsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
partyDeathsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -248)
partyDeathsLabel:SetText('Party Deaths:')
partyDeathsLabel:SetTextColor(1, 0.9, 0.5, 1)
local partyDeathsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
partyDeathsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -248)
partyDeathsValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
partyDeathsValue:SetTextColor(1, 0.2, 0.2, 1) -- Red for deaths
-- Player Deaths rows; locals hoisted so statsElements can reference them
local playerDeathsLabel, playerDeathsValue
local playerDeathsOpenWorldLabel, playerDeathsOpenWorldValue
local playerDeathsBattlegroundLabel, playerDeathsBattlegroundValue
local playerDeathsArenaLabel, playerDeathsArenaValue
playerDeathsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -263)
playerDeathsLabel:SetText('Deaths (Total):')
playerDeathsLabel:SetTextColor(1, 0.9, 0.5, 1)
playerDeathsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -263)
playerDeathsValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
playerDeathsValue:SetTextColor(1, 0.2, 0.2, 1)

local serverDeathsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
serverDeathsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -278)
serverDeathsLabel:SetText('Server Deaths:')
serverDeathsLabel:SetTextColor(1, 0.9, 0.5, 1)
local serverDeathsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
serverDeathsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -278)
serverDeathsValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
serverDeathsValue:SetTextColor(1, 0.2, 0.2, 1)

-- Player Deaths breakdown rows
playerDeathsOpenWorldLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsOpenWorldLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -293)
playerDeathsOpenWorldLabel:SetText('Deaths (Open World):')
playerDeathsOpenWorldLabel:SetTextColor(1, 0.9, 0.5, 1)
playerDeathsOpenWorldValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsOpenWorldValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -293)
playerDeathsOpenWorldValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
playerDeathsOpenWorldValue:SetTextColor(1, 0.2, 0.2, 1)

playerDeathsBattlegroundLabel =
  CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsBattlegroundLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -308)
playerDeathsBattlegroundLabel:SetText('Deaths (Battleground):')
playerDeathsBattlegroundLabel:SetTextColor(1, 0.9, 0.5, 1)
playerDeathsBattlegroundValue =
  CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsBattlegroundValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -308)
playerDeathsBattlegroundValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
playerDeathsBattlegroundValue:SetTextColor(1, 0.2, 0.2, 1)

playerDeathsArenaLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsArenaLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -323)
playerDeathsArenaLabel:SetText('Deaths (Arena):')
playerDeathsArenaLabel:SetTextColor(1, 0.9, 0.5, 1)
playerDeathsArenaValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsArenaValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -323)
playerDeathsArenaValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
playerDeathsArenaValue:SetTextColor(1, 0.2, 0.2, 1)
-- Lowest Health rows
local lowestHealthLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
lowestHealthLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -323)
lowestHealthLabel:SetText('Lowest HP:')
lowestHealthLabel:SetTextColor(1, 0.9, 0.5, 1)
local lowestHealthValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
lowestHealthValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -323)
lowestHealthValue:SetText('100%')
lowestHealthValue:SetTextColor(0.85, 0.35, 0.3, 1)
local lowestHealthThisLevelLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
lowestHealthThisLevelLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -338)
lowestHealthThisLevelLabel:SetText('Lowest HP (Level):')
lowestHealthThisLevelLabel:SetTextColor(1, 0.9, 0.5, 1)
local lowestHealthThisLevelValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
lowestHealthThisLevelValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -338)
lowestHealthThisLevelValue:SetText('100%')
lowestHealthThisLevelValue:SetTextColor(0.85, 0.35, 0.3, 1)
local lowestHealthThisSessionLabel =
  CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
lowestHealthThisSessionLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -428)
lowestHealthThisSessionLabel:SetText('Lowest HP (Session):')
lowestHealthThisSessionLabel:SetTextColor(1, 0.9, 0.5, 1)
local lowestHealthThisSessionValue =
  CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
lowestHealthThisSessionValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -428)
lowestHealthThisSessionValue:SetText('100%')
lowestHealthThisSessionValue:SetTextColor(0.85, 0.35, 0.3, 1)

-- Avoidance rows
local blocksLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
blocksLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -338)
blocksLabel:SetText('Blocks:')
blocksLabel:SetTextColor(1, 0.9, 0.5, 1)
local blocksValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
blocksValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -338)
blocksValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
blocksValue:SetTextColor(1, 1, 1, 1)

local parriesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
parriesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -353)
parriesLabel:SetText('Parries:')
parriesLabel:SetTextColor(1, 0.9, 0.5, 1)
local parriesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
parriesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -353)
parriesValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
parriesValue:SetTextColor(1, 1, 1, 1)

local dodgesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
dodgesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -368)
dodgesLabel:SetText('Dodges:')
dodgesLabel:SetTextColor(1, 0.9, 0.5, 1)
local dodgesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
dodgesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -368)
dodgesValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
dodgesValue:SetTextColor(1, 1, 1, 1)

local resistsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
resistsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -383)
resistsLabel:SetText('Resists:')
resistsLabel:SetTextColor(1, 0.9, 0.5, 1)
local resistsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
resistsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -383)
resistsValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
resistsValue:SetTextColor(1, 1, 1, 1)
-- Highest crit value row
local highestCritLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
highestCritLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -293)
highestCritLabel:SetText('Highest Crit:')
highestCritLabel:SetTextColor(1, 0.9, 0.5, 1)
local highestCritValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
highestCritValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -293)
highestCritValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
highestCritValue:SetTextColor(1, 0.8, 0, 1) -- Gold for crits
-- Highest heal crit value row
local highestHealCritLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
highestHealCritLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -308)
highestHealCritLabel:SetText('Highest Heal Crit:')
highestHealCritLabel:SetTextColor(1, 0.9, 0.5, 1)
local highestHealCritValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
highestHealCritValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -308)
highestHealCritValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
highestHealCritValue:SetTextColor(0.2, 1, 0.2, 1) -- Green for heals
-- Close escape count row
local closeEscapesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
closeEscapesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -323)
closeEscapesLabel:SetText('Close Escapes:')
closeEscapesLabel:SetTextColor(1, 0.9, 0.5, 1)
local closeEscapesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
closeEscapesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -323)
closeEscapesValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
closeEscapesValue:SetTextColor(0.5, 1, 0.5, 1) -- Light green for escapes
-- Player Kills (PvP) row
local playerKillsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerKillsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -338)
playerKillsLabel:SetText('Player Kills:')
playerKillsLabel:SetTextColor(1, 0.9, 0.5, 1)
local playerKillsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerKillsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -338)
playerKillsValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
playerKillsValue:SetTextColor(0.2, 1, 0.2, 1) -- Green for PvP kills
-- Duels Total value row
local duelsTotalLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsTotalLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -353)
duelsTotalLabel:SetText('Duels Total:')
duelsTotalLabel:SetTextColor(1, 0.9, 0.5, 1)
local duelsTotalValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsTotalValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -353)
duelsTotalValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
duelsTotalValue:SetTextColor(1, 1, 1, 1)
-- Duels Won value row
local duelsWonLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsWonLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -368)
duelsWonLabel:SetText('Duels Won:')
duelsWonLabel:SetTextColor(1, 0.9, 0.5, 1)
local duelsWonValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsWonValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -368)
duelsWonValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
duelsWonValue:SetTextColor(0.2, 1, 0.2, 1) -- Green for wins
-- Duels Lost value row
local duelsLostLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsLostLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -383)
duelsLostLabel:SetText('Duels Lost:')
duelsLostLabel:SetTextColor(1, 0.9, 0.5, 1)
local duelsLostValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsLostValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -383)
duelsLostValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
duelsLostValue:SetTextColor(1, 0.3, 0.3, 1) -- Red for losses
-- Duels Win Percentage
local duelsWinPercentLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsWinPercentLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -398)
duelsWinPercentLabel:SetText('Duel Win Percent:')
duelsWinPercentLabel:SetTextColor(1, 0.9, 0.5, 1)
local duelsWinPercentValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsWinPercentValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -398)
duelsWinPercentValue:SetText('100%')
duelsWinPercentValue:SetTextColor(1, 1, 1, 1)
-- Player Jumps because who doesn't want to know how much they jump. ;)
local playerJumpsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerJumpsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -413)
playerJumpsLabel:SetText('Jumps:')
playerJumpsLabel:SetTextColor(1, 0.9, 0.5, 1)
local playerJumpsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerJumpsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -413)
playerJumpsValue:SetText(UltraStatistics_FormatNumberWithCommas(0))
playerJumpsValue:SetTextColor(1, 1, 1, 1)

-- Economy statistics
local goldGainedLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
goldGainedLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -458)
goldGainedLabel:SetText('Gold Gained:')
goldGainedLabel:SetTextColor(1, 0.9, 0.5, 1)
local goldGainedValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
goldGainedValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -458)
goldGainedValue:SetText('-')
goldGainedValue:SetTextColor(1, 1, 1, 1)

local goldSpentLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
goldSpentLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -473)
goldSpentLabel:SetText('Gold Spent:')
goldSpentLabel:SetTextColor(1, 0.9, 0.5, 1)
local goldSpentValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
goldSpentValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -473)
goldSpentValue:SetText('-')
goldSpentValue:SetTextColor(1, 1, 1, 1)

-- Network statistics
-- XP Gained With Addon

-- Store all statistics elements for easy management
local statsElements = {
{
  label = levelLabel,
  value = levelValue,
  setting = 'showMainStatisticsPanelLevel',
  statKey = 'level',
}, {
  label = guildLabel,
  value = guildValue,
  setting = 'showMainStatisticsPanelGuild',
  statKey = 'guild',
}, {
  label = totalHPLabel,
  value = totalHPValue,
  setting = 'showMainStatisticsPanelTotalHP',
  statKey = 'totalHP',
}, {
  label = totalManaLabel,
  value = totalManaValue,
  setting = 'showMainStatisticsPanelMaxResource',
  statKey = 'maxResource',
}, {
  label = petDeathsLabel,
  value = petDeathsValue,
  setting = 'showMainStatisticsPanelPetDeaths',
  statKey = 'petDeaths',
}, {
  label = partyDeathsLabel,
  value = partyDeathsValue,
  setting = 'showMainStatisticsPanelPartyMemberDeaths',
  statKey = 'partyMemberDeaths',
}}

local playerDeathStatRows = {
  {
    label = playerDeathsLabel,
    value = playerDeathsValue,
    setting = 'showMainStatisticsPanelPlayerDeaths',
    statKey = 'playerDeaths',
  },
  {
    label = serverDeathsLabel,
    value = serverDeathsValue,
    setting = 'showMainStatisticsPanelServerDeaths',
    statKey = 'serverDeaths',
  },
  {
    label = playerDeathsOpenWorldLabel,
    value = playerDeathsOpenWorldValue,
    setting = 'showMainStatisticsPanelPlayerDeathsOpenWorld',
    statKey = 'playerDeathsOpenWorld',
  },
  {
    label = playerDeathsBattlegroundLabel,
    value = playerDeathsBattlegroundValue,
    setting = 'showMainStatisticsPanelPlayerDeathsBattleground',
    statKey = 'playerDeathsBattleground',
  },
  {
    label = playerDeathsArenaLabel,
    value = playerDeathsArenaValue,
    setting = 'showMainStatisticsPanelPlayerDeathsArena',
    statKey = 'playerDeathsArena',
  },
}
for i = 1, #playerDeathStatRows do
  table.insert(statsElements, playerDeathStatRows[i])
end

local statsElementsRest = {
  {
  label = lowestHealthLabel,
  value = lowestHealthValue,
  setting = 'showMainStatisticsPanelLowestHealth',
  statKey = 'lowestHealth',
}, {
  label = lowestHealthThisLevelLabel,
  value = lowestHealthThisLevelValue,
  setting = 'showMainStatisticsPanelLowestHealthThisLevel',
  statKey = 'lowestHealthThisLevel',
}, {
  label = lowestHealthThisSessionLabel,
  value = lowestHealthThisSessionValue,
  setting = 'showMainStatisticsPanelLowestHealthThisSession',
  statKey = 'lowestHealthThisSession',
}, {
  label = blocksLabel,
  value = blocksValue,
  setting = 'showMainStatisticsPanelBlocks',
  statKey = 'blocks',
}, {
  label = parriesLabel,
  value = parriesValue,
  setting = 'showMainStatisticsPanelParries',
  statKey = 'parries',
}, {
  label = dodgesLabel,
  value = dodgesValue,
  setting = 'showMainStatisticsPanelDodges',
  statKey = 'dodges',
}, {
  label = resistsLabel,
  value = resistsValue,
  setting = 'showMainStatisticsPanelResists',
  statKey = 'resists',
}, {
  label = highestCritLabel,
  value = highestCritValue,
  setting = 'showMainStatisticsPanelHighestCritValue',
  statKey = 'highestCritValue',
}, {
  label = highestHealCritLabel,
  value = highestHealCritValue,
  setting = 'showMainStatisticsPanelHighestHealCritValue',
  statKey = 'highestHealCritValue',
}, {
  label = playerKillsLabel,
  value = playerKillsValue,
  setting = 'showMainStatisticsPanelPlayerKills',
  statKey = 'playerKills',
}, {
  label = duelsTotalLabel,
  value = duelsTotalValue,
  setting = 'showMainStatisticsPanelDuelsTotal',
  statKey = 'duelsTotal',
}, {
  label = duelsWonLabel,
  value = duelsWonValue,
  setting = 'showMainStatisticsPanelDuelsWon',
  statKey = 'duelsWon',
}, {
  label = duelsLostLabel,
  value = duelsLostValue,
  setting = 'showMainStatisticsPanelDuelsLost',
  statKey = 'duelsLost',
}, {
  label = duelsWinPercentLabel,
  value = duelsWinPercentValue,
  setting = 'showMainStatisticsPanelDuelsWinPercent',
  statKey = 'duelsWinPercent',
}, {
  label = goldGainedLabel,
  value = goldGainedValue,
  setting = 'showMainStatisticsPanelGoldGained',
  statKey = 'goldGained',
}, {
  label = goldSpentLabel,
  value = goldSpentValue,
  setting = 'showMainStatisticsPanelGoldSpent',
  statKey = 'goldSpent',
}, {
  label = enemiesLabel,
  value = enemiesValue,
  setting = 'showMainStatisticsPanelEnemiesSlain',
  statKey = 'enemiesSlain',
}, {
  label = elitesSlainLabel,
  value = elitesSlainValue,
  setting = 'showMainStatisticsPanelElitesSlain',
  statKey = 'elitesSlain',
}, {
  label = rareElitesSlainLabel,
  value = rareElitesSlainValue,
  setting = 'showMainStatisticsPanelRareElitesSlain',
  statKey = 'rareElitesSlain',
}, {
  label = worldBossesSlainLabel,
  value = worldBossesSlainValue,
  setting = 'showMainStatisticsPanelWorldBossesSlain',
  statKey = 'worldBossesSlain',
}, {
  label = dungeonBossesLabel,
  value = dungeonBossesValue,
  setting = 'showMainStatisticsPanelDungeonBosses',
  statKey = 'dungeonBossesKilled',
}, {
  label = dungeonsCompletedLabel,
  value = dungeonsCompletedValue,
  setting = 'showMainStatisticsPanelDungeonsCompleted',
  statKey = 'dungeonsCompleted',
}, {
  label = healthPotionsLabel,
  value = healthPotionsValue,
  setting = 'showMainStatisticsPanelHealthPotionsUsed',
  statKey = 'healthPotionsUsed',
}, {
  label = manaPotionsLabel,
  value = manaPotionsValue,
  setting = 'showMainStatisticsPanelManaPotionsUsed',
  statKey = 'manaPotionsUsed',
}, {
  label = bandagesLabel,
  value = bandagesValue,
  setting = 'showMainStatisticsPanelBandagesUsed',
  statKey = 'bandagesUsed',
}, {
  label = targetDummiesLabel,
  value = targetDummiesValue,
  setting = 'showMainStatisticsPanelTargetDummiesUsed',
  statKey = 'targetDummiesUsed',
}, {
  label = grenadesLabel,
  value = grenadesValue,
  setting = 'showMainStatisticsPanelGrenadesUsed',
  statKey = 'grenadesUsed',
}, {
  label = closeEscapesLabel,
  value = closeEscapesValue,
  setting = 'showMainStatisticsPanelCloseEscapes',
  statKey = 'closeEscapes',
}, {
  label = playerJumpsLabel,
  value = playerJumpsValue,
  setting = 'showMainStatisticsPanelPlayerJumps',
  statKey = 'playerJumps',
},
}

for i = 1, #statsElementsRest do
  table.insert(statsElements, statsElementsRest[i])
end

-- Create lookup table to reduce upvalues
local statLookup = {}
for _, element in ipairs(statsElements) do
  if element.statKey then
    statLookup[element.statKey] = element
  end
end

-- Extra space below the last visible row (inside the backdrop)
local MAIN_SCREEN_STATS_BOTTOM_PADDING = BOTTOM_PADDING

local function PlaceIdentityDivider(yOffset)
  identityDivider:ClearAllPoints()
  identityDivider:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', SIDE_INSET, yOffset)
  identityDivider:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -SIDE_INSET, yOffset)
  identityDivider:Show()
end

-- Function to update row visibility and positioning
local function UpdateRowVisibility()
  local yOffset = -TOP_PADDING
  local identityVisible = false
  local dividerPlaced = false

  local function ensureDividerBeforeStats()
    if identityVisible and not dividerPlaced then
      yOffset = yOffset - DIVIDER_GAP_ABOVE
      PlaceIdentityDivider(yOffset)
      yOffset = yOffset - 1 - DIVIDER_GAP_BELOW
      dividerPlaced = true
    end
  end

  for _, element in ipairs(statsElements) do
    local isVisible = false

    if ULTRA_STATISTICS_GLOBAL_SETTINGS and ULTRA_STATISTICS_GLOBAL_SETTINGS[element.setting] ~= nil then
      isVisible = ULTRA_STATISTICS_GLOBAL_SETTINGS[element.setting]
    else
      isVisible = false
    end

    if isVisible then
      local isIdentity = element.statKey == 'level' or element.statKey == 'guild'
      if not isIdentity then
        ensureDividerBeforeStats()
      end

      element.label:ClearAllPoints()
      element.value:ClearAllPoints()
      element.label:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', SIDE_INSET, yOffset)
      element.value:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -SIDE_INSET, yOffset)
      element.label:Show()
      -- Level row shows "Level {x} {race} {class}" in label only; hide value
      -- Guild row shows "<GuildName>" in label only
      if isIdentity then
        element.value:Hide()
        identityVisible = true
      else
        element.value:Show()
      end

      local rowHeight = ROW_HEIGHT
      if element.statKey == 'level' then
        rowHeight = HEADER_LEVEL_HEIGHT
      elseif element.statKey == 'guild' then
        rowHeight = HEADER_GUILD_HEIGHT
      end
      yOffset = yOffset - rowHeight
    else
      element.label:Hide()
      element.value:Hide()
    end
  end

  if identityVisible and not dividerPlaced then
    yOffset = yOffset - DIVIDER_GAP_ABOVE
    PlaceIdentityDivider(yOffset)
    yOffset = yOffset - 1
    dividerPlaced = true
  elseif not identityVisible then
    identityDivider:Hide()
  end

  local newHeight = math.max(36, -yOffset + MAIN_SCREEN_STATS_BOTTOM_PADDING)
  statsFrame:SetSize(PANEL_WIDTH, newHeight)
end

-- Make UpdateRowVisibility globally accessible
UltraStatsFrame = statsFrame
UltraStatsFrame.UpdateRowVisibility = UpdateRowVisibility

-- Hide the frame if the statistics setting is off
function CheckAddonEnabled()
  if not ULTRA_STATISTICS_GLOBAL_SETTINGS or not ULTRA_STATISTICS_GLOBAL_SETTINGS.showOnScreenStatistics then
    statsFrame:Hide()
  else
    statsFrame:Show()
    UpdateRowVisibility()
    ApplyStatsBackgroundOpacity()
  end
end
_G.CheckAddonEnabled = CheckAddonEnabled


local function FormatMoneyText(copper)
  copper = tonumber(copper) or 0
  if copper < 0 then
    copper = -copper
  end
  if copper == 0 then
    return '-'
  end
  local g = math.floor(copper / 10000)
  local s = math.floor((copper % 10000) / 100)
  local c = math.floor(copper % 100)

  local parts = {}
  local iconSize = 12
  if g > 0 then
    local goldIcon =
      string.format('|TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:0:0|t', iconSize, iconSize)
    table.insert(parts, string.format('%d%s', g, goldIcon))
  end
  if s > 0 then
    local silverIcon =
      string.format('|TInterface\\MoneyFrame\\UI-SilverIcon:%d:%d:0:0|t', iconSize, iconSize)
    table.insert(parts, string.format('%d%s', s, silverIcon))
  end
  -- Only show copper if it's non-zero.
  if c > 0 then
    local copperIcon =
      string.format('|TInterface\\MoneyFrame\\UI-CopperIcon:%d:%d:0:0|t', iconSize, iconSize)
    table.insert(parts, string.format('%d%s', c, copperIcon))
  end
  return (#parts > 0) and table.concat(parts, ' ') or '-'
end

-- Function to update all statistics (refactored to reduce upvalues)
function UpdateStatistics()
  if not UltraStatisticsDB then return end

  -- Helper to get stat element from lookup table
  local function getStat(statKey)
    return statLookup[statKey]
  end

  -- Update character level: show "Level {x} {race} {class}" with class colour
  local playerLevel = UnitLevel('player') or 1
  local raceName = UnitRace('player') or ''
  local className, classFileName = UnitClass('player')
  className = className or ''
  local levelStat = getStat('level')
  if levelStat then
    levelStat.label:SetText(string.format('Level %d %s %s', playerLevel, raceName, className))
    if classFileName and GetClassColor then
      local r, g, b = GetClassColor(classFileName)
      if r and g and b then
        levelStat.label:SetTextColor(r, g, b, 1)
      else
        levelStat.label:SetTextColor(0.9, 0.9, 0.85, 1)
      end
    else
      levelStat.label:SetTextColor(0.9, 0.9, 0.85, 1)
    end
    levelStat.value:Hide()
  end

  local guildStat = getStat('guild')
  if guildStat then
    local guildName = select(1, GetGuildInfo('player'))
    local gText = (guildName and guildName ~= '') and ('<' .. guildName .. '>') or 'Guildless'
    guildStat.label:SetText(gText)
    guildStat.label:SetTextColor(0.72, 0.72, 0.68, 1)
    guildStat.value:Hide()
  end

  -- Update total HP and Max Resource: show max *ever*, only update stored when current is higher
  local currentMaxHealth = UnitHealthMax('player') or 0
  local maxHealthEver = UltraStatisticsCharacterStats:GetStat('maxHealthEver') or 0
  if currentMaxHealth > maxHealthEver then
    UltraStatisticsCharacterStats:UpdateStat('maxHealthEver', currentMaxHealth)
    maxHealthEver = currentMaxHealth
  end
  local totalHPStat = getStat('totalHP')
  if totalHPStat then
    totalHPStat.value:SetText(UltraStatistics_FormatNumberWithCommas(maxHealthEver))
    totalHPStat.label:SetTextColor(1, 0.9, 0.5, 1)
    totalHPStat.value:SetTextColor(1, 1, 1, 1)
  end

  local resourceLabel, powerType = GetPlayerPrimaryResourceLabelAndType()
  local currentMaxResource = UnitPowerMax('player', powerType or MANA_POWER_TYPE) or 0
  local maxResourceEver = UltraStatisticsCharacterStats:GetStat('maxResourceEver') or 0
  if currentMaxResource > maxResourceEver then
    UltraStatisticsCharacterStats:UpdateStat('maxResourceEver', currentMaxResource)
    maxResourceEver = currentMaxResource
  end
  local maxResourceStat = getStat('maxResource')
  if maxResourceStat then
    maxResourceStat.value:SetText(UltraStatistics_FormatNumberWithCommas(maxResourceEver))
    maxResourceStat.label:SetText('Highest ' .. (resourceLabel or 'Resource') .. ':')
    maxResourceStat.label:SetTextColor(1, 0.9, 0.5, 1)
    maxResourceStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update enemies slain
  local enemies = UltraStatisticsCharacterStats:GetStat('enemiesSlain') or 0
  local enemiesStat = getStat('enemiesSlain')
  if enemiesStat then
    enemiesStat.value:SetText(UltraStatistics_FormatNumberWithCommas(enemies))
    enemiesStat.label:SetTextColor(1, 0.9, 0.5, 1)
    enemiesStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update pet deaths
  local petDeaths = UltraStatisticsCharacterStats:GetStat('petDeaths') or 0
  local petDeathsStat = getStat('petDeaths')
  if petDeathsStat then
    petDeathsStat.value:SetText(UltraStatistics_FormatNumberWithCommas(petDeaths))
    petDeathsStat.label:SetTextColor(1, 0.9, 0.5, 1)
    petDeathsStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update elites slain
  local elitesSlain = UltraStatisticsCharacterStats:GetStat('elitesSlain') or 0
  local elitesStat = getStat('elitesSlain')
  if elitesStat then
    elitesStat.value:SetText(UltraStatistics_FormatNumberWithCommas(elitesSlain))
    elitesStat.label:SetTextColor(1, 0.9, 0.5, 1)
    elitesStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update rare elites slain
  local rareElitesSlain = UltraStatisticsCharacterStats:GetStat('rareElitesSlain') or 0
  local rareElitesStat = getStat('rareElitesSlain')
  if rareElitesStat then
    rareElitesStat.value:SetText(UltraStatistics_FormatNumberWithCommas(rareElitesSlain))
    rareElitesStat.label:SetTextColor(1, 0.9, 0.5, 1)
    rareElitesStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update world bosses slain
  local worldBossesSlain = UltraStatisticsCharacterStats:GetStat('worldBossesSlain') or 0
  local worldBossesStat = getStat('worldBossesSlain')
  if worldBossesStat then
    worldBossesStat.value:SetText(UltraStatistics_FormatNumberWithCommas(worldBossesSlain))
    worldBossesStat.label:SetTextColor(1, 0.9, 0.5, 1)
    worldBossesStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update dungeon bosses slain
  local dungeonBosses = UltraStatisticsCharacterStats:GetStat('dungeonBossesKilled') or 0
  local dungeonBossesStat = getStat('dungeonBossesKilled')
  if dungeonBossesStat then
    dungeonBossesStat.value:SetText(UltraStatistics_FormatNumberWithCommas(dungeonBosses))
    dungeonBossesStat.label:SetTextColor(1, 0.9, 0.5, 1)
    dungeonBossesStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update dungeons completed
  local dungeonsCompleted = UltraStatisticsCharacterStats:GetStat('dungeonsCompleted') or 0
  local dungeonsCompletedStat = getStat('dungeonsCompleted')
  if dungeonsCompletedStat then
    dungeonsCompletedStat.value:SetText(UltraStatistics_FormatNumberWithCommas(dungeonsCompleted))
    dungeonsCompletedStat.label:SetTextColor(1, 0.9, 0.5, 1)
    dungeonsCompletedStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update survival statistics
  local healthPotions = UltraStatisticsCharacterStats:GetStat('healthPotionsUsed') or 0
  local healthPotionsStat = getStat('healthPotionsUsed')
  if healthPotionsStat then
    healthPotionsStat.value:SetText(UltraStatistics_FormatNumberWithCommas(healthPotions))
    healthPotionsStat.label:SetTextColor(1, 0.9, 0.5, 1)
    healthPotionsStat.value:SetTextColor(1, 1, 1, 1)
  end

  local manaPotions = UltraStatisticsCharacterStats:GetStat('manaPotionsUsed') or 0
  local manaPotionsStat = getStat('manaPotionsUsed')
  if manaPotionsStat then
    manaPotionsStat.value:SetText(UltraStatistics_FormatNumberWithCommas(manaPotions))
    manaPotionsStat.label:SetTextColor(1, 0.9, 0.5, 1)
    manaPotionsStat.value:SetTextColor(1, 1, 1, 1)
  end

  local bandages = UltraStatisticsCharacterStats:GetStat('bandagesUsed') or 0
  local bandagesStat = getStat('bandagesUsed')
  if bandagesStat then
    bandagesStat.value:SetText(UltraStatistics_FormatNumberWithCommas(bandages))
    bandagesStat.label:SetTextColor(1, 0.9, 0.5, 1)
    bandagesStat.value:SetTextColor(1, 1, 1, 1)
  end

  local targetDummies = UltraStatisticsCharacterStats:GetStat('targetDummiesUsed') or 0
  local targetDummiesStat = getStat('targetDummiesUsed')
  if targetDummiesStat then
    targetDummiesStat.value:SetText(UltraStatistics_FormatNumberWithCommas(targetDummies))
    targetDummiesStat.label:SetTextColor(1, 0.9, 0.5, 1)
    targetDummiesStat.value:SetTextColor(1, 1, 1, 1)
  end

  local grenades = UltraStatisticsCharacterStats:GetStat('grenadesUsed') or 0
  local grenadesStat = getStat('grenadesUsed')
  if grenadesStat then
    grenadesStat.value:SetText(UltraStatistics_FormatNumberWithCommas(grenades))
    grenadesStat.label:SetTextColor(1, 0.9, 0.5, 1)
    grenadesStat.value:SetTextColor(1, 1, 1, 1)
  end

  local partyDeaths = UltraStatisticsCharacterStats:GetStat('partyMemberDeaths') or 0
  local partyDeathsStat = getStat('partyMemberDeaths')
  if partyDeathsStat then
    partyDeathsStat.value:SetText(UltraStatistics_FormatNumberWithCommas(partyDeaths))
    -- Party deaths
    partyDeathsStat.label:SetTextColor(1, 0.9, 0.5, 1)
    partyDeathsStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Player deaths
  local playerDeaths = UltraStatisticsCharacterStats:GetStat('playerDeaths') or 0
  local playerDeathsStat = getStat('playerDeaths')
  if playerDeathsStat then
    playerDeathsStat.value:SetText(UltraStatistics_FormatNumberWithCommas(playerDeaths))
    playerDeathsStat.label:SetTextColor(1, 0.9, 0.5, 1)
    playerDeathsStat.value:SetTextColor(1, 1, 1, 1)
  end

  local serverDeaths = UltraStatisticsCharacterStats:GetServerDeaths() or 0
  local serverDeathsStat = getStat('serverDeaths')
  if serverDeathsStat then
    serverDeathsStat.value:SetText(UltraStatistics_FormatNumberWithCommas(serverDeaths))
    serverDeathsStat.label:SetTextColor(1, 0.9, 0.5, 1)
    serverDeathsStat.value:SetTextColor(1, 1, 1, 1)
  end

  local playerDeathsOpenWorld = UltraStatisticsCharacterStats:GetStat('playerDeathsOpenWorld') or 0
  local playerDeathsOpenWorldStat = getStat('playerDeathsOpenWorld')
  if playerDeathsOpenWorldStat then
    playerDeathsOpenWorldStat.value:SetText(UltraStatistics_FormatNumberWithCommas(playerDeathsOpenWorld))
    playerDeathsOpenWorldStat.label:SetTextColor(1, 0.9, 0.5, 1)
    playerDeathsOpenWorldStat.value:SetTextColor(1, 1, 1, 1)
  end

  local playerDeathsBattleground = UltraStatisticsCharacterStats:GetStat('playerDeathsBattleground') or 0
  local playerDeathsBattlegroundStat = getStat('playerDeathsBattleground')
  if playerDeathsBattlegroundStat then
    playerDeathsBattlegroundStat.value:SetText(UltraStatistics_FormatNumberWithCommas(playerDeathsBattleground))
    playerDeathsBattlegroundStat.label:SetTextColor(1, 0.9, 0.5, 1)
    playerDeathsBattlegroundStat.value:SetTextColor(1, 1, 1, 1)
  end

  local playerDeathsArena = UltraStatisticsCharacterStats:GetStat('playerDeathsArena') or 0
  local playerDeathsArenaStat = getStat('playerDeathsArena')
  if playerDeathsArenaStat then
    playerDeathsArenaStat.value:SetText(UltraStatistics_FormatNumberWithCommas(playerDeathsArena))
    playerDeathsArenaStat.label:SetTextColor(1, 0.9, 0.5, 1)
    playerDeathsArenaStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Lowest health (percent)
  local function formatLowestHealthPercent(val)
    local v = tonumber(val) or 100
    if v % 1 == 0 then
      return string.format('%d%%', v)
    end
    return string.format('%.1f%%', v)
  end
  local lowestHealth = UltraStatisticsCharacterStats:GetStat('lowestHealth') or 100
  local lowestHealthStat = getStat('lowestHealth')
  if lowestHealthStat then
    lowestHealthStat.value:SetText(formatLowestHealthPercent(lowestHealth))
    lowestHealthStat.label:SetTextColor(1, 0.9, 0.5, 1)
    lowestHealthStat.value:SetTextColor(0.85, 0.35, 0.3, 1)
  end
  local lowestHealthThisLevel = UltraStatisticsCharacterStats:GetStat('lowestHealthThisLevel') or 100
  local lowestHealthThisLevelStat = getStat('lowestHealthThisLevel')
  if lowestHealthThisLevelStat then
    lowestHealthThisLevelStat.value:SetText(formatLowestHealthPercent(lowestHealthThisLevel))
    lowestHealthThisLevelStat.label:SetTextColor(1, 0.9, 0.5, 1)
    lowestHealthThisLevelStat.value:SetTextColor(0.85, 0.35, 0.3, 1)
  end
  local lowestHealthThisSession = UltraStatisticsCharacterStats:GetStat('lowestHealthThisSession') or 100
  local lowestHealthThisSessionStat = getStat('lowestHealthThisSession')
  if lowestHealthThisSessionStat then
    lowestHealthThisSessionStat.value:SetText(formatLowestHealthPercent(lowestHealthThisSession))
    lowestHealthThisSessionStat.label:SetTextColor(1, 0.9, 0.5, 1)
    lowestHealthThisSessionStat.value:SetTextColor(0.85, 0.35, 0.3, 1)
  end

  local blocks = UltraStatisticsCharacterStats:GetStat('blocks') or 0
  local blocksStat = getStat('blocks')
  if blocksStat then
    blocksStat.value:SetText(UltraStatistics_FormatNumberWithCommas(blocks))
    blocksStat.label:SetTextColor(1, 0.9, 0.5, 1)
    blocksStat.value:SetTextColor(1, 1, 1, 1)
  end

  local parries = UltraStatisticsCharacterStats:GetStat('parries') or 0
  local parriesStat = getStat('parries')
  if parriesStat then
    parriesStat.value:SetText(UltraStatistics_FormatNumberWithCommas(parries))
    parriesStat.label:SetTextColor(1, 0.9, 0.5, 1)
    parriesStat.value:SetTextColor(1, 1, 1, 1)
  end

  local dodges = UltraStatisticsCharacterStats:GetStat('dodges') or 0
  local dodgesStat = getStat('dodges')
  if dodgesStat then
    dodgesStat.value:SetText(UltraStatistics_FormatNumberWithCommas(dodges))
    dodgesStat.label:SetTextColor(1, 0.9, 0.5, 1)
    dodgesStat.value:SetTextColor(1, 1, 1, 1)
  end

  local resists = UltraStatisticsCharacterStats:GetStat('resists') or 0
  local resistsStat = getStat('resists')
  if resistsStat then
    resistsStat.value:SetText(UltraStatistics_FormatNumberWithCommas(resists))
    resistsStat.label:SetTextColor(1, 0.9, 0.5, 1)
    resistsStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update highest crit value
  local highestCrit = UltraStatisticsCharacterStats:GetStat('highestCritValue') or 0
  local highestCritStat = getStat('highestCritValue')
  if highestCritStat then
    highestCritStat.value:SetText(UltraStatistics_FormatNumberWithCommas(highestCrit))
    highestCritStat.label:SetTextColor(1, 0.9, 0.5, 1)
    highestCritStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update highest heal crit value
  local highestHealCrit = UltraStatisticsCharacterStats:GetStat('highestHealCritValue') or 0
  local highestHealCritStat = getStat('highestHealCritValue')
  if highestHealCritStat then
    highestHealCritStat.value:SetText(UltraStatistics_FormatNumberWithCommas(highestHealCrit))
    highestHealCritStat.label:SetTextColor(1, 0.9, 0.5, 1)
    highestHealCritStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update close escape count
  local closeEscapes = UltraStatisticsCharacterStats:GetStat('closeEscapes') or 0
  local closeEscapesStat = getStat('closeEscapes')
  if closeEscapesStat then
    closeEscapesStat.value:SetText(UltraStatistics_FormatNumberWithCommas(closeEscapes))
    closeEscapesStat.label:SetTextColor(1, 0.9, 0.5, 1)
    closeEscapesStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update Player Kills value (PvP)
  local playerKills = UltraStatisticsCharacterStats:GetStat('playerKills') or 0
  local playerKillsStat = getStat('playerKills')
  if playerKillsStat then
    playerKillsStat.value:SetText(UltraStatistics_FormatNumberWithCommas(playerKills))
    playerKillsStat.label:SetTextColor(1, 0.9, 0.5, 1)
    playerKillsStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update Duels Total value
  local duelsTotal = UltraStatisticsCharacterStats:GetStat('duelsTotal') or 0
  local duelsTotalStat = getStat('duelsTotal')
  if duelsTotalStat then
    duelsTotalStat.value:SetText(UltraStatistics_FormatNumberWithCommas(duelsTotal))
    duelsTotalStat.label:SetTextColor(1, 0.9, 0.5, 1)
    duelsTotalStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update Duels Won value
  local duelsWon = UltraStatisticsCharacterStats:GetStat('duelsWon') or 0
  local duelsWonStat = getStat('duelsWon')
  if duelsWonStat then
    duelsWonStat.value:SetText(UltraStatistics_FormatNumberWithCommas(duelsWon))
    duelsWonStat.label:SetTextColor(1, 0.9, 0.5, 1)
    duelsWonStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update Duels Lost value
  local duelsLost = UltraStatisticsCharacterStats:GetStat('duelsLost') or 0
  local duelsLostStat = getStat('duelsLost')
  if duelsLostStat then
    duelsLostStat.value:SetText(UltraStatistics_FormatNumberWithCommas(duelsLost))
    duelsLostStat.label:SetTextColor(1, 0.9, 0.5, 1)
    duelsLostStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update Duels Win Percentage value (percent stat)
  local duelsWinPercent = UltraStatisticsCharacterStats:GetStat('duelsWinPercent') or 0
  local duelsWinPercentStat = getStat('duelsWinPercent')
  if duelsWinPercentStat then
    if duelsWinPercent % 1 == 0 then
      duelsWinPercentStat.value:SetText(string.format('%d%%', duelsWinPercent))
    else
      duelsWinPercentStat.value:SetText(string.format('%.1f%%', duelsWinPercent))
    end
    duelsWinPercentStat.label:SetTextColor(1, 0.9, 0.5, 1)
    duelsWinPercentStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update player jumps value
  local playerJumps = UltraStatisticsCharacterStats:GetStat('playerJumps') or 0
  local playerJumpsStat = getStat('playerJumps')
  if playerJumpsStat then
    playerJumpsStat.value:SetText(UltraStatistics_FormatNumberWithCommas(playerJumps))
    playerJumpsStat.label:SetTextColor(1, 0.9, 0.5, 1)
    playerJumpsStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Economy stats (money)
  local goldGained = UltraStatisticsCharacterStats:GetStat('goldGained') or 0
  local goldGainedStat = getStat('goldGained')
  if goldGainedStat then
    goldGainedStat.value:SetText(FormatMoneyText(goldGained))
    goldGainedStat.label:SetTextColor(1, 0.9, 0.5, 1)
    goldGainedStat.value:SetTextColor(1, 1, 1, 1)
  end

  local goldSpent = UltraStatisticsCharacterStats:GetStat('goldSpent') or 0
  local goldSpentStat = getStat('goldSpent')
  if goldSpentStat then
    goldSpentStat.value:SetText(FormatMoneyText(goldSpent))
    goldSpentStat.label:SetTextColor(1, 0.9, 0.5, 1)
    goldSpentStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update row visibility after updating values
  UpdateRowVisibility()
end

-- Register events to update statistics when they change
statsFrame:RegisterEvent('UNIT_HEALTH_FREQUENT')
statsFrame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
statsFrame:RegisterEvent('PLAYER_LEVEL_UP')
statsFrame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
statsFrame:RegisterEvent('UNIT_MAXHEALTH')
statsFrame:RegisterEvent('UNIT_MAXPOWER')
statsFrame:RegisterEvent('PLAYER_LOGIN') -- Player entity and world are ready. Addon database and C_ APIs are safe to access.
statsFrame:RegisterEvent('PLAYER_GUILD_UPDATE')
statsFrame:SetScript('OnEvent', function(self, event, ...)
  if event == 'PLAYER_LOGIN' then
    CheckAddonEnabled()
    UpdateStatistics()
  elseif event == 'UNIT_HEALTH_FREQUENT' then
    -- Update lowest health when health changes
    UpdateStatistics()
  elseif event == 'UNIT_MAXHEALTH' or event == 'UNIT_MAXPOWER' then
    local unit = ...
    if unit == 'player' then
      UpdateStatistics()
    end
  elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
    -- Update kill counts when combat events occur
    UpdateStatistics()
  elseif event == 'PLAYER_LEVEL_UP' then
    -- Update XP when leveling up
    UpdateStatistics()
  elseif event == 'PLAYER_EQUIPMENT_CHANGED' or event == 'PLAYER_GUILD_UPDATE' then
    UpdateStatistics()
  end
end)

-- Slash command to reset statistics frame to its saved position
local function ResetStatsFrameToSavedPosition()
  if not UltraStatisticsDB then return end
  statsFrame:ClearAllPoints()
  local pos = UltraStatisticsDB and UltraStatisticsDB.statsFramePosition or nil
  if pos then
    local point = pos.point or 'TOPLEFT'
    local relPoint = pos.relPoint or pos.relativePoint or 'TOPLEFT'
    local x = pos.x or pos.xOfs or 130
    local y = pos.y or pos.yOfs or -10
    statsFrame:SetPoint(point, UIParent, relPoint, x, y)
  else
    statsFrame:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 130, -10)
  end
end

-- Reset statistics frame to default position
local function ResetStatsFramePosition()
  statsFrame:ClearAllPoints()
  statsFrame:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 130, -10)
  if UltraStatisticsDB then
    UltraStatisticsDB.statsFramePosition = nil
  end
  if SaveUltraStatisticsDBData then
    SaveUltraStatisticsDBData('statsFramePosition', nil)
  end
  print('|cfff44336[STATS]|r Statistics panel position reset to default.')
end

-- Make ResetStatsFramePosition globally accessible for combined reset commands
_G.ResetStatsFramePosition = ResetStatsFramePosition

SLASH_UHCSTATSRESET1 = '/uhcstatsreset'
SLASH_UHCSTATSRESET2 = '/uhcsr'
SlashCmdList['UHCSTATSRESET'] = ResetStatsFrameToSavedPosition

-- Initial check with delay to ensure ULTRA_STATISTICS_GLOBAL_SETTINGS is loaded
C_Timer.After(1, function()
  CheckAddonEnabled()
  ApplyStatsBackgroundOpacity()
end)
