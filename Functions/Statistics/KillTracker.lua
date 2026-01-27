KillTracker = KillTracker or {}

function KillTracker.HandlePartyKill(destGUID)
  if not destGUID or not CharacterStats then return end

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

  if IsDungeonBoss then
    local isDungeonBoss = IsDungeonBoss(destGUID)
    if isDungeonBoss then
      local currentDungeonBosses = CharacterStats:GetStat('dungeonBossesKilled') or 0
      CharacterStats:UpdateStat('dungeonBossesKilled', currentDungeonBosses + 1)
    end
  end

  if IsDungeonFinalBoss then
    local isDungeonFinalBoss = IsDungeonFinalBoss(destGUID)
    if isDungeonFinalBoss then
      local currentDungeonsCompleted = CharacterStats:GetStat('dungeonsCompleted') or 0
      CharacterStats:UpdateStat('dungeonsCompleted', currentDungeonsCompleted + 1)
    end
  end

  local currentEnemies = CharacterStats:GetStat('enemiesSlain') or 0
  CharacterStats:UpdateStat('enemiesSlain', currentEnemies + 1)
end


