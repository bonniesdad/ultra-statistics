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
  end
end)
