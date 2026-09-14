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

  -- party/raid deaths still count toward the total, but no dedicated bucket
  if instanceType == 'party' or instanceType == 'raid' then
    return nil
  end

  return 'playerDeathsOpenWorld'
end

frame:SetScript('OnEvent', function(_, event)
  if not UltraStatisticsCharacterStats then return end

  if event == 'PLAYER_DEAD' then
    local nowT = GetTime and GetTime() or 0
    if (nowT - lastCountTime) < DEBOUNCE_SECONDS then return end
    lastCountTime = nowT

    local total = UltraStatisticsCharacterStats:GetStat('playerDeaths') or 0
    UltraStatisticsCharacterStats:UpdateStat('playerDeaths', total + 1)

    local contextKey = GetDeathContextKey()
    if contextKey then
      local contextVal = UltraStatisticsCharacterStats:GetStat(contextKey) or 0
      UltraStatisticsCharacterStats:UpdateStat(contextKey, contextVal + 1)
    end
  end
end)
