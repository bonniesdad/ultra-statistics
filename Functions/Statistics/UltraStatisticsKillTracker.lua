UltraStatisticsKillTracker = UltraStatisticsKillTracker or {}

local recentBossKillTimes = {}
local BOSS_KILL_DEDUPE_SECONDS = 2.0

local recentPartyKillGUIDs = {}
local PARTY_KILL_DEDUPE_SECONDS = 2.0

local function getNow()
  return (GetTime and GetTime()) or 0
end

local function shouldDedupePartyKill(destGUID)
  if not destGUID then
    return false
  end
  local now = getNow()
  local last = recentPartyKillGUIDs[destGUID]
  if last and (now - last) < PARTY_KILL_DEDUPE_SECONDS then
    return true
  end
  recentPartyKillGUIDs[destGUID] = now
  return false
end

local function shouldDedupeBossKill(destGUID)
  if not destGUID then
    return false
  end
  local now = getNow()
  local last = recentBossKillTimes[destGUID]
  if last and (now - last) < BOSS_KILL_DEDUPE_SECONDS then
    return true
  end
  recentBossKillTimes[destGUID] = now
  return false
end

local function HandleBossDeathForKillTracking(destGUID)
  if not destGUID or not UltraStatisticsCharacterStats then
    return
  end
  if not IsUltraStatisticsDungeonBoss then
    return
  end

  local isDungeon, isRaid = IsUltraStatisticsDungeonBoss(destGUID)
  if not (isDungeon or isRaid) then
    return
  end

  if shouldDedupeBossKill(destGUID) then
    return
  end

  local currentDungeonBosses = UltraStatisticsCharacterStats:GetStat('dungeonBossesKilled') or 0
  UltraStatisticsCharacterStats:UpdateStat('dungeonBossesKilled', currentDungeonBosses + 1)
end

function UltraStatisticsKillTracker.HandlePartyKill(destGUID)
  if not destGUID or not UltraStatisticsCharacterStats then
    return
  end

  -- Dedupe: PARTY_KILL can fire twice for the same mob in some cases
  if shouldDedupePartyKill(destGUID) then
    return
  end

  -- Player kills (PvP): destGUID starts with "Player-" for enemy players
  if destGUID:sub(1, 7) == 'Player-' then
    local currentPlayerKills = UltraStatisticsCharacterStats:GetStat('playerKills') or 0
    UltraStatisticsCharacterStats:UpdateStat('playerKills', currentPlayerKills + 1)
    return -- Don't count players as enemies slain
  end

  -- Boss kill tracking (PARTY_KILL only fires when someone in the party gets the killing blow)
  HandleBossDeathForKillTracking(destGUID)

  if IsUltraStatisticsEnemyElite and IsUltraStatisticsEnemyElite(destGUID) then
    local currentElites = UltraStatisticsCharacterStats:GetStat('elitesSlain') or 0
    UltraStatisticsCharacterStats:UpdateStat('elitesSlain', currentElites + 1)
  end

  if IsUltraStatisticsEnemyRareElite and IsUltraStatisticsEnemyRareElite(destGUID) then
    local currentRareElites = UltraStatisticsCharacterStats:GetStat('rareElitesSlain') or 0
    UltraStatisticsCharacterStats:UpdateStat('rareElitesSlain', currentRareElites + 1)
  end

  if IsUltraStatisticsEnemyWorldBoss and IsUltraStatisticsEnemyWorldBoss(destGUID) then
    local currentWorldBosses = UltraStatisticsCharacterStats:GetStat('worldBossesSlain') or 0
    UltraStatisticsCharacterStats:UpdateStat('worldBossesSlain', currentWorldBosses + 1)
  end

  if IsDungeonFinalBoss then
    local isDungeonFinalBoss = IsDungeonFinalBoss(destGUID)
    if isDungeonFinalBoss then
      local currentDungeonsCompleted = UltraStatisticsCharacterStats:GetStat('dungeonsCompleted') or 0
      UltraStatisticsCharacterStats:UpdateStat('dungeonsCompleted', currentDungeonsCompleted + 1)
    end
  end

  local currentEnemies = UltraStatisticsCharacterStats:GetStat('enemiesSlain') or 0
  UltraStatisticsCharacterStats:UpdateStat('enemiesSlain', currentEnemies + 1)
end

-- Boss kill tracking fallback: UNIT_DIED fires even when PARTY_KILL doesn't (no killing blow credit).
function UltraStatisticsKillTracker.HandleUnitDied(destGUID)
  HandleBossDeathForKillTracking(destGUID)
end
