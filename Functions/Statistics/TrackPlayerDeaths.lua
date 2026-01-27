-- Track player deaths (total / this session / this level)

local frame = CreateFrame('Frame')
frame:RegisterEvent('PLAYER_DEAD')
frame:RegisterEvent('PLAYER_LEVEL_UP')
frame:RegisterEvent('PLAYER_LOGIN')
frame:RegisterEvent('PLAYER_LOGOUT')

local lastCountTime = 0
local DEBOUNCE_SECONDS = 2.0

local function IsNewSession()
  if not CharacterStats then return false end
  local lastLogout = CharacterStats:GetStat('lastLogoutTime')
  if not lastLogout then
    return true
  end
  local now = GetServerTime and GetServerTime() or time()
  return (now - lastLogout) > 1800
end

frame:SetScript('OnEvent', function(_, event)
  if not CharacterStats then return end

  if event == 'PLAYER_LOGIN' then
    -- Reset "this session" counters if we were logged out long enough.
    if IsNewSession() then
      if CharacterStats.ResetPlayerDeathsThisSession then
        CharacterStats:ResetPlayerDeathsThisSession()
      end
    end
    return
  end

  if event == 'PLAYER_LOGOUT' then
    -- lastLogoutTime is handled by TrackLowestHealth, but keep it safe here too.
    local now = GetServerTime and GetServerTime() or time()
    CharacterStats:UpdateStat('lastLogoutTime', now)
    return
  end

  if event == 'PLAYER_LEVEL_UP' then
    if CharacterStats.ResetPlayerDeathsThisLevel then
      CharacterStats:ResetPlayerDeathsThisLevel()
    end
    return
  end

  if event == 'PLAYER_DEAD' then
    local nowT = GetTime and GetTime() or 0
    if (nowT - lastCountTime) < DEBOUNCE_SECONDS then
      return
    end
    lastCountTime = nowT

    local total = CharacterStats:GetStat('playerDeaths') or 0
    local session = CharacterStats:GetStat('playerDeathsThisSession') or 0
    local level = CharacterStats:GetStat('playerDeathsThisLevel') or 0

    CharacterStats:UpdateStat('playerDeaths', total + 1)
    CharacterStats:UpdateStat('playerDeathsThisSession', session + 1)
    CharacterStats:UpdateStat('playerDeathsThisLevel', level + 1)
  end
end)


