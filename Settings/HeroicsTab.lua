-- Heroics Tab Content
-- Shows a list of heroic dungeons, each under a collapsible section.
function UltraStatistics_InitializeHeroicsTab(tabContents)
  if not tabContents or not tabContents[3] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[3].initialized then return end

  -- Mark as initialized
  tabContents[3].initialized = true

  local parent = tabContents[3]

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

  local function AttachBossSpellIds(instances)
    if type(instances) ~= 'table' then
      return instances
    end

    local all = _G.UltraStatisticsHeroicBossSpells
    if type(all) ~= 'table' then
      return instances
    end

    -- Per-instance boss name aliases (because the text source and the in-game boss name sometimes differ).
    local aliases = {
      hellfireRamparts = {
        ['Vazruden the Herald'] = 'Vazruden the Herald / Nazan',
      },
    }

    for _, inst in ipairs(instances) do
      local instanceKey = inst and inst.key
      local bossMap = instanceKey and all[instanceKey]
      local aliasMap = instanceKey and aliases[instanceKey]

      if type(bossMap) == 'table' and type(inst.bosses) == 'table' then
        for _, boss in ipairs(inst.bosses) do
          if type(boss) == 'table' then
            local name = boss.name or boss.title
            if type(name) == 'string' and name ~= '' then
              local ids = bossMap[name]
              if not ids and aliasMap and aliasMap[name] then
                ids = bossMap[aliasMap[name]]
              end
              if type(ids) == 'table' and #ids > 0 then
                boss.spellIds = ids
              end
            end
          end
        end
      end
    end

    return instances
  end

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

      -- MergeWithStored intentionally returns a *copy* that only includes known stat fields.
      -- Attach ability spellIds after merging so the UI can render the ability guide.
      instances = AttachBossSpellIds(instances)

      -- Replace the scroll child so we don't have to manually destroy old frames.
      -- Important: hide the old scroll child to prevent duplicate rows.
      if state.currentScrollChild and state.currentScrollChild.Hide then
        state.currentScrollChild:Hide()
      end

      local newChild = CreateFrame('Frame', nil, state.scrollFrame)
      newChild:SetSize(state.width, 300)
      state.scrollFrame:SetScrollChild(newChild)
      state.currentScrollChild = newChild

      -- Section header (even though there are no Classic heroics, this matches the Raids/Dungeons style)
      local SECTION_TITLE_HEIGHT = 22
      local DIVIDER_GAP = 6
      local AFTER_DIVIDER_GAP = 10
      local BOTTOM_PADDING = 20

      local tbcHeader = CreateFrame('Frame', nil, newChild)
      tbcHeader:SetSize(state.width, SECTION_TITLE_HEIGHT)
      tbcHeader:SetPoint('TOPLEFT', newChild, 'TOPLEFT', 0, -2)
      tbcHeader:SetPoint('TOPRIGHT', newChild, 'TOPRIGHT', 0, -2)

      local tbcTitle = tbcHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
      tbcTitle:SetPoint('LEFT', tbcHeader, 'LEFT', 4, 0)
      tbcTitle:SetText('The Burning Crusade')
      tbcTitle:SetTextColor(1, 0.82, 0, 1)

      local tbcDivider = newChild:CreateTexture(nil, 'BACKGROUND')
      tbcDivider:SetColorTexture(1, 1, 1, 0.15)
      tbcDivider:SetHeight(1)
      tbcDivider:SetPoint('TOPLEFT', tbcHeader, 'BOTTOMLEFT', 0, -DIVIDER_GAP)
      tbcDivider:SetPoint('TOPRIGHT', tbcHeader, 'BOTTOMRIGHT', 0, -DIVIDER_GAP)

      local listContainer = CreateFrame('Frame', nil, newChild)
      listContainer:SetPoint('TOPLEFT', tbcDivider, 'BOTTOMLEFT', 0, -AFTER_DIVIDER_GAP)
      listContainer:SetPoint('TOPRIGHT', tbcDivider, 'BOTTOMRIGHT', 0, -AFTER_DIVIDER_GAP)
      listContainer:SetSize(state.width, 1)

      local function updateScrollHeight()
        local totalHeight =
          2 +
          (tbcHeader:GetHeight() or SECTION_TITLE_HEIGHT) +
          DIVIDER_GAP + 1 + AFTER_DIVIDER_GAP +
          (listContainer:GetHeight() or 0) +
          BOTTOM_PADDING
        newChild:SetHeight(math.max(1, totalHeight))
      end

      UltraStatistics_CreateInstanceAccordionList({
        scrollChild = listContainer,
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
          updateScrollHeight()
        end,
      })

      updateScrollHeight()
      state.dirty = false
    end

    if C_Timer and C_Timer.After then
      C_Timer.After(0, doRebuild)
    else
      doRebuild()
    end
  end

  -- TBC 5-man instances (boss list from IsDungeonBoss; stats merged from stored DungeonRaidStats)
  local defaultHeroics = { {
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

  heroicsInstances = AttachBossSpellIds(heroicsInstances)

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
