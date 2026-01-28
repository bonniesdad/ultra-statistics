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

  local sections = {}

  local function addSection(header, content, key)
    local section = {
      header = header,
      content = content,
      key = key,
      -- Default to collapsed when unset; store explicit false when user expands.
      collapsed = GLOBAL_SETTINGS.collapsedHeroicsSections[key] ~= false,
      _updateIcon = nil,
    }
    table.insert(sections, section)
    return section
  end

  local function updateSectionPositions()
    local y = -5
    for _, section in ipairs(sections) do
      local header = section.header
      local content = section.content
      if header then
        header:ClearAllPoints()
        header:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 0, y)
      end

      local headerHeight = (header and header:GetHeight()) or layout.SECTION_HEADER_HEIGHT
      if section.collapsed then
        if content then
          content:Hide()
        end
        y = y - headerHeight - layout.SECTION_SPACING
      else
        if content then
          content:Show()
          content:ClearAllPoints()
          -- Flush accordion: no gap between header/content, no left indent.
          content:SetPoint('TOPLEFT', header, 'BOTTOMLEFT', 0, 0)
          local contentHeight = content:GetHeight() or 0
          y = y - headerHeight - contentHeight - layout.SECTION_SPACING
        else
          y = y - headerHeight - layout.SECTION_SPACING
        end
      end
    end

    scrollChild:SetHeight(math.max(1, -y + 20))
  end

  local function makeHeaderClickable(section)
    if not section or not section.header then return end

    local header = section.header
    local key = section.key

    local collapseIcon = header:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    collapseIcon:SetPoint('LEFT', header, 'LEFT', 10, 0)
    collapseIcon:SetTextColor(0.9, 0.85, 0.75, 1)
    collapseIcon:SetShadowOffset(1, -1)
    collapseIcon:SetShadowColor(0, 0, 0, 0.8)

    local function updateIcon()
      collapseIcon:SetText(section.collapsed and '+' or '-')
    end
    section._updateIcon = updateIcon
    updateIcon()

    header:EnableMouse(true)
    header:SetScript('OnMouseDown', function(_, button)
      if button ~= 'LeftButton' then return end
      section.collapsed = not section.collapsed
      GLOBAL_SETTINGS.collapsedHeroicsSections[key] = section.collapsed and true or false
      if section._updateIcon then
        section._updateIcon()
      end
      updateSectionPositions()
    end)

    header:SetScript('OnEnter', function(self)
      self:SetBackdropColor(0.2, 0.2, 0.28, 0.95)
      self:SetBackdropBorderColor(0.6, 0.6, 0.75, 1)
    end)
    header:SetScript('OnLeave', function(self)
      self:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
      self:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
    end)
  end

  -- Show "-" for zero/nil stats instead of 0
  local function formatStat(val)
    if val == nil or val == 0 then
      return '-'
    end
    return tostring(val)
  end

  -- Reusable helper to slugify titles/boss names into file/folder-friendly keys
  local function SlugifyName(name)
    if not name or type(name) ~= 'string' then
      return ''
    end
    local slug = name:lower()
    -- Replace spaces with dashes
    slug = slug:gsub('%s+', '-')
    -- Remove characters that are likely not in filenames (quotes, commas etc.)
    slug = slug:gsub('["\'%.,!%?]', '')
    -- Collapse multiple dashes
    slug = slug:gsub('%-+', '-')
    return slug
  end

  -- Generic, reusable collapsible section builder for heroics/raids.
  -- Takes a single "instance" object with:
  -- {
  --   key = 'hellfireRamparts',
  --   title = 'Hellfire Ramparts',
  --   totalClears = number,
  --   totalDeaths = number,
  --   firstClearDeaths = number,
  --   bosses = {
  --     {
  --       name = 'Watchkeeper Gargolmar',
  --       totalKills = number,
  --       totalDeaths = number,
  --       firstClearDeaths = number,
  --       isFinal = boolean,
  --     },
  --     ...
  --   }
  -- }
  local function CreateInstanceSection(instance)
    if type(instance) ~= 'table' then return end

    local dungeonKey = instance.key or SlugifyName(instance.title or '')
    if not dungeonKey or dungeonKey == '' then return end

    local title = instance.title or dungeonKey

    local header = CreateFrame('Frame', nil, scrollChild, 'BackdropTemplate')
    header:SetSize(435, layout.SECTION_HEADER_HEIGHT)
    header:SetBackdrop({
      bgFile = 'Interface\\Buttons\\WHITE8X8',
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      tile = true,
      tileSize = 8,
      edgeSize = 12,
      insets = {
        left = 3,
        right = 3,
        top = 3,
        bottom = 3,
      },
    })
    header:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
    header:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)

    local label = header:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    label:SetPoint('LEFT', header, 'LEFT', 24, 0)
    label:SetText(title)
    label:SetTextColor(0.9, 0.85, 0.75, 1)
    label:SetShadowOffset(1, -1)
    label:SetShadowColor(0, 0, 0, 0.8)

    local content = CreateFrame('Frame', nil, scrollChild, 'BackdropTemplate')
    -- Match header width; since we're no longer indenting, keep content flush/full width.
    content:SetSize(435, 120)
    content:SetBackdrop({
      bgFile = 'Interface\\Buttons\\WHITE8X8',
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      tile = true,
      tileSize = 8,
      edgeSize = 10,
      insets = {
        left = 3,
        right = 3,
        top = 3,
        bottom = 3,
      },
    })
    content:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
    content:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

    -- Determine texture folder from the instance title
    local folderSlug = SlugifyName(title)
    local baseTexturePath =
      'Interface\\AddOns\\UltraStatistics\\Textures\\heroics\\' .. folderSlug .. '\\bg.png'

    -- Background image: fixed height so it doesn't stretch when panel grows; width fills content
    local bgHeight = 200
    local bg = content:CreateTexture(nil, 'BACKGROUND')
    bg:SetPoint('TOPLEFT', content, 'TOPLEFT', 2, -2)
    bg:SetPoint('TOPRIGHT', content, 'TOPRIGHT', -2, -2)
    bg:SetHeight(bgHeight)
    bg:SetTexture(baseTexturePath)
    bg:SetAlpha(0.8)

    local bosses = instance.bosses or {}

    -- Work out if the instance is "complete" by checking kills on the final boss.
    local hasFinalBossKill = false
    if type(bosses) == 'table' and #bosses > 0 then
      local finalIndex = nil
      for index, boss in ipairs(bosses) do
        if type(boss) == 'table' and boss.isFinal then
          finalIndex = index
          break
        end
      end
      if not finalIndex then
        finalIndex = #bosses
      end

      local finalBoss = bosses[finalIndex]
      if type(finalBoss) == 'table' then
        local kills = finalBoss.totalKills or finalBoss.kills or 0
        if kills > 0 then
          hasFinalBossKill = true
        end
      end
    end

    -- If we have at least 1 kill on the final boss, mark the whole card as "complete" with a green border.
    if hasFinalBossKill then
      content:SetBackdropBorderColor(0.1, 0.8, 0.1, 1)
      header:SetBackdropBorderColor(0.1, 0.8, 0.1, 1)
    end

    -- Summary stats block (top): label + clear stat lines
    local totalClears = instance.totalClears or 0
    local totalDeaths = instance.totalDeaths or 0
    local firstClearDeaths = instance.firstClearDeaths or 0

    local summaryLabel = content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    summaryLabel:SetPoint('TOPLEFT', content, 'TOPLEFT', 12, -10)
    summaryLabel:SetText('Summary')
    summaryLabel:SetTextColor(1, 0.95, 0.75, 1)
    summaryLabel:SetShadowOffset(1, -1)
    summaryLabel:SetShadowColor(0, 0, 0, 0.9)

    local summaryGap = 2
    local summaryLine1 = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    summaryLine1:SetPoint('TOPLEFT', summaryLabel, 'BOTTOMLEFT', 0, -4)
    summaryLine1:SetText(
      string.format(
        '|cffb0b0b0First attempt deaths:|r |cffffffff%s|r',
        formatStat(firstClearDeaths)
      )
    )
    summaryLine1:SetShadowOffset(1, -1)
    summaryLine1:SetShadowColor(0, 0, 0, 0.8)

    local summaryLine2 = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    summaryLine2:SetPoint('TOPLEFT', summaryLine1, 'BOTTOMLEFT', 0, -summaryGap)
    summaryLine2:SetText(
      string.format('|cffb0b0b0Clears:|r |cffffffff%s|r', formatStat(totalClears))
    )
    summaryLine2:SetShadowOffset(1, -1)
    summaryLine2:SetShadowColor(0, 0, 0, 0.8)

    local summaryLine3 = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    summaryLine3:SetPoint('TOPLEFT', summaryLine2, 'BOTTOMLEFT', 0, -summaryGap)
    summaryLine3:SetText(
      string.format('|cffb0b0b0Deaths:|r |cffffffff%s|r', formatStat(totalDeaths))
    )
    summaryLine3:SetShadowOffset(1, -1)
    summaryLine3:SetShadowColor(0, 0, 0, 0.8)

    -- Boss rows: each boss gets its own row with image, name, divider and stats
    local bossesTitle = content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    bossesTitle:SetPoint('TOPLEFT', content, 'TOPLEFT', 12, -78)
    bossesTitle:SetText('Bosses')
    bossesTitle:SetTextColor(1, 0.95, 0.75, 1)
    bossesTitle:SetShadowOffset(1, -1)
    bossesTitle:SetShadowColor(0, 0, 0, 0.9)

    local bossCount = 0
    local rowHeight = 86
    local rowSpacing = 6
    local previousRow = nil

    if type(bosses) == 'table' then
      for _, boss in ipairs(bosses) do
        local bossName
        local totalBossKills = 0
        local totalBossDeaths = 0
        local firstBossDeaths = 0

        if type(boss) == 'table' then
          bossName = boss.name or boss.title
          totalBossKills = boss.totalKills or boss.kills or 0
          totalBossDeaths = boss.totalDeaths or boss.deaths or 0
          firstBossDeaths = boss.firstClearDeaths or boss.firstDeaths or 0
        elseif type(boss) == 'string' then
          bossName = boss
        end

        if type(bossName) == 'string' and bossName ~= '' then
          bossCount = bossCount + 1

          local row = CreateFrame('Frame', nil, content, 'BackdropTemplate')
          row:SetSize(435 - 24, rowHeight)
          row:SetBackdrop({
            bgFile = 'Interface\\Buttons\\WHITE8X8',
            edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
            tile = true,
            tileSize = 8,
            edgeSize = 10,
            insets = {
              left = 2,
              right = 2,
              top = 2,
              bottom = 2,
            },
          })
          row:SetBackdropColor(0, 0, 0, 0.25)
          row:SetBackdropBorderColor(0.15, 0.15, 0.18, 0.8)

          if previousRow then
            row:SetPoint('TOPLEFT', previousRow, 'BOTTOMLEFT', 0, -rowSpacing)
          else
            row:SetPoint('TOPLEFT', bossesTitle, 'BOTTOMLEFT', 0, -6)
          end

          -- Boss image on the left (top padding from row)
          local rowTopPadding = 10
          local icon = row:CreateTexture(nil, 'ARTWORK')
          icon:SetSize(128, 64)
          icon:SetPoint('TOPLEFT', row, 'TOPLEFT', 4, -rowTopPadding)

          local bossSlug = SlugifyName(bossName)
          local bossTexturePath =
            'Interface\\AddOns\\UltraStatistics\\Textures\\heroics\\' .. folderSlug .. '\\' .. bossSlug .. '.png'
          icon:SetTexture(bossTexturePath)
          icon:SetTexCoord(0, 1, 0, 1)

          -- Boss name on the right of the image (more gap from top of row)
          local nameFS = row:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
          nameFS:SetPoint('TOPLEFT', icon, 'TOPRIGHT', 8, 0)
          nameFS:SetText(bossName)
          nameFS:SetTextColor(1, 0.97, 0.9, 1)
          nameFS:SetShadowOffset(1, -1)
          nameFS:SetShadowColor(0, 0, 0, 0.9)

          -- Divider below the name (more gap between title and divider)
          local titleToDividerGap = 8
          local divider = row:CreateTexture(nil, 'BACKGROUND')
          divider:SetColorTexture(1, 1, 1, 0.15)
          divider:SetHeight(1)
          divider:SetPoint('TOPLEFT', nameFS, 'BOTTOMLEFT', 0, -titleToDividerGap)
          divider:SetPoint('RIGHT', row, 'RIGHT', -4, 0)

          -- Details below the divider: each stat on its own row
          local dividerToBodyGap = 8
          local detailsGap = 2
          local detailsLine1 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          detailsLine1:SetPoint('TOPLEFT', divider, 'BOTTOMLEFT', 0, -dividerToBodyGap)
          detailsLine1:SetJustifyH('LEFT')
          detailsLine1:SetShadowOffset(1, -1)
          detailsLine1:SetShadowColor(0, 0, 0, 0.8)
          detailsLine1:SetText(
            string.format(
              '|cffa0a0a0First attempt deaths:|r |cffffffff%s|r',
              formatStat(firstBossDeaths)
            )
          )

          local detailsLine2 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          detailsLine2:SetPoint('TOPLEFT', detailsLine1, 'BOTTOMLEFT', 0, -detailsGap)
          detailsLine2:SetJustifyH('LEFT')
          detailsLine2:SetShadowOffset(1, -1)
          detailsLine2:SetShadowColor(0, 0, 0, 0.8)
          detailsLine2:SetText(
            string.format('|cffa0a0a0Kills:|r |cffffffff%s|r', formatStat(totalBossKills))
          )

          local detailsLine3 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          detailsLine3:SetPoint('TOPLEFT', detailsLine2, 'BOTTOMLEFT', 0, -detailsGap)
          detailsLine3:SetJustifyH('LEFT')
          detailsLine3:SetShadowOffset(1, -1)
          detailsLine3:SetShadowColor(0, 0, 0, 0.8)
          detailsLine3:SetText(
            string.format('|cffa0a0a0Deaths:|r |cffffffff%s|r', formatStat(totalBossDeaths))
          )

          -- Green border if more than one kill on this boss
          if totalBossKills > 1 then
            row:SetBackdropBorderColor(0.1, 0.8, 0.1, 1)
          end

          previousRow = row
        end
      end
    end

    -- Resize content height to fit boss rows
    local minHeight = 110
    local computedHeight = 88 + (bossCount * (rowHeight + rowSpacing))
    content:SetHeight(math.max(minHeight, computedHeight))

    local section = addSection(header, content, dungeonKey)
    makeHeaderClickable(section)
    return section
  end

  -- TBC 5-man instances (boss list derived from the IDs in Functions/Checks/IsDungeonBoss.lua)
  local heroicsInstances = { {
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

  for _, instance in ipairs(heroicsInstances) do
    CreateInstanceSection(instance)
  end

  updateSectionPositions()
end
