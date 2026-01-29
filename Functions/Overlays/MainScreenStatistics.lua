-- Main Screen Statistics Display
-- Shows the same statistics that appear in the settings panel, but on the main screen at all times

-- Create the main statistics frame with backdrop styling
local statsFrame = CreateFrame('Frame', 'UltraStatsFrame', UIParent, 'BackdropTemplate')
statsFrame:SetSize(220, 360) -- Increased width for better spacing
statsFrame:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 130, -10)

-- Enhanced backdrop styling with decorative border
statsFrame:SetBackdrop({
  bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
  edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
  tile = true,
  tileSize = 32,
  edgeSize = 16,
  insets = {
    left = 6,
    right = 6,
    top = 6,
    bottom = 6,
  },
})

-- Background behind statistics with configurable opacity
local statsBackground = statsFrame:CreateTexture(nil, 'BACKGROUND')
statsBackground:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 2, -2)
statsBackground:SetPoint('BOTTOMRIGHT', statsFrame, 'BOTTOMRIGHT', -2, 2)
statsBackground:SetColorTexture(0, 0, 0, 0.3)

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
  if GLOBAL_SETTINGS and GLOBAL_SETTINGS.statisticsBackgroundOpacity ~= nil then
    alpha = GLOBAL_SETTINGS.statisticsBackgroundOpacity
  end
  -- Clamp between 0 and 1
  if alpha < 0 then
    alpha = 0
  end
  if alpha > 1 then
    alpha = 1
  end
  statsBackground:SetColorTexture(0, 0, 0, alpha)
  -- Also update backdrop color
  statsFrame:SetBackdropColor(0.1, 0.1, 0.1, alpha * 0.9)

  -- Border opacity
  local borderAlpha = 0.9
  if GLOBAL_SETTINGS and GLOBAL_SETTINGS.statisticsBorderOpacity ~= nil then
    borderAlpha = GLOBAL_SETTINGS.statisticsBorderOpacity
  end
  -- Clamp between 0 and 1
  if borderAlpha < 0 then
    borderAlpha = 0
  end
  if borderAlpha > 1 then
    borderAlpha = 1
  end
  statsFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, borderAlpha) -- Light grey decorative border
end

-- Expose globally for instant UI updates
_G.ApplyStatsBackgroundOpacity = ApplyStatsBackgroundOpacity

ApplyStatsBackgroundOpacity()

-- Make the frame draggable
MakeFrameDraggable(statsFrame)

-- Helper function to create font strings with standard WoW font
-- Available fonts: FRIZQT__.TTF (standard), ARIALN.TTF (narrow), MORPHEUS.TTF (serif), SKURRI.TTF
-- Available styles: '' (none), 'OUTLINE', 'THICKOUTLINE', 'MONOCHROME', 'MONOCHROME,OUTLINE'
local function CreatePixelFontString(parent, layer, template)
  local fontString = parent:CreateFontString(nil, layer, template)
  -- Use standard WoW font with slightly larger size for better readability
  fontString:SetFont('Fonts\\FRIZQT__.TTF', 13, 'OUTLINE')
  fontString:SetTextColor(0.9, 0.9, 0.85, 1) -- Slightly off-white for better contrast
  return fontString
end

-- Create statistics text elements
-- Character Level at the top
local levelLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
levelLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -8)
levelLabel:SetText('Level:')
levelLabel:SetTextColor(1, 0.9, 0.5, 1) -- Gold color for labels
local levelValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
levelValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -8)
levelValue:SetText(formatNumberWithCommas(1))
levelValue:SetTextColor(1, 1, 1, 1) -- White for values
local totalHPLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
totalHPLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -23)
totalHPLabel:SetText('Highest Health:')
totalHPLabel:SetTextColor(1, 0.9, 0.5, 1)

local totalHPValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
totalHPValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -23)
totalHPValue:SetText(formatNumberWithCommas(UnitHealthMax('player') or 0))
totalHPValue:SetTextColor(1, 0.2, 0.2, 1) -- Red tint for HP
local totalManaLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
totalManaLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -38)
totalManaLabel:SetText('Highest Resource:')
totalManaLabel:SetTextColor(1, 0.9, 0.5, 1)

local totalManaValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
totalManaValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -38)
do
  local _, powerType = GetPlayerPrimaryResourceLabelAndType()
  totalManaValue:SetText(
    formatNumberWithCommas(UnitPowerMax('player', powerType or MANA_POWER_TYPE) or 0)
  )
end
totalManaValue:SetTextColor(1, 1, 1, 1)
local enemiesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
enemiesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -98)
enemiesLabel:SetText('Enemies Slain:')
enemiesLabel:SetTextColor(1, 0.9, 0.5, 1)

local enemiesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
enemiesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -98)
enemiesValue:SetText(formatNumberWithCommas(0))
enemiesValue:SetTextColor(1, 1, 1, 1)

local dungeonsCompletedLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
dungeonsCompletedLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -113)
dungeonsCompletedLabel:SetText('Dungeons Completed:')
dungeonsCompletedLabel:SetTextColor(1, 0.9, 0.5, 1)
local dungeonsCompletedValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
dungeonsCompletedValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -113)
dungeonsCompletedValue:SetText(formatNumberWithCommas(0))
dungeonsCompletedValue:SetTextColor(1, 1, 1, 1)
-- Additional statistics rows
local petDeathsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
petDeathsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -128)
petDeathsLabel:SetText('Pet Deaths:')
petDeathsLabel:SetTextColor(1, 0.9, 0.5, 1)
local petDeathsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
petDeathsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -128)
petDeathsValue:SetText(formatNumberWithCommas(0))
petDeathsValue:SetTextColor(1, 0.3, 0.3, 1)
local elitesSlainLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
elitesSlainLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -143)
elitesSlainLabel:SetText('Elites Slain:')
elitesSlainLabel:SetTextColor(1, 0.9, 0.5, 1)
local elitesSlainValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
elitesSlainValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -143)
elitesSlainValue:SetText(formatNumberWithCommas(0))
elitesSlainValue:SetTextColor(1, 1, 1, 1)
local rareElitesSlainLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
rareElitesSlainLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -158)
rareElitesSlainLabel:SetText('Rare Elites Slain:')
rareElitesSlainLabel:SetTextColor(1, 0.9, 0.5, 1)
local rareElitesSlainValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
rareElitesSlainValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -158)
rareElitesSlainValue:SetText(formatNumberWithCommas(0))
rareElitesSlainValue:SetTextColor(1, 0.8, 0.2, 1) -- Gold tint for rare
local worldBossesSlainLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
worldBossesSlainLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -173)
worldBossesSlainLabel:SetText('World Bosses Slain:')
worldBossesSlainLabel:SetTextColor(1, 0.9, 0.5, 1)
local worldBossesSlainValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
worldBossesSlainValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -173)
worldBossesSlainValue:SetText(formatNumberWithCommas(0))
worldBossesSlainValue:SetTextColor(1, 0.5, 0, 1) -- Orange tint for world bosses
local dungeonBossesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
dungeonBossesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -188)
dungeonBossesLabel:SetText('Dungeon Bosses:')
dungeonBossesLabel:SetTextColor(1, 0.9, 0.5, 1)
local dungeonBossesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
dungeonBossesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -188)
dungeonBossesValue:SetText(formatNumberWithCommas(0))
dungeonBossesValue:SetTextColor(0.8, 0.2, 0.8, 1) -- Purple tint for dungeon bosses
-- Survival statistics rows
local healthPotionsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
healthPotionsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -203)
healthPotionsLabel:SetText('Health Potions:')
healthPotionsLabel:SetTextColor(1, 0.9, 0.5, 1)
local healthPotionsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
healthPotionsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -203)
healthPotionsValue:SetText(formatNumberWithCommas(0))
healthPotionsValue:SetTextColor(1, 0.3, 0.3, 1)
local manaPotionsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
manaPotionsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -218)
manaPotionsLabel:SetText('Mana Potions:')
manaPotionsLabel:SetTextColor(1, 0.9, 0.5, 1)
local manaPotionsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
manaPotionsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -218)
manaPotionsValue:SetText(formatNumberWithCommas(0))
manaPotionsValue:SetTextColor(0.3, 0.7, 1, 1)
local bandagesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
bandagesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -233)
bandagesLabel:SetText('Bandages Used:')
bandagesLabel:SetTextColor(1, 0.9, 0.5, 1)
local bandagesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
bandagesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -233)
bandagesValue:SetText(formatNumberWithCommas(0))
bandagesValue:SetTextColor(1, 1, 1, 1)
local targetDummiesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
targetDummiesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -248)
targetDummiesLabel:SetText('Target Dummies:')
targetDummiesLabel:SetTextColor(1, 0.9, 0.5, 1)
local targetDummiesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
targetDummiesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -248)
targetDummiesValue:SetText(formatNumberWithCommas(0))
targetDummiesValue:SetTextColor(1, 1, 1, 1)
local grenadesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
grenadesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -263)
grenadesLabel:SetText('Grenades Used:')
grenadesLabel:SetTextColor(1, 0.9, 0.5, 1)
local grenadesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
grenadesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -263)
grenadesValue:SetText(formatNumberWithCommas(0))
grenadesValue:SetTextColor(1, 0.5, 0, 1) -- Orange for grenades
local partyDeathsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
partyDeathsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -278)
partyDeathsLabel:SetText('Party Deaths:')
partyDeathsLabel:SetTextColor(1, 0.9, 0.5, 1)
local partyDeathsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
partyDeathsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -278)
partyDeathsValue:SetText(formatNumberWithCommas(0))
partyDeathsValue:SetTextColor(1, 0.2, 0.2, 1) -- Red for deaths
-- Player Deaths rows
local playerDeathsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -293)
playerDeathsLabel:SetText('Deaths (Total):')
playerDeathsLabel:SetTextColor(1, 0.9, 0.5, 1)
local playerDeathsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -293)
playerDeathsValue:SetText(formatNumberWithCommas(0))
playerDeathsValue:SetTextColor(1, 0.2, 0.2, 1)

-- Player Deaths breakdown rows
local playerDeathsOpenWorldLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsOpenWorldLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -308)
playerDeathsOpenWorldLabel:SetText('Deaths (Open World):')
playerDeathsOpenWorldLabel:SetTextColor(1, 0.9, 0.5, 1)
local playerDeathsOpenWorldValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsOpenWorldValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -308)
playerDeathsOpenWorldValue:SetText(formatNumberWithCommas(0))
playerDeathsOpenWorldValue:SetTextColor(1, 0.2, 0.2, 1)

local playerDeathsBattlegroundLabel =
  CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsBattlegroundLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -323)
playerDeathsBattlegroundLabel:SetText('Deaths (Battleground):')
playerDeathsBattlegroundLabel:SetTextColor(1, 0.9, 0.5, 1)
local playerDeathsBattlegroundValue =
  CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsBattlegroundValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -323)
playerDeathsBattlegroundValue:SetText(formatNumberWithCommas(0))
playerDeathsBattlegroundValue:SetTextColor(1, 0.2, 0.2, 1)

local playerDeathsDungeonLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsDungeonLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -338)
playerDeathsDungeonLabel:SetText('Deaths (Dungeon):')
playerDeathsDungeonLabel:SetTextColor(1, 0.9, 0.5, 1)
local playerDeathsDungeonValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsDungeonValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -338)
playerDeathsDungeonValue:SetText(formatNumberWithCommas(0))
playerDeathsDungeonValue:SetTextColor(1, 0.2, 0.2, 1)

local playerDeathsHeroicDungeonLabel =
  CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsHeroicDungeonLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -353)
playerDeathsHeroicDungeonLabel:SetText('Deaths (Heroic Dungeon):')
playerDeathsHeroicDungeonLabel:SetTextColor(1, 0.9, 0.5, 1)
local playerDeathsHeroicDungeonValue =
  CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsHeroicDungeonValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -353)
playerDeathsHeroicDungeonValue:SetText(formatNumberWithCommas(0))
playerDeathsHeroicDungeonValue:SetTextColor(1, 0.2, 0.2, 1)

local playerDeathsRaidLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsRaidLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -368)
playerDeathsRaidLabel:SetText('Deaths (Raid):')
playerDeathsRaidLabel:SetTextColor(1, 0.9, 0.5, 1)
local playerDeathsRaidValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsRaidValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -368)
playerDeathsRaidValue:SetText(formatNumberWithCommas(0))
playerDeathsRaidValue:SetTextColor(1, 0.2, 0.2, 1)

local playerDeathsArenaLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsArenaLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -383)
playerDeathsArenaLabel:SetText('Deaths (Arena):')
playerDeathsArenaLabel:SetTextColor(1, 0.9, 0.5, 1)
local playerDeathsArenaValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerDeathsArenaValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -383)
playerDeathsArenaValue:SetText(formatNumberWithCommas(0))
playerDeathsArenaValue:SetTextColor(1, 0.2, 0.2, 1)

-- Avoidance rows
local blocksLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
blocksLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -338)
blocksLabel:SetText('Blocks:')
blocksLabel:SetTextColor(1, 0.9, 0.5, 1)
local blocksValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
blocksValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -338)
blocksValue:SetText(formatNumberWithCommas(0))
blocksValue:SetTextColor(1, 1, 1, 1)

local parriesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
parriesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -353)
parriesLabel:SetText('Parries:')
parriesLabel:SetTextColor(1, 0.9, 0.5, 1)
local parriesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
parriesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -353)
parriesValue:SetText(formatNumberWithCommas(0))
parriesValue:SetTextColor(1, 1, 1, 1)

local dodgesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
dodgesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -368)
dodgesLabel:SetText('Dodges:')
dodgesLabel:SetTextColor(1, 0.9, 0.5, 1)
local dodgesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
dodgesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -368)
dodgesValue:SetText(formatNumberWithCommas(0))
dodgesValue:SetTextColor(1, 1, 1, 1)

local resistsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
resistsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -383)
resistsLabel:SetText('Resists:')
resistsLabel:SetTextColor(1, 0.9, 0.5, 1)
local resistsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
resistsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -383)
resistsValue:SetText(formatNumberWithCommas(0))
resistsValue:SetTextColor(1, 1, 1, 1)
-- Highest crit value row
local highestCritLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
highestCritLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -293)
highestCritLabel:SetText('Highest Crit:')
highestCritLabel:SetTextColor(1, 0.9, 0.5, 1)
local highestCritValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
highestCritValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -293)
highestCritValue:SetText(formatNumberWithCommas(0))
highestCritValue:SetTextColor(1, 0.8, 0, 1) -- Gold for crits
-- Highest heal crit value row
local highestHealCritLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
highestHealCritLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -308)
highestHealCritLabel:SetText('Highest Heal Crit:')
highestHealCritLabel:SetTextColor(1, 0.9, 0.5, 1)
local highestHealCritValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
highestHealCritValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -308)
highestHealCritValue:SetText(formatNumberWithCommas(0))
highestHealCritValue:SetTextColor(0.2, 1, 0.2, 1) -- Green for heals
-- Close escape count row
local closeEscapesLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
closeEscapesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -323)
closeEscapesLabel:SetText('Close Escapes:')
closeEscapesLabel:SetTextColor(1, 0.9, 0.5, 1)
local closeEscapesValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
closeEscapesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -323)
closeEscapesValue:SetText(formatNumberWithCommas(0))
closeEscapesValue:SetTextColor(0.5, 1, 0.5, 1) -- Light green for escapes
-- Duels Total value row
local duelsTotalLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsTotalLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -338)
duelsTotalLabel:SetText('Duels Total:')
duelsTotalLabel:SetTextColor(1, 0.9, 0.5, 1)
local duelsTotalValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsTotalValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -338)
duelsTotalValue:SetText(formatNumberWithCommas(0))
duelsTotalValue:SetTextColor(1, 1, 1, 1)
-- Duels Won value row
local duelsWonLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsWonLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -353)
duelsWonLabel:SetText('Duels Won:')
duelsWonLabel:SetTextColor(1, 0.9, 0.5, 1)
local duelsWonValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsWonValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -353)
duelsWonValue:SetText(formatNumberWithCommas(0))
duelsWonValue:SetTextColor(0.2, 1, 0.2, 1) -- Green for wins
-- Duels Lost value row
local duelsLostLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsLostLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -368)
duelsLostLabel:SetText('Duels Lost:')
duelsLostLabel:SetTextColor(1, 0.9, 0.5, 1)
local duelsLostValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsLostValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -368)
duelsLostValue:SetText(formatNumberWithCommas(0))
duelsLostValue:SetTextColor(1, 0.3, 0.3, 1) -- Red for losses
-- Duels Win Percentage
local duelsWinPercentLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsWinPercentLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -383)
duelsWinPercentLabel:SetText('Duel Win Percent:')
duelsWinPercentLabel:SetTextColor(1, 0.9, 0.5, 1)
local duelsWinPercentValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
duelsWinPercentValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -383)
duelsWinPercentValue:SetText('100%')
duelsWinPercentValue:SetTextColor(1, 1, 1, 1)
-- Player Jumps because who doesn't want to know how much they jump. ;)
local playerJumpsLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerJumpsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -398)
playerJumpsLabel:SetText('Jumps:')
playerJumpsLabel:SetTextColor(1, 0.9, 0.5, 1)
local playerJumpsValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
playerJumpsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -398)
playerJumpsValue:SetText(formatNumberWithCommas(0))
playerJumpsValue:SetTextColor(1, 1, 1, 1)
-- Player 360s (full spins during jumps)
local player360sLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
player360sLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -413)
player360sLabel:SetText('Jump 360s:')
player360sLabel:SetTextColor(1, 0.9, 0.5, 1)
local player360sValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
player360sValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -413)
player360sValue:SetText(formatNumberWithCommas(0))
player360sValue:SetTextColor(1, 1, 1, 1)

-- Economy statistics
local goldGainedLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
goldGainedLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -443)
goldGainedLabel:SetText('Gold Gained:')
goldGainedLabel:SetTextColor(1, 0.9, 0.5, 1)
local goldGainedValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
goldGainedValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -443)
goldGainedValue:SetText('-')
goldGainedValue:SetTextColor(1, 1, 1, 1)

local goldSpentLabel = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
goldSpentLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, -458)
goldSpentLabel:SetText('Gold Spent:')
goldSpentLabel:SetTextColor(1, 0.9, 0.5, 1)
local goldSpentValue = CreatePixelFontString(statsFrame, 'OVERLAY', 'GameFontHighlight')
goldSpentValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, -458)
goldSpentValue:SetText('-')
goldSpentValue:SetTextColor(1, 1, 1, 1)

-- Network statistics
-- XP Gained With Addon

-- Store all statistics elements for easy management
-- Non-tier stats first (noTier flag, percent types, or not in config), then tiered stats
local statsElements = { -- Non-tier stats (no tier system)
{
  label = levelLabel,
  value = levelValue,
  setting = 'showMainStatisticsPanelLevel',
  statKey = 'level',
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
}, {
  label = playerDeathsLabel,
  value = playerDeathsValue,
  setting = 'showMainStatisticsPanelPlayerDeaths',
  statKey = 'playerDeaths',
}, {
  label = playerDeathsOpenWorldLabel,
  value = playerDeathsOpenWorldValue,
  setting = 'showMainStatisticsPanelPlayerDeathsOpenWorld',
  statKey = 'playerDeathsOpenWorld',
}, {
  label = playerDeathsBattlegroundLabel,
  value = playerDeathsBattlegroundValue,
  setting = 'showMainStatisticsPanelPlayerDeathsBattleground',
  statKey = 'playerDeathsBattleground',
}, {
  label = playerDeathsDungeonLabel,
  value = playerDeathsDungeonValue,
  setting = 'showMainStatisticsPanelPlayerDeathsDungeon',
  statKey = 'playerDeathsDungeon',
}, {
  label = playerDeathsHeroicDungeonLabel,
  value = playerDeathsHeroicDungeonValue,
  setting = 'showMainStatisticsPanelPlayerDeathsHeroicDungeon',
  statKey = 'playerDeathsHeroicDungeon',
}, {
  label = playerDeathsRaidLabel,
  value = playerDeathsRaidValue,
  setting = 'showMainStatisticsPanelPlayerDeathsRaid',
  statKey = 'playerDeathsRaid',
}, {
  label = playerDeathsArenaLabel,
  value = playerDeathsArenaValue,
  setting = 'showMainStatisticsPanelPlayerDeathsArena',
  statKey = 'playerDeathsArena',
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
  -- Tiered stats (with tier system)
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
}, {
  label = player360sLabel,
  value = player360sValue,
  setting = 'showMainStatisticsPanelPlayer360s',
  statKey = 'player360s',
} }

-- Create lookup table to reduce upvalues
local statLookup = {}
for _, element in ipairs(statsElements) do
  if element.statKey then
    statLookup[element.statKey] = element
  end
end

-- Function to update row visibility and positioning
local function UpdateRowVisibility()
  local yOffset = -8
  local visibleRows = 0

  for _, element in ipairs(statsElements) do
    local isVisible = false

    if GLOBAL_SETTINGS and GLOBAL_SETTINGS[element.setting] ~= nil then
      -- Use the actual setting value
      isVisible = GLOBAL_SETTINGS[element.setting]
    else
      isVisible = false
    end

    if isVisible then
      -- Clear previous anchors to avoid conflicting points building up over time
      element.label:ClearAllPoints()
      element.value:ClearAllPoints()
      element.label:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 12, yOffset)
      element.value:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -12, yOffset)
      element.label:Show()
      element.value:Show()
      yOffset = yOffset - 16
      visibleRows = visibleRows + 1
    else
      element.label:Hide()
      element.value:Hide()
    end
  end

  -- Adjust frame height based on visible rows
  local newHeight = math.max(20, visibleRows * 16 + 16)
  statsFrame:SetSize(220, newHeight)
end

-- Make UpdateRowVisibility globally accessible
UltraStatsFrame = statsFrame
UltraStatsFrame.UpdateRowVisibility = UpdateRowVisibility

-- Hide the frame if the statistics setting is off
local function CheckAddonEnabled()
  if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS.showOnScreenStatistics then
    statsFrame:Hide()
  else
    statsFrame:Show()
    UpdateRowVisibility()
    ApplyStatsBackgroundOpacity()
  end
end

-- Helper function to calculate tier color for a statistic (using same logic as StatisticsTab.lua)
local function GetTierColorForStat(statKey, value)
  -- Use global tier configs from StatisticsTab.lua if available
  if not _G.ULTRA_STAT_BAR_CONFIG or not _G.ULTRA_TIER_COLORS then
    return nil -- Fallback to default colors if not available
  end

  local cfg = _G.ULTRA_STAT_BAR_CONFIG[statKey] or _G.ULTRA_STAT_BAR_CONFIG.default

  -- Skip tier calculation for percent stats or stats with noTier flag
  if cfg.type == 'percent' or cfg.noTier then
    return nil
  end

  -- Calculate tier using the same logic as StatisticsTab.lua
  local base = cfg.base or _G.ULTRA_STAT_BAR_CONFIG.default.base
  local multiplier = cfg.multiplier or _G.ULTRA_STAT_BAR_CONFIG.default.multiplier
  if multiplier <= 1 then
    multiplier = _G.ULTRA_STAT_BAR_CONFIG.default.multiplier
  end

  local currentValue = math.max(0, value or 0)
  if base <= 0 then
    return nil
  end

  local tier = 1
  local tierMax = base

  -- Inclusive boundary: hitting the max of a tier counts as entering the next tier
  while currentValue >= tierMax do
    tier = tier + 1
    tierMax = tierMax * multiplier
  end

  -- Get tier color
  local tierColorIndex = math.min(tier, #_G.ULTRA_TIER_COLORS)
  return _G.ULTRA_TIER_COLORS[tierColorIndex] or nil
end

-- Helper function to apply tier color to label and value
local function ApplyTierColor(statKey, value, label, valueElement)
  local tierColor = GetTierColorForStat(statKey, value)
  if tierColor then
    -- Apply tier color to both label and value
    label:SetTextColor(tierColor[1], tierColor[2], tierColor[3], 1)
    valueElement:SetTextColor(tierColor[1], tierColor[2], tierColor[3], 1)
  else
    -- Use default colors if no tier
    label:SetTextColor(1, 0.9, 0.5, 1) -- Gold for labels
    valueElement:SetTextColor(1, 1, 1, 1) -- White for values
  end
end

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

  -- Update character level
  local playerLevel = UnitLevel('player') or 1
  local levelStat = getStat('level')
  if levelStat then
    levelStat.value:SetText(formatNumberWithCommas(playerLevel))
    levelStat.label:SetTextColor(1, 0.9, 0.5, 1)
    levelStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update total HP and Max Resource: show max *ever*, only update stored when current is higher
  local currentMaxHealth = UnitHealthMax('player') or 0
  local maxHealthEver = CharacterStats:GetStat('maxHealthEver') or 0
  if currentMaxHealth > maxHealthEver then
    CharacterStats:UpdateStat('maxHealthEver', currentMaxHealth)
    maxHealthEver = currentMaxHealth
  end
  local totalHPStat = getStat('totalHP')
  if totalHPStat then
    totalHPStat.value:SetText(formatNumberWithCommas(maxHealthEver))
    totalHPStat.label:SetTextColor(1, 0.9, 0.5, 1)
    totalHPStat.value:SetTextColor(1, 1, 1, 1) -- White for non-tier stats
  end

  local resourceLabel, powerType = GetPlayerPrimaryResourceLabelAndType()
  local currentMaxResource = UnitPowerMax('player', powerType or MANA_POWER_TYPE) or 0
  local maxResourceEver = CharacterStats:GetStat('maxResourceEver') or 0
  if currentMaxResource > maxResourceEver then
    CharacterStats:UpdateStat('maxResourceEver', currentMaxResource)
    maxResourceEver = currentMaxResource
  end
  local maxResourceStat = getStat('maxResource')
  if maxResourceStat then
    maxResourceStat.value:SetText(formatNumberWithCommas(maxResourceEver))
    maxResourceStat.label:SetText('Highest ' .. (resourceLabel or 'Resource') .. ':')
    maxResourceStat.label:SetTextColor(1, 0.9, 0.5, 1)
    maxResourceStat.value:SetTextColor(1, 1, 1, 1) -- White for non-tier stats
  end

  -- Update enemies slain
  local enemies = CharacterStats:GetStat('enemiesSlain') or 0
  local enemiesStat = getStat('enemiesSlain')
  if enemiesStat then
    enemiesStat.value:SetText(formatNumberWithCommas(enemies))
    ApplyTierColor('enemiesSlain', enemies, enemiesStat.label, enemiesStat.value)
  end

  -- Update dungeons completed
  local dungeonsCompleted = CharacterStats:GetStat('dungeonsCompleted') or 0
  local dungeonsStat = getStat('dungeonsCompleted')
  if dungeonsStat then
    dungeonsStat.value:SetText(formatNumberWithCommas(dungeonsCompleted))
    ApplyTierColor('dungeonsCompleted', dungeonsCompleted, dungeonsStat.label, dungeonsStat.value)
  end

  -- Update pet deaths (noTier flag)
  local petDeaths = CharacterStats:GetStat('petDeaths') or 0
  local petDeathsStat = getStat('petDeaths')
  if petDeathsStat then
    petDeathsStat.value:SetText(formatNumberWithCommas(petDeaths))
    petDeathsStat.label:SetTextColor(1, 0.9, 0.5, 1)
    petDeathsStat.value:SetTextColor(1, 1, 1, 1) -- White for non-tier stats
  end

  -- Update elites slain
  local elitesSlain = CharacterStats:GetStat('elitesSlain') or 0
  local elitesStat = getStat('elitesSlain')
  if elitesStat then
    elitesStat.value:SetText(formatNumberWithCommas(elitesSlain))
    ApplyTierColor('elitesSlain', elitesSlain, elitesStat.label, elitesStat.value)
  end

  -- Update rare elites slain
  local rareElitesSlain = CharacterStats:GetStat('rareElitesSlain') or 0
  local rareElitesStat = getStat('rareElitesSlain')
  if rareElitesStat then
    rareElitesStat.value:SetText(formatNumberWithCommas(rareElitesSlain))
    ApplyTierColor('rareElitesSlain', rareElitesSlain, rareElitesStat.label, rareElitesStat.value)
  end

  -- Update world bosses slain
  local worldBossesSlain = CharacterStats:GetStat('worldBossesSlain') or 0
  local worldBossesStat = getStat('worldBossesSlain')
  if worldBossesStat then
    worldBossesStat.value:SetText(formatNumberWithCommas(worldBossesSlain))
    ApplyTierColor(
      'worldBossesSlain',
      worldBossesSlain,
      worldBossesStat.label,
      worldBossesStat.value
    )
  end

  -- Update dungeon bosses slain
  local dungeonBosses = CharacterStats:GetStat('dungeonBossesKilled') or 0
  local dungeonBossesStat = getStat('dungeonBossesKilled')
  if dungeonBossesStat then
    dungeonBossesStat.value:SetText(formatNumberWithCommas(dungeonBosses))
    ApplyTierColor(
      'dungeonBossesKilled',
      dungeonBosses,
      dungeonBossesStat.label,
      dungeonBossesStat.value
    )
  end

  -- Update survival statistics
  local healthPotions = CharacterStats:GetStat('healthPotionsUsed') or 0
  local healthPotionsStat = getStat('healthPotionsUsed')
  if healthPotionsStat then
    healthPotionsStat.value:SetText(formatNumberWithCommas(healthPotions))
    ApplyTierColor(
      'healthPotionsUsed',
      healthPotions,
      healthPotionsStat.label,
      healthPotionsStat.value
    )
  end

  local manaPotions = CharacterStats:GetStat('manaPotionsUsed') or 0
  local manaPotionsStat = getStat('manaPotionsUsed')
  if manaPotionsStat then
    manaPotionsStat.value:SetText(formatNumberWithCommas(manaPotions))
    ApplyTierColor('manaPotionsUsed', manaPotions, manaPotionsStat.label, manaPotionsStat.value)
  end

  local bandages = CharacterStats:GetStat('bandagesUsed') or 0
  local bandagesStat = getStat('bandagesUsed')
  if bandagesStat then
    bandagesStat.value:SetText(formatNumberWithCommas(bandages))
    ApplyTierColor('bandagesUsed', bandages, bandagesStat.label, bandagesStat.value)
  end

  local targetDummies = CharacterStats:GetStat('targetDummiesUsed') or 0
  local targetDummiesStat = getStat('targetDummiesUsed')
  if targetDummiesStat then
    targetDummiesStat.value:SetText(formatNumberWithCommas(targetDummies))
    ApplyTierColor(
      'targetDummiesUsed',
      targetDummies,
      targetDummiesStat.label,
      targetDummiesStat.value
    )
  end

  local grenades = CharacterStats:GetStat('grenadesUsed') or 0
  local grenadesStat = getStat('grenadesUsed')
  if grenadesStat then
    grenadesStat.value:SetText(formatNumberWithCommas(grenades))
    ApplyTierColor('grenadesUsed', grenades, grenadesStat.label, grenadesStat.value)
  end

  local partyDeaths = CharacterStats:GetStat('partyMemberDeaths') or 0
  local partyDeathsStat = getStat('partyMemberDeaths')
  if partyDeathsStat then
    partyDeathsStat.value:SetText(formatNumberWithCommas(partyDeaths))
    -- Party deaths has noTier flag
    partyDeathsStat.label:SetTextColor(1, 0.9, 0.5, 1)
    partyDeathsStat.value:SetTextColor(1, 1, 1, 1) -- White for non-tier stats
  end

  -- Player deaths
  local playerDeaths = CharacterStats:GetStat('playerDeaths') or 0
  local playerDeathsStat = getStat('playerDeaths')
  if playerDeathsStat then
    playerDeathsStat.value:SetText(formatNumberWithCommas(playerDeaths))
    playerDeathsStat.label:SetTextColor(1, 0.9, 0.5, 1)
    playerDeathsStat.value:SetTextColor(1, 1, 1, 1)
  end

  local playerDeathsOpenWorld = CharacterStats:GetStat('playerDeathsOpenWorld') or 0
  local playerDeathsOpenWorldStat = getStat('playerDeathsOpenWorld')
  if playerDeathsOpenWorldStat then
    playerDeathsOpenWorldStat.value:SetText(formatNumberWithCommas(playerDeathsOpenWorld))
    playerDeathsOpenWorldStat.label:SetTextColor(1, 0.9, 0.5, 1)
    playerDeathsOpenWorldStat.value:SetTextColor(1, 1, 1, 1)
  end

  local playerDeathsBattleground = CharacterStats:GetStat('playerDeathsBattleground') or 0
  local playerDeathsBattlegroundStat = getStat('playerDeathsBattleground')
  if playerDeathsBattlegroundStat then
    playerDeathsBattlegroundStat.value:SetText(formatNumberWithCommas(playerDeathsBattleground))
    playerDeathsBattlegroundStat.label:SetTextColor(1, 0.9, 0.5, 1)
    playerDeathsBattlegroundStat.value:SetTextColor(1, 1, 1, 1)
  end

  local playerDeathsDungeon = CharacterStats:GetStat('playerDeathsDungeon') or 0
  local playerDeathsDungeonStat = getStat('playerDeathsDungeon')
  if playerDeathsDungeonStat then
    playerDeathsDungeonStat.value:SetText(formatNumberWithCommas(playerDeathsDungeon))
    playerDeathsDungeonStat.label:SetTextColor(1, 0.9, 0.5, 1)
    playerDeathsDungeonStat.value:SetTextColor(1, 1, 1, 1)
  end

  local playerDeathsRaid = CharacterStats:GetStat('playerDeathsRaid') or 0
  local playerDeathsRaidStat = getStat('playerDeathsRaid')
  if playerDeathsRaidStat then
    playerDeathsRaidStat.value:SetText(formatNumberWithCommas(playerDeathsRaid))
    playerDeathsRaidStat.label:SetTextColor(1, 0.9, 0.5, 1)
    playerDeathsRaidStat.value:SetTextColor(1, 1, 1, 1)
  end

  local playerDeathsArena = CharacterStats:GetStat('playerDeathsArena') or 0
  local playerDeathsArenaStat = getStat('playerDeathsArena')
  if playerDeathsArenaStat then
    playerDeathsArenaStat.value:SetText(formatNumberWithCommas(playerDeathsArena))
    playerDeathsArenaStat.label:SetTextColor(1, 0.9, 0.5, 1)
    playerDeathsArenaStat.value:SetTextColor(1, 1, 1, 1)
  end

  local blocks = CharacterStats:GetStat('blocks') or 0
  local blocksStat = getStat('blocks')
  if blocksStat then
    blocksStat.value:SetText(formatNumberWithCommas(blocks))
    blocksStat.label:SetTextColor(1, 0.9, 0.5, 1)
    blocksStat.value:SetTextColor(1, 1, 1, 1)
  end

  local parries = CharacterStats:GetStat('parries') or 0
  local parriesStat = getStat('parries')
  if parriesStat then
    parriesStat.value:SetText(formatNumberWithCommas(parries))
    parriesStat.label:SetTextColor(1, 0.9, 0.5, 1)
    parriesStat.value:SetTextColor(1, 1, 1, 1)
  end

  local dodges = CharacterStats:GetStat('dodges') or 0
  local dodgesStat = getStat('dodges')
  if dodgesStat then
    dodgesStat.value:SetText(formatNumberWithCommas(dodges))
    dodgesStat.label:SetTextColor(1, 0.9, 0.5, 1)
    dodgesStat.value:SetTextColor(1, 1, 1, 1)
  end

  local resists = CharacterStats:GetStat('resists') or 0
  local resistsStat = getStat('resists')
  if resistsStat then
    resistsStat.value:SetText(formatNumberWithCommas(resists))
    resistsStat.label:SetTextColor(1, 0.9, 0.5, 1)
    resistsStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update highest crit value (noTier flag)
  local highestCrit = CharacterStats:GetStat('highestCritValue') or 0
  local highestCritStat = getStat('highestCritValue')
  if highestCritStat then
    highestCritStat.value:SetText(formatNumberWithCommas(highestCrit))
    highestCritStat.label:SetTextColor(1, 0.9, 0.5, 1)
    highestCritStat.value:SetTextColor(1, 1, 1, 1) -- White for non-tier stats
  end

  -- Update highest heal crit value (noTier flag)
  local highestHealCrit = CharacterStats:GetStat('highestHealCritValue') or 0
  local highestHealCritStat = getStat('highestHealCritValue')
  if highestHealCritStat then
    highestHealCritStat.value:SetText(formatNumberWithCommas(highestHealCrit))
    highestHealCritStat.label:SetTextColor(1, 0.9, 0.5, 1)
    highestHealCritStat.value:SetTextColor(1, 1, 1, 1) -- White for non-tier stats
  end

  -- Update close escape count
  local closeEscapes = CharacterStats:GetStat('closeEscapes') or 0
  local closeEscapesStat = getStat('closeEscapes')
  if closeEscapesStat then
    closeEscapesStat.value:SetText(formatNumberWithCommas(closeEscapes))
    ApplyTierColor('closeEscapes', closeEscapes, closeEscapesStat.label, closeEscapesStat.value)
  end

  -- Update Duels Total value (noTier flag)
  local duelsTotal = CharacterStats:GetStat('duelsTotal') or 0
  local duelsTotalStat = getStat('duelsTotal')
  if duelsTotalStat then
    duelsTotalStat.value:SetText(formatNumberWithCommas(duelsTotal))
    duelsTotalStat.label:SetTextColor(1, 0.9, 0.5, 1)
    duelsTotalStat.value:SetTextColor(1, 1, 1, 1)
  end

  -- Update Duels Won value (noTier flag)
  local duelsWon = CharacterStats:GetStat('duelsWon') or 0
  local duelsWonStat = getStat('duelsWon')
  if duelsWonStat then
    duelsWonStat.value:SetText(formatNumberWithCommas(duelsWon))
    duelsWonStat.label:SetTextColor(1, 0.9, 0.5, 1)
    duelsWonStat.value:SetTextColor(1, 1, 1, 1) -- White for non-tier stats
  end

  -- Update Duels Lost value (noTier flag)
  local duelsLost = CharacterStats:GetStat('duelsLost') or 0
  local duelsLostStat = getStat('duelsLost')
  if duelsLostStat then
    duelsLostStat.value:SetText(formatNumberWithCommas(duelsLost))
    duelsLostStat.label:SetTextColor(1, 0.9, 0.5, 1)
    duelsLostStat.value:SetTextColor(1, 1, 1, 1) -- White for non-tier stats
  end

  -- Update Duels Win Percentage value (percent stat)
  local duelsWinPercent = CharacterStats:GetStat('duelsWinPercent') or 0
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
  local playerJumps = CharacterStats:GetStat('playerJumps') or 0
  local playerJumpsStat = getStat('playerJumps')
  if playerJumpsStat then
    playerJumpsStat.value:SetText(formatNumberWithCommas(playerJumps))
    ApplyTierColor('playerJumps', playerJumps, playerJumpsStat.label, playerJumpsStat.value)
  end

  -- Update player 360s value
  local player360s = CharacterStats:GetStat('player360s') or 0
  local player360sStat = getStat('player360s')
  if player360sStat then
    player360sStat.value:SetText(formatNumberWithCommas(player360s))
    ApplyTierColor('player360s', player360s, player360sStat.label, player360sStat.value)
  end

  -- Economy stats (money)
  local goldGained = CharacterStats:GetStat('goldGained') or 0
  local goldGainedStat = getStat('goldGained')
  if goldGainedStat then
    goldGainedStat.value:SetText(FormatMoneyText(goldGained))
    ApplyTierColor('goldGained', goldGained, goldGainedStat.label, goldGainedStat.value)
  end

  local goldSpent = CharacterStats:GetStat('goldSpent') or 0
  local goldSpentStat = getStat('goldSpent')
  if goldSpentStat then
    goldSpentStat.value:SetText(FormatMoneyText(goldSpent))
    ApplyTierColor('goldSpent', goldSpent, goldSpentStat.label, goldSpentStat.value)
  end

  -- Update row visibility after updating values
  UpdateRowVisibility()

  -- Refresh settings-panel instance lists (Heroics tab) when stats change.
  if _G and _G.UltraStatistics_RefreshHeroicsTab then
    _G.UltraStatistics_RefreshHeroicsTab()
  end
  if _G and _G.UltraStatistics_RefreshDungeonsTab then
    _G.UltraStatistics_RefreshDungeonsTab()
  end
end

-- Register events to update statistics when they change
statsFrame:RegisterEvent('UNIT_HEALTH_FREQUENT')
statsFrame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
statsFrame:RegisterEvent('PLAYER_LEVEL_UP')
statsFrame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
statsFrame:RegisterEvent('UNIT_MAXHEALTH')
statsFrame:RegisterEvent('UNIT_MAXPOWER')
statsFrame:RegisterEvent('PLAYER_LOGIN') -- Player entity and world are ready. Addon database and C_ APIs are safe to access.
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
  elseif event == 'PLAYER_EQUIPMENT_CHANGED' then
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
  if SaveDBData then
    SaveDBData('statsFramePosition', nil)
  end
  print('|cfff44336[STATS]|r Statistics panel position reset to default.')
end

-- Make ResetStatsFramePosition globally accessible for combined reset commands
_G.ResetStatsFramePosition = ResetStatsFramePosition

SLASH_UHCSTATSRESET1 = '/uhcstatsreset'
SLASH_UHCSTATSRESET2 = '/uhcsr'
SlashCmdList['UHCSTATSRESET'] = ResetStatsFrameToSavedPosition

-- Initial check with delay to ensure GLOBAL_SETTINGS is loaded
C_Timer.After(1, function()
  CheckAddonEnabled()
  ApplyStatsBackgroundOpacity()
end)
