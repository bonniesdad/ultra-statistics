-- Stored dungeon and raid instance stats (boss kills, deaths, first clear date).
-- Merges with default instance lists from HeroicsTab/RaidsTab and persists per character.

DungeonRaidStats = DungeonRaidStats or {}

-- Instance name -> { category, instanceKey }
-- Used for recording non-boss deaths based on the current dungeon name from GetInstanceInfo().
-- Note: The Stockade is intentionally categorized under "heroics" for testing purposes.
local DUNGEON_NAME_TO_INSTANCE = {
  -- TBC Heroics (instance names as returned by GetInstanceInfo())
  ['Hellfire Ramparts'] = {
    category = 'heroics',
    instanceKey = 'hellfireRamparts',
  },
  ['The Blood Furnace'] = {
    category = 'heroics',
    instanceKey = 'bloodFurnace',
  },
  ['The Shattered Halls'] = {
    category = 'heroics',
    instanceKey = 'shatteredHalls',
  },
  ['The Slave Pens'] = {
    category = 'heroics',
    instanceKey = 'slavePens',
  },
  ['The Underbog'] = {
    category = 'heroics',
    instanceKey = 'underbog',
  },
  ['The Steamvault'] = {
    category = 'heroics',
    instanceKey = 'steamvault',
  },
  ['Mana-Tombs'] = {
    category = 'heroics',
    instanceKey = 'manaTombs',
  },
  ['Auchenai Crypts'] = {
    category = 'heroics',
    instanceKey = 'auchenaiCrypts',
  },
  ['Sethekk Halls'] = {
    category = 'heroics',
    instanceKey = 'sethekkHalls',
  },
  ['Shadow Labyrinth'] = {
    category = 'heroics',
    instanceKey = 'shadowLabyrinth',
  },
  ['Old Hillsbrad Foothills'] = {
    category = 'heroics',
    instanceKey = 'oldHillsbradFoothills',
  },
  ['The Black Morass'] = {
    category = 'heroics',
    instanceKey = 'blackMorass',
  },
  ['The Botanica'] = {
    category = 'heroics',
    instanceKey = 'botanica',
  },
  ['The Mechanar'] = {
    category = 'heroics',
    instanceKey = 'mechanar',
  },
  ['The Arcatraz'] = {
    category = 'heroics',
    instanceKey = 'arcatraz',
  },
  ["Magister's Terrace"] = {
    category = 'heroics',
    instanceKey = 'magistersTerrace',
  },
}

-- Heroic-mode gating exception list (The Stockade is added for testing in normal mode).
local ALLOW_NON_HEROIC_FOR_TEST = { stockades = true }

local function getStorage()
  if not UltraStatisticsDB then
    UltraStatisticsDB = {}
  end
  local guid = UnitGUID('player')
  if not guid then
    return nil
  end
  if not UltraStatisticsDB.dungeonRaidStats then
    UltraStatisticsDB.dungeonRaidStats = {}
  end
  if not UltraStatisticsDB.dungeonRaidStats[guid] then
    UltraStatisticsDB.dungeonRaidStats[guid] = {
      heroics = {},
      raids = {},
    }
  end
  return UltraStatisticsDB.dungeonRaidStats[guid]
end

local function ensureInstance(storage, category, instanceKey)
  if not storage[category][instanceKey] then
    storage[category][instanceKey] = {
      totalClears = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      firstClearDate = '',
      bosses = {},
    }
  end
  return storage[category][instanceKey]
end

local function ensureBoss(instanceData, bossName)
  if not instanceData.bosses[bossName] then
    instanceData.bosses[bossName] = {
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }
  end
  return instanceData.bosses[bossName]
end

-- True when the player is in a HEROIC 5-man dungeon (difficultyID 2).
-- Heroics stats must only be updated in heroic mode.
local function isInHeroicDungeon()
  if type(GetInstanceInfo) ~= 'function' then
    return false
  end
  local _, instanceType, difficultyID = GetInstanceInfo()
  return instanceType == 'party' and difficultyID == 2
end

-- Format current date as "5th Jun 2026"
local function formatClearDate()
  local d = tonumber(date('%d')) or 1
  local ord =
    (d == 1 or d == 21 or d == 31) and 'st' or (d == 2 or d == 22) and 'nd' or (d == 3 or d == 23) and 'rd' or 'th'
  return d .. ord .. ' ' .. date('%b') .. ' ' .. date('%Y')
end

-- Merge stored stats into a copy of the default instance list (keys, titles, boss names stay from defaults).
function DungeonRaidStats.MergeWithStored(category, defaultInstances)
  if type(defaultInstances) ~= 'table' then
    return defaultInstances
  end
  local storage = getStorage()
  if not storage then
    return defaultInstances
  end

  local cat = storage[category]
  if not cat then
    return defaultInstances
  end

  local result = {}
  for i, inst in ipairs(defaultInstances) do
    local key = inst.key
    if not key then
      result[i] = inst
    else
      local stored = cat[key]
      local copy = {
        key = inst.key,
        title = inst.title,
        totalClears = (stored and stored.totalClears) or 0,
        totalDeaths = (stored and stored.totalDeaths) or 0,
        firstClearDeaths = (stored and stored.firstClearDeaths) or 0,
        firstClearDate = (stored and stored.firstClearDate) or '',
        bosses = {},
      }
      for j, boss in ipairs(inst.bosses or {}) do
        local name = boss.name or boss.title
        if name then
          local bst = stored and stored.bosses and stored.bosses[name]
          copy.bosses[j] = {
            name = name,
            totalKills = (bst and bst.totalKills) or 0,
            totalDeaths = (bst and bst.totalDeaths) or 0,
            firstClearDeaths = (bst and bst.firstClearDeaths) or 0,
            isFinal = boss.isFinal,
          }
        else
          copy.bosses[j] = boss
        end
      end
      result[i] = copy
    end
  end
  return result
end

-- Record a boss kill (destGUID = killed creature). Call from KillTracker when IsDungeonBoss.
-- Heroics category is only updated when the kill is in a HEROIC dungeon.
function DungeonRaidStats.RecordBossKill(destGUID)
  if not DungeonRaidBossInfo then
    return false
  end

  local info = DungeonRaidBossInfo.GetBossInfoByGUID(destGUID)
  if not info then
    return false
  end

  -- TODO: Uncomment
  -- if info.category == 'heroics' and not isInHeroicDungeon() then
  --   return false
  -- end

  local storage = getStorage()
  if not storage then
    return false
  end

  local inst = ensureInstance(storage, info.category, info.instanceKey)
  local boss = ensureBoss(inst, info.bossName)

  boss.totalKills = (boss.totalKills or 0) + 1

  if info.isFinal then
    inst.totalClears = (inst.totalClears or 0) + 1
    if not inst.firstClearDate or inst.firstClearDate == '' then
      inst.firstClearDate = formatClearDate()
    end
  end

  SaveDBData('dungeonRaidStats', UltraStatisticsDB.dungeonRaidStats)
  if _G.UpdateStatistics then
    _G.UpdateStatistics()
  end
  return true
end

-- Record a party member death during a boss fight. bossGUID = one of the bosses we're in combat with.
-- Heroics category is only updated when the death is in a HEROIC dungeon.
function DungeonRaidStats.RecordBossDeath(bossGUID)
  if not DungeonRaidBossInfo then
    return false
  end
  local info = DungeonRaidBossInfo.GetBossInfoByGUID(bossGUID)
  if not info then
    return false
  end

  -- if info.category == 'heroics' and not isInHeroicDungeon() then return end

  local storage = getStorage()
  if not storage then
    return false
  end

  local inst = ensureInstance(storage, info.category, info.instanceKey)
  local boss = ensureBoss(inst, info.bossName)

  local bossKillsBefore = boss.totalKills or 0
  local finalBossKillsBefore =
    info.isFinal and bossKillsBefore or DungeonRaidStats.GetFinalBossKillsForInstance(
      storage,
      info.category,
      info.instanceKey
    )

  -- Boss level: always increment totalDeaths; firstClearDeaths only if totalKills (before) is 0
  boss.totalDeaths = (boss.totalDeaths or 0) + 1
  if bossKillsBefore == 0 then
    boss.firstClearDeaths = (boss.firstClearDeaths or 0) + 1
  end

  -- Instance level: always increment totalDeaths; firstClearDeaths only if final boss not yet killed
  inst.totalDeaths = (inst.totalDeaths or 0) + 1
  if finalBossKillsBefore == 0 then
    inst.firstClearDeaths = (inst.firstClearDeaths or 0) + 1
  end

  SaveDBData('dungeonRaidStats', UltraStatisticsDB.dungeonRaidStats)
  if _G.UpdateStatistics then
    _G.UpdateStatistics()
  end
  return true
end

-- Record a player death inside a 5-man dungeon when NOT in a boss fight.
-- instanceName/difficultyID should come from: local name, _, difficultyID = GetInstanceInfo()
function DungeonRaidStats.RecordNonBossDungeonDeath(instanceName, difficultyID)
  if not instanceName or type(instanceName) ~= 'string' then return end

  local mapped = DUNGEON_NAME_TO_INSTANCE[instanceName]
  if not mapped then return end

  -- Protect heroic stats from being updated in normal mode (except explicit test allowlist).
  -- TODO: Uncomment
  -- if mapped.category == 'heroics' and difficultyID ~= 2 then return end

  local storage = getStorage()
  if not storage then return end

  local inst = ensureInstance(storage, mapped.category, mapped.instanceKey)

  local finalBossKillsBefore =
    DungeonRaidStats.GetFinalBossKillsForInstance(storage, mapped.category, mapped.instanceKey)

  inst.totalDeaths = (inst.totalDeaths or 0) + 1
  if finalBossKillsBefore == 0 then
    inst.firstClearDeaths = (inst.firstClearDeaths or 0) + 1
  end

  SaveDBData('dungeonRaidStats', UltraStatisticsDB.dungeonRaidStats)
  if _G.UpdateStatistics then
    _G.UpdateStatistics()
  end
end

-- Get final boss totalKills for an instance from storage (for firstClearDeaths logic).
function DungeonRaidStats.GetFinalBossKillsForInstance(storage, category, instanceKey)
  if not storage or not category or not instanceKey then
    return 0
  end
  local inst = storage[category] and storage[category][instanceKey]
  if not inst or not inst.bosses then
    return 0
  end
  local finalName =
    DungeonRaidBossInfo and DungeonRaidBossInfo.GetFinalBossName(instanceKey, category)
  if not finalName then
    return 0
  end
  local b = inst.bosses[finalName]
  return (b and b.totalKills) or 0
end

_G.DungeonRaidStats = DungeonRaidStats
