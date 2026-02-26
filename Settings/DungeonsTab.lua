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
  end
  if not isTBC and tbcDivider and tbcDivider.Hide then
    tbcDivider:Hide()
  end

  local function ReflowSections()
    local state = _G.UltraStatisticsDungeonsTabState
    local classic = (state and state.classicContainer) or classicContainer
    local tbc = (state and state.tbcContainer) or tbcContainer
    local root = (state and state.currentScrollChild) or scrollChild

    if not (classic and root) then
      return
    end

    local totalHeight =
      2 +
      (classicHeader:GetHeight() or SECTION_TITLE_HEIGHT) +
      DIVIDER_GAP + 1 + AFTER_DIVIDER_GAP +
      (classic:GetHeight() or 0) +
      BOTTOM_PADDING

    if isTBC and tbc and tbcHeader and tbcDivider then
      tbcHeader:ClearAllPoints()
      tbcHeader:SetPoint('TOPLEFT', classic, 'BOTTOMLEFT', 0, -BETWEEN_SECTIONS_GAP)
      tbcHeader:SetPoint('TOPRIGHT', classic, 'BOTTOMRIGHT', 0, -BETWEEN_SECTIONS_GAP)

      tbcDivider:ClearAllPoints()
      tbcDivider:SetPoint('TOPLEFT', tbcHeader, 'BOTTOMLEFT', 0, -DIVIDER_GAP)
      tbcDivider:SetPoint('TOPRIGHT', tbcHeader, 'BOTTOMRIGHT', 0, -DIVIDER_GAP)

      tbc:ClearAllPoints()
      tbc:SetPoint('TOPLEFT', tbcDivider, 'BOTTOMLEFT', 0, -AFTER_DIVIDER_GAP)
      tbc:SetPoint('TOPRIGHT', tbcDivider, 'BOTTOMRIGHT', 0, -AFTER_DIVIDER_GAP)

      totalHeight = totalHeight +
        BETWEEN_SECTIONS_GAP +
        (tbcHeader:GetHeight() or SECTION_TITLE_HEIGHT) +
        DIVIDER_GAP + 1 + AFTER_DIVIDER_GAP +
        (tbc:GetHeight() or 0)
    end

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

      local showDeaths = (IsTBC and IsTBC())

      UltraStatistics_CreateInstanceAccordionList({
        scrollChild = newClassic,
        showDeaths = showDeaths,
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

      if isTBC then
      UltraStatistics_CreateInstanceAccordionList({
        scrollChild = newTBC,
        layout = state.layout,
        instances = tbcInstances,
        showDeaths = showDeaths,
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
      end

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

  -- Classic dungeons (stored under 'dungeons') with boss lists for tracking kills/deaths.
  local defaultClassicDungeons = { {
    key = 'ragefireChasm',
    title = 'Ragefire Chasm',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Oggleflint', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Taragaman the Hungerer', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Jergosh the Invoker', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Bazzalan', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true } },
  }, {
    key = 'deadmines',
    title = 'The Deadmines',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = "Rhahk'Zor", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Miner Johnson', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Sneed', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Gilnid', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Mr. Smite', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Captain Greenskin', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Edwin VanCleef', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true }, { name = 'Cookie', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 } },
  }, {
    key = 'wailingCaverns',
    title = 'Wailing Caverns',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Kresh', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Lady Anacondra', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Lord Cobrahn', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Deviate Faerie Dragon', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Lord Pythas', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Skum', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Lord Serpentis', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Verdan the Everliving', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Mutanus the Devourer', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true } },
  }, {
    key = 'shadowfangKeep',
    title = 'Shadowfang Keep',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Rethilgore', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Razorclaw the Butcher', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Baron Silverlaine', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Commander Springvale', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Odo the Blindwatcher', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Deathstalker Vincent', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Fenrus the Devourer', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Wolf Master Nandos', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Archmage Arugal', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true }, { name = 'Sever', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 } },
  }, {
    key = 'blackfathomDeeps',
    title = 'Blackfathom Deeps',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Ghamoo-ra', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Lady Sarevess', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Gelihast', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Lorgus Jett', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Baron Aquanis', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Twilight Lord Kelris', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Old Serra'kis", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Aku'mai", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true } },
  }, {
    key = 'stockades',
    title = 'The Stockade',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Targorr the Dread', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Kam Deepfury', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Hamhock', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Dextren Ward', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Bazil Thredd', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Bruegal Ironknuckle', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true } },
  }, {
    key = 'gnomeregan',
    title = 'Gnomeregan',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Grubbis', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Viscous Fallout', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Electrocutioner 6000', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Crowd Pummeler 9-60', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Mekgineer Thermaplugg', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true } },
  }, {
    key = 'razorfenKraul',
    title = 'Razorfen Kraul',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Roogug', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Aggem Thorncurse', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Death Speaker Jargba', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Overlord Ramtusk', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Agathelos the Raging', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Blind Hunter', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true } },
  }, {
    key = 'scarletMonastery',
    title = 'Scarlet Monastery',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Interrogator Vishas', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Bloodmage Thalnos', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Azshir the Sleepless', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Fallen Champion', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Ironspine', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Commander Mograine', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Houndmaster Loksey', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Herod', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Scarlet Commander Mograine', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'High Inquisitor Whitemane', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true }, { name = 'High Inquisitor Fairbanks', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Scarlet Commander', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 } },
  }, {
    key = 'razorfenDowns',
    title = 'Razorfen Downs',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = "Tuten'kash", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Mordresh Fire Eye', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Glutton', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Ragglesnout', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Death Speaker Blackhorn', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Amnennar the Coldbringer', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true }, { name = "Lady Falther'ess", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 } },
  }, {
    key = 'uldaman',
    title = 'Uldaman',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Revelosh', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Baelog', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Ironaya', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Obsidian Sentinel', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Ancient Stone Keeper', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Galgann Firehammer', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Grimlok', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Archaedas', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true } },
  }, {
    key = 'zulFarrak',
    title = "Zul'Farrak",
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = "Antu'sul", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Witch Doctor Zum'rah", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Shadowpriest Sezz'ziz", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Hydromancer Velratha', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Ruuzlu', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Sergeant Bly', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Sandfury Executioner', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Dustwraith', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Chief Ukorz Sandscalp', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true }, { name = 'Zerillis', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Sandarr Dunereaver', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Gahz'rilla", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 } },
  }, {
    key = 'maraudon',
    title = 'Maraudon',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Noxxion', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Razorlash', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Lord Vyletongue', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Celebras the Cursed', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Landslide', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Tinkerer Gizlock', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Rotgrip', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Princess Theradras', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true }, { name = 'Meshlok the Harvester', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 } },
  }, {
    key = 'sunkenTemple',
    title = "The Temple of Atal'Hakkar",
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Dreamscythe', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Weaver', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Hazzas', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Morphaz', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Jammal'an the Prophet", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Ogom the Wretched", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Avatar of Hakkar', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Shade of Eranikus', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Atal'alarion", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Eranikus', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true } },
  }, {
    key = 'blackrockDepths',
    title = 'Blackrock Depths',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Lord Roccor', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Fineous Darkvire', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'High Interrogator Gerstahn', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'General Angerforge', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Golem Lord Argelmach', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Lord Incendius', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Pyromancer Loregrain', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Ring of Law', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Phalanx', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Plugger Spazzring', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Ribbly Screwspigot', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Hurley Blackbreath', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Princess Moira Bronzebeard', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Emperor Dagran Thaurissan', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true }, { name = 'Houndmaster Grebmar', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Warder Stilgiss', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Warder Thelwater', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Warder Theldren', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 } },
  }, {
    key = 'blackrockSpire',
    title = 'Blackrock Spire',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Highlord Omokk', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Shadow Hunter Vosh'gajin", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'War Master Voone', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Mother Smolderweb', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Urok Doomhowl", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Quartermaster Zigris', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Gizrul the Slavener", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Halycon', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Overlord Wyrmthalak', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Pyroguard Emberseer', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Solakar Flamewrath', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Gyth', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Rend Blackhand', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'General Drakkisath', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true } },
  }, {
    key = 'stratholme',
    title = 'Stratholme',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Fras Siabi', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Skul', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Hearthsinger Forresten', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Timmy the Cruel', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Postmaster Malown', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Stonespine', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Baroness Anastari', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Nerub'enkan", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Cannon Master Willey', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Maleki the Pallid', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Baron Rivendare', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true }, { name = 'Malor the Zealous', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'The Unforgiven', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Balzaphon', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 } },
  }, {
    key = 'direMaul',
    title = 'Dire Maul',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Pusillin', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Guardian of the Gordok', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Hydrospawn', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Lethtendris', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Alzzin the Wildshaper', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Guard Mol'dar", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Stomper Kreeg', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Guard Fengus', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Guard Slip'kik", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Captain Kromcrush', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Cho'Rush the Observer", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true }, { name = 'King Gordok', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Illyanna Ravenoak', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Magister Kalendris', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Tendris Warpwood', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = "Immol'thar", totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Prince Tortheldrin', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Revanchion', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 } },
  }, {
    key = 'scholomance',
    title = 'Scholomance',
    totalClears = 0,
    totalDeaths = 0,
    firstClearDeaths = 0,
    bosses = { { name = 'Kirtonos the Herald', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Jandice Barov', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Rattlegore', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Marduk Blackpool', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Vectus', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Ras Frostwhisper', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Instructor Malicia', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Doctor Theolen Krastinov', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Lorekeeper Polkelt', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'The Ravenian', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Lady Illucia Barov', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Kormok', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 }, { name = 'Darkmaster Gandling', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0, isFinal = true }, { name = 'Lord Alexei Barov', totalKills = 0, totalDeaths = 0, firstClearDeaths = 0 } },
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
    showDeaths = isTBC,
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

  if isTBC then
  UltraStatistics_CreateInstanceAccordionList({
    scrollChild = tbcContainer,
    layout = layout,
    instances = tbcInstances,
    showDeaths = true,
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
  end

  -- Initial placement (after both lists have computed their heights).
  ReflowSections()

  -- Mark clean after initial render (refresh will mark dirty on future stat updates).
  if _G.UltraStatisticsDungeonsTabState then
    _G.UltraStatisticsDungeonsTabState.dirty = false
  end
end


