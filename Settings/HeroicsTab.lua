-- Heroics Tab Content
-- Shows a list of heroic dungeons, each under a collapsible section.
function UltraStatistics_InitializeHeroicsTab(tabContents)
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
  if type(GLOBAL_SETTINGS.collapsedHeroicsSections) ~= 'table' then
    GLOBAL_SETTINGS.collapsedHeroicsSections = {}
  end

  -- Outer frame (matches style used in Statistics tab)
  local heroicsFrame = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  heroicsFrame:SetPoint('TOP', parent, 'TOP', 0, -55)
  heroicsFrame:SetPoint('LEFT', parent, 'LEFT', 10, 0)
  heroicsFrame:SetPoint('RIGHT', parent, 'RIGHT', -10, 0)
  heroicsFrame:SetHeight(535)
  heroicsFrame:SetBackdrop({
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
  heroicsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
  heroicsFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

  -- Scroll frame for future expansion (more heroics)
  local scrollFrame = CreateFrame('ScrollFrame', nil, heroicsFrame, 'UIPanelScrollFrameTemplate')
  scrollFrame:SetPoint('TOPLEFT', heroicsFrame, 'TOPLEFT', 10, -10)
  scrollFrame:SetPoint('BOTTOMRIGHT', heroicsFrame, 'BOTTOMRIGHT', -30, 10)

  local scrollChild = CreateFrame('Frame', nil, scrollFrame)
  scrollChild:SetSize(435, 300)
  scrollFrame:SetScrollChild(scrollChild)

  -- Rebuild the heroics list when stats change (called by UpdateStatistics()).
  -- This avoids needing /reload to see updated boss kills/deaths.
  _G.UltraStatisticsHeroicsTabState = {
    parent = parent,
    heroicsFrame = heroicsFrame,
    scrollFrame = scrollFrame,
    currentScrollChild = scrollChild,
    layout = layout,
    collapsedStateTable = GLOBAL_SETTINGS.collapsedHeroicsSections,
    width = 435,
    texturesRoot = 'heroics',
    bgHeight = 200,
    bgInsetX = 2,
    bgInsetY = -2,
    defaultCollapsed = true,
    dirty = true,
    refreshPending = false,
    lastRefreshAt = 0,
    refreshThrottleSeconds = 0.25,
  }

  function _G.UltraStatistics_RefreshHeroicsTab(force)
    local state = _G.UltraStatisticsHeroicsTabState
    if not state or not state.scrollFrame then
      return
    end

    if force then
      state.dirty = true
    else
      -- Any call without force is treated as "stats changed; please refresh when possible".
      state.dirty = true
    end

    -- If the tab isn't effectively visible, just mark dirty and refresh on next open.
    -- (IsShown() can remain true even when a parent frame is hidden.)
    if not (state.parent and state.parent.IsVisible and state.parent:IsVisible()) then
      state.dirty = true
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
          _G.UltraStatistics_RefreshHeroicsTab(true)
        end)
      else
        state.refreshPending = false
        _G.UltraStatistics_RefreshHeroicsTab(true)
      end
      return
    end

    state.refreshPending = true

    local function doRebuild()
      state.refreshPending = false
      state.lastRefreshAt = (GetTime and GetTime()) or 0

      local instances =
        (DungeonRaidStats and DungeonRaidStats.MergeWithStored) and DungeonRaidStats.MergeWithStored(
          'heroics',
          state.defaultHeroics or {}
        ) or (state.defaultHeroics or {})

      -- Replace the scroll child so we don't have to manually destroy old frames.
      -- Important: hide the old scroll child to prevent duplicate rows.
      if state.currentScrollChild and state.currentScrollChild.Hide then
        state.currentScrollChild:Hide()
      end

      local newChild = CreateFrame('Frame', nil, state.scrollFrame)
      newChild:SetSize(state.width, 300)
      state.scrollFrame:SetScrollChild(newChild)
      state.currentScrollChild = newChild

      UltraStatistics_CreateInstanceAccordionList({
        scrollChild = newChild,
        layout = state.layout,
        instances = instances,
        collapsedStateTable = state.collapsedStateTable,
        width = state.width,
        texturesRoot = state.texturesRoot,
        bgHeight = state.bgHeight,
        bgInsetX = state.bgInsetX,
        bgInsetY = state.bgInsetY,
        defaultCollapsed = state.defaultCollapsed,
      })

      state.dirty = false
    end

    if C_Timer and C_Timer.After then
      C_Timer.After(0, doRebuild)
    else
      doRebuild()
    end
  end

  -- TBC 5-man instances (boss list from IsDungeonBoss; stats merged from stored DungeonRaidStats)
  -- NOTE: The Stockade is included for testing (it is NOT a TBC heroic).
  local defaultHeroics = { {
    key = 'stockades',
    title = 'The Stockade',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { {
      name = 'Targorr the Dread',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Kam Deepfury',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Hamhock',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Dextren Ward',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Bazil Thredd',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
    }, {
      name = 'Bruegal Ironknuckle',
      totalKills = 0,
      totalDeaths = 0,
      firstClearDeaths = 0,
      isFinal = true,
    } },
  }, {
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

  local heroicsInstances =
    (DungeonRaidStats and DungeonRaidStats.MergeWithStored) and DungeonRaidStats.MergeWithStored(
      'heroics',
      defaultHeroics
    ) or defaultHeroics

  -- Keep defaults in state for refreshes.
  if _G.UltraStatisticsHeroicsTabState then
    _G.UltraStatisticsHeroicsTabState.defaultHeroics = defaultHeroics
  end

  -- Render using shared helper so RaidsTab can reuse the exact same UI.
  UltraStatistics_CreateInstanceAccordionList({
    scrollChild = scrollChild,
    layout = layout,
    instances = heroicsInstances,
    collapsedStateTable = GLOBAL_SETTINGS.collapsedHeroicsSections,
    width = 435,
    texturesRoot = 'heroics',
    bgHeight = 200,
    bgInsetX = 2,
    bgInsetY = -2,
    defaultCollapsed = true,
  })

  -- Mark clean after initial render (refresh will mark dirty on future stat updates).
  if _G.UltraStatisticsHeroicsTabState then
    _G.UltraStatisticsHeroicsTabState.dirty = false
  end
end
