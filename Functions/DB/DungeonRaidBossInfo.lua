-- NPC ID -> instance key, boss name, isFinal, category (heroics | raids)
-- Used by DungeonRaidStats to update stored values on kill/death.
-- Category matches the storage keys: heroics vs raids.

local DungeonRaidBossInfo = {}

-- [npcID] = { instanceKey = string, bossName = string, isFinal = bool, category = 'heroics'|'raids' }
local NPC_ID_TO_BOSS = {
  -- Test dungeon (Ragefire Chasm) - added under "heroics" for testing UI/tracking
  -- Boss NPC IDs referenced from Functions/Checks/IsDungeonBoss.lua
  [11520] = {
    instanceKey = 'ragefireChasm',
    bossName = 'Taragaman the Hungerer',
    isFinal = false,
    category = 'heroics',
  },
  [11517] = {
    instanceKey = 'ragefireChasm',
    bossName = 'Oggleflint',
    isFinal = false,
    category = 'heroics',
  },
  [11518] = {
    instanceKey = 'ragefireChasm',
    bossName = 'Jergosh the Invoker',
    isFinal = false,
    category = 'heroics',
  },
  [11519] = {
    instanceKey = 'ragefireChasm',
    bossName = 'Bazzalan',
    isFinal = true,
    category = 'heroics',
  },
  -- TBC Heroics (Hellfire Ramparts)
  [17306] = {
    instanceKey = 'hellfireRamparts',
    bossName = 'Watchkeeper Gargolmar',
    isFinal = false,
    category = 'heroics',
  },
  [17308] = {
    instanceKey = 'hellfireRamparts',
    bossName = 'Omor the Unscarred',
    isFinal = false,
    category = 'heroics',
  },
  [17307] = {
    instanceKey = 'hellfireRamparts',
    bossName = 'Vazruden the Herald',
    isFinal = true,
    category = 'heroics',
  },
  -- The Blood Furnace
  [17380] = {
    instanceKey = 'bloodFurnace',
    bossName = 'The Maker',
    isFinal = false,
    category = 'heroics',
  },
  [17377] = {
    instanceKey = 'bloodFurnace',
    bossName = 'Broggok',
    isFinal = false,
    category = 'heroics',
  },
  [17666] = {
    instanceKey = 'bloodFurnace',
    bossName = "Keli'dan the Breaker",
    isFinal = true,
    category = 'heroics',
  },
  -- The Shattered Halls
  [16807] = {
    instanceKey = 'shatteredHalls',
    bossName = 'Grand Warlock Nethekurse',
    isFinal = false,
    category = 'heroics',
  },
  [20923] = {
    instanceKey = 'shatteredHalls',
    bossName = "Warbringer O'mrogg",
    isFinal = false,
    category = 'heroics',
  },
  [16809] = {
    instanceKey = 'shatteredHalls',
    bossName = "Warbringer O'mrogg",
    isFinal = false,
    category = 'heroics',
  },
  [16808] = {
    instanceKey = 'shatteredHalls',
    bossName = 'Warchief Kargath Bladefist',
    isFinal = true,
    category = 'heroics',
  },
  -- The Slave Pens
  [17941] = {
    instanceKey = 'slavePens',
    bossName = 'Mennu the Betrayer',
    isFinal = false,
    category = 'heroics',
  },
  [17991] = {
    instanceKey = 'slavePens',
    bossName = 'Rokmar the Crackler',
    isFinal = false,
    category = 'heroics',
  },
  [17942] = {
    instanceKey = 'slavePens',
    bossName = 'Quagmirran',
    isFinal = true,
    category = 'heroics',
  },
  -- The Underbog
  [17770] = {
    instanceKey = 'underbog',
    bossName = 'Hungarfen',
    isFinal = false,
    category = 'heroics',
  },
  [18105] = {
    instanceKey = 'underbog',
    bossName = "Ghaz'an",
    isFinal = false,
    category = 'heroics',
  },
  [17826] = {
    instanceKey = 'underbog',
    bossName = "Swamplord Musel'ek",
    isFinal = false,
    category = 'heroics',
  },
  [17882] = {
    instanceKey = 'underbog',
    bossName = 'The Black Stalker',
    isFinal = true,
    category = 'heroics',
  },
  -- The Steamvault
  [17797] = {
    instanceKey = 'steamvault',
    bossName = 'Hydromancer Thespia',
    isFinal = false,
    category = 'heroics',
  },
  [17796] = {
    instanceKey = 'steamvault',
    bossName = 'Mekgineer Steamrigger',
    isFinal = false,
    category = 'heroics',
  },
  [17798] = {
    instanceKey = 'steamvault',
    bossName = 'Warlord Kalithresh',
    isFinal = true,
    category = 'heroics',
  },
  -- Mana-Tombs
  [18341] = {
    instanceKey = 'manaTombs',
    bossName = 'Pandemonius',
    isFinal = false,
    category = 'heroics',
  },
  [18343] = {
    instanceKey = 'manaTombs',
    bossName = 'Tavarok',
    isFinal = false,
    category = 'heroics',
  },
  [18344] = {
    instanceKey = 'manaTombs',
    bossName = 'Nexus-Prince Shaffar',
    isFinal = true,
    category = 'heroics',
  },
  [22930] = {
    instanceKey = 'manaTombs',
    bossName = 'Yor',
    isFinal = false,
    category = 'heroics',
  },
  -- Auchenai Crypts
  [18371] = {
    instanceKey = 'auchenaiCrypts',
    bossName = 'Shirrak the Dead Watcher',
    isFinal = false,
    category = 'heroics',
  },
  [18373] = {
    instanceKey = 'auchenaiCrypts',
    bossName = 'Exarch Maladaar',
    isFinal = true,
    category = 'heroics',
  },
  -- Sethekk Halls
  [18472] = {
    instanceKey = 'sethekkHalls',
    bossName = 'Darkweaver Syth',
    isFinal = false,
    category = 'heroics',
  },
  [23035] = {
    instanceKey = 'sethekkHalls',
    bossName = 'Talon King Ikiss',
    isFinal = true,
    category = 'heroics',
  },
  [18473] = {
    instanceKey = 'sethekkHalls',
    bossName = 'Anzu',
    isFinal = false,
    category = 'heroics',
  },
  -- Shadow Labyrinth
  [18731] = {
    instanceKey = 'shadowLabyrinth',
    bossName = 'Ambassador Hellmaw',
    isFinal = false,
    category = 'heroics',
  },
  [18667] = {
    instanceKey = 'shadowLabyrinth',
    bossName = 'Blackheart the Inciter',
    isFinal = false,
    category = 'heroics',
  },
  [18732] = {
    instanceKey = 'shadowLabyrinth',
    bossName = 'Grandmaster Vorpil',
    isFinal = false,
    category = 'heroics',
  },
  [18708] = {
    instanceKey = 'shadowLabyrinth',
    bossName = 'Murmur',
    isFinal = true,
    category = 'heroics',
  },
  -- Old Hillsbrad Foothills
  [17848] = {
    instanceKey = 'oldHillsbradFoothills',
    bossName = 'Lieutenant Drake',
    isFinal = false,
    category = 'heroics',
  },
  [17862] = {
    instanceKey = 'oldHillsbradFoothills',
    bossName = 'Captain Skarloc',
    isFinal = false,
    category = 'heroics',
  },
  [18096] = {
    instanceKey = 'oldHillsbradFoothills',
    bossName = 'Epoch Hunter',
    isFinal = true,
    category = 'heroics',
  },
  -- The Black Morass
  [17879] = {
    instanceKey = 'blackMorass',
    bossName = 'Chrono Lord Deja',
    isFinal = false,
    category = 'heroics',
  },
  [17880] = {
    instanceKey = 'blackMorass',
    bossName = 'Temporus',
    isFinal = false,
    category = 'heroics',
  },
  [17881] = {
    instanceKey = 'blackMorass',
    bossName = 'Aeonus',
    isFinal = true,
    category = 'heroics',
  },
  -- The Botanica
  [17976] = {
    instanceKey = 'botanica',
    bossName = 'Commander Sarannis',
    isFinal = false,
    category = 'heroics',
  },
  [17975] = {
    instanceKey = 'botanica',
    bossName = 'High Botanist Freywinn',
    isFinal = false,
    category = 'heroics',
  },
  [17978] = {
    instanceKey = 'botanica',
    bossName = 'Thorngrin the Tender',
    isFinal = false,
    category = 'heroics',
  },
  [17980] = {
    instanceKey = 'botanica',
    bossName = 'Laj',
    isFinal = false,
    category = 'heroics',
  },
  [17977] = {
    instanceKey = 'botanica',
    bossName = 'Warp Splinter',
    isFinal = true,
    category = 'heroics',
  },
  -- The Mechanar
  [19219] = {
    instanceKey = 'mechanar',
    bossName = 'Mechano-Lord Capacitus',
    isFinal = false,
    category = 'heroics',
  },
  [19218] = {
    instanceKey = 'mechanar',
    bossName = 'Nethermancer Sepethrea',
    isFinal = false,
    category = 'heroics',
  },
  [19710] = {
    instanceKey = 'mechanar',
    bossName = 'Gatewatcher Iron-Hand',
    isFinal = false,
    category = 'heroics',
  },
  [19221] = {
    instanceKey = 'mechanar',
    bossName = 'Gatewatcher Gyro-Kill',
    isFinal = false,
    category = 'heroics',
  },
  [19220] = {
    instanceKey = 'mechanar',
    bossName = 'Pathaleon the Calculator',
    isFinal = true,
    category = 'heroics',
  },
  -- The Arcatraz
  [20870] = {
    instanceKey = 'arcatraz',
    bossName = 'Zereketh the Unbound',
    isFinal = false,
    category = 'heroics',
  },
  [20886] = {
    instanceKey = 'arcatraz',
    bossName = 'Dalliah the Doomsayer',
    isFinal = false,
    category = 'heroics',
  },
  [20885] = {
    instanceKey = 'arcatraz',
    bossName = 'Wrath-Scryer Soccothrates',
    isFinal = false,
    category = 'heroics',
  },
  [20912] = {
    instanceKey = 'arcatraz',
    bossName = 'Harbinger Skyriss',
    isFinal = true,
    category = 'heroics',
  },
  -- Magister's Terrace
  [24723] = {
    instanceKey = 'magistersTerrace',
    bossName = 'Selin Fireheart',
    isFinal = false,
    category = 'heroics',
  },
  [24744] = {
    instanceKey = 'magistersTerrace',
    bossName = 'Vexallus',
    isFinal = false,
    category = 'heroics',
  },
  [24560] = {
    instanceKey = 'magistersTerrace',
    bossName = 'Priestess Delrissa',
    isFinal = false,
    category = 'heroics',
  },
  [24664] = {
    instanceKey = 'magistersTerrace',
    bossName = "Kael'thas Sunstrider",
    isFinal = true,
    category = 'heroics',
  },
  -- TBC Raids (Gruul's Lair)
  [18831] = {
    instanceKey = 'gruulsLair',
    bossName = 'High King Maulgar',
    isFinal = false,
    category = 'raids',
  },
  [19044] = {
    instanceKey = 'gruulsLair',
    bossName = 'High King Maulgar',
    isFinal = false,
    category = 'raids',
  },
  [18835] = {
    instanceKey = 'gruulsLair',
    bossName = 'High King Maulgar',
    isFinal = false,
    category = 'raids',
  },
  [18836] = {
    instanceKey = 'gruulsLair',
    bossName = 'High King Maulgar',
    isFinal = false,
    category = 'raids',
  },
  [18834] = {
    instanceKey = 'gruulsLair',
    bossName = 'High King Maulgar',
    isFinal = false,
    category = 'raids',
  },
  [18832] = {
    instanceKey = 'gruulsLair',
    bossName = 'Gruul the Dragonkiller',
    isFinal = true,
    category = 'raids',
  },
  -- Karazhan
  [16152] = {
    instanceKey = 'karazhan',
    bossName = 'Attumen the Huntsman',
    isFinal = false,
    category = 'raids',
  },
  [15687] = {
    instanceKey = 'karazhan',
    bossName = 'Moroes',
    isFinal = false,
    category = 'raids',
  },
  [16457] = {
    instanceKey = 'karazhan',
    bossName = 'Maiden of Virtue',
    isFinal = false,
    category = 'raids',
  },
  [17521] = {
    instanceKey = 'karazhan',
    bossName = 'Opera Event',
    isFinal = false,
    category = 'raids',
  },
  [17533] = {
    instanceKey = 'karazhan',
    bossName = 'Opera Event',
    isFinal = false,
    category = 'raids',
  },
  [17534] = {
    instanceKey = 'karazhan',
    bossName = 'Opera Event',
    isFinal = false,
    category = 'raids',
  },
  [17535] = {
    instanceKey = 'karazhan',
    bossName = 'Opera Event',
    isFinal = false,
    category = 'raids',
  },
  [17543] = {
    instanceKey = 'karazhan',
    bossName = 'Opera Event',
    isFinal = false,
    category = 'raids',
  },
  [17546] = {
    instanceKey = 'karazhan',
    bossName = 'Opera Event',
    isFinal = false,
    category = 'raids',
  },
  [17547] = {
    instanceKey = 'karazhan',
    bossName = 'Opera Event',
    isFinal = false,
    category = 'raids',
  },
  [18168] = {
    instanceKey = 'karazhan',
    bossName = 'Opera Event',
    isFinal = false,
    category = 'raids',
  },
  [15691] = {
    instanceKey = 'karazhan',
    bossName = 'The Curator',
    isFinal = false,
    category = 'raids',
  },
  [15688] = {
    instanceKey = 'karazhan',
    bossName = 'Terestian Illhoof',
    isFinal = false,
    category = 'raids',
  },
  [16524] = {
    instanceKey = 'karazhan',
    bossName = 'Shade of Aran',
    isFinal = false,
    category = 'raids',
  },
  [15689] = {
    instanceKey = 'karazhan',
    bossName = 'Netherspite',
    isFinal = false,
    category = 'raids',
  },
  [17225] = {
    instanceKey = 'karazhan',
    bossName = 'Nightbane',
    isFinal = false,
    category = 'raids',
  },
  [15690] = {
    instanceKey = 'karazhan',
    bossName = 'Prince Malchezaar',
    isFinal = true,
    category = 'raids',
  },
  -- Magtheridon's Lair
  [17256] = {
    instanceKey = 'magtheridonsLair',
    bossName = 'Magtheridon',
    isFinal = false,
    category = 'raids',
  },
  [17257] = {
    instanceKey = 'magtheridonsLair',
    bossName = 'Magtheridon',
    isFinal = true,
    category = 'raids',
  },
  -- Serpentshrine Cavern
  [21216] = {
    instanceKey = 'serpentshrineCavern',
    bossName = 'Hydross the Unstable',
    isFinal = false,
    category = 'raids',
  },
  [21217] = {
    instanceKey = 'serpentshrineCavern',
    bossName = 'The Lurker Below',
    isFinal = false,
    category = 'raids',
  },
  [21215] = {
    instanceKey = 'serpentshrineCavern',
    bossName = 'Leotheras the Blind',
    isFinal = false,
    category = 'raids',
  },
  [21214] = {
    instanceKey = 'serpentshrineCavern',
    bossName = 'Fathom-Lord Karathress',
    isFinal = false,
    category = 'raids',
  },
  [21213] = {
    instanceKey = 'serpentshrineCavern',
    bossName = 'Morogrim Tidewalker',
    isFinal = false,
    category = 'raids',
  },
  [21212] = {
    instanceKey = 'serpentshrineCavern',
    bossName = 'Lady Vashj',
    isFinal = true,
    category = 'raids',
  },
  -- Tempest Keep: The Eye
  [19514] = {
    instanceKey = 'tempestKeep',
    bossName = "Al'ar",
    isFinal = false,
    category = 'raids',
  },
  [19516] = {
    instanceKey = 'tempestKeep',
    bossName = 'Void Reaver',
    isFinal = false,
    category = 'raids',
  },
  [18805] = {
    instanceKey = 'tempestKeep',
    bossName = 'High Astromancer Solarian',
    isFinal = false,
    category = 'raids',
  },
  [19622] = {
    instanceKey = 'tempestKeep',
    bossName = "Kael'thas Sunstrider",
    isFinal = true,
    category = 'raids',
  },
  -- The Battle for Mount Hyjal
  [17767] = {
    instanceKey = 'hyjal',
    bossName = 'Rage Winterchill',
    isFinal = false,
    category = 'raids',
  },
  [17808] = {
    instanceKey = 'hyjal',
    bossName = 'Anetheron',
    isFinal = false,
    category = 'raids',
  },
  [17888] = {
    instanceKey = 'hyjal',
    bossName = "Kaz'rogal",
    isFinal = false,
    category = 'raids',
  },
  [17842] = {
    instanceKey = 'hyjal',
    bossName = 'Azgalor',
    isFinal = false,
    category = 'raids',
  },
  [17968] = {
    instanceKey = 'hyjal',
    bossName = 'Archimonde',
    isFinal = true,
    category = 'raids',
  },
  -- Black Temple
  [22887] = {
    instanceKey = 'blackTemple',
    bossName = "High Warlord Naj'entus",
    isFinal = false,
    category = 'raids',
  },
  [22898] = {
    instanceKey = 'blackTemple',
    bossName = 'Supremus',
    isFinal = false,
    category = 'raids',
  },
  [22841] = {
    instanceKey = 'blackTemple',
    bossName = 'Shade of Akama',
    isFinal = false,
    category = 'raids',
  },
  [22871] = {
    instanceKey = 'blackTemple',
    bossName = 'Teron Gorefiend',
    isFinal = false,
    category = 'raids',
  },
  [22948] = {
    instanceKey = 'blackTemple',
    bossName = 'Gurtogg Bloodboil',
    isFinal = false,
    category = 'raids',
  },
  [23418] = {
    instanceKey = 'blackTemple',
    bossName = 'Reliquary of Souls',
    isFinal = false,
    category = 'raids',
  },
  [23419] = {
    instanceKey = 'blackTemple',
    bossName = 'Reliquary of Souls',
    isFinal = false,
    category = 'raids',
  },
  [23420] = {
    instanceKey = 'blackTemple',
    bossName = 'Reliquary of Souls',
    isFinal = false,
    category = 'raids',
  },
  [22947] = {
    instanceKey = 'blackTemple',
    bossName = 'Mother Shahraz',
    isFinal = false,
    category = 'raids',
  },
  [22949] = {
    instanceKey = 'blackTemple',
    bossName = 'Illidari Council',
    isFinal = false,
    category = 'raids',
  },
  [22950] = {
    instanceKey = 'blackTemple',
    bossName = 'Illidari Council',
    isFinal = false,
    category = 'raids',
  },
  [22951] = {
    instanceKey = 'blackTemple',
    bossName = 'Illidari Council',
    isFinal = false,
    category = 'raids',
  },
  [22952] = {
    instanceKey = 'blackTemple',
    bossName = 'Illidari Council',
    isFinal = false,
    category = 'raids',
  },
  [22917] = {
    instanceKey = 'blackTemple',
    bossName = 'Illidan Stormrage',
    isFinal = true,
    category = 'raids',
  },
  -- Zul'Aman
  [23574] = {
    instanceKey = 'zulAman',
    bossName = "Akil'zon",
    isFinal = false,
    category = 'raids',
  },
  [23576] = {
    instanceKey = 'zulAman',
    bossName = 'Nalorakk',
    isFinal = false,
    category = 'raids',
  },
  [23578] = {
    instanceKey = 'zulAman',
    bossName = "Jan'alai",
    isFinal = false,
    category = 'raids',
  },
  [23577] = {
    instanceKey = 'zulAman',
    bossName = 'Halazzi',
    isFinal = false,
    category = 'raids',
  },
  [24239] = {
    instanceKey = 'zulAman',
    bossName = 'Hex Lord Malacrass',
    isFinal = false,
    category = 'raids',
  },
  [23863] = {
    instanceKey = 'zulAman',
    bossName = "Zul'jin",
    isFinal = true,
    category = 'raids',
  },
  -- Sunwell Plateau
  [24850] = {
    instanceKey = 'sunwellPlateau',
    bossName = 'Kalecgos',
    isFinal = false,
    category = 'raids',
  },
  [24892] = {
    instanceKey = 'sunwellPlateau',
    bossName = 'Sathrovarr the Corruptor',
    isFinal = false,
    category = 'raids',
  },
  [24882] = {
    instanceKey = 'sunwellPlateau',
    bossName = 'Brutallus',
    isFinal = false,
    category = 'raids',
  },
  [25038] = {
    instanceKey = 'sunwellPlateau',
    bossName = 'Felmyst',
    isFinal = false,
    category = 'raids',
  },
  [25166] = {
    instanceKey = 'sunwellPlateau',
    bossName = 'Eredar Twins',
    isFinal = false,
    category = 'raids',
  },
  [25165] = {
    instanceKey = 'sunwellPlateau',
    bossName = 'Eredar Twins',
    isFinal = false,
    category = 'raids',
  },
  [25741] = {
    instanceKey = 'sunwellPlateau',
    bossName = "M'uru",
    isFinal = false,
    category = 'raids',
  },
  [25840] = {
    instanceKey = 'sunwellPlateau',
    bossName = 'Entropius',
    isFinal = false,
    category = 'raids',
  },
  [25315] = {
    instanceKey = 'sunwellPlateau',
    bossName = "Kil'jaeden",
    isFinal = true,
    category = 'raids',
  },
}

function DungeonRaidBossInfo.GetBossInfoByNpcID(npcID)
  if not npcID then
    return nil
  end
  return NPC_ID_TO_BOSS[tonumber(npcID)]
end

-- Extract NPC ID from creature GUID (e.g. Creature-0-0-0-0-17306-0x...)
function DungeonRaidBossInfo.GetNpcIDFromGUID(guid)
  if not guid or type(guid) ~= 'string' then
    return nil
  end
  local id =
    guid:match('^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-[%x]+$') or guid:match(
      '^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)$'
    )
  return id and tonumber(id) or nil
end

function DungeonRaidBossInfo.GetBossInfoByGUID(guid)
  local npcID = DungeonRaidBossInfo.GetNpcIDFromGUID(guid)
  return npcID and DungeonRaidBossInfo.GetBossInfoByNpcID(npcID) or nil
end

-- Return the final boss name for an instance (for firstClearDeaths logic).
function DungeonRaidBossInfo.GetFinalBossName(instanceKey, category)
  if not instanceKey or not category then
    return nil
  end
  for _, info in pairs(NPC_ID_TO_BOSS) do
    if info.instanceKey == instanceKey and info.category == category and info.isFinal then
      return info.bossName
    end
  end
  return nil
end

_G.DungeonRaidBossInfo = DungeonRaidBossInfo
