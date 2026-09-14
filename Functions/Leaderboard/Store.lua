-- Persistent leaderboard store + ranking helpers.

UltraStatistics_Leaderboard = UltraStatistics_Leaderboard or {}
local LB = UltraStatistics_Leaderboard

local function ensureDb()
  if not UltraStatisticsDB then
    UltraStatisticsDB = {}
  end
  if type(UltraStatisticsDB.leaderboards) ~= 'table' then
    UltraStatisticsDB.leaderboards = {
      guild = {},
      server = {},
    }
  end
  if type(UltraStatisticsDB.leaderboards.guild) ~= 'table' then
    UltraStatisticsDB.leaderboards.guild = {}
  end
  if type(UltraStatisticsDB.leaderboards.server) ~= 'table' then
    UltraStatisticsDB.leaderboards.server = {}
  end
  return UltraStatisticsDB.leaderboards
end

function LB.IsGuildOptedOut()
  return ULTRA_STATISTICS_GLOBAL_SETTINGS and ULTRA_STATISTICS_GLOBAL_SETTINGS.leaderboardOptOutGuild == true
end

function LB.IsServerOptedOut()
  return ULTRA_STATISTICS_GLOBAL_SETTINGS and ULTRA_STATISTICS_GLOBAL_SETTINGS.leaderboardOptOutServer == true
end

function LB.UpsertEntry(scope, entry)
  if type(entry) ~= 'table' or not entry.key or entry.key == '' then
    return false
  end
  if scope ~= 'guild' and scope ~= 'server' then
    return false
  end
  local db = ensureDb()
  local board = db[scope]
  local existing = board[entry.key]
  local incomingTs = tonumber(entry.timestamp) or 0
  if existing then
    local storedTs = tonumber(existing.timestamp) or 0
    if incomingTs < storedTs then
      return false
    end
  end
  board[entry.key] = {
    key = entry.key,
    name = entry.name or entry.key,
    values = entry.values or {},
    timestamp = incomingTs,
  }
  if SaveUltraStatisticsDBData then
    SaveUltraStatisticsDBData('leaderboards', UltraStatisticsDB.leaderboards)
  end
  return true
end

function LB.UpsertOwnEntry(scope)
  local entry = LB.BuildOwnSnapshot()
  return LB.UpsertEntry(scope, entry)
end

local function mockEntry(key, name, values)
  return {
    key = key,
    name = name,
    values = values,
    timestamp = 1,
  }
end

local function getMockEntries(scope)
  -- Distinct-ish sets so Guild vs Server feel different while browsing.
  if scope == 'guild' then
    return {
      mockEntry('mock-guild-1', 'Thalorien', {
        playerDeaths = 12,
        dungeonsCompleted = 3,
        enemiesSlain = 1840,
        playerJumps = 920,
        goldGained = 4250000,
      }),
      mockEntry('mock-guild-2', 'Mirabelle', {
        playerDeaths = 2,
        dungeonsCompleted = 8,
        enemiesSlain = 960,
        playerJumps = 410,
        goldGained = 1880000,
      }),
      mockEntry('mock-guild-3', 'Grimjaw', {
        playerDeaths = 47,
        dungeonsCompleted = 1,
        enemiesSlain = 5320,
        playerJumps = 2100,
        goldGained = 9700000,
      }),
      mockEntry('mock-guild-4', 'Elowen', {
        playerDeaths = 0,
        dungeonsCompleted = 22,
        enemiesSlain = 310,
        playerJumps = 155,
        goldGained = 420000,
      }),
      mockEntry('mock-guild-5', 'Rook', {
        playerDeaths = 19,
        dungeonsCompleted = 5,
        enemiesSlain = 2760,
        playerJumps = 1340,
        goldGained = 6100000,
      }),
      mockEntry('mock-guild-6', 'Sable', {
        playerDeaths = 8,
        dungeonsCompleted = 11,
        enemiesSlain = 1490,
        playerJumps = 780,
        goldGained = 2550000,
      }),
      mockEntry('mock-guild-7', 'Brannoc', {
        playerDeaths = 31,
        dungeonsCompleted = 2,
        enemiesSlain = 4010,
        playerJumps = 1675,
        goldGained = 8120000,
      }),
      mockEntry('mock-guild-8', 'Nyx', {
        playerDeaths = 5,
        dungeonsCompleted = 14,
        enemiesSlain = 870,
        playerJumps = 540,
        goldGained = 1330000,
      }),
    }
  end

  return {
    mockEntry('mock-server-1', 'Kaelthas-Whitemane', {
      playerDeaths = 64,
      dungeonsCompleted = 1,
      enemiesSlain = 9200,
      playerJumps = 4100,
      goldGained = 15200000,
    }),
    mockEntry('mock-server-2', 'Fenris-Whitemane', {
      playerDeaths = 3,
      dungeonsCompleted = 6,
      enemiesSlain = 1210,
      playerJumps = 690,
      goldGained = 2100000,
    }),
    mockEntry('mock-server-3', 'Isolde-Whitemane', {
      playerDeaths = 21,
      dungeonsCompleted = 4,
      enemiesSlain = 3480,
      playerJumps = 1520,
      goldGained = 7450000,
    }),
    mockEntry('mock-server-4', 'Torvin-Whitemane', {
      playerDeaths = 0,
      dungeonsCompleted = 35,
      enemiesSlain = 180,
      playerJumps = 95,
      goldGained = 215000,
    }),
    mockEntry('mock-server-5', 'Ashen-Whitemane', {
      playerDeaths = 39,
      dungeonsCompleted = 2,
      enemiesSlain = 6100,
      playerJumps = 2880,
      goldGained = 11900000,
    }),
    mockEntry('mock-server-6', 'Lira-Whitemane', {
      playerDeaths = 11,
      dungeonsCompleted = 9,
      enemiesSlain = 2040,
      playerJumps = 1010,
      goldGained = 3980000,
    }),
    mockEntry('mock-server-7', 'Durn-Whitemane', {
      playerDeaths = 28,
      dungeonsCompleted = 3,
      enemiesSlain = 4550,
      playerJumps = 1990,
      goldGained = 8800000,
    }),
    mockEntry('mock-server-8', 'Vesper-Whitemane', {
      playerDeaths = 7,
      dungeonsCompleted = 12,
      enemiesSlain = 1330,
      playerJumps = 760,
      goldGained = 2760000,
    }),
    mockEntry('mock-server-9', 'Orin-Whitemane', {
      playerDeaths = 52,
      dungeonsCompleted = 1,
      enemiesSlain = 7800,
      playerJumps = 3500,
      goldGained = 14100000,
    }),
    mockEntry('mock-server-10', 'Mira-Whitemane', {
      playerDeaths = 15,
      dungeonsCompleted = 7,
      enemiesSlain = 2680,
      playerJumps = 1205,
      goldGained = 5120000,
    }),
  }
end

function LB.GetEntries(scope)
  local db = ensureDb()
  local board = db[scope] or {}
  local rows = {}
  local seen = {}
  for _, entry in pairs(board) do
    if type(entry) == 'table' and type(entry.values) == 'table' and entry.key then
      seen[entry.key] = true
      rows[#rows + 1] = {
        key = entry.key,
        name = entry.name or entry.key,
        values = entry.values,
        timestamp = entry.timestamp or 0,
      }
    end
  end
  if LB.USE_MOCK_DATA then
    for _, entry in ipairs(getMockEntries(scope)) do
      if not seen[entry.key] then
        rows[#rows + 1] = entry
      end
    end
  end
  return rows
end

function LB.SortEntries(rows, statKey, ascending)
  if type(rows) ~= 'table' then
    return rows
  end
  if not statKey then
    table.sort(rows, function(a, b)
      return (a.name or '') < (b.name or '')
    end)
    return rows
  end
  if ascending == nil then
    ascending = LB.LOWER_IS_BETTER[statKey] == true
  end
  table.sort(rows, function(a, b)
    local av = tonumber(a.values and a.values[statKey]) or 0
    local bv = tonumber(b.values and b.values[statKey]) or 0
    if av == bv then
      return (a.name or '') < (b.name or '')
    end
    if ascending then
      return av < bv
    end
    return av > bv
  end)
  return rows
end

function LB.GetRankedList(scope, statKey)
  local rows = LB.GetEntries(scope)
  local lowerIsBetter = LB.LOWER_IS_BETTER[statKey] == true
  local ranked = {}
  for _, entry in ipairs(rows) do
    local value = tonumber(entry.values[statKey])
    if value ~= nil then
      ranked[#ranked + 1] = {
        key = entry.key,
        name = entry.name,
        value = value,
        timestamp = entry.timestamp or 0,
      }
    end
  end
  table.sort(ranked, function(a, b)
    if a.value == b.value then
      return (a.name or '') < (b.name or '')
    end
    if lowerIsBetter then
      return a.value < b.value
    end
    return a.value > b.value
  end)
  return ranked
end

function LB.ClearScope(scope)
  local db = ensureDb()
  if scope == 'guild' or scope == 'server' then
    db[scope] = {}
    if SaveUltraStatisticsDBData then
      SaveUltraStatisticsDBData('leaderboards', UltraStatisticsDB.leaderboards)
    end
  end
end
