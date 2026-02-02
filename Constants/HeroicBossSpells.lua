-- Heroic boss ability spell IDs.
-- Used to show "Boss Abilities" icons + tooltips in the Heroics tab.
--
-- Note: This is intentionally a Lua table (not the .txt reference file) because WoW addons
-- cannot read arbitrary bundled text files at runtime.

_G.UltraStatisticsHeroicBossSpells = {
  -- ======================
  -- HELLFIRE CITADEL
  -- ======================
  hellfireRamparts = {
    ['Watchkeeper Gargolmar'] = { 34645, 30641, 22857 }, -- Surge, Mortal Wound, Retaliation
    ['Omor the Unscarred'] = { 30686, 30695, 30707, 30691 }, -- Shadow Bolt, Treacherous Aura, Summon Fiendish Hound, Bane of Treachery
    ['Vazruden the Herald'] = { 30691, 30926, 39427 }, -- Fireball, Cone of Fire, Bellowing Roar
    -- Some sources label this encounter as "Vazruden the Herald / Nazan"
    ['Vazruden the Herald / Nazan'] = { 30691, 30926, 39427 },
  },
  bloodFurnace = {
    ['The Maker'] = { 30925, 30923 }, -- Exploding Beaker, Domination
    ['Broggok'] = { 30913, 30916 }, -- Slime Spray, Poison Cloud
    ["Keli'dan the Breaker"] = { 30510, 30940, 30938 }, -- Shadow Bolt Volley, Burning Nova, Corruption
  },
  shatteredHalls = {
    ['Grand Warlock Nethekurse'] = { 30495, 30500, 30502 }, -- Shadow Cleave, Death Coil, Dark Spin
    ['Blood Guard Porung'] = { 15496, 30584 }, -- Cleave, Fear
    ["Warbringer O'mrogg"] = { 30600, 30633, 30618 }, -- Blast Wave, Thunderclap, Beatdown
    ['Warchief Kargath Bladefist'] = { 30739, 25821 }, -- Blade Dance, Charge
  },

  -- ======================
  -- COILFANG RESERVOIR
  -- ======================
  slavePens = {
    ['Mennu the Betrayer'] = { 35010, 31985 }, -- Lightning Bolt, Tainted Stoneskin Totem
    ['Rokmar the Crackler'] = { 31956, 31948 }, -- Grievous Wound, Ensnaring Moss
    ['Quagmirran'] = { 38153, 40504 }, -- Acid Spray, Cleave
  },
  underbog = {
    ['Hungarfen'] = { 31673, 38739 }, -- Foul Spores, Acid Geyser
    ["Ghaz'an"] = { 34268, 34267 }, -- Acid Breath, Tail Sweep
    ["Swamplord Musel'ek"] = { 31623, 34974, 31946 }, -- Aimed Shot, Multi-Shot, Freezing Trap
    ['The Black Stalker'] = { 31704, 31717, 31715 }, -- Levitate, Chain Lightning, Static Charge
  },
  steamvault = {
    ['Hydromancer Thespia'] = { 25033, 15531 }, -- Lightning Cloud, Frost Nova
    ['Mekgineer Steamrigger'] = { 31485, 31486 }, -- Super Shrink Ray, Saw Blade
    ['Warlord Kalithresh'] = { 31534, 39061 }, -- Spell Reflection, Impale
  },

  -- ======================
  -- AUCHINDOUN
  -- ======================
  manaTombs = {
    ['Pandemonius'] = { 32325, 32358 }, -- Void Blast, Dark Shell
    ['Tavarok'] = { 33919, 32361 }, -- Earthquake, Crystal Prison
    ['Nexus-Prince Shaffar'] = { 32365, 32371 }, -- Frost Nova, Summon Ethereal Apprentice
  },
  auchenaiCrypts = {
    ['Shirrak the Dead Watcher'] = { 36383, 32264 }, -- Carnivorous Bite, Inhibit Magic
    ['Exarch Maladaar'] = { 32421, 32424 }, -- Soul Scream, Summon Avatar
  },
  sethekkHalls = {
    ['Darkweaver Syth'] = { 15659, 38197 }, -- Chain Lightning, Arcane Shock
    ['Talon King Ikiss'] = { 38197, 1953, 12826 }, -- Arcane Explosion, Blink, Polymorph
  },
  shadowLabyrinth = {
    ['Ambassador Hellmaw'] = { 33547, 33551 }, -- Fear, Corrosive Acid
    ['Blackheart the Inciter'] = { 33676, 24193 }, -- Incite Chaos, Charge
    ['Grandmaster Vorpil'] = { 33841, 33582 }, -- Shadow Bolt Volley, Summon Void Traveler
    ['Murmur'] = { 33923, 33711 }, -- Sonic Boom, Murmur's Touch
  },

  -- ======================
  -- TEMPEST KEEP (5-mans)
  -- ======================
  mechanar = {
    ['Mechano-Lord Capacitus'] = { 39096, 37670 }, -- Polarity Shift, Nether Charge
    ['Nethermancer Sepethrea'] = { 35263, 35275 }, -- Frost Nova, Summon Raging Flames
    ['Pathaleon the Calculator'] = { 35280, 35283 }, -- Domination, Arcane Torrent
  },
  botanica = {
    ['Commander Sarannis'] = { 34794, 34775 }, -- Arcane Resonance, Heal
    ['High Botanist Freywinn'] = { 34550, 34759 }, -- Tranquility, Plant White Seedling
    ['Thorngrin the Tender'] = { 34659, 34661 }, -- Hellfire, Sacrifice
    ['Laj'] = { 34697, 34684 }, -- Allergic Reaction, Summon Lashers
    ['Warp Splinter'] = { 34716, 34722 }, -- War Stomp, Arcane Volley
  },
  arcatraz = {
    ['Zereketh the Unbound'] = { 36123, 36127 }, -- Seed of Corruption, Shadow Nova
    ['Dalliah the Doomsayer'] = { 36142, 36144 }, -- Whirlwind, Heal
    ['Wrath-Scryer Soccothrates'] = { 36512, 36517 }, -- Charge, Knock Away
    ['Harbinger Skyriss'] = { 36924, 37162, 39415 }, -- Mind Rend, Domination, Fear
  },
}


