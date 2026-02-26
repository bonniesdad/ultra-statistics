KillTracker = KillTracker or {}

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

local function HandleBossDeathForKillTracking(trigger, destGUID)
  if not destGUID or not CharacterStats then return end
  if not IsDungeonBoss then return end

  local isDungeon, isRaid = IsDungeonBoss(destGUID)
  if not (isDungeon or isRaid) then return end

  if shouldDedupeBossKill(destGUID) then return end

  local currentDungeonBosses = CharacterStats:GetStat('dungeonBossesKilled') or 0
  CharacterStats:UpdateStat('dungeonBossesKilled', currentDungeonBosses + 1)

  if DungeonRaidStats and DungeonRaidStats.RecordBossKill then
    local ok = DungeonRaidStats.RecordBossKill(destGUID) == true
  end
end

function KillTracker.HandlePartyKill(destGUID)
  if not destGUID or not CharacterStats then return end

  -- Dedupe: PARTY_KILL can fire twice for the same mob in some cases
  if shouldDedupePartyKill(destGUID) then return end

  -- Player kills (PvP): destGUID starts with "Player-" for enemy players
  if destGUID:sub(1, 7) == 'Player-' then
    local currentPlayerKills = CharacterStats:GetStat('playerKills') or 0
    CharacterStats:UpdateStat('playerKills', currentPlayerKills + 1)
    return -- Don't count players as enemies slain
  end

  -- Boss kill tracking (PARTY_KILL only fires when someone in the party gets the killing blow)
  HandleBossDeathForKillTracking('PARTY_KILL', destGUID)

  if IsEnemyElite and IsEnemyElite(destGUID) then
    local currentElites = CharacterStats:GetStat('elitesSlain') or 0
    CharacterStats:UpdateStat('elitesSlain', currentElites + 1)
  end

  if IsEnemyRareElite and IsEnemyRareElite(destGUID) then
    local currentRareElites = CharacterStats:GetStat('rareElitesSlain') or 0
    CharacterStats:UpdateStat('rareElitesSlain', currentRareElites + 1)
  end

  if IsEnemyWorldBoss and IsEnemyWorldBoss(destGUID) then
    local currentWorldBosses = CharacterStats:GetStat('worldBossesSlain') or 0
    CharacterStats:UpdateStat('worldBossesSlain', currentWorldBosses + 1)
  end

  if IsDungeonFinalBoss then
    local isDungeonFinalBoss = IsDungeonFinalBoss(destGUID)
    if isDungeonFinalBoss then
      local currentDungeonsCompleted = CharacterStats:GetStat('dungeonsCompleted') or 0
      CharacterStats:UpdateStat('dungeonsCompleted', currentDungeonsCompleted + 1)

      -- Classic dungeon clears: we may not have per-boss mapping in DungeonRaidBossInfo,
      -- so record the clear at the instance level by name.
      if type(GetInstanceInfo) == 'function' then
        local name, instanceType, difficultyID = GetInstanceInfo()
        if instanceType == 'party' then
          local hasBossMapping =
            (DungeonRaidBossInfo and DungeonRaidBossInfo.GetBossInfoByGUID and DungeonRaidBossInfo.GetBossInfoByGUID(
              destGUID
            )) ~= nil
          if not hasBossMapping and DungeonRaidStats and DungeonRaidStats.RecordDungeonClearByName then
            DungeonRaidStats.RecordDungeonClearByName(name, difficultyID)
          end
        end
      end
    end
  end

  local currentEnemies = CharacterStats:GetStat('enemiesSlain') or 0
  CharacterStats:UpdateStat('enemiesSlain', currentEnemies + 1)
end

-- Boss kill tracking fallback: UNIT_DIED fires even when PARTY_KILL doesn't (no killing blow credit).
function KillTracker.HandleUnitDied(destGUID)
  HandleBossDeathForKillTracking('UNIT_DIED', destGUID)
end
