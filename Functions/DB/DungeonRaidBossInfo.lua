-- NPC ID -> instance key, boss name, isFinal, category (heroics | raids)
-- Used by DungeonRaidStats to update stored values on kill/death.
-- Category matches the storage keys: heroics vs raids.

local DungeonRaidBossInfo = {}

-- [npcID] = { instanceKey = string, bossName = string, isFinal = bool, category = 'heroics'|'raids'|'dungeons' }
local NPC_ID_TO_BOSS = {
  -- Classic Dungeons
  -- Ragefire Chasm
  [11517] = {
    instanceKey = 'ragefireChasm',
    bossName = 'Oggleflint',
    isFinal = false,
    category = 'dungeons',
  },
  [11520] = {
    instanceKey = 'ragefireChasm',
    bossName = 'Taragaman the Hungerer',
    isFinal = false,
    category = 'dungeons',
  },
  [11518] = {
    instanceKey = 'ragefireChasm',
    bossName = 'Jergosh the Invoker',
    isFinal = false,
    category = 'dungeons',
  },
  [11519] = {
    instanceKey = 'ragefireChasm',
    bossName = 'Bazzalan',
    isFinal = true,
    category = 'dungeons',
  },
  -- The Deadmines
  [644] = {
    instanceKey = 'deadmines',
    bossName = "Rhahk'Zor",
    isFinal = false,
    category = 'dungeons',
  },
  [3586] = {
    instanceKey = 'deadmines',
    bossName = 'Miner Johnson',
    isFinal = false,
    category = 'dungeons',
  },
  [643] = {
    instanceKey = 'deadmines',
    bossName = 'Sneed',
    isFinal = false,
    category = 'dungeons',
  },
  [1763] = {
    instanceKey = 'deadmines',
    bossName = 'Gilnid',
    isFinal = false,
    category = 'dungeons',
  },
  [646] = {
    instanceKey = 'deadmines',
    bossName = 'Mr. Smite',
    isFinal = false,
    category = 'dungeons',
  },
  [647] = {
    instanceKey = 'deadmines',
    bossName = 'Captain Greenskin',
    isFinal = false,
    category = 'dungeons',
  },
  [639] = {
    instanceKey = 'deadmines',
    bossName = 'Edwin VanCleef',
    isFinal = true,
    category = 'dungeons',
  },
  [645] = {
    instanceKey = 'deadmines',
    bossName = 'Cookie',
    isFinal = false,
    category = 'dungeons',
  },
  -- Wailing Caverns
  [3653] = {
    instanceKey = 'wailingCaverns',
    bossName = 'Kresh',
    isFinal = false,
    category = 'dungeons',
  },
  [3671] = {
    instanceKey = 'wailingCaverns',
    bossName = 'Lady Anacondra',
    isFinal = false,
    category = 'dungeons',
  },
  [3669] = {
    instanceKey = 'wailingCaverns',
    bossName = 'Lord Cobrahn',
    isFinal = false,
    category = 'dungeons',
  },
  [5912] = {
    instanceKey = 'wailingCaverns',
    bossName = 'Deviate Faerie Dragon',
    isFinal = false,
    category = 'dungeons',
  },
  [3670] = {
    instanceKey = 'wailingCaverns',
    bossName = 'Lord Pythas',
    isFinal = false,
    category = 'dungeons',
  },
  [3674] = {
    instanceKey = 'wailingCaverns',
    bossName = 'Skum',
    isFinal = false,
    category = 'dungeons',
  },
  [3673] = {
    instanceKey = 'wailingCaverns',
    bossName = 'Lord Serpentis',
    isFinal = false,
    category = 'dungeons',
  },
  [5775] = {
    instanceKey = 'wailingCaverns',
    bossName = 'Verdan the Everliving',
    isFinal = false,
    category = 'dungeons',
  },
  [3654] = {
    instanceKey = 'wailingCaverns',
    bossName = 'Mutanus the Devourer',
    isFinal = true,
    category = 'dungeons',
  },
  -- Shadowfang Keep
  [3914] = {
    instanceKey = 'shadowfangKeep',
    bossName = 'Rethilgore',
    isFinal = false,
    category = 'dungeons',
  },
  [3886] = {
    instanceKey = 'shadowfangKeep',
    bossName = 'Razorclaw the Butcher',
    isFinal = false,
    category = 'dungeons',
  },
  [3887] = {
    instanceKey = 'shadowfangKeep',
    bossName = 'Baron Silverlaine',
    isFinal = false,
    category = 'dungeons',
  },
  [4278] = {
    instanceKey = 'shadowfangKeep',
    bossName = 'Commander Springvale',
    isFinal = false,
    category = 'dungeons',
  },
  [4279] = {
    instanceKey = 'shadowfangKeep',
    bossName = 'Odo the Blindwatcher',
    isFinal = false,
    category = 'dungeons',
  },
  [3872] = {
    instanceKey = 'shadowfangKeep',
    bossName = 'Deathstalker Vincent',
    isFinal = false,
    category = 'dungeons',
  },
  [4274] = {
    instanceKey = 'shadowfangKeep',
    bossName = 'Fenrus the Devourer',
    isFinal = false,
    category = 'dungeons',
  },
  [3927] = {
    instanceKey = 'shadowfangKeep',
    bossName = 'Wolf Master Nandos',
    isFinal = false,
    category = 'dungeons',
  },
  [4275] = {
    instanceKey = 'shadowfangKeep',
    bossName = 'Archmage Arugal',
    isFinal = true,
    category = 'dungeons',
  },
  [14682] = {
    instanceKey = 'shadowfangKeep',
    bossName = 'Sever',
    isFinal = false,
    category = 'dungeons',
  },
  -- Blackfathom Deeps
  [4887] = {
    instanceKey = 'blackfathomDeeps',
    bossName = 'Ghamoo-ra',
    isFinal = false,
    category = 'dungeons',
  },
  [4831] = {
    instanceKey = 'blackfathomDeeps',
    bossName = 'Lady Sarevess',
    isFinal = false,
    category = 'dungeons',
  },
  [6243] = {
    instanceKey = 'blackfathomDeeps',
    bossName = 'Gelihast',
    isFinal = false,
    category = 'dungeons',
  },
  [12902] = {
    instanceKey = 'blackfathomDeeps',
    bossName = 'Lorgus Jett',
    isFinal = false,
    category = 'dungeons',
  },
  [12876] = {
    instanceKey = 'blackfathomDeeps',
    bossName = 'Baron Aquanis',
    isFinal = false,
    category = 'dungeons',
  },
  [4832] = {
    instanceKey = 'blackfathomDeeps',
    bossName = 'Twilight Lord Kelris',
    isFinal = false,
    category = 'dungeons',
  },
  [4830] = {
    instanceKey = 'blackfathomDeeps',
    bossName = "Old Serra'kis",
    isFinal = false,
    category = 'dungeons',
  },
  [4829] = {
    instanceKey = 'blackfathomDeeps',
    bossName = "Aku'mai",
    isFinal = true,
    category = 'dungeons',
  },
  -- The Stockade
  [1696] = {
    instanceKey = 'stockades',
    bossName = 'Targorr the Dread',
    isFinal = false,
    category = 'dungeons',
  },
  [1666] = {
    instanceKey = 'stockades',
    bossName = 'Kam Deepfury',
    isFinal = false,
    category = 'dungeons',
  },
  [1717] = {
    instanceKey = 'stockades',
    bossName = 'Hamhock',
    isFinal = false,
    category = 'dungeons',
  },
  [1663] = {
    instanceKey = 'stockades',
    bossName = 'Dextren Ward',
    isFinal = false,
    category = 'dungeons',
  },
  [1716] = {
    instanceKey = 'stockades',
    bossName = 'Bazil Thredd',
    isFinal = false,
    category = 'dungeons',
  },
  [1720] = {
    instanceKey = 'stockades',
    bossName = 'Bruegal Ironknuckle',
    isFinal = true,
    category = 'dungeons',
  },
  -- Gnomeregan
  [7361] = {
    instanceKey = 'gnomeregan',
    bossName = 'Grubbis',
    isFinal = false,
    category = 'dungeons',
  },
  [7079] = {
    instanceKey = 'gnomeregan',
    bossName = 'Viscous Fallout',
    isFinal = false,
    category = 'dungeons',
  },
  [6235] = {
    instanceKey = 'gnomeregan',
    bossName = 'Electrocutioner 6000',
    isFinal = false,
    category = 'dungeons',
  },
  [6229] = {
    instanceKey = 'gnomeregan',
    bossName = 'Crowd Pummeler 9-60',
    isFinal = false,
    category = 'dungeons',
  },
  [6228] = {
    instanceKey = 'gnomeregan',
    bossName = 'Mekgineer Thermaplugg',
    isFinal = false,
    category = 'dungeons',
  },
  [7800] = {
    instanceKey = 'gnomeregan',
    bossName = 'Mekgineer Thermaplugg',
    isFinal = true,
    category = 'dungeons',
  },
  -- Razorfen Kraul
  [6168] = {
    instanceKey = 'razorfenKraul',
    bossName = 'Roogug',
    isFinal = false,
    category = 'dungeons',
  },
  [4424] = {
    instanceKey = 'razorfenKraul',
    bossName = 'Aggem Thorncurse',
    isFinal = false,
    category = 'dungeons',
  },
  [4428] = {
    instanceKey = 'razorfenKraul',
    bossName = 'Death Speaker Jargba',
    isFinal = false,
    category = 'dungeons',
  },
  [4420] = {
    instanceKey = 'razorfenKraul',
    bossName = 'Overlord Ramtusk',
    isFinal = false,
    category = 'dungeons',
  },
  [4422] = {
    instanceKey = 'razorfenKraul',
    bossName = 'Agathelos the Raging',
    isFinal = false,
    category = 'dungeons',
  },
  [4421] = {
    instanceKey = 'razorfenKraul',
    bossName = 'Blind Hunter',
    isFinal = true,
    category = 'dungeons',
  },
  -- Scarlet Monastery (Graveyard, Library, Armory, Cathedral)
  [3983] = {
    instanceKey = 'scarletMonastery',
    bossName = 'Interrogator Vishas',
    isFinal = false,
    category = 'dungeons',
  },
  [4543] = {
    instanceKey = 'scarletMonastery',
    bossName = 'Bloodmage Thalnos',
    isFinal = false,
    category = 'dungeons',
  },
  [6490] = {
    instanceKey = 'scarletMonastery',
    bossName = 'Azshir the Sleepless',
    isFinal = false,
    category = 'dungeons',
  },
  [6488] = {
    instanceKey = 'scarletMonastery',
    bossName = 'Fallen Champion',
    isFinal = false,
    category = 'dungeons',
  },
  [6489] = {
    instanceKey = 'scarletMonastery',
    bossName = 'Ironspine',
    isFinal = false,
    category = 'dungeons',
  },
  [3974] = {
    instanceKey = 'scarletMonastery',
    bossName = 'Commander Mograine',
    isFinal = false,
    category = 'dungeons',
  },
  [6487] = {
    instanceKey = 'scarletMonastery',
    bossName = 'Houndmaster Loksey',
    isFinal = false,
    category = 'dungeons',
  },
  [3975] = {
    instanceKey = 'scarletMonastery',
    bossName = 'Herod',
    isFinal = false,
    category = 'dungeons',
  },
  [3976] = {
    instanceKey = 'scarletMonastery',
    bossName = 'Scarlet Commander Mograine',
    isFinal = false,
    category = 'dungeons',
  },
  [3977] = {
    instanceKey = 'scarletMonastery',
    bossName = 'High Inquisitor Whitemane',
    isFinal = true,
    category = 'dungeons',
  },
  [4542] = {
    instanceKey = 'scarletMonastery',
    bossName = 'High Inquisitor Fairbanks',
    isFinal = false,
    category = 'dungeons',
  },
  [14693] = {
    instanceKey = 'scarletMonastery',
    bossName = 'Scarlet Commander',
    isFinal = false,
    category = 'dungeons',
  },
  -- Razorfen Downs
  [7355] = {
    instanceKey = 'razorfenDowns',
    bossName = "Tuten'kash",
    isFinal = false,
    category = 'dungeons',
  },
  [7356] = {
    instanceKey = 'razorfenDowns',
    bossName = 'Mordresh Fire Eye',
    isFinal = false,
    category = 'dungeons',
  },
  [7357] = {
    instanceKey = 'razorfenDowns',
    bossName = 'Glutton',
    isFinal = false,
    category = 'dungeons',
  },
  [7354] = {
    instanceKey = 'razorfenDowns',
    bossName = 'Ragglesnout',
    isFinal = false,
    category = 'dungeons',
  },
  [8567] = {
    instanceKey = 'razorfenDowns',
    bossName = 'Death Speaker Blackhorn',
    isFinal = false,
    category = 'dungeons',
  },
  [7358] = {
    instanceKey = 'razorfenDowns',
    bossName = 'Amnennar the Coldbringer',
    isFinal = true,
    category = 'dungeons',
  },
  [14686] = {
    instanceKey = 'razorfenDowns',
    bossName = "Lady Falther'ess",
    isFinal = false,
    category = 'dungeons',
  },
  -- Uldaman
  [6910] = {
    instanceKey = 'uldaman',
    bossName = 'Revelosh',
    isFinal = false,
    category = 'dungeons',
  },
  [6906] = {
    instanceKey = 'uldaman',
    bossName = 'Baelog',
    isFinal = false,
    category = 'dungeons',
  },
  [7228] = {
    instanceKey = 'uldaman',
    bossName = 'Ironaya',
    isFinal = false,
    category = 'dungeons',
  },
  [7023] = {
    instanceKey = 'uldaman',
    bossName = 'Obsidian Sentinel',
    isFinal = false,
    category = 'dungeons',
  },
  [7206] = {
    instanceKey = 'uldaman',
    bossName = 'Ancient Stone Keeper',
    isFinal = false,
    category = 'dungeons',
  },
  [7291] = {
    instanceKey = 'uldaman',
    bossName = 'Galgann Firehammer',
    isFinal = false,
    category = 'dungeons',
  },
  [4854] = {
    instanceKey = 'uldaman',
    bossName = 'Grimlok',
    isFinal = false,
    category = 'dungeons',
  },
  [2748] = {
    instanceKey = 'uldaman',
    bossName = 'Archaedas',
    isFinal = true,
    category = 'dungeons',
  },
  -- Maraudon
  [13282] = {
    instanceKey = 'maraudon',
    bossName = 'Noxxion',
    isFinal = false,
    category = 'dungeons',
  },
  [12258] = {
    instanceKey = 'maraudon',
    bossName = 'Razorlash',
    isFinal = false,
    category = 'dungeons',
  },
  [12236] = {
    instanceKey = 'maraudon',
    bossName = 'Lord Vyletongue',
    isFinal = false,
    category = 'dungeons',
  },
  [12225] = {
    instanceKey = 'maraudon',
    bossName = 'Celebras the Cursed',
    isFinal = false,
    category = 'dungeons',
  },
  [12203] = {
    instanceKey = 'maraudon',
    bossName = 'Landslide',
    isFinal = false,
    category = 'dungeons',
  },
  [13601] = {
    instanceKey = 'maraudon',
    bossName = 'Tinkerer Gizlock',
    isFinal = false,
    category = 'dungeons',
  },
  [13596] = {
    instanceKey = 'maraudon',
    bossName = 'Rotgrip',
    isFinal = false,
    category = 'dungeons',
  },
  [12201] = {
    instanceKey = 'maraudon',
    bossName = 'Princess Theradras',
    isFinal = true,
    category = 'dungeons',
  },
  [12237] = {
    instanceKey = 'maraudon',
    bossName = 'Meshlok the Harvester',
    isFinal = false,
    category = 'dungeons',
  },
  -- Zul'Farrak
  [8127] = {
    instanceKey = 'zulFarrak',
    bossName = "Antu'sul",
    isFinal = false,
    category = 'dungeons',
  },
  [7272] = {
    instanceKey = 'zulFarrak',
    bossName = "Witch Doctor Zum'rah",
    isFinal = false,
    category = 'dungeons',
  },
  [7271] = {
    instanceKey = 'zulFarrak',
    bossName = "Shadowpriest Sezz'ziz",
    isFinal = false,
    category = 'dungeons',
  },
  [7796] = {
    instanceKey = 'zulFarrak',
    bossName = 'Hydromancer Velratha',
    isFinal = false,
    category = 'dungeons',
  },
  [7275] = {
    instanceKey = 'zulFarrak',
    bossName = 'Ruuzlu',
    isFinal = false,
    category = 'dungeons',
  },
  [7604] = {
    instanceKey = 'zulFarrak',
    bossName = 'Sergeant Bly',
    isFinal = false,
    category = 'dungeons',
  },
  [7795] = {
    instanceKey = 'zulFarrak',
    bossName = 'Sandfury Executioner',
    isFinal = false,
    category = 'dungeons',
  },
  [10081] = {
    instanceKey = 'zulFarrak',
    bossName = 'Dustwraith',
    isFinal = false,
    category = 'dungeons',
  },
  [7267] = {
    instanceKey = 'zulFarrak',
    bossName = 'Chief Ukorz Sandscalp',
    isFinal = true,
    category = 'dungeons',
  },
  [7797] = {
    instanceKey = 'zulFarrak',
    bossName = 'Zerillis',
    isFinal = false,
    category = 'dungeons',
  },
  [10082] = {
    instanceKey = 'zulFarrak',
    bossName = 'Sandarr Dunereaver',
    isFinal = false,
    category = 'dungeons',
  },
  [10080] = {
    instanceKey = 'zulFarrak',
    bossName = "Gahz'rilla",
    isFinal = false,
    category = 'dungeons',
  },
  -- The Temple of Atal'Hakkar
  [5713] = {
    instanceKey = 'sunkenTemple',
    bossName = 'Dreamscythe',
    isFinal = false,
    category = 'dungeons',
  },
  [8580] = {
    instanceKey = 'sunkenTemple',
    bossName = 'Weaver',
    isFinal = false,
    category = 'dungeons',
  },
  [5721] = {
    instanceKey = 'sunkenTemple',
    bossName = 'Hazzas',
    isFinal = false,
    category = 'dungeons',
  },
  [5720] = {
    instanceKey = 'sunkenTemple',
    bossName = 'Morphaz',
    isFinal = false,
    category = 'dungeons',
  },
  [5710] = {
    instanceKey = 'sunkenTemple',
    bossName = "Jammal'an the Prophet",
    isFinal = false,
    category = 'dungeons',
  },
  [5711] = {
    instanceKey = 'sunkenTemple',
    bossName = 'Ogom the Wretched',
    isFinal = false,
    category = 'dungeons',
  },
  [5719] = {
    instanceKey = 'sunkenTemple',
    bossName = 'Avatar of Hakkar',
    isFinal = false,
    category = 'dungeons',
  },
  [5722] = {
    instanceKey = 'sunkenTemple',
    bossName = 'Shade of Eranikus',
    isFinal = false,
    category = 'dungeons',
  },
  [8443] = {
    instanceKey = 'sunkenTemple',
    bossName = "Atal'alarion",
    isFinal = false,
    category = 'dungeons',
  },
  [5709] = {
    instanceKey = 'sunkenTemple',
    bossName = 'Eranikus',
    isFinal = true,
    category = 'dungeons',
  },
  -- Blackrock Depths
  [9025] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Lord Roccor',
    isFinal = false,
    category = 'dungeons',
  },
  [9016] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Fineous Darkvire',
    isFinal = false,
    category = 'dungeons',
  },
  [9319] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Houndmaster Grebmar',
    isFinal = false,
    category = 'dungeons',
  },
  [9018] = {
    instanceKey = 'blackrockDepths',
    bossName = 'High Interrogator Gerstahn',
    isFinal = false,
    category = 'dungeons',
  },
  [10096] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Ring of Law',
    isFinal = false,
    category = 'dungeons',
  },
  [9024] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Pyromancer Loregrain',
    isFinal = false,
    category = 'dungeons',
  },
  [9033] = {
    instanceKey = 'blackrockDepths',
    bossName = 'General Angerforge',
    isFinal = false,
    category = 'dungeons',
  },
  [8983] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Golem Lord Argelmach',
    isFinal = false,
    category = 'dungeons',
  },
  [9543] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Ribbly Screwspigot',
    isFinal = false,
    category = 'dungeons',
  },
  [9537] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Hurley Blackbreath',
    isFinal = false,
    category = 'dungeons',
  },
  [9499] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Phalanx',
    isFinal = false,
    category = 'dungeons',
  },
  [9502] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Plugger Spazzring',
    isFinal = false,
    category = 'dungeons',
  },
  [9017] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Lord Incendius',
    isFinal = false,
    category = 'dungeons',
  },
  [9056] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Warder Stilgiss',
    isFinal = false,
    category = 'dungeons',
  },
  [9041] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Warder Thelwater',
    isFinal = false,
    category = 'dungeons',
  },
  [9042] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Warder Theldren',
    isFinal = false,
    category = 'dungeons',
  },
  [9156] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Princess Moira Bronzebeard',
    isFinal = false,
    category = 'dungeons',
  },
  [9938] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Princess Moira Bronzebeard',
    isFinal = false,
    category = 'dungeons',
  },
  [8929] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Princess Moira Bronzebeard',
    isFinal = false,
    category = 'dungeons',
  },
  [9019] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Emperor Dagran Thaurissan',
    isFinal = true,
    category = 'dungeons',
  },
  [9438] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Warder Thelwater',
    isFinal = false,
    category = 'dungeons',
  },
  [9442] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Warder Theldren',
    isFinal = false,
    category = 'dungeons',
  },
  [9443] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Warder Theldren',
    isFinal = false,
    category = 'dungeons',
  },
  [9439] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Warder Stilgiss',
    isFinal = false,
    category = 'dungeons',
  },
  [9437] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Warder Stilgiss',
    isFinal = false,
    category = 'dungeons',
  },
  [9441] = {
    instanceKey = 'blackrockDepths',
    bossName = 'Warder Thelwater',
    isFinal = false,
    category = 'dungeons',
  },
  [9039] = {
    instanceKey = 'blackrockDepths',
    bossName = 'General Angerforge',
    isFinal = false,
    category = 'dungeons',
  },
  [9034] = {
    instanceKey = 'blackrockDepths',
    bossName = 'General Angerforge',
    isFinal = false,
    category = 'dungeons',
  },
  [9035] = {
    instanceKey = 'blackrockDepths',
    bossName = 'General Angerforge',
    isFinal = false,
    category = 'dungeons',
  },
  [9036] = {
    instanceKey = 'blackrockDepths',
    bossName = 'General Angerforge',
    isFinal = false,
    category = 'dungeons',
  },
  [9037] = {
    instanceKey = 'blackrockDepths',
    bossName = 'General Angerforge',
    isFinal = false,
    category = 'dungeons',
  },
  [9038] = {
    instanceKey = 'blackrockDepths',
    bossName = 'General Angerforge',
    isFinal = false,
    category = 'dungeons',
  },
  [9040] = {
    instanceKey = 'blackrockDepths',
    bossName = 'General Angerforge',
    isFinal = false,
    category = 'dungeons',
  },
  -- Blackrock Spire (LBRS/UBRS)
  [9196] = {
    instanceKey = 'blackrockSpire',
    bossName = 'Highlord Omokk',
    isFinal = false,
    category = 'dungeons',
  },
  [9236] = {
    instanceKey = 'blackrockSpire',
    bossName = "Shadow Hunter Vosh'gajin",
    isFinal = false,
    category = 'dungeons',
  },
  [9237] = {
    instanceKey = 'blackrockSpire',
    bossName = 'War Master Voone',
    isFinal = false,
    category = 'dungeons',
  },
  [10596] = {
    instanceKey = 'blackrockSpire',
    bossName = 'Mother Smolderweb',
    isFinal = false,
    category = 'dungeons',
  },
  [10584] = {
    instanceKey = 'blackrockSpire',
    bossName = 'Urok Doomhowl',
    isFinal = false,
    category = 'dungeons',
  },
  [9736] = {
    instanceKey = 'blackrockSpire',
    bossName = 'Quartermaster Zigris',
    isFinal = false,
    category = 'dungeons',
  },
  [10268] = {
    instanceKey = 'blackrockSpire',
    bossName = 'Gizrul the Slavener',
    isFinal = false,
    category = 'dungeons',
  },
  [10220] = {
    instanceKey = 'blackrockSpire',
    bossName = 'Halycon',
    isFinal = false,
    category = 'dungeons',
  },
  [9568] = {
    instanceKey = 'blackrockSpire',
    bossName = 'Overlord Wyrmthalak',
    isFinal = false,
    category = 'dungeons',
  },
  [9816] = {
    instanceKey = 'blackrockSpire',
    bossName = 'Pyroguard Emberseer',
    isFinal = false,
    category = 'dungeons',
  },
  [10429] = {
    instanceKey = 'blackrockSpire',
    bossName = 'Solakar Flamewrath',
    isFinal = false,
    category = 'dungeons',
  },
  [10339] = {
    instanceKey = 'blackrockSpire',
    bossName = 'Gyth',
    isFinal = false,
    category = 'dungeons',
  },
  [10430] = {
    instanceKey = 'blackrockSpire',
    bossName = 'Rend Blackhand',
    isFinal = false,
    category = 'dungeons',
  },
  [10363] = {
    instanceKey = 'blackrockSpire',
    bossName = 'General Drakkisath',
    isFinal = true,
    category = 'dungeons',
  },
  -- Stratholme
  [11058] = {
    instanceKey = 'stratholme',
    bossName = 'Fras Siabi',
    isFinal = false,
    category = 'dungeons',
  },
  [10393] = {
    instanceKey = 'stratholme',
    bossName = 'Skul',
    isFinal = false,
    category = 'dungeons',
  },
  [10558] = {
    instanceKey = 'stratholme',
    bossName = 'Hearthsinger Forresten',
    isFinal = false,
    category = 'dungeons',
  },
  [10516] = {
    instanceKey = 'stratholme',
    bossName = 'Timmy the Cruel',
    isFinal = false,
    category = 'dungeons',
  },
  [11143] = {
    instanceKey = 'stratholme',
    bossName = 'Postmaster Malown',
    isFinal = false,
    category = 'dungeons',
  },
  [10808] = {
    instanceKey = 'stratholme',
    bossName = 'Stonespine',
    isFinal = false,
    category = 'dungeons',
  },
  [11032] = {
    instanceKey = 'stratholme',
    bossName = 'Baroness Anastari',
    isFinal = false,
    category = 'dungeons',
  },
  [10997] = {
    instanceKey = 'stratholme',
    bossName = "Nerub'enkan",
    isFinal = false,
    category = 'dungeons',
  },
  [11120] = {
    instanceKey = 'stratholme',
    bossName = 'Cannon Master Willey',
    isFinal = false,
    category = 'dungeons',
  },
  [11121] = {
    instanceKey = 'stratholme',
    bossName = 'Maleki the Pallid',
    isFinal = false,
    category = 'dungeons',
  },
  [10811] = {
    instanceKey = 'stratholme',
    bossName = 'Baron Rivendare',
    isFinal = false,
    category = 'dungeons',
  },
  [10813] = {
    instanceKey = 'stratholme',
    bossName = 'Malor the Zealous',
    isFinal = false,
    category = 'dungeons',
  },
  [10435] = {
    instanceKey = 'stratholme',
    bossName = 'Baron Rivendare',
    isFinal = false,
    category = 'dungeons',
  },
  [10809] = {
    instanceKey = 'stratholme',
    bossName = 'Baroness Anastari',
    isFinal = false,
    category = 'dungeons',
  },
  [10437] = {
    instanceKey = 'stratholme',
    bossName = 'Baron Rivendare',
    isFinal = false,
    category = 'dungeons',
  },
  [10438] = {
    instanceKey = 'stratholme',
    bossName = 'Baron Rivendare',
    isFinal = false,
    category = 'dungeons',
  },
  [10436] = {
    instanceKey = 'stratholme',
    bossName = 'Baron Rivendare',
    isFinal = false,
    category = 'dungeons',
  },
  [10439] = {
    instanceKey = 'stratholme',
    bossName = 'The Unforgiven',
    isFinal = false,
    category = 'dungeons',
  },
  [10440] = {
    instanceKey = 'stratholme',
    bossName = 'Baron Rivendare',
    isFinal = true,
    category = 'dungeons',
  },
  [14684] = {
    instanceKey = 'stratholme',
    bossName = 'Balzaphon',
    isFinal = false,
    category = 'dungeons',
  },
  -- Dire Maul
  [14354] = {
    instanceKey = 'direMaul',
    bossName = 'Pusillin',
    isFinal = false,
    category = 'dungeons',
  },
  [14327] = {
    instanceKey = 'direMaul',
    bossName = 'Guardian of the Gordok',
    isFinal = false,
    category = 'dungeons',
  },
  [13280] = {
    instanceKey = 'direMaul',
    bossName = 'Hydrospawn',
    isFinal = false,
    category = 'dungeons',
  },
  [11490] = {
    instanceKey = 'direMaul',
    bossName = 'Lethtendris',
    isFinal = false,
    category = 'dungeons',
  },
  [11492] = {
    instanceKey = 'direMaul',
    bossName = 'Alzzin the Wildshaper',
    isFinal = false,
    category = 'dungeons',
  },
  [14326] = {
    instanceKey = 'direMaul',
    bossName = "Guard Mol'dar",
    isFinal = false,
    category = 'dungeons',
  },
  [14322] = {
    instanceKey = 'direMaul',
    bossName = 'Stomper Kreeg',
    isFinal = false,
    category = 'dungeons',
  },
  [14321] = {
    instanceKey = 'direMaul',
    bossName = 'Guard Fengus',
    isFinal = false,
    category = 'dungeons',
  },
  [14323] = {
    instanceKey = 'direMaul',
    bossName = "Guard Slip'kik",
    isFinal = false,
    category = 'dungeons',
  },
  [14325] = {
    instanceKey = 'direMaul',
    bossName = 'Captain Kromcrush',
    isFinal = false,
    category = 'dungeons',
  },
  [14324] = {
    instanceKey = 'direMaul',
    bossName = "Cho'Rush the Observer",
    isFinal = true,
    category = 'dungeons',
  },
  [11501] = {
    instanceKey = 'direMaul',
    bossName = 'King Gordok',
    isFinal = false,
    category = 'dungeons',
  },
  [11489] = {
    instanceKey = 'direMaul',
    bossName = 'Illyanna Ravenoak',
    isFinal = false,
    category = 'dungeons',
  },
  [11487] = {
    instanceKey = 'direMaul',
    bossName = 'Magister Kalendris',
    isFinal = false,
    category = 'dungeons',
  },
  [11467] = {
    instanceKey = 'direMaul',
    bossName = 'Tendris Warpwood',
    isFinal = false,
    category = 'dungeons',
  },
  [11488] = {
    instanceKey = 'direMaul',
    bossName = "Immol'thar",
    isFinal = false,
    category = 'dungeons',
  },
  [11496] = {
    instanceKey = 'direMaul',
    bossName = 'Prince Tortheldrin',
    isFinal = false,
    category = 'dungeons',
  },
  [11486] = {
    instanceKey = 'direMaul',
    bossName = 'King Gordok',
    isFinal = false,
    category = 'dungeons',
  },
  [14506] = {
    instanceKey = 'direMaul',
    bossName = 'King Gordok',
    isFinal = false,
    category = 'dungeons',
  },
  [14690] = {
    instanceKey = 'direMaul',
    bossName = 'Revanchion',
    isFinal = false,
    category = 'dungeons',
  },
  -- Scholomance
  [10506] = {
    instanceKey = 'scholomance',
    bossName = 'Kirtonos the Herald',
    isFinal = false,
    category = 'dungeons',
  },
  [10503] = {
    instanceKey = 'scholomance',
    bossName = 'Jandice Barov',
    isFinal = false,
    category = 'dungeons',
  },
  [11622] = {
    instanceKey = 'scholomance',
    bossName = 'Rattlegore',
    isFinal = false,
    category = 'dungeons',
  },
  [10433] = {
    instanceKey = 'scholomance',
    bossName = 'Marduk Blackpool',
    isFinal = false,
    category = 'dungeons',
  },
  [10432] = {
    instanceKey = 'scholomance',
    bossName = 'Vectus',
    isFinal = false,
    category = 'dungeons',
  },
  [10508] = {
    instanceKey = 'scholomance',
    bossName = 'Ras Frostwhisper',
    isFinal = false,
    category = 'dungeons',
  },
  [10505] = {
    instanceKey = 'scholomance',
    bossName = 'Instructor Malicia',
    isFinal = false,
    category = 'dungeons',
  },
  [11261] = {
    instanceKey = 'scholomance',
    bossName = 'Doctor Theolen Krastinov',
    isFinal = false,
    category = 'dungeons',
  },
  [10901] = {
    instanceKey = 'scholomance',
    bossName = 'Lorekeeper Polkelt',
    isFinal = false,
    category = 'dungeons',
  },
  [10507] = {
    instanceKey = 'scholomance',
    bossName = 'The Ravenian',
    isFinal = false,
    category = 'dungeons',
  },
  [10504] = {
    instanceKey = 'scholomance',
    bossName = 'Lady Illucia Barov',
    isFinal = false,
    category = 'dungeons',
  },
  [10502] = {
    instanceKey = 'scholomance',
    bossName = 'Kormok',
    isFinal = false,
    category = 'dungeons',
  },
  [1853] = {
    instanceKey = 'scholomance',
    bossName = 'Darkmaster Gandling',
    isFinal = true,
    category = 'dungeons',
  },
  [14695] = {
    instanceKey = 'scholomance',
    bossName = 'Lord Alexei Barov',
    isFinal = false,
    category = 'dungeons',
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
