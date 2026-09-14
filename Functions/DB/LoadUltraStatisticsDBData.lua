-- Load DB and initialize default per-character settings

function LoadUltraStatisticsDBData()
  if not UltraStatisticsDB then
    UltraStatisticsDB = {}
  end

  if not UltraStatisticsDB.lastSeenVersion then
    UltraStatisticsDB.lastSeenVersion = nil
  end

  if not UltraStatisticsDB.characterSettings then
    UltraStatisticsDB.characterSettings = {}
  end

  if type(UltraStatisticsDB.leaderboards) ~= 'table' then
    UltraStatisticsDB.leaderboards = {
      guild = {},
      server = {},
    }
  end
  if type(UltraStatisticsDB.leaderboards.guild) ~= 'table' then
    UltraStatisticsDB.leaderboards.guild = {}
  end
  if type(UltraStatisticsDB.leaderboards.server) ~= 'table' then
    UltraStatisticsDB.leaderboards.server = {}
  end

  -- Defaults needed by the ported Statistics UI + on-screen overlay.
  local defaultSettings = {
    showOnScreenStatistics = true,
    -- Leaderboard sharing (opt-out disables send + receive)
    leaderboardOptOutGuild = false,
    leaderboardOptOutServer = false,
    -- Statistics panel appearance
    statisticsBackgroundOpacity = 0.3,
    statisticsBorderOpacity = 0.9,
    -- Collapsed sections in Statistics tab
    collapsedStatsSections = {},
    -- Row visibility settings (MainScreenStatistics.lua reads these)
    showMainStatisticsPanelLevel = true,
    showMainStatisticsPanelGuild = false,
    showMainStatisticsPanelTotalHP = false,
    showMainStatisticsPanelTotalMana = false,
    showMainStatisticsPanelMaxResource = false,
    showMainStatisticsPanelEnemiesSlain = true,
    showMainStatisticsPanelPetDeaths = false,
    showMainStatisticsPanelElitesSlain = false,
    showMainStatisticsPanelRareElitesSlain = false,
    showMainStatisticsPanelWorldBossesSlain = false,
    showMainStatisticsPanelDungeonBosses = false,
    showMainStatisticsPanelDungeonsCompleted = false,
    showMainStatisticsPanelHighestCritValue = false,
    showMainStatisticsPanelHighestHealCritValue = false,
    showMainStatisticsPanelHealthPotionsUsed = false,
    showMainStatisticsPanelManaPotionsUsed = false,
    showMainStatisticsPanelBandagesUsed = false,
    showMainStatisticsPanelTargetDummiesUsed = false,
    showMainStatisticsPanelGrenadesUsed = false,
    showMainStatisticsPanelPartyMemberDeaths = false,
    showMainStatisticsPanelPlayerDeaths = true,
    showMainStatisticsPanelServerDeaths = true,
    showMainStatisticsPanelPlayerDeathsOpenWorld = false,
    showMainStatisticsPanelPlayerDeathsBattleground = false,
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

  ULTRA_STATISTICS_GLOBAL_SETTINGS = UltraStatisticsDB.characterSettings[characterGUID]
  if type(ULTRA_STATISTICS_GLOBAL_SETTINGS.collapsedStatsSections) ~= 'table' then
    ULTRA_STATISTICS_GLOBAL_SETTINGS.collapsedStatsSections = {}
  end
end
