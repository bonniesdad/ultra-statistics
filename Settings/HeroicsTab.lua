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
    insets = { left = 5, right = 5, top = 5, bottom = 5 },
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
      collapsed = GLOBAL_SETTINGS.collapsedHeroicsSections[key] == true,
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
        if content then content:Hide() end
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

  local function CreateHeroicDungeonSection(dungeonKey, title, backgroundTexturePath, bosses)
    local header = CreateFrame('Frame', nil, scrollChild, 'BackdropTemplate')
    header:SetSize(435, layout.SECTION_HEADER_HEIGHT)
    header:SetBackdrop({
      bgFile = 'Interface\\Buttons\\WHITE8X8',
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      tile = true,
      tileSize = 8,
      edgeSize = 12,
      insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    header:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
    header:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)

    local label = header:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    label:SetPoint('LEFT', header, 'LEFT', 24, 0)
    label:SetText(title or dungeonKey)
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
      insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    content:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
    content:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

    -- Background image
    if backgroundTexturePath and backgroundTexturePath ~= '' then
      local bg = content:CreateTexture(nil, 'BACKGROUND')
      bg:SetAllPoints()
      bg:SetTexture(backgroundTexturePath)
      bg:SetAlpha(0.55)

      -- Darken overlay for text readability
      local shade = content:CreateTexture(nil, 'BORDER')
      shade:SetAllPoints()
      shade:SetColorTexture(0, 0, 0, 0.45)
    end

    local bossesTitle = content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    bossesTitle:SetPoint('TOPLEFT', content, 'TOPLEFT', 12, -10)
    bossesTitle:SetText('Bosses')
    bossesTitle:SetTextColor(1, 0.95, 0.7, 1)

    local lineHeight = 16
    local yOffset = -30
    local bossCount = 0
    if type(bosses) == 'table' then
      for _, bossName in ipairs(bosses) do
        if type(bossName) == 'string' and bossName ~= '' then
          bossCount = bossCount + 1
          local bossLine = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          bossLine:SetPoint('TOPLEFT', content, 'TOPLEFT', 18, yOffset)
          bossLine:SetText('- ' .. bossName)
          bossLine:SetJustifyH('LEFT')
          bossLine:SetTextColor(0.95, 0.95, 0.9, 1)
          yOffset = yOffset - lineHeight
        end
      end
    end

    -- Resize content height to fit boss list
    local minHeight = 90
    local computedHeight = 10 + 20 + (bossCount * lineHeight) + 18
    content:SetHeight(math.max(minHeight, computedHeight))

    local section = addSection(header, content, dungeonKey)
    makeHeaderClickable(section)
    return section
  end

  -- For now: only Hellfire Ramparts
  CreateHeroicDungeonSection(
    'hellfireRamparts',
    'Hellfire Ramparts',
    'Interface\\AddOns\\UltraStatistics\\Textures\\heroics\\hellfire-ramparts.png',
    {
      'Watchkeeper Gargolmar',
      'Omor the Unscarred',
      'Vazruden the Herald',
      'Nazan',
    }
  )

  updateSectionPositions()

end
