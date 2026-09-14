-- Ultra Statistics leaderboard wire codec (adapted from RaceLocked Comms).

UltraStatistics_Leaderboard = UltraStatistics_Leaderboard or {}
local LB = UltraStatistics_Leaderboard

LB.PREFIX = 'USLB1'
LB.CHANNEL_NAME = 'UltraStatisticsDataBus'
LB.GUILD_ADDON_PREFIX = 'USLBGuild'
LB.WIRE_FIELD_SEP = '\001'

LB.STAT_KEYS = {
  'playerDeaths',
  'dungeonsCompleted',
  'enemiesSlain',
  'playerJumps',
  'goldGained',
}

LB.STAT_LABELS = {
  playerDeaths = 'Deaths',
  dungeonsCompleted = 'Dungeons Cleared',
  enemiesSlain = 'Enemies Slain',
  playerJumps = 'Jumps',
  goldGained = 'Gold Gained',
}

LB.STAT_SHORT_LABELS = {
  playerDeaths = 'Deaths',
  dungeonsCompleted = 'Dungeons',
  enemiesSlain = 'Enemies',
  playerJumps = 'Jumps',
  goldGained = 'Gold',
}

-- Lower values rank higher for these stats.
LB.LOWER_IS_BETTER = {
  playerDeaths = true,
}

-- WIP: seed Guild/Server tables with fake players for UI testing.
LB.USE_MOCK_DATA = true

function LB.BytesToHex(s)
  if type(s) ~= 'string' or s == '' then
    return ''
  end
  local t = {}
  for i = 1, #s do
    t[i] = string.format('%02x', string.byte(s, i))
  end
  return table.concat(t)
end

function LB.HexToBytes(h)
  if type(h) ~= 'string' or h == '' or (#h % 2) ~= 0 then
    return nil
  end
  local t = {}
  for i = 1, #h, 2 do
    local b = tonumber(string.sub(h, i, i + 1), 16)
    if not b then
      return nil
    end
    t[#t + 1] = string.char(b)
  end
  return table.concat(t)
end

local function wireInt(n)
  local v = tonumber(n) or 0
  if v < 0 then
    v = 0
  end
  return math.floor(v + 0.5)
end

local function sanitizeField(s)
  s = tostring(s or '')
  s = s:gsub('|', '/')
  s = s:gsub(LB.WIRE_FIELD_SEP, '')
  s = s:gsub('[%c]', '')
  return s
end

function LB.GetUnixTime()
  if GetServerTime then
    local t = GetServerTime()
    if type(t) == 'number' and t > 0 then
      return math.floor(t)
    end
  end
  return math.floor(time and time() or 0)
end

function LB.GetPlayerKey()
  local guid = UnitGUID('player')
  if type(guid) == 'string' and guid ~= '' then
    return guid
  end
  local name = UnitName('player') or 'Player'
  local realm = (GetNormalizedRealmName and GetNormalizedRealmName()) or (GetRealmName and GetRealmName()) or 'Unknown'
  return name .. '-' .. realm
end

function LB.GetPlayerDisplayName()
  local name = UnitName('player') or 'Player'
  local realm = (GetNormalizedRealmName and GetNormalizedRealmName()) or (GetRealmName and GetRealmName()) or ''
  if realm ~= '' then
    return name .. '-' .. realm
  end
  return name
end

function LB.BuildOwnSnapshot()
  local stats = UltraStatisticsCharacterStats and UltraStatisticsCharacterStats:GetCurrentCharacterStats() or {}
  local values = {}
  for _, key in ipairs(LB.STAT_KEYS) do
    values[key] = tonumber(stats[key]) or 0
  end
  return {
    key = LB.GetPlayerKey(),
    name = LB.GetPlayerDisplayName(),
    values = values,
    timestamp = LB.GetUnixTime(),
  }
end

-- v1 | key | name | deaths | cleared | enemies | jumps | gold | ts
function LB.BuildPayload(entry)
  if type(entry) ~= 'table' or type(entry.values) ~= 'table' then
    return nil
  end
  local v = entry.values
  return table.concat({
    'v1',
    sanitizeField(entry.key),
    sanitizeField(entry.name),
    tostring(wireInt(v.playerDeaths)),
    tostring(wireInt(v.dungeonsCompleted)),
    tostring(wireInt(v.enemiesSlain)),
    tostring(wireInt(v.playerJumps)),
    tostring(wireInt(v.goldGained)),
    tostring(wireInt(entry.timestamp)),
  }, LB.WIRE_FIELD_SEP)
end

function LB.ParsePayload(msg)
  if type(msg) ~= 'string' or msg == '' then
    return nil
  end
  local prefix = LB.PREFIX .. ':'
  if string.sub(msg, 1, #prefix) ~= prefix then
    return nil
  end
  local hex = string.sub(msg, #prefix + 1)
  local raw = LB.HexToBytes(hex)
  if not raw then
    return nil
  end
  local parts = {}
  for part in string.gmatch(raw .. LB.WIRE_FIELD_SEP, '(.-)' .. LB.WIRE_FIELD_SEP) do
    parts[#parts + 1] = part
  end
  if parts[1] ~= 'v1' or #parts < 9 then
    return nil
  end
  return {
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
end

function LB.EncodeWire(payload)
  if not payload or payload == '' then
    return nil
  end
  local wire = LB.PREFIX .. ':' .. LB.BytesToHex(payload)
  if #wire > 255 then
    return nil
  end
  return wire
end
