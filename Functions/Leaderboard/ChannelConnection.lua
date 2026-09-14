-- Hidden chat channel join/send for realm leaderboards (adapted from RaceLocked).

UltraStatistics_Leaderboard = UltraStatistics_Leaderboard or {}
local LB = UltraStatistics_Leaderboard

local channelFiltersInstalled = false
local delayedJoinScheduled = false
local MAX_CHANNEL_SLOTS = 20

function LB.GetDataChannelId()
  if not GetChannelName then
    return 0
  end
  local id = GetChannelName(LB.CHANNEL_NAME)
  return tonumber(id) or 0
end

local function hideChannelFromChatWindows()
  if not ChatFrame_RemoveChannel or not NUM_CHAT_WINDOWS then
    return
  end
  for i = 1, NUM_CHAT_WINDOWS do
    local frame = _G['ChatFrame' .. i]
    if frame then
      ChatFrame_RemoveChannel(frame, LB.CHANNEL_NAME)
    end
  end
end

local function getOtherChannelsHighestIndex(ourId)
  if not GetChannelName then
    return 0
  end
  local highest = 0
  for i = 1, MAX_CHANNEL_SLOTS do
    if i ~= ourId then
      local id, name = GetChannelName(i)
      local occupied = (type(id) == 'number' and id > 0) or (name and name ~= '')
      if occupied then
        highest = i
      end
    end
  end
  return highest
end

local function tryMoveOurChannelToBack()
  local swap = C_ChatInfo and C_ChatInfo.SwapChatChannelsByChannelIndex
  if not swap or not GetChannelName then
    return
  end
  for _ = 1, MAX_CHANNEL_SLOTS do
    local id = LB.GetDataChannelId()
    if id <= 0 then
      return
    end
    local nextId, nextName = GetChannelName(id + 1)
    local nextOccupied = (type(nextId) == 'number' and nextId > 0) or (nextName and nextName ~= '')
    if not nextOccupied then
      return
    end
    swap(id, id + 1)
  end
end

function LB.InstallChannelNoticeFilters()
  if channelFiltersInstalled or not ChatFrame_AddMessageEventFilter then
    return
  end
  channelFiltersInstalled = true
  local function filterFn(_, _, ...)
    local arg1 = select(1, ...)
    local arg2 = select(2, ...)
    local arg3 = select(3, ...)
    if tostring(arg1 or '') == LB.CHANNEL_NAME then
      return true
    end
    if tostring(arg2 or '') == LB.CHANNEL_NAME then
      return true
    end
    if tostring(arg3 or '') == LB.CHANNEL_NAME then
      return true
    end
    return false
  end
  ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL_NOTICE', filterFn)
  ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL_NOTICE_USER', filterFn)
  ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL', function(_, _, ...)
    local channelIndex = select(8, ...)
    local channelBaseName = select(9, ...)
    if channelBaseName == LB.CHANNEL_NAME then
      return true
    end
    local id = tonumber(channelIndex) or 0
    if id > 0 and id == LB.GetDataChannelId() then
      return true
    end
    return false
  end)
end

function LB.EnsureDataChannelJoined(forceJoin)
  local id = LB.GetDataChannelId()
  if id > 0 then
    local othersHighest = getOtherChannelsHighestIndex(id)
    if othersHighest > id then
      tryMoveOurChannelToBack()
      id = LB.GetDataChannelId()
    end
    hideChannelFromChatWindows()
    return id
  end

  local othersHighest = getOtherChannelsHighestIndex(0)
  if othersHighest == 0 and not forceJoin then
    return 0
  end

  if JoinChannelByName then
    JoinChannelByName(LB.CHANNEL_NAME)
    id = LB.GetDataChannelId()
    if id > 0 then
      tryMoveOurChannelToBack()
      id = LB.GetDataChannelId()
      hideChannelFromChatWindows()
      return id
    end
  end
  if JoinTemporaryChannel then
    JoinTemporaryChannel(LB.CHANNEL_NAME)
    id = LB.GetDataChannelId()
    if id > 0 then
      tryMoveOurChannelToBack()
      id = LB.GetDataChannelId()
      hideChannelFromChatWindows()
      return id
    end
  end
  return 0
end

function LB.ScheduleDelayedDataChannelJoin()
  if delayedJoinScheduled then
    return
  end
  delayedJoinScheduled = true
  if not C_Timer or not C_Timer.After then
    LB.EnsureDataChannelJoined(true)
    delayedJoinScheduled = false
    return
  end

  local delays = { 0.5, 1.5, 3.0, 5.0, 8.0 }
  local idx = 1
  local function attemptJoin()
    local id = LB.EnsureDataChannelJoined(false)
    if id > 0 then
      delayedJoinScheduled = false
      return
    end
    if idx >= #delays then
      LB.EnsureDataChannelJoined(true)
      delayedJoinScheduled = false
      return
    end
    idx = idx + 1
    C_Timer.After(delays[idx], attemptJoin)
  end
  C_Timer.After(delays[idx], attemptJoin)
end

function LB.LeaveDataChannel()
  if LeaveChannelByName then
    LeaveChannelByName(LB.CHANNEL_NAME)
  end
end

function LB.SendChannelPayload(payload)
  local channelId = LB.EnsureDataChannelJoined(true)
  if channelId <= 0 then
    return false
  end
  local wire = LB.EncodeWire(payload)
  if not wire or not SendChatMessage then
    return false
  end
  -- Classic Era allows channel SendChatMessage from addon timers; pcall guards protected failures.
  local ok = pcall(SendChatMessage, wire, 'CHANNEL', nil, channelId)
  return ok == true
end

function LB.IsOurDataChannelMessage(...)
  local channelIndex = select(8, ...)
  local channelBaseName = select(9, ...)
  if channelBaseName == LB.CHANNEL_NAME then
    return true
  end
  local id = tonumber(channelIndex) or 0
  return id > 0 and id == LB.GetDataChannelId()
end
