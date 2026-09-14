local statsInitialized = false

local function copyValue(value)
  if type(value) ~= 'table' then
    return value
  end
  local newTable = {}
  for key, v in pairs(value) do
    newTable[key] = copyValue(v)
  end
  return newTable
end

local function GetCurrentRealmKey()
  if GetNormalizedRealmName then
    local normalized = GetNormalizedRealmName()
    if type(normalized) == 'string' and normalized ~= '' then
      return normalized
    end
  end
  local realm = GetRealmName and GetRealmName() or nil
  if type(realm) == 'string' and realm ~= '' then
    return realm
  end
  return 'Unknown'
end

local UltraStatisticsCharacterStats = {
  defaults = {
    closeEscapes = 0,
    enemiesSlain = 0,
    elitesSlain = 0,
    rareElitesSlain = 0,
    worldBossesSlain = 0,
    dungeonBossesKilled = 0,
    dungeonsCompleted = 0,
    petDeaths = 0,
    partyMemberDeaths = 0,
    -- Player death stats
    playerDeaths = 0,
    playerDeathsOpenWorld = 0,
    playerDeathsBattleground = 0,
    playerDeathsArena = 0,
    -- Avoidance / mitigation
    blocks = 0,
    parries = 0,
    dodges = 0,
    resists = 0,
    healthPotionsUsed = 0,
    manaPotionsUsed = 0,
    bandagesUsed = 0,
    targetDummiesUsed = 0,
    grenadesUsed = 0,
    highestCritValue = 0,
    highestHealCritValue = 0,
    playerKills = 0,
    duelsTotal = 0,
    duelsWon = 0,
    duelsLost = 0,
    duelsWinPercent = 0,
    playerJumps = 0,
    goldGained = 0, -- COPPER
    goldSpent = 0, -- COPPER
    lastLogoutTime = 0,
    maxHealthEver = 0,
    maxResourceEver = 0,
    -- Lowest health % (100 = never dropped)
    lowestHealth = 100,
    lowestHealthThisLevel = 100,
    lowestHealthThisSession = 100,
    -- XP verification fields (safe to keep at 0 for now)
    xpTotal = 0,
  },
}

function UltraStatisticsCharacterStats:GetCurrentCharacterStats()
  if not UltraStatisticsDB then
    return self.defaults
  end

  local characterGUID = UnitGUID('player')
  if statsInitialized and UltraStatisticsDB.characterStats and UltraStatisticsDB.characterStats[characterGUID] then
    -- Keep realm tag fresh so server totals stay accurate after transfers/renames.
    UltraStatisticsDB.characterStats[characterGUID].realmKey = GetCurrentRealmKey()
    return UltraStatisticsDB.characterStats[characterGUID]
  end

  if not UltraStatisticsDB.characterStats then
    UltraStatisticsDB.characterStats = {}
  end
  if not UltraStatisticsDB.characterStats[characterGUID] then
    UltraStatisticsDB.characterStats[characterGUID] = copyValue(self.defaults)
  end

  -- Backfill new keys
  for statName, defaultVal in pairs(self.defaults) do
    if UltraStatisticsDB.characterStats[characterGUID][statName] == nil then
      UltraStatisticsDB.characterStats[characterGUID][statName] = copyValue(defaultVal)
    end
  end

  UltraStatisticsDB.characterStats[characterGUID].realmKey = GetCurrentRealmKey()
  statsInitialized = true
  return UltraStatisticsDB.characterStats[characterGUID]
end

-- Call after import so the next GetCurrentCharacterStats() uses the updated DB (avoids stale refs).
function UltraStatisticsCharacterStats:InvalidateCache()
  statsInitialized = false
end

function UltraStatisticsCharacterStats:UpdateStat(statName, value)
  local stats = self:GetCurrentCharacterStats()
  stats[statName] = value
  SaveUltraStatisticsDBData('characterStats', UltraStatisticsDB.characterStats)

  if _G.UpdateStatistics then
    _G.UpdateStatistics()
  end
end

function UltraStatisticsCharacterStats:GetStat(statName)
  local stats = self:GetCurrentCharacterStats()
  return stats[statName]
end

-- Sum of playerDeaths for every character this account has tracked on the current realm.
function UltraStatisticsCharacterStats:GetServerDeaths()
  local realmKey = GetCurrentRealmKey()
  local total = 0
  if not UltraStatisticsDB or type(UltraStatisticsDB.characterStats) ~= 'table' then
    return self:GetStat('playerDeaths') or 0
  end

  -- Ensure the current character is tagged before summing.
  self:GetCurrentCharacterStats()

  for _, stats in pairs(UltraStatisticsDB.characterStats) do
    if type(stats) == 'table' and stats.realmKey == realmKey then
      total = total + (tonumber(stats.playerDeaths) or 0)
    end
  end
  return total
end

function UltraStatisticsCharacterStats:ResetLowestHealthThisLevel()
  self:UpdateStat('lowestHealthThisLevel', 100)
end

function UltraStatisticsCharacterStats:ResetLowestHealthThisSession()
  self:UpdateStat('lowestHealthThisSession', 100)
end

-- Simple share-to-chat used by the Statistics tab "Share" button
function UltraStatisticsCharacterStats:LogStatsToChat()
  local stats = self:GetCurrentCharacterStats()
  local playerName = UnitName('player') or 'Player'
  local playerLevel = UnitLevel('player') or 1
  local _, playerClass = UnitClass('player')
  local msg =
    '[UltraStatistics] ' .. playerName .. ' (' .. (playerClass or 'Class') .. ' L' .. playerLevel .. ') - ' .. 'Deaths: ' .. UltraStatistics_FormatNumberWithCommas(
      stats.playerDeaths or 0
    ) .. ' - ' .. 'Enemies: ' .. UltraStatistics_FormatNumberWithCommas(
      stats.enemiesSlain or 0
    ) .. ' - ' .. 'Elites: ' .. UltraStatistics_FormatNumberWithCommas(stats.elitesSlain or 0)
  DEFAULT_CHAT_FRAME:AddMessage(msg)
end

_G.UltraStatisticsCharacterStats = UltraStatisticsCharacterStats
_G.UltraStatistics_GetCurrentRealmKey = GetCurrentRealmKey
