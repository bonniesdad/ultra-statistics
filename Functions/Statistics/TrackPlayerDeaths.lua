local frame = CreateFrame('Frame')
frame:RegisterEvent('PLAYER_DEAD')

local lastCountTime = 0
local DEBOUNCE_SECONDS = 2.0

local function GetDeathContextKey()
  local inInstance, instanceType = IsInInstance()
  if not inInstance or not instanceType then
    return 'playerDeathsOpenWorld'
  end

  if instanceType == 'pvp' then
    return 'playerDeathsBattleground'
  end
  if instanceType == 'arena' then
    return 'playerDeathsArena'
  end
  if instanceType == 'party' then
    if type(GetInstanceInfo) == 'function' then
      local _, _, difficultyID = GetInstanceInfo()
      if difficultyID == 2 then
        return 'playerDeathsHeroicDungeon'
      end
    end
    return 'playerDeathsDungeon'
  end
  if instanceType == 'raid' then
    return 'playerDeathsRaid'
  end

  return 'playerDeathsOpenWorld'
end

frame:SetScript('OnEvent', function(_, event)
  if not CharacterStats then return end

  if event == 'PLAYER_DEAD' then
    local nowT = GetTime and GetTime() or 0
    if (nowT - lastCountTime) < DEBOUNCE_SECONDS then return end
    lastCountTime = nowT

    local total = CharacterStats:GetStat('playerDeaths') or 0
    local contextKey = GetDeathContextKey()
    local contextVal = CharacterStats:GetStat(contextKey) or 0

    CharacterStats:UpdateStat('playerDeaths', total + 1)
    CharacterStats:UpdateStat(contextKey, contextVal + 1)

    -- If we're in a dungeon and NOT currently in a boss fight, increment deaths for that dungeon.
    if type(GetInstanceInfo) == 'function' then
      local name, instanceType, difficultyID = GetInstanceInfo()
      local inBossFight =
        (BossFightTracker and BossFightTracker.IsInBossFight and BossFightTracker.IsInBossFight()) or false

      if inBossFight then
        local bossGUID =
          (BossFightTracker and BossFightTracker.GetAnyBossGUIDInCombat and BossFightTracker.GetAnyBossGUIDInCombat()) or nil

        local didBossDeathUpdate = false
        if bossGUID and DungeonRaidStats and DungeonRaidStats.RecordBossDeath then
          didBossDeathUpdate = DungeonRaidStats.RecordBossDeath(bossGUID) == true
        end

        -- Even when dying to a boss, total instance deaths should increment.
        -- If boss-attribution didn\'t update (missing bossGUID, no mapping, gated, etc),
        -- fall back to incrementing the current dungeon\'s instance deaths by name.
        if not didBossDeathUpdate and instanceType == 'party' then
          if DungeonRaidStats and DungeonRaidStats.RecordNonBossDungeonDeath then
            DungeonRaidStats.RecordNonBossDungeonDeath(name, difficultyID)
          end
        end

        return
      end

      if not inBossFight then
        if DungeonRaidStats and DungeonRaidStats.RecordNonBossDungeonDeath then
          DungeonRaidStats.RecordNonBossDungeonDeath(name, difficultyID)
        end
      end
    end
  end
end)
