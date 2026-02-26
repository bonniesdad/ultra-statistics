-- Load DB and initialize default per-character settings

function LoadDBData()
  if not UltraStatisticsDB then
    UltraStatisticsDB = {}
  end

  if not UltraStatisticsDB.lastSeenVersion then
    UltraStatisticsDB.lastSeenVersion = nil
  end

  if not UltraStatisticsDB.characterSettings then
    UltraStatisticsDB.characterSettings = {}
  end

  -- Defaults needed by the ported Statistics UI + on-screen overlay.
  local defaultSettings = {
    showTiers = false,
    showOnScreenStatistics = true,
    -- Statistics tracking/toasts
    showStatisticsTracking = false,
    minimalStatisticsTracking = false,
    statisticsTrackingTierOnly = false,
    statisticsToastEnabled = {},
    -- Statistics panel appearance
    statisticsBackgroundOpacity = 0.3,
    statisticsBorderOpacity = 0.9,
    -- Collapsed sections in Statistics tab
    collapsedStatsSections = {},
    -- Row visibility settings (MainScreenStatistics.lua reads these)
    showMainStatisticsPanelLevel = true,
    showMainStatisticsPanelTotalHP = false,
    showMainStatisticsPanelTotalMana = false,
    showMainStatisticsPanelMaxResource = false,
    showMainStatisticsPanelEnemiesSlain = true,
    showMainStatisticsPanelDungeonsCompleted = false,
    showMainStatisticsPanelPetDeaths = false,
    showMainStatisticsPanelElitesSlain = false,
    showMainStatisticsPanelDungeonBosses = false,
    showMainStatisticsPanelRareElitesSlain = false,
    showMainStatisticsPanelWorldBossesSlain = false,
    showMainStatisticsPanelHighestCritValue = false,
    showMainStatisticsPanelHighestHealCritValue = false,
    showMainStatisticsPanelHealthPotionsUsed = false,
    showMainStatisticsPanelManaPotionsUsed = false,
    showMainStatisticsPanelBandagesUsed = false,
    showMainStatisticsPanelTargetDummiesUsed = false,
    showMainStatisticsPanelGrenadesUsed = false,
    showMainStatisticsPanelPartyMemberDeaths = false,
    showMainStatisticsPanelPlayerDeaths = true,
    showMainStatisticsPanelPlayerDeathsOpenWorld = false,
    showMainStatisticsPanelPlayerDeathsBattleground = false,
    showMainStatisticsPanelPlayerDeathsDungeon = false,
    showMainStatisticsPanelPlayerDeathsHeroicDungeon = false,
    showMainStatisticsPanelPlayerDeathsRaid = false,
    showMainStatisticsPanelPlayerDeathsArena = false,
    showMainStatisticsPanelLowestHealth = false,
    showMainStatisticsPanelLowestHealthThisLevel = false,
    showMainStatisticsPanelLowestHealthThisSession = false,
    showMainStatisticsPanelBlocks = false,
    showMainStatisticsPanelParries = false,
    showMainStatisticsPanelDodges = false,
    showMainStatisticsPanelResists = false,
    showMainStatisticsPanelCloseEscapes = false,
    showMainStatisticsPanelPlayerKills = false,
    showMainStatisticsPanelDuelsTotal = false,
    showMainStatisticsPanelDuelsWon = false,
    showMainStatisticsPanelDuelsLost = false,
    showMainStatisticsPanelDuelsWinPercent = false,
    showMainStatisticsPanelPlayerJumps = true,
    showMainStatisticsPanelPlayer360s = false,
    showMainStatisticsPanelGoldGained = false,
    showMainStatisticsPanelGoldSpent = false,
    -- lagHome / lagWorld removed in UltraStatistics

    -- Trackers may write this
    isDueling = false,
  }

  local characterGUID = UnitGUID('player')
  if not UltraStatisticsDB.characterSettings[characterGUID] then
    UltraStatisticsDB.characterSettings[characterGUID] = defaultSettings
  end

  -- Backfill new settings for existing characters
  for k, v in pairs(defaultSettings) do
    if UltraStatisticsDB.characterSettings[characterGUID][k] == nil then
      UltraStatisticsDB.characterSettings[characterGUID][k] = v
    end
  end

  GLOBAL_SETTINGS = UltraStatisticsDB.characterSettings[characterGUID]
  if type(GLOBAL_SETTINGS.statisticsToastEnabled) ~= 'table' then
    GLOBAL_SETTINGS.statisticsToastEnabled = {}
  end
  if type(GLOBAL_SETTINGS.collapsedStatsSections) ~= 'table' then
    GLOBAL_SETTINGS.collapsedStatsSections = {}
  end
end
