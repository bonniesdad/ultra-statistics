function IsDungeonBoss(unitGUID)
  if not unitGUID then
    return false, false
  end

  local inInstance, instanceType = IsInInstance()
  if not inInstance or (instanceType ~= 'party' and instanceType ~= 'raid') then
    return false, false
  end

  local npcID =
    tonumber(unitGUID:match('^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-[%x]+$')) or tonumber(
      unitGUID:match('^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)$')
    )
  if not npcID then
    return false, false
  end

  local dungeonBossIDs = {
    -- Ragefire Chasm
    [11520] = true,
    [11517] = true,
    [11518] = true,
    [11519] = true,
    -- The Deadmines
    [644] = true,
    [3586] = true,
    [643] = true,
    [1763] = true,
    [646] = true,
    [647] = true,
    [639] = true,
    [645] = true,
    -- Wailing Caverns
    [3653] = true,
    [3671] = true,
    [3669] = true,
    [5912] = true,
    [3670] = true,
    [3674] = true,
    [3673] = true,
    [5775] = true,
    [3654] = true,
    -- Shadowfang Keep
    [3914] = true,
    [3886] = true,
    [3887] = true,
    [4278] = true,
    [4279] = true,
    [3872] = true,
    [4274] = true,
    [3927] = true,
    [4275] = true,
    [14682] = true,
    -- Blackfathom Deeps
    [4887] = true,
    [4831] = true,
    [6243] = true,
    [12902] = true,
    [12876] = true,
    [4832] = true,
    [4830] = true,
    [4829] = true,
    -- The Stockade
    [1696] = true,
    [1666] = true,
    [1717] = true,
    [1663] = true,
    [1716] = true,
    [1720] = true,
    -- Gnomeregan
    [7361] = true,
    [7079] = true,
    [6235] = true,
    [6229] = true,
    [6228] = true,
    [7800] = true,
    -- Razorfen Kraul
    [6168] = true,
    [4424] = true,
    [4428] = true,
    [4420] = true,
    [4422] = true,
    [4421] = true,
    -- Scarlet Monastery
    [3983] = true,
    [4543] = true,
    [6490] = true,
    [6488] = true,
    [6489] = true,
    [3974] = true,
    [6487] = true,
    [3975] = true,
    [3976] = true,
    [3977] = true,
    [4542] = true,
    [14693] = true,
    -- Razorfen Downs
    [7355] = true,
    [7356] = true,
    [7357] = true,
    [7354] = true,
    [8567] = true,
    [7358] = true,
    [14686] = true,
    -- Uldaman
    [6910] = true,
    [6906] = true,
    [7228] = true,
    [7023] = true,
    [7206] = true,
    [7291] = true,
    [4854] = true,
    [2748] = true,
    -- Maraudon
    [13282] = true,
    [12258] = true,
    [12236] = true,
    [12225] = true,
    [12203] = true,
    [13601] = true,
    [13596] = true,
    [12201] = true,
    [12237] = true,
    -- Zul'Farrak
    [8127] = true,
    [7272] = true,
    [7271] = true,
    [7796] = true,
    [7275] = true,
    [7604] = true,
    [7795] = true,
    [10081] = true,
    [7267] = true,
    [7797] = true,
    [10082] = true,
    [10080] = true,
    -- The Temple of Atal'Hakkar
    [5713] = true,
    [8580] = true,
    [5721] = true,
    [5720] = true,
    [5710] = true,
    [5711] = true,
    [5719] = true,
    [5722] = true,
    [8443] = true,
    [5709] = true,
    -- Blackrock Depths
    [9025] = true,
    [9016] = true,
    [9319] = true,
    [9018] = true,
    [10096] = true,
    [9024] = true,
    [9033] = true,
    [8983] = true,
    [9543] = true,
    [9537] = true,
    [9499] = true,
    [9502] = true,
    [9017] = true,
    [9056] = true,
    [9041] = true,
    [9042] = true,
    [9156] = true,
    [9938] = true,
    [8929] = true,
    [9019] = true,
    [9438] = true,
    [9442] = true,
    [9443] = true,
    [9439] = true,
    [9437] = true,
    [9441] = true,
    [9039] = true,
    [9034] = true,
    [9035] = true,
    [9036] = true,
    [9037] = true,
    [9038] = true,
    [9040] = true,
    -- Blackrock Spire
    [9196] = true,
    [9236] = true,
    [9237] = true,
    [10596] = true,
    [10584] = true,
    [9736] = true,
    [10268] = true,
    [10220] = true,
    [9568] = true,
    [9816] = true,
    [10429] = true,
    [10339] = true,
    [10430] = true,
    [10363] = true,
    -- Stratholme
    [11058] = true,
    [10393] = true,
    [10558] = true,
    [10516] = true,
    [11143] = true,
    [10808] = true,
    [11032] = true,
    [10997] = true,
    [11120] = true,
    [11121] = true,
    [10811] = true,
    [10813] = true,
    [10435] = true,
    [10809] = true,
    [10437] = true,
    [10438] = true,
    [10436] = true,
    [10439] = true,
    [10440] = true,
    [14684] = true,
    -- Dire Maul
    [14354] = true,
    [14327] = true,
    [13280] = true,
    [11490] = true,
    [11492] = true,
    [14326] = true,
    [14322] = true,
    [14321] = true,
    [14323] = true,
    [14325] = true,
    [14324] = true,
    [11501] = true,
    [11489] = true,
    [11487] = true,
    [11467] = true,
    [11488] = true,
    [11496] = true,
    [11486] = true,
    [14506] = true,
    [14690] = true,
    -- Scholomance
    [10506] = true,
    [10503] = true,
    [11622] = true,
    [10433] = true,
    [10432] = true,
    [10508] = true,
    [10505] = true,
    [11261] = true,
    [10901] = true,
    [10507] = true,
    [10504] = true,
    [10502] = true,
    [1853] = true,
    [14695] = true,
    -- TBC Dungeons
    -- The Blood Furnace
    [17666] = true,
    [17380] = true,
    [17377] = true,
    -- The Shattered Halls
    [16807] = true,
    [20923] = true,
    [16809] = true,
    [16808] = true,
    -- The Slave Pens
    [17941] = true,
    [17991] = true,
    [17942] = true,
    -- The Underbog
    [17770] = true,
    [18105] = true,
    [17826] = true,
    [17882] = true,
    -- The Steamvault
    [17797] = true,
    [17796] = true,
    [17798] = true,
    -- Mana-Tombs
    [18341] = true,
    [18343] = true,
    [18344] = true,
    [22930] = true,
    -- Auchenai Crypts
    [18371] = true,
    [18373] = true,
    -- Sethekk Halls
    [18472] = true,
    [23035] = true,
    [18473] = true,
    -- Shadow Labyrinth
    [18731] = true,
    [18667] = true,
    [18732] = true,
    [18708] = true,
    -- Old Hillsbrad Foothills
    [17848] = true,
    [17862] = true,
    [18096] = true,
    -- The Black Morass
    [17879] = true,
    [17880] = true,
    [17881] = true,
    -- The Botanica
    [17976] = true,
    [17975] = true,
    [17978] = true,
    [17980] = true,
    [17977] = true,
    -- The Mechanar
    [19219] = true,
    [19218] = true,
    [19710] = true,
    [19221] = true,
    [19220] = true,
    -- The Arcatraz
    [20870] = true,
    [20886] = true,
    [20885] = true,
    [20912] = true,
    -- Magister's Terrace
    [24723] = true,
    [24744] = true,
    [24560] = true,
    [24664] = true,
  }

  local RaidBossIDs = {
    -- Molten Core
    [12118] = true,
    [11982] = true,
    [12259] = true,
    [12057] = true,
    [12264] = true,
    [12056] = true,
    [11988] = true,
    [12098] = true,
    [12018] = true,
    [11502] = true,
    -- Onyxia
    [10184] = true,
    -- Blackwing Lair
    [12435] = true,
    [13020] = true,
    [12017] = true,
    [11983] = true,
    [14601] = true,
    [11981] = true,
    [14020] = true,
    [11583] = true,
    -- Zul'Gurub
    [14507] = true,
    [14517] = true,
    [14510] = true,
    [14509] = true,
    [14515] = true,
    [14834] = true,
    [11382] = true,
    [14988] = true,
    [15083] = true,
    [15114] = true,
    [11380] = true,
    -- AQ20
    [15348] = true,
    [15341] = true,
    [15340] = true,
    [15370] = true,
    [15369] = true,
    [15339] = true,
    -- AQ40
    [15263] = true,
    [15516] = true,
    [15510] = true,
    [15509] = true,
    [15276] = true,
    [15275] = true,
    [15727] = true,
    [15543] = true,
    [15544] = true,
    [15511] = true,
    [15299] = true,
    [15517] = true,
    -- Naxxramas
    [15956] = true,
    [15953] = true,
    [15952] = true,
    [15954] = true,
    [15936] = true,
    [16011] = true,
    [16061] = true,
    [16060] = true,
    [16064] = true,
    [16065] = true,
    [16062] = true,
    [16063] = true,
    [16028] = true,
    [15931] = true,
    [15932] = true,
    [15928] = true,
    [15989] = true,
    [15990] = true,
    -- TBC Raids
    -- Gruul's Lair
    [18831] = true,
    [19044] = true,
    [18835] = true,
    [18836] = true,
    [18834] = true,
    [18832] = true,
    -- Karazhan 
    [16152] = true, -- Attumen the Huntsman
    [15687] = true, -- Moroes
    [16457] = true, -- Maiden of Virtue
    [17521] = true, -- The Big Bad Wolf (Opera)
    [17533] = true, -- Romulo (Opera)
    [17534] = true, -- Julianne (Opera)
    [17535] = true, -- Dorothee (Opera)
    [17543] = true, -- Strawman (Opera)
    [17546] = true, -- Roar (Opera)
    [17547] = true, -- Tinhead (Opera)
    [18168] = true, -- The Crone (Opera)
    [15691] = true, -- The Curator
    [15688] = true, -- Terestian Illhoof
    [16524] = true, -- Shade of Aran
    [15689] = true, -- Netherspite
    [17225] = true, -- Nightbane
    [15690] = true, -- Prince Malchezaar
    -- Magtheridon's Lair
    [17256] = true, -- Hellfire Channeler
    [17257] = true, -- Magtheridon
    -- Serpentshrine Cavern
    [21216] = true, -- Hydross the Unstable
    [21217] = true, -- The Lurker Below
    [21215] = true, -- Leotheras the Blind
    [21214] = true, -- Fathom-Lord Karathress
    [21213] = true, -- Morogrim Tidewalker
    [21212] = true, -- Lady Vashj
    -- Tempest Keep: The Eye
    [19514] = true, -- Al'ar
    [19516] = true, -- Void Reaver
    [18805] = true, -- High Astromancer Solarian
    [19622] = true, -- Kael'thas Sunstrider
    -- The Battle for Mount Hyjal
    [17767] = true, -- Rage Winterchill
    [17808] = true, -- Anetheron
    [17888] = true, -- Kaz'rogal
    [17842] = true, -- Azgalor
    [17968] = true, -- Archimonde
    -- Black Temple
    [22887] = true, -- High Warlord Naj'entus
    [22898] = true, -- Supremus
    [22841] = true, -- Shade of Akama
    [22871] = true, -- Teron Gorefiend
    [22948] = true, -- Gurtogg Bloodboil
    [23418] = true, -- Essence of Suffering (Reliquary of Souls)
    [23419] = true, -- Essence of Desire (Reliquary of Souls)
    [23420] = true, -- Essence of Anger (Reliquary of Souls)
    [22947] = true, -- Mother Shahraz
    [22949] = true, -- Gathios the Shatterer (Illidari Council)
    [22950] = true, -- High Nethermancer Zerevor (Illidari Council)
    [22951] = true, -- Lady Malande (Illidari Council)
    [22952] = true, -- Veras Darkshadow (Illidari Council)
    [22917] = true, -- Illidan Stormrage
    -- Zul'Aman
    [23574] = true, -- Akil'zon
    [23576] = true, -- Nalorakk
    [23578] = true, -- Jan'alai
    [23577] = true, -- Halazzi
    [24239] = true, -- Hex Lord Malacrass
    [23863] = true, -- Zul'jin
    -- Sunwell Plateau
    [24850] = true, -- Kalecgos
    [24892] = true, -- Sathrovarr the Corruptor
    [24882] = true, -- Brutallus
    [25038] = true, -- Felmyst
    [25166] = true, -- Grand Warlock Alythess (Eredar Twins)
    [25165] = true, -- Lady Sacrolash (Eredar Twins)
    [25741] = true, -- M'uru
    [25840] = true, -- Entropius
    [25315] = true, -- Kil'jaeden
  }

  local isDungeon = dungeonBossIDs[npcID] or false
  local isRaid = RaidBossIDs[npcID] or false
  return isDungeon, isRaid
end

function IsDungeonFinalBoss(unitGUID)
  local inInstance, instanceType = IsInInstance()
  if not inInstance or (instanceType ~= 'party' and instanceType ~= 'raid') then
    return false, false
  end

  local npcID =
    tonumber(unitGUID:match('^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-[%x]+$')) or tonumber(
      unitGUID:match('^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)$')
    )
  if not npcID then
    return false, false
  end

  local dungeonFinalBossIDs = {
    [11519] = true,
    [639] = true,
    [3654] = true,
    [4275] = true,
    [4829] = true,
    [1716] = true,
    [7800] = true,
    [4421] = true,
    [4543] = true,
    [6487] = true,
    [3975] = true,
    [3977] = true,
    [7358] = true,
    [2748] = true,
    [7267] = true,
    [12201] = true,
    [5709] = true,
    [9019] = true,
    [9568] = true,
    [10363] = true,
    [14324] = true,
    [11492] = true,
    [11486] = true,
    [1853] = true,
    [10440] = true,
    [10813] = true,
  }

  local raidFinalBossIDs = {
    [11502] = true,
    [10184] = true,
    [11583] = true,
    [14834] = true,
    [15339] = true,
    [15727] = true,
    [15990] = true,
  }

  return dungeonFinalBossIDs[npcID] or false, raidFinalBossIDs[npcID] or false
end
