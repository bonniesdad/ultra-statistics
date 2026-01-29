-- Dungeons Tab Content
-- Shows a list of non-heroic (normal) dungeons, each under a collapsible section.
-- Uses the same UI as HeroicsTab, but reads/writes the 'dungeons' category in DungeonRaidStats.
function UltraStatistics_InitializeDungeonsTab(tabContents)
  if not tabContents or not tabContents[2] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[2].initialized then return end

  -- Mark as initialized
  tabContents[2].initialized = true

  local parent = tabContents[2]

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
  if type(GLOBAL_SETTINGS.collapsedDungeonsSections) ~= 'table' then
    GLOBAL_SETTINGS.collapsedDungeonsSections = {}
  end

  -- Outer frame (matches style used in Heroics tab)
  local dungeonsFrame = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  dungeonsFrame:SetPoint('TOP', parent, 'TOP', 0, -55)
  dungeonsFrame:SetPoint('LEFT', parent, 'LEFT', 10, 0)
  dungeonsFrame:SetPoint('RIGHT', parent, 'RIGHT', -10, 0)
  dungeonsFrame:SetHeight(535)
  dungeonsFrame:SetBackdrop({
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
  dungeonsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
  dungeonsFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

  -- Scroll frame (many dungeons)
  local scrollFrame = CreateFrame('ScrollFrame', nil, dungeonsFrame, 'UIPanelScrollFrameTemplate')
  scrollFrame:SetPoint('TOPLEFT', dungeonsFrame, 'TOPLEFT', 10, -10)
  scrollFrame:SetPoint('BOTTOMRIGHT', dungeonsFrame, 'BOTTOMRIGHT', -30, 10)

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

  local tbcHeader = CreateFrame('Frame', nil, scrollChild)
  tbcHeader:SetSize(435, SECTION_TITLE_HEIGHT)
  local tbcTitle = tbcHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  tbcTitle:SetPoint('LEFT', tbcHeader, 'LEFT', 4, 0)
  tbcTitle:SetText('The Burning Crusade')
  tbcTitle:SetTextColor(1, 0.82, 0, 1)

  local tbcDivider = scrollChild:CreateTexture(nil, 'BACKGROUND')
  tbcDivider:SetColorTexture(1, 1, 1, 0.15)
  tbcDivider:SetHeight(1)

  local tbcContainer = CreateFrame('Frame', nil, scrollChild)
  tbcContainer:SetSize(435, 1)

  local function ReflowSections()
    local state = _G.UltraStatisticsDungeonsTabState
    local classic = (state and state.classicContainer) or classicContainer
    local tbc = (state and state.tbcContainer) or tbcContainer
    local root = (state and state.currentScrollChild) or scrollChild

    if not (classic and tbc and tbcHeader and tbcDivider and root) then
      return
    end

    tbcHeader:ClearAllPoints()
    tbcHeader:SetPoint('TOPLEFT', classic, 'BOTTOMLEFT', 0, -BETWEEN_SECTIONS_GAP)
    tbcHeader:SetPoint('TOPRIGHT', classic, 'BOTTOMRIGHT', 0, -BETWEEN_SECTIONS_GAP)

    tbcDivider:ClearAllPoints()
    tbcDivider:SetPoint('TOPLEFT', tbcHeader, 'BOTTOMLEFT', 0, -DIVIDER_GAP)
    tbcDivider:SetPoint('TOPRIGHT', tbcHeader, 'BOTTOMRIGHT', 0, -DIVIDER_GAP)

    tbc:ClearAllPoints()
    tbc:SetPoint('TOPLEFT', tbcDivider, 'BOTTOMLEFT', 0, -AFTER_DIVIDER_GAP)
    tbc:SetPoint('TOPRIGHT', tbcDivider, 'BOTTOMRIGHT', 0, -AFTER_DIVIDER_GAP)

    local totalHeight =
      2 +
      (classicHeader:GetHeight() or SECTION_TITLE_HEIGHT) +
      DIVIDER_GAP + 1 + AFTER_DIVIDER_GAP +
      (classic:GetHeight() or 0) +
      BETWEEN_SECTIONS_GAP +
      (tbcHeader:GetHeight() or SECTION_TITLE_HEIGHT) +
      DIVIDER_GAP + 1 + AFTER_DIVIDER_GAP +
      (tbc:GetHeight() or 0) +
      BOTTOM_PADDING

    root:SetHeight(math.max(1, totalHeight))
  end

  -- Rebuild the dungeons list when stats change (called by UpdateStatistics()).
  _G.UltraStatisticsDungeonsTabState = {
    parent = parent,
    dungeonsFrame = dungeonsFrame,
    scrollFrame = scrollFrame,
    currentScrollChild = scrollChild,
    layout = layout,
    collapsedStateTable = GLOBAL_SETTINGS.collapsedDungeonsSections,
    width = 435,
    texturesRoot = 'heroics', -- reuse existing dungeon textures
    bgHeight = 200,
    bgInsetX = 2,
    bgInsetY = -2,
    defaultCollapsed = true,
    dirty = true,
    refreshPending = false,
    lastRefreshAt = 0,
    refreshThrottleSeconds = 0.25,
    classicContainer = classicContainer,
    tbcContainer = tbcContainer,
    reflow = ReflowSections,
  }

  function _G.UltraStatistics_RefreshDungeonsTab(force)
    local state = _G.UltraStatisticsDungeonsTabState
    if not state or not state.scrollFrame then
      return
    end

    state.dirty = true

    -- If the tab isn't effectively visible, just mark dirty and refresh on next open.
    if not (state.parent and state.parent.IsVisible and state.parent:IsVisible()) then
      return
    end

    -- Coalesce multiple refresh triggers into a single rebuild.
    if state.refreshPending then
      return
    end
    local now = (GetTime and GetTime()) or 0
    local throttle = tonumber(state.refreshThrottleSeconds) or 0
    local sinceLast = now - (state.lastRefreshAt or 0)
    if not force and throttle > 0 and sinceLast < throttle then
      state.refreshPending = true
      local delay = throttle - sinceLast
      if C_Timer and C_Timer.After then
        C_Timer.After(delay, function()
          state.refreshPending = false
          _G.UltraStatistics_RefreshDungeonsTab(true)
        end)
      else
        state.refreshPending = false
        _G.UltraStatistics_RefreshDungeonsTab(true)
      end
      return
    end

    state.refreshPending = true

    local function doRebuild()
      state.refreshPending = false
      state.lastRefreshAt = (GetTime and GetTime()) or 0

      local instances =
        (DungeonRaidStats and DungeonRaidStats.MergeWithStored) and DungeonRaidStats.MergeWithStored(
          'dungeons',
          state.defaultClassicDungeons or {}
        ) or (state.defaultClassicDungeons or {})

      local tbcInstances =
        (DungeonRaidStats and DungeonRaidStats.MergeWithStored) and DungeonRaidStats.MergeWithStored(
          'dungeons',
          state.defaultTBCDungeons or {}
        ) or (state.defaultTBCDungeons or {})

      -- Replace the section containers so we don't have to manually destroy old frames.
      if state.classicContainer and state.classicContainer.Hide then
        state.classicContainer:Hide()
      end
      if state.tbcContainer and state.tbcContainer.Hide then
        state.tbcContainer:Hide()
      end

      local root = state.currentScrollChild
      local newClassic = CreateFrame('Frame', nil, root)
      newClassic:SetSize(state.width, 1)
      newClassic:SetPoint('TOPLEFT', classicDivider, 'BOTTOMLEFT', 0, -AFTER_DIVIDER_GAP)
      newClassic:SetPoint('TOPRIGHT', classicDivider, 'BOTTOMRIGHT', 0, -AFTER_DIVIDER_GAP)
      state.classicContainer = newClassic

      local newTBC = CreateFrame('Frame', nil, root)
      newTBC:SetSize(state.width, 1)
      state.tbcContainer = newTBC

      UltraStatistics_CreateInstanceAccordionList({
        scrollChild = newClassic,
        layout = state.layout,
        instances = instances,
        collapsedStateTable = state.collapsedStateTable,
        width = state.width,
        texturesRoot = state.texturesRoot,
        bgHeight = state.bgHeight,
        bgInsetX = state.bgInsetX,
        bgInsetY = state.bgInsetY,
        defaultCollapsed = state.defaultCollapsed,
        onLayoutUpdated = function()
          if state.reflow then
            state.reflow()
          end
        end,
      })

      UltraStatistics_CreateInstanceAccordionList({
        scrollChild = newTBC,
        layout = state.layout,
        instances = tbcInstances,
        collapsedStateTable = state.collapsedStateTable,
        width = state.width,
        texturesRoot = state.texturesRoot,
        bgHeight = state.bgHeight,
        bgInsetX = state.bgInsetX,
        bgInsetY = state.bgInsetY,
        defaultCollapsed = state.defaultCollapsed,
        onLayoutUpdated = function()
          if state.reflow then
            state.reflow()
          end
        end,
      })

      if state.reflow then
        state.reflow()
      end

      state.dirty = false
    end

    if C_Timer and C_Timer.After then
      C_Timer.After(0, doRebuild)
    else
      doRebuild()
    end
  end

  -- Classic dungeons (stored under 'dungeons'). Boss lists omitted for now; we still track clears/deaths by instance.
  local defaultClassicDungeons = { {
    key = 'ragefireChasm',
    title = 'Ragefire Chasm',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'deadmines',
    title = 'The Deadmines',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'wailingCaverns',
    title = 'Wailing Caverns',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'shadowfangKeep',
    title = 'Shadowfang Keep',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'blackfathomDeeps',
    title = 'Blackfathom Deeps',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'stockades',
    title = 'The Stockade',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'gnomeregan',
    title = 'Gnomeregan',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'razorfenKraul',
    title = 'Razorfen Kraul',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'scarletMonastery',
    title = 'Scarlet Monastery',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'razorfenDowns',
    title = 'Razorfen Downs',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'uldaman',
    title = 'Uldaman',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'zulFarrak',
    title = "Zul'Farrak",
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'maraudon',
    title = 'Maraudon',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'sunkenTemple',
    title = "The Temple of Atal'Hakkar",
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'blackrockDepths',
    title = 'Blackrock Depths',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'blackrockSpire',
    title = 'Blackrock Spire',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'stratholme',
    title = 'Stratholme',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'direMaul',
    title = 'Dire Maul',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  }, {
    key = 'scholomance',
    title = 'Scholomance',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = {},
  } }

  -- TBC 5-man dungeons (normal-mode stats; stored under 'dungeons').
  local defaultTBCDungeons = { {
    key = 'hellfireRamparts',
    title = 'Hellfire Ramparts',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Watchkeeper Gargolmar',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Omor the Unscarred',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Vazruden the Herald',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'bloodFurnace',
    title = 'The Blood Furnace',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'The Maker',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Broggok',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = "Keli'dan the Breaker",
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'shatteredHalls',
    title = 'The Shattered Halls',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Grand Warlock Nethekurse',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = "Warbringer O'mrogg",
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Warchief Kargath Bladefist',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'slavePens',
    title = 'The Slave Pens',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Mennu the Betrayer',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Rokmar the Crackler',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Quagmirran',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'underbog',
    title = 'The Underbog',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Hungarfen',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = "Ghaz'an",
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = "Swamplord Musel'ek",
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'The Black Stalker',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'steamvault',
    title = 'The Steamvault',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Hydromancer Thespia',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Mekgineer Steamrigger',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Warlord Kalithresh',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'manaTombs',
    title = 'Mana-Tombs',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Pandemonius',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Tavarok',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Nexus-Prince Shaffar',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    }, {
      name = 'Yor',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    } },
  }, {
    key = 'auchenaiCrypts',
    title = 'Auchenai Crypts',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Shirrak the Dead Watcher',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Exarch Maladaar',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'sethekkHalls',
    title = 'Sethekk Halls',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Darkweaver Syth',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Talon King Ikiss',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    }, {
      name = 'Anzu',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    } },
  }, {
    key = 'shadowLabyrinth',
    title = 'Shadow Labyrinth',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Ambassador Hellmaw',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Blackheart the Inciter',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Grandmaster Vorpil',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Murmur',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'oldHillsbradFoothills',
    title = 'Old Hillsbrad Foothills',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Lieutenant Drake',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Captain Skarloc',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Epoch Hunter',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'blackMorass',
    title = 'The Black Morass',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Chrono Lord Deja',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Temporus',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Aeonus',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'botanica',
    title = 'The Botanica',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Commander Sarannis',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'High Botanist Freywinn',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Thorngrin the Tender',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Laj',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Warp Splinter',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'mechanar',
    title = 'The Mechanar',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Mechano-Lord Capacitus',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Nethermancer Sepethrea',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Pathaleon the Calculator',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'arcatraz',
    title = 'The Arcatraz',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Zereketh the Unbound',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Dalliah the Doomsayer',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Wrath-Scryer Soccothrates',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Harbinger Skyriss',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
    key = 'magistersTerrace',
    title = "Magister's Terrace",
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Selin Fireheart',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Vexallus',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Priestess Delrissa',
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
  } }

  local classicInstances =
    (DungeonRaidStats and DungeonRaidStats.MergeWithStored) and DungeonRaidStats.MergeWithStored(
      'dungeons',
      defaultClassicDungeons
    ) or defaultClassicDungeons

  local tbcInstances =
    (DungeonRaidStats and DungeonRaidStats.MergeWithStored) and DungeonRaidStats.MergeWithStored(
      'dungeons',
      defaultTBCDungeons
    ) or defaultTBCDungeons

  -- Keep defaults in state for refreshes.
  if _G.UltraStatisticsDungeonsTabState then
    _G.UltraStatisticsDungeonsTabState.defaultClassicDungeons = defaultClassicDungeons
    _G.UltraStatisticsDungeonsTabState.defaultTBCDungeons = defaultTBCDungeons
  end

  UltraStatistics_CreateInstanceAccordionList({
    scrollChild = classicContainer,
    layout = layout,
    instances = classicInstances,
    collapsedStateTable = GLOBAL_SETTINGS.collapsedDungeonsSections,
    width = 435,
    texturesRoot = 'heroics',
    bgHeight = 200,
    bgInsetX = 2,
    bgInsetY = -2,
    defaultCollapsed = true,
    onLayoutUpdated = function()
      ReflowSections()
    end,
  })

  UltraStatistics_CreateInstanceAccordionList({
    scrollChild = tbcContainer,
    layout = layout,
    instances = tbcInstances,
    collapsedStateTable = GLOBAL_SETTINGS.collapsedDungeonsSections,
    width = 435,
    texturesRoot = 'heroics',
    bgHeight = 200,
    bgInsetX = 2,
    bgInsetY = -2,
    defaultCollapsed = true,
    onLayoutUpdated = function()
      ReflowSections()
    end,
  })

  -- Initial placement (after both lists have computed their heights).
  ReflowSections()

  -- Mark clean after initial render (refresh will mark dirty on future stat updates).
  if _G.UltraStatisticsDungeonsTabState then
    _G.UltraStatisticsDungeonsTabState.dirty = false
  end
end


