-- Leaderboard send/receive (guild addon messages + realm data bus).

UltraStatistics_Leaderboard = UltraStatistics_Leaderboard or {}
local LB = UltraStatistics_Leaderboard

local lastGuildSend = 0
local GUILD_SEND_COOLDOWN = 3.0
local lastServerSend = 0
local SERVER_SEND_COOLDOWN = 5.0
local BROADCAST_INTERVAL = 5 * 60
local periodicStarted = false
local loginBroadcastDone = false

local function registerPrefix()
  local reg = C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix
  if reg then
    reg(LB.GUILD_ADDON_PREFIX)
  end
end

local function isSenderLocalPlayer(sender)
  if not sender or sender == '' then
    return false
  end
  local full = GetUnitName and GetUnitName('player', true)
  local short = UnitName('player')
  if full and sender == full then
    return true
  end
  if short and Ambiguate then
    return Ambiguate(sender, 'none') == short
  end
  return short and sender == short
end

function LB.BroadcastGuild(force)
  if LB.IsGuildOptedOut() then
    return false
  end
  if not IsInGuild or not IsInGuild() then
    return false
  end
  local now = GetTime and GetTime() or 0
  if not force and (now - lastGuildSend) < GUILD_SEND_COOLDOWN then
    return false
  end
  LB.UpsertOwnEntry('guild')
  local payload = LB.BuildPayload(LB.BuildOwnSnapshot())
  if not payload then
    return false
  end
  local send = SendAddonMessage or (C_ChatInfo and C_ChatInfo.SendAddonMessage)
  if not send then
    return false
  end
  send(LB.GUILD_ADDON_PREFIX, payload, 'GUILD')
  lastGuildSend = now
  return true
end

function LB.BroadcastServer(force)
  if LB.IsServerOptedOut() then
    return false, 'opted-out'
  end
  local now = GetTime and GetTime() or 0
  if not force and (now - lastServerSend) < SERVER_SEND_COOLDOWN then
    return false, 'cooldown'
  end
  LB.UpsertOwnEntry('server')
  local payload = LB.BuildPayload(LB.BuildOwnSnapshot())
  if not payload then
    return false, 'payload'
  end
  local ok = LB.SendChannelPayload(payload)
  if ok then
    lastServerSend = now
    return true
  end
  return false, 'channel'
end

function LB.BroadcastAll(force)
  LB.BroadcastGuild(force)
  LB.BroadcastServer(force)
end

function LB.StartPeriodicBroadcast()
  if periodicStarted then
    return
  end
  if not C_Timer or not C_Timer.NewTicker then
    return
  end
  periodicStarted = true
  C_Timer.NewTicker(BROADCAST_INTERVAL, function()
    LB.BroadcastAll(true)
  end)
end

function LB.ScheduleLoginBroadcast()
  if loginBroadcastDone then
    return
  end
  loginBroadcastDone = true
  local function runLoginBroadcast()
    LB.BroadcastAll(true)
    LB.StartPeriodicBroadcast()
  end
  if C_Timer and C_Timer.After then
    -- Delay so the data channel has time to join.
    C_Timer.After(3, runLoginBroadcast)
  else
    runLoginBroadcast()
  end
end

function LB.ApplyIncoming(scope, entry)
  if not entry then
    return
  end
  if scope == 'guild' and LB.IsGuildOptedOut() then
    return
  end
  if scope == 'server' and LB.IsServerOptedOut() then
    return
  end
  if entry.key == LB.GetPlayerKey() then
    return
  end
  if LB.UpsertEntry(scope, entry) and LB.RefreshUI then
    LB.RefreshUI()
  end
end

-- Keep local leaderboard rows fresh when stats change; network share is timed.
local function hookCharacterStatUpdates()
  if not UltraStatisticsCharacterStats or UltraStatisticsCharacterStats._leaderboardHooked then
    return
  end
  local oldUpdateStat = UltraStatisticsCharacterStats.UpdateStat
  if type(oldUpdateStat) ~= 'function' then
    return
  end
  UltraStatisticsCharacterStats._leaderboardHooked = true
  function UltraStatisticsCharacterStats:UpdateStat(statName, value)
    oldUpdateStat(self, statName, value)
    if LB.STAT_LABELS[statName] then
      LB.UpsertOwnEntry('guild')
      LB.UpsertOwnEntry('server')
      if LB.RefreshUI then
        LB.RefreshUI()
      end
    end
  end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('PLAYER_LOGIN')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:RegisterEvent('CHAT_MSG_ADDON')
frame:RegisterEvent('CHAT_MSG_CHANNEL')
frame:RegisterEvent('PLAYER_DEAD')
frame:RegisterEvent('PLAYER_GUILD_UPDATE')

frame:SetScript('OnEvent', function(_, event, ...)
  if event == 'PLAYER_LOGIN' or event == 'PLAYER_ENTERING_WORLD' then
    registerPrefix()
    hookCharacterStatUpdates()
    LB.InstallChannelNoticeFilters()
    if LB.IsServerOptedOut() then
      LB.LeaveDataChannel()
    else
      LB.ScheduleDelayedDataChannelJoin()
    end
    LB.UpsertOwnEntry('guild')
    LB.UpsertOwnEntry('server')
    if event == 'PLAYER_LOGIN' then
      LB.ScheduleLoginBroadcast()
    end
    return
  end

  if event == 'PLAYER_GUILD_UPDATE' then
    -- Local guild board only; next timed broadcast will share.
    LB.UpsertOwnEntry('guild')
    return
  end

  if event == 'PLAYER_DEAD' then
    LB.UpsertOwnEntry('guild')
    LB.UpsertOwnEntry('server')
    return
  end

  if event == 'CHAT_MSG_ADDON' then
    local prefix, message, channel, sender = ...
    if prefix ~= LB.GUILD_ADDON_PREFIX then
      return
    end
    if LB.IsGuildOptedOut() then
      return
    end
    if channel ~= 'GUILD' then
      return
    end
    if isSenderLocalPlayer(sender) then
      return
    end
    local parts = {}
    for part in string.gmatch((message or '') .. LB.WIRE_FIELD_SEP, '(.-)' .. LB.WIRE_FIELD_SEP) do
      parts[#parts + 1] = part
    end
    if parts[1] ~= 'v1' or #parts < 9 then
      return
    end
    local entry = {
      key = parts[2],
      name = parts[3],
      values = {
        playerDeaths = tonumber(parts[4]) or 0,
        dungeonsCompleted = tonumber(parts[5]) or 0,
        enemiesSlain = tonumber(parts[6]) or 0,
        playerJumps = tonumber(parts[7]) or 0,
        goldGained = tonumber(parts[8]) or 0,
      },
      timestamp = tonumber(parts[9]) or 0,
    }
    LB.ApplyIncoming('guild', entry)
    return
  end

  if event == 'CHAT_MSG_CHANNEL' then
    if LB.IsServerOptedOut() then
      return
    end
    if not LB.IsOurDataChannelMessage(...) then
      return
    end
    local msg = select(1, ...)
    local entry = LB.ParsePayload(msg)
    if entry then
      LB.ApplyIncoming('server', entry)
    end
  end
end)

_G.UltraStatistics_Leaderboard = LB
