function UltraStatistics_InitializeRaidsTab(tabContents)
  if not tabContents or not tabContents[4] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[4].initialized then return end

  -- Mark as initialized
  tabContents[4].initialized = true

  local parent = tabContents[4]

  -- Fallback layout (LAYOUT is defined globally in Settings/Settings.lua)
  local layout = _G.LAYOUT or {
    SECTION_HEADER_HEIGHT = 28,
    SECTION_SPACING = 10,
    CONTENT_INDENT = 20,
    CONTENT_PADDING = 8,
  }

  if type(GLOBAL_SETTINGS) ~= 'table' then
    GLOBAL_SETTINGS = {}
  end
  if type(GLOBAL_SETTINGS.collapsedRaidsSections) ~= 'table' then
    GLOBAL_SETTINGS.collapsedRaidsSections = {}
  end

  -- Outer frame (matches style used in Heroics tab)
  local raidsFrame = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  raidsFrame:SetPoint('TOP', parent, 'TOP', 0, -55)
  raidsFrame:SetPoint('LEFT', parent, 'LEFT', 10, 0)
  raidsFrame:SetPoint('RIGHT', parent, 'RIGHT', -10, 0)
  raidsFrame:SetHeight(535)
  raidsFrame:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 64,
    edgeSize = 16,
    insets = {
      left = 5,
      right = 5,
      top = 5,
      bottom = 5,
    },
  })
  raidsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
  raidsFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

  -- Scroll frame (many raids)
  local scrollFrame = CreateFrame('ScrollFrame', nil, raidsFrame, 'UIPanelScrollFrameTemplate')
  scrollFrame:SetPoint('TOPLEFT', raidsFrame, 'TOPLEFT', 10, -10)
  scrollFrame:SetPoint('BOTTOMRIGHT', raidsFrame, 'BOTTOMRIGHT', -30, 10)

  local scrollChild = CreateFrame('Frame', nil, scrollFrame)
  scrollChild:SetSize(435, 300)
  scrollFrame:SetScrollChild(scrollChild)

  -- Section headers + containers (Classic / The Burning Crusade)
  local SECTION_TITLE_HEIGHT = 22
  local DIVIDER_GAP = 6
  local AFTER_DIVIDER_GAP = 10
  local BETWEEN_SECTIONS_GAP = 18
  local BOTTOM_PADDING = 20

  local classicHeader = CreateFrame('Frame', nil, scrollChild)
  classicHeader:SetSize(435, SECTION_TITLE_HEIGHT)
  classicHeader:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 0, -2)
  classicHeader:SetPoint('TOPRIGHT', scrollChild, 'TOPRIGHT', 0, -2)
  local classicTitle = classicHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  classicTitle:SetPoint('LEFT', classicHeader, 'LEFT', 4, 0)
  classicTitle:SetText('Classic')
  classicTitle:SetTextColor(1, 0.82, 0, 1)

  local classicDivider = scrollChild:CreateTexture(nil, 'BACKGROUND')
  classicDivider:SetColorTexture(1, 1, 1, 0.15)
  classicDivider:SetHeight(1)
  classicDivider:SetPoint('TOPLEFT', classicHeader, 'BOTTOMLEFT', 0, -DIVIDER_GAP)
  classicDivider:SetPoint('TOPRIGHT', classicHeader, 'BOTTOMRIGHT', 0, -DIVIDER_GAP)

  local classicContainer = CreateFrame('Frame', nil, scrollChild)
  classicContainer:SetPoint('TOPLEFT', classicDivider, 'BOTTOMLEFT', 0, -AFTER_DIVIDER_GAP)
  classicContainer:SetPoint('TOPRIGHT', classicDivider, 'BOTTOMRIGHT', 0, -AFTER_DIVIDER_GAP)
  classicContainer:SetSize(435, 1)

  local isTBC = IsTBC and IsTBC()

  local tbcHeader = CreateFrame('Frame', nil, scrollChild)
  tbcHeader:SetSize(435, SECTION_TITLE_HEIGHT)
  if not isTBC then
    tbcHeader:Hide()
  end
  local tbcTitle = tbcHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  tbcTitle:SetPoint('LEFT', tbcHeader, 'LEFT', 4, 0)
  tbcTitle:SetText('The Burning Crusade')
  tbcTitle:SetTextColor(1, 0.82, 0, 1)

  local tbcDivider = scrollChild:CreateTexture(nil, 'BACKGROUND')
  tbcDivider:SetColorTexture(1, 1, 1, 0.15)
  tbcDivider:SetHeight(1)

  local tbcContainer = CreateFrame('Frame', nil, scrollChild)
  tbcContainer:SetSize(435, 1)
  if not isTBC then
    tbcContainer:Hide()
    tbcDivider:Hide()
  end

  local function ReflowSections()
    if not classicContainer then
      return
    end

    local totalHeight =
      2 + -- top padding
      (classicHeader:GetHeight() or SECTION_TITLE_HEIGHT) +
      DIVIDER_GAP + 1 + AFTER_DIVIDER_GAP +
      (classicContainer:GetHeight() or 0) +
      BOTTOM_PADDING

    if isTBC and tbcHeader and tbcDivider and tbcContainer then
      tbcHeader:ClearAllPoints()
      tbcHeader:SetPoint('TOPLEFT', classicContainer, 'BOTTOMLEFT', 0, -BETWEEN_SECTIONS_GAP)
      tbcHeader:SetPoint('TOPRIGHT', classicContainer, 'BOTTOMRIGHT', 0, -BETWEEN_SECTIONS_GAP)

      tbcDivider:ClearAllPoints()
      tbcDivider:SetPoint('TOPLEFT', tbcHeader, 'BOTTOMLEFT', 0, -DIVIDER_GAP)
      tbcDivider:SetPoint('TOPRIGHT', tbcHeader, 'BOTTOMRIGHT', 0, -DIVIDER_GAP)

      tbcContainer:ClearAllPoints()
      tbcContainer:SetPoint('TOPLEFT', tbcDivider, 'BOTTOMLEFT', 0, -AFTER_DIVIDER_GAP)
      tbcContainer:SetPoint('TOPRIGHT', tbcDivider, 'BOTTOMRIGHT', 0, -AFTER_DIVIDER_GAP)

      totalHeight = totalHeight +
        BETWEEN_SECTIONS_GAP +
        (tbcHeader:GetHeight() or SECTION_TITLE_HEIGHT) +
        DIVIDER_GAP + 1 + AFTER_DIVIDER_GAP +
        (tbcContainer:GetHeight() or 0)
    end

    scrollChild:SetHeight(math.max(1, totalHeight))
  end

  -- Classic raids
  local defaultClassicRaids = { {
    key = 'moltenCore',
    title = 'Molten Core',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {
      { name = 'Lucifron', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Magmadar', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Gehennas', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Garr', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Baron Geddon', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Shazzrah', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Sulfuron Harbinger', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Golemagg the Incinerator', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Majordomo Executus', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Ragnaros', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true },
    },
  }, {
    key = 'onyxia',
    title = 'Onyxia',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {
      { name = 'Onyxia', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true },
    },
  }, {
    key = 'blackwingLair',
    title = 'Blackwing Lair',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {
      { name = 'Razorgore the Untamed', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Vaelastrasz the Corrupt', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Broodlord Lashlayer', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Firemaw', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Ebonroc', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Flamegor', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Chromaggus', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Nefarian', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true },
    },
  }, {
    key = 'zulGurub',
    title = "Zul'Gurub",
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {
      { name = 'High Priestess Jeklik', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'High Priest Venoxis', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = "High Priestess Mar'li", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'High Priest Thekal', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'High Priestess Arlokk', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = "Jin'do the Hexxer", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Hakkar', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true },
    },
  }, {
    key = 'aq20',
    title = "Ruins of Ahn'Qiraj",
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {
      { name = 'Kurinnaxx', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'General Rajaxx', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Moam', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Buru the Gorger', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Ayamiss the Hunter', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Ossirian the Unscarred', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true },
    },
  }, {
    key = 'aq40',
    title = "Temple of Ahn'Qiraj",
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {
      { name = 'The Prophet Skeram', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Battleguard Sartura', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Fankriss the Unyielding', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Princess Huhuran', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Twin Emperors', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Ouro', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = "C'Thun", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true },
    },
  }, {
    key = 'naxxramas',
    title = 'Naxxramas',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {
      { name = "Anub'Rekhan", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Grand Widow Faerlina', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Maexxna', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Noth the Plaguebringer', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Heigan the Unclean', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Loatheb', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Instructor Razuvious', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Gothik the Harvester', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'The Four Horsemen', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Patchwerk', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Grobbulus', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Gluth', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Thaddius', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = 'Sapphiron', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 },
      { name = "Kel'Thuzad", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true },
    },
  } }

  -- TBC raids
  local defaultTBCRaids = { {
    key = 'gruulsLair',
    title = "Gruul's Lair",
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'High King Maulgar',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Gruul the Dragonkiller',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'karazhan',
    title = 'Karazhan',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Attumen the Huntsman',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Moroes',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Maiden of Virtue',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Opera Event',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'The Curator',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Terestian Illhoof',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Shade of Aran',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Netherspite',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Nightbane',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Prince Malchezaar',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'magtheridonsLair',
    title = "Magtheridon's Lair",
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Magtheridon',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'serpentshrineCavern',
    title = 'Serpentshrine Cavern',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Hydross the Unstable',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'The Lurker Below',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Leotheras the Blind',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Fathom-Lord Karathress',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Morogrim Tidewalker',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Lady Vashj',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'tempestKeep',
    title = 'Tempest Keep: The Eye',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = "Al'ar",
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Void Reaver',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'High Astromancer Solarian',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = "Kael'thas Sunstrider",
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'hyjal',
    title = 'The Battle for Mount Hyjal',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Rage Winterchill',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Anetheron',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = "Kaz'rogal",
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Azgalor',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Archimonde',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'blackTemple',
    title = 'Black Temple',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = "High Warlord Naj'entus",
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Supremus',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Shade of Akama',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Teron Gorefiend',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Gurtogg Bloodboil',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Reliquary of Souls',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Mother Shahraz',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Illidari Council',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Illidan Stormrage',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'zulAman',
    title = "Zul'Aman",
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = "Akil'zon",
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Nalorakk',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = "Jan'alai",
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Halazzi',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Hex Lord Malacrass',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = "Zul'jin",
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'sunwellPlateau',
    title = 'Sunwell Plateau',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Kalecgos',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Brutallus',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Felmyst',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Eredar Twins',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = "M'uru",
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = "Kil'jaeden",
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  } }

  local classicInstances =
    (DungeonRaidStats and DungeonRaidStats.MergeWithStored) and DungeonRaidStats.MergeWithStored(
      'raids',
      defaultClassicRaids
    ) or defaultClassicRaids

  local tbcInstances =
    (DungeonRaidStats and DungeonRaidStats.MergeWithStored) and DungeonRaidStats.MergeWithStored(
      'raids',
      defaultTBCRaids
    ) or defaultTBCRaids

  UltraStatistics_CreateInstanceAccordionList({
    scrollChild = classicContainer,
    layout = layout,
    instances = classicInstances,
    showDeaths = isTBC,
    collapsedStateTable = GLOBAL_SETTINGS.collapsedRaidsSections,
    width = 435,
    texturesRoot = 'raids',
    bgHeight = 200,
    bgInsetX = 2,
    bgInsetY = -2,
    defaultCollapsed = true,
    onLayoutUpdated = function()
      ReflowSections()
    end,
  })

  if isTBC then
  UltraStatistics_CreateInstanceAccordionList({
    scrollChild = tbcContainer,
    layout = layout,
    instances = tbcInstances,
    showDeaths = true,
    collapsedStateTable = GLOBAL_SETTINGS.collapsedRaidsSections,
    width = 435,
    texturesRoot = 'raids',
    bgHeight = 200,
    bgInsetX = 2,
    bgInsetY = -2,
    defaultCollapsed = true,
    onLayoutUpdated = function()
      ReflowSections()
    end,
  })
  end

  -- Initial placement (after both lists have computed their heights).
  ReflowSections()
end
